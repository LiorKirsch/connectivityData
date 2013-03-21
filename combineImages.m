
function image = combineImages(imageFolder,resolution, maxTileX, maxTileY)
    image = [];
    for i=0:(maxTileX - 1)
        colmun = [];
        for j=0:(maxTileY - 1)
            fileName = sprintf('%d-%d-%d.jpg', resolution, i,j);
            fileName = fullfile(imageFolder,fileName);
            try
                colmun = [colmun;imread(fileName)];
            catch
                blankImage = uint8(zeros(256,256,3));
                colmun = [colmun;blankImage];
            end
            
        end
        image = [ image, colmun];
    end
            
end
 