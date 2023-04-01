clear;

num = [1 0.111];
den = [1 10.1 1 0];

k = 54.054;

open_loop = tf(num, den);
rlocus(open_loop);

open_loop = k*open_loop;
closed_loop = feedback(open_loop, 1, -1);

info = stepinfo(closed_loop);
fprintf("RiseTime = %f \n",info.RiseTime);
fprintf("Overshoot = %f \n",info.Overshoot);

