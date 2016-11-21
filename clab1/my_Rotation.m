function result = my_Rotation( img,angle )              %function definition
img=double(img);
lenIrow=size(img,1);                                    %get length of row
lenIcol=size(img,2);                                    %get length of col
lenNrow=lenIcol*sin(angle)+lenIrow*cos(angle);          %get row of rotated img
lenNcol=lenIcol*cos(angle)+lenIrow*sin(angle);          %get col of rotated img
lenNrow=ceil(lenNrow);                                  %round to integer
lenNcol=ceil(lenNcol);                                  %round to integer   
T=lenIcol*sin(angle);                                   %translation parameter 
R=[cos(angle),sin(angle);-sin(angle),cos(angle)];       %rotation matrix
%inverse mapping method
for u=1:lenNrow                                         %for each row in new img    
    for v=1:lenNcol                                     %for each col in new img                
        temp=R*([u-T;v]);                               %translation and rotation       
        x=temp(1);                                      %get x from new img                                
        y=temp(2);                                      %get y from new img
        if x>=1 & x<=lenIrow & y>=1 & y<=lenIcol        %if xy falls on the range
            x1 = floor(x);                              %floor the x      
            y1 = floor(y);                              %floor the y         
            y2 = ceil(y);                               %ceil the y
            x2 = ceil(x);                               %ceil the x        
            if (x-x1) <= (x2-x)                         %get 4 surrounding pix    
                  x = x1;                               %then get the nearest pix location          
            else
                x = x2;
            end
            if (y-y1) <= (y2-y)       
                y = y1;                 
            else
                y = y2;                
            end
            %bilinear interpolation    
            p1 = img(x1,y1);                            %assign pix value  
            p2 = img(x2,y1);                            %assign pix value 
            p3 = img(x1,y1);                            %assign pix value    
            p4 = img(x2,y2);                            %assign pix value                 
            s = x-x1;              
            t = y-y1;                    
            imgN(u,v) = (1-s)*(1-t)*p1+(1-s)*t*p3+(1-t)*s*p2+s*t*p4;%imterpolation
        end
    end
   result= uint8(imgN);
end
