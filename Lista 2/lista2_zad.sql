alter session set nls_date_format = 'YYYY-MM-DD';

-- Zad. 17. Wyświetlić pseudonimy, przydziały myszy oraz nazwy band dla kotów operujących
-- na terenie POLE posiadających przydział myszy większy od 50. Uwzględnić fakt, że są w
-- stadzie koty posiadające prawo do polowań na całym „obsługiwanym” przez stado terenie.
-- Nie stosować podzapytań.

select PSEUDO "POLUJE W POLU", nvl(PRZYDZIAL_MYSZY,0) "PRZYDZIAŁ MYSZY", NAZWA "BANDA"
from KOCURY
         natural join BANDY
where nvl(PRZYDZIAL_MYSZY, 0) > 50
  and TEREN IN ('CALOSC', 'POLE');

-- Zad. 18. Wyświetlić bez stosowania podzapytania imiona i daty przystąpienia do stada
-- kotów, które przystąpiły do stada przed kotem o imieniu ’JACEK’. Wyniki uporządkować
-- malejąco wg daty przystąpienia do stadka.

select K.IMIE, TO_CHAR(K.W_STADKU_OD, 'YYYY-MM-DD') "POLUJE OD"
from KOCURY K
         join KOCURY JK ON K.W_STADKU_OD < JK.W_STADKU_OD and JK.IMIE = 'JACEK'
order by "POLUJE OD" desc;

-- Zad. 19. Dla kotów pełniących funkcję KOT i MILUSIA wyświetlić w kolejności hierarchii
-- imiona wszystkich ich szefów. Zadanie rozwiązać na trzy sposoby:
-- a. z wykorzystaniem tylko złączeń,
-- b. z wykorzystaniem drzewa, operatora CONNECT_BY_ROOT i tabel przestawnych,
-- c. z wykorzystaniem drzewa i funkcji SYS_CONNECT_BY_PATH
-- i operatora CONNECT_BY_ROOT.
-- a
select K.IMIE             "Imie",
       '|'                " ",
       K.FUNKCJA          "Funkcja",
       '|'                " ",
       nvl(SZ1.IMIE, ' ') "Szef 1",
       '|'                " ",
       nvl(SZ2.IMIE, ' ') "Szef 2",
       '|'                " ",
       nvl(SZ3.IMIE, ' ') "Szef 3"
from KOCURY K
         left JOIN KOCURY SZ1 ON K.SZEF = SZ1.PSEUDO
         left join KOCURY SZ2 ON SZ1.SZEF = SZ2.PSEUDO
         left join KOCURY SZ3 ON SZ2.SZEF = SZ3.PSEUDO
where K.FUNKCJA in ('KOT', 'MILUSIA');

-- b
select IMIE,
       '|'           " ",
       FUNKCJA,
       '|'           " ",
       nvl(sz1, ' ') "Szef 1",
       '|'           " ",
       nvl(sz2, ' ') "Szef 2",
       '|'           " ",
       nvl(sz3, ' ') "Szef 3"
from (
    select connect_by_root IMIE Imie, connect_by_root FUNKCJA FUNKCJA, IMIE piv, LEVEL poz
    from KOCURY
    connect by prior SZEF = PSEUDO
    start with FUNKCJA in ('KOT', 'MILUSIA'))
    PIVOT (
    min(piv)
    FOR poz
    IN (
        '2' sz1,
        '3' sz2,
        '4' sz3)
    );
-- c

select Imie, '|' " ", FUNKCJA, substr("Imiona kolejnych szefów", 2) "Imiona kolejnych szefów"
from (
         select connect_by_root IMIE    Imie,
                connect_by_root FUNKCJA FUNKCJA,
                sys_connect_by_path(decode(IMIE, connect_by_root IMIE, '', rpad(IMIE, 10)), '| ')
                                        "Imiona kolejnych szefów",
                SZEF
         from KOCURY
         connect by prior SZEF = PSEUDO
         start with FUNKCJA in ('KOT', 'MILUSIA'))
where SZEF is null;
-- Zad. 20. Wyświetlić imiona wszystkich kotek, które uczestniczyły w incydentach po
-- 01.01.2007. Dodatkowo wyświetlić nazwy band do których należą kotki, imiona ich wrogów
-- wraz ze stopniem wrogości oraz datę incydentu.

select IMIE                                  "Imie kotki",
       NAZWA                                 "Nazwa bandy",
       WK.IMIE_WROGA                         "Imie wroga",
       STOPIEN_WROGOSCI                      "Ocena wroga",
       TO_CHAR(DATA_INCYDENTU, 'YYYY-MM-DD') "Data inc."
from KOCURY
         join BANDY B on KOCURY.NR_BANDY = B.NR_BANDY
         join WROGOWIE_KOCUROW WK on KOCURY.PSEUDO = WK.PSEUDO and TO_CHAR(DATA_INCYDENTU, 'YYYY-MM-DD') > '2007-01-01'
         join WROGOWIE W on WK.IMIE_WROGA = W.IMIE_WROGA
where PLEC = 'D'
order by "Imie kotki";

-- Zad. 21. Określić ile kotów w każdej z band posiada wrogów.

select NAZWA "Nazwa bandy", count(distinct PSEUDO) "Koty z wrogami"
from KOCURY K
         natural join WROGOWIE_KOCUROW
         natural join BANDY
group by NAZWA;

-- Zad. 22. Znaleźć koty (wraz z pełnioną funkcją), które posiadają więcej niż jednego wroga.
select FUNKCJA "Funkcja", PSEUDO "Pseudonim kota", count(IMIE_WROGA) "Liczba wrogów"
from WROGOWIE_KOCUROW WK
         natural join KOCURY K
group by PSEUDO, FUNKCJA
having COUNT(IMIE_WROGA) > 1;

-- Zad. 23. Wyświetlić imiona kotów, które dostają „myszą” premię wraz z ich całkowitym
-- rocznym spożyciem myszy. Dodatkowo jeśli ich roczna dawka myszy przekracza 864
-- wyświetlić tekst ’powyzej 864’, jeśli jest równa 864 tekst ’864’, jeśli jest mniejsza od 864
-- tekst ’poniżej 864’. Wyniki uporządkować malejąco wg rocznej dawki myszy. Do
-- rozwiązania wykorzystać operator zbiorowy UNION.

select IMIE, (NVL(PRZYDZIAL_MYSZY, 0) + MYSZY_EXTRA) * 12 "DAWKA ROCZNA", 'powyzej 864' "DAWKA"
from KOCURY
where MYSZY_EXTRA is not null
  and (NVL(PRZYDZIAL_MYSZY, 0) + MYSZY_EXTRA) * 12 > 864
union
select IMIE, (NVL(PRZYDZIAL_MYSZY, 0) + MYSZY_EXTRA) * 12 "DAWKA ROCZNA", '864' "DAWKA"
from KOCURY
where MYSZY_EXTRA is not null
  and (NVL(PRZYDZIAL_MYSZY, 0) + MYSZY_EXTRA) * 12 = 864
union
select IMIE, (NVL(PRZYDZIAL_MYSZY, 0) + MYSZY_EXTRA) * 12 "DAWKA ROCZNA", 'ponizej 864' "DAWKA"
from KOCURY
where MYSZY_EXTRA is not null
  and (NVL(PRZYDZIAL_MYSZY, 0) + MYSZY_EXTRA) * 12 < 864
order by "DAWKA ROCZNA" desc;

-- Zad. 24. Znaleźć bandy, które nie posiadają członków. Wyświetlić ich numery, nazwy i
-- tereny operowania. Zadanie rozwiązać na dwa sposoby: bez podzapytań i operatorów
-- zbiorowych oraz wykorzystując operatory zbiorowe.

select B.NR_BANDY "NR BANDY", NAZWA, TEREN
from BANDY B
         left join KOCURY K on B.NR_BANDY = K.NR_BANDY
where K.NR_BANDY is null;

-- wykorzystując operatory zbiorowe.

select NR_BANDY "NR BANDY", NAZWA, TEREN
from BANDY
minus
select B.NR_BANDY, NAZWA, TEREN
from BANDY B,
     KOCURY K
where B.NR_BANDY IN K.NR_BANDY;

select NR_BANDY "NR BANDY", NAZWA, TEREN
from BANDY
minus
select B.NR_BANDY, NAZWA, TEREN
from BANDY B
     join KOCURY K on B.NR_BANDY=K.NR_BANDY;
-- Zad. 25. Znaleźć koty, których przydział myszy jest nie mniejszy od potrojonego
-- najwyższego przydziału spośród przydziałów wszystkich MILUŚ operujących w SADZIE.
-- Nie stosować funkcji MAX.

select IMIE, FUNKCJA, nvl(PRZYDZIAL_MYSZY,0) "PRZYDZIAL MYSZY"
from KOCURY
where PRZYDZIAL_MYSZY >= 3 * (select *
                              from (select nvl(PRZYDZIAL_MYSZY, 0)
                                    from KOCURY
                                             join BANDY B on KOCURY.NR_BANDY = B.NR_BANDY and TEREN IN ('SAD', 'CALOSC')
                                    where FUNKCJA = 'MILUSIA'
                                    order by PRZYDZIAL_MYSZY desc)
                              where ROWNUM = 1);

-- Zad. 26. Znaleźć funkcje (pomijając SZEFUNIA), z którymi związany jest najwyższy i
-- najniższy średni całkowity przydział myszy. Nie używać operatorów zbiorowych (UNION,
-- INTERSECT, MINUS).


select FUNKCJA, round(avg(nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0))) "Srednio najw. i najm. myszy"
FROM KOCURY
group by FUNKCJA
having round(avg(nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0))) =
       (select max(round(avg(nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0))))
        from KOCURY
        where FUNKCJA != 'SZEFUNIO'
        group by FUNKCJA)
    or round(avg(nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0))) =
       (select min(round(avg(nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0))))
        from KOCURY
        where FUNKCJA != 'SZEFUNIO'
        group by FUNKCJA);

-- Zad. 27. Znaleźć koty zajmujące pierwszych n miejsc pod względem całkowitej liczby
-- spożywanych myszy (koty o tym samym spożyciu zajmują to samo miejsce!). Zadanie
-- rozwiązać na cztery sposoby:
-- a. wykorzystując podzapytanie skorelowane,
-- b. wykorzystując pseudokolumnę ROWNUM,
-- c. wykorzystując złączenie relacji Kocury z relacją Kocury
-- d. wykorzystując funkcje analityczne.

-- a)
SELECT pseudo, nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0) ZJADA
FROM KOCURY K
WHERE 6 > (SELECT  count(distinct nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0))
           FROM KOCURY
           WHERE (nvl(K.PRZYDZIAL_MYSZY, 0) + nvl(K.MYSZY_EXTRA, 0) <
                  nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0)))
ORDER BY ZJADA desc;

-- b)
select PSEUDO, nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0) ZJADA
from KOCURY
where (nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0)) IN (select *
                                                              from (select distinct nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0) ZJADA
                                                                    from KOCURY
                                                                    order by ZJADA desc)
                                                              where ROWNUM <= 6);
-- c)
select K1.PSEUDO, nvl(K1.PRZYDZIAL_MYSZY, 0) + nvl(K1.MYSZY_EXTRA, 0) ZJADA
from KOCURY K1,
     KOCURY K2
where (nvl(K1.PRZYDZIAL_MYSZY,0) + nvl(K1.MYSZY_EXTRA, 0)) <= (nvl(K2.PRZYDZIAL_MYSZY,0) + nvl(K2.MYSZY_EXTRA, 0))
group by K1.PSEUDO, K1.PRZYDZIAL_MYSZY, K1.MYSZY_EXTRA
having count(distinct nvl(K2.PRZYDZIAL_MYSZY, 0) + nvl(K2.MYSZY_EXTRA, 0)) <= 6
order by ZJADA desc;

-- select K1.PSEUDO, (K1.PRZYDZIAL_MYSZY + nvl(K1.MYSZY_EXTRA, 0)), (K2.PRZYDZIAL_MYSZY + nvl(K2.MYSZY_EXTRA, 0))
-- from KOCURY K1,
--      KOCURY K2
-- where (K1.PRZYDZIAL_MYSZY + nvl(K1.MYSZY_EXTRA, 0)) < (K2.PRZYDZIAL_MYSZY + nvl(K2.MYSZY_EXTRA, 0));
-- d)
select PSEUDO, ZJADA
from (select PSEUDO,
             nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0)                                   ZJADA,
             DENSE_RANK() over (order by nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0) desc) pozycja
      from KOCURY)
where pozycja <= 6
order by ZJADA desc;

-- Zad. 28. Określić lata, dla których liczba wstąpień do stada jest najbliższa (od góry i od dołu)
-- średniej liczbie wstąpień dla wszystkich lat (średnia z wartości określających liczbę wstąpień
-- w poszczególnych latach). Nie stosować perspektywy.

select 'Srednia' ROK, round(avg(count(PSEUDO)), 7) "LICZBA WSTAPIEN"
from Kocury
group by TO_CHAR(w_stadku_od, 'YYYY')
union
select TO_CHAR(W_STADKU_OD, 'YYYY'), count(PSEUDO)
from KOCURY
group by TO_CHAR(W_STADKU_OD, 'YYYY')
having count(PSEUDO) in (
                         (select *
                          from (select count(PSEUDO) w
                                from KOCURY
                                group by TO_CHAR(w_stadku_od, 'YYYY')
                                having count(PSEUDO) >= (select round(avg(count(PSEUDO)), 7)
                                                         from Kocury
                                                         group by TO_CHAR(w_stadku_od, 'YYYY'))
                                order by w)
                          where ROWNUM = 1),
                         (select *
                          from (select count(PSEUDO) w
                                from KOCURY
                                group by TO_CHAR(w_stadku_od, 'YYYY')
                                having count(PSEUDO) <= (select round(avg(count(PSEUDO)), 7)
                                                         from Kocury
                                                         group by TO_CHAR(w_stadku_od, 'YYYY'))
                                order by w desc)
                          where ROWNUM = 1))
order by "LICZBA WSTAPIEN", ROK;

-- Zad. 29. Dla kocurów (płeć męska), dla których całkowity przydział myszy nie przekracza
-- średniej w ich bandzie wyznaczyć następujące dane: imię, całkowite spożycie myszy, numer
-- bandy, średnie całkowite spożycie w bandzie. Nie stosować perspektywy. Zadanie rozwiązać
-- na trzy sposoby:
-- a. ze złączeniem ale bez podzapytań,
-- b. ze złączeniem i z jedynym podzapytaniem w klauzurze FROM,
-- c. bez złączeń i z dwoma podzapytaniami: w klauzurach SELECT i WHERE.

--a)
select K1.IMIE,
       nvl(K1.PRZYDZIAL_MYSZY, 0) + nvl(K1.MYSZY_EXTRA, 0)      ZJADA,
       K1.NR_BANDY                                              "NR BANDY",
       AVG(nvl(K2.PRZYDZIAL_MYSZY, 0) + nvl(K2.MYSZY_EXTRA, 0)) "SREDNIA BANDY"
from KOCURY K1
         join KOCURY K2 ON K1.NR_BANDY = K2.NR_BANDY
where K1.PLEC = 'M'
group by K1.IMIE, K1.NR_BANDY, K1.PRZYDZIAL_MYSZY, K1.MYSZY_EXTRA
having nvl(K1.PRZYDZIAL_MYSZY, 0) + nvl(K1.MYSZY_EXTRA, 0) <=
       AVG(nvl(K2.PRZYDZIAL_MYSZY, 0) + nvl(K2.MYSZY_EXTRA, 0))
order by K1.NR_BANDY desc;

--b)
select K1.IMIE,
       ZJADA,
       "NR BANDY",
       AVG(nvl(K2.PRZYDZIAL_MYSZY, 0) + nvl(K2.MYSZY_EXTRA, 0)) "SREDNIA BANDY"
from (select IMIE, nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0) ZJADA, NR_BANDY "NR BANDY"
      from KOCURY
      where PLEC = 'M') K1
         join KOCURY K2 ON K1."NR BANDY" = K2.NR_BANDY
group by K1.IMIE, "NR BANDY", ZJADA
having ZJADA <=
       AVG(nvl(K2.PRZYDZIAL_MYSZY, 0) + nvl(K2.MYSZY_EXTRA, 0))
order by "NR BANDY" desc;

--c)
select IMIE,
       nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0) ZJADA,
       NR_BANDY                                      "NR BANDY",
       (select AVG(nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0))
        from KOCURY K2
        where K2.NR_BANDY = KOCURY.NR_BANDY
        group by K2.NR_BANDY)                        "SREDNIA BANDY"
from KOCURY
where PLEC = 'M'
  and (nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0)) <=
      (select AVG(nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0)) "SREDNIA BANDY"
       from KOCURY K2
       where K2.NR_BANDY = KOCURY.NR_BANDY
       group by K2.NR_BANDY)
order by "NR BANDY" desc;

-- Zad. 30. Wygenerować listę kotów z zaznaczonymi kotami o najwyższym i o najniższym
-- stażu w swoich bandach. Zastosować operatory zbiorowe.

select IMIE, TO_CHAR(W_STADKU_OD, 'YYYY-MM-DD') "WSTAPIL DO STADKA", ' '
from KOCURY
where W_STADKU_OD NOT IN (
    select min(W_STADKU_OD)
    from KOCURY
    group by NR_BANDY
)
  and W_STADKU_OD NOT IN (
    select max(W_STADKU_OD)
    from KOCURY
    group by NR_BANDY
)
union
select IMIE, TO_CHAR(W_STADKU_OD, 'YYYY-MM-DD'), '<--- NAJSTARSZY STAZEM W BANDZIE ' || NAZWA
from KOCURY
         join BANDY B on KOCURY.NR_BANDY = B.NR_BANDY
where W_STADKU_OD IN (select min(W_STADKU_OD)
                      from KOCURY
                      group by NR_BANDY)
union
select IMIE, TO_CHAR(W_STADKU_OD, 'YYYY-MM-DD'), '<--- NAJMLODSZY STAZEM W BANDZIE ' || NAZWA
from KOCURY
         join BANDY B2 on KOCURY.NR_BANDY = B2.NR_BANDY
where W_STADKU_OD IN (select max(W_STADKU_OD)
                      from KOCURY
                      group by NR_BANDY)
order by IMIE;

-- Zad. 31. Zdefiniować perspektywę wybierającą następujące dane: nazwę bandy, średni,
-- maksymalny i minimalny przydział myszy w bandzie, całkowitą liczbę kotów w bandzie oraz
-- liczbę kotów pobierających w bandzie przydziały dodatkowe. Posługując się zdefiniowaną
-- perspektywą wybrać następujące dane o kocie, którego pseudonim podawany jest
-- interaktywnie z klawiatury: pseudonim, imię, funkcja, przydział myszy, minimalny i
-- maksymalny przydział myszy w jego bandzie oraz datę wstąpienia do stada.

create view STATYSTYKI_BAND as
select NAZWA                        NAZWA_BANDY,
       AVG(NVL(PRZYDZIAL_MYSZY, 0)) SRE_SPOZ,
       MAX(NVL(PRZYDZIAL_MYSZY, 0)) MAX_SPOZ,
       MIN(NVL(PRZYDZIAL_MYSZY, 0)) MIN_SPOZ,
       COUNT(PSEUDO)                KOTY,
       COUNT(MYSZY_EXTRA)           KOTY_Z_DOD
from BANDY B
         join KOCURY K on B.NR_BANDY = K.NR_BANDY
group by NAZWA;

select PSEUDO                                  PSEUDONIM,
       IMIE,
       FUNKCJA,
       NVL(PRZYDZIAL_MYSZY, 0)                 ZJADA,
       'OD ' || MIN_SPOZ || ' DO ' || MAX_SPOZ "GRANICE SPOZYCIA",
       TO_CHAR(W_STADKU_OD, 'YYYY-MM-DD')      "LOWI OD"
from KOCURY
         left join BANDY B on KOCURY.NR_BANDY = B.NR_BANDY
         left join STATYSTYKI_BAND SB on B.NAZWA = SB.NAZWA_BANDY
where PSEUDO = &user_ps;

-- Zad. 32. Dla kotów o trzech najdłuższym stażach w połączonych bandach CZARNI
-- RYCERZE i ŁACIACI MYŚLIWI zwiększyć przydział myszy o 10% minimalnego
-- przydziału w całym stadzie lub o 10 w zależności od tego czy podwyżka dotyczy kota płci
-- żeńskiej czy kota płci męskiej. Przydział myszy extra dla kotów obu płci zwiększyć o 15%
-- średniego przydziału extra w bandzie kota. Wyświetlić na ekranie wartości przed i po
-- podwyżce a następnie wycofać zmiany.
select PSEUDO, PLEC, PRZYDZIAL, EXTRA
from (
         select PSEUDO,
                PLEC,
                nvl(PRZYDZIAL_MYSZY, 0)            PRZYDZIAL,
                nvl(MYSZY_EXTRA, 0)                EXTRA,
                RANK() over (order by W_STADKU_OD) poz
         from KOCURY
                  join BANDY B on KOCURY.NR_BANDY = B.NR_BANDY AND NAZWA = 'CZARNI RYCERZE'
         union
         select PSEUDO,
                PLEC,
                nvl(PRZYDZIAL_MYSZY, 0),
                nvl(MYSZY_EXTRA, 0),
                RANK() over (order by W_STADKU_OD)
         from KOCURY
                  join BANDY B on KOCURY.NR_BANDY = B.NR_BANDY AND NAZWA = 'LACIACI MYSLIWI')
where poz < 4;


update KOCURY K
set PRZYDZIAL_MYSZY=
        DECODE(PLEC, 'M', NVL(PRZYDZIAL_MYSZY, 0) + 10, NVL(PRZYDZIAL_MYSZY, 0) + round((
                                                                                            select min(nvl(PRZYDZIAL_MYSZY, 0))
                                                                                            from KOCURY
                                                                                        ) * 0.1)),
    MYSZY_EXTRA=NVL(MYSZY_EXTRA, 0) +
                round(0.15 * (select avg(nvl(MYSZY_EXTRA, 0))
                              from KOCURY
                              where K.NR_BANDY = NR_BANDY
                                group by NR_BANDY))
WHERE PSEUDO IN (
    select PSEUDO
    from (
             select PSEUDO,
                    RANK() over (order by W_STADKU_OD) poz
             from KOCURY
                      join BANDY B on KOCURY.NR_BANDY = B.NR_BANDY AND NAZWA = 'CZARNI RYCERZE'
             union
             select PSEUDO,
                    RANK() over (order by W_STADKU_OD)
             from KOCURY
                      join BANDY B on KOCURY.NR_BANDY = B.NR_BANDY AND NAZWA = 'LACIACI MYSLIWI')
    where poz < 4);

rollback;

-- Zad. 33. Napisać zapytanie, w ramach którego obliczone zostaną sumy całkowitego spożycia
-- myszy przez koty sprawujące każdą z funkcji z podziałem na bandy i płcie kotów.
-- Podsumować przydziały dla każdej z funkcji. Zadanie wykonać na dwa sposoby:
-- a. z wykorzystaniem tzw. raportu macierzowego,
select NAZWA,
       DECODE(PLEC, 'M', 'Kocur', 'Kotka')                                                         PLEC,
       TO_CHAR(count(PSEUDO))                                                                      ILE,
       to_char(sum(DECODE(FUNKCJA, 'SZEFUNIO', nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0), 0))) SZEFUNIO,
       to_char(sum(DECODE(FUNKCJA, 'BANDZIOR', nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0), 0))) BANDZIOR,
       to_char(sum(DECODE(FUNKCJA, 'LOWCZY', nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0), 0)))   LOWCZY,
       to_char(sum(DECODE(FUNKCJA, 'LAPACZ', nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0), 0)))   LAPACZ,
       to_char(sum(DECODE(FUNKCJA, 'KOT', nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0), 0)))      KOT,
       to_char(sum(DECODE(FUNKCJA, 'MILUSIA', nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0), 0)))  MILUSIA,
       to_char(sum(DECODE(FUNKCJA, 'DZIELCZY', nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0), 0))) DZIELCZY,
       to_char(sum(nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0)))                                 SUMA
from KOCURY
         natural join BANDY
group by NAZWA, PLEC
union
select 'Z----------------',
       '------',
       '----',
       '---------',
       '---------',
       '---------',
       '---------',
       '---------',
       '---------',
       '---------',
       '-----------'
from dual
union
select 'ZJADA RAZEM',
       ' ',
       ' ',
       to_char(sum(DECODE(FUNKCJA, 'SZEFUNIO', nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0), 0))),
       to_char(sum(DECODE(FUNKCJA, 'BANDZIOR', nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0), 0))),
       to_char(sum(DECODE(FUNKCJA, 'LOWCZY', nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0), 0))),
       to_char(sum(DECODE(FUNKCJA, 'LAPACZ', nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0), 0))),
       to_char(sum(DECODE(FUNKCJA, 'KOT', nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0), 0))),
       to_char(sum(DECODE(FUNKCJA, 'MILUSIA', nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0), 0))),
       to_char(sum(DECODE(FUNKCJA, 'DZIELCZY', nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0), 0))),
       to_char(sum(nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0)))
from KOCURY;


-- b. z wykorzystaniem klauzuli PIVOT
select "NAZWA BANDY",
       PLEC,
       ILE,
       TO_CHAR(nvl(SZEFUNIO, 0)) SZEFUNIO,
       TO_CHAR(nvl(BANDZIOR, 0)) BANDZIOR,
       TO_CHAR(nvl(LOWCZY, 0))   LOWCZY,
       TO_CHAR(nvl(LAPACZ, 0))   LAPACZ,
       TO_CHAR(nvl(KOT, 0))      KOT,
       TO_CHAR(nvl(MILUSIA, 0))  MILUSIA,
       TO_CHAR(nvl(DZIELCZY, 0)) DZIELCZY,
       TO_CHAR(SUMA)             SUMA
from (select *
      FROM (
          select NAZWA                                                                                    "NAZWA BANDY",
                 DECODE(PLEC, 'M', 'Kocur', 'Kotka')                                                      PLEC,
                 TO_CHAR(count(PSEUDO) over (partition by PLEC, B.NR_BANDY))                              ILE,
                 FUNKCJA,
                 (nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0))                                          cal_prz,
                 (sum(nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0)) over (partition by PLEC,B.NR_BANDY)) SUMA
          from KOCURY
                   join BANDY B on KOCURY.NR_BANDY = B.NR_BANDY)
          PIVOT (
          sum(nvl(cal_prz, 0))
          FOR FUNKCJA
          IN ( 'SZEFUNIO' SZEFUNIO,
              'BANDZIOR' BANDZIOR,
              'LOWCZY' LOWCZY,
              'LAPACZ' LAPACZ,
              'KOT' KOT,
              'MILUSIA' MILUSIA,
              'DZIELCZY' DZIELCZY
              )))
union
select 'Z----------------',
       '------',
       '----',
       '---------',
       '---------',
       '---------',
       '---------',
       '---------',
       '---------',
       '---------',
       '-----------'
from dual
union
select 'ZJADA RAZEM',
       PLEC,
       ' ',
       TO_CHAR(nvl(SZEFUNIO, 0)) SZEFUNIO,
       TO_CHAR(nvl(BANDZIOR, 0)) BANDZIOR,
       TO_CHAR(nvl(LOWCZY, 0))   LOWCZY,
       TO_CHAR(nvl(LAPACZ, 0))   LAPACZ,
       TO_CHAR(nvl(KOT, 0))      KOT,
       TO_CHAR(nvl(MILUSIA, 0))  MILUSIA,
       TO_CHAR(nvl(DZIELCZY, 0)) DZIELCZY,
       TO_CHAR(SUMA)             SUMA
from (select *
      FROM (
          select 'ZJADA RAZEM',
                 ' '                                                                            PLEC,
                 ' ',
                 FUNKCJA,
                 sum(nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0)) over (partition by FUNKCJA) cal_prz,
                 sum(nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0)) over ( )                    SUMA
          from KOCURY
                   join BANDY B on KOCURY.NR_BANDY = B.NR_BANDY)
          PIVOT (
          sum(nvl(cal_prz, 0))
          FOR FUNKCJA
          IN ( 'SZEFUNIO' SZEFUNIO,
              'BANDZIOR' BANDZIOR,
              'LOWCZY' LOWCZY,
              'LAPACZ' LAPACZ,
              'KOT' KOT,
              'MILUSIA' MILUSIA,
              'DZIELCZY' DZIELCZY
              )));

select * from DUAL;