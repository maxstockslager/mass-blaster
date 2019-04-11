clear all, close all

% input filenames and setings 
reprocess_apply_calibration = false; 
addpath(fullfile(pwd, '\helper functions'))

system = 'MB1'; % MB1 or MB2
sheet = '20190408-Macrophages'; % name of google sheet


switch system
    case 'MB1'
        data_root = 'Z:\maxstock\222 systems\Data - Mass blaster';
    case 'MB2'
        data_root = 'Z:\maxstock\222 systems\Data - Blue system\';

end 

metadata = read_google_spreadsheet(system, sheet);
calib_metadata = read_google_spreadsheet(system, '');
calib_metadata = convert_field_to_numeric(calib_metadata, 'bead_diam');
calib_metadata = convert_field_to_numeric(calib_metadata, 'bead_density');
calib_metadata = convert_field_to_numeric(calib_metadata, 'fluid_density');


for ii = 1 : length(metadata.expt_id)

    apply_calibration_to_file = false; % change to true at any point
    
    full_directory = fullfile(data_root, ...
                             metadata.parent_folder{ii}, ...
                             metadata.experiment_folder{ii});
    full_filename = fullfile(full_directory, ...
                             'peak_measurements.mat');

    peak_file_already_exists = check_for_file_in_directory(full_directory, 'peak_measurements.mat');
    
    if peak_file_already_exists & ~strcmp(metadata.redo_peak_detection{ii}, 'T')
       fprintf('Already found peaks for file %.0f. ', ii);     
    elseif peak_file_already_exists & strcmp(metadata.redo_peak_detection{ii}, 'T')
        fprintf('Overwriting existing peak detection for file %.0f.\n', ii);
        measure_peak_heights(full_directory);
        apply_calibration_to_file = true; 
    elseif ~peak_file_already_exists
        fprintf('No peak detection found for file %.0f, processing now.\n', ii);
        measure_peak_heights(full_directory);
        apply_calibration_to_file = true; 
    end
        
    mass_file_already_exists = check_for_file_in_directory(full_directory, 'masses.csv');
    if ~mass_file_already_exists | reprocess_apply_calibration
        apply_calibration_to_file = true; 
    end
    
    
    if apply_calibration_to_file
        fprintf('Applying calibration #%.0f to file %.0f.\n', ...
                 metadata.calib_id_to_use{ii}, ...
                 ii);
         
        bead_metadata_rownumber = find(cell2mat(calib_metadata.expt_id) == metadata.calib_id_to_use{ii});
        full_bead_filename = fullfile(data_root, ...
                      calib_metadata.parent_folder{bead_metadata_rownumber}, ...
                      calib_metadata.experiment_folder{bead_metadata_rownumber}, ...
                      'peak_measurements.mat');

        calib_settings.bead_diameter = calib_metadata.bead_diam{bead_metadata_rownumber}; % um
        calib_settings.fluid_density = calib_metadata.fluid_density{bead_metadata_rownumber}; % g/mL
        calib_settings.bead_density = calib_metadata.bead_density{bead_metadata_rownumber}; % g/mL
        calib_settings.min_beads_measured = 50; 
        calib_settings.max_bead_cv = 5; 
        
        apply_bead_calibration(full_filename, full_bead_filename, calib_settings);  
                
    elseif ~apply_calibration_to_file
        fprintf('Already applied calibration to file %.0f.\n', ii);
    end
       
 
end

