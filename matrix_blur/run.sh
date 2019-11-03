#!/bin/bash
nvcc memoriaUnificada.cu
printf "" > result.txt
printf "\n\n memoriaUnificada \n\n" >> result.txt

./a.out 100 >> result.txt
./a.out 1000 >> result.txt
./a.out 10000 >> result.txt

nvcc copiaManual.cu
printf "\n\n copiaManual \n\n" >> result.txt

./a.out 100 >> result.txt
./a.out 1000 >> result.txt
./a.out 10000 >> result.txt

nvcc streamCPUGPU.cu
printf "\n\n streamCPUGPU \n\n" >> result.txt

./a.out 100 >> result.txt
./a.out 1000 >> result.txt
./a.out 10000 >> result.txt

nvcc allStream.cu
printf "\n\n allStream \n\n" >> result.txt

./a.out 100 >> result.txt
./a.out 1000 >> result.txt
./a.out 10000 >> result.txt
