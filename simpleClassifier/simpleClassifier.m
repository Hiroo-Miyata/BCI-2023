
%% Part 1: load assignmentData.mat
% the variables in this file are:
% signal: a cell array containing EEG recordings from 5 trials of a BCI experiment. Each trial should contain
% 62 channels, one for each electrode, in the format [# of channels, # of samples].
% targets: a list of targets from the original BCI experiment. These are the targets that the subject
% attempted to move a cursor towards by performing motor imagery, but keep in mind that they may not
% have been successful in every trial.
% fs: the sampling frequency of the data.
% labels: a list of electrode labels that correspond to the row numbers in ‘signal’

load('assignmentData.mat')
nlabels = length(labels);
nchannels = size(signal{1},1);
nsamples = size(signal{1},2);

% To simulate analyzing data in an online experiment, cut each trial’s data into overlapping windows.
% The online experiment used 160ms long windows that shifted every 40ms, but you may explore other
% values as well. At the end, your data for each trial should have a similar format to the following
% dimension: [# of windows, # of channels, # samples per window] 
windowSize = 160; % in ms
windowShift = 40; % in ms
windowSize = windowSize*fs/1000;
windowShift = windowShift*fs/1000;
nwindows = floor((nsamples-windowSize)/windowShift)+1;
splittedSignal = cell(1, length(signal));
for i = 1:length(signal)
    splittedSignal{i} = zeros(nwindows, nchannels, windowSize);
    for j = 1:nwindows
        splittedSignal{i}(j,:,:) = signal{i}(:,(j-1)*windowShift+1:(j-1)*windowShift+windowSize);
    end
end

%% Part 2: Small Laplacian Spatial Filtering
% Due to the volume conduction problem discussed during lecture, EEG channels that are located close
% together often share many features. One way to emphasize features that are specific to a certain
% electrode is to apply a spatial filter across the EEG channels. Here, you will use a Laplacian spatial filter
% to emphasize the features specific to electrodes C3 and C4, which lie over the sensorimotor cortex in each
% hemisphere.

% A small Laplacian filter uses the four electrodes immediately surrounding the electrode of interest
% for spatial filtering (front, back, left, and right electrodes). Determine which electrodes should be used
% for a small Laplacian filter around C3, and which should be used for a small Laplacian filter around C4.

surroundingElectrodes_C3 = ["FC3", "C1", "C5", "CP3"];
surroundingElectrodes_C4 = ["FC4", "C2", "C6", "CP4"];
% find the index of the electrodes from labels
surroundingElectrodes_C3 = find(ismember(labels, surroundingElectrodes_C3));
surroundingElectrodes_C4 = find(ismember(labels, surroundingElectrodes_C4));
c3 = find(ismember(labels, "C3"));
c4 = find(ismember(labels, "C4"));

% Laplacian filtering is performed by subtracting the average EEG signal of the surrounding channels
% from the channel of interest. Apply a small Laplacian filter to C3 and C4 using the channels you identified
% in Part 2a by subtracting the average of the four Laplacian channels from the channel of interest.
function [filteredSignal] = laplacianFiltering(signal, surroundingElectrodes, channel)
    filteredSignal = squeeze(signal(:. channel, :));
    for i = 1:size(signal,1)
        filteredSignal(i,:) = squeeze(signal(i,channel,:) - mean(signal(i,surroundingElectrodes,:),2));
    end
end

filteredSignal_C3 = laplacianFiltering(splittedSignal{1}, surroundingElectrodes_C3, c3);
filteredSignal_C4 = laplacianFiltering(splittedSignal{1}, surroundingElectrodes_C4, c4);


%% Part 3: Autoregressive Power Spectrum Estimate (Burg Method)
% There are several well established methods for analyzing the frequency spectrum of a time-series signal.
% For this assignment, you will use the Burg Method, which is a parametric method that is also sometimes
% referred to as an Autoregressive or AR method. These AR methods can obtain better spectral estimations
% than FFT methods for short signals, such as the windows used here.


% Use the Burg method with a 16th order model to estimate the power spectral density (PSD) from 0 to
% 30 Hz for each window of channels C3 and C4. You can use the function pburg in MATLAB or the
% spectrum python package. The online decoder estimated frequencies from 0 to 30 Hz at intervals of
% every 0.2 Hz, but again you are encouraged to explore other values as well. Please take a careful look at
% the inputs and outputs of the pburg function (use “help pburg” in the MATLAB command window or use
% the MATLAB documentation).

function [psd] = burgMethod(signal, fs, frequencyRange)
    psd = zeros(size(signal,1), 151);
    for i = 1:size(signal,1)
        [psd(i,:), f] = pburg(squeeze(signal(i,:)), 16, 151, fs);
    end
    % estimate the power spectral density from 0 to 30 Hz
    psd = psd(:, f>=frequencyRange(1) & f<=frequencyRange(2));
end

% Take the average of the PSD values from Part 3 in the 10.5-13.5 Hz range for each individual
% window. This can be considered the “high” alpha band power of the EEG signal and is the predominant
% EEG feature for this simple decoder. You should now have two values for each data window, one for the
% high-alpha band power in C3 and one for C4.

psd_C3 = burgMethod(filteredSignal_C3, fs, [0, 30]);
psd_C4 = burgMethod(filteredSignal_C4, fs, [0, 30]);
highAlpha_C3 = mean(psd_C3(:, 53:67), 2);
highAlpha_C4 = mean(psd_C4(:, 53:67), 2);


