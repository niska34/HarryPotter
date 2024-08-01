-- přepočet screen time na jednotný formát (min)

DROP TABLE IF EXISTS SCREEN_TIME_MIN;

CREATE TABLE IF NOT EXISTS SCREEN_TIME_MIN AS
(
    SELECT 
        "Movie" AS MOVIE_NAME,
        "Character" AS CHARACTER_NAME,
        CASE 
            WHEN LENGTH("Screen_Time") - LENGTH(REPLACE("Screen_Time", ':', '')) = 2 THEN
                COALESCE(NULLIF(SPLIT_PART("Screen_Time", ':', 1), '')::INT, 0) +           -- Minutes
                COALESCE(NULLIF(SPLIT_PART("Screen_Time", ':', 2), '')::INT, 0) / 60.0 +    -- Seconds to minutes
                COALESCE(NULLIF(SPLIT_PART("Screen_Time", ':', 3), '')::INT, 0) / 60000.0   -- Milliseconds to minutes
            WHEN LENGTH("Screen_Time") - LENGTH(REPLACE("Screen_Time", ':', '')) = 1 THEN
                COALESCE(NULLIF(SPLIT_PART("Screen_Time", ':', 1), '')::INT, 0) + 
                COALESCE(NULLIF(SPLIT_PART("Screen_Time", ':', 2), '')::INT, 0) / 60.0
            WHEN LENGTH("Screen_Time") - LENGTH(REPLACE("Screen_Time", ':', '')) = 0 THEN
                COALESCE(NULLIF("Screen_Time", '')::INT, 0)
            ELSE 0
        END AS SCREEN_TIME_MIN,
        CURRENT_TIMESTAMP AS INSERTED_AT,
        CURRENT_TIMESTAMP AS UPDATED_AT
    FROM
        SCREEN_TIME
);

-- přejmenování filmů a character na jednotný název (v LEFT JOIN)
-- výpočet zastoupení jednotlivých postav na obrazovce (%)

DROP TABLE IF EXISTS FACT_MOVIE_CHARACTER;

CREATE TABLE IF NOT EXISTS FACT_MOVIE_CHARACTER (
    ID_MOVIE INT,
    ID_CHARACTER INT,
    SCREEN_TIME_MIN FLOAT,
    SCREEN_TIME_PERCENTAGE FLOAT,
    INSERTED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
    );

INSERT INTO FACT_MOVIE_CHARACTER (ID_MOVIE, ID_CHARACTER, SCREEN_TIME_MIN, SCREEN_TIME_PERCENTAGE)
SELECT
    COALESCE(m.ID_MOVIE,-1),
    COALESCE(
        CASE
        WHEN c.ID_CHARACTER IS NULL AND TRIM(s.CHARACTER_NAME) = 'Mr. Ollivander' THEN 43
        WHEN c.ID_CHARACTER IS NULL AND TRIM(s.CHARACTER_NAME) = 'The Sorting Hat' THEN 128
        WHEN c.ID_CHARACTER IS NULL AND TRIM(s.CHARACTER_NAME) = 'Madame Hooch' THEN 50 
        WHEN c.ID_CHARACTER IS NULL AND TRIM(s.CHARACTER_NAME) = 'Sir Nicholas "Nearly-Headless Nick"' THEN 47
        WHEN c.ID_CHARACTER IS NULL AND TRIM(s.CHARACTER_NAME) = 'Fat Lady' THEN 141
        WHEN c.ID_CHARACTER IS NULL AND TRIM(s.CHARACTER_NAME) = 'Colin Creevy' THEN 106
        WHEN c.ID_CHARACTER IS NULL AND TRIM(s.CHARACTER_NAME) = 'Madame Poppy Pomfrey' THEN 85
        WHEN c.ID_CHARACTER IS NULL AND TRIM(s.CHARACTER_NAME) = 'Professor Sybil Trelawney' THEN 38
        WHEN c.ID_CHARACTER IS NULL AND TRIM(s.CHARACTER_NAME) = 'Stan Shunpike' THEN 58
        WHEN c.ID_CHARACTER IS NULL AND TRIM(s.CHARACTER_NAME) = 'Madame Rosmerta' THEN 66
        WHEN c.ID_CHARACTER IS NULL AND TRIM(s.CHARACTER_NAME) = 'Bartemius Crouch Jr.' THEN 89
        WHEN c.ID_CHARACTER IS NULL AND TRIM(s.CHARACTER_NAME) = 'Bartemius Crouch Sr.' THEN 33
        WHEN c.ID_CHARACTER IS NULL AND TRIM(s.CHARACTER_NAME) = 'Madame Olympe Maxime' THEN 69
        WHEN c.ID_CHARACTER IS NULL AND TRIM(s.CHARACTER_NAME) = 'Alastor "Mad-Eye" Moody' THEN 13
        WHEN c.ID_CHARACTER IS NULL AND TRIM(s.CHARACTER_NAME) = 'Nigel' THEN 111
        WHEN c.ID_CHARACTER IS NULL AND TRIM(s.CHARACTER_NAME) = 'Yaxley' THEN 70
        WHEN c.ID_CHARACTER IS NULL AND TRIM(s.CHARACTER_NAME) = 'Auntie Muriel' THEN 77
        WHEN c.ID_CHARACTER IS NULL AND TRIM(s.CHARACTER_NAME) = 'Gregorovitch' THEN 125
        WHEN c.ID_CHARACTER IS NULL AND TRIM(s.CHARACTER_NAME) = 'Albus Severus Potter' THEN 84
        WHEN c.ID_CHARACTER IS NULL AND TRIM(s.CHARACTER_NAME) = 'Scabbers / Peter Pettigrew' THEN 44
        WHEN c.ID_CHARACTER IS NULL AND TRIM(s.CHARACTER_NAME) = 'Tom Riddle / Voldemort' THEN 24
        ELSE c.ID_CHARACTER
    END, -1) AS ID_CHARACTER,
    s.SCREEN_TIME_MIN,
    ROUND((s.SCREEN_TIME_MIN / m.RUNTIME) * 100, 2) AS SCREEN_TIME_PERCENTAGE
FROM
    SCREEN_TIME_MIN AS s
    LEFT JOIN 
    DIM_CHARACTER AS c 
    ON c.NAME = CASE
                WHEN TRIM(s.CHARACTER_NAME) LIKE 'Professor%' THEN REPLACE(TRIM(s.CHARACTER_NAME), 'Professor ', '')
                ELSE TRIM(s.CHARACTER_NAME)
                END
    LEFT JOIN
    DIM_MOVIE AS m
    ON m.NAME = CASE
                WHEN s.MOVIE_NAME = 'Harry Potter and the Sorcerer''s Stone' THEN 'Harry Potter and the Philosopher''s Stone'
                WHEN s.MOVIE_NAME LIKE 'Harry Potter and the Deathly Hallows: Part%' THEN REPLACE(s.MOVIE_NAME, ':', '')
                ELSE s.MOVIE_NAME
                END