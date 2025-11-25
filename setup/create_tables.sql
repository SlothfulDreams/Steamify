USE steamify;

DROP TABLE IF EXISTS User;

CREATE TABLE User (
    user_id INT PRIMARY KEY,
    user_name VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS Song;

CREATE TABLE Song (
    song_id INT PRIMARY KEY,
    song_name VARCHAR(255) NOT NULL,
    album VARCHAR(255),
    duration DECIMAL(10, 2) NOT NULL,
    popularity INT NOT NULL,
    explicit BOOLEAN NOT NULL,
    danceability DECIMAL(10, 6) NOT NULL,
    energy DECIMAL(10, 6) NOT NULL,
    acousticness DECIMAL(10, 6) NOT NULL,
    instrumentalness DECIMAL(10, 6) NOT NULL,
    valence DECIMAL(10, 6) NOT NULL
);

DROP TABLE IF EXISTS SongGenre;

CREATE TABLE SongGenre (
    song_genre_id INT PRIMARY KEY,
    song_genre_name VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS Artist;

CREATE TABLE Artist (
    artist_id INT PRIMARY KEY,
    artist_name VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS Developer;

CREATE TABLE Developer (
    developer_id INT PRIMARY KEY,
    developer_name VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS Game;

CREATE TABLE Game (
    game_id INT PRIMARY KEY,
    game_name VARCHAR(255) NOT NULL,
    required_age INT NOT NULL,
    positive_negative_ratings_ratio DECIMAL(10, 6),
    median_playtime_minutes INT NOT NULL,
    total_ratings INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

DROP TABLE IF EXISTS GameGenre;

CREATE TABLE GameGenre (
    game_genre_id INT PRIMARY KEY,
    game_genre_name VARCHAR(255)
);

DROP TABLE IF EXISTS GameCategory;

CREATE TABLE GameCategory (
    game_category_id INT PRIMARY KEY,
    game_category_name VARCHAR(255) NOT NULL
);