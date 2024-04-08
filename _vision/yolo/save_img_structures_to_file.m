function save_img_structures_to_file
% Assumes .mat image structures in ./ros_matlab/code/_vision/data/merge
% Will extract images from each structure and save them to file. 
% Uses the base name of file_name as folder_name and then inside saves them
% as img##.jpg.

    cur_dir = pwd;
    last = strsplit(cur_dir,'/');
    if ~strcmp( last(end),'merge')
        error('You are not in the ./yolo/data/merge folder. Please switch or call merge_img_structures from the /yolo/data folder first')
    end

    % Only load .mat files (currently not handling older .mat files, may be
    % redundant).
    files = dir('*.mat');
    
    % File length
    file_len = length(files);

    % Initialize a cell array to hold the loaded data structures
    loadedData = cell(file_len, 1);
    
    for i = 1:file_len
        % Construct the full path to the file
        filePath = fullfile(files(i).folder, files(i).name);
        
        % Load structures inside cell. Still need to refer to them by internal field name: myImgStruct to access data
        loadedData{i} = load(filePath);
    end    
 
    % Timestamp for folder
    formattedDateTimeStr = datetime('now', 'Format', 'yyyyMMdd_HHmmss');

    ctr = 1;
    field_names = cell(1,file_len);
    
    for i = 1:file_len

        %% Create folder and cd into folder for set of images    
        tokens = strsplit(files(i).name,'_');     
        base_name = strjoin(tokens(1:2), '_');
        outputFileName = append(base_name,"_", char(formattedDateTimeStr)); 
        fullPath = fullfile(outputFileName); % Creates a full file path   
                
        if exist(fullPath, 'dir')~=7  
            mkdir(fullPath);
            cd(fullPath);
        end

        %% Save images

        str = loadedData{i};
        field_names{i} = fieldnames(str.outStruct); % Hold cell array of field names        

        % Use field names to set outStruct to the equivalent images
        for j = 1:length(field_names{i})
            %field = append('img',num2str(ctr));

            % Save the image to file
            entry = field_names{i}{j};
            fileName = append(entry,'.jpg');
            imwrite(str.outStruct.(entry), fileName);

            % Increase counter
            ctr = ctr + 1;
        end

        % Exit the specific folder back into ./data
        cd('..')
    end
end
