%%  Find Image File Names
imageNames = dir('*.jpg');      % .bmp
imageNames = {imageNames.name}';
workingDir = 'video';
mkdir(workingDir);

%%  Create New Video with the Image Sequence
fullname = fullfile(workingDir, 'teapot.avi');  % replace the video file name
outputVideo = VideoWriter(fullname);
outputVideo.FrameRate = 30;
open(outputVideo)

for ii = 1:length(imageNames)
   img = imread(imageNames{ii});
   writeVideo(outputVideo,img)
end

close(outputVideo)