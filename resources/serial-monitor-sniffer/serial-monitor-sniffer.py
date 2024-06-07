import serial

BAUD_RATE = 2_000_000
fpga_com = serial.Serial('COM5', BAUD_RATE, timeout=0)

def read_data():
    reading = fpga_com.read(1)
    if(reading != b''):
        return ord(reading) * 2
    else:
        return None

samples = []
i = 0
while i < 1_000_000:
    data = read_data()
    # print("gathering...")
    if data != None: 
        i = i + 1
        print(data)

output = open("output.txt", "w")
print(samples, file=output)