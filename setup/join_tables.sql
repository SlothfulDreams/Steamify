-- Spotify Join Tables

CREATE TABLE IF NOT EXISTS Songs_Genres (
    song_id INT NOT NULL,
    song_genre_id INT NOT NULL,
    PRIMARY KEY (song_id, song_genre_id),
    FOREIGN KEY (song_id) REFERENCES Song(song_id),
    FOREIGN KEY (song_genre_id) REFERENCES Song_Genre(song_genre_id)
);

CREATE TABLE IF NOT EXISTS Feature (
    song_id INT NOT NULL,
    artist_id INT NOT NULL,
    PRIMARY KEY (song_id, artist_id),
    FOREIGN KEY (song_id) REFERENCES Song(song_id),
    FOREIGN KEY (artist_id) REFERENCES Artist(artist_id)
);

CREATE TABLE IF NOT EXISTS Listen (
    user_id INT NOT NULL,
    song_id INT NOT NULL,
    PRIMARY KEY (user_id, song_id),
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    FOREIGN KEY (song_id) REFERENCES Song(song_id)
);

-- Steam Join Tables

CREATE TABLE IF NOT EXISTS Develop (
    game_id INT NOT NULL,
    developer_id INT NOT NULL,
    PRIMARY KEY (game_id, developer_id),
    FOREIGN KEY (game_id) REFERENCES Game(game_id),
    FOREIGN KEY (developer_id) REFERENCES Developer(developer_id)
);

CREATE TABLE IF NOT EXISTS Games_Genres (
    game_id INT NOT NULL,
    genre_id INT NOT NULL,
    PRIMARY KEY (game_id, genre_id),
    FOREIGN KEY (game_id) REFERENCES Game(game_id),
    FOREIGN KEY (genre_id) REFERENCES Game_Genre(game_genre_id)
);

CREATE TABLE IF NOT EXISTS Games_Categories (
    game_id INT NOT NULL,
    category_id INT NOT NULL,
    PRIMARY KEY (game_id, category_id),
    FOREIGN KEY (game_id) REFERENCES Game(game_id),
    FOREIGN KEY (category_id) REFERENCES Game_Category(game_category_id)
);
