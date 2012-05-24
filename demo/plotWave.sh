#!/bin/zsh
gen()
{
  ruby genWave.rb $1 $2 $3 $4 > /tmp/plot.data
  gnuplot -e "set terminal png size 1920,1080;\
              set output \"/tmp/plot.$4.$3.$1.$2.png\";\
              set yrange [-1:1];\
              plot \"/tmp/plot.data\",
              \"/tmp/plot.data\" with lines title \"lines\",\
              \"/tmp/plot.data\" smooth csplines with lines title \"csplines\",\
              \"/tmp/plot.data\" smooth bezier with lines title \"bezier\";"
}

#Sine
gen 250 50 0
gen 250 50 5
gen 250 50 9

gen 100 20 0
gen 100 20 5
gen 100 20 9

gen 50 10 0
gen 50 10 5
gen 50 10 9

gen 10 5 0
gen 10 5 5
gen 10 5 9

gen 10 2 0
gen 10 2 5
gen 10 2 9

#Triangle
gen 250 50 0 triangle
gen 250 50 5 triangle
gen 250 50 9 triangle

gen 100 20 0 triangle
gen 100 20 5 triangle
gen 100 20 9 triangle

gen 50 10 0 triangle
gen 50 10 5 triangle
gen 50 10 9 triangle

gen 10 5 0 triangle
gen 10 5 5 triangle
gen 10 5 9 triangle

gen 10 2 0 triangle
gen 10 2 5 triangle
gen 10 2 9 triangle

#Square
gen 250 50 0 square
gen 250 50 5 square
gen 250 50 9 square

gen 100 20 0 square
gen 100 20 5 square
gen 100 20 9 square

gen 50 10 0 square
gen 50 10 5 square
gen 50 10 9 square

gen 10 5 0 square
gen 10 5 5 square
gen 10 5 9 square

gen 10 2 0 square
gen 10 2 5 square
gen 10 2 9 square

#Sawtooth
gen 250 50 0 sawtooth
gen 250 50 5 sawtooth
gen 250 50 9 sawtooth

gen 100 20 0 sawtooth
gen 100 20 5 sawtooth
gen 100 20 9 sawtooth

gen 50 10 0 sawtooth
gen 50 10 5 sawtooth
gen 50 10 9 sawtooth

gen 10 5 0 sawtooth
gen 10 5 5 sawtooth
gen 10 5 9 sawtooth

gen 10 2 0 sawtooth
gen 10 2 5 sawtooth
gen 10 2 9 sawtooth

#View
feh /tmp/plot.*.png
