


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