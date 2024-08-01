DROP TABLE IF EXISTS DIM_SCENE;

CREATE TABLE IF NOT EXISTS DIM_SCENE (
    ID_SCENE INT,
    SCENE_NAME VARCHAR,
    ID_MOVIE INT,
    INSERTED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

INSERT INTO DIM_SCENE (
    ID_SCENE, SCENE_NAME, ID_MOVIE
) VALUES (
    -1, 'unknown', -1
);

INSERT INTO DIM_SCENE (
SELECT 
    "Chapter_ID" AS ID_SCENE,
    "Chapter_Name" AS SCENE_NAME,
    "Movie_ID" AS ID_MOVIE,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM
    "chapter")