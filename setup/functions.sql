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

CREATE FUNCTION age_to_explicit(age int) RETURNS boolean
    DETERMINISTIC CONTAINS SQL
BEGIN
    DECLARE explicit_var boolean;

    SET explicit_var = (age >= 18);

    RETURN explicit_var;
END //

DELIMITER ;


-- Testing
SELECT get_bucket_from_score(33, 4);
SELECT age_to_explicit(18);
SELECT explicit_to_age(false);
