# Photo transformation using base station locations
The project is about using base station locations to transform photos taken by mobile devices. The goal is to detect the location of this mobile devices in the local coordinate system from the base station locations. 
# TODO
- [ ] Error in the people axes since the readArucoMarkers have a different orientation that the ones obtained from the markers 
## Requisites

- Matlab 2024a or above

# Phone calibration
To obtain calibration data for phone, take multiple photos of the checkerboard and save them on a google drive folder as `*.HEIC`. Use the code in preprocesing images section to obtain `*.jpg` images that will be used for calibrating the camera
To calibrate the camera, use the in-built app in matlab called `camera calibrator`. Then export the output to workplace and save the variable  `cameraParams` to a specified folder. 


## Preprocessing of Images
Images captured on the phone must be added to a drive file to prevent any deformations or compression when transfering images. 
The raw image obtained from the phone should have a format file of '.HEIC'. To change all the images from .HEIC to .jpg input in terminal from image folder
```
sudo apt-get install libheif-examples
for file in *.HEIC; do
    filename="${file%.HEIC}"
    heif-convert -q 100 "$file" "${filename}.jpg"
done
```


# Localisation of bases using AR tags

Please update code until line 80 using the approach used in: 

https://github.com/daniel-perezb/localisation

After obtaining the location of all markers, the code in main.m determines the location of a person capturing an image of the marker. This allows for the localization of different people at different times on a map using only data obtained from images taken.

After capturing multiple pictures of the markers, the orientation and location of the markers are updated to match the coordinates obtained from the theodolite scans. Pose from the AR tag is obtaine dusing Matlab documentation in [here](https://au.mathworks.com/help/vision/ref/readarucomarker.html?s_tid=doc_ta#mw_c3d8aa14-aa4e-41af-aa42-e6f12ab79f75_sep_mw_0ba1f907-4cfa-44c1-88a3-664d27c33d29) where:

In the `getPose.m` file update `arTagImagePath` (path of the AR tag image), `camParamMatFilePath` (saved during calibration step) and `markerSizeMM` (size of the AR tag in mm) 


The marker number in each image is defined using the section below:
```
Marker_Image = [2, 4, 2, 4, 2, 4];
```

## Generating AR tags
You can generate AR markers using a online website like [this](https://fodi.github.io/arucosheetgen/) and print them.
