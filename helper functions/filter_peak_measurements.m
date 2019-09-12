function [accepted_peak_data, rej_peak_data] = filter_peak_measurements(peak_data, settings)

peak_heightMask = peak_data.peak_heights > abs(settings.detection_threshold);
roughPeakHeightMask = peak_data.peak_heights > abs(settings.detection_threshold);
baseline_deviationMask = abs(peak_data.baseline_deviation) < settings.baseline_deviation_limit;
% outlierMask = ~isoutlier(peak_data.fit_error, 'quartiles');

fprintf('    %.0f peaks rejected based on peak height\n', peak_data.n_peaks - nnz(peak_heightMask));
fprintf('    %.0f peaks rejected based on rough peak height\n', peak_data.n_peaks - nnz(roughPeakHeightMask));
fprintf('    %.0f peaks rejected based on baseline slope\n', peak_data.n_peaks - nnz(baseline_deviationMask));
% fprintf('    %.0f peaks rejected based on fit error\n', peak_data.n_peaks - nnz(outlierMask));

if peak_data.n_peaks == 0
    mask = false;
else
    mask = all([peak_heightMask; ...
                roughPeakHeightMask; ...
                baseline_deviationMask]); ...
%                 outlierMask]);
end
fprintf('    total of %.0f/%.0f peaks accepted\n', nnz(mask), peak_data.n_peaks);
        

% mask = (peak_data.peak_heights > abs(settings.detection_threshold)) ...
%      & (peak_data.rough_peak_height_estimates > abs(settings.detection_threshold)) ...
%      & (abs(peak_data.baseline_deviation) < settings.baseline_deviation_limit)...
%      & (~isoutlier(peak_data.fit_error));
 
n_accepted = nnz(mask);
n_rejected = peak_data.n_peaks - nnz(mask);

accepted_peak_data.raw_signal = peak_data.raw_signal(mask);
accepted_peak_data.bandpassSignal = peak_data.bandpassSignal(mask);
accepted_peak_data.lowpassSignal = peak_data.lowpassSignal(mask);
accepted_peak_data.baselineSignal = peak_data.baselineSignal(mask);
accepted_peak_data.peakRangesIncludingBaseline = peak_data.peakRangesIncludingBaseline(mask, :);
accepted_peak_data.peakRanges = peak_data.peakRanges(mask, :);
accepted_peak_data.peak_durations_indices = peak_data.peak_durations_indices(mask);
accepted_peak_data.peak_durations_time = peak_data.peak_durations_time(mask);
accepted_peak_data.n_peaks = n_accepted;
accepted_peak_data.totalDuration_indices = peak_data.totalDuration_indices; % unchanged
accepted_peak_data.totalDuration_time = peak_data.totalDuration_time; % unchanged
accepted_peak_data.baseline_subtracted_signal = peak_data.baseline_subtracted_signal(mask); % unchanged
accepted_peak_data.peak_heights = peak_data.peak_heights(mask);
accepted_peak_data.rough_peak_height_estimates = peak_data.rough_peak_height_estimates(mask);
accepted_peak_data.peak_plot_data = peak_data.peak_plot_data(mask); 


if mask == 0
    rej_peak_data = accepted_peak_data; % special case when there's only one cell, which gets rejected
else
    rej_peak_data = peak_data; % starting point
    rej_peak_data.raw_signal = peak_data.raw_signal(~mask);
    rej_peak_data.bandpassSignal = peak_data.bandpassSignal(~mask);
    rej_peak_data.lowpassSignal = peak_data.lowpassSignal(~mask);
    rej_peak_data.baselineSignal = peak_data.baselineSignal(~mask);
    rej_peak_data.peakRangesIncludingBaseline = peak_data.peakRangesIncludingBaseline(~mask, :);
    rej_peak_data.peakRanges = peak_data.peakRanges(~mask, :);
    rej_peak_data.peak_durations_indices = peak_data.peak_durations_indices(~mask);
    rej_peak_data.peak_durations_time = peak_data.peak_durations_time(~mask);
    rej_peak_data.n_peaks = n_rejected;
    rej_peak_data.totalDuration_indices = peak_data.totalDuration_indices; % unchanged
    rej_peak_data.totalDuration_time = peak_data.totalDuration_time; % unchanged
    rej_peak_data.baseline_subtracted_signal = peak_data.baseline_subtracted_signal(~mask); % unchanged
    rej_peak_data.peak_heights = peak_data.peak_heights(~mask);
    rej_peak_data.rough_peak_height_estimates = peak_data.rough_peak_height_estimates(~mask);
    rej_peak_data.peak_plot_data = peak_data.peak_plot_data(~mask); 
end

end