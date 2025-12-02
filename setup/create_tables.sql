USE steamify;

DROP TABLE IF EXISTS user;

CREATE TABLE user (
    user_id INT PRIMARY KEY,
    user_name VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS song;

CREATE TABLE song (
    song_id INT PRIMARY KEY,
    song_name VARCHAR(255) NOT NULL,
    album VARCHAR(255),
    duration DECIMAL(10, 2) NOT NULL,
    popularity  DECIMAL(10, 6) NOT NULL,
    explicit BOOLEAN NOT NULL,
    danceability DECIMAL(10, 6) NOT NULL,
    energy DECIMAL(10, 6) NOT NULL,
    acousticness DECIMAL(10, 6) NOT NULL,
    instrumentalness DECIMAL(10, 6) NOT NULL,
    valence DECIMAL(10, 6) NOT NULL
);

DROP TABLE IF EXISTS song_genre;

CREATE TABLE song_genre (
    song_genre_id INT PRIMARY KEY,
    song_genre_name VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS artist;

CREATE TABLE artist (
    artist_id INT PRIMARY KEY,
    artist_name VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS developer;

CREATE TABLE developer (
    developer_id INT PRIMARY KEY,
    developer_name VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS game;

CREATE TABLE game (
    game_id INT PRIMARY KEY,
    game_name VARCHAR(255) NOT NULL,
    required_age INT NOT NULL,
    positive_negative_ratings_ratio DECIMAL(10, 6) NOT NULL,
    median_playtime_minutes  DECIMAL(10, 6) NOT NULL,
    total_ratings  DECIMAL(10, 6) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

DROP TABLE IF EXISTS game_genre;

CREATE TABLE game_genre (
    game_genre_id INT PRIMARY KEY,
    game_genre_name VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS game_category;

CREATE TABLE game_category (
    game_category_id INT PRIMARY KEY,
    game_category_name VARCHAR(255) NOT NULL
);