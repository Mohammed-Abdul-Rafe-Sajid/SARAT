 unset key
 set pm3d map
 spl 'composite_6687.dat'
 set xla 'Longitude'
 set yla 'Latitude'
 set xla font 'Helvetca,20'
 set yla font 'Helvetca,20'
 set xtics font 'Helvetca,16'
 set ytics font 'Helvetca,16'
 set xra[69.62630:70.00400]
 set yra[22.43720 :22.73060 ]
 replot
 set term po solid color eps
 set o 'images/probability_6687.eps'
 replot
