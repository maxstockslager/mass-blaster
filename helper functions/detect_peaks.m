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
    

    
    % make sure separation between peaks is above threshold
    time_to_next_peak = (1/settings.datarate) * ...
        [peak_range_indices(2:end, 1) - peak_range_indices(1:(end-1), 2);
        1e6];
    
    time_to_prev_peak = (1/settings.datarate) * ...
        [1e6; peak_range_indices(2:end, 1) - peak_range_indices(1:(end-1),2)];
    
    
    % remove peaks not meeting criteria
    filteredPeakMask = (peakDuration_time > settings.min_peak_duration) ...
        & (peakDuration_time < settings.max_peak_duration) ...
        & (time_to_prev_peak > settings.min_peak_separation) ...
        & (time_to_next_peak > settings.min_peak_separation);
    filteredPeakRangeIndices = peak_range_indices(filteredPeakMask, :);
    
    
    
    % plot
    PLOT_PEAKS = false;
    if PLOT_PEAKS
        
        % plot signal
        figure
        plot(signal, 'Color', 0.65*[1 1 1]);
        hold on
        
        % plot indices below threshold
        plot(get(gca, 'XLim'), settings.detection_threshold*[1 1], 'k--');
        
        % plot all peak range indices (initial guess)
        for peak_number = 1 : length(peak_range_indices)
            start_idx = peak_range_indices(peak_number, 1);
            end_idx = peak_range_indices(peak_number, 2);
            plot(start_idx:end_idx, ...
                 signal(start_idx:end_idx), 'r')
        end
        % plot "filtered" peak range indices
        for peak_number = 1 : length(filteredPeakRangeIndices)
            start_idx = filteredPeakRangeIndices(peak_number, 1);
            end_idx = filteredPeakRangeIndices(peak_number, 2);
            plot(start_idx:end_idx, ...
                 signal(start_idx:end_idx), 'g')
        end
    end

    
    
    
end