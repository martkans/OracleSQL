INSERT INTO KOCURY_R VALUES ('MRUCZEK','M','TYGRYS','SZEFUNIO',NULL,'2002-01-01',103,33,1);
insert INTO KOCURY_R VALUES
        ('MICKA','D','LOLA','MILUSIA',(SELECT ref(r) from KOCURY_R r where r.PSEUDO='TYGRYS'),'2009-10-14',25,47,1);
insert into KOCURY_R VALUES
        ('CHYTRY','M','BOLEK','DZIELCZY',(SELECT ref(r) from KOCURY_R r where r.PSEUDO='TYGRYS'),'2002-05-05',50,NULL,1);
insert into KOCURY_R VALUES
        ('KOREK','M','ZOMBI','BANDZIOR',(SELECT ref(r) from KOCURY_R r where r.PSEUDO='TYGRYS'),'2004-03-16',75,13,3);
insert into KOCURY_R VALUES
        ('BOLEK','M','LYSY','BANDZIOR',(SELECT ref(r) from KOCURY_R r where r.PSEUDO='TYGRYS'),'2006-08-15',72,21,2);
insert into KOCURY_R VALUES
        ('RUDA','D','MALA','MILUSIA',(SELECT ref(r) from KOCURY_R r where r.PSEUDO='TYGRYS'),'2006-09-17',22,42,1);
insert into KOCURY_R VALUES
        ('PUCEK','M','RAFA','LOWCZY',(SELECT ref(r) from KOCURY_R r where r.PSEUDO='TYGRYS'),'2006-10-15',65,NULL,4);
insert into KOCURY_R VALUES
        ('JACEK','M','PLACEK','LOWCZY',(SELECT ref(r) from KOCURY_R r where r.PSEUDO='LYSY'),'2008-12-01',67,NULL,2);
insert into KOCURY_R VALUES
        ('BARI','M','RURA','LAPACZ',(SELECT ref(r) from KOCURY_R r where r.PSEUDO='LYSY'),'2009-09-01',56,NULL,2);
insert into KOCURY_R VALUES
        ('BELA','D','LASKA','MILUSIA',(SELECT ref(r) from KOCURY_R r where r.PSEUDO='LYSY'),'2008-02-01',24,28,2);
insert into KOCURY_R VALUES
        ('ZUZIA','D','SZYBKA','LOWCZY',(SELECT ref(r) from KOCURY_R r where r.PSEUDO='LYSY'),'2006-07-21',65,NULL,2);
insert into KOCURY_R VALUES
        ('SONIA','D','PUSZYSTA','MILUSIA',(SELECT ref(r) from KOCURY_R r where r.PSEUDO='ZOMBI'),'2010-11-18',20,35,3);
insert into KOCURY_R VALUES
        ('PUNIA','D','KURKA','LOWCZY',(SELECT ref(r) from KOCURY_R r where r.PSEUDO='ZOMBI'),'2008-01-01',61,NULL,3);
insert into KOCURY_R VALUES
        ('LUCEK','M','ZERO','KOT',(SELECT ref(r) from KOCURY_R r where r.PSEUDO='KURKA'),'2010-03-01',43,NULL,3);
insert into KOCURY_R VALUES
        ('LATKA','D','UCHO','KOT',(SELECT ref(r) from KOCURY_R r where r.PSEUDO='RAFA'),'2011-01-01',40,NULL,4);
insert into KOCURY_R VALUES
        ('DUDEK','M','MALY','KOT',(SELECT ref(r) from KOCURY_R r where r.PSEUDO='RAFA'),'2011-05-15',40,NULL,4);
insert into KOCURY_R values
        ('KSAWERY','M','MAN','LAPACZ',(SELECT ref(r) from KOCURY_R r where r.PSEUDO='RAFA'),'2008-07-12',51,NULL,4);
insert into KOCURY_R values
        ('MELA','D','DAMA','LAPACZ',(SELECT ref(r) from KOCURY_R r where r.PSEUDO='RAFA'),'2008-11-01',51,NULL,4);
commit;

INSERT ALL
INTO WROGOWIE_KOCUROW_R
    VALUES (1,(select ref(r) from KOCURY_R r where PSEUDO = 'TYGRYS'),'KAZIO','2004-10-13','USILOWAL NABIC NA WIDLY')
INTO WROGOWIE_KOCUROW_R
    VALUES (2,(select ref(r) from KOCURY_R r where PSEUDO = 'ZOMBI'),'SWAWOLNY DYZIO','2005-03-07','WYBIL OKO Z PROCY')
INTO WROGOWIE_KOCUROW_R
    VALUES (3,(select ref(r) from KOCURY_R r where PSEUDO = 'BOLEK'),'KAZIO','2005-03-29','POSZCZUL BURKIEM')
INTO WROGOWIE_KOCUROW_R
    VALUES (4,(select ref(r) from KOCURY_R r where PSEUDO = 'SZYBKA'),'GLUPIA ZOSKA','2006-09-12','UZYLA KOTA JAKO SCIERKI')
INTO WROGOWIE_KOCUROW_R
    VALUES (5,(select ref(r) from KOCURY_R r where PSEUDO = 'MALA'),'CHYTRUSEK','2007-03-07','ZALECAL SIE')
INTO WROGOWIE_KOCUROW_R
    VALUES (6,(select ref(r) from KOCURY_R r where PSEUDO = 'TYGRYS'),'DZIKI BILL','2007-06-12','USILOWAL POZBAWIC ZYCIA')
INTO WROGOWIE_KOCUROW_R
    VALUES (7,(select ref(r) from KOCURY_R r where PSEUDO = 'BOLEK'),'DZIKI BILL','2007-11-10','ODGRYZL UCHO')
INTO WROGOWIE_KOCUROW_R
    VALUES (8,(select ref(r) from KOCURY_R r where PSEUDO = 'LASKA'),'DZIKI BILL','2008-12-12','POGRYZL ZE LEDWO SIE WYLIZALA')
INTO WROGOWIE_KOCUROW_R
    VALUES (9,(select ref(r) from KOCURY_R r where PSEUDO = 'LASKA'),'KAZIO','2009-01-07','ZLAPAL ZA OGON I ZROBIL WIATRAK')
INTO WROGOWIE_KOCUROW_R
    VALUES (10,(select ref(r) from KOCURY_R r where PSEUDO = 'DAMA'),'KAZIO','2009-02-07','CHCIAL OBEDRZEC ZE SKORY')
INTO WROGOWIE_KOCUROW_R
    VALUES (11,(select ref(r) from KOCURY_R r where PSEUDO = 'MAN'),'REKSIO','2009-04-14','WYJATKOWO NIEGRZECZNIE OBSZCZEKAL')
INTO WROGOWIE_KOCUROW_R
    VALUES (12,(select ref(r) from KOCURY_R r where PSEUDO = 'LYSY'),'BETHOVEN','2009-05-11','NIE PODZIELIL SIE SWOJA KASZA')
INTO WROGOWIE_KOCUROW_R
    VALUES (13,(select ref(r) from KOCURY_R r where PSEUDO = 'RURA'),'DZIKI BILL','2009-09-03','ODGRYZL OGON')
INTO WROGOWIE_KOCUROW_R
    VALUES (14,(select ref(r) from KOCURY_R r where PSEUDO = 'PLACEK'),'BAZYLI','2010-07-12','DZIOBIAC UNIEMOZLIWIL PODEBRANIE KURCZAKA')
INTO WROGOWIE_KOCUROW_R
    VALUES (15,(select ref(r) from KOCURY_R r where PSEUDO = 'PUSZYSTA'),'SMUKLA','2010-11-19','OBRZUCILA SZYSZKAMI')
INTO WROGOWIE_KOCUROW_R
    VALUES (16,(select ref(r) from KOCURY_R r where PSEUDO = 'KURKA'),'BUREK','2010-12-14','POGONIL')
INTO WROGOWIE_KOCUROW_R
    VALUES (17,(select ref(r) from KOCURY_R r where PSEUDO = 'MALY'),'CHYTRUSEK','2011-07-13','PODEBRAL PODEBRANE JAJKA')
INTO WROGOWIE_KOCUROW_R
    VALUES (18,(select ref(r) from KOCURY_R r where PSEUDO = 'UCHO'),'SWAWOLNY DYZIO','2011-07-14','OBRZUCIL KAMIENIAMI')
SELECT * FROM Dual;

commit;

insert all
    into PLEBS_R values (1,(select ref(r) from KOCURY_R r where PSEUDO = 'RURA'))
    into PLEBS_R values (2,(select ref(r) from KOCURY_R r where PSEUDO = 'ZERO'))
    into PLEBS_R values (3,(select ref(r) from KOCURY_R r where PSEUDO = 'PUSZYSTA'))
    into PLEBS_R values (4,(select ref(r) from KOCURY_R r where PSEUDO = 'UCHO'))
    into PLEBS_R values (5,(select ref(r) from KOCURY_R r where PSEUDO = 'MALY'))
    into PLEBS_R values (6,(select ref(r) from KOCURY_R r where PSEUDO = 'MALA'))
    into PLEBS_R values (7,(select ref(r) from KOCURY_R r where PSEUDO = 'LASKA'))
    into PLEBS_R values (8,(select ref(r) from KOCURY_R r where PSEUDO = 'MAN'))
    into PLEBS_R values (9,(select ref(r) from KOCURY_R r where PSEUDO = 'DAMA'))
select * from dual;

commit;

insert all
    into ELITA_R values (1,(select ref(r) from KOCURY_R r where PSEUDO = 'PLACEK'), null)
    into ELITA_R values (2,(select ref(r) from KOCURY_R r where PSEUDO = 'LOLA'), (select ref(r) from PLEBS_R r where r.KOT.PSEUDO = 'PUSZYSTA'))
    into ELITA_R values (3,(select ref(r) from KOCURY_R r where PSEUDO = 'TYGRYS'), (select ref(r) from PLEBS_R r where r.KOT.PSEUDO = 'RURA'))
    into ELITA_R values (4,(select ref(r) from KOCURY_R r where PSEUDO = 'BOLEK'), null)
    into ELITA_R values (5,(select ref(r) from KOCURY_R r where PSEUDO = 'ZOMBI'), (select ref(r) from PLEBS_R r where r.KOT.PSEUDO = 'ZERO'))
    into ELITA_R values (6,(select ref(r) from KOCURY_R r where PSEUDO = 'LYSY'), (select ref(r) from PLEBS_R r where r.KOT.PSEUDO = 'MALY'))
    into ELITA_R values (7,(select ref(r) from KOCURY_R r where PSEUDO = 'SZYBKA'), (select ref(r) from PLEBS_R r where r.KOT.PSEUDO = 'UCHO'))
    into ELITA_R values (8,(select ref(r) from KOCURY_R r where PSEUDO = 'RAFA'), (select ref(r) from PLEBS_R r where r.KOT.PSEUDO = 'MALA'))
    into ELITA_R values (9,(select ref(r) from KOCURY_R r where PSEUDO = 'KURKA'), null)
select * from dual;

commit ;

insert all
    into KONTA_R VALUES (1, (select ref(r) from ELITA_R r where NR_CZLONKA_ELITY = 3), '2019-12-12', null)
    into KONTA_R VALUES (2, (select ref(r) from ELITA_R r where NR_CZLONKA_ELITY = 1), '2019-12-17', '2019-12-20')
    into KONTA_R VALUES (3, (select ref(r) from ELITA_R r where NR_CZLONKA_ELITY = 3), '2019-12-17', null)
    into KONTA_R VALUES (4, (select ref(r) from ELITA_R r where NR_CZLONKA_ELITY = 3), '2019-12-24', '2019-12-25')
    into KONTA_R VALUES (5, (select ref(r) from ELITA_R r where NR_CZLONKA_ELITY = 9), '2019-12-24', null)
    into KONTA_R VALUES (6, (select ref(r) from ELITA_R r where NR_CZLONKA_ELITY = 8), '2019-12-27', '2019-12-29')
    into KONTA_R VALUES (7, (select ref(r) from ELITA_R r where NR_CZLONKA_ELITY = 7), '2019-12-28', '2019-12-30')
    into KONTA_R VALUES (8, (select ref(r) from ELITA_R r where NR_CZLONKA_ELITY = 5), '2019-12-30', '2019-12-31')
select * from dual;

insert into KONTA_R VALUES (9, (select ref(r) from ELITA_R r where NR_CZLONKA_ELITY = 1), '2019-11-11', null);
commit;
