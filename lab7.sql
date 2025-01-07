-- Ćwiczenie 1
-- Linear Referencing System – podstawy.
-- A. Utwórz tabelę A6_LRS posiadającą jedną kolumnę GEOM typu SDO_GEOMETRY.

create table A6_LRS (
    GEOM SDO_GEOMETRY
);

-- B. Skopiuj do tabeli A6_LRS obiekt przestrzenny z tabeli STREETS_AND_RAILROADS
-- znajdujący się w odległości nie większej niż 10 km od Koszalina.

insert into A6_LRS (GEOM)
SELECT SDO_LRS.CONVERT_TO_LRS_GEOM(st.GEOM, 0, 276.681)
from STREETS_AND_RAILROADS STR, MAJOR_CITIES C
WHERE SDO_RELATE(STR.GEOM,
                 SDO_GEOM.SDO_BUFFER(c.GEOM, 10, 1, 'unit=km'),
                 'MASK=ANYINTERACT') = 'TRUE'
AND C.CITY_NAME = 'Koszalin';

-- C. Sprawdź długość oraz liczbę punktów, na który składa się skopiowany odcinek –
-- planowany przebieg autostrady A6.

SELECT SDO_GEOM.SDO_LENGTH(GEOM, 1, 'unit=km'), ST_LINESTRING(GEOM).ST_NUMPOINTS() FROM A6_LRS;

-- D. Dokonaj konwersji obiektu przestrzennego uzupełniając go o miary punktów
-- wchodzących w skład obiektu z przedziału od 0 do wartości będącej długością
-- skopiowanego odcinka.

UPDATE A6_LRS SET GEOM = SDO_LRS.CONVERT_TO_LRS_GEOM(GEOM, 0, 276.6813);

-- E. Zarejestruj metadane dotyczące tabeli A6_LRS.

INSERT INTO USER_SDO_GEOM_METADATA
SELECT 'A6_LRS', 'GEOM', ASGM.DIMINFO, ASGM.SRID
FROM ALL_SDO_GEOM_METADATA ASGM
WHERE ASGM.TABLE_NAME = 'A6_LRS';

-- F. Utwórz indeks przestrzenny na tabeli A6_LRS.

CREATE INDEX A6_LRS_IDX ON A6_LRS(GEOM) INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;

--  list index
SELECT * FROM USER_INDEXES WHERE TABLE_NAME = 'A6_LRS';

-- Ćwiczenie 2
-- Linear Referencing System – przetwarzanie.
-- A. Sprawdź czy miara o wartości 500 jest prawidłową miarą dla utworzonego
-- segmentu LRS.

SELECT SDO_LRS.VALID_MEASURE(GEOM, 500) FROM A6_LRS;

-- B. Sprawdź jaki punkt jest punktem kończącym segment LRS.

SELECT SDO_LRS.GEOM_SEGMENT_END_PT(GEOM) FROM A6_LRS;

-- C. Wyznacz punkt, w którym kończy się 150-ty kilometr autostrady A6.

SELECT SDO_LRS.LOCATE_PT(GEOM, 150, 0) FROM A6_LRS;

-- D. Wyznacz ciąg linii będący fragmentem autostrady A6 od jej 120 kilometra do 160
-- kilometra.

SELECT SDO_LRS.CLIP_GEOM_SEGMENT(GEOM, 120, 160, 0) FROM A6_LRS;

-- E. Zakładając, że punkty definiujące autostradę A6 są jej wjazdami znajdź
-- współrzędne wjazdu położonego najbliżej od Słupska, przy założeniu, że kierowca
-- udaje się do Szczecina.

SELECT SDO_LRS.GET_NEXT_SHAPE_PT(A6.GEOM, SDO_LRS.PROJECT_PT(A6.GEOM, C.GEOM)) WJAZD_NA_A6
FROM A6_LRS A6, MAJOR_CITIES C WHERE C.CITY_NAME = 'Slupsk';

-- F. Gdyby chcieć zbudować gazociąg biegnący po lewej stronie autostrady A6
-- w odległości 50 metrów od niej, ciągnący się od 50-tego do 200-nego jej
-- kilometra, to jaki byłby koszt jego budowy? Przyjmij, że koszt budowy gazociągu
-- to 1mln/km.

SELECT SDO_LRS.GEOM_SEGMENT_LENGTH(SDO_LRS.CLIP_GEOM_SEGMENT(A6.GEOM, 50, 200, 0)) / 1000 KOSZT_BUDOWY_W_MLN_ZL
FROM A6_LRS A6;
