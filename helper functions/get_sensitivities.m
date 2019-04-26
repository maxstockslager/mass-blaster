function sensitivities = get_sensitivities(varargin)

addpath(fullfile(pwd, '\helper functions'))

if isempty(varargin)
   clear all, close all
   bead_filename =  'C:\Users\Maestro 1\Documents\Data\20180925 Calibration\2 8um PS\peak_measurements.mat';
   calib_settings.bead_diameter = 8;
   calib_settings.fluid_density = 1.003; 
   calib_settings.bead_density = 1.049;  
   calib_settings.min_beads_measured = 50; 
   calib_settings.max_bead_cv = 5; % percent
   make_plots = true; 
elseif numel(varargin) == 2
    bead_filename = varargin{1};
    calib_settings = varargin{2};
    make_plots = false; 
else
    error('Expecting two arguments: bead_filename and calib_settings');
end

load(bead_filename) 

sensors_to_keep = find(summary.peaks_per_sensor >= calib_settings.min_beads_measured ...
                     & summary.peak_height_robust_cv <= calib_settings.max_bead_cv/100);
sensors_to_drop = find(summary.peaks_per_sensor < calib_settings.min_beads_measured ...
                     | summary.peak_height_robust_cv > calib_settings.max_bead_cv/100);
bead_volume = 4/3 * pi * (calib_settings.bead_diameter/2)^3;
buoyant_mass = bead_volume * (calib_settings.bead_density - calib_settings.fluid_density);
sensitivities = summary.peak_height_median ./ buoyant_mass; 
sensitivities(sensors_to_drop) = nan;

%-- OPTIONAL: generate plots
if make_plots
    color_list = linspecer(numel(bead_filename));
    
    figure
    subplot(2, 2, 1)
    for sensor_number = 1 : numel(summary.peaks_per_sensor)
       if any(sensor_number == sensors_to_keep)
           color = 'k';
       else
           color = 0.65*[1 1 1];
       end

       box_plot(peak_measurements(sensor_number).peak_heights, sensor_number, ...
            color);  
       hold on
    end
    set(gca, 'XTick', 1:numel(summary.peaks_per_sensor));
    ylabel('Peak height (Hz)');
    title('Bead peak heights');
    set(gca, 'XLim', [0.5, numel(summary.peaks_per_sensor)+0.5]);
    set(gca, 'XTick', 1:numel(summary.peaks_per_sensor));


    subplot(2, 2, 2)
    bar(summary.peaks_per_sensor);
    hold on
    plot(get(gca, 'XLim'), calib_settings.min_beads_measured*[1 1], 'k--');
    title('Beads measured');
    set(gca, 'XLim', [0.5, numel(summary.peaks_per_sensor)+0.5]);
    set(gca, 'XTick', 1:numel(summary.peaks_per_sensor));
    ylabel('Beads measured');

    subplot(2, 2, 3)
    bar(summary.peak_height_robust_cv*100);
    title('Bead robust CV (%)');
    hold on
    plot(get(gca, 'XLim'), calib_settings.max_bead_cv*[1 1], 'k--');
    set(gca, 'XTick', 1:numel(summary.peaks_per_sensor));
    set(gca, 'XLim', [0.5, numel(summary.peaks_per_sensor)+0.5]);
    set(gca, 'XTick', 1:numel(summary.peaks_per_sensor));
    ylabel('Robust CV');

    subplot(2, 2, 4)
    plot(1:numel(summary.peaks_per_sensor), sensitivities, 'ko');
    xlabel('Sensor number');
    ylabel('Sensitivity (Hz/pg)');
    set(gca, 'XLim', [0.5, numel(summary.peaks_per_sensor)+0.5]);
    set(gca, 'XTick', 1:numel(summary.peaks_per_sensor));
    title('Sensitivities');

    figure
    subplot(2, 2, 1)
    for ii = 1 : numel(bead_filename)

        plot(1:numel(sensitivities{ii}), sensitivities{ii}, 'o', ...
            'MarkerSize', 7, 'LineWidth', 2, ...
            'Color', color_list(ii, :));
        hold on
        xlabel('Sensor number');
        ylabel('Sensitivity (Hz/pg)');
        set(gca, 'XLim', [0.5, numel(sensitivities{1})+0.5]);
        set(gca, 'XTick', 1:numel(sensitivities{1}));
        title('Sensitivities');
    end

    subplot(2, 2, 2)
    for ii = 1 : numel(bead_filename)
        bar(summaries{ii}.peaks_per_sensor, ...
            'FaceColor', color_list(ii, :), ...
            'FaceAlpha', 0.2);
        hold on
        plot(get(gca, 'XLim'), calib_settings.min_beads_measured*[1 1], 'k--');
        title('Beads measured');
        set(gca, 'XLim', [0.5, numel(summaries{ii}.peaks_per_sensor)+0.5]);
        set(gca, 'XTick', 1:numel(summaries{ii}.peaks_per_sensor));
        ylabel('Beads measured');
    end

    subplot(2, 2, 3)
    for ii = 1 : numel(bead_filename)
        bar(summaries{ii}.peak_height_robust_cv*100, ...
            'FaceColor', color_list(ii, :), ...
            'FaceAlpha', 0.2);
        hold on
        plot(get(gca, 'XLim'), calib_settings.max_bead_cv*[1 1], 'k--');
        title('Bead CV');
        set(gca, 'XLim', [0.5, numel(summaries{ii}.peaks_per_sensor)+0.5]);
        set(gca, 'XTick', 1:numel(summaries{ii}.peaks_per_sensor));
        ylabel('Bead CV (%)')
        set(gca, 'YLim', [0, 2*calib_settings.max_bead_cv]);
    end

    subplot(2, 2, 4)
    for ii = 1 : numel(bead_filename)

        plot(1:numel(sensitivities{ii}), sensitivities{ii}, 'o', ...
            'MarkerSize', 7, 'LineWidth', 2, ...
            'Color', color_list(ii, :));
        hold on
        xlabel('Sensor number');
        ylabel('Sensitivity (Hz/pg)');
        set(gca, 'XLim', [0.5, numel(sensitivities{1})+0.5]);
        set(gca, 'XTick', 1:numel(sensitivities{1}));
        title('Sensitivities');
    end

        mask = find(files_combined_per_sensor > 1);
        plot(mask, combined_sensitivities(mask), 'k.', ...
            'MarkerSize', 12)
end
end


