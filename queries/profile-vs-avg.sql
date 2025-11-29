USE steamify;

-- Each User's Listening Profile vs The Average
WITH
    user_profiles AS (
        SELECT
            u.user_id,
            u.user_name,
            AVG(s.danceability) as avg_danceability,
            AVG(s.energy) as avg_energy,
            AVG(s.acousticness) as avg_acousticness,
            AVG(s.instrumentalness) as avg_instrumentalness,
            AVG(s.valence) as avg_valence
        FROM user u
            JOIN listen l ON u.user_id = l.user_id
            JOIN song s ON l.song_id = s.song_id
        GROUP BY
            u.user_id,
            u.user_name
    ),
    global_avg AS (
        SELECT
            AVG(danceability) as avg_danceability,
            AVG(energy) as avg_energy,
            AVG(acousticness) as avg_acousticness,
            AVG(instrumentalness) as avg_instrumentalness,
            AVG(valence) as avg_valence
        FROM song
    )
SELECT
    up.user_id,
    up.user_name,
    up.avg_danceability as user_danceability,
    ga.avg_danceability as global_danceability,
    up.avg_energy as user_energy,
    ga.avg_energy as global_energy,
    up.avg_acousticness as user_acousticness,
    ga.avg_acousticness as global_acousticness,
    up.avg_instrumentalness as user_instrumentalness,
    ga.avg_instrumentalness as global_instrumentalness,
    up.avg_valence as user_valence,
    ga.avg_valence as global_valence
FROM user_profiles up
    CROSS JOIN global_avg ga
ORDER BY up.user_id;

-- Each User's Gaming Profile vs The Average
WITH
    user_profiles AS (
        SELECT
            u.user_id,
            u.user_name,
            AVG(
                g.positive_negative_ratings_ratio
            ) as avg_rating_ratio,
            AVG(g.median_playtime_minutes) as avg_playtime,
            AVG(g.price) as avg_price,
            COUNT(DISTINCT p.game_id) as games_played
        FROM user u
            JOIN play p ON u.user_id = p.user_id
            JOIN game g ON p.game_id = g.game_id
        GROUP BY
            u.user_id,
            u.user_name
    ),
    global_avg AS (
        SELECT
            AVG(
                positive_negative_ratings_ratio
            ) as avg_rating_ratio,
            AVG(median_playtime_minutes) as avg_playtime,
            AVG(price) as avg_price,
            COUNT(*) as total_games
        FROM game
    )
SELECT
    up.user_id,
    up.user_name,
    up.avg_rating_ratio as user_rating_ratio,
    ga.avg_rating_ratio as global_rating_ratio,
    up.avg_playtime as user_playtime,
    ga.avg_playtime as global_playtime,
    up.avg_price as user_price,
    ga.avg_price as global_price,
    up.games_played as user_games_played,
    ga.total_games as total_games_in_db
FROM user_profiles up
    CROSS JOIN global_avg ga
ORDER BY up.user_id;