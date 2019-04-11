function metadata = read_google_spreadsheet(system, sheet)

switch system
    case 'MB1'
        key = '1ZGlRd2MdWTbD31BbJzbkGvpnMiY1y-pztS4rQq2zV6A';
        switch sheet
            case '20190325-GBM'
                gid = '1426304271';
            case '20190325-Leukemia'
                gid = '518678333';
            case '20190408-Macrophages'
                gid = '1617073548';
            otherwise
                gid = '';
end

    case 'MB2'
        key = '1x3tMqMacX6RdZQtH0SXU7R_6uimEX3XrPt8fG8byvQ8';
        switch sheet
            case '20190325-GBM'
                gid = '1426304271';
            otherwise 
                gid = '';
                
        end
end


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

