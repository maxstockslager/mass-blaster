function baseline = moving_quantile(signal, decimation, quantile_width, quantile_value)

    downsampled = signal(1:decimation:end);
    baseline = running_percentile(downsampled, quantile_width, quantile_value);
    baseline = repmat(baseline, 1, decimation)';
    baseline = baseline(:);
    baseline = baseline(1:length(signal));
    
end
