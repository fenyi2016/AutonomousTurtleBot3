% close all;
function lines = detect_straight_lines(img)
% img = imread('combined_lanes.jpg'); %read image
bw=rgb2gray(img); %Convert to Grayscale image
% figure
% imshow(bw);
% filter out noise by remove darker pixels
dark_pixel_ind = find(bw < 120);
bw(dark_pixel_ind) = 0;
% figure
% imshow(bw);
bw_Canny = edge(bw,'Canny'); %Detect edges using Canny
% figure
% imshow(bw_Canny);

[H,T,R] = hough(bw_Canny,'RhoResolution',0.5,'ThetaResolution',0.5);

numpeaks = 7; %Specify the number of peaks
P  = houghpeaks(H,numpeaks);

lines = houghlines(bw_Canny,T,R,P,'FillGap',40,'MinLength',500);

% 
figure(1); imshow(bw)
title('Original Image')
figure(2); imshow(bw_Canny)
title('Canny')
hold on

max_len = 0;
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

   % Plot beginnings and ends of lines
   plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
   plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

   % Determine the endpoints of the longest line segment
   len = norm(lines(k).point1 - lines(k).point2);
   if ( len > max_len)
      max_len = len;
      xy_long = xy;
   end
end



figure
%Show the rho-theta voting
imshow(imadjust(mat2gray(H)),'XData',T,'YData',R,...
      'InitialMagnification','fit');
title('Hough transform results');
xlabel('\theta'), ylabel('\rho');
axis on, axis normal, hold on;
colormap(gca,hot);

imshow(H,[],'XData',T,'YData',R,'InitialMagnification','fit');
xlabel('\theta'), ylabel('\rho');
axis on, axis normal, hold on;
plot(T(P(:,2)),R(P(:,1)),'s','color','white');
