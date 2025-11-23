import pandas as pd
from sqlalchemy import create_engine, text
import os
import glob

def seed_database():
    DATABASE_NAME = "steamify"
    engine = create_engine(f'mysql+pymysql://root@localhost/{DATABASE_NAME}')

    print("Running the create tables script...")
    execute_sql_file(engine, "../create_tables.sql")
    
    print("Running the join tables script...")
    execute_sql_file(engine, "../join_tables.sql")
    
    spotify_csv_folder = "../../table_csvs/spotify"
    spotify_files = glob.glob(f'{spotify_csv_folder}/*.csv')
    
    steam_csv_folder = "../../table_csvs/steam"
    steam_files = glob.glob(f'{steam_csv_folder}/*.csv')

    if not spotify_files and not steam_files:
        print("Warning: No CSV files found!")
        return
    
    print(f"Found {len(spotify_files)} Spotify files and {len(steam_files)} Steam files.")
    print("Seeding the database...")
    
    insert_values(spotify_files, engine)
    insert_values(steam_files, engine)
    
    engine.dispose()
    print("✓ Finished seeding the database! ✓")
  
def execute_sql_file(engine, filepath):
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

def insert_values(files, engine):
    for csv_path in files:
        table_name = os.path.splitext(os.path.basename(csv_path))[0]
        try:
            print(f"Loading {csv_path} into {table_name}...")
            df = pd.read_csv(csv_path)
            
            df = df.where(pd.notnull(df), None)  
            
            df.to_sql(
                table_name,
                con=engine,
                if_exists="append",
                index=False,
                chunksize=1000
            )
            print(f"✓ Inserted {len(df)} rows into {table_name}")
        except FileNotFoundError:
            print(f"✗ File not found: {csv_path}")
        except Exception as e:
            print(f"✗ Error processing {table_name}: {e}")
            raise 

if __name__ == "__main__":
    seed_database()