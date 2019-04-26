function frequency_signal = read_frequency_signal(filename)
fileID = fopen(filename, 'r', 'b');
frequency_signal = fread(fileID, 'uint32');
frequency_signal(1:129:end) = [];
frequency_signal = frequency_signal * (12.5e6/2^32); 
fclose(fileID);
end