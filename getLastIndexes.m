function [resolution, maxTileX, maxTileY] = getLastIndexes(resFromMax,width, height, tileSize, numTiers)
    resolution = numTiers - resFromMax -1;
    maxTileX = floor(width / tileSize / 2^resFromMax);
    maxTileY = floor(height / tileSize/ 2^resFromMax);
end