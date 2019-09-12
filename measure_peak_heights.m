function measure_peak_heights(varargin) 

set(0,'DefaultFigureWindowStyle','docked')
addpath(fullfile(pwd, '\helper functions'))
close all

if ~isempty(varargin)  
    directory = varargin{1};
elseif isempty(varargin)
    directory = uigetdir('Z:\maxstock\222 systems');  
end

% Peak detection settings 
settings = struct(...
    'datarate', 12500, ...
    'quantile_width', 500, ...
    'quantile', 50, ...
    'quantile_decimation', 10, ...
    'min_peak_duration', 15/1000, ...
    'max_peak_duration', 300/1000, ...
    'min_peak_separation', 100/1000, ...
    'detection_threshold', -2.5, ...
    'pad_indices_ratio', 1, ...
    'baseline_fraction', 0.15, ...
    'peak_fit_window_fraction', 0.06, ...
    'poly_fit_order', 2, ...
    'sgolay_order', 3, ...
    'sgolay_length', 51, ...
    'baseline_deviation_limit', 3, ...
    'colors', linspecer(12), ...
    'max_peaks_to_plot', 100, ...
    'min_peaks_to_plot', 10, ...
    'plot_decimation', 10 ...
);

%%
data = load_data_from_directory(directory); % load .binf iles
data = prepare_for_detection(data, settings); % bandpass filter

%%
    
figs.peak_detection = figure;
for sensor_number = 1 : numel(data)
   
    fprintf('Detecting peaks in sensor %.0f...\n', sensor_number);
        peak_range_indices = detect_peaks(data(sensor_number).bandpass, settings);
    fprintf('    detected %.0f continuous segments below threshold...\n', length(peak_range_indices));
        current_sensor_peak_measurements = get_peak_data(data(sensor_number), peak_range_indices, settings);
    fprintf('    extracted frequency signal from these %.0f segments...\n', length(current_sensor_peak_measurements.raw_signal));
        current_sensor_peak_measurements = estimate_peak_heights(current_sensor_peak_measurements, settings); 
    fprintf('    estimated heights of these %.0f peaks... \n', length(current_sensor_peak_measurements.raw_signal));
    fprintf('    removing peaks that do not meet QC criteria...\n')
    [current_sensor_peak_measurements, rej_current_sensor_peak_measurements] = ...
        filter_peak_measurements(current_sensor_peak_measurements, settings);
    
    % plot accepted and rejected peaks
    figure(figs.peak_detection);
    make_peak_detection_plot(data, current_sensor_peak_measurements, sensor_number)
    plot_rejected_peaks(data, rej_current_sensor_peak_measurements, sensor_number)

    figure;
    plot_example_peaks(current_sensor_peak_measurements, settings)
    suptitle(sprintf('Sensor %.0f accepted peak examples', sensor_number));
   
    figure;
    plot_example_peaks(rej_current_sensor_peak_measurements, settings)
    suptitle(sprintf('Sensor %.0f rejected peak examples', sensor_number));
    
    if ~exist('peak_measurements')
        peak_measurements = current_sensor_peak_measurements;
    else
        peak_measurements(sensor_number) = current_sensor_peak_measurements;
    end
end

% Compile some experiment data (duration, datarate, total # peaks, ...)
summary = generate_summary_statistics(peak_measurements);
make_summary_plots(data, peak_measurements, summary, settings)
fprintf('Detected %.0f peaks in %.1f min (%.1f peaks/min).\n', summary.total_cell_number, ...
    summary.total_duration/60, summary.total_cell_number/(summary.total_duration/60));
fprintf('Median transit time %.1f ms\n', summary.medianTransitTime*1000);

% Export data
fprintf('Saving peak measurements... \n');
outputFilename = [directory, '\peak_measurements.mat'];
save(outputFilename, 'peak_measurements', 'settings', 'summary');
fprintf('Peak measurements saved. \n');

% Export spreadsheet
fprintf('Exporting data to spreadsheet...\n');
outputSpreadsheetFilename = strcat(directory, '\peaks.xlsx');
outputArray = [];
totalLength = max([peak_measurements.n_peaks]);

for sensor_number = 1 : numel(peak_measurements)     
    col1 = peak_measurements(sensor_number).peak_heights(:);
    col2 = peak_measurements(sensor_number).peak_durations_time(:);
    col1 = vertcat(col1, NaN(totalLength-length(col1), 1));
    col2 = vertcat(col2, NaN(totalLength-length(col2), 1));
    outputArray = [outputArray, col1, col2];
end

xlswrite(outputSpreadsheetFilename, outputArray)
fprintf('Saving summary figure...\n');
savefig(strcat(directory, '\peak_detection.fig'))

% end