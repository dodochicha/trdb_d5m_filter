
# # Import the necessary libraries
# from PIL import Image
# from numpy import asarray
 
 
# # load the image and convert into
# # numpy array
# img = Image.open('image.jpg')
 
# # asarray() class is used to convert
# # PIL images into NumPy arrays
# numpydata = asarray(img)
 
# # <class 'numpy.ndarray'>
# print(type(numpydata))
 
# #  shape
# print(numpydata.shape)
# # print(numpydata)
# for j in range(640):
#     print(numpydata[150][j][0], ' ', numpydata[150][j][1], ' ', numpydata[150][j][2])
import numpy as np
print(np.uint8(300))