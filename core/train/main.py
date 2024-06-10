import serial
import time
import aiosqlite
import asyncio
import sys

fpga_com: serial.Serial = None


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


async def load_hashes_to_db(db: aiosqlite.Connection, song_id, hashes):
    for h, ts in hashes:
        await db.execute_insert("INSERT INTO song_hashes (hash, time, song_id) VALUES (?, ?, ?)", [h, ts, song_id])


def parse_int(s):
    try:
        return int(s)
    except:
        return None


BAUD_RATE = 2_000_000


async def main():
    global fpga_com
    database = await aiosqlite.connect("shazam.db")
    fpga_com = serial.Serial('COM4', BAUD_RATE, timeout=0.1)

    name_or_id = input("Input new song name or existing song ID: ")
    in_id = parse_int(name_or_id)
    id = None

    if in_id is not None:
        cursor = await database.execute("SELECT id FROM songs WHERE songs.id = ?", [in_id])
        res = await cursor.fetchone()
        if res:
            id = res[0]
    else:
        song_name = name_or_id
        cursor = await database.execute("SELECT id FROM songs WHERE songs.name = ?", [song_name])
        res = await cursor.fetchone()
        await cursor.close()
        if res:
            id = res[0]
            print(f"\nDeleting data for \"{song_name}\"...", file=sys.stderr)
            await database.execute("DELETE FROM songs WHERE songs.id = ?", [id])
            await database.commit()
        else:
            print("New song!", file=sys.stderr)
        cursor = await database.execute("INSERT INTO songs (name) VALUES (?) RETURNING id", [song_name])
        res = await cursor.fetchone()
        id = res[0]
        await database.commit()

    if id is None:
        print("The song was not found", file=sys.stderr)
        sys.exit(1)

    print(f"Song ID: {id}", file=sys.stderr)

    await load_hashes_to_db(database, id, read_frequencies())
    await database.commit()
    await database.close()


if (__name__ == "__main__"):
    asyncio.run(main())
