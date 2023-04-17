 clear all; close all;

%reading in a folder
%myFolder = uigetdir();
load("neuroscanChannelLabels68.mat")
theFiles = dir(fullfile('./MatData', '*.mat'));%myFolder
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

%%% Preprocessing %%%
%{
Optional Steps:
remove unnecessary electrodes
bandpass filtering
LaPlacian filtering
detrend
artifact removal
convert to frequency
%}



preprocessed = cell(numRuns, numTrials);
for k = 1:numRuns
    for j = 1:numTrials
        trial = runData{k}.trials{j}(LaplacianNumbers,:);
        outlierIdx = findOutliers(trial);
        preprocessed{k,j} = preprocessing(trial,LaplacianLabels,fs, []);
        % preprocessed{k,j} = preprocessing(trial,labels,fs);
    end 
end

% channels = [1:3 5:64]; %EXCLUDE Channel 4 for run 1 trial 1


%%% Feature Extraction %%%
% common spatial patterns (CSP)
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

% % make the amount of trial equal in each class
% minIdx = min(size(X1,2), size(X2,2));
% X1 = X1(:, 1:minIdx);
% X2 = X2(:, 1:minIdx);

% data1 = X1';
% data2 = X2';
% % Plot the generated data and their directions
% subplot(1,2,1);
% scatter(data1(:,1), data1(:,2)); hold on;
% scatter(data2(:,1), data2(:,2)); hold on;
% legend('class 1', 'class 2'); hold off;
% grid on; axis equal;
% title('Before CSP filtering');
% xlabel('Channel 1'); ylabel('Channel 2');
% % CSP
% [W,l,A] = csp(X1,X2);
% X1_CSP = W'*X1;
% X2_CSP = W'*X2;
% % Plot the results
% subplot(1,2,2);
% scatter(X1_CSP(1,:), X1_CSP(2,:)); hold on;
% scatter(X2_CSP(1,:), X2_CSP(2,:)); hold on;
% legend('class 1', 'class 2'); hold off;
% axis equal; grid on;
% title('After CSP filtering');
% xlabel('Channel 1'); ylabel('Channel 2');


%%% Classification %%%
%{
Classifying Options:
linear classifier
support vector machines (SVM)
linear discriminant analysis (LDA)
decision trees/random forest
AdaBoost
AI/deep learning
%}

%[svmModel, accuracy] = SVM(data,label)

% data = [X1_CSP X2_CSP];
% label = [ones(1,size(X1_CSP,2)) 2*ones(1,size(X2_CSP,2))];
% [svmModel, accuracy] = SVM(data',label');

% disp(mean(onlineCorrect(2,:)));
% disp(mean(accuracy));

data = [X1 X2];
% run PCA
[coeff, score, latent, tsquared, explained, mu] = pca(data');
% plot the explained variance
figure;
plot(cumsum(explained));
xlabel('Number of Components');
ylabel('Variance (%)'); %for each component

% choose the number of components
numComponents = 10;
% project the data
data = score(:,1:numComponents);
data = data';

label = [ones(1,size(X1,2)) 2*ones(1,size(X2,2))];
[svmModel, accuracy] = SVM(data',label');

disp(mean(onlineCorrect(2,:)));
disp(mean(accuracy));
%%% Apply Decoder %%%


%%% Compare Performance to Online %%%


%%% Statistical Comparison of Performances %%%



