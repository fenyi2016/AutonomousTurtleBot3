close all;
C = imread('ObjectDetection.PNG'); %read image
trim=C(100:end,30:end-30,:); %Cut out some boundary artifacts and the stuff not in the ground plane
hsv_I = rgb2hsv(trim);
bw=hsv_I(:,:,2); %Convert to Grayscale image

[bw_Canny,threshOut] = edge(bw,'Canny');

% override some default parameters
params.minMajorAxis = 50;
params.maxMajorAxis = 100;
params.numBest = 3;
params.rotation = 90;
params.rotationSpan = 10;


% note that the edge (or gradient) image is used
bestFits = ellipseDetection(bw_Canny, params);

fprintf('Output %d best fits.\n', size(bestFits,1));

figure;
image(trim);
%ellipse drawing implementation: http://www.mathworks.com/matlabcentral/fileexchange/289 
ellipse(bestFits(1,3),bestFits(1,4),bestFits(1,5)*pi/180,bestFits(1,1),bestFits(1,2),'r');