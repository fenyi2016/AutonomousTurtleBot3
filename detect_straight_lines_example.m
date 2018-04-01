clear;  close all;
% function lines = detect_straight_lines(img)

%% Read image
img = imread('combined_lanes.jpg'); %read image
img = img(1001:end,:,:);
% imshow(img);

% Turn img to gray
gray = rgb2gray(img); %Convert to Grayscale image

% Binarize image
T = adaptthresh(gray, 0.6);
BW = imbinarize(gray,T);

% Gaussian to remove noise
h_gaosi = fspecial('gaussian',70,30);  
BW_after = imfilter(BW, h_gaosi); 




%% filter out noise by remove darker pixels
% dark_pixel_ind = find(bw < 120);
% bw(dark_pixel_ind) = 0;


%% Detect edges
bw_Canny = edge(BW_after,'Canny'); % Detect edges using Canny
% figure


%% Detect lines using hough transform
[H,T,R] = hough(bw_Canny,'RhoResolution',0.5,'ThetaResolution',0.5);

numpeaks = 7; %Specify the number of peaks
P  = houghpeaks(H,numpeaks);

lines = houghlines(bw_Canny,T,R,P,'FillGap',100,'MinLength',10);

% % 
% figure(1); 
% subplot(211); imshow(bw); title('Original Image')

% figure(2); 
figure
subplot(221);imshow(BW); title("Adaptive threshold");
subplot(222);imshow(BW_after); title("Use Gaussian filter to remove noise");
subplot(223);imshow(bw_Canny); title("After canny edge detection");
subplot(224); imshow(bw_Canny); title('Use Hough transform to detect lines')
hold on

%% Plot lines on bw image
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


% 
% figure
% %Show the rho-theta voting
% subplot(211);
% imshow(imadjust(mat2gray(H)),'XData',T,'YData',R,...
%       'InitialMagnification','fit');
% title('Hough transform results');
% xlabel('\theta'), ylabel('\rho');
% axis on, axis normal, hold on;
% colormap(gca,hot);
% 
% subplot(212);
% imshow(H,[],'XData',T,'YData',R,'InitialMagnification','fit');
% xlabel('\theta'), ylabel('\rho');
% axis on, axis normal, hold on;
% plot(T(P(:,2)),R(P(:,1)),'s','color','white');





