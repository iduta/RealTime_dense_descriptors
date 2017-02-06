%%
clc
fprintf('##############################################################\n')
fprintf('Demo for fast dense descriptor extraction code for the papers:\n\n - J.R.R. Uijlings, I.C. Duta, E. Sangineto, and N. Sebe\n   "Video Classification with Densely Extracted HOG/HOF/MBH Features:\n   An Evaluation of the Accuracy/Computational Efficiency Trade-off"\n   In International Journal of Multimedia Information Retrieval (IJMIR), 2015.\n - I.C. Duta, J.R.R. Uijlings, T.A. Nguyen, K. Aizawa, A.G. Hauptmann, B. Ionescu, N. Sebe\n   "Histograms of Motion Gradients for Real-time Video Classification" \n   In International Workshop on Content-based Multimedia Indexing (CBMI), 2016.\n\n');
fprintf('Please cite our works when using this code!\n\n');
fprintf('This code requires the Matlab vision toolbox.\n');
fprintf('##############################################################\n\n')
% pause(1);
% Setup a global variable which contains the path of video files
global DATAopts
DATAopts.videoPath = '%s';

%settings
blockSize = [8 8 6]; % block size is 8 by 8 pixels by 6 frames, but we will vary the number of frames
numBlocks = [3 3 2]; % 3 x3 spatial blocks and 2 temporal blocks
numOr = 8; % Quantization in 8 orientations
flowMethod = 'Horn-Schunck'; % the optical flow choice

% Load the video
vidName = [pwd '/v_HulaHoop_g11_c04.avi'];

if exist('mmread', 'file')
    % Under Linux, Fedora 20, mmread was almost 5x faster. Just download mmread from:
    %       http://www.mathworks.co.uk/matlabcentral/fileexchange/8028-mmread
    % and make sure to set your path correctly
    fprintf('Using mmread to load video');
    tic;
    vid = VideoRead(vidName);
    videoReadTime = toc;
    fprintf('... took %.2f seconds\n', videoReadTime);
else
    fprintf('Using VideoReader from Matlab to load in video.\nWarning: We found that loading videos using native Matlab code (under Fedora 20) took more \ntime than the HOG features sampled at every frame. Instead, using the external library\nmmread loading a video is 8x faster. See comments in demo.m\n');
    tic
    vid = VideoReadNative(vidName);
    videoReadTime = toc;
    fprintf('Loaded video in %.2f seconds\n', videoReadTime);
end


%%
% For-loop over the sampling rate for HOG
fprintf('\nNow extracting HOG features. Timings below include loading the video (as in our paper):\n');
hogDesc = cell(4, 1);
hogInfo = cell(4, 1);
idx = 1;
for frameSampleRate=[1 2 3 6]
    tic
    % Subsample framerate of video
    sampledVid = vid(:,:,1:frameSampleRate:end);
    
    % Get correct number of frames per block
    blockSize(3) = 6 / frameSampleRate;
    
    % Get HOG descriptors
    [hogDesc{idx}, hogInfo{idx}] = Video2DenseHOGVolumes(sampledVid, blockSize, numBlocks, numOr);
    idx = idx + 1;
    
    % Print statistics
    extractionTimeHOG(idx) = toc;
    totalDescriptorTime = extractionTimeHOG(idx) + videoReadTime;
    fprintf('HOG: frames/block: %d sample rate: %d sec/vid: %.2f frame/sec: %.2f\n', ...
        blockSize(3), frameSampleRate, totalDescriptorTime, size(vid,3)/totalDescriptorTime);
end

%
% For-loop over the sampling rate for HOF
fprintf('\nNow extracting HOF features. Timings below include loading the video (as in our paper):\n');
hofDesc = cell(4, 1);
hofInfo = cell(4, 1);
idx = 1;
for frameSampleRate=[1 2 3 6]
    tic
    % Subsample framerate of video
    sampledVid = vid(:,:,1:frameSampleRate:end);
    
    % Get correct number of frames per block
    blockSize(3) = 6 / frameSampleRate;
    
    % Get HOG descriptors
    [hofDesc{idx}, hofInfo{idx}] = ...
        Video2DenseHOFVolumes(sampledVid, blockSize, numBlocks, numOr, flowMethod);
    idx = idx + 1;
    
    % Print statistics
    extractionTimeHOF(idx) = toc;
    totalDescriptorTime = extractionTimeHOF(idx) + videoReadTime;
    fprintf('HOF: frames/block: %d sample rate: %d sec/vid: %.2f frame/sec: %.2f\n', ...
        blockSize(3), frameSampleRate, totalDescriptorTime, size(vid,3)/totalDescriptorTime);
end

%
% For-loop over the sampling rate for MBH
fprintf('\nNow extracting MBH features. Timings below include loading the video (as in our paper):\n');
MBHRowDesc = cell(4, 1);
MBHColDesc = cell(4, 1);
mbhInfo = cell(4, 1);
idx = 1;
for frameSampleRate=[1 2 3 6]
    tic
    % Subsample framerate of video
    sampledVid = vid(:,:,1:frameSampleRate:end);
    
    % Get correct number of frames per block
    blockSize(3) = 6 / frameSampleRate;
    
    % Get HOG descriptors
    [MBHRowDesc{idx}, MBHColDesc{idx}, mbhInfo{idx}] = ...
        Video2DenseMBHVolumes(sampledVid, blockSize, numBlocks, numOr, flowMethod);
    idx = idx + 1;
    
    % Print statistics
    extractionTimeMBH(idx) = toc;
    totalDescriptorTime = extractionTimeMBH(idx) + videoReadTime;
    fprintf('MBH: frames/block: %d sample rate: %d sec/vid: %.2f frame/sec: %.2f\n', ...
        blockSize(3), frameSampleRate, totalDescriptorTime, size(vid,3)/totalDescriptorTime);
end

%%
% For-loop over the sampling rate for HOG
fprintf('\nNow extracting HMG features. Timings below include loading the video (as in our paper):\n');
hmgDesc = cell(4, 1);
hmgInfo = cell(4, 1);
idx = 1;
for frameSampleRate=[1 2 3 6]
    tic
    % Subsample framerate of video
    sampledVid = vid(:,:,1:frameSampleRate:end);
    
    % Get correct number of frames per block
    blockSize(3) = 6 / frameSampleRate;
    
    % Get HOG descriptors
    [hmgDesc{idx}, hmgInfo{idx}] = Video2DenseHMGVolumes(sampledVid, blockSize, numBlocks, numOr);
    idx = idx + 1;
    
    % Print statistics
    extractionTimeHMG(idx) = toc;
    totalDescriptorTime = extractionTimeHMG(idx) + videoReadTime;
    fprintf('HMG: frames/block: %d sample rate: %d sec/vid: %.2f frame/sec: %.2f\n', ...
        blockSize(3), frameSampleRate, totalDescriptorTime, size(vid,3)/totalDescriptorTime);
end

fprintf('\nDone!\n');