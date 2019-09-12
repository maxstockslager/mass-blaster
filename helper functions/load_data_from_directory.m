function data = load_data_from_directory(directory)
    files = dir(fullfile(directory, '*.bin') );   % structure listing all *.bin files
    files = {files.name}';    
    if isempty(files)
        error(strcat('Did not find data in directory: ', directory))
    end

    % Read frequency signals
    data(numel(files)) = struct('frequency_signal', []);
    fprintf('Loading data from files...\n');
    for sensor_number = 1 : numel(files)
        data(sensor_number).frequency_signal = read_frequency_signal(fullfile(directory, files{sensor_number}));
    end
end
