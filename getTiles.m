function getTiles(path, resolution, maxTileX, maxTileY,tilesDir,onlyNames,fileId)
    for i=1:maxTileX+1
        xIndex = i-1;
        for j=1:maxTileY+1
            yIndex = j-1;
            tileUrl = sprintf('http://connectivity.brain-map.org/tiles/%s/TileGroup0/%d-%d-%d.jpg?range=0,1500,0,1000,0,4095',path,resolution, xIndex, yIndex);
            fileName = sprintf('%d-%d-%d.jpg',resolution, xIndex, yIndex);
            fileName = fullfile(tilesDir, fileName);
            if ~onlyNames
                urlwrite(tileUrl,fileName);
                fprintf('.');
            else
               fprintf(fileId, '%s\n',tileUrl); 
            end
        end
    end
    fprintf('\n');
end