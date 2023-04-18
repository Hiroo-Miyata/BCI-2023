function [average_accuracy] = svm_cross_val(X, Y)

    % Shuffle the data
    n = size(X, 1);
    idx = randperm(n);
    X = X(idx, :);
    Y = Y(idx);

    % Define k-fold
    k_fold = 5;
    cv = cvpartition(Y, 'KFold', k_fold);

    % Initialize parameters
    svr_cs = 2 .^ (-7:12);
    svr_gammas = 2 .^ (-10:0);

    % Initialize average accuracy matrix
    average_accuracy = zeros(length(svr_cs), length(svr_gammas));

    % Perform cross-validation
    for i = 1:length(svr_cs)
        for k = 1:length(svr_gammas)
            accuracy = zeros(1, k_fold);
            for fold = 1:k_fold
                Xtrain = X(cv.training(fold), :);
                Ytrain = Y(cv.training(fold));
                Xtest = X(cv.test(fold), :);
                Ytest = Y(cv.test(fold));

                % Train the SVM model
                svm_model = fitcsvm(Xtrain, Ytrain, 'KernelFunction', 'rbf', ...
                    'BoxConstraint', svr_cs(i), 'KernelScale', 1/sqrt(svr_gammas(k)));

                % Test the SVM model
                Ypred = predict(svm_model, Xtest);

                % Calculate accuracy
                accuracy(fold) = sum(Ypred == Ytest) / length(Ytest);
            end
            % Save the average accuracy
            average_accuracy(i, k) = mean(accuracy);
        end
    end
end