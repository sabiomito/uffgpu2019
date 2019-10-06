#!/bin/bash

nvcc soma1.cu
printf "" > result.txt
printf "1024 th/blk blk calculated \n\n" >> result.txt

./a.out 10 >> result.txt
./a.out 100 >> result.txt
./a.out 1000 >> result.txt
./a.out 10000 >> result.txt
./a.out 100000 >> result.txt
./a.out 1000000 >> result.txt
./a.out 10000000 >> result.txt

