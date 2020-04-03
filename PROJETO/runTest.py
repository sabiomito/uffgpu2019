# -*- coding: utf-8 -*-


def printColored(blabla):
  print('\x1b[7;32;41m' + blabla + '\x1b[0m')

printColored("teste..!!")

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

  for i in range(tam):
    txt = ""
    for j in range(tam):
      txt+=" "+str(data[i][j])
    arquivo.write(txt+"\n")
  arquivo.close()

fazEntrada(512,False)

import os


def compile0(size,steps,blockX,blockY):
  string = "nvcc 2DstencilGPUSharedMemoryKarma.cu  -o go -D MODEL_WIDTH="+str(size)+" BLOCKDIM_Y="+str(blockY)+" BLOCKDIM_X="+str(blockX)
  print(string)
  os.system(string)
  string = "./go "+str(steps)
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


'''

fazEntrada(2048,True)
#!nvcc 2DstencilGPUSharedMemoryKarmaSpaceTimeBlockingSpiralSimulation.cu  -o go -D MODEL_WIDTH=256
#! ./go 256 15 50000
#compile_TimeTest_blocksDim(256,15,8000,64,16)
#compile0(256,8000,32,32)

string = "nvcc 2DstencilGPUSharedMemoryKarma.cu  -o go -D MODEL_WIDTH=2048 -D BLOCKDIM_Y=32 -D BLOCKDIM_X=32"
print(string)
os.system(string)
string = "./go 20000"
os.system(string)

string = "nvcc 2DstencilGPUSharedMemoryKarmaSpaceTimeBlocking.cu  -o go -D MODEL_WIDTH=2048"
print(string)
os.system(string)
string = "./go 2048 1 20000 32 32"
os.system(string)
'''



blockSizes = []
blockSizes.append((2, 16))
blockSizes.append((2, 32))
blockSizes.append((2, 64))
blockSizes.append((2, 128))
blockSizes.append((2, 256))
blockSizes.append((2, 512))
blockSizes.append((4, 8))
blockSizes.append((8, 8))
blockSizes.append((8, 32))
blockSizes.append((4, 16))
blockSizes.append((4, 64))
blockSizes.append((4, 32))
blockSizes.append((32, 32))
blockSizes.append((8, 16))
blockSizes.append((16, 16))
blockSizes.append((16, 32))
blockSizes.append((8, 64))
blockSizes.append((8, 128))
blockSizes.append((16, 64))
blockSizes.append((4, 128))
blockSizes.append((4, 256))
blockSizes.append((1, 1024))

print(blockSizes)

timeSteps = list(range(1,15))
print(timeSteps)

dominios = []
dominios.append((96,96))
dominios.append((256,256))
dominios.append((512,512))
dominios.append((1024,1024))
dominios.append((2048,2048))
dominios.append((4096,4096))
dominios.append((8192,8192))


print(dominios)

nomeArquivo = 'MaiorTesteDeTodosOsTempos.txt'
arquivo = open(nomeArquivo, 'wt')
#arquivo.write("\n-----------\n")
#arquivo.write("\n-----------\n")
#arquivo.write("\n blockSizes\n"+str(blockSizes)+"\n")
#arquivo.write("\n timeSteps\n"+str(timeSteps)+"\n")
#arquivo.write("\n dominios\n"+str(dominios)+"\n")
arquivo.write("dominios = []\n")


import subprocess

classicDict = dict()

for domain in dominios:
  arquivo.write("blockSizesClassic = []\n")
  print("blockSizesClassic = []\n")
  fazEntrada(domain[0],False)

  for blockSize in blockSizes:
    comado = "nvcc 2DstencilGPUSharedMemoryKarma.cu  -o go -D MODEL_WIDTH="+str(domain[0])+" -D BLOCKDIM_Y="+str(blockSize[0])+" -D BLOCKDIM_X="+str(blockSize[1])+" -w"
    os.system(comado)
    x = subprocess.check_output(["./go", "20000"])
    classicDict[blockSize] = float(x)
    arquivo.write("blockSizesClassic.append(("+str(blockSize)+","+str(x)+"))\n")
    print("blockSizesClassic.append(("+str(blockSize)+","+str(x)+"))\n")
    
  arquivo.write("blockSizesOur = []\n")
  print("blockSizesOur = []\n")
  for blockSize in blockSizes:
    arquivo.write("timeSteps = []\n")
    print("timeSteps = []\n")
    for times in timeSteps:
      comado = "nvcc 2DstencilGPUSharedMemoryKarmaSpaceTimeBlocking.cu  -o go -D MODEL_WIDTH="+str(domain[0])+" -D BLOCKDIM_Y="+str(blockSize[0])+" -D BLOCKDIM_X="+str(blockSize[1])+" -D BLOCK_TIMES="+str(times)+" -w"
      os.system(comado)
      x = subprocess.check_output(["./go","20000"])
      if(float(x)==-1):
        continue
      arquivo.write("timeSteps.append(("+str(times)+","+str(x)+"))\n")
      if(float(x)<classicDict[blockSize]):
        printColored("timeSteps.append(("+str(times)+","+str(x)+"))")
        print("\n")
      else:
        print("timeSteps.append(("+str(times)+","+str(x)+"))\n")
    arquivo.write("blockSizesOur.append(("+str(blockSize)+",timeSteps))\n")
    print("blockSizesOur.append(("+str(blockSize)+",timeSteps))\n")

  arquivo.write("dominios.append(("+str(domain)+",(blockSizesClassic,blockSizesOur)))\n")
  print("dominios.append(("+str(domain)+",(blockSizesClassic,blockSizesOur)))")

arquivo.close()


def enviaArquivo(path):
    from ftplib import FTP 
    import os
    import fileinput
    ftp = FTP()
    ftp.set_debuglevel(2)
    ftp.connect('cobrinha-do-mito.freetzi.com', 21) 
    ftp.login('cobrinha-do-mito.freetzi.com','32431404')
    ftp.cwd('/uploads')
    fp = open("/home/cpires/paperDoCoracao/uffgpu2019/PROJETO/"+path, 'rb')
    ftp.storbinary('STOR %s' % os.path.basename("/home/cpires/paperDoCoracao/uffgpu2019/PROJETO/"+path), fp, 1024)

enviaArquivo(nomeArquivo)