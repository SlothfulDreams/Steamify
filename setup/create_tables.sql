DROP DATABASE IF EXISTS steamify;

CREATE DATABASE steamify;

USE steamify;

DROP TABLE IF EXISTS User;

CREATE TABLE User (
    user_id INT PRIMARY KEY,
    user_name VARCHAR(45) NOT NULL
);

DROP TABLE IF EXISTS Song;

CREATE TABLE Song (
    song_id INT PRIMARY KEY,
    song_name VARCHAR(45) NOT NULL,
    album_name VARCHAR(45),
    duration_minutes INT NOT NULL,
    popularity INT NOT NULL,
    is_explicit BOOLEAN NOT NULL,
    danceability DECIMAL(3) NOT NULL,
    energy DECIMAL(3) NOT NULL,
    acousticness DECIMAL(3) NOT NULL,
    instrumentalness DECIMAL(3) NOT NULL,
    valence DECIMAL(3) NOT NULL
);

DROP TABLE IF EXISTS SongGenre;

CREATE TABLE SongGenre (
    song_genre_id INT PRIMARY KEY,
    song_genre_name VARCHAR(45) NOT NULL
);

DROP TABLE IF EXISTS Aritst;

CREATE TABLE Artist (
    artist_id INT PRIMARY KEY,
    artist_name VARCHAR(45) NOT NULL
);

DROP TABLE IF EXISTS Developer;

CREATE TABLE Developer (
    developer_id INT PRIMARY KEY,
    developer_name VARCHAR(45) NOT NULL
);

DROP TABLE IF EXISTS Game;

CREATE TABLE Game (
    game_id INT PRIMARY KEY,
    game_name VARCHAR(45) NOT NULL,
    required_age INT NOT NULl,
    positive_negative_ratings_ratio DECIMAL(3),
    median_playtime_minutes VARCHAR(45) NOT NULL,
    total_ratings INT NOT NULl,
    price DECIMAL(2) NOT NULL
);

DROP TABLE IF EXISTS GameGenre;

CREATE TABLE GameGenre (
    game_genre_id INT PRIMARY KEY,
    game_genre_name VARCHAR(45)
);

DROP TABLE IF EXISTS GameCategory;

CREATE TABLE GameCategory (
    game_category_id INT PRIMARY KEY,
    game_category_name VARCHAR(45) NOT NULL
);