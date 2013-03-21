% download images:


function mainGetConnectionData()
    resolution = 0 ; % 0 is the highest resolution;
    onlyNames= true;
    
    
    [structuresData,structuresIDs, structuresNames] = getLocations();
    exprimentData = cell(length(structuresIDs),1);
    directory = createDir('.', 'output');
    saveFile(structuresData, 'structures', directory);
    
    for j = 1:length(structuresIDs)
        fprintf('%s:\n',structuresNames{j});
        [exprimentData{j}, exprimentId] = getListOfSpecimensIDs(structuresIDs(j));
        structureDir = createDir(directory, structuresNames{j});
       
        exprimentData{j}.imagesMetaData = cell(length(exprimentId),1);
        
        for i = 1:length(exprimentId);
            [exprimentData{j}.imagesMetaData{i}, imagesPaths, imageIDs] = getListOfPhotos(exprimentId(i));
            exprimentDir = createDir(structureDir, num2str(exprimentId(i)));
            
            exprimentData{j}.imagesMetaData{i}.imageTilesData = cell(length(imagesPaths),1);
            tileUrlsDir = createDir(exprimentDir,['tilesURLs-res',num2str(resolution)]);
            for m = 1:length(imagesPaths)
                [imageID,maxResolution, maxTileX, maxTileY, exprimentData{j}.imagesMetaData{i}.imageTilesData{m}] = getPhotos(imagesPaths{m}, imageIDs{m}, resolution);
                tilesDir = createDir([exprimentDir,'/tiles'], imageID);
                %saveFile(exprimentData{j}.imagesMetaData{i}.imageTilesData{m}, imageID, exprimentDir);
                textFileName = createTextFileName(imageID, maxTileX, maxTileY, maxResolution);
                fileId = fopen(fullfile(tileUrlsDir,textFileName),'w');
                getTiles(imagesPaths{m},maxResolution, maxTileX, maxTileY,tilesDir,onlyNames,fileId);
                fclose(fileId);
                
                if ~onlyNames
                    imageData = exprimentData{j}.imagesMetaData{i}.imageTilesData{m};
                    myImage = combineImages(imageData, tilesDir,maxResolution);
                    fileName = sprintf('%d-%s.jpg',maxResolution, imageID);
                    imageFile = fullfile(fullImages,fileName);
                    imwrite(myImage, imageFile);
                end
            end
            saveFile(exprimentData{j}.imagesMetaData{i}, num2str(exprimentId(i)), structureDir);
        end
        saveFile(exprimentData{j}, structuresNames{j}, directory);
    end
end

function fileName = createTextFileName(imageID, maxTileX, maxTileY, maxResolution)
    fileName = sprintf('%s_tilesX=%d_tilesY=%d_res=%d.txt', imageID, maxTileX, maxTileY, maxResolution);
end


function saveFile(data, name, directory)
    fileName = [name, '.mat'];
    save(fullfile(directory,fileName),'data');
end
function [data,structuresIDs, structuresNames] = getLocations()
    dataToInclude = 'include=structure&only=name,primary_injection_structure_id,structure_id,specimen_id';
    order = 'sorder=structures.name$asc';
    
    locationsURL = sprintf(['http://connectivity.brain-map.org/api/v2/data/Injection/query.json?wrap=true'...
        '&criteria=specimen(donor(products[id$in5])),structure[id]&%s&%s'],dataToInclude,order);
    jsonString = urlread(locationsURL);
    data = parse_json(jsonString);
    m=1;
    injectionAreas = data.msg;
    for i = 1:length(injectionAreas)
       currentExp = injectionAreas{i};
       structuresIDs(m) = currentExp.primary_injection_structure_id;
       structuresNames{m} = currentExp.structure.name;
       m= m+1;
    end
    data.structuresIDs = structuresIDs;
    data.structuresNames = structuresNames;
end
function [data, exprimentId] = getListOfSpecimensIDs(regionID)

    regionUrl  = sprintf(['http://connectivity.brain-map.org/api/v2/data/Injection/query.json?wrap=true&criteria',...
        '=[primary_injection_structure_id$eq%d],specimen(donor(products[id$eq5]))&include=structure',...
        '[id$eq%d],specimen(donor(age),data_sets[type$eqSectionDataSet])&order=structures.name,+data_sets.id&numRows=25'],regionID, regionID);
      
    jsonString = urlread(regionUrl);
    data = parse_json(jsonString);
    m=1;
    expriments = data.msg;
    for i = 1:length(expriments)
       currentExp = expriments{i};
       dataSetsInExpriment = currentExp.specimen.data_sets;
       for j=1:length(dataSetsInExpriment)
           currentDataSet = dataSetsInExpriment{j};
           exprimentId(m) =  currentDataSet.id;
           m= m+1;
       end
    end
    data.exprimentId = exprimentId;
end

function [data, imagesPaths, imageIDs] = getListOfPhotos(specimentId)
    dataToInclude = 'plane_of_section,treatments,specimen(donor(age)),section_images(associates),genes';
    order = 'sub_images.section_number$desc';
    photosUrl = sprintf(['http://connectivity.brain-map.org/api/v2/data/SectionDataSet/%d.json?', ...
          'wrap=true&include=%s&order=%s'], specimentId,dataToInclude,order);
      
    jsonString = urlread(photosUrl);
    data = parse_json(jsonString);
    m=1;
    expriments = data.msg;
    for i = 1:length(expriments)
       currentExp = expriments{i};
       imagesInExpriment = currentExp.section_images;
       for j=1:length(imagesInExpriment)
           currentImage = imagesInExpriment{j};
           imagesPaths{m} =  currentImage.path;
           indexOfLine = regexp(currentImage.path,'/');
           imageIDs{m} = currentImage.path(indexOfLine(end)+1:end);
           m= m+1;
       end
    end
    data.imagesPaths = imagesPaths;
    data.imageIDs = imageIDs;
end

function [ imageID,resolution, maxTileX, maxTileY, data] = getPhotos(path, imageID, resFromMax)
    
    imageUrl = sprintf('http://connectivity.brain-map.org/tiles/%s/ImageProperties.xml',path);
    %imageXml = urlread(imageUrl);
    resolution = 0;
    maxTileX = 0;
    maxTileY = 0;
    try
        imageXml=xmlread(imageUrl);
        data = parseChildNodes(imageXml);
        attributes = data.Attributes;
        for i=1:length(attributes)
            switch attributes(i).Name
                case 'HEIGHT'
                    height = str2double(attributes(i).Value);
                case 'WIDTH'
                    width = str2double(attributes(i).Value);
                case 'NUMTIERS'
                    numTiers = str2double(attributes(i).Value);
                case 'TILESIZE'
                    tileSize = str2double(attributes(i).Value);
            end
        end
        data.tileSize = tileSize;
        data.numTiers = numTiers;
        data.width = width;
        data.height = height;
        [resolution, maxTileX, maxTileY] = getLastIndexes(resFromMax,width, height, tileSize, numTiers);
    catch exception
        error('seriesXml:noXml','No data available for image %s while accessing \n%s\n%s ',imageID,imageUrl,exception.message);
    end
%     WIDTH="40000" 
%     HEIGHT="30000" 
%     NUMTILES="24796" 
%     NUMTIERS="9" 
%     NUMIMAGES="1" 
%     VERSION="1.8" 
%     TILESIZE="256"
    
    
    %tilesDir = fullfile(directory, imageID);
    
    % download photo
end
 
