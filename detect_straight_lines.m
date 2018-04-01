function [lines, x_mid] = detect_straight_lines(img)

% Crop the image to increase the speed
% img = img(350:end,:,:);

% Turn img to gray
gray = rgb2gray(img); %Convert to Grayscale image

% Binarize image
T = adaptthresh(gray, 0.6);
bw = imbinarize(gray,T);

% Gaussian to remove noise
bw = double(bw);
bw_after = imgaussfilt(bw, 20); 

%% Detect edges
bw_Canny = edge(bw_after,'Canny',0.6,20); % Detect edges using Canny
% figure


%% Detect lines using hough transform
[H,T,R] = hough(bw_Canny,'RhoResolution',0.5,'ThetaResolution',0.5);

numpeaks = 7; %Specify the number of peaks
P  = houghpeaks(H,numpeaks);

lines = houghlines(bw_Canny,T,R,P,'FillGap',200,'MinLength',100);

%% Calculate mid point
if size(lines,2) > 1
    x1 = floor((250 - csc(lines(1).theta/180*pi)*lines(1).rho)/(-cot(lines(1).theta/180*pi)));
    x2 = floor((250 - csc(lines(2).theta/180*pi)*lines(2).rho)/(-cot(lines(2).theta/180*pi)));
    x_mid = (x1+x2)/2; 
else 
    x1 = 0;
    x2 = 0;
    x_mid = 0;
end

%% Plot

figure
subplot(221);imshow(bw); title("Adaptive threshold");
subplot(222);imshow(bw_after); title("Use Gaussian filter to remove noise");
subplot(223);imshow(bw_Canny); title("After canny edge detection");
subplot(224); imshow(bw_Canny); title('Use Hough transform to detect lines')
hold on

% Plot lines on bw image
max_len = 0; % record max length
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
hold on

plot(x_mid, 250, '*', x1, 250, '*', x2, 250, '*' );

pause(1); close all;

end


