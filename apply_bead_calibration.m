function apply_bead_calibration(varargin) 

% Settings
sensors_to_drop = []; 

if isempty(varargin)
    bead_filenames = 'Z:\maxstock\222 systems\Data - Mass blaster\20190326 Calibration\1 8um PS\peak_measurements.mat';
    expt_filename = strcat(uigetdir('Z:\maxstock\222 systems'), '\peak_measurements.mat');
    calib_settings.bead_diameter = 8; % um
    calib_settings.fluid_density = 1.003; % g/mL
    calib_settings.bead_density = 1.049; % g/mL
    calib_settings.min_beads_measured = 100; 
    calib_settings.max_bead_cv = 5; 

else
    expt_filename = varargin{1};
    bead_filenames = varargin{2};
    calib_settings = varargin{3};
end

if ~isempty(sensors_to_drop)
    fprintf('WARNING: dropping all peaks from sensor %.0f\n', sensors_to_drop);
end

% Read in bead data & measurement data
% sensitivities = merge_bead_calibrations(bead_filenames, calib_settings); 
sensitivities = get_sensitivities(bead_filenames, calib_settings);
peak_measurements = read_peak_data(expt_filename);
peak_measurements = apply_calibration(peak_measurements, sensitivities);
sensors_to_drop = union(sensors_to_drop, find(isnan(sensitivities)));
save_mass_measurements(expt_filename, peak_measurements, sensors_to_drop)

       
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [peak_measurements, summary, settings] = read_peak_data(expt_filename)
   load(expt_filename) 
   if exist('peakMeasurements')
       peak_measurements = peakMeasurements;
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function peak_measurements = apply_calibration(peak_measurements, sensitivities)

for sensor_number = 1 : numel(peak_measurements)
   peak_measurements(sensor_number).buoyant_mass = ...
       peak_measurements(sensor_number).peak_heights ./ sensitivities(sensor_number);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save spreadsheets with peak_measurements added
function save_mass_measurements(expt_filename, peak_measurements, sensors_to_drop)
idx = strfind(expt_filename, 'peak_measurements.mat');
directory = expt_filename(1:(idx-1));
output_filename = strcat(directory, 'masses.csv');

buoyant_mass = [];
transit_time = [];
sensor_number = [];
peak_height = [];

for ii = 1 : numel(peak_measurements)
    if ~any(ii == sensors_to_drop) && ~isempty(peak_measurements(ii).n_peaks)
        buoyant_mass = [buoyant_mass;
                        peak_measurements(ii).buoyant_mass(:)];
        transit_time = [transit_time;
                        peak_measurements(ii).peak_durations_time(:)];
        sensor_number = [sensor_number;
                          repmat(ii, peak_measurements(ii).n_peaks, 1)];

        peak_height = [peak_height;
                       peak_measurements(ii).peak_heights(:)];
    end
end

output_array = horzcat(buoyant_mass, ...
                       transit_time, ...
                       sensor_number, ...
                       peak_height);
                       
output_colnames = 'buoyant_mass, transit_time, sensor_number, peak_height\n';
fid = fopen(output_filename, 'w');
fprintf(fid, output_colnames);
fclose(fid);
dlmwrite(output_filename, output_array, '-append');

end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Merge multiple bead calibration runs into one
% function sensitivities = merge_bead_calibrations(bead_filenames, calib_settings)
% sensitivities = compare_calibrations(bead_filenames, calib_settings);
% end

