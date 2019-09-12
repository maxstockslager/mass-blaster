function sheet_names = get_sheet_names(system_name)
    spreadsheet_fn = 'SPREADSHEET_KEYS_TABLE.csv';
    keys_tbl = readtable(spreadsheet_fn);
    keys_struct = table2struct(keys_tbl);
    rownums_for_this_system = find(strcmp(keys_tbl{:,1}, system_name));
    sheet_names = keys_tbl{rownums_for_this_system, 2};
end

