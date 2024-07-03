import serial

BAUD_RATE = 2_000_000
fpga_com = serial.Serial('COM4', BAUD_RATE, timeout=0)


def read_data():
    reading = fpga_com.read(1)
    if (reading != b''):
        return ord(reading) * 2
    else:
        return None


samples = []
while 1:
    data = read_data()
    if data != None:
        print(data)


output = open("output.txt", "w")
print(samples, file=output)
