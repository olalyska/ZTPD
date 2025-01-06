-- 1. A. Utwórz tabelę o nazwie FIGURY z dwoma kolumnami:
-- ID - number(1) - klucz podstawowy
-- KSZTALT - MDSYS.SDO_GEOMETRY.

CREATE TABLE FIGURY
(
    ID NUMBER(1) PRIMARY KEY,
    KSZTALT MDSYS.SDO_GEOMETRY
);

-- B. Wstaw do tabeli FIGURY trzy kształty przedstawione na rysunku poniżej. Układ odniesienia pozostaw pusty – będzie to kartezjański układ odniesienia.

INSERT INTO FIGURY VALUES(
     1,
     MDSYS.SDO_GEOMETRY(
             2007,
             NULL,
             NULL,
             MDSYS.SDO_ELEM_INFO_ARRAY(1,1003,4),
             MDSYS.SDO_ORDINATE_ARRAY(5,7, 3,5, 5,3) )
 );
 
 INSERT INTO FIGURY VALUES(
 2,
 MDSYS.SDO_GEOMETRY(
         2007,
         NULL,
         NULL,
         MDSYS.SDO_ELEM_INFO_ARRAY(1,1003,3),
         MDSYS.SDO_ORDINATE_ARRAY(1,1, 5,5)
 ) );
 
 INSERT INTO figury VALUES(
 3,
 MDSYS.SDO_GEOMETRY(
         2002,
         NULL,
         NULL,
         SDO_ELEM_INFO_ARRAY(1,4,2, 1,2,1, 5,2,2),
         SDO_ORDINATE_ARRAY(3,2, 6,2, 7,3, 8,2, 7,1) ) );
COMMIT;

--C. Wstaw do tabeli FIGURY własny kształt o nieprawidłowej definicji (przykłady: otwarty wielokąt, wielokąt zdefiniowany w oparciu o punkty podane w nieprawidłowej kolejności, koło zdefiniowane przez punkty leżące na prostej, kształt, którego definicja elementów określona w SDO_ELEM_INFO jest niezgodna z typem geometrii SDO_GEOM itp.)
--

INSERT INTO FIGURY (ID, GEOMETRIA) 
VALUES (
    1, 
    SDO_GEOMETRY(
        2003, 
        8307,
        NULL,
        SDO_ELEM_INFO_ARRAY(1, 1003, 1),
        SDO_ORDINATE_ARRAY(
            10, 10,
            20, 10,
            20, 20,
            15, 15
        )
    )
);

--D. Zweryfikuj poprawność wstawionych geometrii za pomocą funkcji SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT (na slajdach znajdziesz przykład użycia tej funkcji)
--
Select id, SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(ksztalt, 0.005) from FIGURY;

--E. Usuń te wiersze z tabeli FIGURY, które zawierają nieprawidłowe kształty.

Delete from FIGURY where ID=4;
--
--F. Zatwierdź transakcję. (Tabela FIGURY będzie używana w kolejnych ćwiczeniach.)
COMMIT; 
