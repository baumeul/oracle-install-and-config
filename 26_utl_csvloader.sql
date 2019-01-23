--------------------------------------------------------
--  DDL for Package UTL_CSVLOADER
--------------------------------------------------------

CREATE OR REPLACE EDITIONABLE PACKAGE "UTL_CSVLOADER" AS
  FUNCTION HEX2DEC (p_HexStr IN VARCHAR2) RETURN NUMBER;
  PROCEDURE load_csv_files;
  PROCEDURE load_csv_files_old (p_bank IN VARCHAR2);
  PROCEDURE load_blob_content (p_id IN NUMBER);
  PROCEDURE einfuegen_buchungsdaten(p_id IN NUMBER, p_fileName IN VARCHAR2, p_blobContent BLOB);
  PROCEDURE INSERT_INTO_TEMP (p_id IN NUMBER);
END UTL_CSVLOADER;

/
--------------------------------------------------------
--  DDL for Package Body UTL_CSVLOADER
--------------------------------------------------------

CREATE OR REPLACE EDITIONABLE PACKAGE BODY "UTL_CSVLOADER" AS

  FUNCTION HEX2DEC (p_HexStr IN VARCHAR2) RETURN NUMBER AS
    v_Dec NUMBER;
    v_Hex VARCHAR2(16) := '0123456789ABCDEF';
    Hex2DecError EXCEPTION;
  BEGIN
      v_Dec := 0;
      FOR indx IN 1 .. LENGTH(p_HexStr)
      LOOP
        v_Dec := v_Dec * 16 + INSTR(v_Hex, UPPER(SUBSTR(p_HexStr, indx, 1))) - 1;
      END LOOP;
      RETURN v_Dec;
  EXCEPTION
    WHEN Hex2DecError THEN
        INSERT INTO ums_log (log) VALUES ('Fehler in Fuction hex2dec');
  END HEX2DEC;

  /*
    load_csv_files liest alle Records aus APEX_APPLICATION_TEMP_FILES
    und schreibt sie in ums_csvfiles.
  */
  PROCEDURE load_csv_files AS
    v_fileName    UMS_CSVFILES.FIL_FILENAME%TYPE;
    v_mimeType    UMS_CSVFILES.FIL_MIME_TYPE%TYPE;
    v_blobContent UMS_CSVFILES.FIL_BLOB_CONTENT%TYPE;
    v_id          UMS_CSVFILES.FIL_ID%TYPE;
    LoadCsvFilesError EXCEPTION;
    CURSOR c_files IS  -- Cursor für APEX_APLLICATION_TEMP_FILES
      SELECT filename, mime_type, blob_content
      FROM APEX_APPLICATION_TEMP_FILES;
  BEGIN
    OPEN c_files;
    LOOP
      FETCH c_files INTO v_fileName, v_mimeType, v_blobContent;
      EXIT WHEN c_files%NOTFOUND;
      v_id := immo_seq.NEXTVAL;
      -- Einen Datensatz in ums_csvfiles schreiben
      INSERT INTO ums_csvfiles (fil_id, fil_filename, fil_mime_type,
        fil_created_on, fil_blob_content, fil_updated_on)
      VALUES (v_id, v_filename, v_mimetype, SYSDATE, v_blobContent, SYSDATE);
      -- Debug only
      -- INSERT INTO ums_log (log) VALUES ('INSERT '||v_id||' '||v_filename);
      -- Für diesen Datensatz mit dem PK v_id blob_content lesen, konvertieren
      -- und in ums_buchungsdaten schreiben
      /*
        Procedure <load_blob_content(v_id)>. Für diesen Datensatz <blob_content>
        in <ums_buchungsdaten> schreiben.
      */
      utl_csvloader.load_blob_content(v_id);
    END LOOP;
    CLOSE c_files;
    COMMIT;
  EXCEPTION
    WHEN LoadCsvFilesError THEN
        INSERT INTO ums_log (log) VALUES ('LOAD_CSV_FILES: Fehler in Function.');
    WHEN DUP_VAL_ON_INDEX THEN
        INSERT INTO ums_log (log) VALUES ('LOAD_CSV_FILES: Doppelter Wert beim INSERT.');
  END;
  /*
    load_blob_content liest das Blob-Feld aus ums_csvfiles und ruft die
    Procedure einfuegen_buchungsdaten() auf. Schreibt Buchungsdatum in
    ums_csvfiles.
  */
  PROCEDURE load_blob_content (p_id IN NUMBER) AS
    v_fileName    UMS_CSVFILES.FIL_FILENAME%TYPE;
    v_mimeType    UMS_CSVFILES.FIL_MIME_TYPE%TYPE;
    v_blobContent UMS_CSVFILES.FIL_BLOB_CONTENT%TYPE;
    v_id          UMS_CSVFILES.FIL_ID%TYPE;
    v_code        NUMBER;
    v_errm        VARCHAR2(64);
    v_DateMin     DATE;
    v_DateMax     DATE;
    CURSOR c_blob_content IS
        SELECT fil_id, fil_filename, fil_blob_content
        FROM ums_csvfiles
        WHERE fil_id = p_id;
  BEGIN
    OPEN c_blob_content;
    LOOP
        -- Hole einen Datensatz aus utl_csvfiles.
        FETCH c_blob_content INTO v_id, v_fileName, v_blobContent;
        EXIT WHEN c_blob_content%NOTFOUND;
        -- Debug only
        -- INSERT INTO ums_log (log) VALUES ('FETCH '||v_id||' '||v_filename);
        --
        -- Einfügen Buchungsdaten in ums_buchungen.
        -- v_id : PK, v_fileName : die zu lesende Csv-Datei,
        -- v_blobContent : die eigentlichen Csv-Daten.
        --
        utl_csvloader.einfuegen_buchungsdaten(v_id, v_fileName, v_blobContent);
        -- Start- und Enddatum
        SELECT MIN(buchungsdatum), MAX(buchungsdatum) INTO v_DateMin, v_DateMax
        FROM ums_dates;
        UPDATE ums_csvfiles
            SET fil_date_start  = v_DateMin,
                fil_date_end    = v_DateMax
            WHERE fil_id = p_id;
    END LOOP;
    CLOSE c_blob_content;
  EXCEPTION
    WHEN OTHERS THEN
        v_code := SQLCODE;
        v_errm := SQLERRM;
        INSERT INTO ums_log (log) VALUES ('ERROR load_blob_content: ' || v_code || '- ' || v_errm);
  END;
  /*
    einfuegen_buchungsdaten fügt Datensätze, die aus v_blobContent geholt
    wurden in *IM_UMSAETZE* ein. Konvertiert vorher Blob in String.
  */
  PROCEDURE einfuegen_buchungsdaten(p_id IN NUMBER, p_fileName IN VARCHAR2, p_blobContent BLOB) AS
    v_buchungstag       ums_buchungen.ums_buchungstag%type;
    v_wertstellung      ums_buchungen.ums_wertstellung%type;
    v_auftraggeber      ums_buchungen.ums_auftraggeber%type;
    v_verwendungszweck  ums_buchungen.ums_verwendungszweck%type;
    v_kontonummer       ums_buchungen.ums_kontonummer%type;
    v_bank              ums_buchungen.ums_bank%type;
    v_betrag            ums_buchungen.ums_betrag%type;
    v_waehrung          ums_buchungen.ums_waehrung%type;
    v_id                ums_buchungen.ums_id%TYPE;
    v_ObjId             im_objekte.obj_id%TYPE;
    v_BlobLen           NUMBER;
    v_Position          NUMBER;
    v_RawChunk          RAW(10000);
    --v_Char              CHAR(1);
    v_Char              VARCHAR(2);
    v_ChunkLen          NUMBER := 1;
    v_Line              VARCHAR2(32767) := NULL;
    v_LineNew           VARCHAR2(32767) := NULL;
    v_DataArray         apex_application_global.vc_arr2;
    v_LineCnt           NUMBER;
    v_code              NUMBER;
    v_errm              VARCHAR2(64);
    v_CharNumber        NUMBER;
  BEGIN
    v_BlobLen   := dbms_lob.getlength(p_blobContent);
    v_Position  := 1;
    v_LineCnt   := 1;

    WHILE (v_Position <= v_BlobLen)
    LOOP
        v_RawChunk  := dbms_lob.SUBSTR(p_blobContent, v_ChunkLen, v_Position);
        /*
            Konvertiere ein hex-Zeichen in Character. v_CharNumber enthält
            den dez-Wert des hex-Zeichens aus Blob.
        */
        v_CharNumber := UTL_CSVLOADER.HEX2DEC(RAWTOHEX(v_RawChunk));

        IF v_CharNumber = 195 THEN
            v_Char := NULL; -- 195 ist der Dez.Wert des ersten Bytes eines Unicode-Zeichens 'ä'
        ELSIF v_CharNumber = 164 THEN
            v_Char := 'ä';  -- 164 ist der Dez.Wert des zweiten Bytes des Unicode-Zeichens 'ä'
        ELSIF v_CharNumber = 182 THEN
            v_Char := 'ö';
        ELSIF v_CharNumber = 188 THEN
            v_Char := 'ü';
        ELSIF v_CharNumber = 132 THEN
            v_Char := 'Ä';
        ELSIF v_CharNumber = 150 THEN
            v_Char := 'Ö';
        ELSIF v_CharNumber = 156 THEN
            v_Char := 'Ü';
        ELSIF v_CharNumber = 159 THEN
            v_Char := 'ß';
        ELSE
            v_Char := CHR(v_CharNumber); --kein Unicodezeichen
        END IF;

        -- v_Char      := CHR(UTL_CSVLOADER.HEX2DEC(RAWTOHEX(v_RawChunk)));
        v_Line      := v_Line || v_Char;
        v_Position  := v_Position + v_ChunkLen;
        -- NEW Begin
        -- NEW End
        -- When a whole line is retrieved
        IF v_Char = CHR(10) THEN -- CHR(10) is LF
          v_Line := REPLACE(v_line, '"', '');

          -- Convert each column separeted by ';' into array of data
          v_DataArray := APEX_UTIL.string_to_table (v_Line, ';');

          -- Debug only
          INSERT INTO ums_log (log) VALUES ('v_Line '||v_Line||' p_FileName: '||p_FileName);

          SELECT obj_id INTO v_ObjId
            FROM v_obj_id_kontonummer
            WHERE obj_name_kurz = RTRIM(p_fileName, '.csv');

          -- Insert data-fields into target table *ums_buchungen*
          IF v_LineCnt > 1 THEN
            -- Insert Start- and End Dates into tmp_start_end_date
            v_id                := p_id;
            v_buchungstag       := TO_DATE(v_DataArray(1),'DD.MM.YY');
            v_wertstellung      := TO_DATE(v_DataArray(2),'DD.MM.YY');
            v_auftraggeber      := v_DataArray(4);
            v_verwendungszweck  := v_DataArray(5);
            v_kontonummer       := v_DataArray(6);
            v_bank              := v_DataArray(7);
            v_betrag            := TO_NUMBER(v_DataArray(8), '999999D00');
            v_waehrung          := v_DataArray(9);
            INSERT INTO ums_dates (buchungsdatum) VALUES (v_buchungstag);
            INSERT INTO im_umsaetze (ums_buchungstag, ums_wertstellung,
                ums_auftraggeber, ums_verwendungszweck, ums_kontonummer,
                ums_bank, ums_betrag, ums_waehrung, ums_obj_id, ums_filename,
                ums_fil_id, ums_datum_hochgeladen, ums_datum_aenderung)
            VALUES (v_buchungstag, v_wertstellung, v_auftraggeber,
                v_verwendungszweck, v_kontonummer, v_bank, v_betrag,
                v_waehrung, v_ObjId, p_fileName, v_id, SYSDATE, SYSDATE);
          END IF;
          -- Clear out
          v_Line := NULL;
          v_LineCnt := v_LineCnt + 1;
        END IF;
    END LOOP;
    EXCEPTION
    WHEN OTHERS THEN
        v_code := SQLCODE;
        v_errm := SQLERRM;
        INSERT INTO ums_log (log) VALUES ('ERROR einfuegen_buchungsdaten: ' || v_code || '- ' || v_errm);
  END;

  /*
    load_csv_files_old für die alten Kontoauszüge von DB, KB und SK. Liest alle Records aus APEX_APPLICATION_TEMP_FILES
    und schreibt sie in ums_csvfiles. Startet load_blob_content (Umsätze schreiben).
  */
  PROCEDURE load_csv_files_old (p_bank IN VARCHAR2) AS
    v_fileName    UMS_CSVFILES.FIL_FILENAME%TYPE;
    v_mimeType    UMS_CSVFILES.FIL_MIME_TYPE%TYPE;
    v_blobContent UMS_CSVFILES.FIL_BLOB_CONTENT%TYPE;
    v_id          UMS_CSVFILES.FIL_ID%TYPE;
    v_code        NUMBER;
    v_errm        VARCHAR2(64);
    LoadCsvFilesError EXCEPTION;
    CURSOR c_files IS  -- Cursor für APEX_APLLICATION_TEMP_FILES
      SELECT filename, mime_type, blob_content
      FROM APEX_APPLICATION_TEMP_FILES;
  BEGIN
    OPEN c_files;
    LOOP
      FETCH c_files INTO v_fileName, v_mimeType, v_blobContent;
      EXIT WHEN c_files%NOTFOUND;
      v_id := immo_seq.NEXTVAL;
      -- Einen Datensatz in ums_csvfiles schreiben
      INSERT INTO ums_csvfiles (fil_id, fil_filename, fil_mime_type,
        fil_created_on, fil_blob_content, fil_updated_on)
      VALUES (v_id, v_filename, v_mimetype, SYSDATE, v_blobContent, SYSDATE);
      -- Für diesen Datensatz:
      -- 1. Schreibe alle DS aus dem Blob-Feld in die temporäre Tabelle ums_temp.
      UTL_CSVLOADER.INSERT_INTO_TEMP (v_id);
      -- 2. Abhängig von der Bank, Kopf- und Fusszeilen löschen.
      -- 3. Inhalt von ums_temp.line in Felder splitten und in ums_buchungen schreiben.
      -- utl_csvloader.load_blob_content(v_id);
    END LOOP;
    CLOSE c_files;
    COMMIT;
  EXCEPTION
    WHEN LoadCsvFilesError THEN
        INSERT INTO ums_log (log) VALUES ('LOAD_CSV_FILES: Fehler in Function.');
    WHEN DUP_VAL_ON_INDEX THEN
        INSERT INTO ums_log (log) VALUES ('LOAD_CSV_FILES: Doppelter Wert beim INSERT.');
  END;

  PROCEDURE INSERT_INTO_TEMP (p_id IN NUMBER) AS
  BEGIN
    NULL;
  END;

END UTL_CSVLOADER;

/

