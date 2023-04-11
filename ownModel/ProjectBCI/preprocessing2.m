function rawOutput = preprocessing2(trial,labels,fs)
    %% trial: 68 * ntimes: 68 electrodes, ntimes: time points
    %% labels: 62 * 1: the name of trial(1:62) electrodes,
    %% fs: sampling rate 


    % 0.
    %% check the impedance of the electrodes
    LaplacianLabels = ["C3", "Fc3", "C1", "C5", "Cp3", "F3", "Fc5", "T7", "Cp5", "P3", "Cp1", "Cz", "Fc1", ...
                        "C4", "Fc4", "C2", "Cp4", "C6", "F4", "Fc2", "Cz", "Cp2", "P4", "Cp6", "T8", "Fc6"];                                        %The labels of electrodes in the Laplcaian filter for C3 (use lowercase letters after the first: Fcz)
    LaplacianNumbers = [];
    for label = LaplacianLabels
        LaplacianNumbers(end+1) = find(strcmp(labels,label));                  %Find the corresponding electrode number in 'labels'
    end
    
    trial_measured = trial(LaplacianNumbers, :);

    meanV = zeros(size(trial_measured, 1), 1);
    for i = 1:length(meanV)
        meanV(i) = mean(abs(trial_measured(i, :)));
    end
    
    % 1. remove the electrode which has motion artifact
    % to detect the motion artifact, we use the variance of the trial
    % if the variance is too high, we remove the electrode
    % find the outlier from the distribution of variance
    threshold = 3 * iqr(meanV); % calculate threshold using interquartile range of variance
    outlierIdx = find(meanV > threshold); % find the index of outlier electrodes
    trial_filtered = trial_measured;
    % trial_filtered(outlierIdx, :) = []; % remove outlier electrodes

    figure;
    subplot(2, 1, 1);
    plot(LaplacianNumbers, meanV, 'o'); hold on;
    plot(LaplacianNumbers(outlierIdx), meanV(outlierIdx), 'ro');

 
    rawOutput = trial_highpass';
    close all
end
    
    
    
    