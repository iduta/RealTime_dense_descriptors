function ogIm = Image2OrientedGradientsHaar(im, numOr)
% Converts image into gray image. Then creates a n x m x 8 array where for
% each of 8 orientations (starting with y, and going clockwise), a
% magnitude is given. In contrast to Image2OrientedGradients,
% edge responses are calculated using haar features (-1 0 1) instead of a
% gaussian window. Furthermore, for a single pixel the magnitude is divided
% over only 2 orientation bins.
%
% im:               N x M The image
% numOr(optional):  Number of orientations (8 is default)
%
% ogIm:             N x M x numOr orientation responses
%
% Jasper Uijlings, 2013

if nargin == 1
    numOr = 8; % Default: 8 orientations
end

% Convert to proper image class
if isa(im, 'uint8')
    warning('Image should be double');
    im = im2double(im);
end

if size(im,3) == 3
    warning('Image should be grayscale. Converting to grayscale');
    im = rgb2gray(im);
end

ogIm = zeros(size(im,1), size(im,2), numOr);

% Get pixel-differences (haar-based)
rowIm = im(1:end-2, 2:end-1) - im(3:end,2:end-1);
colIm = im(2:end-1, 1:end-2) - im(2:end-1,3:end);

% One could have used VectorField2D2OrientedMagnitude. But inline is 10%
% faster...
% ogIm(2:end-1,2:end-1,:) = VectorField2D2OrientedMagnitude(numOr, rowIm, colIm);

% Calculate magnitude and angle
magIm = sqrt(rowIm .* rowIm + colIm .* colIm);
angleIm = atan2(rowIm, colIm);

% Now get orientation bins
binReal = (angleIm) * (numOr / (2 * pi));
binLow = floor(binReal);
weightHigh = binReal - binLow;
weightLow = 1 - weightHigh;
binLow = mod(binLow, numOr) + 1; % 15% speed increase is mod is removed
binHigh = binLow + 1;
binHigh(binHigh == (numOr+1)) = 1;

% Now add the lower bin
[colI, rowI] = meshgrid(2:size(im,2)-1, 2:size(im,1)-1);
indLow = sub2ind(size(ogIm), rowI(:), colI(:), binLow(:));
ogIm(indLow) = ogIm(indLow) + ...
                    magIm(:) .* weightLow(:);

% And the higher bin
indHigh = sub2ind(size(ogIm), rowI(:), colI(:), binHigh(:));
ogIm(indHigh) = ogIm(indHigh) + ...
                    magIm(:) .* weightHigh(:);
