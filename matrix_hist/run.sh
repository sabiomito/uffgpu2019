#!/bin/bash



nvcc matrix_hist.cu
printf "" > result.txt
printf "1024 th/blk blk calculated \n\n" >> result.txt

./a.out 10 >> result.txt
./a.out 100 >> result.txt
./a.out 1000 >> result.txt
./a.out 10000 >> result.txt
./a.out 100000 >> result.txt
./a.out 1000000 >> result.txt
./a.out 10000000 >> result.txt
./a.out 100000000 >> result.txt
./a.out 1000000000 >> result.txt

printf "512 th/blk blk calculated \n\n" >> result.txt

./a.out 10 512 >> result.txt
./a.out 100 512 >> result.txt
./a.out 1000 512 >> result.txt
./a.out 10000 512 >> result.txt
./a.out 100000 512 >> result.txt
./a.out 1000000 512 >> result.txt
./a.out 10000000 512 >> result.txt
./a.out 100000000 512 >> result.txt
./a.out 1000000000 512 >> result.txt

printf "256 th/blk blk calculated \n\n" >> result.txt

./a.out 10 256 >> result.txt
./a.out 100 256 >> result.txt
./a.out 1000 256 >> result.txt
./a.out 10000 256 >> result.txt
./a.out 100000 256 >> result.txt
./a.out 1000000 256 >> result.txt
./a.out 10000000 256 >> result.txt
./a.out 100000000 256 >> result.txt
./a.out 1000000000 256 >> result.txt


printf "126 th/blk blk calculated \n\n" >> result.txt

./a.out 10 126 >> result.txt
./a.out 100 126 >> result.txt
./a.out 1000 126 >> result.txt
./a.out 10000 126 >> result.txt
./a.out 100000 126 >> result.txt
./a.out 1000000 126 >> result.txt
./a.out 10000000 126 >> result.txt
./a.out 100000000 126 >> result.txt
./a.out 1000000000 126 >> result.txt

printf "64 th/blk blk calculated \n\n" >> result.txt

./a.out 10 64 >> result.txt
./a.out 100 64 >> result.txt
./a.out 1000 64 >> result.txt
./a.out 10000 64 >> result.txt
./a.out 100000 64 >> result.txt
./a.out 1000000 64 >> result.txt
./a.out 10000000 64 >> result.txt
./a.out 100000000 64 >> result.txt
./a.out 1000000000 64 >> result.txt