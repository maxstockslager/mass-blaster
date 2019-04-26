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
