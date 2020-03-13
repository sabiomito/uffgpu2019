# -*- coding: utf-8 -*-
"""PROJETO.ipynb

Automatically generated by Colaboratory.

Original file is located at
    https://colab.research.google.com/drive/1EYCcal_iMni-pld98uKIXJ2NYGLaJk9G
"""

# Commented out IPython magic to ensure Python compatibility.
!git clone https://github.com/sabiomito/uffgpu2019.git
# %cd uffgpu2019
!git checkout master

# %cd PROJETO
!mkdir animatedFolder

def fazEntrada(tam,show):
  from random import randint
  from random import seed
  arquivo = open('entrada.txt', 'w')
  data = []
  for i in range(tam):
    dt = []
    for j in range(tam):
      if(j<tam/20):#(j>tam/2-5 and j<tam/2+4):# and i>128 and i<1024-128):# or (j>120 and j<130 and i >120 and i<130)):
        dt.append(3)
      else:
        dt.append(0)
      
    data.append(dt)


  #seed(30)
  #for i in range(tam):
  #  data[randint(0,tam-1)][randint(0,tam-1)] = 3


  for i in range(tam):
    txt = ""
    for j in range(tam):
      txt+=" "+str(data[i][j])
    arquivo.write(txt+"\n")
  arquivo.close()


  from matplotlib import pyplot as plt
  arquivo = open('entrada.txt', 'r')
  img = []
  for linha in arquivo:
      img.append(list(map(int,linha.split())))
  #print(img)
  arquivo.close()
  plt.imshow(img,cmap='plasma')
  if(show):
    plt.show()
fazEntrada(512,True)

import os
def compile(steps):
  !nvcc 2DstencilGPUSharedMemoryKarma.cu  -o go -D MODEL_WIDTH=1024
  string = "./go "+str(steps)
  print(string)
  os.system(string)
  #!./go steps

def compile0(size,steps,blockX,blockY):
  string = "nvcc 2DstencilGPUSharedMemoryKarma.cu  -o go -D MODEL_WIDTH="+str(size)+" BLOCKDIM_Y="+str(blockY)+" BLOCKDIM_X="+str(blockX)
  print(string)
  os.system(string)
  string = "./go "+str(steps)
  print(string)
  os.system(string)
  #!./go steps


def compile2(size,order,steps):
  !nvcc 2DstencilGPUSharedMemoryKarmaSpaceTimeBlocking.cu  -o go
  string = "./go "+str(size)+" "+str(order)+" "+str(steps)
  print(string)
  os.system(string)
  #!./go steps

def compile3(size,order,steps):
  !nvcc 2DstencilGPUSharedMemoryKarmaSpaceTimeBlockingTimeTest.cu  -o go -D MODEL_WIDTH=1024
  string = "./go "+str(size)+" "+str(order)+" "+str(steps)
  print(string)
  os.system(string)
  #!./go steps

def compile4(size,order,steps):
  string = "nvcc 2DstencilGPUSharedMemoryKarmaSpaceTimeBlockingTimeTest.cu  -o go -D MODEL_WIDTH="+str(size)
  print(string)
  os.system(string)
  string = "./go "+str(size)+" "+str(order)+" "+str(steps)
  print(string)
  os.system(string)
  #!./go steps

def compile_TimeTest_blocksDim(size,order,steps,BX,BY):
  string = "nvcc 2DstencilGPUSharedMemoryKarmaSpaceTimeBlockingTimeTest.cu  -o go -D MODEL_WIDTH="+str(size)
  print(string)
  os.system(string)
  string = "./go "+str(size)+" "+str(order)+" "+str(steps)+" "+str(BX)+" "+str(BY)
  print(string)
  os.system(string)
  #!./go steps

def show():
  arquivo = open('resultado.txt', 'r')
  img = []
  for linha in arquivo:
    img.append(list(map(float,linha.split())))
  arquivo.close()
  plt.imshow(img,cmap='plasma')
  plt.show()
  return img

def show2(tam):
  arquivo = open('resultado.txt', 'r')
  img = []
  lin = []
  cont = 0
  for linha in arquivo:
    lin.append(list(map(float,linha.split()))[0])
    cont+=1
    #print("len"+str(len(lin)))
    if(cont==tam):
      img.append(lin)
      lin = []
      cont=0
  arquivo.close()
  plt.imshow(img,cmap='plasma')
  plt.show()
  return img
  #for i in img:
  #  print(i)

from matplotlib import pyplot as plt
def saveToGif(t):
  arquivo = open('resultado.txt', 'r')
  img = []
  for linha in arquivo:
    img.append(list(map(float,linha.split())))
  arquivo.close()
  plt.imshow(img,cmap='plasma')
  name = "animatedFolder/animated"+str(t)
  plt.savefig(name)
  return(name+".png")
  #plt.show()

!nvcc 3DstencilCPU.cpp  -o go
!./go

!nvcc 3DstencilGPUGlobalMemory.cu  -o go
!./go 512 512 160 2

#0.59546
!nvcc 3DstencilGPUSharedMemory.cu -o go
!./go 32 32 4

!nvcc 3DstencilGPUGlobalMemoryCpuBorder.cu  -o go
!./go 4 4 2 4

!nvcc 3DstencilGPUMiciquevicious.cu  -o go
!./go 16 16 80 4

!nvcc 3DstencilGPUGlobalMemoryCube.cu  -o go
!./go 16 16 16 4

!gcc 2DstencilCPU.cpp -o go
!./go 64 2 8

!nvcc 2DstencilGPUGlobalMemory.cu  -o go
!./go 64 8 1

!nvcc 2DstencilGPUGlobalMemoryCPUBorder.cu  -o go
!./go 4096 8 4

!nvcc 2DstencilGPUGlobalMemoryBlankBorder.cu  -o go
!./go 64 2 30

!nvcc 2DstencilGPUSharedMemoryBlankBorder.cu  -o go
!./go 4096 16 32

!nvcc 2DstencilGPUSharedMemoryBlankBorderTimeSpaceSharing.cu  -o go
!./go 4096 2 3 32 32

!nvcc 2DstencilGPUGlobalMemoryBlankBorder.cu -o runGlobal && nvcc 2DstencilGPUSharedMemoryBlankBorder.cu -o runShared && nvcc 2DstencilGPUSharedMemoryBlankBorderTimeSpaceSharing.cu -o runTime && ./runGlobal 4096 4 1 > Global_4096_4.txt && echo 4096 4 1 && ./runGlobal 4096 4 2 >> Global_4096_4.txt && echo 4096 4 2 && ./runGlobal 4096 4 3 >> Global_4096_4.txt && echo 4096 4 3 && ./runGlobal 4096 4 4 >> Global_4096_4.txt && echo 4096 4 4 && ./runGlobal 4096 4 5 >> Global_4096_4.txt && echo 4096 4 5 && ./runGlobal 4096 4 6 >> Global_4096_4.txt && echo 4096 4 6 && ./runGlobal 4096 4 7 >> Global_4096_4.txt && echo 4096 4 7 && ./runGlobal 4096 4 8 >> Global_4096_4.txt && echo 4096 4 8 && ./runGlobal 4096 4 9 >> Global_4096_4.txt && echo 4096 4 9 && ./runGlobal 4096 4 10 >> Global_4096_4.txt && echo 4096 4 1 && ./runGlobal 4096 4 11 >> Global_4096_4.txt && echo 4096 4 1 && ./runShared 4096 4 1 > Shared_4096_4.txt && echo 4096 4 1 && ./runShared 4096 4 2 >> Shared_4096_4.txt && echo 4096 4 2 && ./runShared 4096 4 3 >> Shared_4096_4.txt && echo 4096 4 3 && ./runShared 4096 4 4 >> Shared_4096_4.txt && echo 4096 4 4 && ./runShared 4096 4 5 >> Shared_4096_4.txt && echo 4096 4 5 && ./runShared 4096 4 6 >> Shared_4096_4.txt && echo 4096 4 6 && ./runShared 4096 4 7 >> Shared_4096_4.txt && echo 4096 4 7 && ./runShared 4096 4 8 >> Shared_4096_4.txt && echo 4096 4 8 && ./runShared 4096 4 9 >> Shared_4096_4.txt && echo 4096 4 9 && ./runShared 4096 4 10 >> Shared_4096_4.txt && echo 4096 4 1 && ./runShared 4096 4 11 >> Shared_4096_4.txt && echo 4096 4 1 && ./runTime 4096 4 1 > Time_4096_4.txt && echo 4096 4 1 && ./runTime 4096 4 2 >> Time_4096_4.txt && echo 4096 4 2 && ./runTime 4096 4 3 >> Time_4096_4.txt && echo 4096 4 3 && ./runTime 4096 4 4 >> Time_4096_4.txt && echo 4096 4 4 && ./runTime 4096 4 5 >> Time_4096_4.txt && echo 4096 4 5 && ./runTime 4096 4 6 >> Time_4096_4.txt && echo 4096 4 6 && ./runTime 4096 4 7 >> Time_4096_4.txt && echo 4096 4 7 && ./runTime 4096 4 8 >> Time_4096_4.txt && echo 4096 4 8 && ./runTime 4096 4 9 >> Time_4096_4.txt && echo 4096 4 9 && ./runTime 4096 4 10 >> Time_4096_4.txt && echo 4096 4 1 && ./runTime 4096 4 11 >> Time_4096_4.txt && echo 4096 4 1

from matplotlib import pyplot as plt
arquivo = open('resultado.txt', 'r')
img = []
for linha in arquivo:
  img.append(list(map(float,linha.split())))
arquivo.close()
plt.imshow(img,cmap='plasma')
plt.show()

import imageio
'''
filenames = []
for i in range(1,12000,200):
  compile(i)
  filenames.append(saveToGif(i))
images = []
for filename in filenames:
    images.append(imageio.imread(filename))
imageio.mimsave('animatedFolder/animated0.gif', images)
max 21 times
'''

for times in range(1,21,1):
  filenames = []
  for i in range(1,19000,200):
    compile2(96,times,i)
    filenames.append(saveToGif(i))
  images = []
  for filename in filenames:      
      images.append(imageio.imread(filename))
  imageio.mimsave('animatedFolder/animated0'+str(times)+'.gif', images)

import imageio
'''
filenames = []
for i in range(1,50000,500):
  !nvcc 2DstencilGPUSharedMemoryKarmaSpaceTimeBlockingSpiralSimulation.cu  -o go -D MODEL_WIDTH=256
  string = "./go 256 1 "+str(i)
  print(string)
  os.system(string)
  img = show()
  filenames.append(saveToGif(i))
images = []
for filename in filenames:      
    images.append(imageio.imread(filename))
imageio.mimsave('animatedFolder/animatedSpiral.gif', images)
'''
'''
import imageio
for size in range(64,800,32):
  fazEntrada(size,False)
  filenames = []
  for i in range(1,19000,400):
    compile4(size,15,i)
    filenames.append(saveToGif(i))
  images = []
  for filename in filenames:      
      images.append(imageio.imread(filename))
  imageio.mimsave('animatedFolder/animated0'+str(size)+'.gif', images)
'''
'''
for i in range(32,800,32):
  print("Entrada ")
  fazEntrada(i,False)
  compile4(i,15,6000)
'''
'''
for i in range(15):
  !nvcc 2DstencilGPUSharedMemoryKarmaSpaceTimeBlockingSpiralSimulation.cu  -o go -D MODEL_WIDTH=256
  string = "./go 256 "+str(i)+" 12000"
  print(string)
  os.system(string)
  img = show()
'''

'''
fazEntrada(256,False)
!nvcc 2DstencilGPUSharedMemoryKarmaSpaceTimeBlockingSpiralSimulation.cu  -o go -D MODEL_WIDTH=256
!./go 256 9 21000
img = show()
'''

X,Y = 4,5
!nvcc 2DstencilGPUSharedMemoryKarmaSpaceTimeBlockingSpiralSimulation.cu  -o go -D MODEL_WIDTH=256
fazEntrada(256,False)
images = []
qt = 21000/(Y*X)
for i in range(1,21001,int(qt)):
  string = "./go 256 9 "+str(i)
  print(string)
  os.system(string)
  images.append(show())


f, axarr = plt.subplots(Y,X,figsize=(X,Y))
for x in range(X):
  for y in range(Y):
    axarr[y,x].imshow(images[x+X*y])
    axarr[y,x].axis('off')
    axarr[y,x].axis('image')
    axarr[y,x].axis("tight")
    #axarr[y,x].set_cmap('seismic')


plt.set_cmap('jet')

#.add_axes(ax)
plt.savefig("test.png", dpi=1200)
plt.show()


'''
axarr[0,0].imshow(image_datas[0])
axarr[0,1].imshow(image_datas[1])
axarr[1,0].imshow(image_datas[2])
axarr[1,1].imshow(image_datas[3])
'''

fazEntrada(2048,True)
#!nvcc 2DstencilGPUSharedMemoryKarmaSpaceTimeBlockingSpiralSimulation.cu  -o go -D MODEL_WIDTH=256
#! ./go 256 15 50000
#compile_TimeTest_blocksDim(256,15,8000,64,16)
#compile0(256,8000,32,32)


!nvcc 2DstencilGPUSharedMemoryKarma.cu  -o go -D MODEL_WIDTH=2048 -D BLOCKDIM_Y=32 -D BLOCKDIM_X=32
!./go 20000
#img = show()


#sharedSize = 2 => 15552
!nvcc 2DstencilGPUSharedMemoryKarmaSpaceTimeBlocking.cu  -o go -D MODEL_WIDTH=2048
!./go 2048 1 20000 32 32
!./go 2048 2 20000 32 32
!./go 2048 3 20000 32 32

img = show()
'''
!./go 768 2 8000 32 32
!./go 768 3 8000 32 32
!./go 768 4 8000 32 32
!./go 768 5 8000 32 32
!./go 768 6 8000 32 32
!./go 768 7 8000 32 32
!./go 768 8 8000 32 32
!./go 768 9 8000 32 32
!./go 768 10 8000 32 32
!./go 768 11 8000 32 32
!./go 768 12 8000 32 32
!./go 768 13 8000 32 32
!./go 768 14 8000 32 32
!./go 768 15 8000 32 32
!./go 768 16 8000 32 32
'''
!free -m

img = show()

import imageio
for filename in filenames:      
    images.append(imageio.imread(filename))
imageio.mimsave('animatedFolder/animatedSpiral.gif', images)

#!nvcc 2DstencilGPUSharedMemoryKarmaSpaceTimeBlockingTimeTest.cu  -o go -D MODEL_WIDTH=256
#! ./go 256 15 4000
#img = show()
import imageio

for size in range(768,800,32):
  for times in range(1,17,1):
    fazEntrada(size,False)
    #compile0(size,19000)
    compile4(size,times,19000)

from matplotlib import pyplot as plt
arquivo = open('entrada.txt', 'r')
img = []
for linha in arquivo:
    img.append(list(map(int,linha.split())))
#print(img)
arquivo.close()
plt.imshow(img,cmap='plasma')
plt.show()

#for i in range(1,30,1):
compile(12000)
img = show()
for i in range(1,21,1):
  compile3(1024,i,12000)
  img = show()

!git checkout -- .

for i in img:
  print(i)

!rm -R uffgpu2019/

!nvidia-smi

!nvcc 2DstencilGPUSharedMemoryBlankBorderTimeSpaceSharingOpencvKarma.cu -o go `pkg-config --cflags --libs opencv` -w
!./go 32 2 1

combinations = []
combinations.append((2,1))
for X in range(1,1024):
  for Y in range(1,1024):
    if((X*Y)%32==0 and ((X*Y)==1024 or(X*Y)==512 or (X*Y)==128 or (X*Y)==64) and X%4==0 and Y%4==0 and not((Y,X) in combinations)):
      combinations.append((X,Y))
      print(X,Y)


for comb in combinations:
  print("\n\\addplot[\ncolor=red,\nmark=triangle,\n]\ncoordinates {")
  for times in range(1,30):
    print("(",times,",",(((comb[0] + (2 * times)) * (comb[1] + (2 * times))) * 4 * 3),")");
  print("};")


print("\legend{",end="")
for comb in combinations:
  print(comb[0],"X",comb[1],",",end="");
print("};")

blockSizes = []
blockSizes.append((4 , 4))
blockSizes.append((4, 8))
blockSizes.append((4, 16))
blockSizes.append((4, 32))
blockSizes.append((4, 128))
blockSizes.append((4, 256))
blockSizes.append((8, 8))
blockSizes.append((8, 16))
blockSizes.append((8, 64))
blockSizes.append((8, 128))
blockSizes.append((8, 256))
blockSizes.append((16, 32))
blockSizes.append((16, 64))
blockSizes.append((32, 32))
print(blockSizes)

timeSteps = list(range(1,15))
print(timeSteps)

dominios = []
dominios.append((256,256))
dominios.append((512,512))
dominios.append((1024,1024))
dominios.append((2048,2048))
dominios.append((4096,4096))
dominios.append((8192,8192))

print(dominios)

arquivo = open('graficosParaPlotar.txt', 'wt')
arquivo.write("\n-----------\n")
arquivo.write("\n-----------\n")
arquivo.write("\n blockSizes\n"+str(blockSizes)+"\n")
arquivo.write("\n timeSteps\n"+str(timeSteps)+"\n")
arquivo.write("\n dominios\n"+str(dominios)+"\n")

print(dominios[0][0])

import subprocess


for domain in dominios:
  arquivo.write("\n\n\n DOMINIO "+str(domain[0])+"x"+str(domain[0])+"\n\n")
  print("\n\n\n DOMINIO "+str(domain[0])+"x"+str(domain[0])+"\n\n")
  fazEntrada(domain[0],False)

  for blockSize in blockSizes:
    comado = "nvcc 2DstencilGPUSharedMemoryKarma.cu  -o go -D MODEL_WIDTH=+"+str(domain[0])+" -D BLOCKDIM_Y=+"+str(blockSize[0])+" -D BLOCKDIM_X="+str(blockSize[1])
    os.system(comado)
    x = subprocess.check_output(["./go", "8000"])
    arquivo.write(str(blockSize)+str(x).split("'")[1]+"\n")
    print(str(blockSize)+str(x).split("'")[1]+"\n")

  for blockSize in blockSizes:
    arquivo.write("----------\n\n"+str(blockSize)+"\n\n")
    print("----------\n\n"+str(blockSize)+"\n\n")
    for times in timeSteps:
      comado = "nvcc 2DstencilGPUSharedMemoryKarmaSpaceTimeBlocking.cu  -o go -D MODEL_WIDTH=+"+str(domain[0])
      os.system(comado)
      x = subprocess.check_output(["./go", str(domain[0]),str(times),str(8000),str(blockSize[0]),str(blockSize[1])])
      arquivo.write(str(x).split("'")[1]+"\n")
      print(str(x).split("'")[1]+"\n")

x = subprocess.check_output(["nvidia-smi"])
arquivo.write(str(x))
arquivo.close()