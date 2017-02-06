function video = VideoReadNative(videoName, colourSpace)
% video = VideoRead(videoName, colourSpace)
%
% Reads in a video using mmread on the DATAopts.videoPath combined with the
% videoName. Returns a 3D video matrix OR a cell array with 3D video
% matrices, one for each colour channel
%
% videoName:        Name of the video
% colourSpace:      Name of the colour space in which video is desired
% 
% video:            N x M x F double matrix with video of F frames
%
% This function works with http://www.mathworks.co.uk/matlabcentral/fileexchange/8028-mmread
%
%           Jasper Uijlings - 2013

global DATAopts;

if nargin == 1
    colourSpace = 'Intensity';
end

% Load the video using the Matlab native video reader
videoStruct = VideoReader(sprintf(DATAopts.videoPath, videoName));

% Obtain first frame
videoFrame = Image2ColourSpace(read(videoStruct, 1), colourSpace);

% Different behaviour depending on colour image or not
if size(videoFrame,3) == 1 % Single channel colour space
    % Create video array
    video = zeros(videoStruct.Height, videoStruct.Width, videoStruct.NumberOfFrames);
    for i=1:videoStruct.NumberOfFrames
        videoFrame = Image2ColourSpace(read(videoStruct, i), colourSpace);
        video(:,:,i) = videoFrame;
    end
else % Mulitple channel colour space
    % Create video array
    numChannels = size(videoFrame,3); % Number of colour channels
    
    % Initialize video
    video = cell(numChannels,1);
    for cI=1:numChannels
        video{cI} = zeros(videoStruct.Height, videoStruct.Width, videoStruct.NumberOfFrames);
    end
    
    % Get video for all frames
    for i=1:videoStruct.NumberOfFrames
        videoFrame = Image2ColourSpace(read(videoStruct, i), colourSpace);
        for cI=1:numChannels
            video{cI}(:,:,i) = videoFrame(:,:,cI);
        end
    end
end