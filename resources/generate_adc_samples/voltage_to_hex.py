import math

V_REF = 2.5 # Volts
def voltage_to_hex(voltage):
    return hex(math.floor(voltage / V_REF * (2 ** 12)))