USE steamify;

-- Bucketing numeric values into n buckets
DROP FUNCTION IF EXISTS get_bucket_from_score;

DELIMITER //

CREATE FUNCTION get_bucket_from_score(score DECIMAL(10, 6), n INT) RETURNS INT
    DETERMINISTIC CONTAINS SQL
BEGIN
    DECLARE category_index_var INT;

    SET category_index_var = FLOOR(score / (100 / n));

    IF category_index_var >= n THEN SET category_index_var = n - 1; END IF;

    RETURN category_index_var + 1;
END //

DELIMITER ;

-- Converting from explicit to age
DROP FUNCTION IF EXISTS explicit_to_age;

DELIMITER //

CREATE FUNCTION explicit_to_age(explicit boolean) RETURNS int
    DETERMINISTIC CONTAINS SQL
BEGIN
    DECLARE age_var INT;

    SET age_var = IF(explicit, 18, 0);

    RETURN age_var;
END //

DELIMITER ;

-- Converting from age to explicit
DROP FUNCTION IF EXISTS age_to_explicit;

DELIMITER //

CREATE FUNCTION age_to_explicit(age int) RETURNS int
    DETERMINISTIC CONTAINS SQL
BEGIN
    DECLARE explicit_var boolean;

    SET explicit_var = age >= 18;

    RETURN explicit_var;
END //

DELIMITER ;

-- Converting from instrumentalness to genre
DROP FUNCTION IF EXISTS instrumentalness_to_genre;

DELIMITER //

CREATE FUNCTION instrumentalness_to_genre(instrumentalness DECIMAL(10, 6)) RETURNS VARCHAR(50)
    DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE genre_count_var INT;
    DECLARE bucket_var INT;
    DECLARE genre_var VARCHAR(50);

    SELECT COUNT(game_genre.game_genre_id) INTO genre_count_var FROM game_genre;

    SET bucket_var = get_bucket_from_score(instrumentalness, genre_count_var);

    SET genre_var = CASE bucket_var WHEN 1 THEN 'Utilities'
                                    WHEN 2 THEN 'Software Training'
                                    WHEN 3 THEN 'Web Publishing'
                                    WHEN 4 THEN 'Photo Editing'
                                    WHEN 5 THEN 'Video Production'
                                    WHEN 6 THEN 'Design & Illustration'
                                    WHEN 7 THEN 'Game Development'
                                    WHEN 8 THEN 'Animation & Modeling'
                                    WHEN 9 THEN 'Audio Production'
                                    WHEN 10 THEN 'Education'
                                    WHEN 11 THEN 'Simulation'
                                    WHEN 12 THEN 'Strategy'
                                    WHEN 13 THEN 'Sports'
                                    WHEN 14 THEN 'Racing'
                                    WHEN 15 THEN 'Casual'
                                    WHEN 16 THEN 'Free to Play'
                                    WHEN 17 THEN 'Early Access'
                                    WHEN 18 THEN 'Indie'
                                    WHEN 19 THEN 'Massively Multiplayer'
                                    WHEN 20 THEN 'Action'
                                    WHEN 21 THEN 'Adventure'
                                    WHEN 22 THEN 'RPG'
                                    WHEN 23 THEN 'Gore'
                                    WHEN 24 THEN 'Violent'
                                    WHEN 25 THEN 'Nudity'
                                    WHEN 26 THEN 'Sexual Content' END;

    RETURN genre_var;
END //

DELIMITER ;

-- Converting from genre to instrumentalness
DROP FUNCTION IF EXISTS genre_to_instrumentalness;

DELIMITER //

CREATE FUNCTION genre_to_bucket(genre VARCHAR(50)) RETURNS INT
    DETERMINISTIC CONTAINS SQL
BEGIN
    DECLARE bucket_var INT;

    SET bucket_var = CASE genre WHEN 'Utilities' THEN 1
                                WHEN 'Software Training' THEN 2
                                WHEN 'Web Publishing' THEN 3
                                WHEN 'Photo Editing' THEN 4
                                WHEN 'Video Production' THEN 5
                                WHEN 'Design & Illustration' THEN 6
                                WHEN 'Game Development' THEN 7
                                WHEN 'Animation & Modeling' THEN 8
                                WHEN 'Audio Production' THEN 9
                                WHEN 'Education' THEN 10
                                WHEN 'Simulation' THEN 11
                                WHEN 'Strategy' THEN 12
                                WHEN 'Sports' THEN 13
                                WHEN 'Racing' THEN 14
                                WHEN 'Casual' THEN 15
                                WHEN 'Free to Play' THEN 16
                                WHEN 'Early Access' THEN 17
                                WHEN 'Indie' THEN 18
                                WHEN 'Massively Multiplayer' THEN 19
                                WHEN 'Action' THEN 20
                                WHEN 'Adventure' THEN 21
                                WHEN 'RPG' THEN 22
                                WHEN 'Gore' THEN 23
                                WHEN 'Violent' THEN 24
                                WHEN 'Nudity' THEN 25
                                WHEN 'Sexual Content' THEN 26 END;

    RETURN bucket_var;
END //

DELIMITER ;

-- Testing 
SELECT age_to_explicit(18);
SELECT get_bucket_from_score(33, 4);
SELECT instrumentalness_to_genre(0);
SELECT genre_to_bucket('Sexual Content');