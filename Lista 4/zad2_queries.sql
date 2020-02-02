-- Podaj pseudonimy kotów, które korzystały z konta myszowego oraz policz ile razy wykorzystały te konto.
-- grupowanie, łączenie, metody z typów
select
       k.DAJ_WLASCICIELA().DAJ_ELITE().pseudo        "Pseudo",
       count(k.DAJ_WLASCICIELA().DAJ_ELITE()) "Ilość kont"
from KONTA_V k
group by k.DAJ_WLASCICIELA().DAJ_ELITE();

-- Podaj pseudonimy i całkowity przydział myszy kotów, które mają całkowity przydział myszy niższy od kota,
-- który najdłużej trzyma/trzymał mysz na lokacie (w razie dwóch takich samych najdłużyszch okresów wybierz kota,
-- którego pseudonim jest alfabetycznie wcześniej).
-- podzapytanie, metody, łączenie
select PSEUDO, kr.DAJ_CALKOWITY_PRZYDZIAL_MYSZY() "Całkowity przydzial myszy"
from KOCURY_V kr
where kr.DAJ_CALKOWITY_PRZYDZIAL_MYSZY() < (
    select krp.DAJ_CALKOWITY_PRZYDZIAL_MYSZY()
    from KOCURY_V krp
    where PSEUDO IN (
        select "Pseudo"
        from (
                 select k.DAJ_WLASCICIELA().DAJ_ELITE().pseudo "Pseudo", k.CZAS_LOKATY() "lokata"
                 from KONTA_V k
                 order by "lokata" desc, "Pseudo" asc )
        where ROWNUM = 1))
order by "Całkowity przydzial myszy" desc ;

-- Lista 2.
-- Zad. 22. Znaleźć koty (wraz z pełnioną funkcją), które posiadają więcej niż jednego wroga.
select deref(KOT).PSEUDO "Pseudonim kota", deref(KOT).funkcja "Funkcja", count(IMIE_WROGA) "Liczba wrogów"
from WROGOWIE_KOCUROW_V
group by deref(KOT).PSEUDO, deref(KOT).funkcja
having count(IMIE_WROGA) > 1;

-- Zad. 28. Określić lata, dla których liczba wstąpień do stada jest najbliższa (od góry i od dołu)
-- średniej liczbie wstąpień dla wszystkich lat (średnia z wartości określających liczbę wstąpień
-- w poszczególnych latach). Nie stosować perspektywy.
select 'Srednia' ROK, round(avg(count(PSEUDO)), 7) "LICZBA WSTAPIEN"
from KOCURY_V
group by TO_CHAR(w_stadku_od, 'YYYY')
union
select TO_CHAR(W_STADKU_OD, 'YYYY'), count(PSEUDO)
from KOCURY_V
group by TO_CHAR(W_STADKU_OD, 'YYYY')
having count(PSEUDO) in (
                         (select *
                          from (select count(PSEUDO) w
                                from KOCURY_V
                                group by TO_CHAR(w_stadku_od, 'YYYY')
                                having count(PSEUDO) >= (select round(avg(count(PSEUDO)), 7)
                                                         from KOCURY_V
                                                         group by TO_CHAR(w_stadku_od, 'YYYY'))
                                order by w)
                          where ROWNUM = 1),
                         (select *
                          from (select count(PSEUDO) w
                                from KOCURY
                                group by TO_CHAR(w_stadku_od, 'YYYY')
                                having count(PSEUDO) <= (select round(avg(count(PSEUDO)), 7)
                                                         from KOCURY_V
                                                         group by TO_CHAR(w_stadku_od, 'YYYY'))
                                order by w desc)
                          where ROWNUM = 1))
order by "LICZBA WSTAPIEN", ROK;

-- Lista 3.

-- Zad. 35. Napisać blok PL/SQL, który wyprowadza na ekran następujące informacje o kocie o
-- pseudonimie wprowadzonym z klawiatury (w zależności od rzeczywistych danych):
-- - 'calkowity roczny przydzial myszy >700'
-- - 'imię zawiera litere A'
-- - 'styczeń jest miesiacem przystapienia do stada'
-- - 'nie odpowiada kryteriom'.
-- Powyższe informacje wymienione są zgodnie z hierarchią ważności. Każdą wprowadzaną
-- informację poprzedzić imieniem kota.
DECLARE
    pseudonim        KOCURY_V.PSEUDO%TYPE;
    przydzial        KOCURY_V.PRZYDZIAL_MYSZY%TYPE;
    im               KOCURY_V.IMIE%TYPE;
    mies             NUMBER;
    spelnia_kryteria boolean default false;
BEGIN
    select PSEUDO, IMIE, nvl(PRZYDZIAL_MYSZY, 0), extract(month from W_STADKU_OD)
    into pseudonim, im, przydzial, mies
    from KOCURY_V
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

-- Zad. 37. Napisać blok, który powoduje wybranie w pętli kursorowej FOR pięciu kotów o
-- najwyższym całkowitym przydziale myszy. Wynik wyświetlić na ekranie.

declare
    cursor naj_przydz is
        select *
        from (
                 select PSEUDO,
                        V.DAJ_CALKOWITY_PRZYDZIAL_MYSZY()                                   cal_przydz,
                        DENSE_RANK() over (order by V.DAJ_CALKOWITY_PRZYDZIAL_MYSZY() desc) poz
                 from KOCURY_V V
             )
        where poz < 6;
begin
    for kot in naj_przydz
        loop
            DBMS_OUTPUT.PUT_LINE(kot.PSEUDO || ' - ' || kot.cal_przydz);
        end loop;
end;
