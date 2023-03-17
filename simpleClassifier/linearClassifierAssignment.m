%% Linear Classifier Main Script

%This is the main script for the linear classifier assignment/demo. You
%should also have received the "assignmentData.mat" file and 
%"linearClassifierFx.m" function along with this script.
%% Part 1a: Load Data

%Load data
load("assignmentData.mat")

%Select one trial
trial = signal{1};

%Stop here and open "linearClassifierFx.m" for parts 1b to 4
%Once you have finished Part 4, continue below:

%% Part 5: Normalizer

%Run the linear classifier on all of the trials
rawOutputs = {};
for i = 1:length(signal)
    trial = signal{i};
    rawOutputs{end+1} = linearClassifierFx(trial,labels,fs);
end

%Compute the average of all the outputs
normalizerMean = mean(cellfun(@mean,rawOutputs));

%Normalize the outputs (subtract the mean from each output)
normOutputs = cellfun(@(x) x - normalizerMean,rawOutputs,'UniformOutput',0);

%Calculate position
rawPosition = cellfun(@cumsum,rawOutputs,'UniformOutput',0);
normPosition = cellfun(@cumsum,normOutputs,'UniformOutput',0);

%Raw output plot
figure;
subplot(2,1,1)
title('Raw Output')
plot(rawOutputs{1},'b')
ylabel('Velocity')
subplot(2,1,2)
plot(rawPosition{1},'g')
ylabel('Position')

%Normalized output plot
figure;
subplot(2,1,1)
title('Normalized Output')
plot(normOutputs{1},'b')
ylabel('Velocity')
subplot(2,1,2)
plot(normPosition{1},'g')
ylabel('Position')

%% Part 6: Evaluation

figure;
numOfTrials = length(signal);
for i = 1:numOfTrials
    subplot(numOfTrials,1,i)
    plot(normPosition{i},'g')
    ylabel(strcat('Trial ',num2str(i),' Position'))
end

%Based on Figure 3, which side of the screen is target 1 on? Target 2?