#!/bin/sh
set -ve
python freqlut.py > freqlut.asm
rgbasm -E -o gbvgm.o gbvgm.asm
rgblink -n gbvgm.sym -m gbvgm.map -o gbvgm.gbc gbvgm.o
rgbfix -jv -c -i XXXX -k XX -l 0x33 -m 0x01 -p 0 -r 0 -t gbvgm gbvgm.gbc

