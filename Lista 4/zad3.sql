drop table MYSZY;
-- Tworzenie Myszy
begin
    execute immediate 'create table Myszy
                       (
                           nr_myszy       number
                               constraint my_pk primary key,
                           lowca          varchar2(15)
                               constraint my_lo_nn not null
                               constraint my_lo_fk references KOCURY (PSEUDO),
                           zjadacz        varchar2(15)
                               constraint my_zj_fk references KOCURY (PSEUDO),
                           waga_myszy     number(3)
                               constraint my_wm_nn not null
                               constraint my_wm_val check ( waga_myszy between 100 and 200),
                           data_zlowienia date
                               constraint my_dz_nn not null,
                           data_wydania   date,
                           constraint my_dz_dw_val check ( data_zlowienia <= data_wydania )
                       )';
end;

-- Generowanie danych

declare

    TYPE KOCURY_ROWTYPE IS RECORD (pseudo KOCURY.PSEUDO%TYPE, cal_przydzial number, w_stadku_od KOCURY.w_stadku_od%TYPE);
    TYPE KOCURY_DTO IS TABLE OF KOCURY_ROWTYPE index by binary_integer ;
    TYPE MYSZY_DTO IS TABLE OF MYSZY%ROWTYPE index by binary_integer ;

    kocuryDto               KOCURY_DTO;
    myszyDto                MYSZY_DTO;
    data_obecna             date default to_date('2004-01-01');
    sroda                   date;
    srednia                 integer;
    nr_myszy_upolowane      MYSZY.NR_MYSZY%TYPE default 1;
    nr_myszy_zjedzone       MYSZY.NR_MYSZY%TYPE default 1;
    przedzial_lowienia      number;
begin
    while data_obecna < SYSDATE
        loop
            sroda := next_day(last_day(data_obecna) - 7, 'ŚRODA');

            select ceil(avg(nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0)))
            into srednia
            from KOCURY
            where W_STADKU_OD <= sroda;

            select PSEUDO,
                   nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0) cal_przydzial,
                   W_STADKU_OD
                bulk collect
            into kocuryDto
            from KOCURY
            where W_STADKU_OD <= sroda;


            for i in 1 .. kocuryDto.COUNT
                loop
                    for j in 1 .. srednia
                        loop
                            myszyDto(nr_myszy_upolowane).NR_MYSZY := nr_myszy_upolowane;
                            myszyDto(nr_myszy_upolowane).WAGA_MYSZY := DBMS_RANDOM.VALUE(100, 200);
                            myszyDto(nr_myszy_upolowane).LOWCA := kocuryDto(i).pseudo;
                            if kocuryDto(i).w_stadku_od < data_obecna then
                                if sroda < SYSDATE then
                                    przedzial_lowienia := sroda - data_obecna;
                                else
                                    przedzial_lowienia := sysdate - data_obecna;
                                end if;
                                myszyDto(nr_myszy_upolowane).DATA_ZLOWIENIA :=
                                        data_obecna + DBMS_RANDOM.VALUE(0, przedzial_lowienia);
                            else
                                if sroda < SYSDATE then
                                    przedzial_lowienia := sroda - kocuryDto(i).w_stadku_od;
                                else
                                    przedzial_lowienia := sysdate - kocuryDto(i).w_stadku_od;
                                end if;
                                myszyDto(nr_myszy_upolowane).DATA_ZLOWIENIA :=
                                        kocuryDto(i).w_stadku_od + DBMS_RANDOM.VALUE(0, przedzial_lowienia);
                            end if;
                            nr_myszy_upolowane := nr_myszy_upolowane + 1;
                        end loop;
                end loop;

            if sroda < sysdate then
                for i in 1 .. kocuryDto.COUNT
                    loop
                        for j in 1 .. kocuryDto(i).cal_przydzial
                            loop
                                 myszyDto(nr_myszy_zjedzone).DATA_WYDANIA := sroda;
                                 myszyDto(nr_myszy_zjedzone).ZJADACZ := kocuryDto(i).pseudo;
                                 nr_myszy_zjedzone := nr_myszy_zjedzone + 1;
                            end loop;
                    end loop;
               while nr_myszy_zjedzone < nr_myszy_upolowane
                loop
                    myszyDto(nr_myszy_zjedzone).DATA_WYDANIA := sroda;
                    myszyDto(nr_myszy_zjedzone).ZJADACZ := 'TYGRYS';
                    nr_myszy_zjedzone := nr_myszy_zjedzone + 1;
                end loop;
            end if;
            data_obecna := add_months(data_obecna, 1);
        end loop;
    forall i in 1 .. myszyDto.COUNT
        insert into MYSZY
        values (myszyDto(i).NR_MYSZY, myszyDto(i).LOWCA, myszyDto(i).ZJADACZ, myszyDto(i).WAGA_MYSZY,
                myszyDto(i).DATA_ZLOWIENIA,
                myszyDto(i).DATA_WYDANIA);
end;


-- Tworzenie indywidualnych kont

declare
    cursor pseuda is select PSEUDO
                     from KOCURY;
begin
    for pseudo in pseuda
        loop
            execute immediate 'create table OFIARY_' || pseudo.PSEUDO || '
                               (
                                   id_ofiary      number
                                       constraint of_pk_' || pseudo.PSEUDO || ' primary key,
                                   waga_myszy     number(3)
                                       constraint of_wm_nn_' || pseudo.PSEUDO || ' not null
                                       constraint of_wm_val_' || pseudo.PSEUDO || ' check ( waga_myszy between 100 and 200),
                                   data_zlowienia date
                                       constraint of_dz_nn_' || pseudo.PSEUDO || ' not null
                               )';
        end loop;
end;

-- Usuwanie indywidualnych kont
declare
    cursor pseuda is select PSEUDO
                     from KOCURY;
begin
    for pseudo in pseuda
        loop
            execute immediate 'drop table OFIARY_' || pseudo.PSEUDO || '';
        end loop;
end;

-- Wpłata
create or
    replace procedure WPLATA(ps KOCURY.PSEUDO%TYPE, data_zl date)
as
    TYPE OFIARY_ROWTYPE IS RECORD (waga_myszy MYSZY.nr_myszy%TYPE, data_zlowienia MYSZY.data_zlowienia%TYPE);
    TYPE OFIARY_DTO IS TABLE OF OFIARY_ROWTYPE index by binary_integer ;
    TYPE MYSZY_DTO IS TABLE OF MYSZY%ROWTYPE index by binary_integer ;
    liczba_pseudo number;
    lp            number;
    ofiaryDto     OFIARY_DTO;
    myszyDto      MYSZY_DTO;

begin
    select count(*) into liczba_pseudo from KOCURY where PSEUDO = ps;

    if liczba_pseudo = 0 then
        raise_application_error(-20001, 'BRAK KOTA O DANYM PSEUDONIMIE');
    end if;

    select nvl(MAX(NR_MYSZY) + 1, 1) into lp from MYSZY;
    DBMS_OUTPUT.PUT_LINE(lp);

    execute immediate 'select WAGA_MYSZY, DATA_ZLOWIENIA from OFIARY_' || ps || ' where DATA_ZLOWIENIA=''' || data_zl ||
                      ''''
        bulk collect into ofiaryDto;

    for i in 1 .. ofiaryDto.COUNT
        loop
            myszyDto(i).NR_MYSZY := lp;
            myszyDto(i).WAGA_MYSZY := ofiaryDto(i).waga_myszy;
            myszyDto(i).DATA_ZLOWIENIA := ofiaryDto(i).data_zlowienia;
            lp := lp + 1;
        end loop;

    forall i in 1 .. myszyDto.COUNT
        insert into MYSZY
        values (myszyDto(i).NR_MYSZY, ps, null, myszyDto(i).WAGA_MYSZY, myszyDto(i).DATA_ZLOWIENIA, null);

    execute immediate 'delete from OFIARY_' || ps || ' where DATA_ZLOWIENIA=''' || data_zl ||
                      '''';
end;

-- Wyplata
create or
    replace procedure WYPLATA(data date)
as
    TYPE KOCURY_ROWTYPE IS RECORD (pseudo KOCURY.PSEUDO%TYPE, cal_przydzial number);
    TYPE MYSZY_ROWTYPE IS RECORD (nr_myszy MYSZY.nr_myszy%TYPE, zjadacz MYSZY.zjadacz%TYPE);
    TYPE KOCURY_DTO IS TABLE OF KOCURY_ROWTYPE index by binary_integer ;
    TYPE MYSZY_DTO IS TABLE OF MYSZY_ROWTYPE index by binary_integer ;
    kocuryDto               KOCURY_DTO;
    myszyDto                MYSZY_DTO;
    indeks_myszy            number default 1;
    liczba_myszy_do_wyplaty number default 1;
    sroda                   date;

begin

    select next_day(last_day(data) - 7, 'ŚRODA') into sroda from dual;
    select PSEUDO,
           nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0) cal_przydzial
        bulk collect
    into kocuryDto
    from KOCURY
    where W_STADKU_OD <= data
    start with SZEF is null
    connect by prior PSEUDO = SZEF
    order by LEVEL;

    select NR_MYSZY,
           ZJADACZ
        bulk collect
    into myszyDto
    from MYSZY
    where ZJADACZ is null
      and DATA_ZLOWIENIA <= data;

    for i in 1 .. kocuryDto.COUNT
        loop
            liczba_myszy_do_wyplaty := liczba_myszy_do_wyplaty + kocuryDto(i).cal_przydzial;
        end loop;

    while indeks_myszy <= myszyDto.COUNT AND liczba_myszy_do_wyplaty > 0
        loop
            for i in 1 .. kocuryDto.COUNT
                loop
                    if kocuryDto(i).cal_przydzial > 0 then
                        myszyDto(indeks_myszy).zjadacz := kocuryDto(i).pseudo;
                        kocuryDto(i).cal_przydzial := kocuryDto(i).cal_przydzial - 1;
                        liczba_myszy_do_wyplaty := liczba_myszy_do_wyplaty - 1;
                        indeks_myszy := indeks_myszy + 1;
                    end if;
                end loop;
        end loop;

    forall i in 1 .. indeks_myszy - 1
        update MYSZY
        set ZJADACZ=myszyDto(i).zjadacz,
            DATA_WYDANIA = sroda
        where NR_MYSZY = myszyDto(i).nr_myszy;
end;


