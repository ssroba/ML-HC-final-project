%% Import
kinectTable = table();

% Set k3da equal to the location of the k3DA folder
k3da = 'C:\Users\Steve\Desktop\ML Proj\k3DA';

% patients = the names of folders in k3DA (each patient has a folder)
patients = dir(k3da);

% Loop through all folders
% starts at 3 because 2 irrelevant files are created when calling dir(k3da))
for p = 3:(size(patients,1))
    
    % current patient = current folder
    patient = patients(p).name;                         
    disp(patient);
    
    % add current patient folder to file path and enter folder
    pfolder = fullfile(k3da,patient);                   
    cd(pfolder);
    
    % records = the names of folders in the patient folder
    records = dir(pfolder);
    
    % Loop through all folders
    for r = 3:size(records,1)
        
        % current record = current folder
        rec = records(r).name;                          
        
        % Extract trial number from folder name
        [~,remainder] = strtok(rec,'_');                
        [~,remainder2] = strtok(remainder,'_');
        [exercise,remainder3] = strtok(remainder2,'_');
        trial = strtok(remainder3,'_');
        
        % add current record folder to file path and enter folder
        rfolder = fullfile(pfolder,rec); 
        cd(rfolder);
        
        % if a raw data file exists, read both the raw and clean files,
        % otherwise continue to the next iteration of the loop
        % clean files have timestamps corresponding to clean data in the raw files
        if exist(fullfile(rfolder,'skeletons_raw.csv'),'file')==2
            raw = readtable(fullfile(rfolder,'skeletons_raw.csv'));
            clean = readtable(fullfile(rfolder,'skeletons_clean.csv'));
        else
            continue;
        end
        
        % set the patient id, exercise id, trial id, and clean timestamps
        % related to the raw file
        raw.p_id = repmat(patient,size(raw,1),1);
        raw.e_id = repmat(str2double(exercise),size(raw,1),1);
        raw.t_id = repmat(str2double(trial),size(raw,1),1);
        raw.clean = ones(size(raw,1),1);
        
        % if an outlier file exists, read the timestamps and combine with
        % the clean timestamps to get all timestamps for the raw file
        if exist(fullfile(rfolder,'skeletons_outlier.csv'),'file')==2
            outliers = readtable(fullfile(rfolder,'skeletons_outlier.csv'));
            timeStamps = sort([table2array(clean(:,1));table2array(outliers(:,1))]);
            
            % set raw.clean = 0 for all outliers so we know which points are outliers
            for i = 1:size(outliers,1)
                raw(table2array(outliers(i,2)),'clean') = {0};
            end
        else
            % if no outlier file exists, set timestamps = the timestamps
            % from clean
            timeStamps = table2array(clean(:,1));
        end
        
        % if the number of timestamps and number of rows of raw data match,
        % set raw.time = timestamps and add the data to kinectTable
        if size(raw,1) == length(timeStamps)
            raw.time = timeStamps;
        else
            continue
        end
        
        kinectTable = [kinectTable;raw];
    end
end

% save('C:\Users\Steve\Desktop\ML Proj\kinectTable.mat','kinectTable')
