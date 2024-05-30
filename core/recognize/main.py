import serial
import time
import aiosqlite
import asyncio

BAUD_RATE = 2_000_000
F_RANG = 50

fpga_com = serial.Serial('COM4', BAUD_RATE, timeout=0.1)

async def find_song_by_hash(hash, time):
    global database
    cursor = await database.execute("SELECT hash, abs(? - time), song_id FROM song_hashes WHERE hash = ?", [hash, time])
    rows = await cursor.fetchall();
    print(rows)
    await cursor.close()

constellation_map = []
async def make_1_hash (idx, time, freq):
    if(idx > F_RANG): 
        return; 
    # sampling at 25kHz
    upper_frequency = 12_500
    frequency_bits = 10
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
        # Place the frequencies (in Hz) into a 1024 bins
        freq_binned = (freq * 24) / upper_frequency * (2 ** frequency_bits)
        other_freq_binned = (other_freq * 24) / upper_frequency * (2 ** frequency_bits)
        print("BINNED FREQ:", freq_binned, other_freq)
        # Produce a 32 bit hash
        # Use bit shifting to move the bits to the correct location
        hash = int(freq_binned) | (int(other_freq_binned) << 10) | (int(diff) << 20)
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
                started = 1;
                constellation_map.append([time.perf_counter() * 10_000, data_from_FPGA])
                if(j == 2 * F_RANG):
                    await find_song()
                    print("RECOGNIZING...")
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
    database = await aiosqlite.connect("../train/shazam.db")

    await read_frequencies()
    await database.close()


if(__name__ == "__main__"):
    asyncio.run(main())