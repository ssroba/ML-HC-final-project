%% Tidy Kinect Data

load('C:\Users\Steve\Desktop\ML Proj\kinectTable.mat','kinectTable')

% Rearrange colunns and make p_id strings
fullTable = kinectTable;
fullTable = fullTable(:,[76:80 1:75]);
fullTable.p_id = cellstr(fullTable.p_id);

% Set to correct file location, read table and set variable names
patients = readtable('C:\Users\Steve\Desktop\ML Proj\participant_details.csv');
patients.Properties.VariableNames = {'p_id', 'age', 'gender', 'group',...
    'weight', 'height', 'warning'};

% Merge kinect data with patient data by matching p_id and rearrange
% columns
fullTable = outerjoin(fullTable,patients,'MergeKeys',true);
fullTable = fullTable(:,[1 81:86 2:80]);

% Names of joints 1:25 recorded by Kinect
joints = {'SpineBase','SpineMid','Neck','Head','ShoulderLeft',...
    'ElbowLeft','WristLeft','HandLeft','ShoulderRight','ElbowRight',...
    'WristRight','HandRight','HipLeft','KneeLeft','AnkleLeft','FootLeft',...
    'HipRight','KneeRight','AnkleRight','FootRight','SpineShoulder',...
    'HandTipLeft','ThumbLeft','HandTipRight','ThumbRight'};

% Create new vector of variable names leaving out all joint variables, and
% add start, which will be 1 if the row is the start of a new record
varNames = fullTable.Properties.VariableNames;
varNames = varNames(1:11);
varNames = [varNames,'start'];

% for each joint, concatenate x, y and z, and add all 3 to varnames
for j = 1:25
    joint = joints(j);
    x = strcat(joint,'_x');
    y = strcat(joint,'_y');
    z = strcat(joint,'_z');
    varNames = [varNames, x, y, z];
end

% Add variable start to fulltable
% If the row is the start of a new record, start = 1, otherwise 0
fullTable.start = nan(size(fullTable,1),1);
fullTable(1,'start') = {1};
for i=2:size(fullTable,1)
    if((fullTable{i,8}~=fullTable{i-1,8})||(fullTable{i,9}~=fullTable{i-1,9}))
        fullTable(i,'start') = {1};
    else
        fullTable(i,'start') = {0};
    end
end

% Rearrange columns
fullTable = fullTable(:,[1:11 87 12:86]);

% Set fulltable's variable names to varnames
fullTable.Properties.VariableNames = varNames;

% Create cleanTable, which has NaN in all rows where clean = 0
noise = fullTable{:,10} == 0;
cleanTable = fullTable;
cleanTable{noise,13:87} = NaN;

save('C:\Users\Steve\Desktop\ML Proj\fullTable.mat','fullTable')
save('C:\Users\Steve\Desktop\ML Proj\cleanTable.mat','cleanTable')

%% Create MoCap Objects
% Objects formatted to work with the MoCap Toolbox

load('C:\Users\Steve\Desktop\ML Proj\fullTable.mat','fullTable')
load('C:\Users\Steve\Desktop\ML Proj\cleanTable.mat','cleanTable')

% Get the start and stop indexes for all records
startRows = fullTable{:,'start'}==1;
starts = find(startRows);
stops = zeros(size(starts,1),1);
for i = 2:(size(starts,1))
    stops(i-1) = starts(i)-1;
end
stops(size(starts,1)) = size(fullTable,1);

% Create a struct array called moCaps, with each row containing a moCap
% object for a single record, to be used with the MoCap Toolbox
for i = 1:size(starts,1)
    
    start = starts(i);
    stop = stops(i);
    
    mocap.type = 'MoCap data';
    mocap.filename = '';
    mocap.nCameras = 1;
    mocap.nMarkers = 25;
    mocap.freq = 30;
    mocap.nAnalog = 0;
    mocap.anaFreq = 0;
    mocap.timederOrder = 0;
    mocap.analogdata = [];
    mocap.markerName = {'SpineBase';'SpineMid';'Neck';'Head';'ShoulderLeft';...
        'ElbowLeft';'WristLeft';'HandLeft';'ShoulderRight';'ElbowRight';...
        'WristRight';'HandRight';'HipLeft';'KneeLeft';'AnkleLeft';'FootLeft';...
        'HipRight';'KneeRight';'AnkleRight';'FootRight';'SpineShoulder';...
        'HandTipLeft';'ThumbLeft';'HandTipRight';'ThumbRight'};
    mocap.start = start;
    mocap.stop = stop;
    mocap.nFrames = stop-start+1;
    mocap.p_id = char(fullTable{start,1});
    mocap.age = fullTable{start,2};
    mocap.gender = char(fullTable{start,3});
    mocap.group = fullTable{start,4};
    mocap.weight = fullTable{start,5};
    mocap.height = fullTable{start,6};
    mocap.warning = fullTable{start,7};
    mocap.e_id = fullTable{start,8};
    mocap.t_id = fullTable{start,9};
    mocap.clean = fullTable{start:stop,10};
    mocap.time = fullTable{start:stop,11};
    mocap.data = fullTable{start:stop,13:87};
    mocap.cleanData = cleanTable{start:stop,13:87};
    
    moCaps(i) = mocap;
    
end

save('C:\Users\Steve\Desktop\ML Proj\moCaps.mat','moCaps')

%% Fill Missing Data

load('C:\Users\Steve\Desktop\ML Proj\moCaps.mat','moCaps')

% moCap Toolbox function to fill gaps in moCap data, with a max gap of 100
% frames. Gaps are the 'unclean' data
for i = 1:size(moCaps,2)
    moCaps(i).data = moCaps(i).cleanData;
    filled = mcfillgaps(moCaps(i), 100);
    moCaps(i).data = filled.filledData;
end

save('C:\Users\Steve\Desktop\ML Proj\moCaps.mat','moCaps');

%% Trim Ends

load('C:\Users\Steve\Desktop\ML Proj\moCaps.mat','moCaps');
dbstop if error

% Remove data and timestamps at the beginning/end of records that is not
% clean because this was not filled in by mcfillgaps()
% Adjust time so that the first timestamp of every record starts at 0
for i =1:size(moCaps,2)
    data = moCaps(i).data;
    time = moCaps(i).time;
    
    time(all(data==0,2),:)=[];
    data(all(data==0,2),:)=[];
    
    time = time - time(1);
    
    moCaps(i).data = data;
    moCaps(i).time = time;
end
save('C:\Users\Steve\Desktop\ML Proj\moCaps.mat','moCaps');

%% Adjust Time
load('C:\Users\Steve\Desktop\ML Proj\moCaps.mat','moCaps');
dbstop if error

% Make timestamps in units of seconds
for i =1:size(moCaps,2)
    time = moCaps(i).time;
    time = (time-time(1))/10000000;
    moCaps(i).time = time;
end

save('C:\Users\Steve\Desktop\ML Proj\moCaps.mat','moCaps');

%% Feature Extraction

clear variables
close all

load('C:\Users\Steve\Desktop\ML Proj\moCaps.mat','moCaps');
dbstop if error

% Initialize struct of correct size called feats
obs = size(moCaps,2);
feats(obs).p_id = 0;

% Loop through all records and create features
for i = 1:obs
    feats(i).p_id = moCaps(i).p_id;
    feats(i).age = moCaps(i).age;
    feats(i).gender = moCaps(i).gender;
    feats(i).group = moCaps(i).group;
    feats(i).weight = moCaps(i).weight;
    feats(i).height = moCaps(i).height;
    feats(i).warning = moCaps(i).warning;
    feats(i).exercise = moCaps(i).e_id;
    feats(i).trial = moCaps(i).t_id;
    feats(i).length = max(moCaps(i).time);
    
    data = moCaps(i);
    
    % moCap Toolbox functions to calculate SD, mean, skewness, kurtosis,
    % and variance
    feats(i).sd = mcstd(data);
    feats(i).mean = mcmean(data);
    feats(i).skew = mcskewness(data);
    feats(i).kurt = mckurtosis(data);
    feats(i).var = mcvar(data);
    
    % Signal peak analysis
    time = data.time;
    
    % Loop through each joint/axis (25 joints, 3 axes)
    for j = 1:75
        
        d = data.data;
        d = d(:,j);
        
        %Peak analysis
        try
            %pks = peak values, locs = locations
            [pks,locs] = findpeaks(d,time);
            % Number of peaks
            feats(i).nPks(j) = length(pks);
            % Mean distribution between each peak
            feats(i).meanPeakDist(j) = mean(diff(locs));
        catch
            % If none are found, set to NaN
            feats(i).nPks(j) = NaN;
            feats(i).meanPeakDist(j) = NaN;
        end
    end
    
    % moCap Toolbox to calculate velocity of each joint at each time point
    vel = mctimeder(data,1);
    feats(i).maxVel = max(vel.data);
    feats(i).meanVel = mean(vel.data);
    feats(i).minVel = min(vel.data);
    
    % moCap Toolbox to calculate acceleration of each joint at each time point
    acc = mctimeder(data,2);
    feats(i).maxAcc = max(acc.data);
    feats(i).meanAcc = mean(acc.data);
    feats(i).minAcc = min(acc.data);
    
    % moCap Toolbox to calculate displacement of each joint at each time point
    try
        % Had some errors, so added catch to continue in case of an error
        norm = mccumdist(data);
        feats(i).disp = max(norm.data);
    catch
        feats(i).disp = NaN;
    end
    
    % moCap Toolbox to calculate periodicity of each joint at each time point
    feats(i).period = mcperiod(data);
    
end

data = feats;

save('C:\Users\Steve\Desktop\ML Proj\data.mat','data');

%% Expand Features so that each cell contains 1 value

load('C:\Users\Steve\Desktop\ML Proj\data.mat','data');
load('C:\Users\Steve\Desktop\ML Proj\jointNames.mat','jointNames');
dbstop if error

vars = fieldnames(data);
axes = {'X'; 'Y'; 'Z'};
obs = size(data,2);
feats(obs).p_id = 0;

% For every row, create correct variable names by combining joints/axes,
% and set 1 value for every cell
for i = 1:obs
    d = data(i);
    % Bad records, to be removed
    if strcmp(data(i).p_id,'28_AB') || strcmp(data(i).p_id,'28_FB')
        continue;
    end
    feats(i).p_id = data(i).p_id;
    feats(i).age = data(i).age;
    feats(i).gender = data(i).gender;
    feats(i).group = data(i).group;
    feats(i).weight = data(i).weight;
    feats(i).height = data(i).height;
    feats(i).warning = data(i).warning;
    feats(i).exercise = data(i).exercise;
    feats(i).trial = data(i).trial;
    feats(i).length = data(i).length;
    for j = 11:25
        var = vars{j,1};
        varData = d.(var);
        for k = 1:25
            joint = jointNames{k,1};
            if strcmp(var,'disp')
                feats(i).(strcat(joint,'_',var)) = varData(k);
            else
                for a = 1:3
                    axis = axes{a,1};
                    feats(i).(strcat(joint,'_',axis,'_',var)) = varData(3*k +(a - 3));
                end
            end
        end
    end
end

% Convert to table
feats = struct2table(feats);
save('C:\Users\Steve\Desktop\ML Proj\feats.mat','feats');
%% Clean Feats Data

load('C:\Users\Steve\Desktop\ML Proj\feats.mat','feats');

% % Create Categorical variables
% feats.p_id = categorical(feats.p_id);
% feats.gender = categorical(feats.gender);
% feats.group = categorical(feats.group);
% feats.warning = categorical(feats.warning);
% feats.exercise = categorical(feats.exercise);

% Bad records
feats(196:212,:) = [];

% vars = feats(:,1:10);
% summary(vars);

% Remove the warning variable since no patients have a warning now
feats.warning = [];

% vars = feats(:,1:9);
% summary(vars);

save('C:\Users\Steve\Desktop\ML Proj\feats.mat','feats');

%% ExerciseNames

load('C:\Users\Steve\Desktop\ML Proj\feats.mat','feats');

% Change groups and exercises from number values to strings to make it
% easier to tell which is which
for i = 1:size(feats,1)
    ex = table2cell(feats(i,'exercise'));
    ex = ex{1,1};
    switch ex
        case 1
            feats(i,'exercise') = cell2table(cellstr('Balance (2-leg Open Eyes)'));
        case 2
            feats(i,'exercise') = cell2table(cellstr('Balance (2-leg Closed Eyes)'));
        case 3
            feats(i,'exercise') = cell2table(cellstr('Chair Rise'));
        case 4
            feats(i,'exercise') = cell2table(cellstr('Jump (Minimum)'));
        case 5
            feats(i,'exercise') = cell2table(cellstr('Jump (Maximum)'));
        case 6
            feats(i,'exercise') = cell2table(cellstr('One-Leg Balance (Closed Eyes)'));
        case 7
            feats(i,'exercise') = cell2table(cellstr('One-Leg Balance (Open Eyes)'));
        case 8
            feats(i,'exercise') = cell2table(cellstr('Semi-Tandem Balance'));
        case 9
            feats(i,'exercise') = cell2table(cellstr('Tandem Balance'));
        case 10
            feats(i,'exercise') = cell2table(cellstr('Walking (Towards the Kinect)'));
        case 11
            feats(i,'exercise') = cell2table(cellstr('Walking (Away from the Kinect)'));
        case 12
            feats(i,'exercise') = cell2table(cellstr('Timed-Up-and-Go'));
        otherwise
            feats(i,'exercise') = cell2table(cellstr('Hopping (one-leg)'));
    end
    
    group = table2cell(feats(i,'group'));
    group = group{1,1};
    switch group
        case 1
            feats(i,'group') = cell2table(cellstr('young'));
        case 2
            feats(i,'group') = cell2table(cellstr('old athletic'));
        otherwise
            feats(i,'group') = cell2table(cellstr('old'));
    end
end

% Remove unused categories
% feats.exercise = removecats(feats.exercise);
% feats.group = removecats(feats.group);

data = feats;

save('C:\Users\Steve\Desktop\ML Proj\data.mat','data');