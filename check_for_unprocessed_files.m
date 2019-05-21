clear all, close all

addpath(fullfile(pwd, '\helper functions'))

% input filenames and setings 
SETTINGS = struct(...
    'system', 'MB2', ...
    'sheet', '20190325-GBM', ...
    'reprocess_apply_calibration', false ...
);

switch SETTINGS.system
    case 'MB1'
        DATA_ROOT = 'Z:\maxstock\222 systems\Data - Mass blaster\';
    case 'MB2'
        DATA_ROOT = 'Z:\maxstock\222 systems\Data - Blue system\';
end 

metadata = read_google_spreadsheet(SETTINGS.system, SETTINGS.sheet);
calib_metadata = read_google_spreadsheet(SETTINGS.system, '');

files_to_review = {};
for ii = 1 : length(metadata.expt_id)
    apply_calibration_to_file = false; % change to true at any point
    
    full_directory = fullfile(DATA_ROOT, ...
                             metadata.parent_folder{ii}, ...
                             metadata.experiment_folder{ii});
    full_filename = fullfile(full_directory, ...
                             'peak_measurements.mat');
   
    fprintf('File %s: ', ...
        metadata.expt_id{ii});
    
    % Check whether data exists
    data_exists = check_for_file_in_directory(full_directory, 'c00.bin');
    if ~data_exists
        fprintf('SMR data **MISSING**.\n');
        files_to_review = [files_to_review, metadata.expt_id{ii}];
        continue
    end
    
    % If it does, check whether peaks have been detected
    peak_file_already_exists = check_for_file_in_directory(full_directory, 'peak_measurements.mat');
    if peak_file_already_exists && ~strcmp(metadata.redo_peak_detection{ii}, 'T')
       fprintf('peak detection done, '); 
    elseif ~peak_file_already_exists
        fprintf('peak detection **MISSING**.\n');
        files_to_review = [files_to_review, metadata.expt_id{ii}];
        continue
    end
        
    % If peak detection is done, check if calibration has been applied.
    mass_file_already_exists = check_for_file_in_directory(full_directory, 'masses.csv');
    if mass_file_already_exists
        fprintf('calibration applied.\n');
    elseif ~mass_file_already_exists
        fprintf('calibration **MISSING**.\n');
        files_to_review = [files_to_review, metadata.expt_id{ii}];
    end     
 
end

fprintf('\n');
fprintf('-------------------------- SUMMARY --------------------------\n')
if isempty(files_to_review)
    fprintf('No missing data.\n');
else
    fprintf('Review the following files:\n')
    for ii = 1 : numel(files_to_review)
        fprintf('%s\n', files_to_review{ii})
    end
end
