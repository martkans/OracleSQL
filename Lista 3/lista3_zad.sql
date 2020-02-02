alter session set nls_date_format = 'YYYY-MM-DD';
-- Zad. 34. Napisać blok PL/SQL, który wybiera z relacji Kocury koty o funkcji podanej z
-- klawiatury. Jedynym efektem działania bloku ma być komunikat informujący czy znaleziono,
-- czy też nie, kota pełniącego podaną funkcję (w przypadku znalezienia kota wyświetlić nazwę
-- odpowiedniej funkcji).

DECLARE
    znal_fun    Kocury.FUNKCJA%TYPE;
    liczba_znal NUMBER;
BEGIN
    select count(PSEUDO), min(FUNKCJA)
    into liczba_znal, znal_fun
    from KOCURY
    where FUNKCJA = &funkcja;
    if liczba_znal > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Znaleziono kota o funkcji: ' || znal_fun);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono kota');
    END IF;
END;
-- Zad. 35. Napisać blok PL/SQL, który wyprowadza na ekran następujące informacje o kocie o
-- pseudonimie wprowadzonym z klawiatury (w zależności od rzeczywistych danych):
-- - 'calkowity roczny przydzial myszy >700'
-- - 'imię zawiera litere A'
-- - 'styczeń jest miesiacem przystapienia do stada'
-- - 'nie odpowiada kryteriom'.
-- Powyższe informacje wymienione są zgodnie z hierarchią ważności. Każdą wprowadzaną
-- informację poprzedzić imieniem kota.

DECLARE
    pseudonim        Kocury.PSEUDO%TYPE;
    przydzial        Kocury.PRZYDZIAL_MYSZY%TYPE;
    im               Kocury.IMIE%TYPE;
    mies             NUMBER;
    spelnia_kryteria boolean default false;
BEGIN
    select PSEUDO, IMIE, nvl(PRZYDZIAL_MYSZY, 0), extract(month from W_STADKU_OD)
    into pseudonim, im, przydzial, mies
    from KOCURY
    where PSEUDO = &ps;

    if (przydzial * 12) > 700 THEN
        spelnia_kryteria := true;
        DBMS_OUTPUT.PUT_LINE(pseudonim || ' calkowity roczny przydzial myszy >700');
    END IF;

    if im = 'A%' then
        spelnia_kryteria := true;
        DBMS_OUTPUT.PUT_LINE(pseudonim || ' imię zawiera litere A');
    end if;

    if mies = 1 THEN
        spelnia_kryteria := true;
        DBMS_OUTPUT.PUT_LINE(pseudonim || ' styczeń jest miesiacem przystapienia do stada');
    END IF;

    if spelnia_kryteria = false then
        DBMS_OUTPUT.PUT_LINE(pseudonim || ' nie odpowiada kryteriom');
    end if;
END;

-- Zad. 36. W związku z dużą wydajnością w łowieniu myszy SZEFUNIO postanowił
-- wynagrodzić swoich podwładnych. Ogłosił więc, że podwyższa indywidualny przydział
-- myszy każdego kota o 10% poczynając od kotów o najniższym przydziale. Jeśli w którymś
-- momencie suma wszystkich przydziałów przekroczy 1050, żaden inny kot nie dostanie
-- podwyżki. Jeśli przydział myszy po podwyżce przekroczy maksymalną wartość należną dla
-- pełnionej funkcji (relacja Funkcje), przydział myszy po podwyżce ma być równy tej wartości.
-- Napisać blok PL/SQL z kursorem, który wyznacza sumę przydziałów przed podwyżką i
-- realizuje to zadanie. Blok ma działać tak długo, aż suma wszystkich przydziałów
-- rzeczywiście przekroczy 1050 (liczba „obiegów podwyżkowych” może być większa od 1 a
-- więc i podwyżka może być większa niż 10%). Wyświetlić na ekranie sumę przydziałów
-- myszy po wykonaniu zadania wraz z liczbą podwyżek (liczbą zmian w relacji Kocury). Na
-- końcu wycofać wszystkie zmiany.

set serveroutput on;
declare
    cursor lista_up_kot is
        select PSEUDO, nvl(PRZYDZIAL_MYSZY, 0) przydzial, MAX_MYSZY
        from KOCURY
                 join FUNKCJE on KOCURY.FUNKCJA = FUNKCJE.FUNKCJA
        order by przydzial
            for update of PRZYDZIAL_MYSZY;
    row           lista_up_kot%ROWTYPE;
    suma_przyd    NUMBER;
    liczba_zmian  NUMBER := 0;
    dod_przydzial NUMBER;

begin
    select sum(PRZYDZIAL_MYSZY) into suma_przyd from KOCURY;

    open lista_up_kot;
    LOOP
        FETCH lista_up_kot into row;

        if lista_up_kot%NOTFOUND then
            close lista_up_kot;
            open lista_up_kot;
        elsif row.przydzial < row.MAX_MYSZY then
            if round(row.przydzial * 1.1) > row.MAX_MYSZY then
                dod_przydzial := row.MAX_MYSZY - row.przydzial;
            else
                dod_przydzial := round(0.1 * row.przydzial);
            end if;

            update KOCURY
            set PRZYDZIAL_MYSZY = nvl(PRZYDZIAL_MYSZY, 0) + dod_przydzial
            where current of lista_up_kot;

            suma_przyd := suma_przyd + dod_przydzial;
            liczba_zmian := liczba_zmian + 1;

            exit when suma_przyd > 1050;
        end if;
    end loop;
    close lista_up_kot;

    DBMS_OUTPUT.PUT_LINE('Suma przydziałów: ' || suma_przyd);
    DBMS_OUTPUT.PUT_LINE('Liczba zmian: ' || liczba_zmian);
end;

rollback;

select *
from KOCURY;
-- Zad. 37. Napisać blok, który powoduje wybranie w pętli kursorowej FOR pięciu kotów o
-- najwyższym całkowitym przydziale myszy. Wynik wyświetlić na ekranie.

declare
    cursor naj_przydz is
        select *
        from (
                 select PSEUDO,
                        nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0)                                   cal_przydz,
                        DENSE_RANK() over (order by nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0) desc) poz
                 from KOCURY
             )
        where poz < 6;
begin
    for kot in naj_przydz
        loop
            DBMS_OUTPUT.PUT_LINE(kot.PSEUDO || ' - ' || kot.cal_przydz);
        end loop;
end;

-- Zad. 38. Napisać blok, który zrealizuje wersję a. lub wersję b. zad. 19 w sposób uniwersalny
-- (bez konieczności uwzględniania wiedzy o głębokości drzewa). Daną wejściową ma być
-- maksymalna liczba wyświetlanych przełożonych.

declare
    cursor drzewo is select connect_by_root IMIE Imie, connect_by_root FUNKCJA FUNKCJA, IMIE piv, LEVEL poz
                     from KOCURY
                     connect by prior SZEF = PSEUDO
                     start with FUNKCJA in ('KOT', 'MILUSIA')
                     order by Imie, FUNKCJA, poz;
    rzad            drzewo%ROWTYPE;
    il_przelozonych NUMBER;
    niepoprawna_liczba exception;
begin

    il_przelozonych := &max_przelozonych;
    il_przelozonych := il_przelozonych + 1;

    if il_przelozonych < 1 then
        raise niepoprawna_liczba;
    end if;

    open drzewo;

    DBMS_OUTPUT.PUT(rpad('Imie', 15) || rpad('| Funkcja', 15) || '| Imiona kolejnych szefów');
    DBMS_OUTPUT.NEW_LINE();
    DBMS_OUTPUT.PUT('--------------------------------------------------------------------------');
    loop
        fetch drzewo into rzad;
        exit when drzewo%notfound;
        if rzad.poz <= il_przelozonych then
            if (rzad.poz = 1) then
                DBMS_OUTPUT.NEW_LINE();
                DBMS_OUTPUT.PUT(rpad(rzad.Imie, 15) || '| ' || rpad(rzad.FUNKCJA, 15));
            else
                DBMS_OUTPUT.PUT('| ' || rpad(rzad.piv, 15));
            end if;
        end if;
    end loop;

    close drzewo;

exception
    when
        niepoprawna_liczba then DBMS_OUTPUT.PUT_LINE('Liczba przełożonych musi być nieujemna!');
end;

-- Zad. 39. Napisać blok PL/SQL wczytujący trzy parametry reprezentujące nr bandy, nazwę
-- bandy oraz teren polowań. Skrypt ma uniemożliwiać wprowadzenie istniejących już wartości
-- parametrów poprzez obsługę odpowiednich wyjątków. Sytuacją wyjątkową jest także
-- wprowadzenie numeru bandy <=0. W przypadku zaistnienia sytuacji wyjątkowej należy
-- wyprowadzić na ekran odpowiedni komunikat. W przypadku prawidłowych parametrów
-- należy stworzyć nową bandę w relacji Bandy. Zmianę należy na końcu wycofać.

declare
    nr_ban  Bandy.NR_BANDY%TYPE;
    naz_ban Bandy.NAZWA%TYPE;
    ter_ban Bandy.TEREN%TYPE;
    cursor bandy_cur is
        (select NR_BANDY, NAZWA, TEREN
         from BANDY);

    NR_ISTNIEJE EXCEPTION;
    NR_PROG EXCEPTION;
    NAZWA_ISTNIEJE EXCEPTION;
    TEREN_ISTNIEJE EXCEPTION;
begin
    nr_ban := &nr;
    naz_ban := &naz;
    ter_ban := &ter;

    IF nr_ban <= 0 then
        raise NR_PROG;
    end if;

    for banda in bandy_cur
        loop
            if nr_ban = banda.NR_BANDY then
                raise NR_ISTNIEJE;
            elsif naz_ban = banda.NAZWA then
                raise NAZWA_ISTNIEJE;
            elsif ter_ban = banda.TEREN then
                raise TEREN_ISTNIEJE;
            end if;
        end loop;

    insert into BANDY
    values (nr_ban, naz_ban, ter_ban, null);
    DBMS_OUTPUT.PUT_LINE('Dodano bandę!');

exception
    when NR_PROG
        then DBMS_OUTPUT.PUT_LINE('Nr bandy nie może być mniejszy niż 0!');
    when NR_ISTNIEJE
        then DBMS_OUTPUT.PUT_LINE('Banda o nr ' || nr_ban || ' już istnieje!');
    when NAZWA_ISTNIEJE
        then DBMS_OUTPUT.PUT_LINE('Banda o nazwie ' || naz_ban || ' już istnieje!');
    when TEREN_ISTNIEJE
        then DBMS_OUTPUT.PUT_LINE('Banda siejąca grozę na terenie ' || ter_ban || ' już istnieje!');
end;

select *
from BANDY;
rollback;

-- Zad. 40. Przerobić blok z zadania 39 na procedurę umieszczoną w bazie danych.

create or
    replace procedure DODAJ_BANDE(nr_ban Bandy.NR_BANDY%TYPE, naz_ban Bandy.NAZWA%TYPE, ter_ban Bandy.TEREN%TYPE)
as
    cursor
        bandy_cur is
        (select NR_BANDY, NAZWA, TEREN
         from BANDY);

    NR_ISTNIEJE EXCEPTION;
    NR_PROG EXCEPTION;
    NAZWA_ISTNIEJE EXCEPTION;
    TEREN_ISTNIEJE EXCEPTION;
begin

    IF nr_ban <= 0 then
        raise NR_PROG;
    end if;

    for banda in bandy_cur
        loop
            if nr_ban = banda.NR_BANDY then
                raise NR_ISTNIEJE;
            elsif naz_ban = banda.NAZWA then
                raise NAZWA_ISTNIEJE;
            elsif ter_ban = banda.TEREN then
                raise TEREN_ISTNIEJE;
            end if;
        end loop;

    insert into BANDY
    values (nr_ban, naz_ban, ter_ban, null);
    DBMS_OUTPUT.PUT_LINE('Dodano bandę!');

exception
    when NR_PROG
        then DBMS_OUTPUT.PUT_LINE('Nr bandy nie może być mniejszy niż 0!');
    when NR_ISTNIEJE
        then DBMS_OUTPUT.PUT_LINE('Banda o nr ' || nr_ban || ' już istnieje!');
    when NAZWA_ISTNIEJE
        then DBMS_OUTPUT.PUT_LINE('Banda o nazwie ' || naz_ban || ' już istnieje!');
    when TEREN_ISTNIEJE
        then DBMS_OUTPUT.PUT_LINE('Banda siejąca grozę na terenie ' || ter_ban || ' już istnieje!');
end;

begin
    DODAJ_BANDE(5, 'Dziekani', 'PWr');
end;

select *
from BANDY;

rollback;

drop procedure DODAJ_BANDE;
-- Zad. 41. Zdefiniować wyzwalacz, który zapewni, że numer nowej bandy będzie zawsze
-- większy o 1 od najwyższego numeru istniejącej już bandy. Sprawdzić działanie wyzwalacza
-- wykorzystując procedurę z zadania 40.

create or replace trigger numer_nowej_bandy
    before INSERT
    on BANDY
    for each row
declare
    max_nr_bandy BANDY.NR_BANDY%TYPE;
begin
    select max(NR_BANDY) into max_nr_bandy from BANDY;

    :new.nr_bandy := max_nr_bandy + 1;
end;

drop trigger numer_nowej_bandy;
-- Zad. 42. Milusie postanowiły zadbać o swoje interesy. Wynajęły więc informatyka, aby
-- zapuścił wirusa w system Tygrysa. Teraz przy każdej próbie zmiany przydziału myszy na
-- plus (o minusie w ogóle nie może być mowy) o wartość mniejszą niż 10% przydziału myszy
-- Tygrysa żal Miluś ma być utulony podwyżką ich przydziału o tą wartość oraz podwyżką
-- myszy extra o 5. Tygrys ma być ukarany stratą wspomnianych 10%. Jeśli jednak podwyżka
-- będzie satysfakcjonująca, przydział myszy extra Tygrysa ma wzrosnąć o 5.
-- Zaproponować dwa rozwiązania zadania, które ominą podstawowe ograniczenie dla
-- wyzwalacza wierszowego aktywowanego poleceniem DML tzn. brak możliwości odczytu lub
-- zmiany relacji, na której operacja (polecenie DML) „wyzwala” ten wyzwalacz. W pierwszym
-- rozwiązaniu (klasycznym) wykorzystać kilku wyzwalaczy i pamięć w postaci specyfikacji
-- dedykowanego zadaniu pakietu, w drugim wykorzystać wyzwalacz COMPOUND.
-- Podać przykład funkcjonowania wyzwalaczy a następnie zlikwidować wprowadzone przez
-- nie zmiany.

-- a
create or replace package pamiec
as
    il_kar number := 0;
    il_nagrod number := 0;
    dzialka_tygrysa number;
    zmiana boolean := false;
end pamiec;

create or replace trigger info_tygrys
    before update of PRZYDZIAL_MYSZY
    on KOCURY
begin
    select nvl(PRZYDZIAL_MYSZY, 0) into pamiec.dzialka_tygrysa from KOCURY where PSEUDO = 'TYGRYS';
end;

create or replace trigger wirus_before
    before update of PRZYDZIAL_MYSZY
    on KOCURY
    for each row
    when ( new.FUNKCJA = 'MILUSIA' )
begin
    if :old.PRZYDZIAL_MYSZY >= :new.PRZYDZIAL_MYSZY then
        :new.PRZYDZIAL_MYSZY := :old.PRZYDZIAL_MYSZY;
        DBMS_OUTPUT.PUT_LINE('Nie obniżysz nam przydziału Tygrysie!');
    else
        pamiec.zmiana := true;
        if (:new.PRZYDZIAL_MYSZY - :old.PRZYDZIAL_MYSZY) < round(0.1 * pamiec.dzialka_tygrysa) then
            :new.PRZYDZIAL_MYSZY := :old.PRZYDZIAL_MYSZY + round(0.1 * pamiec.dzialka_tygrysa);
            :new.MYSZY_EXTRA := :new.MYSZY_EXTRA + 5;

            pamiec.il_kar := pamiec.il_kar + 1;
            DBMS_OUTPUT.PUT_LINE('Skąpy jesteś Tygrysie...');
        else
            pamiec.il_nagrod := pamiec.il_nagrod + 1;

            DBMS_OUTPUT.PUT_LINE('Kochamy Cię Tygrysie <3');
        end if;
    end if;
end;

create or replace trigger wirus_after
    after update of PRZYDZIAL_MYSZY
    on KOCURY
begin
    if pamiec.zmiana then
        pamiec.zmiana := false;
        if pamiec.il_kar > 0 then
            update KOCURY
            set PRZYDZIAL_MYSZY = round((1 - (pamiec.il_kar * 0.1)) * nvl(PRZYDZIAL_MYSZY, 0))
            where PSEUDO = 'TYGRYS';
            DBMS_OUTPUT.PUT_LINE('Nadchodzą chude lata dla Ciebie...');
            pamiec.il_kar := 0;
        end if;

        if pamiec.il_nagrod > 0 then
            DBMS_OUTPUT.PUT_LINE('Smacznego!');
            update KOCURY set MYSZY_EXTRA= nvl(MYSZY_EXTRA, 0) + pamiec.il_nagrod * 5 where PSEUDO = 'TYGRYS';
            PAMIEC.il_nagrod := 0;
        end if;
    end if;
end;

select *
from KOCURY
where FUNKCJA = 'MILUSIA'
   or PSEUDO = 'TYGRYS';

update KOCURY
set PRZYDZIAL_MYSZY=0
where FUNKCJA = 'MILUSIA';

update KOCURY
set PRZYDZIAL_MYSZY=PRZYDZIAL_MYSZY - 2
where FUNKCJA = 'MILUSIA';

rollback;

drop trigger wirus_after;
drop trigger wirus_before;
drop trigger info_tygrys;
drop package pamiec;

--b

create or replace trigger wirus
    for update of PRZYDZIAL_MYSZY
    on KOCURY
    when ( new.FUNKCJA = 'MILUSIA' )
    compound trigger
    il_kar number := 0;
    il_nagrod number := 0;
    dzialka_tygrysa number;
    zmiana boolean := false;
before statement is
begin
    select nvl(PRZYDZIAL_MYSZY, 0) into dzialka_tygrysa from KOCURY where PSEUDO = 'TYGRYS';
end before statement ;
    before each row is
    begin
        if :old.PRZYDZIAL_MYSZY >= : new.PRZYDZIAL_MYSZY then
            :new.PRZYDZIAL_MYSZY := : old.PRZYDZIAL_MYSZY;
            DBMS_OUTPUT.PUT_LINE('Nie obniżysz nam przydziału Tygrysie!');
        else
            zmiana := true;
            if (:new.PRZYDZIAL_MYSZY - : old.PRZYDZIAL_MYSZY) < round(0.1 * dzialka_tygrysa) then
                :new.PRZYDZIAL_MYSZY := : old.PRZYDZIAL_MYSZY + round(0.1 * dzialka_tygrysa);
                :new.MYSZY_EXTRA := : new.MYSZY_EXTRA + 5;

                il_kar := il_kar + 1;
                DBMS_OUTPUT.PUT_LINE('Skąpy jesteś Tygrysie...');
            else
                il_nagrod := il_nagrod + 1;

                DBMS_OUTPUT.PUT_LINE('Kochamy Cię Tygrysie <3');
            end if;
        end if;
    end before each row ;
    after statement is
    begin
        if zmiana then
            zmiana := false;
            if il_kar > 0 then
                update KOCURY
                set PRZYDZIAL_MYSZY = round((1 - (il_kar * 0.1)) * nvl(PRZYDZIAL_MYSZY, 0))
                where PSEUDO = 'TYGRYS';
                DBMS_OUTPUT.PUT_LINE('Nadchodzą chude lata dla Ciebie...');
                il_kar := 0;
            end if;

            if il_nagrod > 0 then
                DBMS_OUTPUT.PUT_LINE('Smacznego!');
                update KOCURY set MYSZY_EXTRA= nvl(MYSZY_EXTRA, 0) + il_nagrod * 5 where PSEUDO = 'TYGRYS';
                il_nagrod := 0;
            end if;
        end if;
    end after statement;
    end wirus;

drop trigger wirus;
-- Zad. 43. Napisać blok, który zrealizuje zad. 33 w sposób uniwersalny (bez konieczności
-- uwzględniania wiedzy o funkcjach pełnionych przez koty).
declare
    cursor wszystkie_funkcje is select funkcja
                                from funkcje;
    cursor wszystkie_bandy is select NR_BANDY, NAZWA
                              from BANDY;
    cursor plcie is select distinct PLEC
                    from KOCURY;
    ile        number(2);
    suma       number(5);
    suma_banda number(5) := 0;
    plec_dl    VARCHAR2(5);
begin
    DBMS_OUTPUT.PUT(rpad('NAZWA BANDY', 15) || '| PŁEĆ  ' || rpad('| ILE', 10));
    for funkcja in wszystkie_funkcje
        loop
            DBMS_OUTPUT.PUT(rpad('| ' || funkcja.FUNKCJA, 15));
        end loop;
    DBMS_OUTPUT.PUT_LINE(rpad('| SUMA', 10));
    DBMS_OUTPUT.PUT_LINE(rpad('-', 160, '-'));


    for banda in wszystkie_bandy
        loop
            for plec in plcie
                loop
                    select count(pseudo)
                    into ile
                    from KOCURY
                    where NR_BANDY = banda.NR_BANDY
                      and PLEC = plec.plec;
                    if plec.PLEC = 'M' then
                        plec_dl := 'Kocur';
                    else
                        plec_dl := 'Kotka';
                    end if;
                    DBMS_OUTPUT.PUT(rpad(banda.NAZWA, 15) || '| ' || plec_dl || rpad(' | ' || ile, 10));
                    for funkcja in wszystkie_funkcje
                        loop
                            select nvl(sum(nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0)), 0)
                            into suma
                            from KOCURY
                            where NR_BANDY = banda.NR_BANDY
                              and PLEC = plec.PLEC
                              and FUNKCJA = funkcja.FUNKCJA;
                            DBMS_OUTPUT.PUT(rpad('| ' || suma, 15));
                            suma_banda := suma_banda + suma;
                        end loop;
                    DBMS_OUTPUT.PUT(rpad('| ' || suma_banda, 10));
                    suma_banda := 0;
                    DBMS_OUTPUT.NEW_LINE();
                end loop;
        end loop;

    DBMS_OUTPUT.NEW_LINE();
    DBMS_OUTPUT.PUT_LINE(rpad('-', 160, '-'));
    DBMS_OUTPUT.PUT(rpad('Zjada razem', 33));

    for funkcja in wszystkie_funkcje
        loop
            select nvl(sum(nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0)), 0)
            into suma
            from KOCURY
            where FUNKCJA = funkcja.FUNKCJA;
            DBMS_OUTPUT.PUT(rpad('| ' || suma, 15));
            suma_banda := suma_banda + suma;
        end loop;
    DBMS_OUTPUT.PUT(rpad('| ' || suma_banda, 10));
    DBMS_OUTPUT.NEW_LINE();
end;

-- Zad. 44. Tygrysa zaniepokoiło niewytłumaczalne obniżenie zapasów "myszowych".
-- Postanowił więc wprowadzić podatek pogłówny, który zasiliłby spiżarnię. Zarządził więc, że
-- każdy kot ma obowiązek oddawać 5% (zaokrąglonych w górę) swoich całkowitych
-- "myszowych" przychodów. Dodatkowo od tego co pozostanie:
-- - koty nie posiadające podwładnych oddają po dwie myszy za nieudolność w
-- umizgach o awans,
-- - koty nie posiadające wrogów oddają po jednej myszy za zbytnią ugodowość,
-- - koty płacą dodatkowy podatek, którego formę określa wykonawca zadania.
-- Napisać funkcję, której parametrem jest pseudonim kota, wyznaczającą należny podatek
-- pogłówny kota. Funkcję tą razem z procedurą z zad. 40 należy umieścić w pakiecie, a
-- następnie wykorzystać ją do określenia podatku dla wszystkich kotów.

create or replace package podatek_package as
    function wylicz_podatek(ps KOCURY.PSEUDO%TYPE) return number;
    procedure DODAJ_BANDE(nr_ban Bandy.NR_BANDY%TYPE, naz_ban Bandy.NAZWA%TYPE, ter_ban Bandy.TEREN%TYPE);
end;

create or replace package body podatek_package as
    function wylicz_podatek(ps KOCURY.PSEUDO%TYPE) return number as
        podatek number;
        plec    KOCURY.plec%TYPE ;
        temp    number;
    begin
        select ceil(0.05 * (nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0))) into podatek from KOCURY where PSEUDO = ps;

        select count(SZEF) into temp from KOCURY where SZEF = ps;
        if temp = 0 then
            podatek := podatek + 2;
        end if;

        select count(PSEUDO) into temp from WROGOWIE_KOCUROW where PSEUDO = ps;
        if temp = 0 then
            podatek := podatek + 1;
        end if;

        select PLEC into plec from KOCURY where PSEUDO = ps;
        if plec = 'M' then
            podatek := podatek + 3;
        end if;
        return podatek;
    end;
    procedure DODAJ_BANDE(nr_ban Bandy.NR_BANDY%TYPE, naz_ban Bandy.NAZWA%TYPE, ter_ban Bandy.TEREN%TYPE)
    as
        cursor
            bandy_cur is
            (select NR_BANDY, NAZWA, TEREN
             from BANDY);

        NR_ISTNIEJE EXCEPTION;
        NR_PROG EXCEPTION;
        NAZWA_ISTNIEJE EXCEPTION;
        TEREN_ISTNIEJE EXCEPTION;
    begin

        IF nr_ban <= 0 then
            raise NR_PROG;
        end if;

        for banda in bandy_cur
            loop
                if nr_ban = banda.NR_BANDY then
                    raise NR_ISTNIEJE;
                elsif naz_ban = banda.NAZWA then
                    raise NAZWA_ISTNIEJE;
                elsif ter_ban = banda.TEREN then
                    raise TEREN_ISTNIEJE;
                end if;
            end loop;

        insert into BANDY
        values (nr_ban, naz_ban, ter_ban, null);
        DBMS_OUTPUT.PUT_LINE('Dodano bandę!');

    exception
        when NR_PROG
            then DBMS_OUTPUT.PUT_LINE('Nr bandy nie może być mniejszy niż 0!');
        when NR_ISTNIEJE
            then DBMS_OUTPUT.PUT_LINE('Banda o nr ' || nr_ban || ' już istnieje!');
        when NAZWA_ISTNIEJE
            then DBMS_OUTPUT.PUT_LINE('Banda o nazwie ' || naz_ban || ' już istnieje!');
        when TEREN_ISTNIEJE
            then DBMS_OUTPUT.PUT_LINE('Banda siejąca grozę na terenie ' || ter_ban || ' już istnieje!');
    end;
end;

select podatek_package.wylicz_podatek('LOLA')
from DUAL;
begin
    podatek_package.DODAJ_BANDE(6, 'Dziekani', 'PWr');
end;

select *
from BANDY;
rollback;

declare
    cursor pseudonimy is select PSEUDO
                         from KOCURY;
begin
    DBMS_OUTPUT.PUT_LINE(rpad('Pseudonim', 15) || rpad(' | Podatek', 10));
    DBMS_OUTPUT.PUT_LINE(rpad('-', 25, '-'));
    for pseudonim in pseudonimy
        loop
            DBMS_OUTPUT.PUT_LINE(rpad(pseudonim.PSEUDO, 15) ||
                                 rpad(' | ' || podatek_package.wylicz_podatek(pseudonim.PSEUDO), 10));
        end loop;
end;

drop package podatek_package;
-- Zad. 45. Tygrys zauważył dziwne zmiany wartości swojego prywatnego przydziału myszy
-- (patrz zadanie 42). Nie niepokoiły go zmiany na plus ale te na minus były, jego zdaniem,
-- niedopuszczalne. Zmotywował więc jednego ze swoich szpiegów do działania i dzięki temu
-- odkrył niecne praktyki Miluś (zadanie 42). Polecił więc swojemu informatykowi
-- skonstruowanie mechanizmu zapisującego w relacji Dodatki_extra (patrz Wykłady - cz.
-- 2) dla każdej z Miluś -10 (minus dziesięć) myszy dodatku extra przy zmianie na plus
-- któregokolwiek z przydziałów myszy Miluś, wykonanej przez innego operatora niż on sam.
-- Zaproponować taki mechanizm, w zastępstwie za informatyka Tygrysa. W rozwiązaniu
-- wykorzystać funkcję LOGIN_USER zwracającą nazwę użytkownika aktywującego
-- wyzwalacz oraz elementy dynamicznego SQL'a.

create table DODATKI_EXTRA
(
    id        number
        constraint de_pk primary key,
    pseudo    varchar2(15)
        constraint de_fk_ko references KOCURY (PSEUDO),
    dod_extra number
);

create or replace trigger kontroler_milus
    before update of PRZYDZIAL_MYSZY
    on KOCURY
    for each row
    when ( new.FUNKCJA = 'MILUSIA')
declare
    pragma autonomous_transaction ;
begin
    if login_USER != 'TYGRYS' and :new.PRZYDZIAL_MYSZY > :OLD.PRZYDZIAL_MYSZY then
        execute immediate 'declare
            cursor milusie is select PSEUDO
                              from KOCURY
                              where FUNKCJA = ''MILUSIA'';
            max_id number;
        begin
            select nvl(max(id), 0) + 1 into max_id from DODATKI_EXTRA;
            for milusia in milusie
                loop
                    insert into DODATKI_EXTRA values (max_id, milusia.PSEUDO, -10);
                    max_id := max_id + 1;
                end loop;
        end;';
        commit;
    end if;
end;

update KOCURY
set PRZYDZIAL_MYSZY = PRZYDZIAL_MYSZY + 1
where FUNKCJA = 'MILUSIA';

select *
from DODATKI_EXTRA;
select *
from KOCURY
where FUNKCJA = 'MILUSIA'
   or PSEUDO = 'TYGRYS';

rollback;

drop trigger kontroler_milus;
drop table DODATKI_EXTRA;
-- Zad. 46. Napisać wyzwalacz, który uniemożliwi wpisanie kotu przydziału myszy spoza
-- przedziału (min_myszy, max_myszy) określonego dla każdej funkcji w relacji Funkcje.
-- Każda próba wykroczenia poza obowiązujący przedział ma być dodatkowo monitorowana w
-- osobnej relacji (kto, kiedy, jakiemu kotu, jaką operacją).
create
    table
    ZDARZENIA
(
    id       number(2)
        constraint zda_pk primary key,
    kto      VARCHAR2(32)
        constraint zd_kt_nn not null,
    kiedy    date
        default sysdate
        constraint zd_ki_nn not null,
    pseudo   varchar2(15)
        constraint zd_ps_nn not null,
    operacja varchar2(10)
        constraint zd_op_nn not null
);

create
    or
    replace trigger naruszenie_przedzialu_myszy
    before
        insert or
        update
    on KOCURY
    for each row
declare
    min_przydz    FUNKCJE.MIN_MYSZY%type ;
    max_przydz    FUNKCJE.MAX_MYSZY%type ;
    max_id_przydz ZDARZENIA.ID%TYPE;
    operacja      ZDARZENIA.OPERACJA%TYPE;
    kto           zdarzenia.kto%type;
    pragma autonomous_transaction;
begin
    select MIN_MYSZY, MAX_MYSZY into min_przydz, max_przydz from FUNKCJE where FUNKCJA = :new.funkcja;
    IF :new.PRZYDZIAL_MYSZY > max_przydz OR :new.PRZYDZIAL_MYSZY < min_przydz then
        kto := LOGIN_USER;
        select nvl(MAX(ID), 0) into max_id_przydz FROM ZDARZENIA;
        IF inserting then
            operacja := 'INSERT';
        else
            operacja := 'UPDATE';
        end if;
        insert into ZDARZENIA (id, kto, pseudo, operacja)
        values (max_id_przydz + 1, kto, :new.pseudo, operacja);
        commit;

        raise_application_error(-20001, 'Wartość przydziału myszy jest poza widełkami dla funkcji!');
    end if;
end;



update KOCURY
set PRZYDZIAL_MYSZY=200
where PSEUDO = 'TYGRYS';

update KOCURY
set PRZYDZIAL_MYSZY=1
where PSEUDO = 'TYGRYS';

insert into KOCURY
values ('JAN', 'M', 'SZARIK', 'SZEFUNIO', null, sysdate, 200, null, 1);
insert into KOCURY
values ('JAN', 'M', 'SZARIK', 'SZEFUNIO', null, sysdate, 1, null, 1);

select *
from KOCURY;
select *
from ZDARZENIA;
rollback;

drop trigger naruszenie_przedzialu_myszy;
drop table ZDARZENIA;




