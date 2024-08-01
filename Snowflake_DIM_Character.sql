DROP TABLE IF EXISTS DIM_CHARACTER;

CREATE TABLE IF NOT EXISTS DIM_CHARACTER (
    ID_CHARACTER INT,
    NAME VARCHAR, 
    FIRST_NAME VARCHAR,
    LAST_NAME VARCHAR,
    NICK_NAME VARCHAR,
    GENDER VARCHAR,
    HOUSE_NAME VARCHAR,
    ISGOOD BOOLEAN,
    ISMAIN BOOLEAN,
    PATRONUS VARCHAR,
    INSERTED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

INSERT INTO DIM_CHARACTER (
    ID_CHARACTER, NAME, FIRST_NAME, LAST_NAME, NICK_NAME, GENDER, HOUSE_NAME, ISGOOD, ISMAIN, PATRONUS
)
VALUES (
    -1, 'unknown', 'unknown', 'unknown', 'unknown', 'unknown', 'unknown', 'False', 'False', 'unknown'
);

INSERT INTO DIM_CHARACTER (
SELECT 
    "Character_ID" AS ID_CHARACTER,
    "Character_Name" AS NAME,
    SPLIT("Character_Name", ' ')[0] AS FIRST_NAME,
    NULLIF(TRIM(SUBSTRING("Character_Name", POSITION(' ' IN "Character_Name") + 1)), '') AS LAST_NAME, 
    NULL AS NICK_NAME, 
    "Gender" AS GENDER,
    "House" AS HOUSE_NAME,
    NULL AS ISGOOD,
    NULL AS ISMAIN,
    "Patronus" AS PATRONUS,
    CURRENT_TIMESTAMP AS INSERTED_AT,
    CURRENT_TIMESTAMP AS UPDATED_AT
FROM
    "character");

--house id update
UPDATE DIM_CHARACTER
SET HOUSE_NAME = -1
WHERE HOUSE_NAME IS NULL OR TRIM(HOUSE_NAME) = '';

UPDATE DIM_CHARACTER AS ch
SET HOUSE_NAME = h.ID_HOUSE
FROM DIM_HOUSE AS h
WHERE ch.HOUSE_NAME = h.HOUSE_NAME;

ALTER TABLE DIM_CHARACTER
RENAME COLUMN HOUSE_NAME TO ID_HOUSE;

--nicknames
UPDATE DIM_CHARACTER
SET NICK_NAME = CASE
                  WHEN LAST_NAME IN ('Hagrid', 'Snape', 'McGonagall', 'Lupin', 'Moody', 'Umbridge', 'Lockhart', 'Filch', 'Trelawney', 'Quirrell', 'Ollivander', 'Pettigrew', 'Karkaroff', 'Maxime', 'Fudge', 'Crouch Sr.', 'Greyback', 'Burbage', 'Slughorne', 'Flitwick', 'Yaxley', 'Bones', 'Wood', 'Crabbe', 'Flint', 'Grindelwald', 'Goyle', 'Krum', 'Gregorovitch') OR NAME = 'Albus Dumbledore' THEN LAST_NAME
                  WHEN NAME = 'Serpent of Slitherin' THEN 'Basilisk'
                  WHEN NAME = 'Rolanda Hooch' THEN 'Madame Hooch'
                  WHEN NAME = 'Poppy Pomfrey' THEN 'Madame Pomfrey'
                  WHEN NAME = 'Arabella Figg' THEN 'Mrs. Figg'
                  WHEN NAME = 'Pomona Sprout' THEN 'Madame Sprout'
                  WHEN NAME = 'Mrs. Cole' THEN NAME
                  WHEN NAME = 'Mrs. Granger' THEN NAME
                  WHEN NAME = 'Mr. Granger' THEN NAME
                  WHEN NAME = 'Tom Riddle' THEN NAME
                  WHEN NAME = 'Nearly Headless Nick' THEN NAME
                  WHEN NAME = 'Helena Ravenclaw' THEN NAME
                  WHEN NAME = 'Bloody Baron' THEN NAME
                  ELSE FIRST_NAME
               END;

--is character good

UPDATE DIM_CHARACTER
SET ISGOOD = CASE
                  WHEN NICK_NAME IN ('Snape', 'Umbridge', 'Filch', 'Quirrell', 'Pettigrew', 'Voldemort', 'Fudge', 'Bellatrix', 'Barty', 'Riddle', 'Scabior', 'Crabbe', 'Goyle', 'Basilisk', 'Karkaroff', 'Rita', 'Mundungus', 'Parkinson', 'Greyback', 'Griphook', 'Aragog', 'Pius', 'Greyback', 'Tom Riddle', 'Yaxley', 'Flint', 'Pansy', 'Blaise', 'Alecto', 'Death')
                  OR
                  LAST_NAME IN ('Malfoy', 'Dursley') 
                  THEN FALSE
                  ELSE TRUE
               END

--is character main

UPDATE DIM_CHARACTER               
SET ISMAIN = CASE
                  WHEN NICK_NAME IN ('Harry', 'Ron', 'Hermione', 'Dumbledore', 'Hagrid', 'Snape', 'McGonagall', 'Voldemort', 'Neville', 'Draco', 'Sirius', 'Luna', 'Dobby', 'Ginny', 'Molly', 'Arthur', 'Lupin', 'Moody','Bellatrix','Lucius')
                  THEN TRUE
                  ELSE FALSE
               END

--empty patronus

UPDATE DIM_CHARACTER
SET PATRONUS = CASE
                 WHEN PATRONUS IS NULL OR PATRONUS = '' THEN 'unknown'
                 ELSE PATRONUS
              END;

--gender update

UPDATE DIM_CHARACTER
SET GENDER = CASE
                 WHEN GENDER = 'unknown' THEN 'Unknown'
                 WHEN GENDER = 'Human' THEN 'Male'
                 WHEN NICK_NAME = 'Goblin' THEN 'Male'
                 WHEN NAME = 'Station guard' THEN 'Male'
                 WHEN NICK_NAME = 'Girl' THEN 'Female'
                 WHEN NICK_NAME = 'Boy' THEN 'Male'
                 WHEN NICK_NAME = 'Man' THEN 'Male'
                 WHEN NICK_NAME = 'Woman' THEN 'Female'
                 WHEN LAST_NAME = 'Fat Lady' THEN 'Female'
                 WHEN NICK_NAME = 'Snatcher' THEN 'Male'
                 WHEN NICK_NAME = 'Wizard' THEN 'Male'
                 WHEN NAME = 'Trolley witch' THEN 'Female'
                 WHEN NICK_NAME = 'Waitress' THEN 'Female'
                 WHEN NAME = 'Old man' THEN 'Male'
                 WHEN NICK_NAME = 'Witch' THEN 'Female'
                 WHEN NICK_NAME = 'Centaur' THEN 'Male'
                 WHEN NAME = 'Man in a painting' THEN 'Male'
                 WHEN NICK_NAME = 'Waiter' THEN 'Male'
                 WHEN NAME = 'Boy 2' THEN 'Male'
                 WHEN GENDER IS NULL OR GENDER = '' THEN 'Unknown'
                 ELSE GENDER
              END;