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
- loudness
- speechiness
- acousticness
- instrumentalness
- liveness
- valence
- tempo

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
Genre

Category

Game
 - Developer release date
