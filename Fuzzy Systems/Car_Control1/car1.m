clear all;
k = 1;
for theta = [0, -45, -90]
    clear {'x_arr', 'y_arr', 'theta_arr', 'd_theta_arr'} ;
    x = 4.1;
    y = 0.3;
    
    i=1;
    car = readfis('car1_Improved');
    while(x<10)
        x_arr(i)= x;
        y_arr(i)= y;
        if(x - 5 <0)
            dh = 5-x;
            if(y-1<0)
                dv =1-y;
            else
                dv = 0;
                dh = 1;
            end
        elseif(x-6 < 0)
            dh = 6-x;
            if(y-2<0)
                dv = 2-y;
            
            else
                dv = 0;
                dh = 1;
            end
        elseif(x-7<0)
            dh = 7-x;
            if(y-3<0)
                dv = 3-y;
            else
                dv = 0;
                dh = 1;
            end
        elseif(x<10)
            if(y-3.2<0)
                dv = 3.2-y;
                dh = 1;
            else
                dv = 0;
                dh = 1;
            end
        end
        dh_arr(i)=dh;
        dv_arr(i)=dv;
        theta_arr(i) = theta;
    
    d_theta = evalfis([dv dh theta],car);
    d_theta_arr(i) = d_theta;
    
    %new theta, x, y
    theta = d_theta + theta;
    if(theta>180)
        theta = mod(theta, 360);  
        theta = theta - 360;
    end
    x = x+cosd(theta)*0.05; %xronos ananewsis 1 sec
    y = y+sind(theta)*0.05;
    i=i+1;
    end
    i;
    figure;
    plot(x_arr,y_arr);
    hold on;
    rectangle('Position', [5 0 1 1]);
    rectangle('Position', [6 0 1 2]);
    rectangle('Position', [7 0 1 3]);
    plot(10, 3.2, 'rx');
    hold off;
    error(k) = abs((y_arr(end)-3.2));
    k = k+1;
    %1
end