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
