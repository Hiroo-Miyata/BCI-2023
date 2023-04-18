clear all; close all;

folders = ["./MatData/S1LR", "./MatData/S1UD"]; % , "./MatData/S2LR", "./MatData/S2UD"

for thefolder = folders
load("neuroscanChannelLabels68.mat")
theFiles = dir(fullfile(thefolder, '*.mat'));%myFolder
numRuns = length(theFiles);
numTrials = 25;
for k = 1 : length(theFiles)
    %fprintf(1, 'Now reading %s\n', fullFileName);
    temp{k} = load(fullfile(theFiles(k).folder, theFiles(k).name)); %readtable for excel or load for mat
    runData{k} = temp{k}.runData;
end
fs = runData{1}.fs;

clear temp;
clear theFiles;

%%% PVC and PTC %%%
for k = 1:numRuns
    onlineCorrect(1,k) = sum(runData{k}.outcome==1)/sum(runData{k}.outcome~=0); %PVC
    onlineCorrect(2,k) = sum(runData{k}.outcome==1)/numTrials; %PTC
    onlineCorrect(3,k) = sum(runData{k}.outcome==-1)/numTrials; %PTC
end

%%% setting %%%

LaplacianLabels = ["C3", "Fc3", "C1", "C5", "Cp3", "F3", "Fc5", "T7", "Cp5", "P3", "Cp1", "Cz", "Fc1", ...
                    "C4", "Fc4", "C2", "Cp4", "C6", "F4", "Fc2", "Cp2", "P4", "Cp6", "T8", "Fc6"];                                        %The labels of electrodes in the Laplcaian filter for C3 (use lowercase letters after the first: Fcz)
LaplacianNumbers = [];
for label = LaplacianLabels
    LaplacianNumbers(end+1) = find(strcmp(labels,label));                  %Find the corresponding electrode number in 'labels'
end

preprocessed = cell(numRuns, numTrials);
for k = 1:numRuns
    for j = 1:numTrials
        trial = runData{k}.trials{j}(LaplacianNumbers,:);
        outlierIdx = findOutliers(trial);
        preprocessed{k,j} = preprocessing(trial,LaplacianLabels,fs, []);
        % preprocessed{k,j} = preprocessing(trial,labels,fs);
    end 
end

X1 = [];
X2 = [];
for k = 1:numRuns
    for j = 1:numTrials
        target = runData{k}.target(j);
        if target == 1
            X1 = cat(2, X1, preprocessed{k,j});
        elseif target == 2
            X2 = cat(2, X2, preprocessed{k,j});
        end
    end
end

data = [X1 X2];
data = normalize(data, 1);
% run PCA
[coeff, score, latent, tsquared, explained, mu] = pca(data');
% plot the explained variance
figure;
plot(cumsum(explained));
xlabel('Number of Components');
ylabel('Variance (%)'); %for each component

% choose the number of components
numComponents = 20;
% project the data
data = score(:,1:numComponents);
data = data';

label = [ones(1,size(X1,2)) 2*ones(1,size(X2,2))];

figure;
scatter(score(1:size(X1,2), 3), score(1:size(X1,2),4), 10, 'red', 'filled'); hold on;
scatter(score(size(X1,2)+1:end, 3), score(size(X1,2)+1:end,4), 10, 'blue', 'filled'); hold on;
legend(["class 1", "class 2"], Location='best'); hold off;
grid on; axis equal;
title('after PCA');
xlabel('PC1'); ylabel('PC2');

% [svmModel, accuracy] = SVM(data',label');
[accuracy] = SVM_new(data',label');

disp(mean(onlineCorrect(2,:)));
disp(max(accuracy(:)));

end

