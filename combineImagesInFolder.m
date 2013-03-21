function combineImagesInFolder(structureIndex)
    resFromMax = 4;
    strctures = load('./output/structures.mat');
    stucture = strctures.data.structuresNames{structureIndex};
    fprintf('=======   %s =======\n', stucture);
    structureFolder = fullfile('./output', stucture);
    matFile = sprintf('./output/%s.mat',stucture);
    load(matFile);
    fileId = NaN;
    onlyNames = false;
    removePatches = true;

    for j=1:length(data.exprimentId)
        expreiment = data.imagesMetaData{j};
        expermientFolder = fullfile(structureFolder, num2str(data.exprimentId));
        imageIDs = expreiment.imageIDs;
        imageTilesData = expreiment.imageTilesData;
        imagesPaths = expreiment.imagesPaths;
        fullImages = createDir(expermientFolder,['fullImages-res',num2str(resFromMax)]);
        
        for i=1:length(imageIDs)
            currentImageTileData = imageTilesData{i};
            %imageFolder = fullfile(expermientFolder, imageIDs{i});
            tilesFolder = sprintf('%s/tiles-res%d/%s' , expermientFolder,resFromMax, imageIDs{i});
            
            [resolution, maxTileX, maxTileY] = getLastIndexes(resFromMax,currentImageTileData.width, currentImageTileData.height, currentImageTileData.tileSize, currentImageTileData.numTiers);
            if onlyNames
                textFileName = createTextFileName(imageIDs{i}, maxTileX, maxTileY, resolution);
                fileId = fopen(fullfile(tileUrlsDir,textFileName),'w');
            end
            if ~exist(tilesFolder, 'dir')
                tilesDir = createDir('', tilesFolder);
                getTiles(imagesPaths{i}, resolution, maxTileX, maxTileY,tilesDir,onlyNames,fileId);
            else
                fprintf('found existing tile directory %s\n',  tilesFolder);
            end
            if onlyNames
                fclose(fileId);
            else
                fileName = sprintf('%d-%s.tiff',resolution, imageIDs{i});
                imageFile = fullfile(fullImages,fileName);
                if ~exist(imageFile, 'file')
                    try
                        image = combineImages(tilesDir,resolution, maxTileX, maxTileY);
                        imwrite(image, imageFile,'tiff');

						if removePatches
							rmdir(tilesDir,'s');
						end
                    catch exp
                       fprintf('problem creating %s\n',  imageFile);
                       disp(exp.message);
                    end
                else
                     fprintf('found existing image %s\n',  imageFile);
                end
            end
        end
        
    end
end

