import serial
import time
import aiosqlite
import asyncio
import aiofiles

BAUD_RATE = 2_000_000
F_RANG = 20

fpga_com = serial.Serial('COM5', BAUD_RATE, timeout=0)
database: aiosqlite.Connection = None

song_id_deltas = {}
scores = {}
output_record = aiofiles.open("output_records", mode = "w") 
output_row = aiofiles.open("output_row", mode = "w") 
    

async def find_song_by_hash(hash, time):
    global database, song_scores_by_offset, output_row, song_id_deltas
    cursor = await database.execute("SELECT hash, CAST(abs(? - time) as INTEGER) as delta_t, song_id FROM song_hashes WHERE hash = ?", [time, hash])
    rows = await cursor.fetchall();
    for i, (hash, delta_t, song_id) in enumerate(rows):
        if song_id not in song_id_deltas:
            song_id_deltas[song_id] = []
        else:
            song_id_deltas[song_id].append(delta_t)  
    await cursor.close()

constellation_map = []
async def make_1_hash (idx, time, freq):
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
        await find_song_by_hash(hash, time)

async def find_song():
    await asyncio.gather(*[make_1_hash(idx, time, freq) for idx, (time, freq) in enumerate(constellation_map)])  

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
async def read_frequencies ():
    try: 
        global data_from_FPGA, i, j, started, constellation_map
        while (data_from_FPGA != None or not started):
            data_from_FPGA = read_data()
            if data_from_FPGA:
                print("FREQuENCY:", data_from_FPGA)
                started = 1;
                constellation_map.append([time.perf_counter() * 10_000, data_from_FPGA])
                if(j == 2 * F_RANG):
                    await find_song()
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
    global database, scores, song_id_deltas
    database = await aiosqlite.connect("../train/shazam.db")

    await read_frequencies()

    for song_id in song_id_deltas.keys():
        scores_by_song_id = {}
        for song_id_1, delta_t in song_id_deltas.items():
            if(song_id_1 == song_id):
                for delta_t_1 in delta_t:
                    if delta_t_1 not in scores_by_song_id:
                        scores_by_song_id[delta_t_1] = 0
                    scores_by_song_id[delta_t_1] += 1
        maximum = (0, 0)
        for offset, score in scores_by_song_id.items():
            if score > maximum[1]:
                maximum = (offset, score)
        
        scores[song_id] = maximum;
    
    max_scores = sorted(scores.items(), key=lambda tup: tup[1][1], reverse=True)
    print(max_scores)
    best_match_id = max_scores[0][0]
    print("BEST MATCH ID:", best_match_id)

    cursor = await database.execute("SELECT name FROM songs WHERE id = ?", [int(best_match_id)])
    name = await cursor.fetchone()
    await database.close()
    print("THE BEST MATCH IS: ", name)


if(__name__ == "__main__"):
    asyncio.run(main())