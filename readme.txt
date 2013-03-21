This is the way to download the connectivity images:

Edit the script combineImagesInFolder
and change the var resFromMax
where resFromMax=0 is the highest resolution.

Then run 
combineImagesInFolder(1);
...
combineImagesInFolder(50);

To download the images.
The program downloads the images in it patched form. and then stich the patches together.
So for each section you end up with one very high resolution image.


The high resolution files are in stored in the output folder.
