set terminal postscript enhanced color
set output "| ps2pdf - /tmp/scope.pdf"
#set output "/tmp/scope.eps"
#set terminal png size 30000,2000
#set output "/tmp/scope.png"
set autoscale
unset log
unset label
set xtic auto
set ytic auto
set title "Scope data"
set xlabel "Sample (N)"
set ylabel "Voltage (mV)"
#set yrange [-3300:3300]
set datafile separator ","
plot "data.csv" every ::1 u 1:2 t "A" w lp, "data.csv" u 1:3 t "B" w lp
# vim:ft=gnuplot
