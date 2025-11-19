import pandas as pd
from sqlalchemy import create_engine
import os
import glob

def seed_database():
  DATABASE_NAME = "steamify"
  engine = create_engine(f'mysql+pymysql://root@localhost/{DATABASE_NAME}') # password is not needed

  spotify_csv_folder = "../../table_csvs/spotify"
  spotify_files = glob.glob(f'{spotify_csv_folder}/*.csv')
  
  steam_csv_folder = "../../table_csvs/steam"
  steam_files = glob.glob(f'{steam_csv_folder}/*.csv')

  print("Files have been found.\nSeeding the database...")
  
  insert_values(spotify_files, engine)
  insert_values(steam_files, engine)
  
  engine.dispose()
  print("✓ Finished seeding the database! ✓")

def insert_values(files, engine):
  for csv_path in files:
    table_name = os.path.splitext(os.path.basename(csv_path))[0]

    try:
      print(f"Loading {csv_path} into {table_name}...")
      df = pd.read_csv(csv_path)
      
      df.to_sql(
        table_name,
        con=engine,
        if_exists="append",
        index=False,
        chunksize=1000
      )

      print(f"Inserted {len(df)} rows into {table_name}")
    except Exception as e:
      print(f"An error occurred while processing files for {table_name}: {e}")
      raise RuntimeError()

if __name__ == "__main__":
  seed_database()
