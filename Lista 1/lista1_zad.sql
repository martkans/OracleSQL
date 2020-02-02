alter session set nls_date_format = 'YYYY-MM-DD';

--Zad. 1. Znajdź imiona wrogów, którzy dopuścili się incydentów w 2009r.
select IMIE_WROGA WROG,
       OPIS_INCYDENTU PRZEWINA
from WROGOWIE_KOCUROW
where EXTRACT(year from DATA_INCYDENTU) = 2009;

-- Zad. 2. Znajdź wszystkie kotki (płeć żeńska), które przystąpiły do stada między 1 września
-- 2005r. a 31 lipca 2007r.
select IMIE,
       FUNKCJA,
       TO_CHAR(W_STADKU_OD, 'YYYY-MM-DD') "Z NAMI OD"
from KOCURY
where PLEC = 'D'
  AND W_STADKU_OD between '2005-09-01' and '2007-07-31';

-- Zad. 3. Wyświetl imiona, gatunki i stopnie wrogości nieprzekupnych wrogów. Wyniki mają
-- być uporządkowane rosnąco według stopnia wrogości.
select IMIE_WROGA WROG,
       GATUNEK,
       STOPIEN_WROGOSCI "STOPIEN WROGOSCI"
from WROGOWIE
where LAPOWKA is null
order by STOPIEN_WROGOSCI;

-- Zad. 4. Wyświetlić dane o kotach płci męskiej zebrane w jednej kolumnie postaci:
-- JACEK zwany PLACEK (fun. LOWCZY) lowi myszki w bandzie2 od 2008-12-01
-- Wyniki należy uporządkować malejąco wg daty przystąpienia do stada. W przypadku tej
-- samej daty przystąpienia wyniki uporządkować alfabetycznie wg pseudonimów.
select IMIE || ' zwany ' || PSEUDO || ' (fun. ' || FUNKCJA || ') lowi myszki w bandzie ' || NR_BANDY || ' od ' ||
       to_char(W_STADKU_OD, 'YYYY-MM-DD')
            "WSZYSTKO O KOCURACH"
from KOCURY
where PLEC = 'M'
order by W_STADKU_OD desc,
         PSEUDO;

-- Zad. 5. Znaleźć pierwsze wystąpienie litery A i pierwsze wystąpienie litery L w każdym
-- pseudonimie a następnie zamienić znalezione litery na odpowiednio # i %. Wykorzystać
-- funkcje działające na łańcuchach. Brać pod uwagę tylko te pseudonimy, w których występują
-- obie litery.
select PSEUDO,
       regexp_replace(regexp_replace(PSEUDO, 'L', '%', 1, 1), 'A', '#', 1, 1)
           "Po wymianie A na # oraz L na %"
from KOCURY
where PSEUDO like '%A%L%'
   OR PSEUDO LIKE '%L%A%';

-- Zad. 6. Wyświetlić imiona kotów z co najmniej dziesięcioletnim stażem (które dodatkowo
-- przystępowały do stada od 1 marca do 30 września), daty ich przystąpienia do stada,
-- początkowy przydział myszy (obecny przydział, ze względu na podwyżkę po pół roku
-- członkostwa, jest o 10% wyższy od początkowego) , datę wspomnianej podwyżki o 10%
-- oraz aktualnym przydział myszy. Wykorzystać odpowiednie funkcje działające na datach. W
-- poniższym rozwiązaniu datą bieżącą jest 03.07.2019
select IMIE,
       to_char(W_STADKU_OD, 'YYYY-MM-DD') "W stadku",
       ROUND((NVL(PRZYDZIAL_MYSZY,0)/1.1)) "Zjadal",
       to_char(add_months(W_STADKU_OD, 6), 'YYYY-MM-DD') "Podwyzka",
       NVL(PRZYDZIAL_MYSZY,0) "Zjada"
from KOCURY
where months_between(sysdate, W_STADKU_OD) / 12 >= 10
  and extract(month from W_STADKU_OD) between 3 and 9
order by "Zjada" desc;

-- Zad. 7. Wyświetlić imiona, kwartalne przydziały myszy i kwartalne przydziały dodatkowe
-- dla wszystkich kotów, u których przydział myszy jest większy od dwukrotnego przydziału
-- dodatkowego ale nie mniejszy od 55.
select IMIE, NVL(PRZYDZIAL_MYSZY, 0) * 3 "MYSZY KWARTALNIE", NVL(MYSZY_EXTRA, 0) * 3 "KWARTALNE DODATKI"
from KOCURY
where NVL(PRZYDZIAL_MYSZY, 0) > 2 * NVL(MYSZY_EXTRA, 0)
  and NVL(PRZYDZIAL_MYSZY, 0) >= 55
order by "MYSZY KWARTALNIE" desc;

-- Zad. 8. Wyświetlić dla każdego kota (imię) następujące informacje o całkowitym rocznym
-- spożyciu myszy: wartość całkowitego spożycia jeśli przekracza 660, ’Limit’ jeśli jest równe
-- 660, ’Ponizej 660’ jeśli jest mniejsze od 660. Nie używać operatorów zbiorowych (UNION,
-- INTERSECT, MINUS).
select IMIE,
       CASE
           when (12 * (NVL(PRZYDZIAL_MYSZY,0) + NVL(MYSZY_EXTRA, 0))) = 660 then 'Limit'
           when (12 * (NVL(PRZYDZIAL_MYSZY,0) + NVL(MYSZY_EXTRA, 0))) < 660 then 'Ponizej 660'
           ELSE TO_CHAR(12 * (NVL(PRZYDZIAL_MYSZY,0) + NVL(MYSZY_EXTRA, 0)))
           END "Zjada rocznie"
from KOCURY
order by IMIE;

-- Zad. 9. Po kilkumiesięcznym, spowodowanym kryzysem, zamrożeniu wydawania myszy
-- Tygrys z dniem bieżącym wznowił wypłaty zgodnie z zasadą, że koty, które przystąpiły do
-- stada w pierwszej połowie miesiąca (łącznie z 15-m) otrzymują pierwszy po przerwie
-- przydział myszy w ostatnią środę bieżącego miesiąca, natomiast koty, które przystąpiły do
-- stada po 15-ym, pierwszy po przerwie przydział myszy otrzymują w ostatnią środę
-- następnego miesiąca. W kolejnych miesiącach myszy wydawane są wszystkim kotom w
-- ostatnią środę każdego miesiąca. Wyświetlić dla każdego kota jego pseudonim, datę
-- przystąpienia do stada oraz datę pierwszego po przerwie przydziału myszy, przy założeniu, że
-- datą bieżącą jest 24 i 26 wrzesień 2019.
select PSEUDO, to_char(W_STADKU_OD, 'YYYY-MM-DD') "W STADKU",
    CASE when extract(day from W_STADKU_OD)<=15
        and to_char(next_day(last_day('2019-09-24') - 7, 'ŚRODA'), 'YYYY-MM-DD') > '2019-09-24'
        then to_char(next_day(last_day('2019-09-24') - 7, 'ŚRODA'), 'YYYY-MM-DD')
    ELSE to_char(next_day(last_day(add_months('2019-09-24', 1)) - 7, 'ŚRODA'), 'YYYY-MM-DD') END WYPLATA
from KOCURY;

select PSEUDO, to_char(W_STADKU_OD, 'YYYY-MM-DD') "W STADKU",
    CASE when extract(day from W_STADKU_OD)<=15
        and to_char(next_day(last_day('2019-09-26') - 7, 'ŚRODA'), 'YYYY-MM-DD') > '2019-09-26'
        then to_char(next_day(last_day('2019-09-26') - 7, 'ŚRODA'), 'YYYY-MM-DD')
    ELSE to_char(next_day(last_day(add_months('2019-09-26', 1)) - 7, 'ŚRODA'), 'YYYY-MM-DD') END WYPLATA
from KOCURY;
-- Zad. 10. Atrybut pseudo w tabeli Kocury jest kluczem głównym tej tabeli. Sprawdzić, czy
-- rzeczywiście wszystkie pseudonimy są wzajemnie różne. Zrobić to samo dla atrybutu szef.
select PSEUDO || ' - ' || decode(count(PSEUDO), 1, 'Unikalny', 'nieunikalny') "Unikalnosc atr. PSEUDO"
from KOCURY
group by PSEUDO;

select SZEF || ' - ' || decode(count(PSEUDO), 1, 'Unikalny', 'nieunikalny') "Unikalnosc atr. SZEF"
from KOCURY
where SZEF is not null
group by SZEF
order by SZEF;

-- Zad. 11. Znaleźć pseudonimy kotów posiadających co najmniej dwóch wrogów.
select PSEUDO "Pseudonim", count(PSEUDO) "Liczba wrogow"
from WROGOWIE_KOCUROW
group by PSEUDO
having count(PSEUDO) >= 2;

-- Zad. 12. Znaleźć maksymalny całkowity przydział myszy dla wszystkich grup funkcyjnych (z
-- pominięciem SZEFUNIA i kotów płci męskiej) o średnim całkowitym przydziale (z
-- uwzględnieniem dodatkowych przydziałów – myszy_extra) większym od 50.
select 'Liczba kotów = ' || count(PSEUDO) || ' łowi jako ' || FUNKCJA || ' i zjada max ' ||
       max(nvl(PRZYDZIAL_MYSZY,0) + NVL(MYSZY_EXTRA, 0))  " "
from KOCURY
where FUNKCJA != 'SZEFUNIO'
  and PLEC != 'M'
group by FUNKCJA
having avg(NVL(PRZYDZIAL_MYSZY,0) + NVL(MYSZY_EXTRA, 0)) > 50;

-- Zad. 13. Wyświetlić minimalny przydział myszy w każdej bandzie z podziałem na płcie.
select NR_BANDY "Nr bandy", PLEC "Plec", min(NVL(PRZYDZIAL_MYSZY,0)) "Minimalny przydzial"
FROM KOCURY
group by NR_BANDY, PLEC;

-- Zad. 14. Wyświetlić informację o kocurach (płeć męska) posiadających w hierarchii
-- przełożonych szefa płci męskiej pełniącego funkcję BANDZIOR (wyświetlić także dane tego
-- przełożonego). Dane kotów podległych konkretnemu szefowi mają być wyświetlone zgodnie
-- z ich miejscem w hierarchii podległości.
select level "Poziom", PSEUDO "Pseudonim", FUNKCJA "Funkcja", NR_BANDY "Nr bandy"
from KOCURY
where PLEC = 'M'
connect by prior PSEUDO=SZEF
start with FUNKCJA = 'BANDZIOR';

-- Zad. 15. Przedstawić informację o podległości kotów posiadających dodatkowy przydział
-- myszy tak aby imię kota stojącego najwyżej w hierarchii było wyświetlone z najmniejszym
-- wcięciem a pozostałe imiona z wcięciem odpowiednim do miejsca w hierarchii.
select rpad('===>', (LEVEL - 1) * 4, '===>') || (LEVEL - 1) || '   ' || IMIE "Hierarchia",
       NVL(SZEF, 'Sam sobie szefem')                                         "Pseudo szefa",
       FUNKCJA
from KOCURY
where MYSZY_EXTRA is not null
connect by prior PSEUDO = SZEF
start with SZEF is null;

-- Zad. 16. Wyświetlić określoną pseudonimami drogę służbową (przez wszystkich kolejnych
-- przełożonych do głównego szefa) kotów płci męskiej o stażu dłuższym niż dziesięć lat (w
-- poniższym rozwiązaniu datą bieżącą jest 03.07.2019) nie posiadających dodatkowego
-- przydziału myszy.
SELECT RPAD(' ', (LEVEL - 1) * 4) || PSEUDO "Droga sluzbowa"
from KOCURY
connect by prior SZEF = PSEUDO
start with months_between(sysdate, W_STADKU_OD) / 12 > 10
       and PLEC = 'M'
       and MYSZY_EXTRA is null;

