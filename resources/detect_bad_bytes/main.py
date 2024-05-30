# Demonstrated Python Program
# to read file character by character
file = open('../../fpga/data/arduino_64_pause/output.txt', 'r')

a = None 
b = None 
c = None 
d = None 
e = None 

mistakes = 0
mistake_positions = []
i = 0
while 1:
    # read by character
    a = file.read(1)
    b = file.read(1)
    c = file.read(1)
    d = file.read(1)
    if not a or not b or not c or not d or not e: 
        break
    if(a == '0' and b == '1' and c == '2' and d == '3' and e == '4'):
        1
    else:
        mistakes = mistakes + 1
        mistake_positions.append(i)
    
    i = i + 5
 
file.close()
print("MISTAKES:", mistakes)
print("AT LOCATIONS:", mistake_positions)