import pandas as pd
from sqlalchemy import create_engine, text
import os

def seed_database():
    DATABASE_NAME = "steamify"
    engine = create_engine(f'mysql+pymysql://root@localhost/{DATABASE_NAME}')
    
    # Run SQL scripts first
    print("Running table creation script...")
    execute_sql_file(engine, "../create_tables.sql")
    sep()
    
    print("Running join tables script...")
    execute_sql_file(engine, "../join_tables.sql")
    sep()
    
    spotify_csv_folder = "../../table_csvs/spotify"
    steam_csv_folder = "../../table_csvs/steam"
    
    spotify_parent_tables = [
        ('user', 'User'),
        ('song', 'Song'),
        ('song_genre', 'SongGenre'),
        ('artist', 'Artist')
    ]
    
    steam_parent_tables = [
        ('game', 'Game'),
        ('developer', 'Developer'),
        ('game_genre', 'GameGenre'),
        ('game_category', 'GameCategory')
    ]
    
    spotify_join_tables = [
        ('songs_genres', 'Songs_Genres'),
        ('feature', 'Feature'),
        ('listen', 'Listen')
    ]
    
    steam_join_tables = [
        ('develop', 'Develop'),
        ('games_genres', 'Games_Genres'),
        ('games_categories', 'Games_Categories')
    ]
    
    print("Loading parent tables first...")
    load_tables_by_name(spotify_csv_folder, spotify_parent_tables, engine)
    load_tables_by_name(steam_csv_folder, steam_parent_tables, engine)
    sep()
    
    print("Loading join tables...")
    load_tables_by_name(spotify_csv_folder, spotify_join_tables, engine)
    load_tables_by_name(steam_csv_folder, steam_join_tables, engine)
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
        
        if table_name == 'Game' and 'median_playtime' in df.columns:
            df.rename(columns={'median_playtime': 'median_playtime_minutes'}, inplace=True)
        
        if table_name == 'Games_Genres' and 'game_genre_id' in df.columns:
            df.rename(columns={'game_genre_id': 'genre_id'}, inplace=True)
        
        if table_name == 'Games_Categories' and 'game_category_id' in df.columns:
            df.rename(columns={'game_category_id': 'category_id'}, inplace=True)
        
        df = df.where(pd.notnull(df), None)
        
        df.to_sql(
            table_name,
            con=engine,
            if_exists="append",
            index=False,
            chunksize=1000
        )
        print(f"✓ Inserted {len(df)} rows into {table_name}")
    except Exception as e:
        print(f"✗ Error processing {table_name}: {e}")
        raise

def execute_sql_file(engine, filepath):
    """Execute a SQL script file"""
    try:
        with open(filepath, 'r') as file:
            sql_script = file.read()
        
        statements = [stmt.strip() for stmt in sql_script.split(';') if stmt.strip()]
        
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
    print("="*50)

if __name__ == "__main__":
    seed_database()