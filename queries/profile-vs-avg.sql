USE steamify;

-- Each User's Listening Profile vs The Average
SELECT u.user_id,
       u.user_name,
       AVG(s.danceability)                      AS user_danceability,
       (SELECT AVG(danceability) FROM song)     AS global_danceability,
       AVG(s.energy)                            AS user_energy,
       (SELECT AVG(energy) FROM song)           AS global_energy,
       AVG(s.acousticness)                      AS user_acousticness,
       (SELECT AVG(acousticness) FROM song)     AS global_acousticness,
       AVG(s.instrumentalness)                  AS user_instrumentalness,
       (SELECT AVG(instrumentalness) FROM song) AS global_instrumentalness,
       AVG(s.valence)                           AS user_valence,
       (SELECT AVG(valence) FROM song)          AS global_valence,
       COUNT(DISTINCT l.song_id)                AS songs_listened,
       (SELECT COUNT(*) FROM song)              AS total_songs_in_db
FROM user u
         JOIN listen l ON u.user_id = l.user_id
         JOIN song s ON l.song_id = s.song_id
GROUP BY u.user_id, u.user_name
ORDER BY u.user_id;

-- Each User's Gaming Profile vs The Average
SELECT u.user_id,
       u.user_name,
       AVG(g.positive_negative_ratings_ratio)                  AS user_rating_ratio,
       (SELECT AVG(positive_negative_ratings_ratio) FROM game) AS global_rating_ratio,
       AVG(g.median_playtime_minutes)                          AS user_playtime,
       (SELECT AVG(median_playtime_minutes) FROM game)         AS global_playtime,
       AVG(g.price)                                            AS user_price,
       (SELECT AVG(price) FROM game)                           AS global_price,
       COUNT(DISTINCT p.game_id)                               AS games_played,
       (SELECT COUNT(*) FROM game)                             AS total_games_in_db
FROM user u
         JOIN play p ON u.user_id = p.user_id
         JOIN game g ON p.game_id = g.game_id
GROUP BY u.user_id, u.user_name
ORDER BY u.user_id;