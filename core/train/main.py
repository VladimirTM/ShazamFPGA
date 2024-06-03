import serial
import time
import aiosqlite
import asyncio

BAUD_RATE = 2_000_000
F_RANG = 10

fpga_com = serial.Serial('COM4', BAUD_RATE, timeout=0)

database: aiosqlite.Connection = None
async def write_hashes_to_DB (hash, time, song_id):
    global database
    cursor = await database.execute("INSERT INTO song_hashes (hash, time, song_id) VALUES (?, ?, ?);", [hash, time, song_id])
    await database.commit()
    await cursor.close()

constellation_map = []
async def upload_1_hash (idx, time, freq, song_id):
    if(idx > F_RANG): 
        return; 

    # Iterate the constellation
    # Iterate the next 100 pairs to produce the combinatorial hashes
    # When we produced the constellation before, it was sorted by time already
    # So this finds the next n points in time (though they might occur at the same time)
    for other_time, other_freq in constellation_map[idx : idx + F_RANG]: 
        diff = other_time - time
        # If the time difference between the pairs is too small or large
        # ignore this set of pairs
        if diff < 1 or diff > 100:
            continue

        # Produce a 32 bit hash
        # Use bit shifting to move the bits to the correct location
        hash = int(freq) | (int(other_freq) << 10) | (int(diff) << 20)
        await write_hashes_to_DB(hash, time, song_id)


async def upload_to_database(song_id):
    if(not song_id):
        raise ValueError('No song id was provided!')
    await asyncio.gather(*[upload_1_hash(idx, time, freq, song_id) for idx, (time, freq) in enumerate(constellation_map)])    

def read_data():
    reading = fpga_com.read(1)
    if(reading):
        return ord(reading) * 2
    else:
        return None

i = 0
j = 0
data_from_FPGA = None
started = 0

async def read_frequencies (song_id):
    try: 
        global data_from_FPGA, i, j, started, constellation_map
        while (data_from_FPGA != None or not started):
            data_from_FPGA = read_data()
            print("FREQUENCY: ", data_from_FPGA)
            if data_from_FPGA: 
                started = 1;
                constellation_map.append([time.perf_counter() * 10_000, data_from_FPGA])
                if(j == 2 * F_RANG):
                    await upload_to_database(song_id)
                    print("Progress: Uploaded Successfully!")
                    constellation_map = []
                    j = 0
                else:
                    if(i == 15):
                        i = 0
                        j = j + 1
                    else: 
                        i = i + 1
    except Exception as e: 
        print("An error occurred in read_frequencies: ", e)

async def main():
    global database
    database = await aiosqlite.connect("shazam.db")
    
    song_name = input("Please select the name of the song you want to train: ")

    cursor = await database.execute("SELECT id FROM songs WHERE songs.name = ?", [song_name])
    id = await cursor.fetchone()
    await cursor.close()
    print("THE ID IS:", id)
    if(id):
        id = id[0]
        print(f"\n {song_name}: has already been recorded! Will delete the current training data!")
        await database.execute("DELETE FROM songs WHERE songs.id = ?", [id])
        await database.commit()
    
    cursor = await database.execute("INSERT INTO songs (name) VALUES (?) RETURNING id", [song_name])
    id = await cursor.fetchone()
    await database.commit()

    id = id[0]
    print("THE NEW ID IS:", id)
    await read_frequencies(id)
    await database.close()


if(__name__ == "__main__"):
    asyncio.run(main())