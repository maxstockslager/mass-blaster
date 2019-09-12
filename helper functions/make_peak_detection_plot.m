function make_peak_detection_plot(data, current_sensor_peak_measurements, sensor_number)
    subplot(ceil(numel(data)/2), 2, sensor_number);
    plot(data(sensor_number).bandpass, 'Color', 0.65*[1 1 1]);
    hold on

    % plot *detected* peaks
    for peak_number = 1 : current_sensor_peak_measurements.n_peaks
        start_idx = current_sensor_peak_measurements.peakRanges(peak_number, 1);
        end_idx = current_sensor_peak_measurements.peakRanges(peak_number, 2);
        plot(start_idx:end_idx, ...
             data(sensor_number).bandpass(start_idx:end_idx), 'g')
    end

end
