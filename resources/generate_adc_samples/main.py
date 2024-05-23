import random
from voltage_to_hex import voltage_to_hex

adc_measurements_file = open('../../fpga/adc_simulation_measurements/adc_simulation_measurements.txt', 'w')
adc_measurements_hex_file = open('adc-simulation-measurements-hex.txt', 'w')

for i in range (0, 1024 * 64 - 1):
    random_float = random.random()
    adc_measurements_file.write(f"{i} {random_float}\n")
    adc_measurements_hex_file.write(f"{i} {voltage_to_hex(random_float)}\n")

adc_measurements_file.close()
adc_measurements_hex_file.close()