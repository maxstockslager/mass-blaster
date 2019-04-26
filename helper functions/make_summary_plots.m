function make_summary_plots(data, peak_measurements, summary, settings)

% Plot histogram of transit times
figure
subplot(2, 3, 1)
for sensor_number = 1 : numel(peak_measurements)
    if peak_measurements(sensor_number).n_peaks > settings.min_peaks_to_plot
        box_plot(peak_measurements(sensor_number).peak_durations_time*1000, ...
            sensor_number, settings.colors(sensor_number, :));
        hold on 
    end
end
ylabel('Transit time rough estimate (ms)');
set(gca, 'XTick', 1:numel(data))
set(gca, 'XLim', [0, (numel(data)+1)]);
set(gca, 'YLim', [0, max(get(gca, 'YLim'))]);

% Plot bar graph of number of cells in each cantilever
subplot(2, 3, 2)
for sensor_number = 1 : numel(peak_measurements)
    
    if peak_measurements(sensor_number).n_peaks == 0
        continue
    end
    
    bar(sensor_number, numel(peak_measurements(sensor_number).peak_durations_time));
    hold on
    xlabel('Sensor number');
    ylabel('Particles detected');

end
set(gca, 'XTick', 1:numel(data))

subplot(2, 3, 3)
for sensor_number = 1 : numel(peak_measurements)
    if peak_measurements(sensor_number).n_peaks > settings.min_peaks_to_plot
        box_plot(peak_measurements(sensor_number).peak_heights, ...
            sensor_number, settings.colors(sensor_number, :));
        hold on
    end
end
ylabel('Peak height (Hz)');
set(gca, 'XTick', 1:numel(data))
set(gca, 'XLim', [0, (numel(data)+1)]);
set(gca, 'YLim', [0, max(get(gca, 'YLim'))]);

subplot(2, 3, 4)
for sensor_number = 1 : numel(peak_measurements)
    
        if peak_measurements(sensor_number).n_peaks == 0
        continue
    end
    
    plot(peak_measurements(sensor_number).peak_durations_time*1000, peak_measurements(sensor_number).peak_heights(:), ...
        '.', 'Color', settings.colors(sensor_number, :));
    hold on
    set(gca, 'XLim', [0, 3*summary.medianTransitTime]*1000);
    xlabel('Transit time (ms)');
    ylabel('Peak height (Hz)'); 
end
set(gca, 'YLim', [0, max(get(gca, 'YLim'))])

subplot(2, 3, 5)
for sensor_number = 1 : numel(peak_measurements)
    
    if peak_measurements(sensor_number).n_peaks == 0
        continue
    end
    
    plot(peak_measurements(sensor_number).rough_peak_height_estimates, peak_measurements(sensor_number).peak_heights, ...
        '.', 'Color', settings.colors(sensor_number, :));
    hold on
    xlabel('Rough peak height estimate (Hz)');
    ylabel('Peak height (Hz)');
end
axis square
tempX = get(gca, 'XLim'); tempY = get(gca, 'YLim');
newAx = [0, max([tempX, tempY])];
axis([newAx newAx]);
plot(get(gca, 'XLim'), get(gca, 'YLim'), 'Color', 0.65*[1 1 1]);

subplot(2, 3, 6)
bar(summary.peak_height_robust_cv*100)
xlabel('Sensor number');
ylabel('Robust CV (%)');
set(gca, 'XTick', 1:numel(data))
set(gca, 'XLim', [0, (numel(data)+1)]);

