

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