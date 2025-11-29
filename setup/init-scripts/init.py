import pandas as pd
from sqlalchemy import create_engine, text
import os
from dotenv import load_dotenv
from urllib.parse import quote_plus

load_dotenv()


def seed_database():
    DATABASE_NAME = "steamify"

    MYSQL_USER = os.getenv("MYSQL_USER", "root")
    MYSQL_PASSWORD = quote_plus(os.getenv("MYSQL_PASSWORD", ""))
    MYSQL_HOST = os.getenv("MYSQL_HOST", "localhost")
    MYSQL_PORT = os.getenv("MYSQL_PORT", "3306")

    if MYSQL_PASSWORD:
        auth_string = f"{MYSQL_USER}:{MYSQL_PASSWORD}"
    else:
        auth_string = f"{MYSQL_USER}"

    # Connect without database to create it
    connection_string_no_db = f"mysql+pymysql://{auth_string}@{MYSQL_HOST}:{MYSQL_PORT}"
    temp_engine = create_engine(connection_string_no_db)

    print("Creating database if it doesn't exist...")
    with temp_engine.connect() as connection:
        connection.execute(text(f"DROP DATABASE IF EXISTS {DATABASE_NAME}"))
        connection.execute(text(f"CREATE DATABASE {DATABASE_NAME}"))
        connection.commit()
    temp_engine.dispose()

    # Now connect to the specific database
    connection_string = (
        f"mysql+pymysql://{auth_string}@{MYSQL_HOST}:{MYSQL_PORT}/{DATABASE_NAME}"
    )
    engine = create_engine(connection_string)

    print("Running table creation script...")
    execute_sql_file(engine, "../create_tables.sql")
    sep()

    print("Running join tables script...")
    execute_sql_file(engine, "../join_tables.sql")
    sep()

    spotify_csv_folder = "../../table_csvs/spotify"
    steam_csv_folder = "../../table_csvs/steam"
    mapping_csv_folder = "../../table_csvs/mapping"

    spotify_parent_tables = [
        ("user", "user"),
        ("song", "song"),
        ("song_genre", "song_genre"),
        ("artist", "artist"),
    ]

    steam_parent_tables = [
        ("game", "game"),
        ("developer", "developer"),
        ("game_genre", "game_genre"),
        ("game_category", "game_category"),
    ]

    spotify_join_tables = [
        ("songs_genres", "songs_genres"),
        ("feature", "feature"),
        ("listen", "listen"),
    ]

    steam_join_tables = [
        ("develop", "develop"),
        ("games_genres", "games_genres"),
        ("games_categories", "games_categories"),
        ("play", "play"),
    ]

    mapping_join_tables = [("genre_mapping", "genre_mapping")]

    mapping_join_tables = [
        ("genre_mapping", "genre_mapping"),
        ("genre_to_song_metric_mapping", "genre_to_song_metric_mapping"),
    ]

    print("Loading parent tables first...")
    load_tables_by_name(spotify_csv_folder, spotify_parent_tables, engine)
    load_tables_by_name(steam_csv_folder, steam_parent_tables, engine)
    sep()

    print("Loading join tables...")
    load_tables_by_name(spotify_csv_folder, spotify_join_tables, engine)
    load_tables_by_name(steam_csv_folder, steam_join_tables, engine)
    load_tables_by_name(mapping_csv_folder, mapping_join_tables, engine)
    sep()

    engine.dispose()
    print("✓ Finished seeding the database! ✓")


def load_tables_by_name(folder, table_list, engine):
    """Load specific tables by name in the given order"""
    for csv_name, table_name in table_list:
        csv_path = os.path.join(folder, f"{csv_name}.csv")
        if os.path.exists(csv_path):
            insert_csv(csv_path, table_name, engine)
        else:
            print(f"⚠ Warning: {csv_path} not found, skipping...")


def insert_csv(csv_path, table_name, engine):
    """Insert a single CSV file into the database"""
    try:
        print(f"Loading {csv_path} into {table_name}...")
        df = pd.read_csv(csv_path)

        if table_name == "game" and "median_playtime" in df.columns:
            df.rename(
                columns={"median_playtime": "median_playtime_minutes"}, inplace=True
            )

        if table_name == "games_genres" and "game_genre_id" in df.columns:
            df.rename(columns={"game_genre_id": "genre_id"}, inplace=True)

        if table_name == "games_categories" and "game_category_id" in df.columns:
            df.rename(columns={"game_category_id": "category_id"}, inplace=True)

        df = df.where(pd.notnull(df), None)

        df.to_sql(
            table_name, con=engine, if_exists="append", index=False, chunksize=1000
        )
        print(f"✓ Inserted {len(df)} rows into {table_name}")
    except Exception as e:
        print(f"✗ Error processing {table_name}: {e}")
        raise


def execute_sql_file(engine, filepath):
    """Execute a SQL script file"""
    try:
        with open(filepath, "r") as file:
            sql_script = file.read()

        statements = [stmt.strip() for stmt in sql_script.split(";") if stmt.strip()]

        with engine.connect() as connection:
            for statement in statements:
                if statement:
                    connection.execute(text(statement))
                    connection.commit()

        print(f"✓ Successfully executed {filepath}")
    except FileNotFoundError:
        print(f"✗ SQL file not found: {filepath}")
        raise
    except Exception as e:
        print(f"✗ Error executing {filepath}: {e}")
        raise


def sep():
    print("=" * 100)
    print("=" * 100)


if __name__ == "__main__":
    seed_database()

