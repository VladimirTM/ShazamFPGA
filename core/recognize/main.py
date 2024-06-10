import serial
import time
import aiosqlite
import asyncio

BAUD_RATE = 2_000_000
F_RANG = 10

fpga_com = serial.Serial('COM4', BAUD_RATE, timeout=0.1)

database: aiosqlite.Connection = None

song_id_deltas = {}


async def find_song_by_hash(hash, time):
    global database, song_id_deltas
    cursor = await database.execute("SELECT hash, CAST(abs(? - time) as INTEGER) as delta_t, song_id FROM song_hashes WHERE hash = ?", [time, hash])
    rows = await cursor.fetchall()
    for i, (hash, delta_t, song_id) in enumerate(rows):
        if song_id not in song_id_deltas:
            song_id_deltas[song_id] = []
        else:
            song_id_deltas[song_id].append(delta_t)
    await cursor.close()


def find_max_delta_t():
    global song_id_deltas
    scores = {}
    for song_id in song_id_deltas.keys():
        scores_by_song_id = {}
        for song_id_1, delta_t in song_id_deltas.items():
            if (song_id_1 == song_id):
                for delta_t_1 in delta_t:
                    if delta_t_1 not in scores_by_song_id:
                        scores_by_song_id[delta_t_1] = 0
                    scores_by_song_id[delta_t_1] += 1
        maximum = (0, 0)
        for offset, score in scores_by_song_id.items():
            if score > maximum[1]:
                maximum = (offset, score)

        scores[song_id] = maximum
    return scores


def read_single_data():
    global fpga_com
    reading = fpga_com.read(1)
    if (reading != b''):
        return ord(reading) * 2
    else:
        return None


def read_data():
    TOL = 20
    state = 0
    cnt = 0
    while state != 2:
        b = read_single_data()
        if b is not None:
            cnt = 0
            if state == 0:
                state = 1
            if b:
                yield b
        elif state == 1:
            cnt = cnt + 1
            if cnt == TOL:
                state = 2


def generate_hashes(constellation_map, window_size):
    hashes = {}

    for i, (ts, f) in enumerate(constellation_map):
        for ots, of in constellation_map[i:i+window_size]:
            diff = ots - ts
            if diff <= 1:
                continue
            if diff > 4095:
                print("Difference greater than saveable")
                continue

            h = f | (of << 10) | (diff << 20)
            hashes[h] = ts

    return hashes.items()


def read_frequencies():
    PEAK_SIZE = 10
    BATCH_SIZE = 100
    ts = None
    constellation_map = []
    for i, f in enumerate(read_data()):
        if i % BATCH_SIZE == 0 and ts is not None:
            yield from generate_hashes(constellation_map, PEAK_SIZE * 2)
            constellation_map = []
        if i % PEAK_SIZE == 0:
            ts = int(time.perf_counter() * 1_000)
        print(f"{str(i).rjust(9, ' ')}: {int(f * 24.41)}hz @ {ts}ms")
        constellation_map.append([ts, f])


async def find_hashes(hashes):
    for h, ts in hashes:
        await find_song_by_hash(h, ts)


def parse_int(s):
    try:
        return int(s)
    except:
        return None


BAUD_RATE = 2_000_000


async def main():
    global database
    database = await aiosqlite.connect("../train/shazam.db")

    await find_hashes(read_frequencies())
    scores = find_max_delta_t()

    print("SCORES:", scores)

    await database.close()

if (__name__ == "__main__"):
    asyncio.run(main())
