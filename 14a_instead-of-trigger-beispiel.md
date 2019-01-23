# Instead Of Trigger - Beispiel

## Tabellen





## View

 SELECT
     k.kde_id,
     k.kde_name,
     k.kde_kommentar,
     ka.kda_id,
     ka.kda_adresstyp,
     a.adr_id,
     a.adr_plz,
     a.adr_ort,
     a.adr_strasse,
     a.adr_zusatz1,
     a.adr_zusatz2,
     a.adr_kommentar,
     a.adr_name
 FROM
     sn_kunden k
     INNER JOIN sn_kunde_adressen ka ON k.kde_id = ka.kda_kde_id
     INNER JOIN sn_adressen a ON a.adr_id = ka.kda_adr_id;

## Trigger

create or replace trigger io_sn_kundenadressen
instead of insert or update on sn_kundenadressen
declare
    v_kde_id sn_kunden.kde_id%type;
    v_kda_id sn_kunde_adressen.kda_id%type;
    v_adr_id sn_adressen.adr_id%type;
begin
    if inserting then
        insert into sn_kunden (kde_id, kde_name, kde_kommentar)
        values (NULL, :new.kde_name, :new.kde_kommentar);
        v_kde_id := sn_sequence.currval;
        
        insert into sn_adressen (adr_id, adr_plz, adr_ort, adr_strasse, adr_zusatz1, adr_zusatz2, adr_kommentar, adr_name)
        values (NULL, :new.adr_plz, :new.adr_ort, :new.adr_strasse, :new.adr_zusatz1, :new.adr_zusatz2, :new.adr_kommentar, :new.adr_name);      
        v_adr_id := sn_sequence.currval;
        
        insert into sn_kunde_adressen (kda_id, kda_adr_id, kda_kde_id, kda_adresstyp)
        values (NULL, v_adr_id, v_kde_id, :new.kda_adresstyp);
        
    end if;
    
    if updating then
        update sn_kunden
        set kde_name = :new.kde_name, kde_kommentar = :new.kde_kommentar
        where kde_id = :new.kde_id;
        
        update sn_adressen
        set adr_plz = :new.adr_plz, adr_ort = :new.adr_ort, adr_strasse = :new.adr_strasse, adr_zusatz1 = :new.adr_zusatz1, 
        adr_zusatz2 = :new.adr_zusatz2, adr_kommentar = :new.adr_kommentar, adr_name = :new.adr_name
        where adr_id = :new.adr_id;
        
        update sn_kunde_adressen
        set kda_adr_id = :new.adr_id, kda_kde_id = :new.kde_id
        where kda_id = :new.kda_id;
        
    end if;
    
end;