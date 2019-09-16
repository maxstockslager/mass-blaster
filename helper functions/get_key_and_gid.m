function [key, gid] = get_key_and_gid(system_name, sheet_name)

    spreadsheet_fn = 'SPREADSHEET_KEYS_TABLE.csv';
    keys_tbl = readtable(spreadsheet_fn);
    
    if strcmp(sheet_name, '') % calibration files    
        system_rownum = find(...
            strcmp(keys_tbl{:,1}, system_name));
        
        key = keys_tbl{system_rownum,3}{1}; 
        gid = '0'; % same for all calib files
    else
        rownum_for_this_sheet = find(...
            strcmp(keys_tbl{:,1}, system_name) .* ... % multiplying to do element-wise AND
            strcmp(keys_tbl{:,2}, sheet_name) ...
        );
        key = keys_tbl{rownum_for_this_sheet, 3}{1};
        gid = num2str(keys_tbl{rownum_for_this_sheet, 4});
    end
end

