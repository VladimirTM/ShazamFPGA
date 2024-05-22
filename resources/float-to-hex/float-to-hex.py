import struct

def float_to_hex(f):
    # Pack the float into a binary string (32 bits)
    binary_string = struct.pack('<f', f)
    
    # Unpack the binary string as an integer
    integer_value = struct.unpack('<I', binary_string)[0]
    
    # Convert the integer to a hexadecimal string
    hex_string = hex(integer_value)
    
    return hex_string

# Example usage:
float_value = -0.4234
hex_representation = float_to_hex(float_value)
print(f"Float {float_value} as hex: {hex_representation}")
