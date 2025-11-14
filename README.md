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

Song_Genre
- song_id
- genre

Artist
- artist_id
- artist_name

Feature
- song_id
- artist_id

Listen
- user_id
- songs_id

**__Steam Tables__**

Game
 - game_id
 - game_name
 - required_age
 - positive_negative_ratings_ratio
 - median_playtime
 - total_ratings
 - price
 - publisher_id

Publish
- game_id
- publisher_id

Publisher
- publisher_id
- publisher_name

Game_Genre
- game_id
- genre

Game_Category
- game_id
- category


**__Steamify Table__**  
