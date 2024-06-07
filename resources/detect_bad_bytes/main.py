file = open('./pause_31/output.txt', 'r')

a = None 
b = None 
c = None 
d = None 
e = None

mistakes = 0
mistake_positions = []
i = 0
has_seen_zero = 0

while 1:
    # read by character
    a = '0' if has_seen_zero else file.read(1)
    if(has_seen_zero): 
        has_seen_zero = 0
    b = file.read(1)
    c = file.read(1)
    d = file.read(1)
    e = file.read(1)

    print(a,b,c,d,e)
    
    i = i + 5
    if not a or not b or not c or not d or not e: 
        break
    if(a == '0' and b == '2' and c == '4' and d == '6' and e == '8'):
        1
    else:
        mistakes = mistakes + 1
        mistake_positions.append(i)
        while(file.read(1) != '0'):
            i = i + 1
            has_seen_zero = 1
 
file.close()
print("MISTAKES:", mistakes, " OUT OF: ", i)
print("AT LOCATIONS:", mistake_positions)