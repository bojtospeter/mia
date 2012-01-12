% mia - medical image analysis
%
% This Matlab GUI  enables you to do analysis on medical images. A collection 
% of tools are provided to perform slice or volume based analysis. Other hand 
% the program can be consider as a wrapper of useful previously developed and 
% own matlab tools for medical image processing. The following features are included:   
%
% Version 2.3
%
%  - working under unix
%  - slice and frame SLIDER added. This might be useful under unix
%    where the UP, DOWN, LEFT and RIGHT navigation keys does not always
%    work
%  - the statistics results of ROI and VOI(TAC) analysis can be saved 
%    as csv file under unix
%  - on the main figure the most of button has "ToolTip String" helping 
%    for the users
%  - loading dynamic analyze file (with the help of Roger Gunn, MNI, Montreal)
%  - loading CUB type CT file (with the help of Olivier Morin, Department
%       of Radiation Oncology University of California, San Francisco )
%  - loading and saving image file as MAT format
%     Storing a 3D scalar dataset for mia in a MAT file a structe 
%     to be defined:
%     VolumeInfo.imaVOL
%        %the 3D volume with size of [Xdim,Ydim,Zdim] 
%     VolumeInfo.pixelsize
%        %[xres yres zres] in [mm]. eg: [2 2 3.4]
%     VolumeInfo.isfloat 
%        % DataType flag: 0 for int16 data case, 1 for double data case. 
%          It is an important flag to conserv the memory usage by defining 
%          int16 variable type of the 3D dataset in general case.
%     Sample MAT file(the MATLAB MRI file) for mia can be found in the 
%     sample file package: http://petunia.atomki.hu/~balkay/mia/mia_samples.zip  
%
%  - mia does not contain further the EMMA library for minc format 
%    image file handling.(The main reason is the extra size). EMMA package 
%    for PC and the Linux can be downloded from: 
%           http://www.bic.mni.mcgill.ca/users/fmorales/emma_matlab6.zip
%           http://www.bic.mni.mcgill.ca/users/fmorales/emma.tar.gz
%  - performing 3D interpolation
%  - improved zoom and pan possibilities on the main image and
%    also on any of the 3D cursor windows:
%       Middle drag to zoom and right drag to pan the image, 
%       double click to restore the original.
%  - changing the colorbar max and min values by the appropriate slider
%    the following figures will be refreshed automatically (if they opened):
%    main image, 3D cursor windows, sliceomatic figure, reslice windows
%  - improved improfile option
%  - defining a 'detail rectangle' to view the zoomed details
%    on the current slice
%
%
% Version 2.1 (default features)
%
% -	loading as saving dicom, analyse, minc, ecat v file format. 
%   For dicom loading multiply file selection enabled and the program 
%   try to produce a whole volume for image analysis 
%   (the extension should be as *.dcm). Dynamic investigations is
%   supported in the case of dicom (echo, angio), minc or ecat file.  
%   In file saving only the most important header information is transferred
%   (which defines the volume). The most of basic file I/O functions came 
%   from different universities, hospitals with the kindness of their authors:
%
%       - ecat reading/writing: the function use the ecatfile.m, 
%       readecatvol.m procedures from Aarhus University Hospitals (Denmark) by 
%       the kindness of Flemming Hermansen. 
%       - analyze reading/writing: this function also use the WriteAnalyzeImg,
%       readanalyimage functions from CNR(MR Department, Hvidovre Hospital,Denmark) 
%        by the help of Claus Svarer.
%       - minc reading/writing: the emma_v0_9_5 utility from MNI (Canada) is 
%       built in for file I/O handling in the case of minc files
%
% - two different modality files can be load at same time to analyze them at 
%   different transparency setting (good graphical card necessary to enable the 
%   efficient OpenGL mode)%
%
% -	easy scrolling between slices and frames using the 
%   UP, DOWN and the LEFT, RIGHT buttons on the main image.
%
% -	there is a pixel bar showing the pixel and distance 
%   information from the current slice
%
% -	mouse driven zoom/pan and image profile options
%
% -	3D cursor view mode, where the user can navigate 
%   on the volume by mouse
%
% -	3d rendering
%
% -	the well-known sliceomatic tool is incorporated
%   Slice and isosurface volume exploration task uses the slightly modified
%   Sliceomatic GUI, written by Eric Ludlam <eludlam@mathworks.com>
% 
% -	reslicing the volume showing the whole set of images at the 3 basic 
%   view (axial, coronal, sagittal)
%
% -	ROI and VOI(up to 8 different color set)  generation, saving and 
%   loading as mat file
%
% -	saving the ROI and VOI(TAC) statistics results as xls file           
%
% -	MIP avi generation
%
% -	saving Time frames as avi file (it would be useful for echo 
%   or angiography investigation)
%
%
%  This program is distributed in the hope that it will be useful, 
%  but not all situation has been checked. I wrote it for fun 
%  (I always enjoy working with matlab), there are no warranties 
%  expressed or implied.
%
% University of Debrecen, PET Center/Laszlo Balkay
% Author: Laszlo Balkay.
% email: balkay@pet.dote.hu
global dcminfo_ForCurrentSlice;
global ecatinfo_ForCurrentImage;
global DcmRowImage; 
global DcmHdrInfo;

mia_gui;