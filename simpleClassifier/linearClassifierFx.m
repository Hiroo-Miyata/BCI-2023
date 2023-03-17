%% Linear Classifier Assignment

function rawOutput = linearClassifierFx(trial,labels,fs)
%% Part 1b: Preprocessing

%Cut trial into windows
windowLength = 160; %Window length in samples
windowStride = 40; %How often to update the window in samples
numOfWindows = 1+((size(trial,2)-windowLength)/windowStride);               %Calculate number of windows
windows = [];                                                               
for i = 1:numOfWindows
    windowStart = windowStride*(i-1) + 1;                                   %The start index of the windows. For 40ms shift this is: (1, 41, 81, etc.)
    windowEnd = windowStart+windowLength-1;
    windows(end+1,:,:) = trial(:,windowStart:windowEnd);
end

%% Part 2: 

%Get electrode numbers from labels
c3LaplacianLabels = ["FC3", "C1", "C5", "CP3"];                                            %The labels of electrodes in the Laplcaian filter for C3 (use lowercase letters after the first: Fcz)
c3LaplacianNumbers = [];
for label = c3LaplacianLabels
    c3LaplacianNumbers(end+1) = find(strcmp(labels,label));                  %Find the corresponding electrode number in 'labels'
end
c4LaplacianLabels = ["FC4", "C2", "C6", "CP4"];
c4LaplacianNumbers = [];
for label = c4LaplacianLabels
    c4LaplacianNumbers(end+1) = find(strcmp(labels,label));
end
c3 = find(strcmp(labels,'C3'));
c4 = find(strcmp(labels,'C4'));

%Perform spatial filtering
c3Filt = [];
c4Filt = [];
for windowNumber = 1:size(windows,1)
    currentWindow = squeeze(windows(windowNumber,:,:));
    c3Filt(end+1,:) = currentWindow(c3,:) - mean(currentWindow(c3LaplacianNumbers,:),1); %C3 - average of Laplacian electrodes. Make sure to take the average across channels, not time
    c4Filt(end+1,:) = currentWindow(c4,:) - mean(currentWindow(c4LaplacianNumbers,:),1); %C4 - average of Laplacian electrodes
end

%% Part 3:
% Use the Burg method with a 16th order model to estimate the power spectral density (PSD) from 0 to
% 30 Hz for each window of channels C3 and C4. You can use the function pburg in MATLAB or the
% spectrum python package. The online decoder estimated frequencies from 0 to 30 Hz at intervals of
% every 0.2 Hz, but again you are encouraged to explore other values as well. Please take a careful look at
% the inputs and outputs of the pburg function (use “help pburg” in the MATLAB command window or use
% the MATLAB documentation).

%Analyze one window at a time
c3alpha = [];
c4alpha = [];
for windowNumber = 1:size(windows)
    currentC3 = squeeze(c3Filt(windowNumber,:));
    currentC4 = squeeze(c4Filt(windowNumber,:));
    %Estimate power spectrum
    % The online decoder estimated frequencies from 0 to 30 Hz at intervals of every 0.2 Hz
    [spectrumC3,f] = pburg(currentC3, 16, [0:0.2:30], fs); %Use the Burg method with a 16th order model to estimate the power spectral density (PSD) from 0 to 30 Hz for each window of channels C3 and C4
    [spectrumC4,f] = pburg(currentC4, 16, [0:0.2:30], fs);
    %Sum points between 10.5 and 13.5 Hz
    c3alpha(end+1)=sum(spectrumC3(f>=10.5 & f<=13.5)); %Sum points between 10.5 and 13.5 Hz
    c4alpha(end+1)=sum(spectrumC4(f>=10.5 & f<=13.5));
end

%% Part 4: Linear Classifier
% As discussed in lecture, motor imagery causes Event-Related Desynchronization (ERD) or Event-Related
% Synchronization (ERS) in the sensorimotor cortex. Specifically, hand motor imagery will cause ERD in the
% alpha power of the sensorimotor region of the contralateral (opposite side) hemisphere. Motor imagery
% of the right hand will result in a lower alpha power in the C3 electrode channel, and motor imagery of the
% left hand will cause a lower alpha power in C4. Therefore, by comparing the alpha power between these
% two electrodes, you can try to determine which hand the subject is imagining moving.

% For each window, subtract the C3 alpha power from the C4 alpha power. This is the raw output
% signal for the simple decoder. Set a copy of these values aside for Part 5. 
% Linear classifer
rawOutput = c3alpha - c4alpha;




