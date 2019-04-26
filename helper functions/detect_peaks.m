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
    
end