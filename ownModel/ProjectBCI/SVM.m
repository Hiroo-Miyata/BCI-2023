function [svmModel, accuracy] = SVM(data,label)


kfolds = 10;
fold_size = floor(length(label)/kfolds);

% shuffle
rng(1);
shuffledIndex = randperm(length(label));
shuffledData = data(shuffledIndex, :);
shuffledLabel = label(shuffledIndex);

% cross validation
accuracy = zeros(kfolds, 1);
% store trigger dimension which is orthogonal to the hyperplane
% hyperPlane = zeros(nneurons, kfolds);
for i = 1:kfolds
    % split data
    testIndex = (i-1)*fold_size+1:i*fold_size;
    trainIndex = setdiff(1:length(label), testIndex);
    Xtrain = shuffledData(trainIndex, :);
    Xtest = shuffledData(testIndex, :);
    Ytrain = shuffledLabel(trainIndex);
    Ytest = shuffledLabel(testIndex);
    
    svmModel{i} = fitcsvm(Xtrain, Ytrain); %, 'KernelFunction', 'rbf', 'KernelScale', 'auto', 'Standardize', true, 'BoxConstraint', 1, 'ClassNames', [0, 1]);

    % Predict class labels for testing data
    Ypred = predict(svmModel{i}, Xtest);

    % Evaluate classification performance
    accuracy(i) = sum(Ypred == Ytest) / length(Ytest);
    confusionMat{i} = confusionmat(Ytest, Ypred);
end