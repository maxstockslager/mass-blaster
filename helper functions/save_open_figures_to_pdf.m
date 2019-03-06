function save_open_figures_to_pdf(directory_to_save_to)

figHandles = get(groot, 'Children');

% directory_to_save_to = 'C:\Users\Maestro 1\Documents\Data\20180906 Fixation test d4\1 DMSO PFA media roomtemp rep1\';
% path = 'C:\Users\Maestro 1\Documents\Data\20180906 Fixation test d4\1 DMSO PFA media roomtemp rep1\test.pdf';
path = fullfile(directory_to_save_to, 'peak_detection.pdf');

export_fig(path, figHandles(1), '-pdf');

if numel(figHandles) >= 2
    for ii = numel(figHandles) : -1 : 2
        export_fig(path, figHandles(ii), '-pdf', '-append');
    end
end

end