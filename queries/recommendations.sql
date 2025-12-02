USE steamify;

DROP FUNCTION IF EXISTS get_bucket_from_score;

DELIMITER //

-- Function: get_bucket_from_score
-- Calculates an int bucket number by bucketing numeric values into n buckets
CREATE FUNCTION get_bucket_from_score(score DECIMAL(10, 6), n INT) RETURNS INT
    DETERMINISTIC CONTAINS SQL
BEGIN
    DECLARE category_index_var INT;

    SET category_index_var = FLOOR(score / (100 / n));

    IF category_index_var >= n THEN SET category_index_var = n - 1; END IF;

    RETURN category_index_var + 1;
END //

DELIMITER ;

-- 
DROP PROCEDURE IF EXISTS get_user_audio_buckets;

DELIMITER //
    
-- Procedure: get_user_audio_buckets
-- Calculates a user's average audio profile from their listening history.
-- Averages danceability, energy, acousticness, and instrumentalness across all songs, then bucket it into a 1-3 scale
CREATE PROCEDURE get_user_audio_buckets(
  IN p_user_id       INT,
  OUT p_dance        INT,
  OUT p_energy       INT,
  OUT p_acoustic     INT,
  OUT p_instrumental INT
)
BEGIN
  SELECT get_bucket_from_score(AVG(s.danceability), 3),
         get_bucket_from_score(AVG(s.energy), 3),
         get_bucket_from_score(AVG(s.acousticness), 3),
         get_bucket_from_score(AVG(s.instrumentalness), 3)
  INTO p_dance, p_energy, p_acoustic, p_instrumental
  FROM listen l
         JOIN song s ON l.song_id = s.song_id
  WHERE l.user_id = p_user_id;
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS get_combined_audio_buckets;

DELIMITER //

-- Procedure: get_combined_audio_buckets
-- Calculates a combined audio profile for two user's listening histories.
-- Averages audio features across both user songs, then buckets it into a 1-3 scale.
CREATE PROCEDURE get_combined_audio_buckets(
  IN p_user1_id      INT,
  IN p_user2_id      INT,
  OUT p_dance        INT,
  OUT p_energy       INT,
  OUT p_acoustic     INT,
  OUT p_instrumental INT
)
BEGIN
  SELECT get_bucket_from_score(AVG(s.danceability), 3),
         get_bucket_from_score(AVG(s.energy), 3),
         get_bucket_from_score(AVG(s.acousticness), 3),
         get_bucket_from_score(AVG(s.instrumentalness), 3)
  INTO p_dance, p_energy, p_acoustic, p_instrumental
  FROM listen l
         JOIN song s ON l.song_id = s.song_id
  WHERE l.user_id IN (p_user1_id, p_user2_id);
END //

DELIMITER ;

-- Q1: Top 10 recommended songs based on listening
SELECT s.song_id,
       s.song_name,
       s.album,
       s.popularity,
       COUNT(DISTINCT sg.song_genre_id) AS genre_overlap
FROM song s
       JOIN songs_genres sg ON s.song_id = sg.song_id
WHERE sg.song_genre_id IN ( SELECT DISTINCT sg2.song_genre_id
                            FROM listen l
                                   JOIN songs_genres sg2 ON l.song_id = sg2.song_id
                            WHERE l.user_id = 1 )
  AND s.song_id NOT IN ( SELECT song_id
                         FROM listen
                         WHERE user_id = 1 )
GROUP BY s.song_id, s.song_name, s.album, s.popularity
ORDER BY genre_overlap DESC, s.popularity DESC
LIMIT 10;

-- Q2: Top 10 recommended games based on gaming
SELECT g.game_id,
       g.game_name,
       g.positive_negative_ratings_ratio,
       g.price,
       COUNT(DISTINCT gg.genre_id) AS genre_overlap
FROM game g
       JOIN games_genres gg ON g.game_id = gg.game_id
WHERE gg.genre_id IN ( SELECT DISTINCT gg2.genre_id
                       FROM play p
                              JOIN games_genres gg2 ON p.game_id = gg2.game_id
                       WHERE p.user_id = 1 )
  AND g.game_id NOT IN ( SELECT game_id
                         FROM play
                         WHERE user_id = 1 )
GROUP BY g.game_id, g.game_name, g.positive_negative_ratings_ratio, g.price
ORDER BY genre_overlap DESC, g.positive_negative_ratings_ratio DESC
LIMIT 10;

-- Q3: Top 10 recommended games based on song preference
CALL get_user_audio_buckets(
    1, @dance,
    @energy, @acoustic, @instrumental);

SELECT g.game_id,
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
WHERE g.game_id NOT IN ( SELECT game_id
                         FROM play
                         WHERE user_id = 1 )
GROUP BY g.game_id, g.game_name, g.positive_negative_ratings_ratio, g.price
ORDER BY distance ASC, g.positive_negative_ratings_ratio DESC
LIMIT 10;

-- Q4: Top 10 recommended songs based on games
SELECT s.song_id,
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
       CROSS JOIN ( SELECT DISTINCT m.danceability_bucket,
                                    m.energy_bucket,
                                    m.acousticness_bucket,
                                    m.instrumentalness_bucket
                    FROM play p
                           JOIN games_genres gg ON p.game_id = gg.game_id
                           JOIN genre_to_song_metric_mapping m ON gg.genre_id = m.game_genre_id
                    WHERE p.user_id = 1 ) m
WHERE s.song_id NOT IN ( SELECT song_id
                         FROM listen
                         WHERE user_id = 1 )
GROUP BY s.song_id, s.song_name, s.album, s.popularity
ORDER BY distance, s.popularity DESC
LIMIT 10;

-- Q5: Top 10 recommended games for two users
CALL get_combined_audio_buckets(1, 2, @dance,
                                @energy, @acoustic, @instrumental);

SELECT g.game_id,
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
WHERE g.game_id NOT IN ( SELECT game_id
                         FROM play
                         WHERE user_id IN (1, 2) )
GROUP BY g.game_id, g.game_name, g.positive_negative_ratings_ratio, g.price
ORDER BY distance ASC, g.positive_negative_ratings_ratio DESC
LIMIT 10;

-- Q6: Top 10 recommended songs for two users
SELECT s.song_id,
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
       CROSS JOIN ( SELECT DISTINCT m.danceability_bucket,
                                    m.energy_bucket,
                                    m.acousticness_bucket,
                                    m.instrumentalness_bucket
                    FROM play p
                           JOIN games_genres gg ON p.game_id = gg.game_id
                           JOIN genre_to_song_metric_mapping m ON gg.genre_id = m.game_genre_id
                    WHERE p.user_id IN (1, 2) ) m
WHERE s.song_id NOT IN ( SELECT song_id
                         FROM listen
                         WHERE user_id IN (1, 2) )
GROUP BY s.song_id, s.song_name, s.album, s.popularity
ORDER BY distance ASC, s.popularity DESC
LIMIT 10;

-- Q7: What is a given user's listening preferences/profile summary compared to the avg?
SELECT u.user_id,
       u.user_name,
       AVG(s.danceability)       AS user_danceability,
       ( SELECT AVG(danceability)
         FROM song )             AS global_danceability,
       AVG(s.energy)             AS user_energy,
       ( SELECT AVG(energy)
         FROM song )             AS global_energy,
       AVG(s.acousticness)       AS user_acousticness,
       ( SELECT AVG(acousticness)
         FROM song )             AS global_acousticness,
       AVG(s.instrumentalness)   AS user_instrumentalness,
       ( SELECT AVG(instrumentalness)
         FROM song )             AS global_instrumentalness,
       AVG(s.valence)            AS user_valence,
       ( SELECT AVG(valence)
         FROM song )             AS global_valence,
       COUNT(DISTINCT l.song_id) AS songs_listened,
       ( SELECT COUNT(*)
         FROM song )             AS total_songs_in_db
FROM user u
       JOIN listen l ON u.user_id = l.user_id
       JOIN song s ON l.song_id = s.song_id
GROUP BY u.user_id,
         u.user_name
ORDER BY u.user_id;

-- Q8: What is a given user's gaming preferences/profile summary compared to the avg?
SELECT u.user_id,
       u.user_name,
       AVG(
           g.positive_negative_ratings_ratio
       )                              AS user_rating_ratio,
       ( SELECT AVG(
                    positive_negative_ratings_ratio
                )
         FROM game )                  AS global_rating_ratio,
       AVG(g.median_playtime_minutes) AS user_playtime,
       ( SELECT AVG(median_playtime_minutes)
         FROM game )                  AS global_playtime,
       AVG(g.price)                   AS user_price,
       ( SELECT AVG(price)
         FROM game )                  AS global_price,
       COUNT(DISTINCT p.game_id)      AS games_played,
       ( SELECT COUNT(*)
         FROM game )                  AS total_games_in_db
FROM user u
       JOIN play p ON u.user_id = p.user_id
       JOIN game g ON p.game_id = g.game_id
GROUP BY u.user_id,
         u.user_name
ORDER BY u.user_id;

-- Q9: How does a user's recommended songs change based on their listening vs gaming?
SELECT song_id,
       MAX(song_name)  AS song_name,
       MAX(popularity) AS popularity,
       CASE
         WHEN COUNT(DISTINCT source) = 2 THEN 'Both'
         WHEN MAX(source) = 'Listening' THEN 'Listening Only'
         ELSE 'Gaming Only'
         END           AS recommendation_source
FROM ( ( SELECT s.song_id,
                s.song_name,
                s.popularity,
                'Listening' AS source
         FROM song s
                JOIN songs_genres sg ON s.song_id = sg.song_id
         WHERE sg.song_genre_id IN ( SELECT DISTINCT sg2.song_genre_id
                                     FROM listen l
                                            JOIN songs_genres sg2 ON l.song_id = sg2.song_id
                                     WHERE l.user_id = 1 )
           AND s.song_id NOT IN ( SELECT song_id
                                  FROM listen
                                  WHERE user_id = 1 )
         GROUP BY s.song_id, s.song_name, s.popularity
         ORDER BY COUNT(DISTINCT sg.song_genre_id) DESC, s.popularity DESC
         LIMIT 10 )

       UNION ALL

       ( SELECT s.song_id,
                s.song_name,
                s.popularity,
                'Gaming' AS source
         FROM song s
                CROSS JOIN ( SELECT DISTINCT m.danceability_bucket,
                                             m.energy_bucket,
                                             m.acousticness_bucket,
                                             m.instrumentalness_bucket
                             FROM play p
                                    JOIN games_genres gg ON p.game_id = gg.game_id
                                    JOIN genre_to_song_metric_mapping m
                                         ON gg.genre_id = m.game_genre_id
                             WHERE p.user_id = 1 ) m
         WHERE s.song_id NOT IN ( SELECT song_id
                                  FROM listen
                                  WHERE user_id = 1 )
         GROUP BY s.song_id, s.song_name, s.popularity
         ORDER BY MIN(
                      ABS(get_bucket_from_score(s.danceability, 3) - m.danceability_bucket) +
                      ABS(get_bucket_from_score(s.energy, 3) - m.energy_bucket) +
                      ABS(get_bucket_from_score(s.acousticness, 3) - m.acousticness_bucket) +
                      ABS(get_bucket_from_score(s.instrumentalness, 3) -
                          m.instrumentalness_bucket)
                  ) ASC, s.popularity DESC
         LIMIT 10 ) ) AS combined
GROUP BY song_id
ORDER BY recommendation_source, popularity DESC;

-- Q10: How does a user's recommended games change based on their gaming vs listening?
CALL get_user_audio_buckets(
    1,
    @dance,
    @energy,
    @acoustic,
    @instrumental
);

SELECT game_id,
       MAX(game_name)                       AS game_name,
       MAX(positive_negative_ratings_ratio) AS rating_ratio,
       CASE
         WHEN COUNT(DISTINCT source) = 2 THEN 'Both'
         WHEN MAX(source) = 'Gaming' THEN 'Gaming Only'
         ELSE 'Listening Only'
         END                                AS recommendation_source
FROM ( ( SELECT g.game_id,
                g.game_name,
                g.positive_negative_ratings_ratio,
                'Gaming' AS source
         FROM game g
                JOIN games_genres gg ON g.game_id = gg.game_id
         WHERE gg.genre_id IN ( SELECT DISTINCT gg2.genre_id
                                FROM play p
                                       JOIN games_genres gg2 ON p.game_id = gg2.game_id
                                WHERE p.user_id = 1 )
           AND g.game_id NOT IN ( SELECT game_id
                                  FROM play
                                  WHERE user_id = 1 )
         GROUP BY g.game_id, g.game_name, g.positive_negative_ratings_ratio
         ORDER BY COUNT(DISTINCT gg.genre_id) DESC, g.positive_negative_ratings_ratio DESC
         LIMIT 10 )

       UNION ALL

       ( SELECT g.game_id,
                g.game_name,
                g.positive_negative_ratings_ratio,
                'Listening' AS source
         FROM game g
                JOIN games_genres gg ON g.game_id = gg.game_id
                JOIN genre_to_song_metric_mapping m ON gg.genre_id = m.game_genre_id
         WHERE g.game_id NOT IN ( SELECT game_id
                                  FROM play
                                  WHERE user_id = 1 )
         GROUP BY g.game_id, g.game_name, g.positive_negative_ratings_ratio
         ORDER BY MIN(
                      ABS(m.danceability_bucket - @dance) +
                      ABS(m.energy_bucket - @energy) +
                      ABS(m.acousticness_bucket - @acoustic) +
                      ABS(m.instrumentalness_bucket - @instrumental)
                  ), g.positive_negative_ratings_ratio DESC
         LIMIT 10 ) ) AS combined
GROUP BY game_id
ORDER BY recommendation_source, rating_ratio DESC;
