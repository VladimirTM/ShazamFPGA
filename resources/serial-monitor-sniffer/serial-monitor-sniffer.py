import serial

BAUD_RATE = 2_000_000
fpga_com = serial.Serial('COM4', BAUD_RATE, timeout=0.1)

def read_data():
    reading = fpga_com.read(1)
    if(reading):
        return ord(reading) * 2
    else:
        return None

samples = []
i = 0
while i < 10_000:
    data = read_data()
    # print("gathering...")
    if data: 
        samples.append(data)
        i = i + 1
    

print("SAMPLES:", samples)
