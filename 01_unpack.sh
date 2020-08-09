#!/usr/bin/env bash

ls *.bz2 | xargs -n1 -P8 bunzip2 --keep
sort *.log > final_log
