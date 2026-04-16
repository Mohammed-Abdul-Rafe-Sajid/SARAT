 unset key
 plot 'complete_traj_6687.dat' w l lc 3
 rep 'convex_hull_6687.dat' u 2:3 w l lw 3 l       t 7
 set xla 'Longitude'
 set yla 'Latitude'
 set xla font 'Helvetca,20'
 set yla font 'Helvetca,20'
 set xtics font 'Helvetca,16'
 set ytics font 'Helvetca,16'
 replot
 set term po solid color eps
 set o 'images/complete_trajectory_6687.eps'
 replot
