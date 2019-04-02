function metadata_out = convert_field_to_numeric(metadata, fieldname)

new_field = num2cell(str2num(cell2mat(metadata.(fieldname))));
metadata_out = metadata;
metadata_out.(fieldname) = new_field;
end