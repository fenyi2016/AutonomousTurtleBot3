function [YPAng, YPDist, WLDist] = detect_straight_lines(img)

% Process above ground and on the ground part seperately
% to detect yellow poles and white lines
[nX, nY, ~] = size(img);
Glevel = 180;
Midlevel = (nX - Glevel) - 30;

% Crop the image to increase the speed
UpImg = img(1:Glevel,:,:);
DownImg = img(Glevel:end,:,:);

%% Find yellow poles and compute its angle and distance 
% Transform into HSV space and detect yellow poles
HsvUpImg = rgb2hsv(UpImg);


% Make sure yellow pole is detected

        

HsvUpBW = imbinarize(HsvUpImg(:,:,2),0.5);
BigObjUpBW = bwareafilt(HsvUpBW,1); % find the biggest object

% Get the position of the bottom of yellow pole
CannyUpBW = edge(BigObjUpBW);
SumCanny = sum(CannyUpBW,2);

% Find the bottom index
for i = length(SumCanny):-1:1
    if SumCanny(i) > 0
        YPBottom = i;
        break
    end
end

% Find the top index
for i = 1:length(SumCanny)
    if SumCanny(i) > 0
        YPTop = i;
        break
    end
end

bottomLine = CannyUpBW(YPBottom,:);

for i = length(bottomLine):-1:1
    if bottomLine(i) > 0
        rightPoint = i;
        break
    end
end

for i = 1:length(bottomLine)
    if bottomLine(i) > 0
        leftPoint = i;
        break
    end
end

YPPoint = [YPBottom, round((rightPoint + leftPoint)/2)];

% Assuming FOV is 60 deg
FOV = 60;
YPAng = (YPPoint(2) - floor(nY/2))/nY*FOV;

% Assuming the height of camera is 0.127m
camHeight = 0.127; % meter
focalLen = 0.00304;
SizeOfPixel = 1.12e-6;
resolutionRatio = 8;
rowDiff = abs(YPPoint(1) - floor(nX/2));

YPDist = camHeight*focalLen/rowDiff/SizeOfPixel/resolutionRatio;

figure;
subplot(221); imshow(UpImg)
subplot(222); imshow(HsvUpImg)
subplot(223); imshow(BigObjUpBW)
subplot(224); imshow(CannyUpBW); hold on;
plot( YPPoint(2), YPPoint(1),'*'); hold off;




%% Find white lines and compute its angle and Distance
% Turn img to gray
gray = rgb2gray(DownImg); %Convert to Grayscale image

% Binarize image
T = adaptthresh(gray, 0.6);
DownBW = imbinarize(gray, T);
OpenDownBW = DownBW;

% Gaussian to remove noise
% se = strel('disk',4);
% OpenDownBW = imopen(DownBW,se);

%% Detect edges
CannyDownBW = edge(OpenDownBW,'Canny',0.6,5); % Detect edges using Canny


%% Detect lines using hough transform
[H,T,R] = hough(CannyDownBW,'RhoResolution',0.5,'ThetaResolution',0.5);

numpeaks = 7; %Specify the number of peaks
P  = houghpeaks(H,numpeaks);

lines = houghlines(CannyDownBW,T,R,P,'FillGap',30,'MinLength',50);



%% Calculate mid point
if size(lines,2) > 1  % if there is two lines or more
    x1 = floor((Midlevel - csc(lines(1).theta/180*pi)*lines(1).rho)/(-cot(lines(1).theta/180*pi)));
    x2 = floor((Midlevel - csc(lines(2).theta/180*pi)*lines(2).rho)/(-cot(lines(2).theta/180*pi)));
    x_mid = (x1+x2)/2; 
elseif size(lines,2) == 1
    x1 = floor((Midlevel - csc(lines(1).theta/180*pi)*lines(1).rho)/(-cot(lines(1).theta/180*pi)));
    x2 = x1;
    x_mid = x1;
    
else
    x1 = -1;
    x2 = -1;
    x_mid = -1;
end

WLPoint = [Midlevel, x_mid];

rowDiff = abs(WLPoint(1) - nX/2);
WLDist = camHeight*focalLen/rowDiff/SizeOfPixel/resolutionRatio;


%% Plot

figure
subplot(221);imshow(img); title("Adaptive threshold");
subplot(222);imshow(OpenDownBW); title("Remove noise");
subplot(223);imshow(CannyDownBW); title("After canny edge detection");
subplot(224);imshow(CannyDownBW); title('Use Hough transform to detect lines')
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

if x_mid > 0
    plot(x_mid, Midlevel, '*', x1, Midlevel, '*', x2, Midlevel, '*' );
end

hold off

% end


