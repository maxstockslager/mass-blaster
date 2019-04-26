function plot_peak_fit(peak_plot_data)
plot(get(gca, 'XLim'), [0 0], 'Color', 0.65*[1 1 1]);
hold on
plot(peak_plot_data.baseline_subtracted_signal, 'Color', 0.65*[1 1 1]);
plot(peak_plot_data.peak_fit_window_indices, peak_plot_data.smoothed_peak_fit_data, 'b');
plot(peak_plot_data.peak_location_estimate, -peak_plot_data.peak_height_estimate, 'r.', 'MarkerSize', 15);
plot(get(gca, 'XLim'), -peak_plot_data.peak_height_estimate*[1 1], 'Color', 0.65*[1 1 1]);
plot(get(gca, 'XLim'), [0 0], 'Color', 0.65*[1 1 1]);
set(gca, 'YLim', [min(get(gca, 'YLim')), 2]);
set(gca, 'XLim', [1, length(peak_plot_data.baseline_subtracted_signal)]);
end