import serial

BAUD_RATE = 115200
fpga_com = serial.Serial('COM3', BAUD_RATE, timeout=0.1)

def read_data():
    return fpga_com.read(3);

while 1:
    print("DATA FORM FPGA:", read_data());
