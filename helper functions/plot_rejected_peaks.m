    % plot rejected peaks
    function plot_rejected_peaks(data, rej_current_sensor_peak_measurements, sensor_number)
        for peak_number = 1 : rej_current_sensor_peak_measurements.n_peaks
            start_idx = rej_current_sensor_peak_measurements.peakRanges(peak_number, 1);
            end_idx = rej_current_sensor_peak_measurements.peakRanges(peak_number, 2);
            plot(start_idx:end_idx, ...
                 data(sensor_number).bandpass(start_idx:end_idx), 'r')
        end
    end