#!/usr/bin/env python
from serial import Serial, EIGHTBITS, PARITY_NONE, STOPBITS_ONE
from sys import argv
import numpy as np
from PIL import Image
from ultralytics import YOLO

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

# Load a model
model = YOLO('yolov8s.yaml')  # load an official model
model = YOLO('pt/best_s.pt')  # load a custom model

while True:
    img_array = np.empty([480, 640, 3], dtype=np.uint8)
    for i in range(480):
        for j in range(640):
            print('i,j= ', i, ' ', j)
            dec = s.read(3)
            dec = int.from_bytes(dec, "big")
            r = dec % 256
            dec = dec // 256
            g = dec % 256
            b = dec // 256
            print("rgb:", r, ' ', g, ' ', b)
            img_array[i][j][0] = np.uint8(r)
            img_array[i][j][1] = np.uint8(g)
            img_array[i][j][2] = np.uint8(b)

    # save the image
    img = Image.fromarray(img_array, "RGB") 
    img.save(f'image.jpg')

    # predict
    results = model("image.jpg",
                    project='predict',
                    save=True,
                    exist_ok=True,
                    imgsz = (480, 640), #  (height, width)
                    device = 'cpu',
                    max_det = 15,
                    conf = 0.02,
                    iou = 0)

    for fore in results[0].boxes.data:
        print(int(fore[0]),int(fore[1]),int(fore[2]),int(fore[3]))

    fore_array = []
    for i in range(15):
        if i <= len(results[0].boxes.data)-1:
            for fore in results[0].boxes.data:
                for j in range(4):
                    for k in range(2):
                        if k == 0:
                            x = int(fore[j]) // 256
                            print(int(fore[j]), ' ', x)
                            fore_array.append(x)
                        else:
                            y = int(fore[j]) % 256
                            print(int(fore[j]), ' ', y)
                            fore_array.append(y)
        else:
            for j in range(8):
                fore_array.append(66)
    print(len(fore_array))
    print(fore_array)

    for i in range(120):
        s.write([fore_array[i]])
    print('pass')




