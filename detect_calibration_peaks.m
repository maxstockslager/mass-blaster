clear all, close all
addpath(fullfile(pwd, '\helper functions'))

% input filenames and setings 
SETTINGS = struct(...
    'system', 'MB2', ...
    'sheet', '' ...
);

switch SETTINGS.system
    case 'MB1'
        DATA_ROOT = 'Z:\maxstock\222 systems\Data - Mass blaster';
    case 'MB2'
        DATA_ROOT = 'Z:\maxstock\222 systems\Data - Blue system\';
end 

metadata = read_google_spreadsheet(SETTINGS.system, '');

for ii = 1 : length(metadata.expt_id)
   
    full_directory = fullfile(DATA_ROOT, ...
                             metadata.parent_folder{ii}, ...
                             metadata.experiment_folder{ii});
    full_filename = fullfile(full_directory, ...
                             'peak_measurements.mat');

    % Check whether data exists
    data_exists = check_for_file_in_directory(full_directory, 'c00.bin');
    if ~data_exists
        fprintf('Did not find data for file %s, skipping to next file.\n', ...
                metadata.expt_id{ii});
        continue
    end
    
    % Check whether peaks have been detected
    peak_file_already_exists = check_for_file_in_directory(full_directory, 'peak_measurements.mat');
    if peak_file_already_exists && ~strcmp(metadata.redo_peak_detection{ii}, 'T')
       fprintf('Already found peaks for file %.0f (%s). \n', ii, metadata.expt_id{ii});     
    elseif peak_file_already_exists && strcmp(metadata.redo_peak_detection{ii}, 'T')
        fprintf('Overwriting existing peak detection for file %.0f (%s).\n', ii, metadata.expt_id{ii});
        measure_peak_heights(full_directory);
        apply_calibration_to_file = true; 
    elseif ~peak_file_already_exists
        fprintf('No peak detection found for file %.0f (%s), processing now.\n', ii, metadata.expt_id{ii});
        measure_peak_heights(full_directory);
        apply_calibration_to_file = true; 
    end
 
end

