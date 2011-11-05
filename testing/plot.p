#set terminal postscript enhanced color
#set output "| ps2pdf - /tmp/tmp/scope.pdf"
#set output "/tmp/tmp/scope.eps"
set terminal png size 30000,2000
set output "/tmp/tmp/scope.png"
set autoscale
unset log
unset label
set xtic auto
set ytic auto
set title "Scope data"
set xlabel "Sample (N)"
set ylabel "Voltage (mV)"
#set yrange [-3300:3300]
plot "/tmp/tmp/scopeproca" t "A"  w lp, "/tmp/tmp/scopeprocb" t "B" w lp
# vim:ft=gnuplot
