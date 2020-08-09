#!/usr/bin/env bash

# Find the unique message IDs on the busses

cut -f3 -d" " *.log | cut -f1 -d"#" | sort | uniq
