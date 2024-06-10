import numpy as np
from scipy.fftpack import fft, fftfreq
from numpy import linspace
import matplotlib.pyplot as plt
import csv

# CONSTANTS:
FFT_SIZE = 1024
SAMPLING_RATE = 10_000


# HELPERS:
def read_samples_from_file(file_path):
    samples = []
    with open(file_path, 'r') as file:
        # Creating a csv reader object
        reader = csv.reader(file)
        for row in reader:
            samples = list(map(lambda x: float(x) if x != '' else 0, row))
    return samples


def try_find_peaks(data, number_of_peaks_to_find):
    peaks = []
    for i in range(0, number_of_peaks_to_find):
        maximum = max(list(data))
        maximum_index = list(data).index(maximum)
        data[maximum_index] = 0
        peaks.append({"value": maximum, "index": maximum_index})
    return peaks


x = linspace(0, FFT_SIZE, FFT_SIZE)[:FFT_SIZE//2]


def make_FFT(samples, sampling_rate, start=0):
    normalized_samples = samples[start:start + FFT_SIZE - 1]

    y = fft(normalized_samples, FFT_SIZE)

    x = fftfreq(1024, 1/sampling_rate)[:FFT_SIZE//2]

    magnitude = np.abs(y[:FFT_SIZE // 2])
    return magnitude, x


def plot_FFT(magnitudes, x, title):
    plt.figure()
    plt.xlabel("Frequency (Hz)")
    plt.title(title)
    plt.plot(x, magnitudes, label="Spectrum")
    detected_maximas = np.array(try_find_peaks(magnitudes, 16))
    plt.scatter(np.array(list(map(lambda max_index_pair: max_index_pair["index"], detected_maximas))), list(map(
        lambda max_index_pair: max_index_pair["value"], detected_maximas)), color="y", zorder=10, label="My Marker")
    return list(sorted(map(lambda max_index_pair: max_index_pair["index"], detected_maximas)))


# ANALYZE DATA FROM INPUT USING PYTHON FFT:
arduino_input_path = '../../fpga/test/data/inputs/arduino.txt'
arduino_samples = read_samples_from_file(arduino_input_path)
print("Length arduino_samples_barely_holding_on_v2", len(arduino_samples))

for i in range(0, 5):
    magnitudes_0, x_0 = make_FFT(arduino_samples, SAMPLING_RATE, 512 * i)
    max_frequencies_0 = plot_FFT(magnitudes_0, x, f"PYTHON FFT: {i}")
    print(f"MAX FREQUENCIES DETECTED IN: {i}",
          list(sorted(max_frequencies_0)))

# ANALYZE DATA FROM FPGA INPUT USING PYTHON FFT:
fpga_input_path = '../../fpga/quartus/fpga_input.csv'


# ANALYZE THE MAGNITUDES COMING FROM THE FFT SIMULATION:
verilog_magnitudes_path = "../../fpga/test/1024pt_16bit/data/arduino/magnitudes.txt"
verilog_magnitudes = read_samples_from_file(verilog_magnitudes_path)[0:512]

print("LENGTH OF VERILOG FFT FIRST HALF: ", len(verilog_magnitudes))
max_frequencies_verilog_0 = plot_FFT(
    verilog_magnitudes, x, "VERILOG FFT FIRST HALF")
print("VERILOG MAX FREQUENCIES FIRST HALF:", max_frequencies_verilog_0)
plt.show()
