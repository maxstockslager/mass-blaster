function system_names = get_system_names()
    spreadsheet_fn = 'SPREADSHEET_KEYS_TABLE.csv';
    keys_tbl = readtable(spreadsheet_fn);
    keys_struct = table2struct(keys_tbl);
    system_names = unique({keys_struct.system});
    
    system_names = system_names(:);
end
