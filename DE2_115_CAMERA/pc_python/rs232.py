# #!/usr/bin/env python
# from __future__ import print_function
# from serial import Serial, EIGHTBITS, PARITY_NONE, STOPBITS_ONE
# from sys import argv


# assert len(argv) >= 2
# s = Serial(
#     port=argv[1],
#     baudrate=115200,
#     bytesize=EIGHTBITS,
#     parity=PARITY_NONE,
#     stopbits=STOPBITS_ONE,
#     xonxoff=False,
#     rtscts=False
# )



# # fp_key = open('key.bin', 'rb')
# # fp_enc = open('enc.bin', 'rb')
# # fp_dec = open('dec.bin', 'wb')
# fp_key = open('golden/key.bin', 'rb')
# fp_enc = open('golden/cipher_20240329.bin', 'rb')
# fp_dec = open('../output_files/dec_cipher_20240329.bin', 'wb')
# assert fp_key and fp_enc and fp_dec

# key = fp_key.read(64)
# enc = fp_enc.read()

# assert len(enc) % 32 == 0
# len_enc = len(enc) // 32


# s.write(key)
# for i in range(0, len(enc), 32): #32*len(enc)
#     s.write(enc[i:i+32]) 8*32 bit
#     dec = s.read(31) #8*31 bit
#     print(dec.decode("utf-8"), end="")
#     fp_dec.write(dec) 


# fp_key.close()
# fp_enc.close()
# fp_dec.close()
#!/usr/bin/env python
from serial import Serial, EIGHTBITS, PARITY_NONE, STOPBITS_ONE
from sys import argv
import numpy as np
from PIL import Image

assert len(argv) >= 2
print('hello')
s = Serial(
    port=argv[1],
    baudrate=115200,
    bytesize=EIGHTBITS,
    parity=PARITY_NONE,
    stopbits=STOPBITS_ONE,
    xonxoff=False,
    rtscts=False
)

img_array = np.empty([480, 640, 3], dtype=np.uint8)
for i in range(480):
    for j in range(640):
        print('i,j= ', i, ' ', j)
        dec = s.read(3)
        dec = int.from_bytes(dec, "big")
        # dec = 256*256*25+256*15+5
        # print('dec:', dec)
        r = dec % 256
        dec = dec // 256
        g = dec % 256
        b = dec // 256
        print("rgb:", r, ' ', g, ' ', b)
        img_array[i][j][0] = np.uint8(r)
        img_array[i][j][1] = np.uint8(g)
        img_array[i][j][2] = np.uint8(b)

for i in range(30):
    for j in range(4):
        integer_val = j*8
        print(integer_val.to_bytes(2, 'big'))
        s.write(integer_val.to_bytes(2, 'big'))
img = Image.fromarray(img_array, "RGB") 
img.save(f'image.jpg')
for i in range(100):
    print(img_array[150][i][0], ' ', img_array[150][i][1], ' ', img_array[150][i][2])

