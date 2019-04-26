function measure_peak_heights(varargin) 

set(0,'DefaultFigureWindowStyle','docked')
addpath(fullfile(pwd, '\helper functions'))
close all

if ~isempty(varargin)  
    directory = varargin{1};
elseif isempty(varargin)
    directory = uigetdir('Z:\maxstock\222 systems');  
end

sensors_to_skip = [];

% Peak detection settings 
settings = struct(...
    'datarate', 12500, ...
    'quantile_width', 500, ...
    'quantile', 50, ...
    'quantile_decimation', 10, ...
    'min_peak_duration', 8/1000, ...
    'max_peak_duration', 150/1000, ...
    'detection_threshold', -2, ...
    'pad_indices_ratio', 1.5, ...
    'baseline_fraction', 0.15, ...
    'peak_fit_window_fraction', 0.06, ...
    'poly_fit_order', 2, ...
    'sgolay_order', 3, ...
    'sgolay_length', 51, ...
    'baseline_deviation_limit', 0.5, ...
    'colors', linspecer(12), ...
    'max_peaks_to_plot', 100, ...
    'min_peaks_to_plot', 10, ...
    'plot_decimation', 10 ...
);

% get file names from structure
files = dir(fullfile(directory, '*.bin') );   % structure listing all *.bin files
files = {files.name}';    
if isempty(files)
    error(strcat('Did not find data in directory: ', directory))
end
    
% Read frequency signals
data(numel(files)) = struct('frequency_signal', []);
for sensor_number = 1 : numel(files)
    data(sensor_number).frequency_signal = read_frequency_signal(fullfile(directory, files{sensor_number}));
end

fprintf('Preparing signals for peak detection...\n');
parfor ii = 1 : numel(data)
    filt_data(ii) = get_filtered_signal_struct(data(ii), settings); 
end
data = filt_data; clear('filt_data');

% Plot peak detection
freqSignals = figure; figure(freqSignals)
for sensor_number = 1 : numel(data)
    subplot(ceil(numel(data)/2), 2, sensor_number);
    plot(data(sensor_number).bandpass(1:settings.plot_decimation:end), 'Color', 0.65*[1 1 1]);
    hold on
end
    
% Detect peaks under threshold. Get nx2 array of start+end indices.    
for sensor_number = 1 : numel(data)
    
    if any(sensors_to_skip == sensor_number)
       fprintf('***WARNING: skipping sensor %.0f***\n', sensor_number)
       continue
    end
    
    fprintf('Detecting peaks in sensor %.0f...\n', sensor_number);
    
    peak_range_indices = detect_peaks(data(sensor_number).bandpass, settings);
    fprintf('    detected %.0f continuous segments below threshold...\n', length(peak_range_indices));
   
    current_sensor_peak_measurements = get_peak_data(data(sensor_number), peak_range_indices, settings);
    fprintf('    extracted frequency signal from these %.0f segments...\n', length(current_sensor_peak_measurements.raw_signal));
    
    current_sensor_peak_measurements = estimate_peak_heights(current_sensor_peak_measurements, settings); 
    fprintf('    estimated heights of these %.0f peaks...\n', length(current_sensor_peak_measurements.raw_signal));

    [current_sensor_peak_measurements, n_accepted, n_rejected] = filter_peak_measurements(current_sensor_peak_measurements, settings);

    figure
    max_peaks_to_plot = 64; 
    for peak_number = 1:min([current_sensor_peak_measurements.n_peaks, max_peaks_to_plot])
        subplot(8, 8, peak_number)
        plot_peak_fit(current_sensor_peak_measurements.peak_plot_data(peak_number));
        hold on
        plot(get(gca, 'XLim'), settings.detection_threshold*[1 1], '--', 'Color', ...
            0.65*[1 1 1]);
    end
    
    suptitle(sprintf('Sensor %.0f peak detection', sensor_number));
    
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

end