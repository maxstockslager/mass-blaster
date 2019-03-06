clear all, close all

% input filenames and setings 
reprocess_peak_detection = false; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
reprocess_apply_calibration = true; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% also check bead size in apply_bead_calibration

% -------------------------------------------------------------
% % BaF3 imatinib measurements
% common_directory = {'C:\Users\Maestro 1\Documents\Data\20180828 BaF3 imatinib fixation 24h\';
%                     'C:\Users\Maestro 1\Documents\Data\20180829 BaF3 imatinib fixation\';
%                     'C:\Users\Maestro 1\Documents\Data\20180830 BaF3 ponatinib fixation\';
%                     'C:\Users\Maestro 1\Documents\Data\20180831 BaF3 ponatinib fixation\'};
% 
% folder_list = {...
%                {'1 DMSO 12h rep1';
%                '2 1uM imatinib 12h rep1';
%                '3 DMSO 12h rep2';
%                '4 1uM imatinib 12h rep2';
%                '5 DMSO 12h rep3';
%                '6 1uM imatinib 12h rep3'};
%                ...
%                {'1 12h DMSO rep3';
%                '2 12h imatinib rep3';
%                '3 12h 0.1uM rep1';
%                '4 12h 0.1uM rep2';
%                '5 12h 0.1uM rep3'};
%                ...
%                {'1 100nM ponatinib 12h rep1';
%                 '2 100nM ponatinib 12h rep2';
%                 '3 100nM ponatinib 12h rep3';
%                };
%                {'1 12h 10nM ponatinib rep1';
%                 '2 12h 10nM ponatinib rep2';
%                 '3 12h 10nM ponatinib rep3'} 
%               };
%           
% bead_filenames = {...
%                   {'C:\Users\Maestro 1\Documents\Data\20180821 7um PS beads PBS\1\peak_measurements.mat'};
%                   ...
%                   {'C:\Users\Maestro 1\Documents\Data\20180821 7um PS beads PBS\1\peak_measurements.mat'};
%                   ...
%                   {'C:\Users\Maestro 1\Documents\Data\20180821 7um PS beads PBS\1\peak_measurements.mat'};
%                   ...
%                   {'C:\Users\Maestro 1\Documents\Data\20180831 7um PS calibration\1\peak_measurements.mat'};
%                  };


% -------------------------------------------------------------
% % Fixation test
% common_directory = {'C:\Users\Maestro 1\Documents\Data\20180903 Fixation test\';
%                     'C:\Users\Maestro 1\Documents\Data\20180904 Fixation test d2\';
%                     'C:\Users\Maestro 1\Documents\Data\20180905 Fixation test d3\';
%                     'C:\Users\Maestro 1\Documents\Data\20180906 BaF3 imatinib ethanol fixation d0\';
%                     'C:\Users\Maestro 1\Documents\Data\20180906 Fixation test d4\'
%                     };
%                   
% folder_list = {...
%                {'1 DMSO formalin media rep1';
%                 '2 DMSO formalin media rep2';
%                 '3 DMSO formalin media rep3';
%                 '4 Imatinib formalin media rep1';
%                 '5 Imatinib formalin media rep2';
%                 '6 Imatinib formalin media rep3';
%                 '7 DMSO formalin PBS rep1';
%                 '8 DMSO formalin PBS rep2';
%                 '9 DMSO formalin PBS rep3'};
%                 ...
%                 {'1 Imatinib formalin PBS rep1';
%                  '2 Imatinib formalin PBS rep2';
%                  '3 Imatinib formalin PBS rep3'};
%                 ...
%                 {'1 DMSO PFA media 1';
%                  '2 DMSO PFA media 2';
%                  '3 DMSO PFA media 3'};
%                  ...
%                 {'1 DMSO EtOH rep1';
%                  '2 Imatinib EtOH rep1'};
%                  ...
%                  {'1 DMSO PFA media roomtemp rep1';
%                   '2 Imatinib PFA media roomtemp rep1';
%                   '3 Imatinib PFA media roomtemp rep2';
%                   '4 Imatinib PFA media roomtemp rep3';
%                   '5 DMSO PFA PBS roomtemp rep1';
%                   '6 DMSO PFA PBS roomtemp rep2';
%                   '7 DMSO PFA PBS roomtemp rep3';
%                   '8 Imatinib PFA PBS roomtemp rep1';
%                   '9 Imatinib PFA PBS roomtemp rep2';
%                   '10 Imatinib PFA PBS roomtemp rep3';
%                   };
%               };
%           
% bead_filenames = {...
%                   {'C:\Users\Maestro 1\Documents\Data\20180831 7um PS calibration\1\peak_measurements.mat'};
%                   {'C:\Users\Maestro 1\Documents\Data\20180831 7um PS calibration\1\peak_measurements.mat'};
%                   {'C:\Users\Maestro 1\Documents\Data\20180831 7um PS calibration\1\peak_measurements.mat'};
%                   {'C:\Users\Maestro 1\Documents\Data\20180831 7um PS calibration\1\peak_measurements.mat'};
%                   {'C:\Users\Maestro 1\Documents\Data\20180831 7um PS calibration\1\peak_measurements.mat'};
%                  };


% -------------------------------------------------------------
%  % Fixed L1210s
% common_directory = {'C:\Users\Maestro 1\Documents\Data\20180808 L1210 fixation test\';
%                     'C:\Users\Maestro 1\Documents\Data\20180809 L1210 fixation day2\';
%                     'C:\Users\Maestro 1\Documents\Data\20180815 L1210 fixation day7\';
%                     'C:\Users\Maestro 1\Documents\Data\20180824 L1210 fixation day16\';
%                     'C:\Users\Maestro 1\Documents\Data\20180831 L1210 fixation day23\'};
%                 
% folder_list = {...
%                 {'1 Mock';
%                  '3 PFA 10 min'};
%                ...
%                 {'2 PFA 10 min'};
%                ...
%                 {'2 pfa 10min'};
%                 ...
%                 {'PFA 10min'};
%                 ...
%                 {'pfa 10min'};
%                 };
%             
% bead_filenames = {...
%                    {'C:\Users\Maestro 1\Documents\Data\20180802 P01 F15 7um PS\3 P3 faster\peak_measurements.mat'};
%                    ...
%                    {'C:\Users\Maestro 1\Documents\Data\20180802 P01 F15 7um PS\3 P3 faster\peak_measurements.mat'};
%                    ...
%                    {'C:\Users\Maestro 1\Documents\Data\20180802 P01 F15 7um PS\3 P3 faster\peak_measurements.mat'};
%                    ...
%                    {'C:\Users\Maestro 1\Documents\Data\20180831 7um PS calibration\1\peak_measurements.mat'};
%                    ...
%                    {'C:\Users\Maestro 1\Documents\Data\20180831 7um PS calibration\1\peak_measurements.mat'};
%                  };
             
% %  GBM
% common_directory = {'C:\Users\Maestro 1\Documents\Data\20180917 GBM samples\'};
%                 
% folder_list = {...
%                 {'1 BT112 control media';
%                  '2 BT112 abema media';
%                  '3 BT112 TMZ media';
%                  '4 BT224 control media';
%                  '5 BT224 abema media';
%                  '6 BT224 TMZ media';
%                  '7 DIPG19 DMSO media';
%                  '8 DIPG19 abema media';
%                  '9 DIPG19 TMZ media';
%                  '10 DIPG29 DMSO media';
%                  '11 DIPG29 abema media';
%                  '12 DIPG29 TMZ media'};
%               };
%             
% bead_filenames = {...
%                    {'C:\Users\Maestro 1\Documents\Data\20180917 8um PS beads\1 8um beads\peak_measurements.mat'};
%                  };
%              

% %  GBM
common_directory = {'C:\Users\Maestro 1\Documents\Data\20180920 GBM d3 fixed samples\';
                    'C:\Users\Maestro 1\Documents\Data\20180921 GBM d3 fixed samples\';
                    'C:\Users\Maestro 1\Documents\Data\20180924 GBM d10\'
                        };
                
folder_list = {...
                {'1 BT112 DMSO fixed';
                 '2 BT112 abema fixed';
                 '3 BT112 TMZ fixed';
                 '4 BT224 DMSO fixed';
                 '5 BT224 abema fixed';
                 '6 BT224 TMZ fixed'};
                 ...
                 {'1 DIPG19 control';
                  '2 DIPG19 abema';
                  '3 DIPG19 TMZ';
                  '4 DIPG29 control';
                  '5 DIPG29 abema';
                  '6 DIPG29 TMZ'};
                  ...
                  {'1 BT112 DMSO';
                   '2 BT112 abema';
                   '3 BT112 TMZ';
                   '4 BT224 DMSO';
                   '5 BT224 abema';
                   '6 BT224 TMZ';
                   '7 DIPG19 DMSO';
                   '8 DIPG19 abema';
                   '9 DIPG19 TMZ';
                   '10 DIPG29 DMSO';
                   '11 DIPG29 abema';
                   '12 DIPG29 TMZ'}
              };
            
bead_filenames = {...
                   {'C:\Users\Maestro 1\Documents\Data\20180917 8um PS beads\1 8um beads\peak_measurements.mat'};
                   {'C:\Users\Maestro 1\Documents\Data\20180917 8um PS beads\1 8um beads\peak_measurements.mat'};
                   {'C:\Users\Maestro 1\Documents\Data\20180925 Calibration\1 8um PS\peak_measurements.mat'};
                 };
             


% -------------------------------------------------------------
% peak detection
addpath(fullfile(pwd, '\helper functions'))
number_processed = zeros(1, numel(common_directory));

for jj = 1 : numel(common_directory)
    folders = folder_list{jj};
    for ii = 1 : numel(folders)
       directory = fullfile(common_directory{jj}, folders{ii});
       files = dir(directory);
       files = {files.name};

       if ~reprocess_peak_detection
           if any(strcmp(files, 'peak_measurements.mat'))
              fprintf('Already detected peaks for file %.0f of directory %.0f.\n', ...
                  ii, jj);
              continue
           end
       end

       fprintf('Detecting peaks for file %.0f of directory %.0f...\n', ii, jj)
       measure_peak_heights(directory);
       number_processed(jj) = number_processed(jj) + 1; 
    end
end

% -------------------------------------------------------------
% applying calibration
for jj = 1 : numel(common_directory)     

    folders = folder_list{jj};
    
    for ii = 1 : numel(folders)
       directory = fullfile(common_directory{jj}, folders{ii});
       files = dir(directory);
       files = {files.name};
       
       if ~reprocess_apply_calibration
           if any(strcmp(files, 'masses.csv'))
              fprintf('Already applied calibration for file %.0f of directory %.0f.\n', ...
                  ii, jj);
              continue
           end
       end
       
        full_filename = strcat(common_directory{jj}, folders{ii}, '\peak_measurements.mat');          
        fprintf('Applying calibration to file %.0f of directory %.0f...\n', ii, jj);
        apply_bead_calibration(full_filename, bead_filenames{jj}); 
    end 
end

%     full_filenames = cellfun(@(x) strcat(common_directory{jj}, x, '/peak_measurements.mat'), ...
%                              folder_list{jj}, ...
%                              'UniformOutput', false);
%         for ii = 1 : numel(full_filenames)
%            fprintf('Applying calibration to file %.0f of directory %.0f...\n', ii, jj);
%            apply_bead_calibration(full_filenames{ii}, bead_filenames{jj}); 
%         end