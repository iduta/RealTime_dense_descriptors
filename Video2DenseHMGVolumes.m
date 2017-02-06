function [hmgs, info] = Video2DenseHMGVolumes(video, blockSize, numBlocks, numOr)
% [hmgs, info] = Video2DenseHMGVolumes(video, blockSize, numBlocks, numOr)
%
% Get Densely Sampled Historams of Motion Gradients (HMG) descriptors
% from a video. Final size of the volume per descriptor is 
% (blockSize .* numBlocks) pixels.
% - Soft cell-borders within a single frame (linear interpolation in 
%   row and col directions)
% - Hard cell-borders in time direction
% - Sampling is as dense as subcells
%
% video:            N x M x F grayscale video
% blockSize:        1 x 3 vector with sub-block size in pixels ([pRow pCol pFrames]
% numBlocks:        1 x 3 vector with number of blocks [nRow nCol nZ]
% numOr (optional): Number of orientations for the histogram (default: 8)

%
% hmgs:             HMG descriptors
% info:             Info structure containing e.g. coordinates
%
%           Jasper Uijlings - 2013
%         Ionut Cosmin Duta - 2016

if nargin < 4
    numOr = 8; % Default: 8 orientations
end



% Calculate teh motion between frames by using a simple tempral derivation
% with the filter [1 -1]
simpleMotion = video(:, :, 1:end-1)-video(:, :, 2:end);

% Histograms of Motion Gradients can be calculated by considering the computed simple motion
% as a video and simply calculating Histograms of Oriented Gradients.
[hmgs, info] = Video2DenseHOGVolumes(simpleMotion, blockSize, numBlocks, numOr);

