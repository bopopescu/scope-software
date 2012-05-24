#!/bin/zsh
gen()
{
  ruby genWave.rb $1 $2 $3 > /tmp/plot.data
  gnuplot -e "set terminal png size 1920,1080;\
              set output \"/tmp/plot.$1.$2.$3.png\";\
              set yrange [-1:1];\
              plot \"/tmp/plot.data\",
              \"/tmp/plot.data\" with lines title \"lines\",\
              \"/tmp/plot.data\" smooth csplines with lines title \"csplines\",\
              \"/tmp/plot.data\" smooth bezier with lines title \"bezier\";"
}

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

feh /tmp/plot.*.png
