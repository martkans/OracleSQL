drop trigger plebs_iu;
drop trigger elita_iu;

create or replace trigger plebs_iu
    before insert or update
    on PLEBS
    for each row
declare
    cursor psueda_elity is select PSEUDO
                           from elita;
begin
    for pseudo_e in psueda_elity
        loop
            if :new.pseudo = pseudo_e.PSEUDO then
                raise_application_error(-20001, 'Kot o danym pseudonimie istnieje już w relacji ELITA');
            end if;
        end loop;
end;

create or replace trigger elita_iu
    before insert or update
    on ELITA
    for each row
declare
    cursor psueda_plebsu is select PSEUDO
                           from PLEBS;
begin
    for pseudo_p in psueda_plebsu
        loop
            if pseudo_p.PSEUDO = :new.pseudo then
                raise_application_error(-20001, 'Kot o danym pseudonimie istnieje już w relacji PLEBS');
            end if;
        end loop;
end;
