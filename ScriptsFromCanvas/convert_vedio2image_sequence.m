%%  Create a temporary working folder to store the image sequence.
videoNames = dir('*.mp4');
for i = 1:length(videoNames)
    [path, name, ext] = fileparts(videoNames(i).name);
    workingDir = name;
    mkdir(workingDir);
    mkdir(workingDir,'images');

%%  Create a VideoReader to use for reading frames from the file.

    Video = VideoReader([workingDir '.mp4']);

%%  Create the Image Sequence

    ii = 1;

    while hasFrame(Video)
       img = readFrame(Video);
       filename = [sprintf('%03d',ii) '.jpg'];
       fullname = fullfile(workingDir,'images',filename);
       imwrite(img,fullname)    % Write out to a JPEG file (img1.jpg, img2.jpg, etc.)
       ii = ii+1;
    end

% Find all the JPEG file names in the images folder. Convert the set of image names to a cell array.

    imageNames = dir(fullfile(workingDir,'images','*.jpg'));
    imageNames = {imageNames.name}';

    workingDir
end

