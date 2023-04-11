function outlierIdx = findOutliers(trial)
    %% trial: 68 * ntimes: 68 electrodes, ntimes: time points
    %% labels: 62 * 1: the name of trial(1:62) electrodes,
    %% fs: sampling rate 


    % 0.
    %% check the impedance of the electrodes

    meanV = zeros(size(trial, 1), 1);
    for i = 1:length(meanV)
        meanV(i) = mean(abs(trial(i, :)));
    end
    
    % 1. remove the electrode which has motion artifact
    % to detect the motion artifact, we use the variance of the trial
    % if the variance is too high, we remove the electrode
    % find the outlier from the distribution of variance
    threshold = 3 * iqr(meanV); % calculate threshold using interquartile range of variance
    outlierIdx = find(meanV > threshold); % find the index of outlier electrodes
    trial_filtered = trial;

    % also find the outlier from the distribution of variance
    % find too small variance
    variances = var(trial, 0, 2);
    iqr_var = iqr(variances);
    lower_threshold = prctile(variances, 25) - 1.5 * iqr_var; % calculate lower threshold
    upper_threshold = prctile(variances, 75) + 1.5 * iqr_var; % calculate upper threshold
    outlierIdx2 = find(variances < lower_threshold | variances > upper_threshold); % find the index of outlier electrodes

    outlierIdx = union(outlierIdx, outlierIdx2); % find the union of two outlier indices

    % figure;
    % subplot(2, 1, 1);
    % plot(1:size(trial, 1), meanV, 'o'); hold on;
    % plot(outlierIdx, meanV(outlierIdx), 'ro');
    % subplot(2, 1, 2);
    % plot(1:size(trial, 1), variances, 'o'); hold on;
    % plot(outlierIdx, variances(outlierIdx), 'ro');

    
    % close all
end
    
    
    
    