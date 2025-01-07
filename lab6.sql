-- Ćwiczenie 1
-- Standard SQL/MM Part: 3 Spatial.

-- A. Wykorzystując klauzulę CONNECT BY wyświetl hierarchię typu ST_GEOMETRY.
select lpad('-',2*(level-1),'|-') || t.owner||'.'||t.type_name||' (FINAL:'||t.final||
       ', INSTANTIABLE:'||t.instantiable||', ATTRIBUTES:'||t.attributes||', METHODS:'||t.methods||')'
from all_types t
    start with t.type_name = 'ST_GEOMETRY'
connect by prior t.type_name = t.supertype_name
       and prior t.owner = t.owner;

-- B. Wyświetl nazwy metod typu ST_POLYGON.
select distinct m.method_name
from all_type_methods m
where m.type_name like 'ST_POLYGON'
  and m.owner = 'MDSYS'
order by 1;

-- C. Utwórz tabelę MYST_MAJOR_CITIES o następujących kolumnach:
-- • FIPS_CNTRY VARCHAR2(2),
-- • CITY_NAME VARCHAR2(40),
-- • STGEOM ST_POINT.

create table MYST_MAJOR_CITIES (
    FIPS_CNTRY VARCHAR2(2),
    CITY_NAME VARCHAR2(40),
    STGEOM ST_POINT
);

-- D. Przepisz zawartość tabeli MAJOR_CITIES (znajduje się ona w schemacie ZTPD) do
-- stworzonej przez Ciebie tabeli MYST_MAJOR_CITIES dokonując odpowiedniej
-- konwersji typów.

insert into MYST_MAJOR_CITIES (FIPS_CNTRY, CITY_NAME, STGEOM)
select ztpd.FIPS_CNTRY, ztpd.CITY_NAME, TREAT(ST_POINT.FROM_SDO_GEOM(ztpd.GEOM) AS ST_POINT) STGEOM
from MAJOR_CITIES ztpd;

insert into MYST_MAJOR_CITIES
select FIPS_CNTRY, CITY_NAME, TREAT(ST_POINT.FROM_SDO_GEOM(GEOM) AS ST_POINT) STGEOM
from MAJOR_CITIES;

-- Ćwiczenie 2
-- Standard SQL/MM Part: 3 Spatial – definiowanie geometrii

-- A. Wstaw do tabeli MYST_MAJOR_CITIES informację dotyczącą Szczyrku. Załóż, że
-- centrum Szczyrku znajduje się w punkcie o współrzędnych 19.036107;
-- 49.718655. Wykorzystaj 3-argumentowy konstruktor ST_POINT (ostatnim
-- argumentem jest identyfikator układu współrzędnych).


insert into MYST_MAJOR_CITIES
values('PL', 'Szczyrk', NEW ST_POINT(19.036107, 49.718655, null))


-- Ćwiczenie 3
-- Standard SQL/MM Part: 3 Spatial – pobieranie własności i miar

-- A. Utwórz tabelę MYST_COUNTRY_BOUNDARIES z następującymi atrybutami
-- • FIPS_CNTRY VARCHAR2(2),
-- • CNTRY_NAME VARCHAR2(40),
-- • STGEOM ST_MULTIPOLYGON.

create table MYST_COUNTRY_BOUNDARIES (
    FIPS_CNTRY VARCHAR2(2),
    CNTRY_NAME VARCHAR2(40),
    STGEOM ST_MULTIPOLYGON
);

-- B. Przepisz zawartość tabeli COUNTRY_BOUNDARIES do nowo utworzonej tabeli
-- dokonując odpowiednich konwersji.

insert into MYST_COUNTRY_BOUNDARIES (FIPS_CNTRY, CNTRY_NAME, STGEOM)
select A.FIPS_CNTRY, A.CNTRY_NAME, ST_MULTIPOLYGON(A.GEOM)
from COUNTRY_BOUNDARIES A;

-- C. Sprawdź jakiego typu i ile obiektów przestrzennych zostało umieszczonych
-- w tabeli MYST_COUNTRY_BOUNDARIES.

select A.STGEOM.ST_GEOMETRYTYPE(), count(*) from MYST_COUNTRY_BOUNDARIES A
group by A.STGEOM.ST_GEOMETRYTYPE();

-- D. Sprawdź czy wszystkie definicje przestrzenne uznawane są za proste.

select A.STGEOM.ST_ISSIMPLE()
from MYST_COUNTRY_BOUNDARIES A;

delete from MYST_MAJOR_CITIES where CITY_NAME = 'Szczyrk';

-- Ćwiczenie 4
-- Standard SQL/MM Part: 3 Spatial – przetwarzanie danych przestrzennych

-- Sprawdź ile miejscowości (MYST_MAJOR_CITIES) zawiera się w danym państwie
-- (MYST_COUNTRY_BOUNDARIES).

SELECT B.CNTRY_NAME, COUNT(*)
FROM MYST_COUNTRY_BOUNDARIES B,
     MYST_MAJOR_CITIES C
WHERE B.STGEOM.ST_CONTAINS(C.STGEOM) = 1
GROUP BY B.CNTRY_NAME;

-- B. Znajdź te państwa, które graniczą z Czechami.

SELECT B.CNTRY_NAME B_NAME, A.CNTRY_NAME A_NAME
FROM MYST_COUNTRY_BOUNDARIES A,
     MYST_COUNTRY_BOUNDARIES B
WHERE A.STGEOM.ST_TOUCHES(B.STGEOM) = 1
  AND A.CNTRY_NAME = 'Czech Republic';

-- C. Znajdź nazwy tych rzek, które przecinają granicę Czech – wykorzystaj tabelę
-- RIVERS (z racji korzystania z implementacji SQL/MM w Oracle konieczne jest
-- wykorzystanie także konstruktora typu ST_LINESTRING).

SELECT b.CNTRY_NAME, R.NAME
FROM MYST_COUNTRY_BOUNDARIES B, RIVERS R
WHERE ST_LINESTRING(R.GEOM).ST_INTERSECTS(B.STGEOM) = 1
AND B.CNTRY_NAME = 'Czech Republic';

--D.  Sprawdź, jaka powierzchnia jest Czech i Słowacji połączonych w jeden obiekt
-- przestrzenny.

SELECT TREAT(A.STGEOM.ST_UNION(B.STGEOM) as ST_POLYGON).ST_AREA() POW_CZECHOSLOWACJI
FROM MYST_COUNTRY_BOUNDARIES A, MYST_COUNTRY_BOUNDARIES B
WHERE A.CNTRY_NAME = 'Czech Republic'
AND B.CNTRY_NAME = 'Slovakia';

-- E. Sprawdź jakiego typu obiektem są Węgry z "wykrojonym" Balatonem –
-- wykorzystaj tabelę WATER_BODIES.

SELECT A.STGEOM.ST_DIFFERENCE(ST_GEOMETRY(W.GEOM)).ST_GEOMETRYTYPE()
FROM MYST_COUNTRY_BOUNDARIES A, WATER_BODIES W
WHERE A.CNTRY_NAME = 'Hungary'
AND W.NAME = 'Balaton';

-- Ćwiczenie 5
-- Standard SQL/MM Part: 3 Spatial – indeksowanie i przetwarzanie przy
-- użyciu operatorów SDO_NN i SDO_WITHIN_DISTANCE.

-- A. Wykorzystując operator SDO_WITHIN_DISTANCE znajdź liczbę miejscowości
-- oddalonych od terytorium Polski nie więcej niż 100 km. (wykorzystaj tabele
-- MYST_MAJOR_CITIES i MYST_COUNTRY_BOUNDARIES). Obejrzyj plan wykonania
-- zapytania. (Uwaga: We wcześniejszych wersjach Oracle użycie tych operatorów
-- nawet dla standardowych typów SQL/MM było możliwe tylko z pomocą indeksu
-- przestrzennego. Bez niego zapytanie kończyło się błędem „ORA-13226: interfejs
-- nie jest obsługiwany bez indeksu przestrzennego”.)

select B.CNTRY_NAME A_NAME, COUNT(*) from MYST_COUNTRY_BOUNDARIES B, MYST_MAJOR_CITIES C
WHERE SDO_WITHIN_DISTANCE(C.STGEOM, B.STGEOM,
                          'distance=100 unit=km') = 'TRUE'
  and B.CNTRY_NAME = 'Poland'
group by B.CNTRY_NAME;

-- B. Zarejestruj metadane dotyczące stworzonych przez Ciebie tabeli
-- MYST_MAJOR_CITIES i/lub MYST_COUNTRY_BOUNDARIES.

INSERT INTO USER_SDO_GEOM_METADATA
SELECT 'MYST_MAJOR_CITIES', 'STGEOM', T.DIMINFO, T.SRID
FROM ALL_SDO_GEOM_METADATA T
WHERE T.TABLE_NAME = 'MAJOR_CITIES';

-- c. Utwórz na tabelach MYST_MAJOR_CITIES i/lub MYST_COUNTRY_BOUNDARIES
-- indeks R-drzewo.

CREATE INDEX MYST_MAJOR_CITIES_IDX ON MYST_MAJOR_CITIES(STGEOM) INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;

-- D. Ponownie znajdź liczbę miejscowości oddalonych od terytorium Polski nie więcej
-- niż 100 km. Sprawdź jednocześnie, czy założone przez Ciebie indeksy są
-- wykorzystywane wyświetlając plan wykonania zapytania.
EXPLAIN PLAN FOR
select B.CNTRY_NAME A_NAME, COUNT(*) from MYST_COUNTRY_BOUNDARIES B, MYST_MAJOR_CITIES C
WHERE SDO_WITHIN_DISTANCE(C.STGEOM, B.STGEOM,
                          'distance=100 unit=km') = 'TRUE'
  and B.CNTRY_NAME = 'Poland'
group by B.CNTRY_NAME;


SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY);
