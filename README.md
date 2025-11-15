# Steamify

**__User Tables__**

User
- user_id
- user_name

**__Spotifys__**

Song
- song_id: int
- song_name
- album: string
- artist_id
- duration 
- popularity
- explicit: boolean
- danceability
- energy
- acousticness
- instrumentalness
- valence

Songs_Genres
- song_id
- song_genre_id

Song_Genre
- song_genre_id
- song_genre_name

Artist
- artist_id
- artist_name

Feature
- song_id
- artist_id

Listen
- user_id
- song_id

**__Steam Tables__**

Game
 - game_id
 - game_name
 - required_age
 - positive_negative_ratings_ratio
 - median_playtime
 - total_ratings
 - price

Develop
- game_id
- developer_id

Developer
- developer_id
- developer_name

Game_Genre
- game_genre_id
- game_genre_name

Games_Genres
- game_id
- genre_id

Games_Categories
- game_id
- category_id

Game_Category
- game_category_id
- game_category_name


**__Steamify Table(s)__**  

Idea for how to match attributes

| Song             | Game                                                  |
|------------------|-------------------------------------------------------|
| genre (only include top 20 in matching since there are a lot of song genres)           | category or genre                                     |
| duration         | median_playtime                                       |
| popularity       | total_ratings                                         |
| explicit         | required_age                                          |
| danceability     | category or genre                                     |
| energy           | category or genre                                     |
| acousticness     | category or genre                                     |
| instrumentalness | category or genre                                     |
| valence          | category or genre or positive_negative_ratings_ratio? |
