%% Linear Classifier Assignment

function rawOutput = preprocessing(trial,labels,fs, outlierIdx)
    %% Part 1: 
    
    %Get electrode numbers from labels
    c3LaplacianLabels = ["Fc3", "C1", "C5", "Cp3"];                                     %The labels of electrodes in the Laplcaian filter for C3 (use lowercase letters after the first: Fcz)
    c3LaplacianNumbers = getIdxFromLabel(labels, c3LaplacianLabels, outlierIdx);
    c4LaplacianLabels = ["Fc4", "C2", "C6", "Cp4"];
    c4LaplacianNumbers = getIdxFromLabel(labels, c4LaplacianLabels, outlierIdx);
    c3LaplacianLabels2 = ["F3", "Fc5", "T7", "Cp5", "P3", "Cp1", "Cz", "Fc1"];
    c3LaplacianNumbers2 = getIdxFromLabel(labels, c3LaplacianLabels2, outlierIdx);
    c4LaplacianLabels2 = ["F4", "Fc6", "T8", "Cp6", "P4", "Cp2", "Cz", "Fc2"];
    c4LaplacianNumbers2 = getIdxFromLabel(labels, c4LaplacianLabels2, outlierIdx);

    c3 = find(strcmp(labels,'C3'));
    c4 = find(strcmp(labels,'C4'));
    
    % closest laplacian electrodes
    % c3Filt = trial(c3,:) - mean(trial(c3LaplacianNumbers,:),1);
    % c4Filt = trial(c4,:) - mean(trial(c4LaplacianNumbers,:),1);
    
    D = size(trial, 2);
    window = round(0.1*fs):D;
    signals = zeros(10, size(trial(:, window),2));
    nelectrodes = size(trial, 1);
    signals(1,:) = trial(c3, window);
    signals(2,:) = trial(c4, window);
    signals(3:6,:) = trial(c3LaplacianNumbers, window);
    signals(7:10,:) = trial(c4LaplacianNumbers, window);


    % c3Filt = trial(c3,round(0.1*fs):end);
    % c4Filt = trial(c4,round(0.1*fs):end);
    
    % far laplacian electrodes
    % c3Filt(end+1,:) = trial(c3,:) - mean(trial(c3LaplacianNumbers2,:),1);
    % c4Filt(end+1,:) = trial(c4,:) - mean(trial(c4LaplacianNumbers2,:),1);

    % Define frequency bands
    % delta_band = [1 4];
    % theta_band = [4 8];
    alpha_band = [8 13];
    % beta_band = [13 30];
    % gamma_band = [30 100];
    
    rawOutput = zeros(nelectrodes, 1);

    for i = 1:nelectrodes
        rawOutput(i) = bandpower(signals(i,:), fs, alpha_band);
    end

    % Calculate power for each frequency band
    % c3_features.delta = bandpower(c3Filt, fs, delta_band);
    % c3_features.theta = bandpower(c3Filt, fs, theta_band);
    % c3_features.alpha = bandpower(c3Filt, fs, alpha_band);
    % c3_features.beta = bandpower(c3Filt, fs, beta_band);
    % c3_features.gamma = bandpower(c3Filt, fs, gamma_band);

    % c4_features.delta = bandpower(c4Filt, fs, delta_band);
    % c4_features.theta = bandpower(c4Filt, fs, theta_band);
    % c4_features.alpha = bandpower(c4Filt, fs, alpha_band);
    % c4_features.beta = bandpower(c4Filt, fs, beta_band);
    % c4_features.gamma = bandpower(c4Filt, fs, gamma_band);

    % rawOutput(1) = c3_features.delta;
    % rawOutput(2) = c3_features.theta;
    % rawOutput(3) = c3_features.alpha;
    % rawOutput(4) = c3_features.beta;
    % rawOutput(5) = c3_features.gamma;
    % rawOutput(6) = c4_features.delta;
    % rawOutput(7) = c4_features.theta;
    % rawOutput(8) = c4_features.alpha;
    % rawOutput(9) = c4_features.beta;
    % rawOutput(10) = c4_features.gamma;

end
    
    
    
    