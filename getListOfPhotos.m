% download images:
% readJson

function [listOfPhotos listOfPhotosTags] = getListOfPhotos(region)

    regionUrl = ['http://connectivity.brain-map.org/api/v2/data/Injection/query.json?wrap=true',...
        '&criteria=%5Bprimary_injection_structure_id%24eq726%5D%2Cspecimen(donor(products%5Bid%24eq5%5D))',...
        '&include=structure%5Bid%24eq726%5D%2Cspecimen(donor(age)%2Cdata_sets%5Btype%24eqSectionDataSet%5D)',...
        '&order=structures.name%2C+data_sets.id&numRows=25'];
    regionUrl  = 'http://connectivity.brain-map.org/api/v2/data/Injection/query.json?wrap=true&criteria=%5Bprimary_injection_structure_id%24eq409%5D%2Cspecimen(donor(products%5Bid%24eq5%5D))&include=structure%5Bid%24eq409%5D%2Cspecimen(donor(age)%2Cdata_sets%5Btype%24eqSectionDataSet%5D)&order=structures.name%2C+data_sets.id&numRows=25';
    url = ['http://connectivity.brain-map.org/api/v2/data/SectionDataSet/100141214.json?', ...
          'wrap=true&include=plane_of_section%2Ctreatments%2Cspecimen(donor(age))%2C', ...
          'section_images(associates)%2Cgenes&order=sub_images.section_number%24desc'];
      
    imageCount = 0;
    fields = 'id,name,count'; 
    jsonString = urlread(regionUrl);
    data = parse_json(jsonString);
    
    expriments = data.msg;
    for i = 1:length(specimen.data_sets)
       currentExp = expriments{i};
       dataSetsInExpriment = currentExp.specimen.data_sets;
       for j=1:length(dataSetsInExpriment)
           currentDataSet = dataSetsInExpriment{j};
           dataImageSetId =  currentDataSet.id;
       end
    end
    if isempty(data.data)
        fprintf('got an empty albums request on %s\n', getAlbumsURL);
        listOfPhotos = {};
        listOfPhotosTags = {};
    else
        albums = cell(length(data.data),1);
        albumsTags = cell(length(data.data),1);
        for i=1:length(data.data)
            if isfield(data.data{i},'count')
                currentAlbumID = data.data{i}.id;
                [albums{i} albumsTags{i}] = getImageInAlbum(currentAlbumID,token);
                imageCount = imageCount + length(albums{i});
            else
                fprintf('album %s (%s) has no images\n', data.data{i}.name, data.data{i}.id);
            end
        end
        
        listOfPhotos = flattenPhotosStructure(albums,imageCount);
        listOfPhotosTags = flattenPhotosStructure(albumsTags,imageCount);
    end
    
    
    
end
