#!/usr/bin/env bash


while [ 1 ]
do

candump -n 10000 -l any,0:0,#FFFFFFFF
bzip2 *.log
git add *.bz2
git commit -am "`date`"
git push
done
