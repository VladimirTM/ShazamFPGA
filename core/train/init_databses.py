import sqlite3
connection = sqlite3.connect("shazam.db")
cursor = connection.cursor()

cursor.execute("DROP TABLE IF EXISTS songs;")
cursor.execute(
    "CREATE TABLE songs (id INTEGER PRIMARY KEY ASC, name TEXT UNIQUE NOT NULL);")

cursor.execute("DROP TABLE IF EXISTS song_hashes;")
cursor.execute("CREATE TABLE song_hashes (id INTEGER PRIMARY KEY, hash INTEGER NOT NULL, time INTEGER NOT NULL, song_id INTEGER NOT NULL, FOREIGN KEY (song_id) REFERENCES songs (id) ON DELETE CASCADE ON UPDATE NO ACTION);")
cursor.execute(
    "CREATE INDEX IF NOT EXISTS song_hashes_hash ON song_hashes (hash)")
