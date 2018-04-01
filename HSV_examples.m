rgb_I = imread('ScreenShot.jpg');
hsv_I = rgb2hsv(rgb_I);
% subplot(221); imshow(rgb_I)
% subplot(222); imshow(hsv_I(:,:,1))
% subplot(223); imshow(hsv_I(:,:,2))
% subplot(224); imshow(hsv_I(:,:,3))
% 
% figure
% subplot(221); imshow(histeq(rgb_I))
% subplot(222); imshow(histeq(hsv_I(:,:,1)))
% subplot(223); imshow(histeq(hsv_I(:,:,2)))
% subplot(224); imshow(histeq(hsv_I(:,:,3)))

hsv_I(:,:,2) = histeq(hsv_I(:,:,2));
imshow(hsv_I(:,:,2));
hsv_I = hsv_I(:,:,2) + hsv_I(:,:,3);

bw=hsv_I(140:end-10,:); %Convert to Grayscale image


[bw_Canny,threshOut] = edge(bw,'Canny'); %Detect edges using Canny
imshow(bw_Canny);




[H,T,R] = hough(bw_Canny,'RhoResolution',0.5,'ThetaResolution',0.5);

numpeaks = 10; %Specify the number of peaks
P  = houghpeaks(H,numpeaks);

lines = houghlines(bw_Canny,T,R,P,'FillGap',2,'MinLength',2);

figure
subplot(311); imshow(bw)
title('Original Image')
subplot(312); imshow(bw_Canny)
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

