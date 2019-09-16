function metadata = read_google_spreadsheet(system, sheet)

%[key, gid] = SPREADSHEET_KEYS(system, sheet);
[key, gid] = get_key_and_gid(system, sheet);
raw = GetGoogleSpreadsheet(key, gid);

%%
col_names = raw(1, :);
raw = raw(2:end, :);

metadata = struct();
for ii = 1 : numel(col_names)
    metadata.(col_names{ii}) = raw(:, ii);
end

row_has_missing_info = zeros(1, numel(metadata.expt_id));
for ii = 1 : numel(metadata.expt_id)
   row_has_missing_info(ii) = any(isempty(metadata.experiment_folder{ii})); % different from excel
end

fields = fieldnames(metadata);
for ii = 1:numel(fields)
   field = fields{ii};
   temp_field = metadata.(field);
   temp_field = temp_field(~row_has_missing_info);
   metadata.(field) = temp_field;
    
end

end

