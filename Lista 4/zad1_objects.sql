drop type KOCURY_O force;
drop type WROGOWIE_KOCUROW_O;
drop type PLEBS_O;
drop type ELITA_O;
drop type KONTA_O;

create or replace type KOCURY_O as object
(
    imie            varchar2(15),
    plec            varchar2(1),
    pseudo          varchar2(15),
    funkcja         varchar2(10),
    szef            ref KOCURY_O,
    w_stadku_od     date,
    przydzial_myszy number(3),
    myszy_extra     number(3),
    banda           varchar2(20),
    member procedure WYSWIETL_PSEUDO_SZEFA,
    member function DAJ_CALKOWITY_PRZYDZIAL_MYSZY return number,
    member function DAJ_BANDE return varchar2,
    map member function POROWNAJ return varchar2
);

create or replace type body KOCURY_O as
    member procedure WYSWIETL_PSEUDO_SZEFA is
            szefo KOCURY_O;
        begin
            select deref(SZEF) into szefo from dual;
            DBMS_OUTPUT.PUT_LINE(szefo.PSEUDO);
        end;
    member function DAJ_CALKOWITY_PRZYDZIAL_MYSZY return number is
        begin
            return nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0);
        end;
    member function DAJ_BANDE return varchar2 is
        begin
            return banda;
        end;
    map member function POROWNAJ return varchar2 is
        begin
            return pseudo;
        end;
end;

create or replace type WROGOWIE_KOCUROW_O as object
(
    nr_incydentu   number(3),
    kot            ref KOCURY_O,
    imie_wroga     varchar2(15),
    data_incydentu date,
    opis_incydentu varchar2(50),
    map member function POROWNAJ return varchar2,
    member function DAJ_KOTA return KOCURY_O,
    member procedure WYSWIETL_INFO_O_INCYDENCIE
);

create or replace type body WROGOWIE_KOCUROW_O as
    map member function POROWNAJ return varchar2 is
        kocur KOCURY_O;
        begin
            select deref(KOT) into kocur from dual;
            return kocur.PSEUDO||' '||imie_wroga;
        end;
    member function DAJ_KOTA return KOCURY_O is
        temp KOCURY_O;
        begin
            select deref(kot) into temp from DUAL;
            return temp;
        end;
    member procedure WYSWIETL_INFO_O_INCYDENCIE is
        begin
            DBMS_OUTPUT.PUT_LINE(data_incydentu||' - '||opis_incydentu);
        end;
end;

create or replace type PLEBS_O as object
(
    nr_czlonka_plebsu number(2),
    kot       ref KOCURY_O,
    map member function POROWNAJ return varchar2,
    member function DAJ_PLEBS return KOCURY_O
);

create or replace type body PLEBS_O as
    map member function POROWNAJ return varchar2 is
        begin
            return DAJ_PLEBS().PSEUDO;
        end;
    member function DAJ_PLEBS return KOCURY_O is
        temp KOCURY_O;
        begin
            select deref(KOT) into temp from dual;
            return temp;
        end;
end;

create or replace type ELITA_O as object
(
    nr_czlonka_elity number(2),
    kot              ref KOCURY_O,
    sluga            ref PLEBS_O,
    map member function POROWNAJ return varchar2,
    member function DAJ_ELITE return KOCURY_O,
    member function DAJ_SLUGE return PLEBS_O
);

create or replace type body ELITA_O as
    map member function POROWNAJ return varchar2 is
        begin
            return DAJ_ELITE().PSEUDO;
        end;
    member function DAJ_ELITE return KOCURY_O is
        temp KOCURY_O;
        begin
            select deref(KOT) into temp from dual;
            return temp;
        end;
    member function DAJ_SLUGE return PLEBS_O is
        temp PLEBS_O;
        begin
            select deref(sluga) into temp from DUAL;
            return temp;
        end;
end;

create or replace type KONTA_O as object
(
    nr_konta          number(3),
    wlasciciel        ref ELITA_O,
    data_wprowadzenia date,
    data_usuniecia    date,
    map member function POROWNAJ return number,
    member function DAJ_WLASCICIELA return ELITA_O,
    member function CZAS_LOKATY return number
);

create or replace type body KONTA_O as
    map member function POROWNAJ return number is
        begin
            return nr_konta;
        end;
    member function DAJ_WLASCICIELA return ELITA_O is
        temp ELITA_O;
        begin
            select deref(wlasciciel) into temp from dual;
            return temp;
        end;
    member function CZAS_LOKATY return number is
        liczba_dni number;
        begin
            select (nvl(DATA_USUNIECIA, sysdate) - DATA_WPROWADZENIA) into liczba_dni from DUAL;
            return liczba_dni;
        end;
end;
