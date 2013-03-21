function fullDir = createDir(currentDir, newDir)
    fullDir = fullfile(currentDir,newDir);
    if ~exist(fullDir, 'dir')
        mkdir(fullDir);
    end
end