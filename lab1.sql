create type SAMOCHOD as object(
MARKA VARCHAR2(20),
MODEL VARCHAR2(20),
KILOMETRY NUMBER,
DATA_PRODUKCJI DATE,
CENA NUMBER(10,2));

create table SAMOCHODY of SAMOCHOD;

insert into SAMOCHODY values
(new SAMOCHOD('FIAT','BRAVA', 60000, '1999-11-30', 25000));

insert into SAMOCHODY values
(new SAMOCHOD('FORD', 'MONDEO', 80000, '1997-05-10', 45000));

insert into SAMOCHODY values
(new SAMOCHOD('MAZDA', '323', 12000, '2000-09-22', 52000));

create type Wlasciciel as object(
IMIE VARCHAR2(100),
NAZWISKO VARCHAR2(100),
AUTO Samochod)

create table wlasciciele of Wlasciciel;

insert into Wlasciciele values
(new Wlasciciel('JAN', 'KOWALSKI', New SAMOCHOD('FIAT', 'SEICENTO', 30000, '02-12-0010', 19500)));

insert into Wlasciciele values(new Wlasciciel('JAN', 'KOWALSKI', New SAMOCHOD('FIAT', 'SEICENTO', 30000, '0010-12-02', 19500)));

insert into Wlasciciele values(new Wlasciciel('ADAM', 'NOWAK', New SAMOCHOD('OPEL', 'ASTRA', 34000, '0009-06-01', 33700)));

alter TYPE SAMOCHOD replace as object (
    MARKA VARCHAR2(20),
MODEL_ VARCHAR2(20),
KILOMETRY NUMBER,
DATA_PRODUKCJI DATE,
CENA NUMBER(10,2),
    MEMBER FUNCTION wartosc RETURN NUMBER
);

create or replace type body SAMOCHOD as
    MEMBER FUNCTION wartosc RETURN NUMBER is
        BEGIN
            return cena*power(0.9,
                extract(year from current_date) - extract(year from DATA_PRODUKCJI));
        end wartosc;
end;

SELECT s.marka, s.cena, s.wartosc() FROM SAMOCHODY s;

-- Dodaj do typu SAMOCHOD metodę odwzorowującą, która pozwoli na porównywanie
-- samochodów na podstawie ich wieku i zużycia. Przyjmij, że 10000 km odpowiada
-- jednemu rokowi wieku samochodu.

Alter type samochod add map MEMBER FUNCTION porownaj RETURN NUMBER CASCADE INCLUDING TABLE DATA;

create or replace type body samochod as
    MEMBER FUNCTION wartosc RETURN NUMBER IS
    BEGIN
        RETURN cena * (1 - (months_between(sysdate, data_produkcji) / 12) * 0.1);
    END;
    map MEMBER FUNCTION porownaj RETURN NUMBER IS
    BEGIN
        RETURN (months_between(sysdate, data_produkcji) / 12) + (kilometry / 10000);
    END;
END;

SELECT * FROM SAMOCHODY s ORDER BY value(s);

-- Stwórz typ WLASCICIEL zawierający imię i nazwisko właściciela samochodu, dodaj
-- do typu SAMOCHOD referencje do właściciela. Wypełnij tabelę przykładowymi
-- danymi.

drop table wlasciciele;
create or replace type wlasciciel as object (
    imie varchar(20),
    nazwisko varchar(20)
);

create table wlasciciele of wlasciciel;

insert into wlasciciele values (new wlasciciel('Jan', 'Kowalski'));
insert into wlasciciele values (new wlasciciel('Adam', 'Nowak'));
insert into wlasciciele values (new wlasciciel('Piotr', 'Kowalczyk'));

drop table SAMOCHODY;
drop type SAMOCHOD;

create TYPE SAMOCHOD as object (
    nazwa varchar2(20),
    model varchar2(20),
    kilometry number,
    data_produkcji DATE,
    cena NUMBER(10,2),
    sWlasciciel REF WLASCICIEL,
    MEMBER FUNCTION wartosc RETURN NUMBER
);

alter type SAMOCHOD add map member function odwzoruj
return number cascade including table data;

create table SAMOCHODY of SAMOCHOD;

Alter table SAMOCHODY Add scope for ( SWLASCICIEL ) is WLASCICIELE;

insert into SAMOCHODY values ('FIAT', 'BRAVA', 60000, TO_DATE('30-11-1999', 'DD-MM-YYYY'), 25000, null);
insert into SAMOCHODY values ('FORD', 'MONDEO', 80000, TO_DATE('10-05-1997', 'DD-MM-YYYY'), 45000, null);
insert into SAMOCHODY values ('MAZDA', '323', 12000, TO_DATE('22-09-2000', 'DD-MM-YYYY'), 52000, null);

update SAMOCHODY s set s.SWLASCICIEL = (
    SELECT REF(w) from WLASCICIELE w
    where w.imie = 'Jan'
    );

--. Zbuduj kolekcję (tablicę o zmiennym rozmiarze) zawierającą informacje
--o przedmiotach (łańcuchy znaków). Wstaw do kolekcji przykładowe przedmioty,
--rozszerz kolekcję, wyświetl zawartość kolekcji, usuń elementy z końca kolekcji

DECLARE
 TYPE t_przedmioty IS VARRAY(10) OF VARCHAR2(20);
 moje_przedmioty t_przedmioty := t_przedmioty('');
BEGIN
 moje_przedmioty(1) := 'MATEMATYKA';
 moje_przedmioty.EXTEND(9);
 FOR i IN 2..10 LOOP
 moje_przedmioty(i) := 'PRZEDMIOT_' || i;
 END LOOP;
 FOR i IN moje_przedmioty.FIRST()..moje_przedmioty.LAST() LOOP
 DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
 END LOOP;
 moje_przedmioty.TRIM(2);
 FOR i IN moje_przedmioty.FIRST()..moje_przedmioty.LAST() LOOP
 DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
 END LOOP;
 DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
 DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
 moje_przedmioty.EXTEND();
 moje_przedmioty(9) := 9;
 DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
 DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
 moje_przedmioty.DELETE();
 DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
 DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
END;


--Zdefiniuj kolekcję (w oparciu o tablicę o zmiennym rozmiarze) zawierającą listę
--tytułów książek. Wykonaj na kolekcji kilka czynności (rozszerz, usuń jakiś element,
--wstaw nową książkę).


create type t_ksiazki as varray(10) of varchar2(50);
create table seria_ksiazek (tytul varchar2(100), ksiazki t_ksiazki);
insert into seria_ksiazek values ('Opowieści z Narnii', T_KSIAZKI('Lew, czarownica i stara szafa', 'Ksiaze Kaspian', 'Podroz wedrowca do switu'));
insert into seria_ksiazek values ('Mroczna Wieza', T_KSIAZKI('Roland', 'Powolanie trojki', 'Ziemie jalowe'));

select * from seria_ksiazek;

update seria_ksiazek set ksiazki = t_ksiazki('Lew, czarownica i stara szafa', 'Ksiaze Kaspian') where tytul = 'Opowieści z Narnii';

select * from seria_ksiazek;

--8. Zbuduj kolekcję (tablicę zagnieżdżoną) zawierającą informacje o wykładowcach.
--Przetestuj działanie kolekcji podobnie jak w przykładzie 6

DECLARE
 TYPE t_wykladowcy IS TABLE OF VARCHAR2(20);
 moi_wykladowcy t_wykladowcy := t_wykladowcy();
BEGIN
 moi_wykladowcy.EXTEND(2);
 moi_wykladowcy(1) := 'MORZY';
 moi_wykladowcy(2) := 'WOJCIECHOWSKI';
 moi_wykladowcy.EXTEND(8);
 FOR i IN 3..10 LOOP
 moi_wykladowcy(i) := 'WYKLADOWCA_' || i;
 END LOOP;
 FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
 DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
 END LOOP;
 moi_wykladowcy.TRIM(2);
 FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
 DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
 END LOOP;
 moi_wykladowcy.DELETE(5,7);
 DBMS_OUTPUT.PUT_LINE('Limit: ' || moi_wykladowcy.LIMIT());
 DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moi_wykladowcy.COUNT());
 FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
 IF moi_wykladowcy.EXISTS(i) THEN
 DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
 END IF;
 END LOOP;
 moi_wykladowcy(5) := 'ZAKRZEWICZ';
 moi_wykladowcy(6) := 'KROLIKOWSKI';
 moi_wykladowcy(7) := 'KOSZLAJDA';
 FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
 IF moi_wykladowcy.EXISTS(i) THEN
 DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
 END IF;
 END LOOP;
 DBMS_OUTPUT.PUT_LINE('Limit: ' || moi_wykladowcy.LIMIT());
 DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moi_wykladowcy.COUNT());
END;

-- Zbuduj kolekcję (w oparciu o tablicę zagnieżdżoną) zawierającą listę miesięcy. Wstaw
-- do kolekcji właściwe dane, usuń parę miesięcy, wyświetl zawartość kolekcji./
DECLARE
    TYPE t_miesiace IS TABLE OF VARCHAR2(20);
    miesiace t_miesiace := t_miesiace();
BEGIN
    miesiace.EXTEND(12);
    miesiace(1) := 'STYCZEN';
    miesiace(2) := 'LUTY';
    miesiace(3) := 'MARZEC';
    miesiace(4) := 'KWIECIEN';
    miesiace(5) := 'MAJ';
    miesiace(6) := 'CZERWIEC';
    miesiace(7) := 'LIPIEC';
    miesiace(8) := 'SIERPIEN';
    miesiace(9) := 'WRZESIEN';
    miesiace(10) := 'PAZDZIERNIK';
    miesiace(11) := 'LISTOPAD';
    miesiace(12) := 'GRUDZIEN';

    FOR i IN miesiace.FIRST()..miesiace.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(miesiace(i));
    END LOOP;

    miesiace.TRIM(2);

    FOR i IN miesiace.FIRST()..miesiace.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(miesiace(i));
    END LOOP;

    miesiace.DELETE(5,7);

    DBMS_OUTPUT.PUT_LINE('Limit: ' || miesiace.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || miesiace.COUNT());


    FOR I IN miesiace.FIRST()..miesiace.LAST() LOOP
        IF miesiace.EXISTS(I) THEN
            DBMS_OUTPUT.PUT_LINE(miesiace(I));
        END IF;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Limit: ' || miesiace.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || miesiace.COUNT());
end;


-- 9. Zbuduj kolekcję (w oparciu o tablicę zagnieżdżoną) zawierającą listę miesięcy. Wstaw
-- do kolekcji właściwe dane, usuń parę miesięcy, wyświetl zawartość kolekcji.

create type msc as object (
    nazwa varchar2(30),
    dlugosc numer);

create type t_miesiace as TABLE OF miesiace;

create table kwartaly (nazwa varchar2(30), miesiac t_miesiace)
nested table miesiac store as k_miesiace;

insert into kwartaly values ('Pierwszy', new t_miesiace(new miesiac('Styczen', 31), new miesiace('Luty', 28),  new miesiace('Marzec', 31)));

select * from kwartaly;

-- 10. Sprawdź działanie obu rodzajów kolekcji w przypadku atrybutów bazodanowych.
CREATE TYPE lista_rozdzialow AS VARRAY(10) OF VARCHAR2(50);
/
CREATE TYPE ksiazka AS OBJECT (
                                     tytul VARCHAR2(100),
                                     autor VARCHAR2(50),
                                     rozdzialy lista_rozdzialow );
/
CREATE TABLE ksiazki OF ksiazka;
INSERT INTO ksiazki VALUES
    ('Podstawy Programowania','Jan Kowalski',lista_rozdzialow('Wstęp','Zmienna','Pętle'));
INSERT INTO ksiazki VALUES
    ('Bazy Danych','Anna Nowak',lista_rozdzialow('Wstęp','Model Relacyjny','SQL'));
SELECT * FROM ksiazki;
SELECT k.rozdzialy FROM ksiazki k;
UPDATE KSIAZKI
SET rozdzialy = lista_rozdzialow('Wstęp','Model Relacyjny','SQL','Zaawansowane Zapytania')
WHERE tytul = 'Bazy Danych';
CREATE TYPE lista_sekcji AS TABLE OF VARCHAR2(50);
/
CREATE TYPE rozdzial AS OBJECT (
                                  numer NUMBER,
                                  sekcje lista_sekcji );
/
CREATE TABLE rozdzialy OF rozdzial
    NESTED TABLE sekcje STORE AS tab_sekcji;
INSERT INTO rozdzialy VALUES
    (rozdzial(1,lista_sekcji('Teoria','Przykłady','Ćwiczenia')));
INSERT INTO rozdzialy VALUES
    (rozdzial(2,lista_sekcji('Omówienie','Praktyka')));
SELECT r.numer, s.*
FROM rozdzialy r, TABLE(r.sekcje) s;
SELECT s.*
FROM rozdzialy r, TABLE ( r.sekcje ) s;
SELECT * FROM TABLE ( SELECT r.sekcje FROM rozdzialy r WHERE numer=1 );
INSERT INTO TABLE ( SELECT r.sekcje FROM rozdzialy r WHERE numer=2 )
VALUES ('Testowanie');
UPDATE TABLE ( SELECT r.sekcje FROM rozdzialy r WHERE numer=2 ) s
SET s.column_value = 'Implementacja'
WHERE s.column_value = 'Praktyka';
DELETE FROM TABLE ( SELECT r.sekcje FROM rozdzialy r WHERE numer=2 ) s
WHERE s.column_value = 'Omówienie';

-- Zbuduj tabelę ZAKUPY zawierającą atrybut zbiorowy KOSZYK_PRODUKTOW
-- w postaci tabeli zagnieżdżonej. Wstaw do tabeli przykładowe dane. Wyświetl
-- zawartość tabeli, usuń wszystkie transakcje zawierające wybrany produkt.

CREATE TYPE produkt AS OBJECT (
    nazwa VARCHAR(20),
    cena NUMBER(10,2)
);

CREATE TYPE KOSZYK_PRODUKTOW AS TABLE OF produkt;

CREATE TYPE zakup AS OBJECT (
    data DATE,
    koszyk_zakupow koszyk_produktow
);

CREATE TABLE zakupy OF zakup
    NESTED TABLE koszyk_zakupow STORE AS produkty;

INSERT INTO zakupy VALUES (
    TO_DATE('01-12-2024', 'dd-mm-yyyy'),
    koszyk_produktow(
        new produkt('Ciastka', 10),
        new produkt('Maslo', 20),
        new produkt('Czipsy', 10)
    )
);

INSERT INTO zakupy VALUES (
    TO_DATE('24-06-2024', 'dd-mm-yyyy'),
    koszyk_produktow(
        new produkt('Makaron', 6),
        new produkt('Czekolada', 6),
        new produkt('Ser', 12)
    )
);

Select * from zakupy;



-- 12. Zbuduj hierarchię reprezentującą instrumenty muzyczne.
CREATE TYPE instrument AS OBJECT (
 nazwa VARCHAR2(20),
 dzwiek VARCHAR2(20),
 MEMBER FUNCTION graj RETURN VARCHAR2 ) NOT FINAL;
CREATE TYPE BODY instrument AS
 MEMBER FUNCTION graj RETURN VARCHAR2 IS
 BEGIN
 RETURN dzwiek;
 END;
END;
/
CREATE TYPE instrument_dety UNDER instrument (
 material VARCHAR2(20),
 OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2,
 MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2 );
CREATE OR REPLACE TYPE BODY instrument_dety AS
 OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS
 BEGIN
 RETURN 'dmucham: '||dzwiek;
 END;
 MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2 IS
 BEGIN
 RETURN glosnosc||':'||dzwiek;
 END;
END;
/
CREATE TYPE instrument_klawiszowy UNDER instrument (
 producent VARCHAR2(20),
 OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 );
CREATE OR REPLACE TYPE BODY instrument_klawiszowy AS
 OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS
 BEGIN
 RETURN 'stukam w klawisze: '||dzwiek;
 END;
END;
/
DECLARE
 tamburyn instrument := instrument('tamburyn','brzdek-brzdek');
 trabka instrument_dety := instrument_dety('trabka','tra-ta-ta','metalowa');
 fortepian instrument_klawiszowy := instrument_klawiszowy('fortepian','pingping','steinway');
BEGIN
 dbms_output.put_line(tamburyn.graj);
 dbms_output.put_line(trabka.graj);
 dbms_output.put_line(trabka.graj('glosno'));
 dbms_output.put_line(fortepian.graj);
END;

-- 13. Zbuduj hierarchię zwierząt i przetestuj klasy abstrakcyjne.
CREATE TYPE istota AS OBJECT (
                                 nazwa VARCHAR2(20),
                                 NOT INSTANTIABLE MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR )
    NOT INSTANTIABLE NOT FINAL;
CREATE TYPE lew UNDER istota (
                                 liczba_nog NUMBER,
                                 OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR );
CREATE OR REPLACE TYPE BODY lew AS
    OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR IS
    BEGIN
        RETURN 'upolowana ofiara: '||ofiara;
    END;
END;
DECLARE
    KrolLew lew := lew('LEW',4);
    InnaIstota istota := istota('JAKIES ZWIERZE');
BEGIN
    DBMS_OUTPUT.PUT_LINE( KrolLew.poluj('antylopa') );
END;
-- 14. Zbadaj własność polimorfizmu na przykładzie hierarchii instrumentów.
DECLARE
    tamburyn instrument;
    cymbalki instrument;
    trabka instrument_dety;
    saksofon instrument_dety;
BEGIN
    tamburyn := instrument('tamburyn','brzdek-brzdek');
    cymbalki := instrument_dety('cymbalki','ding-ding','metalowe');
    trabka := instrument_dety('trabka','tra-ta-ta','metalowa');
    -- saksofon := instrument('saksofon','tra-taaaa');
    -- saksofon := TREAT( instrument('saksofon','tra-taaaa') AS instrument_dety);
END;

-- 15. Zbuduj tabelę zawierającą różne instrumenty. Zbadaj działanie funkcji wirtualnych.
CREATE TABLE instrumenty OF instrument;
INSERT INTO instrumenty VALUES ( instrument('tamburyn','brzdek-brzdek') );
INSERT INTO instrumenty VALUES ( instrument_dety('trabka','tra-ta-ta','metalowa')
                               );
INSERT INTO instrumenty VALUES ( instrument_klawiszowy('fortepian','pingping','steinway') );
SELECT i.nazwa, i.graj() FROM instrumenty i;
