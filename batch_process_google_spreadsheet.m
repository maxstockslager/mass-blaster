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
calib_metadata = convert_field_to_numeric(calib_metadata, 'bead_diam');
calib_metadata = convert_field_to_numeric(calib_metadata, 'bead_density');
calib_metadata = convert_field_to_numeric(calib_metadata, 'fluid_density');

for ii = 1 : length(metadata.expt_id)

    apply_calibration_to_file = false; % change to true at any point
    
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
       fprintf('Already found peaks for file %.0f (%s). ', ii, metadata.expt_id{ii});     
    elseif peak_file_already_exists && strcmp(metadata.redo_peak_detection{ii}, 'T')
        fprintf('Overwriting existing peak detection for file %.0f (%s).\n', ii, metadata.expt_id{ii});
        measure_peak_heights(full_directory);
        apply_calibration_to_file = true; 
    elseif ~peak_file_already_exists
        fprintf('No peak detection found for file %.0f (%s), processing now.\n', ii, metadata.expt_id{ii});
        measure_peak_heights(full_directory);
        apply_calibration_to_file = true; 
    end
        
    % Check whether calibration has already been applied
    mass_file_already_exists = check_for_file_in_directory(full_directory, 'masses.csv');
    if ~mass_file_already_exists || SETTINGS.reprocess_apply_calibration
        apply_calibration_to_file = true; 
    end
    
    % If calibration needs to be applied, do it now. 
    if ~apply_calibration_to_file
        fprintf('Already applied calibration to file %.0f (%s).\n', ii, metadata.expt_id{ii});        
    elseif apply_calibration_to_file
        fprintf('Applying calibration %s to file %.0f (%s).\n', ...
                 metadata.calib_id_to_use{ii}, ...
                 ii, ...
                 metadata.expt_id{ii});
                     
        if isempty(metadata.calib_id_to_use{ii})
            fprintf('Specify a calibration to use for this file!\n');
            continue
        end
        
        bead_metadata_rownumber = find(strcmp(calib_metadata.expt_id, metadata.calib_id_to_use{ii}));
        if isempty(bead_metadata_rownumber)
            fprintf('Did not find %s in the calibration metadata! Moving to next file.\n', ...
                    metadata.calib_id_to_use{ii});
            continue
        end
        
        full_bead_filename = fullfile(DATA_ROOT, ...
                      calib_metadata.parent_folder{bead_metadata_rownumber}, ...
                      calib_metadata.experiment_folder{bead_metadata_rownumber}, ...
                      'peak_measurements.mat');
  
        % Check whether peak heights have been detected for this bead
        % calibration file. 
        calib_file_exists = check_for_file_in_directory(full_bead_filename);
        if ~calib_file_exists
            fprintf('Calibration peaks not detected for file %s (calibration %s).\n', metadata.expt_id{ii}, metadata.calib_id_to_use{ii});
            fprintf('Continuing to next file.\n')
            continue
        end       
                  
        calib_settings = struct(...
            'bead_diameter', calib_metadata.bead_diam{bead_metadata_rownumber}, ...
            'fluid_density', calib_metadata.fluid_density{bead_metadata_rownumber}, ...
            'bead_density', calib_metadata.bead_density{bead_metadata_rownumber}, ...
            'min_beads_measured', 50, ...
            'max_bead_cv', 5 ...
        );
    
        apply_bead_calibration(full_filename, full_bead_filename, calib_settings);  
    end
       
 
end

