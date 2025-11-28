-- Spotify Join Tables

USE steamify;

DROP TABLE IF EXISTS songs_genres;

CREATE TABLE IF NOT EXISTS songs_genres (
    song_id INT NOT NULL,
    song_genre_id INT NOT NULL,
    PRIMARY KEY (song_id, song_genre_id),
    FOREIGN KEY (song_id) REFERENCES song (song_id),
    FOREIGN KEY (song_genre_id) REFERENCES song_genre (song_genre_id)
);

DROP TABLE IF EXISTS feature;

CREATE TABLE IF NOT EXISTS feature (
    song_id INT NOT NULL,
    artist_id INT NOT NULL,
    PRIMARY KEY (song_id, artist_id),
    FOREIGN KEY (song_id) REFERENCES song (song_id),
    FOREIGN KEY (artist_id) REFERENCES artist (artist_id)
);

DROP TABLE IF EXISTS listen;

CREATE TABLE IF NOT EXISTS listen (
    user_id INT NOT NULL,
    song_id INT NOT NULL,
    PRIMARY KEY (user_id, song_id),
    FOREIGN KEY (user_id) REFERENCES user (user_id),
    FOREIGN KEY (song_id) REFERENCES song (song_id)
);

-- Steam Join Tables

DROP TABLE IF EXISTS develop;

CREATE TABLE IF NOT EXISTS develop (
    game_id INT NOT NULL,
    developer_id INT NOT NULL,
    PRIMARY KEY (game_id, developer_id),
    FOREIGN KEY (game_id) REFERENCES game (game_id),
    FOREIGN KEY (developer_id) REFERENCES developer (developer_id)
);

DROP TABLE IF EXISTS games_genres;

CREATE TABLE IF NOT EXISTS games_genres (
    game_id INT NOT NULL,
    genre_id INT NOT NULL,
    PRIMARY KEY (game_id, genre_id),
    FOREIGN KEY (game_id) REFERENCES game (game_id),
    FOREIGN KEY (genre_id) REFERENCES game_genre (game_genre_id)
);

DROP TABLE IF EXISTS games_categories;

CREATE TABLE IF NOT EXISTS games_categories (
    game_id INT NOT NULL,
    category_id INT NOT NULL,
    PRIMARY KEY (game_id, category_id),
    FOREIGN KEY (game_id) REFERENCES game (game_id),
    FOREIGN KEY (category_id) REFERENCES game_category (game_category_id)
);

-- Mapping join tables between Spotify and Steam

DROP TABLE IF EXISTS genre_mapping;

CREATE TABLE IF NOT EXISTS genre_mapping (
    song_genre_id INT NOT NULL,
    game_genre_id INT NOT NULL,
    PRIMARY KEY (song_genre_id, game_genre_id),
    FOREIGN KEY (song_genre_id) REFERENCES song_genre (song_genre_id),
    FOREIGN KEY (game_genre_id) REFERENCES game_genre (game_genre_id)
DROP TABLE IF EXISTS play;

CREATE TABLE IF NOT EXISTS play (
    user_id INT NOT NULL,
    game_id INT NOT NULL,
    PRIMARY KEY (user_id, game_id),
    FOREIGN KEY (user_id) REFERENCES user (user_id),
    FOREIGN KEY (game_id) REFERENCES game (game_id)
);