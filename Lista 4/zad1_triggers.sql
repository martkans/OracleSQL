-- nie sprawdzałem dokładnie tych triggerów

drop trigger plebs_r_iu;
drop trigger elita_r_iu;
drop trigger incydenty_r_iu;

create or replace trigger plebs_r_iu
    before insert or update
    on PLEBS_R
    for each row
declare
    cursor elity is select deref(KOT).PSEUDO ps
                    from elita_R;
    cursor plebsy is select deref(KOT).PSEUDO ps
                     from PLEBS_R;
    k KOCURY_O;
begin
    select deref(:new.KOT) into k from dual;
    for el in elity
        loop
            if k.PSEUDO = el.ps then
                raise_application_error(-20001, 'Kot o danym pseudonimie istnieje już w relacji ELITA_R');
            end if;
        end loop;
    for pl in plebsy
        loop
            if k.PSEUDO = pl.ps then
                raise_application_error(-20001, 'Kot o danym pseudonimie istnieje już w relacji PLEBS_R');
            end if;
        end loop;
end;


create or replace trigger elita_r_iu
    before insert or update
    on ELITA_R
    for each row
declare
    cursor elity is select deref(KOT).PSEUDO ps, deref(SLUGA).NR_CZLONKA_PLEBSU nr_sl
                    from elita_R;
    cursor plebsy is select deref(KOT).PSEUDO ps
                     from PLEBS_R;
    k KOCURY_O;
    s PLEBS_O;
begin
    select deref(:new.KOT), deref(:new.SLUGA) into k, s from dual;
    for el in elity
        loop
            if k.PSEUDO = el.ps then
                raise_application_error(-20001, 'Kot o danym pseudonimie istnieje już w relacji ELITA_R');
            end if;
            if s.NR_CZLONKA_PLEBSU = el.nr_sl then
                raise_application_error(-20001, 'Wybrany sługa jest już sługą innego członka elity!');
            end if;
        end loop;
    for pl in plebsy
        loop
            if k.PSEUDO = pl.ps then
                raise_application_error(-20001, 'Kot o danym pseudonimie istnieje już w relacji PLEBS_R');
            end if;
        end loop;
end;

create or replace trigger incydenty_r_iu
    before insert or update
    on WROGOWIE_KOCUROW_R
    for each row
declare
    cursor wrogowie is select deref(KOT).PSEUDO ps, IMIE_WROGA
                       from WROGOWIE_KOCUROW_R;
    k KOCURY_O;
begin
    select deref(:new.KOT) into k from dual;
    for wr in wrogowie
        loop
            if k.PSEUDO = wr.ps AND :new.IMIE_WROGA = wr.IMIE_WROGA then
                raise_application_error(-20001, 'Podana para wrogów została już zdefioniowana');
            end if;
        end loop;
end;

