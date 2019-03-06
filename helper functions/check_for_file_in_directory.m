    function file_exists_in_directory = check_for_file_in_directory(directory, filename_to_check)
        files = dir(directory);
        filenames = {files.name};
        file_exists_in_directory = any(strcmp(filenames, filename_to_check));

    end