function pH = pH_rockFACE(depth)

depth0 = [0 5 20 40 75 110]/100;
pH0 = [7.17 6.85 6.4 6.5 7.1 7.8];

pH = interp1(depth0,pH0,depth,'spline');

end
