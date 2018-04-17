function [YellowPillarDist, YellowPillarAng , IsArrieved, WhiteLineDist, WhiteLineAng, WhiteLineAng2] = detect_straight_lines(img)

% clearvars -except img

%% Initialize
% Flag
IsYellowPillarDetected = false;
IsWhiteLineDetected = false;
IsPlotting = true;

% Assuming the height of camera is 0.127m
camHeight = 0.127; % meter
focalLen = 0.00304;
SizeOfPixel = 1.12e-6;
resolutionRatio = 8;
FOV = deg2rad(62.2); % FOV is 62.2 deg

% Process above ground and on the ground part seperately
% to detect yellow poles and white lines
[nX, nY, ~] = size(img);

Glevel = 180;   % for 410*308, it's 180
HighGlevel = Glevel+20;
Midline = nY/2;
Midlevel = (nX-Glevel)/2;


%% Crop the image to increase the speed
HighImg = img(1:HighGlevel,:,:);
LowImg = img(Glevel+1:end,:,:);


%% Find yellow poles and compute its angle and distance 
% Transform into HSV space and detect yellow poles
HighImgHsv = rgb2hsv(HighImg);

% Make sure yellow pole is detected
HighImgYellow = false(HighGlevel,nY);
for i = 1 : HighGlevel  
    for j = 1 : nY  
        hij = HighImgHsv(i, j, 1);  
        sij = HighImgHsv(i, j, 2);  
        vij = HighImgHsv(i, j, 3);  
        
        if ( hij >= 0.11 && hij<= 0.16 ) && ( sij >= 0.3 && sij <= 0.9 ) % && ( vij >= 0.18 && vij <= 1)  
            
            HighImgYellow(i, j) = true;   
        end  
    end  
end

% subplot(221); imshow(HighImgYellow);
% subplot(222); imshow(HighImgHsv(:,:,1))
% subplot(223); imshow(HighImgHsv(:,:,2))
% subplot(224); imshow(HighImgHsv(:,:,3))

% Binarize image
HighBWHsv = imbinarize(HighImgHsv(:,:,2),0.5);

% Find the intersect of HSV and yellow area
HighBWHsv = bitand(HighBWHsv, HighImgYellow);
HighBWBiggestObj = bwareafilt(HighBWHsv,1); % find the biggest object

% Get the position of the middle bottom point of yellow pole
HighBWCanny = edge(HighBWBiggestObj, 'canny');

if bwarea(HighBWBiggestObj) > 10000
    IsArrieved = 1;
else
    IsArrieved = -1;
end

if bwarea(HighBWBiggestObj) < 30
    
    IsYellowPillarDetected = false;
    
    YellowPillarPoint = [-1,-1];
    YellowPillarAng = -1;
    YellowPillarDist = -1;
    
    
else
    
    SumCanny = sum(HighBWCanny,2);
    YellowPillarTop = find(SumCanny>0, 1, 'first'); % Find the top index
    YellowPillarBottom = find(SumCanny>0, 1, 'last'); % Find the bottom index

    SumCanny = sum(HighBWCanny,1);
    YellowPillarLeft = find(SumCanny>0, 1, 'first'); % Find the left index
    YellowPillarRight = find(SumCanny>0, 1, 'last'); % Find the right index

    YellowPillarPoint = [YellowPillarBottom, (YellowPillarLeft + YellowPillarRight)/2];

    % Calculate the angle between yellow and image center
    YellowPillarAng = (YellowPillarPoint(2) - nY/2)/nY*FOV;

    % Calculate the distance between yellow pole and camera
    rowDiff = abs(YellowPillarPoint(1) - nX/2);
    YellowPillarDist = (camHeight * focalLen)/(rowDiff * SizeOfPixel * resolutionRatio);
    
    IsYellowPillarDetected = true;

    
end




%% Find white lines and compute its angle and Distance
% LowImg = histeq(LowImg);
LowHsv = rgb2hsv(LowImg);

% This method is easily got tricked by light
LowHsvWhite = zeros(nX - Glevel,nY);
for i = 1 : (nX - Glevel)  
    for j = 1 : nY  
        hij = LowHsv(i, j, 1);  
        sij = LowHsv(i, j, 2);  
        vij = LowHsv(i, j, 3);  
        
        if  ( sij >= 0 && sij <= 0.3 ) && ( vij >= 0.6 && vij <= 1) % ( hij >= 0.11 && hij<= 0.16 ) &&
            
            LowHsvWhite(i, j) = true;   % logical value
        end  
    end  
end

% subplot(221); imshow(LowImg);
% subplot(222); imshow(LowHsv(:,:,1))
% subplot(223); imshow(LowHsv(:,:,2))
% subplot(224); imshow(LowHsv(:,:,3))



% Binarize image
gray = rgb2gray(LowImg);
T = adaptthresh(gray, 0.6);
LowBW = imbinarize(gray, T);

% Filter out non white part
LowBW = bitand(LowBW, LowHsvWhite);

LowBWOpen = LowBW;
% Use open function to remove noise
se = strel('disk', 3);
LowBWOpen = imopen(LowBW, se);

% new = LowBWOpen;
% 
% CC = bwconncomp(LowBWOpen);
% numPixels = cellfun(@numel,CC.PixelIdxList);
% [biggest,idx] = max(numPixels);
% LowBWOpen(CC.PixelIdxList{idx}) = 0;
% LowBWOpen = imsubtract(new, LowBWOpen);


%% Detect edges
LowBWCanny = edge(LowBWOpen,'Prewitt'); % Detect edges using Canny


%% Detect lines using hough transform
[H,T,R] = hough(LowBWCanny,'RhoResolution',0.5,'ThetaResolution',0.5);

numpeaks = 7; %Specify the number of peaks
P  = houghpeaks(H,numpeaks);

% lines = houghlines(LowBWCanny,T,R,P,'FillGap',70,'MinLength',100);
lines = houghlines(LowBWCanny,T,R,P,'FillGap',15,'MinLength',70);

if sum(sum(LowBW,1)) < 0 || size(lines,2) == 0
    
        IsWhiteLineDetected = false;
        
        WhiteLineHighPoint = -1;
        WhiteLineLowPoint = -1;
        WhiteLineMidPoint = [-1,-1];
        
        WhiteLineAng = -1;
        WhiteLineAng2 = -1;
        WhiteLineDist = -1; 

else
    
    IsWhiteLineDetected = true;
    
    % Calculate mid point
    if size(lines,2) > 1 % if there is two lines or more
     
        % Calculate the distance between white line middle point and camera
        WhiteLineHighPoint = -cot(lines(1).theta/180*pi)*Midline + csc(lines(1).theta/180*pi)*lines(1).rho;
        WhiteLineLowPoint = -cot(lines(2).theta/180*pi)*Midline + csc(lines(2).theta/180*pi)*lines(2).rho;
        
        WhiteLineMidPoint = [(WhiteLineHighPoint+WhiteLineLowPoint)/2 + Glevel, Midline]; 
        rowDiff = abs(WhiteLineMidPoint(1) - nX/2);
        WhiteLineDist = (camHeight * focalLen)/(rowDiff * SizeOfPixel * resolutionRatio);

        % Calculate the angle between white line and y axis
        % -x to +y to x, means -90 to 0 to 90 deg
        % WhiteLineAng = (lines(1).theta/180*pi + lines(2).theta/180*pi)/2;  % radian
        WhiteLineLeft = (Midlevel - csc(lines(1).theta/180*pi)*lines(1).rho)/(-cot(lines(1).theta/180*pi));
        WhiteLineRight = (Midlevel - csc(lines(2).theta/180*pi)*lines(2).rho)/(-cot(lines(2).theta/180*pi));
        WhiteLineAng = ((WhiteLineLeft+WhiteLineRight)/2 - nY/2)/nY*FOV;
        WhiteLineAng2 = (lines(1).theta/180*pi + lines(2).theta/180*pi)/2;  % radian

    elseif size(lines,2) == 1
        
        WhiteLineHighPoint = -cot(lines(1).theta/180*pi)*Midline + csc(lines(1).theta/180*pi)*lines(1).rho;
        WhiteLineLowPoint = WhiteLineHighPoint;
        WhiteLineMidPoint = [(WhiteLineHighPoint+WhiteLineLowPoint)/2 + Glevel, Midline];

        WhiteLineLeft = (Midlevel - csc(lines(1).theta/180*pi)*lines(1).rho)/(-cot(lines(1).theta/180*pi));
        WhiteLineRight = WhiteLineLeft;
        WhiteLineAng = ((WhiteLineLeft+WhiteLineRight)/2 - nY/2)/nY*FOV;
        WhiteLineAng2 = (lines(1).theta/180*pi)/2;  % radian
        
        % Calculate the distance between white line middle point and camera
        rowDiff = abs(WhiteLineMidPoint(1) - nX/2);
        WhiteLineDist = (camHeight * focalLen)/(rowDiff * SizeOfPixel * resolutionRatio);
        
    end
    
    if ( WhiteLineHighPoint > nX || WhiteLineHighPoint < 0 ) || ( WhiteLineLowPoint > nX || WhiteLineLowPoint < 0 )
        WhiteLineDist = -1;
    end
    
    if WhiteLineAng > FOV/2 || WhiteLineAng < -FOV/2
        WhiteLineAng = -1;
    end
    
end




% % Plot

if ~IsPlotting
    return
end

figure
subplot(221); imshow(HighImg);
% subplot(222); imshow(HighImgYellow);
if IsYellowPillarDetected
%     subplot(223); imshow(HighBWBiggestObj);
    subplot(222); imshow(HighBWCanny); 
    hold on; plot( YellowPillarPoint(2), YellowPillarPoint(1),'*'); hold off;
end



% figure
subplot(223);imshow(LowImg); 
% subplot(222);imshow(LowBW); 
if IsWhiteLineDetected
    
%     subplot(223);imshow(LowBWOpen); 
    subplot(224);imshow(LowBWCanny); 
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

    if WhiteLineMidPoint > 0
        plot(Midline, WhiteLineMidPoint(1)-Glevel, '*', Midline, WhiteLineHighPoint,'*', Midline, WhiteLineLowPoint,'*' );
    end

    hold off
    
end

%     info = [YellowPillarDist, YellowPillarAng , WhiteLineDist, WhiteLineAng];
%     disp(info);

end


