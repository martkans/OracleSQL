drop view KOCURY_V;
drop view WROGOWIE_KOCUROW_V;
drop view PLEBS_V;
drop view ELITA_V;
drop view KONTA_V;


CREATE OR REPLACE force VIEW Kocury_V OF KOCURY_O_V
WITH OBJECT IDENTIFIER (pseudo) AS
SELECT imie, plec, pseudo, funkcja, MAKE_REF(Kocury_V, szef), w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy
FROM kocury;

select * from Kocury_V;
create or replace view WROGOWIE_KOCUROW_V OF WROGOWIE_KOCUROW_O_V
with object identifier (deref(kot).pseudo, imie_wroga) as
    select make_ref(KOCURY_V, pseudo) , imie_wroga, DATA_INCYDENTU, OPIS_INCYDENTU
    from WROGOWIE_KOCUROW;

create or replace view PLEBS_V OF PLEBS_O_V
with object identifier (deref(kot).pseudo) as
    select make_ref(KOCURY_V, pseudo)  from PLEBS;

create or replace view ELITA_V OF ELITA_O_V
with object identifier (deref(kot).pseudo) as
    select make_ref(KOCURY_V, pseudo), make_ref(PLEBS_V, PSEUDO) from ELITA;

create or replace view KONTA_V OF KONTA_O_V
with object identifier (nr_konta) as
    select NR_KONTA, make_ref(ELITA_V, pseudo), DATA_WPROWADZENIA, DATA_USUNIECIA from KONTA;
