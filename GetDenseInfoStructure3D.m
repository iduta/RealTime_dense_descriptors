function info = GetDenseInfoStructure3D(numSubregions, regionSize, offset)
% info = GetDenseInfoStructure(imSize, regionSize)
%
% Gets the info structure for Dense Features. Calculates row,col,frame
% coordinates
%
% numSubregions: 1 x 3 vector denoting the number of subregions in 
%                [row, col, depth] direction
% regionSize:    1 x 3 vector with size of the descriptor
% offset:        1 x 3 vector with the offset where first descriptor starts
%
% info:         info structure used for a.o. making feature spatial
%   row:        row coordinate per feature
%   col:        col coordinate per feature
%   depth:      depth coordinate per feature
%
%       Jasper Uijlings - 2013

% Meshgrid gets the correct consecutive indices
[col, row, depth] = meshgrid(1:numSubregions(2), ...
                             1:numSubregions(1), ...
                             1:numSubregions(3));

% Multiply meshgrid with indices and add offset to get end points of descriptors
% '-(regionSize(i)-1)/2) is to get middle point of descriptors
info.row = row(:) * regionSize(1) + (offset(1) - (regionSize(1)-1)/2);
info.col = col(:) * regionSize(2) + (offset(2) - (regionSize(2)-1)/2);
info.depth = depth(:) * regionSize(3) + (offset(3) - (regionSize(3)-1)/2);
