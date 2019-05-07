function metadata_out = convert_field_to_numeric(metadata, fieldname)

metadata_out = metadata;
for ii = 1 : length(metadata.(fieldname))
    old_entry = metadata.(fieldname){ii};
    new_entry = str2num(old_entry);
    metadata_out.(fieldname){ii} = new_entry;
end

end