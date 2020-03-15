import subprocess
import os

x = subprocess.check_output(["nvcc","2DstencilGPUSharedMemoryKarma.cu","-o","go","-D","MODEL_WIDTH=256","-D","BLOCKDIM_Y=32","-D","BLOCKDIM_X=32","-D","BLOCK_TIMES=1"])
print(x)
x = subprocess.check_output(["./go","8000","1"])
print(x)


x = subprocess.check_output(["nvcc","2DstencilGPUSharedMemoryKarmaSpaceTimeBlocking.cu","-o","go","-D","MODEL_WIDTH=256","-D","BLOCKDIM_Y=32","-D","BLOCKDIM_X=32","-D","BLOCK_TIMES=1"])
print(x)
x = subprocess.check_output(["./go","8000","1"])
print(x)