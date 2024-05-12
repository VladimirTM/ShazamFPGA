def hex_to_decimal(hex_str):
    return int(hex_str, 16)

def convert_hex_file_to_decimal(file_path):
    with open(file_path, 'r') as file:
        hex_values = file.read().split(',')
        decimal_values = []
        for hex_value in hex_values:
            decimal_value = hex_to_decimal(hex_value.strip())
            if(decimal_value > 300 or decimal_value < 20):
                print(decimal_value, " was a result of: ", hex_value)
            else:
                decimal_values.append(decimal_value);
            
        return decimal_values

def write_decimals_to_file(decimal_values, output_file_path):
    with open(output_file_path, 'w') as output_file:
        for decimal_value in decimal_values:
            output_file.write(str(decimal_value) + ',')

input_file_path = '../../arduino/captured_data/microphone_data_in.txt'  # Path to your file containing hex values separated by commas
output_file_path = 'arduino_data_decimal_form.txt'  # Path to the output file

decimal_values = convert_hex_file_to_decimal(input_file_path)
write_decimals_to_file(decimal_values, output_file_path)
print("Decimal values have been written to", output_file_path)