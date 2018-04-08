clear;  close all;

picNames = dir('*.jpg');
for i = 1:1
    
%% Read image
% filename = picNames(i).name;
% img = imread(filename); %read image
% % img = img(350:end,:,:);

img = imread('sample10.png');
img = img(0.5*size(img,1):end,:,:);

% hsv_I = rgb2hsv(img);
% subplot(221); imshow(img)
% subplot(222); imshow(hsv_I(:,:,1))
% subplot(223); imshow(hsv_I(:,:,2))
% subplot(224); imshow(hsv_I(:,:,3))

% [y,x,z]=size(hsv_I);
% new = zeros(y,x);
% for i = 1 : y  
%     for j = 1 : x  
%         hij = hsv_I(i, j, 1);  
%         sij = hsv_I(i, j, 2);  
%         vij = hsv_I(i, j, 3);  
%         
%         if ( sij >= 0&& sij<= 0.1 ) && ( vij >= 0.9 && vij <= 1)  
%             
%             new(i, j) = hsv_I(i,j,3);   
%         end  
%     end  
% end
% 
% imshow(new);
% imshow(img);

% Turn img to gray
gray = rgb2gray(img); %Convert to Grayscale image


% Binarize image
T = adaptthresh(gray, 0.6);
bw = imbinarize(gray,T);

% Gaussian to remove noise
bw = double(bw);
% bw_after = imgaussfilt(bw, 20); 

bw_after = bw;
se = strel('disk',4);
bw_after = imopen(bw,se);


% figure
% subplot(221);imshow(bw); title("Adaptive threshold");
% subplot(222);imshow(bw_after); title("Use Gaussian filter to remove noise");


%% filter out noise by remove darker pixels
% dark_pixel_ind = find(bw < 120);
% bw(dark_pixel_ind) = 0;


%% Detect edges
bw_Canny = edge(bw_after,'Canny',0.6,5); % Detect edges using Canny
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
subplot(221);imshow(bw); title("Adaptive threshold");
subplot(222);imshow(bw_after); title("After removed noise");
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

% hold on
% 
% fprintf('This is the %d picture \n', i);
% 
% % Find the desired point
% % We set the desired point to the midpoint of the two intersections 
% % of y = 250 & y = -cot(theta)*x + csc(theta)*rho
% if size(lines,2) > 1
%     x1 = floor((250 - csc(lines(1).theta/180*pi)*lines(1).rho)/(-cot(lines(1).theta/180*pi)));
%     x2 = floor((250 - csc(lines(2).theta/180*pi)*lines(2).rho)/(-cot(lines(2).theta/180*pi)));
%     x_mid = (x1+x2)/2; 
%     plot(x_mid, 250, '*', x1, 250, '*', x2, 250, '*' );
% end

% pause(1);
% 
% 
% close all;

end


