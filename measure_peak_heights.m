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
settings.datarate =  12500; %
settings.quantile_width = 500; % width of moving quantile window. 1000>10
settings.quantile = 50; % percentile for moving quantile filter
settings.quantile_decimation = 10; % decimation factor for quantile filter 
settings.min_peak_duration = 8/1000; % sec
settings.max_peak_duration = 150/1000; % sec

settings.detection_threshold = -2; % Hz
settings.pad_indices_ratio = 1.5; % pad the peak with this multiple of its length on either side 
settings.baseline_fraction = 0.15; % for detection, baseline is this fraction of signal at beginning/end
settings.peak_fit_window_fraction = 0.06;
settings.poly_fit_order = 2; 
settings.sgolay_order = 3;
settings.sgolay_length = 51; % ONLY use this for peak DETECTION, not fitting 
settings.baseline_deviation_limit = 0.5; % left and right baseline must be within this amount

% Plotting settings 
settings.colors = linspecer(12);
settings.max_peaks_to_plot = 100; 
settings.min_peaks_to_plot = 10; % don't plot anything if we see fewer than this many peaks
settings.plot_decimation = 10; 

% get file names from structure
files = dir(fullfile(directory, '*.bin') );   % structure listing all *.bin files
files = {files.name}';    
    
% Read frequency signals
data(numel(files)) = struct('frequency_signal', []);
for sensor_number = 1 : numel(files)
    data(sensor_number).frequency_signal = read_frequency_signal(fullfile(directory, files{sensor_number}));
end

fprintf('Preparing signals for peak detection...\n');
parfor ii = 1 : numel(data)
% for ii = 1 : numel(data)
    filt_data(ii) = get_filtered_signal_struct(data(ii), settings); 
end
data = filt_data; clear('filt_data');

% % Plot peak detection
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
    
%     if isempty(peak_range_indices)
%         
%         continue;
%         
%     end

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
% if input('Save data? ')
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
% fprintf('Writing summary pdf...\n');
% save_open_figures_to_pdf(directory);

end



%% read_frequency_signal
function frequency_signal = read_frequency_signal(filename)
fileID = fopen(filename, 'r', 'b');
frequency_signal = fread(fileID, 'uint32');
frequency_signal(1:129:end) = [];
frequency_signal = frequency_signal * (12.5e6/2^32); 
fclose(fileID);
end

%% moving_quantile
function baseline = moving_quantile(signal, decimation, quantile_width, quantile_value)

    downsampled = signal(1:decimation:end);
    baseline = running_percentile(downsampled, quantile_width, quantile_value);
    baseline = repmat(baseline, 1, decimation)';
    baseline = baseline(:);
    baseline = baseline(1:length(signal));
    
end

%% running_percentile
function y = running_percentile(x, win, p, varargin)
%RUNNING_PERCENTILE Median or percentile over a moving window.
%   Y = RUNNING_PERCENTILE(X,WIN,P) returns percentiles of the values in 
%   the vector Y over a moving window of size win, where p and win are
%   scalars. p = 0 gives the rolling minimum, and p = 100 the maximum.
%
%   running_percentile(X,WIN,P,THRESH) includes a threshold where NaN will be
%   returned in areas where the number of NaN values exceeds THRESH. If no
%   value is specified the default is the window size / 2.

% Check inputs
N = length(x);
if win > N || win < 1
    error('window size must be <= size of X and >= 1')
end
if length(win) > 1
    error('win must be a scalar')
end
if p < 0 || p > 100
    error('percentile must be between 0 and 100')
end
if ceil(win) ~= floor(win)
    error('window size must be a whole number')
end
if ~isvector(x)
    error('x must be a vector')
end

if nargin == 4
    NaN_threshold = varargin{1};
else
    NaN_threshold = floor(win/2);
end

% pad edges with data and sort first window
if iscolumn(x)
    x = [x(ceil(win/2)-1 : -1 : 1); x; x(N : -1 : N-floor(win/2)+1); NaN];
else
    x = [x(ceil(win/2)-1 : -1 : 1), x, x(N : -1 : N-floor(win/2)+1), NaN];
end
tmp = sort(x(1:win));
y = NaN(N,1);

offset = length(ceil(win/2)-1 : -1 : 1) + floor(win/2);
numnans = sum(isnan(tmp));

% loop
for i = 1:N
	% Percentile levels given by equation: 100/win*((1:win) - 0.5);
	% solve for desired index
	pt = p*(win-numnans)/100 + 0.5;
    if numnans > NaN_threshold;   % do nothing
    elseif pt < 1        % not enough points: return min
		y(i) = tmp(1);
	elseif pt > win-numnans     % not enough points: return max
		y(i) = tmp(win - numnans);
	elseif floor(pt) == ceil(pt);  % exact match found
		y(i) = tmp(pt);
	else             % linear interpolation
		pt = floor(pt);
		x0 = 100*(pt-0.5)/(win - numnans);
		x1 = 100*(pt+0.5)/(win - numnans);
		xfactor = (p - x0)/(x1 - x0);
		y(i) = tmp(pt) + (tmp(pt+1) - tmp(pt))*xfactor;
    end
    
	% find index of oldest value in window
	if isnan(x(i))
		ix = win;  						  % NaN are stored at end of list
		numnans = numnans - 1;
	else
		ix = find(tmp == x(i),1,'first');
	end
	
	% replace with next item in data
	newnum = x(offset + i + 1);
	tmp(ix) = newnum;
	if isnan(newnum)
		numnans = numnans + 1;
	end
	tmp = sort(tmp);

end
end

%%
function filteredPeakRangeIndices = detect_peaks(signal, settings)
    
    indicesBelowThreshold = find(signal < settings.detection_threshold);
    
    if isempty(indicesBelowThreshold)
        filteredPeakRangeIndices = [];
        return
    end
    
    peakStartIndices = indicesBelowThreshold([1; 1+find(diff(indicesBelowThreshold) ...
        > settings.min_peak_duration * settings.datarate)]);
    peakEndIndices = indicesBelowThreshold([find(diff(indicesBelowThreshold) ...
        > settings.min_peak_duration * settings.datarate); numel(indicesBelowThreshold)]);
    peak_range_indices = [peakStartIndices(:), peakEndIndices(:)];
    
    
    
    peakDuration_indices = peak_range_indices(:, 2) - peak_range_indices(:, 1);
    peakDuration_time = peakDuration_indices / settings.datarate;
    
    filteredPeakMask = (peakDuration_time > settings.min_peak_duration) ...
        & (peakDuration_time < settings.max_peak_duration);
    filteredPeakRangeIndices = peak_range_indices(filteredPeakMask, :);
    
%     % Plots for debugging
%     figure
%     plot(signal, 'k'); hold on
%     for peak_number = 1 : length(filteredPeakRangeIndices)
%         plot(filteredPeakRangeIndices(peak_number, 1) : filteredPeakRangeIndices(peak_number, 2), ...
%             signal(filteredPeakRangeIndices(peak_number, 1) : filteredPeakRangeIndices(peak_number, 2)), ...
%             'r');
%     end
%     
end

%%
function currentPeakData = get_peak_data(currentData, peak_range_indices, settings)

if isempty(peak_range_indices)
    currentPeakData.raw_signal = {};
    currentPeakData.bandpassSignal = {};
    currentPeakData.lowpassSignal = {};
    currentPeakData.baselineSignal = {};
    currentPeakData.peakRangesIncludingBaseline = []; 
    currentPeakData.raw_signal = {};
    currentPeakData.bandpassSignal = {};
    currentPeakData.lowpassSignal = {};
    currentPeakData.baselineSignal = {};
    currentPeakData.peakRangesIncludingBaseline = [];
    currentPeakData.peakRanges = [];  
    currentPeakData.peak_durations_indices = [];
    currentPeakData.peak_durations_time = []; 
    currentPeakData.n_peaks = 0;
    currentPeakData.totalDuration_indices = [];
    currentPeakData.totalDuration_time = []; 
    return
end

peak_durations_indices = peak_range_indices(:, 2) - peak_range_indices(:, 1);
peak_durations_time = peak_durations_indices / settings.datarate; 

% Initialize (in case there are no peaks)
currentPeakData.raw_signal = {};
currentPeakData.bandpassSignal = {};
currentPeakData.lowpassSignal = {};
currentPeakData.baselineSignal = {};
currentPeakData.peakRangesIncludingBaseline = []; 

    for peak_number = 1 : numel(peak_durations_indices)
       peakRangeIncludingBaseline = ...
           [peak_range_indices(peak_number, 1) - ...
           ceil(settings.pad_indices_ratio * peak_durations_indices(peak_number)), ...
           peak_range_indices(peak_number, 2) + ...
           ceil(settings.pad_indices_ratio * peak_durations_indices(peak_number))];
       peakRangeIncludingBaseline(peakRangeIncludingBaseline < 1) = 1; 
       peakRangeIncludingBaseline(peakRangeIncludingBaseline > length(currentData.bandpass)) = length(currentData.bandpass);

       peak_dataIncludingBaseline = currentData.bandpass(...
           peakRangeIncludingBaseline(1) : peakRangeIncludingBaseline(2));
       rawPeakDataIncludingBaseline = currentData.frequency_signal(...
           peakRangeIncludingBaseline(1) : peakRangeIncludingBaseline(2));
       lowpassPeakDataIncludingBaseline = currentData.lowpass(...
           peakRangeIncludingBaseline(1) : peakRangeIncludingBaseline(2));

       currentPeakData.raw_signal{peak_number} = rawPeakDataIncludingBaseline;
       currentPeakData.bandpassSignal{peak_number} = peak_dataIncludingBaseline; 
       currentPeakData.lowpassSignal{peak_number} = lowpassPeakDataIncludingBaseline;
       currentPeakData.baselineSignal{peak_number} = ...
           currentPeakData.lowpassSignal{peak_number} - currentPeakData.bandpassSignal{peak_number};
       
       currentPeakData.peakRangesIncludingBaseline(peak_number, :) = ...
           peakRangeIncludingBaseline;

    end
    

    % Save the stuff we want into peak_data     
    currentPeakData.peakRanges = peak_range_indices;  
    currentPeakData.peak_durations_indices = peak_durations_indices;
    currentPeakData.peak_durations_time = peak_durations_time; 
    currentPeakData.n_peaks = numel(currentPeakData.peak_durations_time);
    currentPeakData.totalDuration_indices = length(currentData.bandpass);
    currentPeakData.totalDuration_time = currentPeakData.totalDuration_indices / settings.datarate; 

end

%
function peak_measurements_output = estimate_peak_heights(peak_measurements_input, settings)

peak_measurements_output = peak_measurements_input; % Initialize
peak_heights_vector = []; % initialize 
baseline_subtracted_signal_array = {}; 
rough_peak_height_estimate_vector = []; 
peak_plot_data_vector = []; 
baseline_deviation_vector = [];
fit_error_vector = []; 

for peak_number = 1 : peak_measurements_input.n_peaks
    baseline_points_length = round(length(peak_measurements_input.raw_signal{peak_number})...
        * settings.baseline_fraction);
    signal_to_analyze = peak_measurements_input.raw_signal{peak_number};
    left_baseline_values = signal_to_analyze(1:baseline_points_length);
    right_baseline_values = signal_to_analyze((end-baseline_points_length+1) : end);
    baseline_deviation = median(right_baseline_values) - median(left_baseline_values);
    baseline_values = [left_baseline_values; right_baseline_values];
    baseline_estimate = median(baseline_values);
    baseline_subtracted_signal = signal_to_analyze - baseline_estimate; 
    [rough_peak_height_estimate, peakIndex] = min(baseline_subtracted_signal); 
    peakFitWindowSize = round(settings.peak_fit_window_fraction * length(signal_to_analyze));
    peak_fit_window_indices = (peakIndex - peakFitWindowSize) : (peakIndex + peakFitWindowSize);
    peak_fit_window_indices = coerceVector(peak_fit_window_indices, 1, length(baseline_subtracted_signal));
    peakFitWindowData = baseline_subtracted_signal(peak_fit_window_indices);
    ws = warning('off', 'all');
    [p, ~, mu] = polyfit(peak_fit_window_indices(:), peakFitWindowData(:), settings.poly_fit_order);
    warning(ws);
    smoothed_peak_fit_data = polyval(p, peak_fit_window_indices, [], mu);
    [peak_height_estimate, peak_location_estimate] = min(smoothed_peak_fit_data);
    peak_location_estimate = peak_location_estimate + min(peak_fit_window_indices) - 1; 
    deviation = peakFitWindowData(:)-smoothed_peak_fit_data(:);
    fit_error = sum(deviation.*deviation)/length(deviation);

    peak_height_estimate = abs(peak_height_estimate); % want to be positive 
    rough_peak_height_estimate = abs(rough_peak_height_estimate);
    current_peak_plot_data.baseline_subtracted_signal = baseline_subtracted_signal;
    current_peak_plot_data.peak_fit_window_indices = peak_fit_window_indices;
    current_peak_plot_data.smoothed_peak_fit_data = smoothed_peak_fit_data;
    current_peak_plot_data.peak_location_estimate = peak_location_estimate;
    current_peak_plot_data.peak_height_estimate = peak_height_estimate; 
      
    % Assign to vectors, which will be assigned to peak_measurements_output
    peak_heights_vector = [peak_heights_vector, peak_height_estimate];
    baseline_subtracted_signal_array = [baseline_subtracted_signal_array, baseline_subtracted_signal];
    rough_peak_height_estimate_vector = [rough_peak_height_estimate_vector, ...
        rough_peak_height_estimate]; 
    baseline_deviation_vector = [baseline_deviation_vector, baseline_deviation];
    peak_plot_data_vector = [peak_plot_data_vector, current_peak_plot_data];
    fit_error_vector = [fit_error_vector, fit_error]; 
end

    peak_measurements_output.baseline_subtracted_signal = baseline_subtracted_signal_array;
    peak_measurements_output.peak_heights = peak_heights_vector; 
    peak_measurements_output.rough_peak_height_estimates = rough_peak_height_estimate_vector;
    peak_measurements_output.peak_plot_data = peak_plot_data_vector; 
    peak_measurements_output.baseline_deviation = baseline_deviation_vector; 
    peak_measurements_output.fit_error = fit_error_vector;
    

end

function plot_peak_fit(peak_plot_data)
plot(get(gca, 'XLim'), [0 0], 'Color', 0.65*[1 1 1]);
hold on
plot(peak_plot_data.baseline_subtracted_signal, 'Color', 0.65*[1 1 1]);
plot(peak_plot_data.peak_fit_window_indices, peak_plot_data.smoothed_peak_fit_data, 'b');
plot(peak_plot_data.peak_location_estimate, -peak_plot_data.peak_height_estimate, 'r.', 'MarkerSize', 15);
plot(get(gca, 'XLim'), -peak_plot_data.peak_height_estimate*[1 1], 'Color', 0.65*[1 1 1]);
plot(get(gca, 'XLim'), [0 0], 'Color', 0.65*[1 1 1]);
set(gca, 'YLim', [min(get(gca, 'YLim')), 2]);
set(gca, 'XLim', [1, length(peak_plot_data.baseline_subtracted_signal)]);
end

function out = coerceVector(vector, min, max)

vector(vector < min) = min;
vector(vector > max) = max; 
out = vector; 

end

function [peak_data, n_accepted, n_rejected] = filter_peak_measurements(peak_data, settings)

peak_heightMask = peak_data.peak_heights > abs(settings.detection_threshold);
roughPeakHeightMask = peak_data.peak_heights > abs(settings.detection_threshold);
baseline_deviationMask = abs(peak_data.baseline_deviation) < settings.baseline_deviation_limit;
outlierMask = ~isoutlier(peak_data.fit_error);

fprintf('    %.0f peaks rejected based on peak height\n', peak_data.n_peaks - nnz(peak_heightMask));
fprintf('    %.0f peaks rejected based on rough peak height\n', peak_data.n_peaks - nnz(roughPeakHeightMask));
fprintf('    %.0f peaks rejected based on baseline slope\n', peak_data.n_peaks - nnz(baseline_deviationMask));
fprintf('    %.0f peaks rejected based on fit error\n', peak_data.n_peaks - nnz(outlierMask));

if peak_data.n_peaks == 0
    mask = false;
else
    mask = all([peak_heightMask; ...
                roughPeakHeightMask; ...
                baseline_deviationMask; ...
                outlierMask]);
end
fprintf('    total of %.0f/%.0f peaks accepted\n', nnz(mask), peak_data.n_peaks);
        

% mask = (peak_data.peak_heights > abs(settings.detection_threshold)) ...
%      & (peak_data.rough_peak_height_estimates > abs(settings.detection_threshold)) ...
%      & (abs(peak_data.baseline_deviation) < settings.baseline_deviation_limit)...
%      & (~isoutlier(peak_data.fit_error));
 
n_accepted = nnz(mask);
n_rejected = length(mask) - nnz(mask);

peak_data.raw_signal = peak_data.raw_signal(mask);
peak_data.bandpassSignal = peak_data.bandpassSignal(mask);
peak_data.lowpassSignal = peak_data.lowpassSignal(mask);
peak_data.baselineSignal = peak_data.baselineSignal(mask);
peak_data.peakRangesIncludingBaseline = peak_data.peakRangesIncludingBaseline(mask, :);
peak_data.peakRanges = peak_data.peakRanges(mask, :);
peak_data.peak_durations_indices = peak_data.peak_durations_indices(mask);
peak_data.peak_durations_time = peak_data.peak_durations_time(mask);
peak_data.n_peaks = numel(peak_data.raw_signal);
peak_data.totalDuration_indices = peak_data.totalDuration_indices; % unchanged
peak_data.totalDuration_time = peak_data.totalDuration_time; % unchanged
peak_data.baseline_subtracted_signal = peak_data.baseline_subtracted_signal; % unchanged
peak_data.peak_heights = peak_data.peak_heights(mask);
peak_data.rough_peak_height_estimates = peak_data.rough_peak_height_estimates(mask);
peak_data.peak_plot_data = peak_data.peak_plot_data(mask); 

end

function summary = generate_summary_statistics(peak_data)

summary.peaks_per_sensor = [peak_data.n_peaks];
summary.total_cell_number = sum([peak_data.n_peaks]);
summary.total_duration = peak_data(1).totalDuration_time; 
if isempty(peak_data(1).totalDuration_time)
    summary.total_duration = peak_data(2).totalDuration_time;
end

for sensor_number = 1 : numel(peak_data)
   currentPeakData = peak_data(sensor_number);
   
   summary.peak_height_mean(sensor_number) = mean(currentPeakData.peak_heights);
   summary.peak_height_median(sensor_number)= median(currentPeakData.peak_heights);
   summary.peak_height_sd(sensor_number) = std(currentPeakData.peak_heights);
   summary.peak_height_cv(sensor_number) = mean(currentPeakData.peak_heights)/std(currentPeakData.peak_heights);
   summary.peak_height_robust_cv(sensor_number) = 0.741*calculate_iqr(currentPeakData.peak_heights)/median(currentPeakData.peak_heights);
    
end

all_transit_times = [];
for sensor_number = 1 : numel(peak_data)
    all_transit_times = [all_transit_times; peak_data(sensor_number).peak_durations_time];
end
summary.medianTransitTime = median(all_transit_times);

end

function iqr = calculate_iqr(x)
if length(x) == 0
    iqr = 0;
else

    x = sort(x);
    ind1 = ceil(0.25*length(x));
    ind2 = ceil(0.75*length(x));
    iqr = x(ind2)-x(ind1);
end

end


function filtered_signal_struct = get_filtered_signal_struct(unfilt_signal_struct, settings)
filtered_signal_struct = unfilt_signal_struct; 
filtered_signal_struct.lowpass = sgolayfilt(filtered_signal_struct.frequency_signal, ...
    settings.sgolay_order, settings.sgolay_length); 
filtered_signal_struct.baseline = moving_quantile(filtered_signal_struct.lowpass, ...
    settings.quantile_decimation, settings.quantile_width, settings.quantile);
filtered_signal_struct.bandpass = filtered_signal_struct.lowpass - filtered_signal_struct.baseline; 
filtered_signal_struct.diff = diff(filtered_signal_struct.bandpass);
end

function make_summary_plots(data, peak_measurements, summary, settings)
% 
% for sensor_number = 1 : numel(peak_measurements)
%     
%     if peak_measurements(sensor_number).n_peaks == 0
%         continue
%     end
%     
%     figure
%     peaks_to_plot = min(settings.max_peaks_to_plot, peak_measurements(sensor_number).n_peaks);
%     subplot_size = ceil(sqrt(peaks_to_plot));
%     
%     for peak_number = 1 : peaks_to_plot
%         subplot(subplot_size, subplot_size, peak_number)
% 
%         peak_number_to_plot = round(1 + (peak_measurements(sensor_number).n_peaks-1) ...
%             * rand());
% 
%         plot_peak_fit(peak_measurements(sensor_number).peak_plot_data(peak_number_to_plot));
%     end
% 
% end

% Plot histogram of transit times
figure
subplot(2, 3, 1)
for sensor_number = 1 : numel(peak_measurements)
    if peak_measurements(sensor_number).n_peaks > settings.min_peaks_to_plot
        box_plot(peak_measurements(sensor_number).peak_durations_time*1000, ...
            sensor_number, settings.colors(sensor_number, :));
        hold on 
    end
end
ylabel('Transit time rough estimate (ms)');
set(gca, 'XTick', 1:numel(data))
set(gca, 'XLim', [0, (numel(data)+1)]);
set(gca, 'YLim', [0, max(get(gca, 'YLim'))]);

% Plot bar graph of number of cells in each cantilever
subplot(2, 3, 2)
for sensor_number = 1 : numel(peak_measurements)
    
    if peak_measurements(sensor_number).n_peaks == 0
        continue
    end
    
    bar(sensor_number, numel(peak_measurements(sensor_number).peak_durations_time));
    hold on
    xlabel('Sensor number');
    ylabel('Particles detected');

end
set(gca, 'XTick', 1:numel(data))

subplot(2, 3, 3)
for sensor_number = 1 : numel(peak_measurements)
    if peak_measurements(sensor_number).n_peaks > settings.min_peaks_to_plot
        box_plot(peak_measurements(sensor_number).peak_heights, ...
            sensor_number, settings.colors(sensor_number, :));
        hold on
    end
end
ylabel('Peak height (Hz)');
set(gca, 'XTick', 1:numel(data))
set(gca, 'XLim', [0, (numel(data)+1)]);
set(gca, 'YLim', [0, max(get(gca, 'YLim'))]);

subplot(2, 3, 4)
for sensor_number = 1 : numel(peak_measurements)
    
        if peak_measurements(sensor_number).n_peaks == 0
        continue
    end
    
    plot(peak_measurements(sensor_number).peak_durations_time*1000, peak_measurements(sensor_number).peak_heights(:), ...
        '.', 'Color', settings.colors(sensor_number, :));
    hold on
    set(gca, 'XLim', [0, 3*summary.medianTransitTime]*1000);
    xlabel('Transit time (ms)');
    ylabel('Peak height (Hz)'); 
end
set(gca, 'YLim', [0, max(get(gca, 'YLim'))])

subplot(2, 3, 5)
for sensor_number = 1 : numel(peak_measurements)
    
    if peak_measurements(sensor_number).n_peaks == 0
        continue
    end
    
    plot(peak_measurements(sensor_number).rough_peak_height_estimates, peak_measurements(sensor_number).peak_heights, ...
        '.', 'Color', settings.colors(sensor_number, :));
    hold on
    xlabel('Rough peak height estimate (Hz)');
    ylabel('Peak height (Hz)');
end
axis square
tempX = get(gca, 'XLim'); tempY = get(gca, 'YLim');
newAx = [0, max([tempX, tempY])];
axis([newAx newAx]);
plot(get(gca, 'XLim'), get(gca, 'YLim'), 'Color', 0.65*[1 1 1]);

subplot(2, 3, 6)
bar(summary.peak_height_robust_cv*100)
xlabel('Sensor number');
ylabel('Robust CV (%)');
set(gca, 'XTick', 1:numel(data))
set(gca, 'XLim', [0, (numel(data)+1)]);


% save last figure

end