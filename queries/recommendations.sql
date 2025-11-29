USE steamify;

DROP PROCEDURE IF EXISTS get_user_audio_buckets;

DELIMITER //

CREATE PROCEDURE get_user_audio_buckets(
    IN p_user_id INT,
    OUT p_dance INT,
    OUT p_energy INT,
    OUT p_acoustic INT,
    OUT p_instrumental INT
)
BEGIN
    SELECT
        get_bucket_from_score(AVG(s.danceability) , 3),
        get_bucket_from_score(AVG(s.energy) , 3),
        get_bucket_from_score(AVG(s.acousticness) , 3),
        get_bucket_from_score(AVG(s.instrumentalness) , 3)
    INTO p_dance, p_energy, p_acoustic, p_instrumental
    FROM listen l
    JOIN song s ON l.song_id = s.song_id
    WHERE l.user_id = p_user_id;
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS get_combined_audio_buckets;

DELIMITER //

CREATE PROCEDURE get_combined_audio_buckets(
    IN p_user1_id INT,
    IN p_user2_id INT,
    OUT p_dance INT,
    OUT p_energy INT,
    OUT p_acoustic INT,
    OUT p_instrumental INT
)
BEGIN
    SELECT
        get_bucket_from_score(AVG(s.danceability) , 3),
        get_bucket_from_score(AVG(s.energy) , 3),
        get_bucket_from_score(AVG(s.acousticness) , 3),
        get_bucket_from_score(AVG(s.instrumentalness) , 3)
    INTO p_dance, p_energy, p_acoustic, p_instrumental
    FROM listen l
    JOIN song s ON l.song_id = s.song_id
    WHERE l.user_id IN (p_user1_id, p_user2_id);
END //

DELIMITER ;

-- Q1: Top 10 recommended songs based on listening
SELECT
    s.song_id,
    s.song_name,
    s.album,
    s.popularity,
    COUNT(DISTINCT sg.song_genre_id) AS genre_overlap
FROM song s
JOIN songs_genres sg ON s.song_id = sg.song_id
WHERE sg.song_genre_id IN (
    SELECT DISTINCT sg2.song_genre_id
    FROM listen l
    JOIN songs_genres sg2 ON l.song_id = sg2.song_id
    WHERE l.user_id = 1
)
AND s.song_id NOT IN (
    SELECT song_id FROM listen WHERE user_id = 1
)
GROUP BY s.song_id, s.song_name, s.album, s.popularity
ORDER BY genre_overlap DESC, s.popularity DESC
LIMIT 10;

-- Q2: Top 10 recommended games based on gaming
SELECT
    g.game_id,
    g.game_name,
    g.positive_negative_ratings_ratio,
    g.price,
    COUNT(DISTINCT gg.genre_id) AS genre_overlap
FROM game g
JOIN games_genres gg ON g.game_id = gg.game_id
WHERE gg.genre_id IN (
    SELECT DISTINCT gg2.genre_id
    FROM play p
    JOIN games_genres gg2 ON p.game_id = gg2.game_id
    WHERE p.user_id = 1
)
AND g.game_id NOT IN (
    SELECT game_id FROM play WHERE user_id = 1
)
GROUP BY g.game_id, g.game_name, g.positive_negative_ratings_ratio, g.price
ORDER BY genre_overlap DESC, g.positive_negative_ratings_ratio DESC
LIMIT 10;

-- Q3: Top 10 recommended games based on song preference
CALL get_user_audio_buckets(
        1, @dance,
        @energy, @acoustic, @instrumental);

SELECT
    g.game_id,
    g.game_name,
    g.positive_negative_ratings_ratio,
    g.price,
    MIN(
        ABS(m.danceability_bucket - @dance) +
        ABS(m.energy_bucket - @energy) +
        ABS(m.acousticness_bucket - @acoustic) +
        ABS(m.instrumentalness_bucket - @instrumental)
    ) AS distance
FROM game g
JOIN games_genres gg ON g.game_id = gg.game_id
JOIN genre_to_song_metric_mapping m ON gg.genre_id = m.game_genre_id
WHERE g.game_id NOT IN (
    SELECT game_id FROM play WHERE user_id = 1
)
GROUP BY g.game_id, g.game_name, g.positive_negative_ratings_ratio, g.price
ORDER BY distance ASC, g.positive_negative_ratings_ratio DESC
LIMIT 10;

-- Q4: Top 10 recommended songs based on games
SELECT
    s.song_id,
    s.song_name,
    s.album,
    s.popularity,
    MIN(
        ABS(get_bucket_from_score(s.danceability, 3) - m.danceability_bucket) +
        ABS(get_bucket_from_score(s.energy, 3) - m.energy_bucket) +
        ABS(get_bucket_from_score(s.acousticness, 3) - m.acousticness_bucket) +
        ABS(get_bucket_from_score(s.instrumentalness, 3) - m.instrumentalness_bucket)
    ) AS distance
FROM song s
CROSS JOIN (
    SELECT DISTINCT m.danceability_bucket, m.energy_bucket,
                    m.acousticness_bucket, m.instrumentalness_bucket
    FROM play p
    JOIN games_genres gg ON p.game_id = gg.game_id
    JOIN genre_to_song_metric_mapping m ON gg.genre_id = m.game_genre_id
    WHERE p.user_id = 1
) m
WHERE s.song_id NOT IN (
    SELECT song_id FROM listen WHERE user_id = 1
)
GROUP BY s.song_id, s.song_name, s.album, s.popularity
ORDER BY distance, s.popularity DESC
LIMIT 10;

-- Q5: Top 10 recommended games for two users
CALL get_combined_audio_buckets(1, 2, @dance,
                                @energy, @acoustic, @instrumental);

SELECT
    g.game_id,
    g.game_name,
    g.positive_negative_ratings_ratio,
    g.price,
    MIN(
        ABS(m.danceability_bucket - @dance) +
        ABS(m.energy_bucket - @energy) +
        ABS(m.acousticness_bucket - @acoustic) +
        ABS(m.instrumentalness_bucket - @instrumental)
    ) AS distance
FROM game g
JOIN games_genres gg ON g.game_id = gg.game_id
JOIN genre_to_song_metric_mapping m ON gg.genre_id = m.game_genre_id
WHERE g.game_id NOT IN (
    SELECT game_id FROM play WHERE user_id IN (1, 2)
)
GROUP BY g.game_id, g.game_name, g.positive_negative_ratings_ratio, g.price
ORDER BY distance ASC, g.positive_negative_ratings_ratio DESC
LIMIT 10;

-- Q6: Top 10 recommended songs for two users
SELECT
    s.song_id,
    s.song_name,
    s.album,
    s.popularity,
    MIN(
        ABS(get_bucket_from_score(s.danceability, 3) - m.danceability_bucket) +
        ABS(get_bucket_from_score(s.energy, 3) - m.energy_bucket) +
        ABS(get_bucket_from_score(s.acousticness, 3) - m.acousticness_bucket) +
        ABS(get_bucket_from_score(s.instrumentalness, 3) - m.instrumentalness_bucket)
    ) AS distance
FROM song s
CROSS JOIN (
    SELECT DISTINCT m.danceability_bucket, m.energy_bucket,
                    m.acousticness_bucket, m.instrumentalness_bucket
    FROM play p
    JOIN games_genres gg ON p.game_id = gg.game_id
    JOIN genre_to_song_metric_mapping m ON gg.genre_id = m.game_genre_id
    WHERE p.user_id IN (1, 2)
) m
WHERE s.song_id NOT IN (
    SELECT song_id FROM listen WHERE user_id IN (1, 2)
)
GROUP BY s.song_id, s.song_name, s.album, s.popularity
ORDER BY distance ASC, s.popularity DESC
LIMIT 10;
