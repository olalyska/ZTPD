-- 1. Utwórz w swoim schemacie kopię tabeli CYTATY ze schematu ZTPD.

CREATE TABLE CYTATY AS SELECT * FROM ZTPD.CYTATY;

-- 2. Znajdź w tabeli CYTATY za pomocą standardowego operatora LIKE cytaty, które
-- zawierają zarówno słowo ‘optymista’ jak i ‘pesymista’ ignorując wielkość liter.

SELECT * FROM CYTATY WHERE UPPER(TEKST) LIKE '%OPTYMISTA%' OR UPPER(TEKST) LIKE '%PESYMISTA%';

-- 3. Utwórz indeks pełnotekstowy typu CONTEXT na kolumnie TEKST tabeli CYTATY przy
-- domyślnych preferencjach dla tworzonego indeksu.

CREATE INDEX TEXT_IDX ON CYTATY(TEKST) INDEXTYPE IS CTXSYS.CONTEXT;

-- 4. Znajdź w tabeli CYTATY za pomocą operatora CONTAINS cytaty, które zawierają
-- zarówno słowo ‘optymista’ jak i ‘pesymista’ (ignorując wielkość liter w tym i kolejnych
-- zapytaniach ze względu na charakterystykę indeksu)

SELECT * FROM CYTATY WHERE CONTAINS(TEKST, 'optymista AND pesymista') > 0;

-- 5. Znajdź w tabeli CYTATY za pomocą operatora CONTAINS cytaty, które zawierają słowo
-- ‘pesymista’, a nie zawierają słowa ‘optymista’

select * from CYTATY
where CONTAINS(TEKST, 'PESYMISTA NOT OPTYMISTA') > 0;

-- 6. Znajdź w tabeli CYTATY za pomocą operatora CONTAINS cytaty, które zawierają słowa
-- ‘optymista’ i ‘pesymista’ w odległości maksymalnie 3 słów.

SELECT * FROM CYTATY
WHERE CONTAINS(TEKST, 'pesymista and optymista') > 0
  AND CONTAINS(TEKST, 'pesymista and optymista') < 3;

-- 7. Znajdź w tabeli CYTATY za pomocą operatora CONTAINS cytaty, które zawierają słowa
-- ‘optymista’ i ‘pesymista’ w odległości maksymalnie 10 słów.

SELECT * FROM CYTATY
WHERE CONTAINS(TEKST, 'pesymista and optymista') > 0
  AND CONTAINS(TEKST, 'pesymista and optymista') < 10;

-- 8. Znajdź w tabeli CYTATY za pomocą operatora CONTAINS cytaty, które zawierają słowo
-- ‘życie’ i jego odmiany. Niestety Oracle nie wspiera stemmingu dla języka polskiego. Dlatego
-- zamiast frazy ‘$życie’ „poratujemy się” szukaniem frazy ‘życi%’.

SELECT * FROM CYTATY WHERE CONTAINS(TEKST, 'życi%') > 0;

-- 9. Zmodyfikuj poprzednie zapytanie, tak by dla każdego pasującego cytatu wyświetlony
-- został stopień dopasowania (SCORE).

SELECT AUTOR, TEKST, CONTAINS(TEKST, 'życi%') AS ST_DOP
FROM CYTATY
WHERE CONTAINS(TEKST, 'życi%') > 0;

-- 10. Zmodyfikuj poprzednie zapytanie, tak by wyświetlony został tylko najlepiej pasujący
-- cytat (w przypadku „remisu” może zostać wyświetlony dowolny z najlepiej pasujących
-- cytatów).

SELECT AUTOR, TEKST, CONTAINS(TEKST, 'życi%') AS ST_DOP
FROM CYTATY
WHERE CONTAINS(TEKST, 'życi%') > 0
ORDER BY CONTAINS(TEKST, 'życi%') DESC
FETCH FIRST 1 ROWS ONLY;

-- 11. Znajdź w tabeli CYTATY za pomocą operatora CONTAINS cytaty, które zawierają
-- słowo ‘problem’ za pomocą wzorca z „literówką”: ‘probelm’.

SELECT * FROM CYTATY WHERE CONTAINS(TEKST,'FUZZY(PROBELM)') > 0;

-- 12. Wstaw do tabeli CYTATY cytat Bertranda Russella 'To smutne, że głupcy są tacy pewni
-- siebie, a ludzie rozsądni tacy pełni wątpliwości.'. Zatwierdź transakcję.

INSERT INTO CYTATY VALUES (00,'Bertrand Russell', 'To smutne, że głupcy są tacy pewni siebie, a ludzie rozsądni tacy pełni wątpliwości.');
COMMIT;

-- 13. Znajdź w tabeli CYTATY za pomocą operatora CONTAINS cytaty, które zawierają
-- słowo ‘głupcy’. Jak wyjaśnisz wynik zapytania?

SELECT * FROM CYTATY WHERE CONTAINS(TEKST, 'głupcy') > 0;

Ten rekord nie był zaindeksowany więc nic się nie pojawiło

-- 14. Odszukaj w swoim schemacie tabelę, która zawiera zawartość indeksu odwróconego na
-- tabeli CYTATY. Wyświetl jej zawartość zwracając uwagę na to, czy słowo ‘głupcy’ znajduje
-- się wśród poindeksowanych słów.


select TOKEN_TEXT from DR$CYTATY_CTX_IDX$I
where TOKEN_TEXT = 'GŁUPCY';

-- 15. Indeks CONTEXT utworzony przy domyślnych preferencjach nie jest uaktualniany na
-- bieżąco. Możliwa jest synchronizacja na żądanie (poprzez procedurę) lub zgodnie z zadaną
-- polityką (poprzez preferencję ustawioną przy tworzeniu indeksu: po zatwierdzeniu transakcji,
-- z zadanym interwałem czasowym). Można też przebudować indeks usuwając go i tworząc
-- ponownie. Wadą tej opcji jest czas trwania operacji i czasowa niedostępność indeksu, ale z tej
-- opcji skorzystamy ze względu na jej prostotę.

drop index TEXT_IDX;
CREATE INDEX TEXT_IDX ON CYTATY(TEKST) INDEXTYPE IS CTXSYS.CONTEXT;

-- 16.
SELECT * FROM CYTATY WHERE CONTAINS(TEKST, 'głupcy') > 0;

-- 17.
drop index TEXT_IDX;

drop table CYTATY;

-- Zaawansowane indeksowanie i wyszukiwanie
-- 1. Utwórz w swoim schemacie kopię tabeli QUOTES ze schematu ZTPD.

CREATE TABLE QUOTES AS SELECT * FROM ZTPD.QUOTES;

-- 2. Utwórz indeks pełnotekstowy typu CONTEXT na kolumnie TEXT tabeli QUOTES przy
-- domyślnych preferencjach.

CREATE INDEX QUOTES_IDX ON QUOTES(TEXT) INDEXTYPE IS CTXSYS.CONTEXT;

-- 3. Tabela QUOTES zawiera teksty w języku angielskim, dla którego Oracle Text obsługuje
-- stemming. Sprawdź działanie operatora CONTAINS dla wzorców:
-- - ‘work’
-- - ‘$work’
-- - ‘working’
-- - ‘$working’

SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'work') > 0;

SELECT * FROM QUOTES WHERE CONTAINS(TEXT, '$work') > 0;

SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'working') > 0;

SELECT * FROM QUOTES WHERE CONTAINS(TEXT, '$working') > 0;

-- 4. Spróbuj znaleźć w tabeli QUOTES wszystkie cytaty, które zawierają słowo ‘it’. Czy
-- system zwrócił jakieś wyniki? Dlaczego?

select * from QUOTES where CONTAINS(TEXT, 'it') > 0;

-- 5. Sprawdź jakie stop listy dostępne są w systemie. Odpytaj w tym celu perspektywę
-- słownikową CTX_STOPLISTS. Jak myślisz, którą system wykorzystywał przy
-- dotychczasowych zapytaniach?

SELECT * FROM CTX_STOPLISTS;

-- 6. Sprawdź jakie słowa znajdują się na domyślnej stop liście. Odpytaj w tym celu
-- perspektywę słownikową CTX_STOPWORDS.

SELECT * FROM CTX_STOPWORDS;

-- 7. Usuń indeks pełnotekstowy na tabeli QUOTES. Utwórz go ponownie wskazując, że przy
-- indeksowaniu ma być użyta dostępna w systemie pusta stop lista.

DROP INDEX QUOTES_IDX;

CREATE INDEX QUOTES_IDX ON QUOTES(TEXT) INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS('STOPLIST CTXSYS.EMPTY_STOPLIST');

-- 8. Ponów zapytanie o wszystkie cytaty, które zawierają słowo ‘it’. Czy tym razem system
-- zwrócił jakieś wyniki?

select AUTHOR, TEXT from QUOTES where CONTAINS(TEXT, 'it') > 0;

-- 9. Znajdź w tabeli QUOTES cytaty zawierające słowa ‘fool’ i ‘humans’.

SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'fool AND humans') > 0;

-- 10. Znajdź w tabeli QUOTES cytaty zawierające słowa ‘fool’ i ‘computer’.

SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'fool AND computer', 1) > 0;

-- 11. Spróbuj znaleźć w tabeli QUOTES cytaty zawierające słowa ‘fool’ i ‘humans’ w jednym
-- zdaniu. Zinterpretuj komunikat o błędzie.

SELECT * FROM QUOTES
WHERE CONTAINS(TEXT, '(fool and humans) WITHIN SENTENCE') > 0;

-- ORA-29902: błąd podczas wykonywania podprogramu ODCIIndexStart()
-- ORA-20000: Oracle Text error:
-- DRG-10837: sekcja SENTENCE nie istnieje

-- 12. Usuń indeks pełnotekstowy na tabeli QUOTES.

DROP INDEX QUOTES_IDX;

-- 13. Utwórz grupę sekcji bazującą na NULL_SECTION_GROUP, zawierającą dodatkowo
-- obsługę zdań i akapitów jako sekcji.

begin
    ctx_ddl.create_section_group('nullgroup', 'NULL_SECTION_GROUP');
    ctx_ddl.add_special_section('nullgroup', 'SENTENCE');
    ctx_ddl.add_special_section('nullgroup', 'PARAGRAPH');
end;

-- 14. Utwórz ponownie indeks pełnotekstowy na tabeli QUOTES wskazując utworzoną grupę
-- sekcji obsługującą zdania i akapity.

CREATE INDEX QUOTES_IDX ON QUOTES(TEXT) INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS('SECTION GROUP nullgroup');

-- 15. Sprawdź czy teraz działają wzorce odwołujące się do zdań szukając najpierw cytatów
-- zawierających w tym samym zdaniu słowa ‘fool’ i ‘humans’, a następnie ‘fool’ i ‘computer’.

SELECT * FROM QUOTES WHERE CONTAINS(TEXT, '(fool AND humans) within SENTENCE') > 0;

SELECT * FROM QUOTES WHERE CONTAINS(TEXT, '(fool AND computer) within SENTENCE') > 0;

-- 16. Znajdź w tabeli QUOTES wszystkie cytaty, które zawierają słowo ‘humans’. Czy system
-- zwrócił też cytaty zawierające ‘non-humans’? Dlaczego?

SELECT * FROM QUOTES 
WHERE CONTAINS(TEXT, 'humans') > 0;

-- 17. Usuń indeks pełnotekstowy na tabeli QUOTES. Utwórz preferencję dla leksera (używając
-- BASIC_LEXER), wskazującą, że myślnik ma być traktowany jako część indeksowanych
-- tokenów (składnik słów tak jak litery). Utwórz ponownie indeks pełnotekstowy na tabeli
-- QUOTES wskazując utworzoną preferencję dla leksera.

DROP INDEX QUOTES_IDX;

begin
    ctx_ddl.create_preference('lex_z_m','BASIC_LEXER');
    ctx_ddl.set_attribute('lex_z_m','printjoins', '-');
end;

CREATE INDEX QUOTES_IDX ON QUOTES(TEXT) INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS('LEXER lex_z_m');

-- 18. Ponów zapytanie o wszystkie cytaty, które zawierają słowo ‘humans’. Czy system tym
-- razem zwrócił też cytaty zawierające ‘non-humans’?

SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'humans') > 0;

-- 19. Znajdź w tabeli QUOTES wszystkie cytaty, które zawierają frazę ‘non-humans’.
-- Wskazówka: myślnik we wzorcu należy „escape’ować” („skorzystać z sekwencji ucieczki”).

SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'non\-humans') > 0;

-- 20. Usuń swoją kopię tabeli QUOTES i utworzoną preferencję.

DROP INDEX QUOTES_IDX;

DROP TABLE QUOTES;

BEGIN
    CTX_DDL.DROP_SECTION_GROUP('nullgroup');
    CTX_DDL.DROP_PREFERENCE('lex_z_m');
END;
