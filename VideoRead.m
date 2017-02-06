function video = VideoRead(videoName, colourSpace)
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

% Load the video using mmread
videoStruct = mmread(sprintf(DATAopts.videoPath, videoName));

if ~isempty(videoStruct.frames(1).colormap)
    warning('Colormaps unsupported in this implementation.');
    keyboard;
end

% Obtain first frame
videoFrame = Image2ColourSpace(videoStruct.frames(1).cdata, colourSpace);

% Different behaviour depending on colour image or not
if size(videoFrame,3) == 1 % Single channel colour space
    % Create video array
    video = zeros(videoStruct.height, videoStruct.width, videoStruct.nrFramesTotal);
    for i=1:videoStruct.nrFramesTotal
        videoFrame = Image2ColourSpace(videoStruct.frames(i).cdata, colourSpace);
        video(:,:,i) = videoFrame;
    end
else % Mulitple channel colour space
    % Create video array
    numChannels = size(videoFrame,3); % Number of colour channels
    
    % Initialize video
    video = cell(numChannels,1);
    for cI=1:numChannels
        video{cI} = zeros(videoStruct.height, videoStruct.width, videoStruct.nrFramesTotal);
    end
    
    % Get video for all frames
    for i=1:videoStruct.nrFramesTotal
        videoFrame = Image2ColourSpace(videoStruct.frames(i).cdata, colourSpace);
        for cI=1:numChannels
            video{cI}(:,:,i) = videoFrame(:,:,cI);
        end
    end
end