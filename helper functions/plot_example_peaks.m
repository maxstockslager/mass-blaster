function plot_example_peaks(peak_measurements, settings)
    max_peaks_to_plot = 64; 
    for peak_number = 1:min([peak_measurements.n_peaks, max_peaks_to_plot])
        subplot(8, 8, peak_number)
        plot_peak_fit(peak_measurements.peak_plot_data(peak_number));
        hold on
        plot(get(gca, 'XLim'), settings.detection_threshold*[1 1], '--', 'Color', ...
            0.65*[1 1 1]);
    end

end
