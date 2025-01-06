-- A. W ramach poprzednich ćwiczeń stworzona została tabela FIGURY. Zawiera ona kolumnę
-- przestrzenną – warstwę mapy przestrzennej
-- Zarejestruj stworzoną przez Ciebie warstwę w słowniku bazy danych (metadanych). Domyślna
-- tolerancja niechaj wynosi 0.01.

INSERT INTO USER_SDO_GEOM_METADATA VALUES (
    'FIGURY',
    'ksztalt',
    SDO_DIM_ARRAY(                 -- Wymiary
        SDO_DIM_ELEMENT('X', -10, 10, 0.01),
        SDO_DIM_ELEMENT('Y', -10, 10, 0.01)
    ),
    NULL
);

-- Dokonaj estymacji rozmiaru indeksu R-drzewo dla stworzonej przez Ciebie tabeli FIGURY.
-- Przyjmij następujące dane:
-- • docelowa liczba wierszy: 3 miliony,
-- • wielkość bloku bazy danych: 8192,
-- • parametr SDO_RTR_PCTFREE: 10,
-- • liczba wymiarów: 2,
-- • indeks nie będzie indeksem geodezyjnym (0).

SELECT SDO_TUNE.ESTIMATE_RTREE_INDEX_SIZE(3000000, 8192, 10, 2, 0) FROM DUAL;

-- C. Utwórz indeks R-drzewo na utworzonej przez Ciebie tabeli.

CREATE INDEX figury_rtree_idx ON figury(ksztalt) INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;

-- Sprawdź za pomocą operatora SDO_FILTER, które z utworzonych geometrii "mają coś
-- wspólnego" z punktem 3,3. Czy wynik odpowiada rzeczywistości? Czym to jest spowodowane?

SELECT id FROM figury WHERE SDO_FILTER(ksztalt, MDSYS.SDO_GEOMETRY(2001, NULL, MDSYS.SDO_POINT_TYPE(3,3,null), null, null)) = 'TRUE';

-- Sprawdź za pomocą operatora SDO_RELATE, które z utworzonych geometrii "mają coś
-- wspólnego" (nie są rozłączne) z punktem 3,3. Czy teraz wynik odpowiada rzeczywistości?

SELECT id FROM figury WHERE SDO_RELATE(KSZTALT, MDSYS.SDO_GEOMETRY(2001, NULL, MDSYS.SDO_POINT_TYPE(3,3,null), null, null), 'mask=anyinteract') = 'TRUE';


-- ćwiczenie 2
-- A. Wykorzystując operator SDO_NN i funkcję SDO_NN_DISTANCE znajdź dziewięć najbliższych
-- miast wraz z odległościami od Warszawy.

SELECT ID FROM MAJOR_CITIES where city_name='Warsaw';
-- ID = 35

SELECT CITY_NAME MIASTO, ROUND(SDO_NN_DISTANCE(1),7) ODLEGLOSC
FROM MAJOR_CITIES
WHERE SDO_NN(GEOM, (SELECT GEOM FROM MAJOR_CITIES WHERE city_name='Warsaw'), 'sdo_num_res=10 unit=km',1) = 'TRUE'
  AND ID <> (SELECT ID FROM MAJOR_CITIES where city_name='Warsaw')
ORDER BY ODLEGLOSC;

-- Sprawdź, które miasta znajdują się w odległości 100 km od Warszawy. Skorzystaj z operatora
-- SDO_WITHIN_DISTANCE. Wynik porównaj z wynikiem z zadania powyżej.

SELECT CITY_NAME MIASTO FROM MAJOR_CITIES
WHERE SDO_WITHIN_DISTANCE(GEOM, (SELECT GEOM FROM MAJOR_CITIES WHERE city_name='Warsaw'), 'distance=100 unit=km') = 'TRUE'
  AND ID <> (SELECT ID FROM MAJOR_CITIES where city_name='Warsaw');

-- wyniki niezgodne

-- C. Wyświetl miasta ze Słowacji. Skorzystaj z operatora SDO_RELATE.

SELECT CITY_NAME MIASTO, CNTRY_NAME KRAJ
FROM MAJOR_CITIES
WHERE SDO_RELATE(GEOM, (SELECT GEOM FROM COUNTRY_BOUNDARIES WHERE CNTRY_NAME='Slovakia'), 'mask=inside+contains') = 'TRUE';

-- Znajdź odległości pomiędzy Polską a krajami, które z nią nie graniczą. Wykorzystaj operator
-- SDO_RELATE oraz funkcję SDO_DISTANCE.

SELECT A.CNTRY_NAME AS PANSTWO, SDO_GEOM.SDO_DISTANCE(A.GEOM, B.GEOM, 1, 'unit=km') AS ODLEGLOSC
FROM COUNTRY_BOUNDARIES A ,COUNTRY_BOUNDARIES B
WHERE SDO_RELATE(A.GEOM, B.GEOM, 'mask=antyinteract') <> 'TRUE' AND B.CNTRY_NAME='Poland'
  AND SDO_GEOM.SDO_DISTANCE(A.GEOM, B.GEOM, 1, 'unit=km')>0;

-- ćwiczenie 3
-- A. Znajdź sąsiadów Polski oraz odczytaj długość granicy z każdym z nich.
SELECT A.CNTRY_NAME AS PANSTWO, SDO_GEOM.SDO_LENGTH(SDO_GEOM.SDO_INTERSECTION(A.GEOM, B.GEOM, 1), 1, 'unit=km') AS DLUGOSC_GRANICY
FROM COUNTRY_BOUNDARIES A ,COUNTRY_BOUNDARIES B
WHERE SDO_RELATE(A.GEOM, B.GEOM, 'mask=touch') = 'TRUE' AND B.CNTRY_NAME='Poland'
ORDER BY DLUGOSC_GRANICY desc;

-- B. Podaj nazwę Państwa, którego fragment przechowywany w bazie danych jest największy.

select A.CNTRY_NAME, ROUND(SDO_GEOM.sdo_area(A.GEOM, 1, 'unit=SQ_KM')) POWIERZCHNIA
from COUNTRY_BOUNDARIES A
order by 2 desc
fetch first 1 row only;

-- Wyznacz pole minimalnego ograniczającego prostokąta (MBR), w którym znajdują się Warszawa
-- i Łódź.

SELECT SDO_GEOM.SDO_AREA(SDO_GEOM.SDO_MBR(SDO_GEOM.SDO_UNION(A.GEOM, B.GEOM, 0.01)),1, 'unit=SQ_KM') SQ_KM
FROM MAJOR_CITIES A, MAJOR_CITIES B
WHERE A.CITY_NAME = 'Warsaw' AND B.CITY_NAME='Lodz';

-- Jakiego typu geometria będzie sumą geometryczną państwa polskiego i Pragi. Wykorzystaj
-- odpowiednią metodę typu SDO_GEOMETRY.

select SDO_GEOM.SDO_UNION(A.GEOM, B.GEOM, 1).SDO_GTYPE as GTYPE
from COUNTRY_BOUNDARIES A, MAJOR_CITIES B
where A.CNTRY_NAME = 'Poland'
and B.CITY_NAME = 'Prague';

-- 2004

-- E. Znajdź nazwę miasta, które znajduje się najbliżej centrum ciężkości swojego państwa.

select * from (select B.CNTRY_Name, SDO_GEOM.SDO_DISTANCE(SDO_GEOM.SDO_CENTROID(B.GEOM,1), c.GEOM) odleglosc, c.city_name
from COUNTRY_BOUNDARIES B join MAJOR_CITIES c
on (B.CNTRY_NAME = C.CNTRY_NAME))
order by odleglosc
fetch first 1 row only;

-- Podaj długość tych z rzek, które przepływają przez terytorium Polski. Ogranicz swoje obliczenia
-- tylko do tych fragmentów, które leżą na terytorium Polski.

select B.CNTRY_NAME, R.name,
sum(SDO_GEOM.SDO_LENGTH(SDO_GEOM.SDO_INTERSECTION(B.GEOM, R.GEOM, 1), 1, 'unit=km'))
from COUNTRY_BOUNDARIES B, RIVERS R
where B.CNTRY_NAME = 'Poland'
and SDO_GEOM.RELATE(B.GEOM, 'DETERMINE', R.GEOM, 1) != 'DISJOINT'
group by B.CNTRY_NAME, R.name;
