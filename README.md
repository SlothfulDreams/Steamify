# Steamify

**__User Tables__**
User

**__Spotify Table__**
Songs
- track_id: int
- track_name
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
- track_id
- genre

Artist
- artist_id
- artist_name

Feature
- track_id
- artist_id

Listen
- user_id
- songs_id

Playlist

**__Steam Table__**

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
