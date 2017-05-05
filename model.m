%% Predict Exercise Given Kinect Data

load('C:\Users\Steve\Desktop\ML Proj\data.mat','data');
dbstop if error

% Create holdout for cross validation, 67% train, 33% test
exPart = cvpartition(data.exercise,'HoldOut',0.33);
exTrain = training(exPart);
exTest = test(exPart);

% tabulate(data.exercise(exTrain));
% tabulate(data.exercise(exTest));

% OptimizeHyperparameters
% The optimization attempts to minimize the cross-validation loss (error) for fitcensemble by varying the parameters. 
% MaxNumSplits, MinLeafSize, NumVariablesToSample, SplitCriterion
% Find hyperparameters that minimize five-fold cross-validation loss by using automatic hyperparameter optimization.

% predictors
preds = data.Properties.VariableNames(10:1084);

% Set overallBest = 1 and currBest = 0 so that any classification error
% will be better on the first loop
overallBest=1;
currBest=0;

% Optimize hyperparameters for a tree ensemble, starting with all
% predictors. If the best model from the optimization is the best model so
% far, set it's classification error to the overallBest. Then find
% predictor importance, remove the predictors with the lowest 10%
% importance, and re-optimize. Repeat until the current optimization is
% worse than the previous, and save the best overall model
while currBest <= overallBest
    ens = fitcensemble(data(exTrain,preds),data.exercise(exTrain),'OptimizeHyperparameters','all');
    currBest = ens.HyperparameterOptimizationResults.MinObjective;
    if currBest < overallBest
        overallBest = currBest;
        exEns = ens;
    end
    imp = predictorImportance(ens);
    impSort = sort(imp);
    thresh = impSort(ceil(0.1*size(impSort,2)));
    predInd = find(imp>thresh);
    preds = preds(predInd);
end

%save('C:\Users\Steve\Desktop\ML Proj\Matlab\code\exEns.mat','exEns');

% Plot the classification error on the test set as the number of trees increases
figure;
plot(loss(exEns,data(exTest,exEns.PredictorNames),data.exercise(exTest),'mode','cumulative'));
xlabel('Number of trees');
ylabel('Classification error');

% Predict on the test set
predEx = predict(exEns,data(exTest,exEns.PredictorNames));

% Confusion Matrix
[exCM,order] = confusionmat(data.exercise(exTest),predEx);

%% Predict Groups

% SAME AS ABOVE, BUT PREDICTING GROUP GIVEN KINECT DATA AND EXERCISE

grpPart = cvpartition(data.group,'HoldOut',0.33);
grpTrain = training(grpPart);
grpTest = test(grpPart);

tabulate(data.group(grpTrain));
tabulate(data.group(grpTest));

% OptimizeHyperparameters
preds = data.Properties.VariableNames(7:1084);
preds(:,2:3) = [];
overallBest=1;
currBest=0;
while currBest <= overallBest
    ens = fitcensemble(data(grpTrain,preds),data.group(grpTrain),'OptimizeHyperparameters','all');
    currBest = ens.HyperparameterOptimizationResults.MinObjective;
    if currBest < overallBest
        overallBest = currBest;
        grpEns = ens;
    end
    imp = predictorImportance(ens);
    impSort = sort(imp);
    thresh = impSort(ceil(0.1*size(impSort,2)));
    predInd = find(imp>thresh);
    preds = preds(predInd);
end

%save('C:\Users\Steve\Desktop\ML Proj\Matlab\code\grpEns.mat','grpEns');

figure;
plot(loss(grpEns,data(grpTest,grpEns.PredictorNames),data.group(grpTest),'mode','cumulative'));
hold on;
xlabel('Number of trees');
ylabel('Classification error');

predGrp = predict(grpEns,data(grpTest,grpEns.PredictorNames));
[grpCM,order] = confusionmat(data.group(grpTest),predGrp);