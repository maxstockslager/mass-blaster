function data = prepare_for_detection(data, settings)
    fprintf('Filtering signals to prepare for peak detection...\n');
    parfor ii = 1 : numel(data)
        filt_data(ii) = get_filtered_signal_struct(data(ii), settings); 
    end
    data = filt_data; 
end