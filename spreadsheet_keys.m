function [key, gid] = SPREADSHEET_KEYS(system, sheet)

switch system
    case 'MB1'
        key = '1ZGlRd2MdWTbD31BbJzbkGvpnMiY1y-pztS4rQq2zV6A';
        switch sheet
            case '20190812-baf3'
                gid = '815719910';
            case '20190325-GBM'
                gid = '1426304271';
            case '20190325-Leukemia'
                gid = '518678333';
            case '20190408-Macrophages'
                gid = '1617073548';
            case '20190417-BoneMarrow'
                gid = '2128580955';
            otherwise
                gid = '';
        end
    case 'MB2'
        key = '1x3tMqMacX6RdZQtH0SXU7R_6uimEX3XrPt8fG8byvQ8';
        switch sheet
            case '20190812-baf3'
                gid = '973793667';
            case '20190325-GBM'
                gid = '1426304271';
            otherwise 
                gid = '';
        end
    otherwise
        error('Did not find a system with this name.');
end

end