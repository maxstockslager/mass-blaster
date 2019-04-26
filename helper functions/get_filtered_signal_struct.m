function filtered_signal_struct = get_filtered_signal_struct(unfilt_signal_struct, settings)
filtered_signal_struct = unfilt_signal_struct; 
filtered_signal_struct.lowpass = sgolayfilt(filtered_signal_struct.frequency_signal, ...
    settings.sgolay_order, settings.sgolay_length); 
filtered_signal_struct.baseline = moving_quantile(filtered_signal_struct.lowpass, ...
    settings.quantile_decimation, settings.quantile_width, settings.quantile);
filtered_signal_struct.bandpass = filtered_signal_struct.lowpass - filtered_signal_struct.baseline; 
filtered_signal_struct.diff = diff(filtered_signal_struct.bandpass);
end