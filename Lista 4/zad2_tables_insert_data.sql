drop table PLEBS;
drop table ELITA;
drop table KONTA;

create table PLEBS
(
    pseudo VARCHAR2(15)
        constraint pl_pk PRIMARY KEY
        constraint pl_ko_fk references KOCURY (PSEUDO)
);

create table ELITA
(
    pseudo VARCHAR2(15)
        constraint el_pk PRIMARY KEY
        constraint el_ko_fk references KOCURY (PSEUDO),
    pseudo_slugi varchar(15)
        constraint el_pl_fk references PLEBS (PSEUDO)
);

create table KONTA
(
    nr_konta number
        constraint kon_pk PRIMARY KEY,
    pseudo            VARCHAR2(15)
        constraint kon_el_fk references ELITA (PSEUDO),
    data_wprowadzenia date
        constraint kon_dw_nn not null,
    data_usuniecia    date,
    constraint kon_dw_du_val check ( data_usuniecia > data_wprowadzenia )
);

insert all
    into PLEBS values ('RURA')
    into PLEBS values ('ZERO')
    into PLEBS values ('PUSZYSTA')
    into PLEBS values ('UCHO')
    into PLEBS values ('MALY')
    into PLEBS values ('MALA')
    into PLEBS values ('LASKA')
    into PLEBS values ('MAN')
    into PLEBS values ('DAMA')
select *
from DUAL;

insert all
    into ELITA values ('PLACEK', null)
    into ELITA values ('LOLA', 'PUSZYSTA')
    into ELITA values ('TYGRYS', 'RURA')
    into ELITA values ('BOLEK', null)
    into ELITA values ('ZOMBI', 'ZERO')
    into ELITA values ('LYSY', 'MALY')
    into ELITA values ('SZYBKA', 'UCHO')
    into ELITA values ('RAFA', 'MALA')
    into ELITA values ('KURKA', null)
select *
from DUAL;

insert all
    into KONTA VALUES (1, 'TYGRYS', '2019-12-12', null)
    into KONTA VALUES (2, 'PLACEK', '2019-12-17', '2019-12-20')
    into KONTA VALUES (3, 'TYGRYS', '2019-12-17', null)
    into KONTA VALUES (4, 'TYGRYS', '2019-12-24', '2019-12-25')
    into KONTA VALUES (5, 'KURKA', '2019-12-24', null)
    into KONTA VALUES (6, 'RAFA', '2019-12-27', '2019-12-29')
    into KONTA VALUES (7, 'SZYBKA', '2019-12-28', '2019-12-30')
    into KONTA VALUES (8, 'ZOMBI', '2019-12-30', '2019-12-31')
    into KONTA VALUES (9, 'KURKA', '2019-11-11', null)
select * from
dual;

commit;
