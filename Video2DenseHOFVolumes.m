function [hofs, info] = Video2DenseHOFVolumes(video, blockSize, numBlocks, numOr, flowMethod)
% [hofs, info] = Video2DenseHOFVolumes(video, blockSize, numBlocks, numOr, flowMethod
%
% Get Densely Sampled Histogram of Oriented Optical Flow volume descriptors
% from a video. Final size of the volume per descriptor is 
% (blockSize .* numBlocks) pixels.
% - Optical Flow is calculated using MATLABs CV toolbox
% - Soft cell-borders within a single frame (linear interpolation in 
%   row and col directions)
% - Hard cell-borders in time direction
% - Sampling is as dense as subcells
%
% video:            N x M x F grayscale video
% blockSize:        1 x 3 vector with sub-block size in pixels ([pRow pCol pFrames]
% numBlocks:        1 x 3 vector with number of blocks [nRow nCol nZ]
% numOr (optional): Number of orientations for the histogram (default: 8)
% flowMethod(optional): Method of optical opticalFlow: {'Horn-Schunck' (default), 'Lucas-Kanade'}
%
% hofs:             Hof descriptors
% info:             Info structure containing e.g. coordinates
%
%           Jasper Uijlings - 2013

if nargin < 4
    numOr = 8; % Default: 8 orientations
end

if nargin < 5
    flowMethod = 'Horn-Schunck'; % Horn-Schunk optical opticalFlow
end

% Calculate optical flow from the video
opticalFlow = Video2OpticalFlow(video, flowMethod);

% Determine area of frame for which features can be extracted
nR = size(opticalFlow,1);
nC = size(opticalFlow,2);
nF = size(opticalFlow,3);
extraPixelsR = mod(nR, blockSize(1));
extraPixelsC = mod(nC, blockSize(2));
extraFrames = mod(nF, blockSize(3));
newR = nR - extraPixelsR;
newC = nC - extraPixelsC;
newF = nF - extraFrames;
offsetR = floor(extraPixelsR / 2); % Shave borders if too many pixels
offsetC = floor(extraPixelsC / 2);
offsetF = floor(extraFrames / 2);
rangeR = (1:newR) + offsetR; % Ranges determine final area of descriptor extraction
rangeC = (1:newC) + offsetC;
rangeF = (1:newF) + offsetF;

% Get matrices for doing multiplication to get subblocks (Real-time
% Bag-of-Words paper, TMM, Uijlings 2010)
subBlocksR = newR / blockSize(1);
subBlocksC = newC / blockSize(2);
subBlocksF = newF / blockSize(3);
arrayA = DiagMatrixLinear(subBlocksR, newR);
arrayB = DiagMatrixLinear(newC, subBlocksC);

% Initialize block HOFs
blockHof = cell(1, numOr);
for i=1:numOr
    blockHof{i} = zeros(subBlocksR, subBlocksC, subBlocksF);
end

% Obtain subblocks
frameBlockCount = 1;
idxF = 1;
for i=rangeF
    % Get oriented magnitudes of opticalFlow field for current frame
    omFrame = VectorField2D2OrientedMagnitude(numOr, opticalFlow(rangeR,rangeC,i));
    
    % Aggregate responses over rows and columns and frames
    for j=1:size(omFrame,3)
        blockHof{j}(:,:,idxF) = blockHof{j}(:,:,idxF) + ...
                                arrayA * omFrame(:,:,j) * arrayB;
    end
    
    % Keep track if feature should be added to this frame or next
    % I.e. this keep track of how we sum over frames
    frameBlockCount = frameBlockCount + 1;
    if frameBlockCount > blockSize(3)
        idxF = idxF + 1;
        frameBlockCount =1;
    end
end

% Concatenate all orientations to get HOFs per subblock
theBlockHof = zeros(length(blockHof{1}(:)), numOr);
for i=1:numOr
    theBlockHof(:,i) = blockHof{i}(:);
end
clear blockHof

% Get info structure
info = GetDenseInfoStructure3D([subBlocksR   subBlocksC   subBlocksF], ...
                               [blockSize(1) blockSize(2) blockSize(3)], ...
                               [offsetR      offsetC      offsetF]);

% Determine which blocks need to be taken together
% Note that subBlocksR is the total number blocks found in this video
% while numBlock denotes the number of desired blocks per HOF descriptor
indices = 1:(subBlocksR * subBlocksC * subBlocksF); % all indices
indices = reshape(indices, subBlocksR, subBlocksC, subBlocksF); % indices where subblock come from

% Now get coordinates for creating final features
totNumBlocks = numBlocks(1) * numBlocks(2) * numBlocks(3);
coordinates = cell(1, totNumBlocks);
idx = 1;
for k=1:numBlocks(3)
    for j=1:numBlocks(2)
        for i=1:numBlocks(1)
            coordinates{idx} = indices(i:end-numBlocks(1)+i, ...
                                       j:end-numBlocks(2)+j, ...
                                       k:end-numBlocks(3)+k);
            coordinates{idx} = coordinates{idx}(:);
            idx = idx + 1;
        end
    end
end
coordsFinal = cat(1, coordinates{:});

% Concatenate the features and reshape. The concatenation is done in such a
% way that the reshape gives the correct HOF features
hofs = theBlockHof(coordsFinal,:);
hofs = reshape(hofs, [], numOr * totNumBlocks);

% Update info structure by concatenating coordinates in the second
% dimension for each subcell (coordsFinal -> reshape) and then take the
% mean to get the middle coordinate of complete block
info.row = info.row(coordsFinal);
info.row = reshape(info.row, [], totNumBlocks);
info.row = mean(info.row, 2);

info.col = info.col(coordsFinal);
info.col = reshape(info.col, [], totNumBlocks);
info.col = mean(info.col, 2);

info.depth = info.depth(coordsFinal);
info.depth = reshape(info.depth, [], totNumBlocks);
info.depth = mean(info.depth, 2);

% Also add descriptor sizes to info structure
info.descSize = (blockSize .* numBlocks);
