drop table KOCURY_R force;
drop table WROGOWIE_KOCUROW_R;
drop table ELITA_R;
drop table PLEBS_R;
drop table KONTA_R;

create table KOCURY_R of KOCURY_O(
    constraint rko_pk primary key (pseudo),
    constraint rko_im_nn check (imie is not null),
    constraint rko_pl_val check (plec in ('M', 'D')),
    constraint rko_sz_fk szef scope is KOCURY_R,
    w_stadku_od default(sysdate)
);

create table WROGOWIE_KOCUROW_R of WROGOWIE_KOCUROW_O(
    constraint rwr_pk primary key (nr_incydentu),
    constraint rwr_da_nn check (data_incydentu is not null),
    constraint rwr_kot_fk kot scope is KOCURY_R
);


create table PLEBS_R of PLEBS_O(
    constraint rp_pk primary key (nr_czlonka_plebsu),
    constraint rp_kot_fk kot scope is KOCURY_R
);

create table ELITA_R of ELITA_O(
    constraint re_pk primary key (nr_czlonka_elity),
    constraint re_kot_fk kot scope is KOCURY_R,
    constraint re_slu_fk sluga scope is PLEBS_R
);

create table KONTA_R of KONTA_O(
    constraint rkn_pk primary key (nr_konta),
    constraint rkn_dw_nn check (data_wprowadzenia is not null),
    constraint rkn_dw_du_val check (data_wprowadzenia <= data_usuniecia),
    constraint rkn_wla_fk wlasciciel scope is ELITA_R
)