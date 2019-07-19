function settings_struct = read_settings(filename)

settings_table = readtable(filename,...
              'ReadVariableNames',false);
settings_cell = table2cell(settings_table);

% remove colons
[nrow, ~] = size(settings_cell);
for rownum = 1:nrow
    settings_cell{rownum,1} = settings_cell{rownum,1}(1:(end-1));
    
    value = settings_cell{rownum,2};
    if strcmp(value, 'false')
        settings_cell{rownum,2} = false;
    elseif strcmp(value, 'true')
        settings_cell{rownum,2} = true;
    end
end

% convert to structure array
settings_struct = cell2struct(settings_cell, settings_cell(:,1), 1);
settings_struct = settings_struct(2);

