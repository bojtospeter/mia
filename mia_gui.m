function varargout = mia_gui(varargin)
% mia_GUI M-file for mia_gui.fig
%      mia_GUI, by itself, creates a new mia_GUI or raises the existing
%      singleton*.
%
%      H = mia_GUI returns the handle to a new mia_GUI or the handle to
%      the existing singleton*.
%
%      mia_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in mia_GUI.M with the given input arguments.
%
%      mia_GUI('Property','Value',...) creates a new mia_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs
%      are
%      applied to the GUI before mia_gui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mia_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mia_gui

% Last Modified by GUIDE v2.5 20-Apr-2010 08:46:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mia_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @mia_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

%%  --- Executes just before mia_gui is made visible.
function mia_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mia_gui (see VARARGIN)

% set the main figure to the possible most upper position 
ScreenSize = get(0,'screenSize');
Position0 = get(handles.mia_figure1,'Position');

set(handles.mia_figure1,'Position',[Position0(1),  ... 
    ScreenSize(4)-Position0(4)*1.1 , Position0(3), Position0(4)]);

%zoom and opengl does not work well with some video card
openglinfo = opengl('data');
handles.openglinfo.Renderer = openglinfo.Renderer;
handles.openglinfo.UseGenericOpenGL = 0;
handles.openglinfo.miafigure_useOpenGL = 0;

if strcmp(openglinfo.Renderer,'GeForce4 Ti 4200 with AGP8X/AGP/SSE2') | ...
   strcmp(openglinfo.Renderer,'Savage4')
    handles.openglinfo.UseGenericOpenGL = 1;
    feature('UseGenericOpenGL',1); % turn off the hardwer version of opengl
else
    handles.openglinfo.UseGenericOpenGL = 1;
end

% Choose default command line output for mia_gui
handles.output = hObject;

handles.ColorRes = 128; % used color resolution in color maps
handles.ROINumOfColor = 8; % number of color used for ROI coloring
handles.ROIperSliceMaxNumber = 128; % maximum number of ROI/slice
handles.decimal_prec_default = 4;
% color codes for ROI colors
for i=1: 128;handles.ROIColorStrings(i) = 'k';end
for i=51: 122;handles.ROIColorStrings(i) = 'y';end
for i=123: 128;handles.ROIColorStrings(i) = 'r';end
handles.ROIColorStrings(40) = 'b'; % roi color for 70% lesion threshold
handles.ROIColorStrings(41) = 'y'; % roi color for total lesion threshold
handles.ROIColorStrings(1:8) = ['y','m','c','r','g','b','w','k']; % color of the DEF. ROI colors

handles.ROIColorStringsLong = cellstr(['yellow ';'magenta';'cyan   ';'red    '; ...
        'green  ';'blue   ';'white  ';'black  ']); % long names for ROI colors
% ROI IDs for NEMA defined ROIs
handles.ROI_NEMAQspeheresid = [123 : 128]; % diam of ROI: [10, 13, 17, 22, 28, 37] mm
handles.ROI_NEMAQbackgr = [51:122]; % 12 ROIs of each of [10, 13, 17, 22, 28, 37] mm
% ROI IDs for lesion volume calculation tasks
handles.ROI_LesionThres70 = 40;
handles.ROI_LesionThresTotal = 41;
handles.ROI_LesionExternal = 42;
handles.ROI_LesionBackground = 43;

% linear fitting parameter for lesion volume calculation tasks
handles.lesionvolcal_slope = [];
handles.lesionvolcal_intercept = [];

% initiate variables for image handlers of resliced maps
handles.haxial = []; handles.hcoronal= []; handles.hsagital= [];
handles.haxial2 = []; handles.hcoronal2= []; handles.hsagital2= [];
% initiate variables for image handlers of sliceomatic_mia and improfile tools
handles.sliceomatic_haxmain = [];
handles.hf_improfile = 0;

% set some deafult settings for GUI
set(handles.MeasureTogglebutton,'value',1);
set(handles.RoiColor4ToggleButton,'value',1);% red ROI color on
handles.CurrentROIColor = 4;
set(handles.RenderingLevelEdit,'String',[]);
set(handles.RenderingLevel2Edit,'String',[]);
set(handles.CurrentFrameEdit,'String',[]);
set(handles.CurrentSliceEdit,'String',[]);
set(handles.ImaAxes,'Yticklabel',{});
set(handles.ImaAxes,'Xticklabel',{});
set(handles.CurrentFrameLengthEdit,'visible','off');
set(handles.CurrentFrameLengthText,'visible','off');
set(handles.CurrentFrameTimeEdit,'visible','off');
set(handles.CurrentFrameTimeText,'visible','off');
set(handles.FrameSlider,'visible','off');
miaControlSetup(2,handles);
axes(handles.ImaAxes);
image(zeros(256,256,3));
axis off;
handles.DICOMDIRmenu_1Selected = 0;
handles.DICOMDIRmenu_2Selected = 0;
handles.DICOMServermenu_Selected = 0;

%defining the global variable for mia_pixval function
global gVOIpixval;
gVOIpixval.pixunit = 'mm';
gVOIpixval.xypixsize = [];
gVOIpixval.CurrentImage = [];
gVOIpixval.CurrentAxes = handles.ImaAxes;
gVOIpixval.xLim = [];
gVOIpixval.yLim = [];

% set some menu items
set(handles.MouseSelected,'enable','off');
set(handles.MouseSelected2,'enable','off');
set(handles.DynFrameMovie,'enable','off');
set(handles.SaveDynFramesAsAvi,'enable','off');
set(handles.SumFrames,'enable','off');
set(handles.OpenDICOMDIRfromCurrent,'enable','off');
set(handles.Open2DICOMDIRfromCurrent,'enable','off');


if ~ispc % no excel output
    set(handles.SaveTACMenuItem,'label','Save VOI TAC (as txt file) ');
    set(handles.SaveROIStatMenuItem,'label','Save ROI statistics (as txt file)');
end

if nargin == 4
    handles.inputpath = char(varargin{1});
    % Update handles structure
    guidata(hObject, handles);
else
    %handles.scaninfo = varargin{2};
    % Update handles structure
    guidata(hObject, handles);
end
if str2double(license) == (206212) & ispc
    tmp = userinfo;
end

% UIWAIT makes mia_gui wait for user response (see UIRESUME)
% uiwait(handles.mia_figure1);


%%  --- Outputs from this function are returned to the command line.
function varargout = mia_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%%  --------------------------------------------------------------------
function OpenImage()
OpenImageFilemenuItem_Callback(handles.OpenImageFilemenuItem, [], handles);

%%  --------------------------------------------------------------------
function OpenImageFilemenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenImageFilemenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~handles.DICOMServermenu_Selected
    if ~handles.DICOMDIRmenu_1Selected
        dicomdirYES = 0;
        % if previous imaVOL is currently being opened delete and set 
        % the appropriate objects
        if isfield(handles,'FileNames')
            handles = ClearImages(handles,2);
            drawnow;
            set(handles.mia_figure1,'keyPressFcn','mia_gui(''mia_figure1_KeyPressFcn'',gcbo,[],guidata(gcbo))');
        end

        % if inputpath was supplied as varargin set this as startup_dir to uigetfiles.m 
        if isfield(handles,'inputpath')
            if ispc
                [FilesSelected, dir_path] = uigetfiles(...
                '*.img;*.mnc;*.dcm;*.v;*.V;*.i;*.S;*.ima;*.IMA;*.cub;*.mat','Select image file',handles.inputpath);
            else
                [FilesSelected, dir_path] = uigetfiles2('Start', '*.*', handles.inputpath);
            end
        else
            % if this is not the first file opening, use the handles.dirname as startup_dir to uigetfiles.m 
            if isfield(handles,'dirname')
                if ispc
                    [FilesSelected, dir_path] = uigetfiles(...
                    '*.img;*.mnc;*.dcm;*.v;*.V;*.i;*.S;*.ima;*.IMA;*.cub;*.mat','Select image file',handles.dirname);
                else
                    [FilesSelected, dir_path] = uigetfiles2('Start', '*.*', handles.dirname);
                end
            else
                if ispc
                    [FilesSelected, dir_path] = uigetfiles(...
                    '*.img;*.mnc;*.dcm;*.v;*.V;*.i;*.S;*.ima;*.IMA;*.cub;*.mat','Select image file');
                else
                    [FilesSelected, dir_path] = uigetfiles2('Start', '*.*');
                end
            end
        end
    else % if the open DICOMDIR menu item was selected 
        FilesSelected = handles.dcmdir.dcmSeries.Images';
        dir_path = handles.dcmdir.dcmSeries.Path;
        dicomdirYES = 1;
        handles.DICOMDIRmenu_1Selected = 0;
    end

    if isempty(FilesSelected);return;end

    handles.FileNames = sortrows(FilesSelected');
    handles.dirname = dir_path;
    %if isfield(handles,'inputpath')
    %    cd(matlabroot);
    %end
    %
    % identify the file type :img, mnc or ima, and
    % load the appropriate imaVOL
    %
    [fpath,fname,fextension,fversion] = fileparts(char(handles.FileNames(1)));
    handles.fextension = char(fextension);
    handles.fname = char(fname);
    if strcmp(lower(char(fextension)),'.ima') 
        num_of_files = size(handles.FileNames,1);
        for i=1:num_of_files
            filelist(i).name = char(handles.FileNames(i));
        end
        filelist = filelist';
        filename=[];jobinfo=1;
        [handles.imaVOL, handles.scaninfo, handles.fileheader] = loadvaxima(filename,jobinfo,filelist,handles.dirname);
    elseif strcmp(char(fextension),'.mnc')
        [handles.imaVOL, handles.scaninfo] = loadminc([handles.dirname,char(handles.FileNames(1))]);
    elseif strcmp(char(fextension),'.dcm') | strcmp(char(fextension),'') | dicomdirYES
        [handles.imaVOL, handles.scaninfo] = loaddcm(handles.FileNames,handles.dirname);
    elseif strcmp(lower(char(fextension)),'.v') | strcmp(lower(char(fextension)),'.V') | strcmp(char(fextension),'.i') | strcmp(char(fextension),'.S')
        [handles.imaVOL, handles.scaninfo handles.ecatinfo] = loadecat([handles.dirname,char(handles.FileNames(1))]);
    elseif strcmp(char(fextension),'.img')
        [handles.imaVOL, handles.scaninfo] = loadanalyze([handles.dirname,char(handles.FileNames(1))]);
    elseif strcmp(char(fextension),'.cub')
        [handles.imaVOL, handles.scaninfo] = loadcube([handles.dirname,char(handles.FileNames(1))]);
    elseif strcmp(char(fextension),'.mat')
        [handles.imaVOL, handles.scaninfo] = loadmat([handles.dirname,char(handles.FileNames(1))]);
    else
        hm = msgbox(['No image file was selected. The supported files are: ',...
        '*.img;*.mnc;*.dcm;*.v;*.ima;*.cub;*.mat'],'mia Info' );
        return; 
    end
else % if the open DICOMDIR menu item was selected 
    handles.DICOMServermenu_Selected = 0;
    handles.FileNames = 'DicomServer';
    handles.dirname = pwd;
    fextension = '.dcmserv';
end
if isempty(handles.imaVOL)% error during file opening 
    hm = msgbox('Error during file opening. For details See the Matlab Command Window','mia Info' );
    return; 
end

% set the default colormap to spectral
set(handles.ImaListbox,'String',handles.FileNames,...
	'Value',1);

% inititate the ImaAxes figure
axes(handles.ImaAxes);
CurrentSlice = round(handles.scaninfo.num_of_slice/2);
CurrentImgIdx = handles.scaninfo.num_of_slice*(handles.scaninfo.Frames-1)+CurrentSlice;
CurrentImage = handles.imaVOL(:,:,handles.scaninfo.num_of_slice*(handles.scaninfo.Frames-1)+CurrentSlice);
CurrentImageMinMax = [min(CurrentImage(:)) max(CurrentImage(:)) ];
% if CurrentImageMinMax(2) == 0
%    CurrentImageMinMax(2) = max(handles.imaVOL(:));     
% end
CurrentImageMinMax(2) = max(handles.imaVOL(:)); % set the current max to the global max    
handles.VolMax = double(max(handles.imaVOL(:)));
handles.VolMin = double(min(handles.imaVOL(:)));
if handles.scaninfo.float % imaVOL type is float
    handles.decimal_prec = handles.decimal_prec_default;
else
    handles.decimal_prec = 0;
end
%Create the RGB image
if strcmp(char(fextension),'.dcm') | strcmp(char(fextension),'') ...
        | strcmp(char(fextension),'.cub') 
    % in case of dcm, cube and mat file the default colormap is gray
    Initial_cmap = gray(handles.ColorRes);
    set(handles.ColorMapPopupmenu,'Value',3);
else
    %otherwise the colormap spectral
    set(handles.ColorMapPopupmenu,'Value',1);
    Initial_cmap = spectral(handles.ColorRes);
end
CurrentImage_RGB = ... 
    CreateRGBImage(CurrentImage,CurrentImageMinMax,handles.ColorRes,Initial_cmap);
ImaHandler = image(CurrentImage_RGB);
set(handles.ImaAxes,'PlotBoxAspectRatioMode','manual');
PlotBAspectRatio = [ size(handles.imaVOL,2)*handles.scaninfo.pixsize(2) ...
    size(handles.imaVOL,1)*handles.scaninfo.pixsize(1) 1];
set(handles.ImaAxes,'PlotBoxAspectRatio',PlotBAspectRatio);
set(handles.ImaAxes,'Tag','ImaAxes');
handles.ImaHandler = ImaHandler;
set(handles.ImaHandler,'Tag','MainImage');
axis off;

%Create the initial colorbar
col=Initial_cmap;
r=col(:,1);g=col(:,2);b=col(:,3);
CMapImgRes=[1:handles.ColorRes];
CMapImg=cat(3,r(CMapImgRes),g(CMapImgRes),b(CMapImgRes));
axes(handles.CmapAxes);
set(handles.CmapAxes,'visible','on');
hcb = image(CMapImg);
handles.hcb = hcb;
set(handles.hcb,'tag','ColorbarImage');
set(handles.hcb,'buttonDownFcn','mia_gui(''SetImageContrast'',gcbo,[],guidata(gcbo))');
set(handles.CmapAxes,'Xticklabel',{});
set(handles.CmapAxes,'Ydir','normal');
set(handles.CmapAxes,'YaxisLocation','right');
Yticks = linspace(0,handles.ColorRes,5);
set(handles.CmapAxes,'Ytick',Yticks);
set(handles.CmapAxes,'Yticklabel',num2cell(Yticks));
handles.NumOfYtickOfColorbar =  length(get(handles.CmapAxes,'Yticklabel'));
hold on;
handles.ColormapIn1 = Initial_cmap;
newlabels = num2cell(fixround(linspace(handles.VolMin,handles.VolMax,handles.NumOfYtickOfColorbar),handles.decimal_prec))';
set(handles.CmapAxes,'Yticklabel',newlabels);
set(handles.CmapAxes,'Tag','CmapAxes');
handles.zoom = 0;
refresh;
%set(ImaHandler,'EraseMode','xor');
%set(get(handles.ImaAxes,'children'),'EraseMode','none');
%
%set the current slice and frame indexes
%
handles.CurrentSlice = CurrentSlice;
handles.CurrentFrame = handles.scaninfo.Frames;
handles.CurrentImgIdx = CurrentImgIdx;
set(handles.CurrentFrameEdit,'String',handles.CurrentFrame);
set(handles.CurrentSliceEdit,'String',handles.CurrentSlice);
if handles.scaninfo.Frames > 1 % dynamic scan
    if handles.scaninfo.num_of_slice == 1 %in case of planar scan (echo, angio ..) turn on the  
        set(handles.DynFrameMovie,'enable','on'); % movie options
        set(handles.SaveDynFramesAsAvi,'enable','on');
    end
    set(handles.SumFrames,'enable','on');
    set(handles.CurrentFrameLengthEdit,'visible','on');
	set(handles.CurrentFrameLengthText,'visible','on');
	set(handles.CurrentFrameTimeEdit,'visible','on');
	set(handles.CurrentFrameTimeText,'visible','on');
    set(handles.CurrentFrameTimeEdit,'String', ...
        sprintf('%1.2f',handles.scaninfo.tissue_ts(handles.CurrentFrame)/60));%min
    set(handles.CurrentFrameLengthEdit,'String', ...
        sprintf('%1.2f',handles.scaninfo.frame_lengths(handles.CurrentFrame)/60));%min
    set(handles.FrameSlider,'visible','on');
    %
	% initiate the Frame Slider
	%
	set(handles.FrameSlider,'Min',1); 
	set(handles.FrameSlider,'Max',handles.scaninfo.Frames);
	set(handles.FrameSlider,'value',handles.scaninfo.Frames);
	set(handles.FrameSlider,'SliderStep',...
        [1/(handles.scaninfo.Frames - 1) 10/(handles.scaninfo.Frames - 1)] );
    
end
%
% initiate the ColorBar Sliders
%
set(handles.ColorBarMaxSlider,'Min',handles.VolMin); 
set(handles.ColorBarMaxSlider,'Max',handles.VolMax);
set(handles.ColorBarMinSlider,'Min',handles.VolMin); 
set(handles.ColorBarMinSlider,'Max',handles.VolMax);
set(handles.ColorBarMaxSlider,'Value',CurrentImageMinMax(2));
set(handles.ColorBarMinSlider,'Value',CurrentImageMinMax(1));
%
% inititate the ROI,VOI parameters
%
handles.ROI = [];
handles.ROI(handles.scaninfo.num_of_slice,handles.ROIperSliceMaxNumber).BW = [];
handles.ROI(handles.scaninfo.num_of_slice,handles.ROIperSliceMaxNumber).xi = [];
handles.ROI(handles.scaninfo.num_of_slice,handles.ROIperSliceMaxNumber).yi = [];
handles.Lines(handles.scaninfo.num_of_slice,handles.ROIperSliceMaxNumber).lh = [];
handles.VOI(handles.ROINumOfColor).tac = [];
handles.VOI(handles.ROINumOfColor).tacstd = [];
handles.VOI(handles.ROINumOfColor).tacmin = [];
handles.VOI(handles.ROINumOfColor).tacmax = [];
handles.VOI(handles.ROINumOfColor).tacvolume = [];     
%
% delete the inputpath if supplied at startup  
%
if(isfield(handles,'inputpath'));
    handles = rmfield(handles,'inputpath');
end
%
%set the menu items if necessary
%
if handles.scaninfo.Frames == 1
    set(handles.SumFrames,'enable','off');
else
    set(handles.SumFrames,'enable','on');
end
%
% set the 3D controls to be on in case of 3D imaVOL
%
if handles.scaninfo.num_of_slice > 1;
    miaControlSetup(0,handles);
    %
	% initiate the Slice Slider
	%
	set(handles.SliceSlider,'Min',1); 
	set(handles.SliceSlider,'Max',handles.scaninfo.num_of_slice);
	set(handles.SliceSlider,'value',CurrentSlice);
	set(handles.SliceSlider,'SliderStep',...
        [1/(handles.scaninfo.num_of_slice-1) 10/(handles.scaninfo.num_of_slice-1)] );
elseif handles.scaninfo.num_of_slice == 1
    miaControlSetup(2,handles);
end 


%
% initiate the mia_pixval function
%
axes(handles.ImaAxes);
global gVOIpixval;
if strcmp(char(fextension),'.mnc') 
    gVOIpixval.xypixsize(1) = handles.scaninfo.pixsize(2);
    gVOIpixval.xypixsize(2) = handles.scaninfo.pixsize(1);
else
    gVOIpixval.xypixsize = handles.scaninfo.pixsize;
end
gVOIpixval.CurrentImage = CurrentImage;
gVOIpixval.xLim = get(handles.ImaAxes,'XLim');
gVOIpixval.yLim = get(handles.ImaAxes,'YLim');
mia_pixval(handles.ImaHandler,'on');

% Update handles structure
%
guidata(hObject, handles);

%%  --------------------------------------------------------------------
function OpenDICOMDIRmain_Callback(hObject, eventdata, handles)
% hObject    handle to OpenDICOMDIRmain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%%  --------------------------------------------------------------------
function OpenDICOMDIRfromNew_Callback(hObject, eventdata, handles)
% hObject    handle to OpenDICOMDIRfromNew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% if previous imaVOL is currently being opened delete and set 
% the appropriate objects
if isfield(handles,'FileNames')
    handles = ClearImages(handles,2);
    drawnow;
    set(handles.mia_figure1,'keyPressFcn','mia_gui(''mia_figure1_KeyPressFcn'',gcbo,[],guidata(gcbo))');
end

[dcmSeries, dcmPatient, SeriesList, SeriesListNumInfo] = loaddcmdir;
if isempty(dcmSeries);
    disp('No DICOM Series was selected!');
    return;
end
handles.dcmdir = [];
handles.dcmdir.dcmSeries = dcmSeries;
handles.dcmdir.dcmPatient = dcmPatient;
handles.dcmdir.SeriesList = SeriesList;
handles.dcmdir.SeriesListNumInfo = SeriesListNumInfo;
handles.DICOMDIRmenu_1Selected = 1;
set(handles.OpenDICOMDIRfromCurrent,'enable','on');

% Update handles structure
guidata(hObject, handles);

% Run the OpenFileMenuItem to load the selected dcm series
OpenImageFilemenuItem_Callback(handles.OpenImageFilemenuItem, [], handles);

%%  --------------------------------------------------------------------
function OpenDICOMDIRfromCurrent_Callback(hObject, eventdata, handles)
% hObject    handle to OpenDICOMDIRfromCurrent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'FileNames')
    handles = ClearImages(handles,2);
    drawnow;
    set(handles.mia_figure1,'keyPressFcn','mia_gui(''mia_figure1_KeyPressFcn'',gcbo,[],guidata(gcbo))');
end

dcmPatient = handles.dcmdir.dcmPatient;
SeriesList = handles.dcmdir.SeriesList;
SeriesListNumInfo = handles.dcmdir.SeriesListNumInfo;
dicomdirpath = handles.dcmdir.dcmSeries.Path;
handles.DICOMDIRmenu_1Selected = 1;

% create popupmenu for dicomseries
global dcmdirlistVal;
dcmdirlistVal = 0;
dcmdirlistfh = figure('menubar','none','NumberTitle','off','name','DICOMDIR info','position',[250   400   760   520]);
lbh = uicontrol('Style','listbox','Position',[10 60 720 440],'tag','dcmdirlist_popupmenu');
set(lbh,'string',SeriesList);
OKCallback = 'global dcmdirlistVal; dcmdirlistVal = get(findobj(''tag'',''dcmdirlist_popupmenu''),''value''); delete(findobj(''name'',''DICOMDIR info''));';
CancelCallback = 'delete(findobj(''name'',''DICOMDIR info''));';
OK_h = uicontrol('Style', 'pushbutton', 'String', 'OK','Position', [440 10 80 30], 'Callback', OKCallback);
Cancel_h = uicontrol('Style', 'pushbutton', 'String', 'Cancel','Position', [340 10 80 30], 'Callback', CancelCallback);

uiwait(dcmdirlistfh);

if dcmdirlistVal == 0;
    disp('No DICOM Series was selected!');
    return;
end

% create the outputs
dcmSeriesPath = dcmPatient(SeriesListNumInfo(dcmdirlistVal).PatientNum). ...
    Study(SeriesListNumInfo(dcmdirlistVal).StudyNum). ...
    Series(SeriesListNumInfo(dcmdirlistVal).SeriesNum). ...
    ImagePath;
% dcmSeries.Path = [dicomdirpath, filesep, dcmSeriesPath, filesep];
% dcmSeries.dicomdirpath = dicomdirpath;
dcmSeries.Path = dicomdirpath;
dcmSeries.dicomdirpath = [dicomdirpath, filesep, dcmSeriesPath, filesep];
dcmSeries.Images = dcmPatient(SeriesListNumInfo(dcmdirlistVal).PatientNum). ...
    Study(SeriesListNumInfo(dcmdirlistVal).StudyNum). ...
    Series(SeriesListNumInfo(dcmdirlistVal).SeriesNum). ...
    ImageNames;
handles.dcmdir.dcmSeries = dcmSeries;

% Update handles structure
guidata(hObject, handles);

% Run the OpenFileMenuItem to load the selected dcm series
OpenImageFilemenuItem_Callback(handles.OpenImageFilemenuItem, [], handles);



%%  --------------------------------------------------------------------
function OpenDicomServer_Callback(hObject, eventdata, handles)
% hObject    handle to OpenDicomServer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% if previous imaVOL is currently being opened delete and set 
% the appropriate objects
global DcmRowImage; 
global DcmHdrInfo;

if isfield(handles,'FileNames')
    handles = ClearImages(handles,2);
    drawnow;
    set(handles.mia_figure1,'keyPressFcn','mia_gui(''mia_figure1_KeyPressFcn'',gcbo,[],guidata(gcbo))');
end

dcmaet = 'MATLAB';dcmaec = 'PET-CT_HOST031';dcmport = '104';dcmhost = '192.168.114.2';
[imaVOL DcmHdrInfo, scaninfo] = dcmserver_connection(dcmaet,dcmaec,dcmhost,dcmport);
scaninfo.FileType    = 'dcmserv';

handles.scaninfo = scaninfo;
handles.imaVOL = imaVOL;
handles.DICOMServermenu_Selected = 1;

% Update handles structure
guidata(hObject, handles);

% Run the OpenFileMenuItem to load the selected dcm series
OpenImageFilemenuItem_Callback(handles.OpenImageFilemenuItem, [], handles);


%%  --------------------------------------------------------------------
function Open2ndImageFilemenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to Open2ndImageFilemenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if not(isfield(handles,'FileNames'));return;end % 1st file should be opened first

% if this is not the first file opening, use the handles.dirname as startup_dir to uigetfiles.m 
if isfield(handles,'dirname')
    if ispc
        [FilesSelected2, dir_path2] = uigetfiles( ...
            '*.img;*.mnc;*.dcm;*.v;*.V;*.i;*.S;*.ima;*.cub;*.mat','Select image files',handles.dirname);
    else
        [FilesSelected2, dir_path2] = uigetfiles2('Start', '*.*', handles.dirname);
    end
else
    if ispc
        [FilesSelected2, dir_path2] = uigetfiles(...
            '*.img;*.mnc;*.dcm;*.v;*.V;*.i;*.S;*.ima;*.cub;*.mat','Select image files');
    else
        [FilesSelected2, dir_path2] = uigetfiles2('Start', '*.*');
    end
end

if isempty(FilesSelected2); return; end
miaControlSetup(1,handles);

% if previous imaVOL2 is currently being opened delete the appropriate
% objects
if (isfield(handles,'FileNames2'))
	delete(handles.ImaHandler2);
	delete(handles.hcb2);
	handles = rmfield(handles,'ImaHandler2');
	handles = rmfield(handles,'FileNames2');
	handles = rmfield(handles,'imaVOL2');
	handles = rmfield(handles,'scaninfo2');
	handles = rmfield(handles,'hcb2');
end 

handles.FileNames2 = sortrows(FilesSelected2');
handles.dirname2 = dir_path2;
%
% identify the file type :mnc or ima, and
% load the appropriate imaVOL
%
[fpath,fname,fextension,fversion] = fileparts(char(handles.FileNames2(1)));
handles.fextension2 = char(fextension);
handles.fname2 = char(fname);
if strcmp(char(fextension),'.ima')
    num_of_files = size(handles.FileNames2,1);
	for i=1:num_of_files
        filelist(i).name = char(handles.FileNames2(i));
	end
	filelist = filelist';
    filename=[];jobinfo=1;
    [handles.imaVOL2, handles.scaninfo2, handles.fileheader2] = loadvaxima(filename,jobinfo,filelist,handles.dirname2);
elseif strcmp(char(fextension),'.mnc')
    [handles.imaVOL2, handles.scaninfo2] = loadminc([handles.dirname2,char(handles.FileNames2(1))]);
elseif strcmp(char(fextension),'.dcm') | strcmp(char(fextension),'')
    [handles.imaVOL2, handles.scaninfo2] = loaddcm(handles.FileNames2,handles.dirname2);
elseif strcmp(lower(char(fextension)),'.v') | strcmp(lower(char(fextension)),'.V') | strcmp(lower(char(fextension)),'.i') | strcmp(lower(char(fextension)),'.S')
    [handles.imaVOL2, handles.scaninfo2 handles.ecatinfo2] = loadecat([handles.dirname2,char(handles.FileNames2(1))]);
elseif strcmp(char(fextension),'.img')
    [handles.imaVOL2, handles.scaninfo2] = loadanalyze([handles.dirname2,char(handles.FileNames2(1))]);
elseif strcmp(char(fextension),'.cub')
    [handles.imaVOL2, handles.scaninfo2] = loadcube([handles.dirname2,char(handles.FileNames2(1))]);
elseif strcmp(char(fextension),'.mat')
    [handles.imaVOL2, handles.scaninfo2] = loadmat([handles.dirname2,char(handles.FileNames2(1))]);
else
    hm = msgbox(['No image file was selected. The supported files are: ',...
    '*.img;*.mnc;*.dcm;*.v;*.ima;*.cub;*.mat'],'mia Info' );
    return; 
end
if isempty(handles.imaVOL2)% error during file opening
    hm = msgbox('Error during the file opening. For details See the Matlab Command Window','mia Info' );
    return;
end
%
% if size(imaVOL2) ~= size(imaVOL) then imaVOL2 should transfrom to the
% imaVOL voxelspace 
%
VOLsizeRel = size(handles.imaVOL,1) ~= size(handles.imaVOL2);
if VOLsizeRel(1) | VOLsizeRel(2) | VOLsizeRel(3) 
    button = questdlg(['The 2nd image dimensions does not fit to the 1st. ones. ', ...
     'Do you want to put them into same coordinate system?'], ...
	'mia info','Yes','No','No');
	if strcmp(button,'Yes')
        object_out = PutIntoSameVoxelSpace(handles.imaVOL,handles.scaninfo.pixsize, ...
            handles.imaVOL2,handles.scaninfo2.pixsize,handles.mia_figure1);
        handles.imaVOL2 = object_out;
        handles.scaninfo2.pixsize = handles.scaninfo.pixsize;
        handles.scaninfo2.imfm = handles.scaninfo.imfm;
        handles.scaninfo2.num_of_slice = handles.scaninfo.num_of_slice;
	end
end


set(handles.ImaList2box,'String',handles.FileNames2,...
	'Value',1);

if isfield(handles,'FileNames')
    CurrentSlice = handles.CurrentSlice;
    CurrentImgIdx= handles.CurrentImgIdx;
else
    CurrentSlice = round(handles.scaninfo2.num_of_slice/2);
    CurrentImgIdx = handles.scaninfo2.num_of_slice*(handles.scaninfo2.Frames-1)+CurrentSlice;
end
CurrentImage = ...
    handles.imaVOL2(:,:,handles.scaninfo2.num_of_slice*(handles.scaninfo2.Frames-1)+CurrentSlice);
handles.VolMax2 = double(max(handles.imaVOL2(:)));
handles.VolMin2 = double(min(handles.imaVOL2(:)));
CurrentImageMinMax = [min(CurrentImage(:)) max(CurrentImage(:)) ];
if handles.scaninfo2.float % imaVOL type is float
    handles.decimal_prec2 = handles.decimal_prec_default;
else
    handles.decimal_prec2 = 0;
end

%Create the RGB image
Initial_cmap = gray(handles.ColorRes);
CurrentImage_RGB = ... 
    CreateRGBImage(CurrentImage,CurrentImageMinMax,handles.ColorRes,Initial_cmap);

% set the figure renderer property to OPENGL enabling the transparency
set(handles.mia_figure1,'renderer','opengl');
handles.openglinfo.miafigure_useOpenGL = 1;

% inititate the ImaAxes figure
axes(handles.ImaAxes);
set(handles.hcb,'buttonDownFcn','mia_gui(''SetImageContrast'',gcbo,[],guidata(gcbo))');
hold on;

% show the image
ImaHandler = image(CurrentImage_RGB);

% if image format (x*y) of imaVOl is not equal to imaVOL2 then 
% the images of imaVOL2 has to fit to  the previously generated imaVOL's image 
if handles.scaninfo2.imfm(1) ~=  handles.scaninfo.imfm(1)
    set(ImaHandler,'XData',[1 handles.scaninfo.imfm(1)]);
    set(ImaHandler,'YData',[1 handles.scaninfo.imfm(2)]);
end
handles.ImaHandler2 = ImaHandler;
set(handles.ImaHandler2,'Tag','MainImage2');
% set the transparency
set(ImaHandler,'AlphaData',0.5);


%Create the initial colorbar
col=Initial_cmap;
r=col(:,1);g=col(:,2);b=col(:,3);
CMapImgRes=[1:handles.ColorRes];
CMapImg=cat(3,r(CMapImgRes),g(CMapImgRes),b(CMapImgRes));
axes(handles.Cmap2Axes);
set(handles.Cmap2Axes,'visible','on');
hcb = image(CMapImg);
handles.hcb2 = hcb;
set(handles.hcb2,'tag','ColorbarImage2');
set(handles.Cmap2Axes,'Xticklabel',{});
set(handles.Cmap2Axes,'Ydir','normal');
set(handles.Cmap2Axes,'YaxisLocation','right');
Yticks = linspace(0,handles.ColorRes,5);
set(handles.Cmap2Axes,'Ytick',Yticks);
set(handles.Cmap2Axes,'Yticklabel',num2cell(Yticks));
%set(handles.Cmap2Axes,'Ylim',[0 64]);
handles.NumOfYtickOfColorbar2 =  length(get(handles.Cmap2Axes,'Yticklabel'));
hold on;
handles.ColormapIn2 = Initial_cmap;
newlabels = num2cell(round(linspace(handles.VolMin2,handles.VolMax2,handles.NumOfYtickOfColorbar2)))';
set(handles.Cmap2Axes,'Yticklabel',newlabels);

handles.CurrentSlice2 = CurrentSlice;
handles.CurrentFrame2 = handles.scaninfo2.Frames;
handles.CurrentImgIdx2 = CurrentImgIdx;
set(handles.CurrentFrameEdit,'String',handles.CurrentFrame2);
set(handles.CurrentSliceEdit,'String',handles.CurrentSlice2);
% initiate the ColorBar Sliders
set(handles.ColorBarMax2Slider,'Min',handles.VolMin2); 
set(handles.ColorBarMax2Slider,'Max',handles.VolMax2);
set(handles.ColorBarMin2Slider,'Min',handles.VolMin2); 
set(handles.ColorBarMin2Slider,'Max',handles.VolMax2);
set(handles.ColorBarMax2Slider,'Value',CurrentImageMinMax(2));
set(handles.ColorBarMin2Slider,'Value',CurrentImageMinMax(1));
%initiate the Transparency Sliders
set(handles.TransparencySlider,'Min',0);
set(handles.TransparencySlider,'Max',1);
set(handles.TransparencySlider,'Value',0.5);


% Update handles structure
guidata(hObject, handles);

% initiate the mia_pixval function
%mia_pixval(handles.ImaHandler,'on');

%%  --------------------------------------------------------------------
function Open2DICOMDIRmain_Callback(hObject, eventdata, handles)
% hObject    handle to Open2DICOMDIRmain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%%  --------------------------------------------------------------------
function Open2DICOMDIRfromNew_Callback(hObject, eventdata, handles)
% hObject    handle to Open2DICOMDIRfromNew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%%  --------------------------------------------------------------------
function Open2DICOMDIRfromCurrent_Callback(hObject, eventdata, handles)
% hObject    handle to Open2DICOMDIRfromCurrent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%%  --------------------------------------------------------------------
function CloseImagesMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseImagesMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'FileNames')
	
    handles = ClearImages(handles);
    % Update handles structure
    guidata(hObject, handles);

end


%%  ------------------------------------
%--------------------------------
function handlesout = ClearImages(handles,clear_option)
% clear the all image and variable on the main gui
%

%if 3Dcursor is being opened
if get(handles.ThreeDcursortogglebutton,'value')
    delete(handles.D3CursorFigData.FigHandlerX);
    delete(handles.D3CursorFigData.FigHandlerY);
    delete(handles.D3CursorFigData.FigHandlerZ);
    handles = rmfield(handles,'D3CursorFigData');
    %set(handles.ThreeDcursor2togglebutton,'enable','on');
end

if isfield(handles,'FileNames')
    
    if nargin == 1
        clear_option = 0;
    end
    
    % delete ROI lines if exists and refresh the handle
    for i =1: handles.scaninfo(1).num_of_slice
        for j=1:handles.ROIperSliceMaxNumber
            if ~isempty(handles.ROI(i,j).BW )
				handles.ROI(i,j).BW = [];
				handles.ROI(i,j).xi = [];
				handles.ROI(i,j).yi = [];
				delete(handles.Lines(i,j).lh);
                handles.Lines(i,j).lh = [];
			end
        end
	end
    
    % delete the TAC values for VOIs
    for j=1:handles.ROINumOfColor
            handles.VOI(j).tac = [];
			handles.VOI(j).tacstd = [];
			handles.VOI(j).tacmin = [];
			handles.VOI(j).tacmax = [];
			handles.VOI(j).tacvolume = [];
    end
    
% 	DeleteAllROIMenuItem_Callback(handles.mia_figure1, [], handles);
%     current_appdata = getappdata(handles.mia_figure1);
%     handles = current_appdata.UsedByGUIData_m;
    
    % delete the pixvalbar, the image and the  colorbar 
	mia_pixval(handles.ImaHandler,'off');
    if  clear_option == 1;
    % clear_option = 1 corresponds 
    % the "clear" before interpolation
        guidata(handles.mia_figure1, handles); 
        handlesout = handles;
        set(handles.hcb,'buttonDownFcn','mia_gui(''SetImageContrast'',gcbo,[],guidata(gcbo))');
        return; 
    end
	delete(handles.ImaHandler);
	delete(handles.hcb);
	
	% delete the most important fields
	handles = rmfield(handles,'ImaHandler');
    handles = rmfield(handles,'FileNames');
	handles = rmfield(handles,'imaVOL');
	handles = rmfield(handles,'scaninfo');
	handles = rmfield(handles,'hcb');
	if(isfield(handles,'inputpath'));
        handles = rmfield(handles,'inputpath');
	end
	set(handles.CmapAxes,'visible','off');
	set(handles.ImaListbox,'string',{});
end 

% delete the most important fields for the 2.file
if (isfield(handles,'FileNames2'))
	delete(handles.ImaHandler2);
	delete(handles.hcb2);
	handles = rmfield(handles,'ImaHandler2');
	handles = rmfield(handles,'FileNames2');
	handles = rmfield(handles,'imaVOL2');
	handles = rmfield(handles,'scaninfo2');
	handles = rmfield(handles,'hcb2');
	set(handles.Cmap2Axes,'visible','off');
	set(handles.ImaList2box,'string',{});
end 
% "clear" the ImageAxes and input boxes
axes(handles.ImaAxes);
hold off;
image(zeros(256,256,3));
axis off;
set(handles.RenderingLevelEdit,'String',[]);
set(handles.RenderingLevel2Edit,'String',[]);
set(handles.CurrentFrameEdit,'String',[]);
set(handles.CurrentSliceEdit,'String',[]);
% turn off the Frametime and framelength info boxes
set(handles.CurrentFrameLengthEdit,'visible','off');
set(handles.CurrentFrameLengthText,'visible','off');
set(handles.CurrentFrameTimeEdit,'visible','off');
set(handles.CurrentFrameTimeText,'visible','off');
set(handles.FrameSlider,'visible','off');
set(handles.DynFrameMovie,'enable','off');
set(handles.SaveDynFramesAsAvi,'enable','off');
set(handles.SumFrames,'enable','off');
set(handles.SUV_normalization,'checked','off');
set(handles.Normalization,'checked','off');
set(handles.Interpolate,'checked','off');
if  ~(clear_option == 2);
% clear before load a new file
% when clear_option = 2, DICOMDIR infos will not be deleted
    set(handles.OpenDICOMDIRfromCurrent,'enable','off');
    set(handles.Open2DICOMDIRfromCurrent,'enable','off');
end
handles.imaVOLtmpinterp = [];

% turn on the pixval button if it was not on
if ~get(handles.MeasureTogglebutton,'value')
    set(handles.MeasureTogglebutton,'value',1)
% 	if get(handles.ZoomTogglebutton,'value')
%         set(handles.ZoomTogglebutton,'value',0);
%         mia_zoompan('stop');
%         handles.zoom = 0;
%         set(handles.ROIbutton,'enable','on');
% 	end
	if get(handles.ImProfileTogglebutton,'value')
        mia_improfile('stop');
        set(handles.ImProfileTogglebutton,'value',0);
        set(handles.ROIbutton,'enable','on');
        ImageProfileHandler = findobj('name','Image Profile');
        delete(ImageProfileHandler);
    end
    if get(handles.DetailRectangleButton,'value')
        set(handles.DetailRectangleButton,'value',0);
        RectangleHandler = findobj('tag','miarectangle');
        draggable(RectangleHandler,'off');
        pause(2);
        delete(findobj('name','Detail Rectangle'));
		axes(handles.ImaAxes);
		set(handles.ROIbutton,'enable','off');
        delete(RectangleHandler);
    end
end

% disabled the controls for 2nd image file 
miaControlSetup(2,handles);

% set the figure renderer property back to normal if 
% OPENGL was enabled 
if handles.openglinfo.miafigure_useOpenGL;
	set(handles.mia_figure1,'renderer','painter');
    handles.openglinfo.miafigure_useOpenGL = 0;
end


% Update handles structure
guidata(handles.mia_figure1, handles); 
handlesout = handles;

%%  --- Executes on button press in ROIbutton.
function ROIbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ROIbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if not(isfield(handles,'FileNames'));return;end%return if no file was opened 

if ~handles.zoom
    %turns off interactive display of information about image pixels
    mia_pixval(handles.ImaHandler,'off');
end
axes(handles.ImaAxes);
set(handles.hcb,'buttonDownFcn','mia_gui(''SetImageContrast'',gcbo,[],guidata(gcbo))');
if ~isempty(handles.ROI(handles.CurrentSlice,handles.CurrentROIColor).BW )
	handles.ROI(handles.CurrentSlice,handles.CurrentROIColor ).BW = [];
	handles.ROI(handles.CurrentSlice,handles.CurrentROIColor ).xi = [];
	handles.ROI(handles.CurrentSlice,handles.CurrentROIColor ).yi = [];
	delete(handles.Lines(handles.CurrentSlice,handles.CurrentROIColor).lh);
    handles.Lines(handles.CurrentSlice,handles.CurrentROIColor).lh = [];
end
%set(get(handles.ImaAxes,'children'),'EraseMode','normal');
[BW,xi,yi] = roipoly;
handles.ROI(handles.CurrentSlice,handles.CurrentROIColor).BW = 1;
%if isfield(handles,'FileNames2')
%    matsize = handles.scaninfo2.imfm(1);
%else
%    matsize = handles.scaninfo.imfm(1);
%end
matsize1 = double(handles.scaninfo.imfm(1));
matsize2 = double(handles.scaninfo.imfm(2));
% setting the normalized coordinates of ROI 
handles.ROI(handles.CurrentSlice,handles.CurrentROIColor).xi = xi/matsize1;
handles.ROI(handles.CurrentSlice,handles.CurrentROIColor).yi = yi/matsize2;
LineHandler = line(xi,yi,'LineWidth',3,'Color',handles.ROIColorStrings(handles.CurrentROIColor));
handles.Lines(handles.CurrentSlice,handles.CurrentROIColor).lh = LineHandler;
draggable(LineHandler);
% Update handles structure
guidata(hObject, handles);

if ~handles.zoom
    %turns on interactive display of information about image pixels
    %set(get(handles.ImaAxes,'children'),'EraseMode','none');
    mia_pixval(handles.ImaHandler,'on');
end
set(handles.ImaAxes,'selected','on');


%%  --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%%  --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.mia_figure1,'Name') '?'],...
                     ['Close ' get(handles.mia_figure1,'Name') '...'],...
                     'Yes','No','Exit Matlab','Yes');
if strcmp(selection,'No')
    return;
elseif strcmp(selection,'Exit Matlab')
    exit;
end
scrsz = get(0,'ScreenSize');
%figure('Position',[1 scrsz(4)/8 scrsz(3)/8 scrsz(4)/8]);
delete(handles.mia_figure1);

%if hardware opengl processing was turn out at startup
%this should turn back 
if handles.openglinfo.UseGenericOpenGL == 1;
    feature('UseGenericOpenGL',0);
end


%%  --------------------------------------------------------------------
function ROIMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%%  --------------------------------------------------------------------
function DeleteAllROIMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% inititate the ROI parameters
if isfield(handles,'FileNames')
	%set(get(handles.ImaAxes,'children'),'EraseMode','normal');
	for i =1: handles.scaninfo(1).num_of_slice
        for j=1:handles.ROIperSliceMaxNumber
            if ~isempty(handles.ROI(i,j).BW )
				handles.ROI(i,j).BW = [];
				handles.ROI(i,j).xi = [];
				handles.ROI(i,j).yi = [];
				delete(handles.Lines(i,j).lh);
                handles.Lines(i,j).lh = [];
			end
        end
	end
    
    % delete the TAC values for VOIs
    for j=1:handles.ROINumOfColor
            handles.VOI(j).tac = [];
			handles.VOI(j).tacstd = [];
			handles.VOI(j).tacmin = [];
			handles.VOI(j).tacmax = [];
			handles.VOI(j).tacvolume = [];            
    end
   
    
	%set(get(handles.ImaAxes,'children'),'EraseMode','none');
	% Update handles structure
	guidata(handles.mia_figure1, handles);
end

%%  --- Executes on key press over mia_figure1 with no controls selected.
function mia_figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to mia_figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global gVOIpixval;
if isfield(handles,'FileNames')
	current_key = double(get(handles.mia_figure1,'CurrentCharacter'));
	PreviousSlice = handles.CurrentSlice;
	if current_key == 30 %UP arrow was pressed: Slice+
        if handles.CurrentImgIdx < handles.scaninfo.num_of_slice*handles.scaninfo.Frames
            handles.CurrentImgIdx = handles.CurrentImgIdx +1;
        else
            handles.CurrentImgIdx = 1;
        end
	elseif current_key == 31 %DOWN arrow was pressed: Slice-
        if handles.CurrentImgIdx > 1
            handles.CurrentImgIdx = handles.CurrentImgIdx - 1;
        else
            handles.CurrentImgIdx = handles.scaninfo.num_of_slice*handles.scaninfo.Frames;
        end
	elseif current_key == 28 %LEFT arrow was pressed: Frame-
        if handles.CurrentImgIdx > handles.scaninfo.num_of_slice
            handles.CurrentImgIdx = handles.CurrentImgIdx - handles.scaninfo.num_of_slice;
        else
            handles.CurrentImgIdx = handles.scaninfo.num_of_slice*(handles.scaninfo.Frames-1)+handles.CurrentSlice;
        end
	elseif current_key == 29 %RIGHT arrow was pressed: Frame+
        if handles.CurrentImgIdx < handles.scaninfo.num_of_slice*(handles.scaninfo.Frames-1)
            handles.CurrentImgIdx = handles.CurrentImgIdx + handles.scaninfo.num_of_slice;
        else
            handles.CurrentImgIdx = handles.CurrentSlice;
        end
    elseif current_key == 32 %SPACE was pressed: 
       return;
	end
    CurrentImage = handles.imaVOL(:,:,handles.CurrentImgIdx);
    SliderPosMin = get(handles.ColorBarMinSlider,'Value');
    SliderPosMax = get(handles.ColorBarMaxSlider,'Value');
    CurrentImage_RGB = ImageRefresh(CurrentImage,SliderPosMax,SliderPosMin,handles.ColorRes,handles.ColormapIn1);
    set(handles.ImaHandler,'CData',CurrentImage_RGB);
    % set the currentimage for gVOIpixval
    gVOIpixval.CurrentImage = CurrentImage;
    
    if isfield(handles,'FileNames2')
        SliderPosMax = get(handles.ColorBarMax2Slider,'Value');
        SliderPosMin = get(handles.ColorBarMin2Slider,'Value');
        CurrentImage = double(handles.imaVOL2(:,:,handles.CurrentSlice));
        CurrentImage_RGB = ImageRefresh(CurrentImage,SliderPosMax,SliderPosMin,handles.ColorRes,handles.ColormapIn2);
        set(handles.ImaHandler2,'CData',CurrentImage_RGB);    
    end
    
	handles.CurrentSlice = mod(handles.CurrentImgIdx,handles.scaninfo.num_of_slice);
	handles.CurrentFrame = fix(handles.CurrentImgIdx/handles.scaninfo.num_of_slice)+1; 
	if handles.CurrentSlice == 0
        handles.CurrentSlice = handles.scaninfo.num_of_slice;
        handles.CurrentFrame = handles.CurrentFrame -1;
	end
	set(handles.CurrentFrameEdit,'String',handles.CurrentFrame);
	set(handles.CurrentSliceEdit,'String',handles.CurrentSlice);
    set(handles.SliceSlider,'value',handles.CurrentSlice);
    if handles.scaninfo.Frames > 1 % dynamic scan
        set(handles.CurrentFrameTimeEdit,'String', ...
            sprintf('%1.2f',handles.scaninfo.tissue_ts(handles.CurrentFrame)/60));%min
        set(handles.CurrentFrameLengthEdit,'String', ... 
            sprintf('%1.2f',handles.scaninfo.frame_lengths(handles.CurrentFrame)/60));%min
        set(handles.FrameSlider,'value',handles.CurrentFrame);
    end

	%redraw the ROI if exist on the current slide
    for j = 1: handles.ROIperSliceMaxNumber
		if ~isempty(handles.Lines(PreviousSlice,j).lh)
            set(handles.Lines(PreviousSlice,j).lh,'visible','off');    
		end
		if ~isempty(handles.Lines(handles.CurrentSlice,j).lh)
            set(handles.Lines(handles.CurrentSlice,j).lh,'visible','on');    
		end
	end
	
	% Update handles structure
	guidata(hObject, handles);
end

%%  --- Executes during object creation, after setting all properties.
function CurrentFrameEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CurrentFrameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function CurrentFrameEdit_Callback(hObject, eventdata, handles)
% hObject    handle to CurrentFrameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CurrentFrameEdit as text
%        str2double(get(hObject,'String')) returns contents of CurrentFrameEdit as a double
global gVOIpixval;
if isfield(handles,'FileNames')
	if str2double(get(handles.CurrentFrameEdit,'String')) > handles.scaninfo.Frames 
        set(handles.CurrentFrameEdit,'String',handles.CurrentFrame);
        set(handles.ImaAxes,'selected','on');
        return;
	end
	handles.CurrentSlice = str2double(get(handles.CurrentSliceEdit,'String'));
	handles.CurrentFrame = str2double(get(handles.CurrentFrameEdit,'String'));;
	handles.CurrentImgIdx = handles.scaninfo.num_of_slice*(handles.CurrentFrame-1) + handles.CurrentSlice;
	%refresh the image
    SliderPosMax = get(handles.ColorBarMaxSlider,'Value');
    SliderPosMin = get(handles.ColorBarMinSlider,'Value');
    CurrentImage = double(handles.imaVOL(:,:,handles.CurrentImgIdx));
    CurrentImage_RGB = ImageRefresh(CurrentImage,SliderPosMax,SliderPosMin,handles.ColorRes,handles.ColormapIn1);
    set(handles.ImaHandler,'CData',CurrentImage_RGB);
    set(handles.CurrentFrameEdit,'String',handles.CurrentFrame);
	set(handles.CurrentSliceEdit,'String',handles.CurrentSlice);
    if handles.scaninfo.Frames > 1 % dynamic scan
        set(handles.CurrentFrameTimeEdit,'String', ...
            sprintf('%1.2f',handles.scaninfo.tissue_ts(handles.CurrentFrame)/60));%min
        set(handles.CurrentFrameLengthEdit,'String', ... 
            sprintf('%1.2f',handles.scaninfo.frame_lengths(handles.CurrentFrame)/60));%min
    end
    
    % set the currentimage for gVOIpixval
    gVOIpixval.CurrentImage = CurrentImage;
    if isfield(handles,'FileNames2')
        SliderPosMax = get(handles.ColorBarMax2Slider,'Value');
        SliderPosMin = get(handles.ColorBarMin2Slider,'Value');
        CurrentImage = double(handles.imaVOL2(:,:,handles.CurrentSlice));
        CurrentImage_RGB = ImageRefresh(CurrentImage,SliderPosMax,SliderPosMin,handles.ColorRes,handles.ColormapIn2);
        set(handles.ImaHandler2,'CData',CurrentImage_RGB);    
    end
	set(handles.ImaAxes,'selected','on');
    % Update handles structure
    guidata(hObject, handles);
end

%%  --- Executes during object creation, after setting all properties.
function CurrentSliceEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CurrentSliceEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function CurrentSliceEdit_Callback(hObject, eventdata, handles)
% hObject    handle to CurrentSliceEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CurrentSliceEdit as text
%        str2double(get(hObject,'String')) returns contents of CurrentSliceEdit as a double
global gVOIpixval;
if isfield(handles,'FileNames')
	if str2double(get(handles.CurrentSliceEdit,'String')) > handles.scaninfo.num_of_slice 
        set(handles.CurrentSliceEdit,'String',handles.CurrentSlice);
        set(handles.ImaAxes,'selected','on');
        return;
	end
	handles.CurrentSlice = str2double(get(handles.CurrentSliceEdit,'String'));
	handles.CurrentFrame = str2double(get(handles.CurrentFrameEdit,'String'));;
	handles.CurrentImgIdx = handles.scaninfo.num_of_slice*(handles.CurrentFrame-1) + handles.CurrentSlice;
	%refresh the image
    SliderPosMax = get(handles.ColorBarMaxSlider,'Value');
    SliderPosMin = get(handles.ColorBarMinSlider,'Value');
    CurrentImage = double(handles.imaVOL(:,:,handles.CurrentImgIdx));
    CurrentImage_RGB = ImageRefresh(CurrentImage,SliderPosMax,SliderPosMin,handles.ColorRes,handles.ColormapIn1);
    set(handles.ImaHandler,'CData',CurrentImage_RGB);
    % set the currentimage for gVOIpixval
    gVOIpixval.CurrentImage = CurrentImage;
    
    if isfield(handles,'FileNames2')
        SliderPosMax = get(handles.ColorBarMax2Slider,'Value');
        SliderPosMin = get(handles.ColorBarMin2Slider,'Value');
        CurrentImage = double(handles.imaVOL2(:,:,handles.CurrentSlice));
        CurrentImage_RGB = ImageRefresh(CurrentImage,SliderPosMax,SliderPosMin,handles.ColorRes,handles.ColormapIn2);
        set(handles.ImaHandler2,'CData',CurrentImage_RGB);    
    end
	set(handles.ImaAxes,'selected','on');
    set(handles.CurrentFrameEdit,'String',handles.CurrentFrame);
	set(handles.CurrentSliceEdit,'String',handles.CurrentSlice);
    set(handles.SliceSlider,'value',handles.CurrentSlice);
    if handles.scaninfo.Frames > 1 % dynamic scan
        set(handles.CurrentFrameTimeEdit,'String', ...
            sprintf('%1.2f',handles.scaninfo.tissue_ts(handles.CurrentFrame)/60));%min
        set(handles.CurrentFrameLengthEdit,'String', ... 
            sprintf('%1.2f',handles.scaninfo.frame_lengths(handles.CurrentFrame)/60));%min
        set(handles.FrameSlider,'value',handles.CurrentFrame);
    end
    
    % Update handles structure
    guidata(hObject, handles);
end

function StepImage(event, handles)
% event - where and what should be step
% handles  -  structure with handles and user data (see GUIDATA)

global gVOIpixval;
PreviousSlice = handles.CurrentSlice;
if strcmp(event,'NextSlice') %  slice+
	if handles.CurrentImgIdx < handles.scaninfo.num_of_slice*handles.scaninfo.Frames
        handles.CurrentImgIdx = handles.CurrentImgIdx +1;
	else
        handles.CurrentImgIdx = 1;
	end
elseif strcmp(event,'PreviousSlice') % Slice-
    if handles.CurrentImgIdx > 1
        handles.CurrentImgIdx = handles.CurrentImgIdx - 1;
    else
        handles.CurrentImgIdx = handles.scaninfo.num_of_slice*handles.scaninfo.Frames;
    end
elseif strcmp(event,'PreviousFrame') %  Frame-
    if handles.CurrentImgIdx > handles.scaninfo.num_of_slice
        handles.CurrentImgIdx = handles.CurrentImgIdx - handles.scaninfo.num_of_slice;
    else
        handles.CurrentImgIdx = handles.scaninfo.num_of_slice*(handles.scaninfo.Frames-1)+handles.CurrentSlice;
    end
elseif strcmp(event,'NextFrame')% Frame+
    if handles.CurrentImgIdx < handles.scaninfo.num_of_slice*(handles.scaninfo.Frames-1)
        handles.CurrentImgIdx = handles.CurrentImgIdx + handles.scaninfo.num_of_slice;
    else
        handles.CurrentImgIdx = handles.CurrentSlice;
    end
end
CurrentImage = handles.imaVOL(:,:,handles.CurrentImgIdx);
SliderPosMin = get(handles.ColorBarMinSlider,'Value');
SliderPosMax = get(handles.ColorBarMaxSlider,'Value');
CurrentImage_RGB = ImageRefresh(CurrentImage,SliderPosMax,SliderPosMin,handles.ColorRes,handles.ColormapIn1);
set(handles.ImaHandler,'CData',CurrentImage_RGB);
% set the currentimage for gVOIpixval
gVOIpixval.CurrentImage = CurrentImage;

if isfield(handles,'FileNames2')
    SliderPosMax = get(handles.ColorBarMax2Slider,'Value');
    SliderPosMin = get(handles.ColorBarMin2Slider,'Value');
    CurrentImage = double(handles.imaVOL2(:,:,handles.CurrentSlice));
    CurrentImage_RGB = ImageRefresh(CurrentImage,SliderPosMax,SliderPosMin,handles.ColorRes,handles.ColormapIn2);
    set(handles.ImaHandler2,'CData',CurrentImage_RGB);    
end

handles.CurrentSlice = mod(handles.CurrentImgIdx,handles.scaninfo.num_of_slice);
handles.CurrentFrame = fix(handles.CurrentImgIdx/handles.scaninfo.num_of_slice)+1; 
if handles.CurrentSlice == 0
    handles.CurrentSlice = handles.scaninfo.num_of_slice;
    handles.CurrentFrame = handles.CurrentFrame -1;
end
set(handles.CurrentFrameEdit,'String',handles.CurrentFrame);
set(handles.CurrentSliceEdit,'String',handles.CurrentSlice);
set(handles.SliceSlider,'value',handles.CurrentSlice);
if handles.scaninfo.Frames > 1 % dynamic scan
    set(handles.CurrentFrameTimeEdit,'String', ...
        sprintf('%1.2f',handles.scaninfo.tissue_ts(handles.CurrentFrame)/60));%min
    set(handles.CurrentFrameLengthEdit,'String', ... 
        sprintf('%1.2f',handles.scaninfo.frame_lengths(handles.CurrentFrame)/60));%min
    set(handles.FrameSlider,'value',handles.CurrentFrame);
end

%redraw the ROI if exist on the current slide
for j = 1: handles.ROIperSliceMaxNumber
	if ~isempty(handles.Lines(PreviousSlice,j).lh)
        set(handles.Lines(PreviousSlice,j).lh,'visible','off');    
	end
	if ~isempty(handles.Lines(handles.CurrentSlice,j).lh)
        set(handles.Lines(handles.CurrentSlice,j).lh,'visible','on');    
	end
end
	
% Update handles structure
guidata(handles.mia_figure1, handles); 


%%  --- Executes during object creation, after setting all properties.
function SliceSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SliceSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


%%  --- Executes on slider movement.
function SliceSlider_Callback(hObject, eventdata, handles)
% hObject    handle to SliceSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global gVOIpixval;
if isfield(handles,'FileNames')
    PreviousSlice = handles.CurrentSlice;
	handles.CurrentSlice = round(get(handles.SliceSlider,'Value'));
    set(handles.CurrentSliceEdit,'String',num2str(handles.CurrentSlice));
	handles.CurrentFrame = str2double(get(handles.CurrentFrameEdit,'String'));
	handles.CurrentImgIdx = handles.scaninfo.num_of_slice*(handles.CurrentFrame-1) + handles.CurrentSlice;
	%refresh the image
    SliderPosMax = get(handles.ColorBarMaxSlider,'Value');
    SliderPosMin = get(handles.ColorBarMinSlider,'Value');
    CurrentImage = double(handles.imaVOL(:,:,handles.CurrentImgIdx));
    CurrentImage_RGB = ImageRefresh(CurrentImage,SliderPosMax,SliderPosMin,handles.ColorRes,handles.ColormapIn1);
    set(handles.ImaHandler,'CData',CurrentImage_RGB);
    % set the currentimage for gVOIpixval
    gVOIpixval.CurrentImage = CurrentImage;
    
    if isfield(handles,'FileNames2')
        SliderPosMax = get(handles.ColorBarMax2Slider,'Value');
        SliderPosMin = get(handles.ColorBarMin2Slider,'Value');
        CurrentImage = double(handles.imaVOL2(:,:,handles.CurrentSlice));
        CurrentImage_RGB = ImageRefresh(CurrentImage,SliderPosMax,SliderPosMin,handles.ColorRes,handles.ColormapIn2);
        set(handles.ImaHandler2,'CData',CurrentImage_RGB);    
    end
	set(handles.ImaAxes,'selected','on');
    set(handles.CurrentFrameEdit,'String',handles.CurrentFrame);
	set(handles.CurrentSliceEdit,'String',handles.CurrentSlice);
    if handles.scaninfo.Frames > 1 % dynamic scan
        set(handles.CurrentFrameTimeEdit,'String', ...
            sprintf('%1.2f',handles.scaninfo.tissue_ts(handles.CurrentFrame)/60));%min
        set(handles.CurrentFrameLengthEdit,'String', ... 
            sprintf('%1.2f',handles.scaninfo.frame_lengths(handles.CurrentFrame)/60));%min
        set(handles.FrameSlider,'value',handles.CurrentFrame);
    end
    
    %redraw the ROI if exist on the current slide
    for j = 1: handles.ROIperSliceMaxNumber
		if ~isempty(handles.Lines(PreviousSlice,j).lh)
            set(handles.Lines(PreviousSlice,j).lh,'visible','off');    
		end
		if ~isempty(handles.Lines(handles.CurrentSlice,j).lh)
            set(handles.Lines(handles.CurrentSlice,j).lh,'visible','on');    
		end
	end
    
    % Update handles structure
    guidata(hObject, handles);
end


%%  --- Executes during object creation, after setting all properties.
function FrameSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrameSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


%%  --- Executes on slider movement.
function FrameSlider_Callback(hObject, eventdata, handles)
% hObject    handle to FrameSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global gVOIpixval;
if isfield(handles,'FileNames')
    PreviousSlice = handles.CurrentSlice;
	handles.CurrentSlice = str2double(get(handles.CurrentSliceEdit,'String'));
	handles.CurrentFrame = round(get(hObject,'Value'));;
    set(handles.CurrentFrameEdit,'String',num2str(handles.CurrentFrame));
	handles.CurrentImgIdx = handles.scaninfo.num_of_slice*(handles.CurrentFrame-1) + handles.CurrentSlice;
	%refresh the image
    SliderPosMax = get(handles.ColorBarMaxSlider,'Value');
    SliderPosMin = get(handles.ColorBarMinSlider,'Value');
    CurrentImage = double(handles.imaVOL(:,:,handles.CurrentImgIdx));
    CurrentImage_RGB = ImageRefresh(CurrentImage,SliderPosMax,SliderPosMin,handles.ColorRes,handles.ColormapIn1);
    set(handles.ImaHandler,'CData',CurrentImage_RGB);
    % set the currentimage for gVOIpixval
    gVOIpixval.CurrentImage = CurrentImage;
    if isfield(handles,'FileNames2')
        SliderPosMax = get(handles.ColorBarMax2Slider,'Value');
        SliderPosMin = get(handles.ColorBarMin2Slider,'Value');
        CurrentImage = double(handles.imaVOL2(:,:,handles.CurrentSlice));
        CurrentImage_RGB = ImageRefresh(CurrentImage,SliderPosMax,SliderPosMin,handles.ColorRes,handles.ColormapIn2);
        set(handles.ImaHandler2,'CData',CurrentImage_RGB);    
    end
	set(handles.ImaAxes,'selected','on');
    set(handles.CurrentFrameEdit,'String',handles.CurrentFrame);
	set(handles.CurrentSliceEdit,'String',handles.CurrentSlice);
    if handles.scaninfo.Frames > 1 % dynamic scan
        set(handles.CurrentFrameTimeEdit,'String', ...
            sprintf('%1.2f',handles.scaninfo.tissue_ts(handles.CurrentFrame)/60));%min
        set(handles.CurrentFrameLengthEdit,'String', ... 
            sprintf('%1.2f',handles.scaninfo.frame_lengths(handles.CurrentFrame)/60));%min
    end
    
     %redraw the ROI if exist on the current slide
    for j = 1: handles.ROIperSliceMaxNumber
		if ~isempty(handles.Lines(PreviousSlice,j).lh)
            set(handles.Lines(PreviousSlice,j).lh,'visible','off');    
		end
		if ~isempty(handles.Lines(handles.CurrentSlice,j).lh)
            set(handles.Lines(handles.CurrentSlice,j).lh,'visible','on');    
		end
	end
    % Update handles structure
    guidata(hObject, handles);
end


%%  --- Executes on button press in VOITACbutton.
function VOITACbutton_Callback(hObject, eventdata, handles)
% hObject    handle to VOITACbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if not(isfield(handles,'FileNames'));return;end % 1st file should be opened first

% if ROIs no exist then return
ROINotExist = 1;
for j=1:handles.ROINumOfColor
    for i = 1 : handles.scaninfo(1).num_of_slice
        if ~isempty(handles.ROI(i,j).BW )
			ROINotExist = 0;
            break;
		end
    end
end
if ROINotExist;return;end 

%roi.area(:,roiIndex) = polyarea(xi,yi);
%roi.center(:,roiIndex) = [mean(Xin(:)), mean(Yin(:))];

if isempty(handles.scaninfo(1).tissue_ts);
   tac_timescale = 1;
else
   tac_timescale = handles.scaninfo(1).tissue_ts;
end
px_num = [];
matsize1 = handles.scaninfo.imfm(1);matsize2 = handles.scaninfo.imfm(2);
tacmaxs = zeros(1,handles.ROINumOfColor);
tacmins = zeros(1,handles.ROINumOfColor);
handles.VOI(handles.ROINumOfColor).tac = [];
handles.VOI(handles.ROINumOfColor).tacstd = [];
handles.VOI(handles.ROINumOfColor).tacmin = [];
handles.VOI(handles.ROINumOfColor).tacmax = [];
handles.VOI(handles.ROINumOfColor).tacvolume = [];

for k=1:handles.ROINumOfColor
    VOItissue_as = []; VOItissue_std = [];px_num = [];
    temp_as = zeros(handles.scaninfo(1).Frames,handles.scaninfo(1).num_of_slice);
    temp_std = zeros(handles.scaninfo(1).Frames,handles.scaninfo(1).num_of_slice);
	for i=1:handles.scaninfo(1).num_of_slice
        if ~isempty(handles.ROI(i,k).BW )
			roimask = poly2mask(handles.ROI(i,k).xi*double(matsize1), ...
                handles.ROI(i,k).yi*double(matsize2),double(matsize1),double(matsize2));
			px = find(roimask); px_num(i) = length(px);
			for j =1 : handles.scaninfo(1).Frames
                imgt = handles.imaVOL(:,:,(j-1)*handles.scaninfo(1).num_of_slice + i);
				imgt_masked=imgt(px);
				temp_as(j,i) = mean(imgt_masked)*px_num(i);
                temp_std(j,i) = std(double(imgt_masked))*px_num(i);
            end
        end
	end
	if not(isempty(px_num))
		if size(temp_as,2) ~= 1
			VOItissue_as = sum(temp_as')'/sum(px_num);
            VOItissue_std = sum(temp_std')'/sum(px_num);
		else
			VOItissue_as = temp_as/sum(px_num);
            VOItissue_std = temp_std/sum(px_num);
		end
        tacmaxs(k) = max(VOItissue_as); tacmins(k) = min(VOItissue_as); 
	    handles.VOI(k).tac  = VOItissue_as';
        handles.VOI(k).tacstd  = VOItissue_std';
        handles.VOI(k).tacmin  = tacmins(k);
        handles.VOI(k).tacmax  = tacmaxs(k);
        if length(handles.scaninfo.pixsize) == 3
            handles.VOI(k).tacvolume = sum(px_num)*handles.scaninfo.pixsize(1)* ...
                handles.scaninfo.pixsize(2)*handles.scaninfo.pixsize(3);
        elseif length(handles.scaninfo.pixsize) == 2
            handles.VOI(k).tacvolume = sum(px_num)*handles.scaninfo.pixsize(1)* ...
                handles.scaninfo.pixsize(2);
        end
    end
end
tacmax = max(tacmaxs); tacmin = max(tacmins);
if tacmin > 0; tacmin = 0;end

% Update handles structure
guidata(hObject, handles);


tac_fh = figure('NumberTitle','off','name','ROI(VOI) curves');
if length(tac_timescale) == 1 
    axis([0 2 tacmin round(1.2*tacmax) ]);
    set(get(tac_fh,'children'),'Xtick',[0 1]);
    title(['ROI means. ','patientID = ',num2str(handles.scaninfo(1).brn)]);
else
    axis([0 max(tac_timescale) tacmin (1.2*tacmax) ]);
    xlabel('Time [sec]');
    title(['VOI curves  ','patientID= ',num2str(handles.scaninfo(1).brn)]);
end
%ylabel('Activity concentration [nCi/ml]');
ylabel('Pixel unit');
hold on;
for j = 1 :handles.ROINumOfColor
    if not(isempty(handles.VOI(j).tac))
        labelcolor = [handles.ROIColorStrings(j),'*'];
        linecolor = [handles.ROIColorStrings(j),'-'];
		plot(tac_timescale,handles.VOI(j).tac,labelcolor);
		plot(tac_timescale,handles.VOI(j).tac,linecolor);
    end
end
hold off;
set(handles.ImaAxes,'selected','on');

%%  --- Executes on button press in ROIstatbutton.
function ROIstatbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ROIstatbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if not(isfield(handles,'FileNames'));return;end % 1st file should be opened first

% if ROIs no exist then return
ROINotExist = 1;
for j=1:handles.ROINumOfColor
    for i = 1 : handles.scaninfo(1).num_of_slice
        if ~isempty(handles.ROI(i,j).BW )
			ROINotExist = 0;
            break;
		end
    end
end
if ROINotExist;return;end 

%[roifilename, pathname] = uiputfile('*.txt', 'Please select an output
rfid = fopen([tempdir,'ROIstatTmp.txt'], 'w+');
fprintf(rfid, '%-20s\t %-25s\n', 'CurrentDate = ', datestr(now));
fprintf(rfid, '\n');        
fprintf(rfid, 'Image file used for ROI statistics: \n');
fprintf(rfid, '\t"%s"\n', [handles.dirname,char(handles.FileNames(1))]);
fprintf(rfid, '\n');

roi_mean = zeros(handles.ROINumOfColor,handles.scaninfo(1).num_of_slice);
roi_std = zeros(handles.ROINumOfColor,handles.scaninfo(1).num_of_slice);
roi_min = zeros(handles.ROINumOfColor,handles.scaninfo(1).num_of_slice);
roi_max = zeros(handles.ROINumOfColor,handles.scaninfo(1).num_of_slice);
roi_pixnum = zeros(handles.ROINumOfColor,handles.scaninfo(1).num_of_slice);
roi_area = zeros(handles.ROINumOfColor,handles.scaninfo(1).num_of_slice);
px_num = [];
matsize1 = handles.scaninfo.imfm(1);matsize2 = handles.scaninfo.imfm(2);

for i=1:handles.scaninfo(1).num_of_slice
    imgt = handles.imaVOL(:,:,(handles.CurrentFrame-1)*handles.scaninfo(1).num_of_slice+i);
    fprintf(rfid, 'ROI statistic data for slice "%s" . : \n\n', num2str(i));
    for k=1:handles.ROINumOfColor
        if ~isempty(handles.ROI(i,k).BW )
			roimask = poly2mask(handles.ROI(i,k).xi*double(matsize1),...
                handles.ROI(i,k).yi*double(matsize2),double(matsize1),double(matsize2));
			px = find(roimask); px_num = length(px);
			imgt_masked=imgt(px);
			roi_mean(k,i) = mean(imgt_masked);
            roi_std(k,i) = std(double(imgt_masked));
            roi_min(k,i) = min(imgt_masked);
            roi_max(k,i) = max(imgt_masked);
            roi_pixnum(k,i) = px_num;
            roi_area(k,i) = sum(px_num)*handles.scaninfo.pixsize(1)* ...
                handles.scaninfo.pixsize(2);
            % print the current ROI stat. values
            fprintf(rfid, '\t');
            fprintf(rfid, 'Data for "%s" ROI: \n', char(handles.ROIColorStringsLong(k)));
            
            fprintf(rfid, '%20s\t', 'Mean = ');
            fprintf(rfid, '%10.2f\t', roi_mean(k,i));
            fprintf(rfid, '\n');
            
            fprintf(rfid, '%20s\t', 'Stdev = ');
            fprintf(rfid, '%10.2f\t', roi_std(k,i));
            fprintf(rfid, '\n');
            
            fprintf(rfid, '%20s\t', 'Min = ');
            fprintf(rfid, '%10.2f\t', roi_min(k,i));
            fprintf(rfid, '\n');
            
            fprintf(rfid, '%20s\t', 'Max = ');
            fprintf(rfid, '%10.2f\t', roi_max(k,i));
            fprintf(rfid, '\n');
            
            fprintf(rfid, '%20s\t', 'NumberOfPixel = ');
            fprintf(rfid, '%10d\t', roi_pixnum(k,i));
            fprintf(rfid, '\n');
            
            fprintf(rfid, '%20s\t', 'Area = ');
            fprintf(rfid, '%10.2f\t', roi_area(k,i));
            fprintf(rfid, '\n\n');    
        end
	end
end
fclose(rfid);
roifile = textread([tempdir,'ROIstatTmp.txt'],'%s','delimiter','\n','whitespace','');
if isempty(findobj('name','MIA ROI statistics'))
    roistatfh = figure('menubar','none','NumberTitle','off','name','MIA ROI statistics');
    lbh = uicontrol('Style','listbox','Position',[10 10 520 400],'tag','MIAROIstatlis');
    set(lbh,'string',roifile);
else
    roistatfh = findobj('name','MIA ROI statistics');
    figure(roistatfh);
    lbh = findobj('tag','MIAROIstatlis');
    set(lbh,'string',roifile);
end


% if isempty(javachk('desktop'))
%     open([handles.dirname,'ROIstatTmp.txt']);
% else
%     roicells = textread([handles.dirname,'ROIstatTmp.txt'],'%s','delimiter','\n','whitespace','');
%     type([handles.dirname,'ROIstatTmp.txt']);
% end

%%  --- Executes on button press in DelCurrentROIbutton.
function DelCurrentROIbutton_Callback(hObject, eventdata, handles)
% hObject    handle to DelCurrentROIbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if not(isfield(handles,'FileNames'));return;end
%set(get(handles.ImaAxes,'children'),'EraseMode','normal');
i = handles.CurrentSlice;
for j=1:handles.ROINumOfColor
    if j == handles.CurrentROIColor
        if ~isempty(handles.ROI(i,j).BW )
			handles.ROI(i,j).BW = [];
			handles.ROI(i,j).xi = [];
			handles.ROI(i,j).yi = [];
			delete(handles.Lines(i,j).lh);
            handles.Lines(i,j).lh = [];
		end
    end
end

% find out what VOI no exist and delete the corresponding TAC values
for j=1:handles.ROINumOfColor
    VOINoExist = 1;
    for i = 1 : handles.scaninfo(1).num_of_slice
        if ~isempty(handles.ROI(i,j).BW )
			VOINoExist = 0;
            break;
		end
    end
    if VOINoExist
        handles.VOI(j).tac = [];
		handles.VOI(j).tacstd = [];
		handles.VOI(j).tacmin = [];
		handles.VOI(j).tacmax = [];
		handles.VOI(j).tacvolume = [];            
    end
end
                
%set(get(handles.ImaAxes,'children'),'EraseMode','none');
% Update handles structure
guidata(hObject, handles);
set(handles.ImaAxes,'selected','on');



%%  --- Executes on button press in DelAllROIbutton.
function DelAllROIbutton_Callback(hObject, eventdata, handles)
% hObject    handle to DelAllROIbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'FileNames')
	%set(get(handles.ImaAxes,'children'),'EraseMode','normal');
	for i =1: handles.scaninfo(1).num_of_slice
        for j=1:handles.ROINumOfColor
            if ~isempty(handles.ROI(i,j).BW )
				handles.ROI(i,j).BW = [];
				handles.ROI(i,j).xi = [];
				handles.ROI(i,j).yi = [];
				delete(handles.Lines(i,j).lh);
                handles.Lines(i,j).lh = [];
			end
        end
	end
    
    % delete the TAC values for VOIs
    for j=1:handles.ROINumOfColor
            handles.VOI(j).tac = [];
			handles.VOI(j).tacstd = [];
			handles.VOI(j).tacmin = [];
			handles.VOI(j).tacmax = [];
			handles.VOI(j).tacvolume = [];            
    end
    
	%set(get(handles.ImaAxes,'children'),'EraseMode','none');
	% Update handles structure
	guidata(hObject, handles);
	set(handles.ImaAxes,'selected','on');
end
%%  --------------------------------------------------------------------
function DelCurrentROIMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to DelCurrentROIMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'FileNames')
	%set(get(handles.ImaAxes,'children'),'EraseMode','normal');
	i = handles.CurrentSlice;
	for j=1:handles.ROINumOfColor
        if j == handles.CurrentROIColor
            if ~isempty(handles.ROI(i,j).BW )
				handles.ROI(i,j).BW = [];
				handles.ROI(i,j).xi = [];
				handles.ROI(i,j).yi = [];
				delete(handles.Lines(i,j).lh);
                handles.Lines(i,j).lh = [];
			end
        end
    end
    
    % find out what VOI no exist and delete the corresponding TAC values
    for j=1:handles.ROINumOfColor
        VOINoExist = 1;
        for i = 1 : handles.scaninfo(1).num_of_slice
            if ~isempty(handles.ROI(i,j).BW )
				VOINoExist = 0;
                break;
			end
        end
        if VOINoExist
            handles.VOI(j).tac = [];
			handles.VOI(j).tacstd = [];
			handles.VOI(j).tacmin = [];
			handles.VOI(j).tacmax = [];
			handles.VOI(j).tacvolume = [];            
        end
    end
    
	%set(get(handles.ImaAxes,'children'),'EraseMode','none');
	% Update handles structure
	guidata(hObject, handles);
end

%%  --------------------------------------------------------------------
function SaveROIMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to SaveROIMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'FileNames')
	for i =1: handles.scaninfo(1).num_of_slice
        for j=1:handles.ROINumOfColor
            if ~isempty(handles.ROI(i,j).BW )
                curdir = pwd;
                cd(handles.dirname);
                [roifilename, pathname] = uiputfile('*ROI.mat', 'Save ROIs as');
                if isequal(roifilename,0) | isequal(pathname,0)
                    return;
                end
                cd(curdir);
			    ROIstructOut = handles.ROI;
                [pathstr,filemainname,ext,vers] = fileparts(roifilename);
			    save([pathname,filemainname,'.mat'],'ROIstructOut');
                return;
            end
        end
	end
end	
%%  --------------------------------------------------------------------
function LoadROIMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to LoadROIMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'FileNames')
    curdir = pwd;
    cd(handles.dirname);
	[roifilename, pathname] = uigetfile('*ROI.mat', 'Load ROI file');
    if isequal(roifilename,0) | isequal(pathname,0)
        return;
    end
    cd(curdir);
	tmpstruct = load([pathname,roifilename]);
	handles.ROI = tmpstruct.ROIstructOut;
    if size(handles.ROI,1) ~= handles.scaninfo(1).num_of_slice
        msgbox('The number of slices in the saved ROI file is not fit to the current!','MIA warning','warn'); 
        return;
    end
    if isfield(handles,'FileNames2')
        matsize1 = double(handles.scaninfo2.imfm(1));
        matsize2 = double(handles.scaninfo2.imfm(2));
    else
        matsize1 = double(handles.scaninfo.imfm(1));
        matsize2 = double(handles.scaninfo.imfm(2));
    end
	for i =1: handles.scaninfo(1).num_of_slice
        for j=1:handles.ROINumOfColor
            if ~isempty(handles.ROI(i,j).BW )
                xi = handles.ROI(i,j).xi*matsize1; 
                yi = handles.ROI(i,j).yi*matsize2;
                if j < 50
    				LineHandler = line(xi,yi,'LineWidth',3,'Color',handles.ROIColorStrings(j));
                else
                    LineHandler = line(xi,yi,'LineWidth',2,'Color',handles.ROIColorStrings(j));
                end
				handles.Lines(i,j).lh = LineHandler;
                if i ~= handles.CurrentSlice
                    set(handles.Lines(i,j).lh,'visible','off');
                end
            end
        end
	end
end
% Update handles structure
guidata(hObject, handles);	    


%%  --------------------------------------------------------------------
function SaveTACMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'FileNames');return;end

% if ROIs no exist then return
ROINotExist = 1;
for j=1:handles.ROINumOfColor
    for i = 1 : handles.scaninfo(1).num_of_slice
        if ~isempty(handles.ROI(i,j).BW )
			ROINotExist = 0;
            break;
		end
    end
end
if ROINotExist;return;end 

% if VOIs no exist then return
VOINotExist = 1;
for j=1:handles.ROINumOfColor
    if ~isempty(handles.VOI(j).tac)
		VOINotExist = 0;
        break;
	end
end
if VOINotExist
    msgbox('First press the VOI TAC button to calculate the VOI parameters','mia info','warn'); 
    return;
end

if ~isempty(handles.scaninfo(1).tissue_ts')
    TACOut = [handles.scaninfo(1).tissue_ts'];
    zeroTAC = zeros(size(TACOut));
    StdOut = zeros(size(TACOut));
    VolOut = zeros(size(TACOut));
else
    TACOut = 0;
    zeroTAC = 0;
    zeroStd = 0;
    zeroVol = 0;
    VolOut = 0;
    StdOut = 0;
end


handles.VOI(handles.ROINumOfColor).tac = [];
handles.VOI(handles.ROINumOfColor).tacstd = [];
handles.VOI(handles.ROINumOfColor).tacmin = [];
handles.VOI(handles.ROINumOfColor).tacmax = [];
handles.VOI(handles.ROINumOfColor).tacvolume = [];


for j = 1 :handles.ROINumOfColor
	if not(isempty(handles.VOI(j).tac))
        TACOut = [TACOut, handles.VOI(j).tac'];
        StdOut = [StdOut, handles.VOI(j).tacstd'];
        VolOut = [VolOut, handles.VOI(j).tacvolume'];
    else
        TACOut = [TACOut, zeroTAC];
        StdOut = [StdOut, zeroStd];
        VolOut = [VolOut, zeroVol];
	end
end
TACOut = [TACOut;StdOut;VolOut];

curdir = pwd;
cd(handles.dirname);
[TACfilename, pathname] = uiputfile('*.xls', 'Save TAC as xls file');
if isequal(TACfilename,0) | isequal(pathname,0)
   return;
end

[pathstr,filemainname,ext,vers] = fileparts(TACfilename);
xlsheader = ['The image file used for TAC generation: ',handles.dirname,char(handles.FileNames(1))];
xlscolnames = {'Time [sec] ','yellow  VOI','magenta VOI','cyan    VOI','red     VOI', ...
        'green   VOI','blue    VOI','white   VOI','black   VOI'};
if ispc
    xlswrite_mod(TACOut,xlsheader,xlscolnames',[filemainname,'.xls']);
else
    OutCell = cell(size(TACOut,1)+2,size(TACOut,2));
    OutCell{1,1} =  strrep(xlsheader,'\','\\');
    for j=1:size(xlscolnames,2); OutCell{2,j} =  xlscolnames{j}; end
    OutCell(3:end,:) = num2cell(TACOut);
    cell2csv([filemainname,'.txt'],OutCell);
end
cd(curdir);
%wk1write([pathname,TACfilename],TACOut);

%%  --------------------------------------------------------------------
function SaveROIStatMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to SaveROIStatMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if not(isfield(handles,'FileNames'));return;end % 1st file should be opened first

% if ROIs no exist then return
ROINotExist = 1;
for j=1:handles.ROINumOfColor
    for i = 1 : handles.scaninfo(1).num_of_slice
        if ~isempty(handles.ROI(i,j).BW )
			ROINotExist = 0;
            break;
		end
    end
end
if ROINotExist;return;end 

%[roifilename, pathname] = uiputfile('*.txt', 'Please select an output
ROIstatOut = zeros(handles.scaninfo(1).num_of_slice,1 + handles.ROINumOfColor*6);
px_num = [];
matsize1 = double(handles.scaninfo.imfm(1)); matsize2 = double(handles.scaninfo.imfm(2));
NumOfStatPar = 6;

for i=1:handles.scaninfo(1).num_of_slice
    imgt = handles.imaVOL(:,:,(handles.CurrentFrame-1)*handles.scaninfo(1).num_of_slice+i);
    ROIstatOut(i,1) = i;
    for k=1:handles.ROINumOfColor
        if ~isempty(handles.ROI(i,k).BW )
			roimask = poly2mask(handles.ROI(i,k).xi*matsize1,handles.ROI(i,k).yi*matsize2,matsize1,matsize2);
			px = find(roimask); px_num = length(px);
			imgt_masked=imgt(px);
			roi_mean = mean(imgt_masked);
            roi_std = std(double(imgt_masked));
            roi_min = min(imgt_masked);
            roi_max = max(imgt_masked);
            roi_pixnum = px_num;
            roi_area = sum(px_num)*handles.scaninfo.pixsize(1)* ...
                handles.scaninfo.pixsize(2);
            ROIstatOut(i,NumOfStatPar*(k-1)+2 :NumOfStatPar*(k-1)+7) = ...
                [roi_mean roi_std roi_min roi_max roi_pixnum roi_area];
        end
	end
end
curdir = pwd;
cd(handles.dirname);
[ROIstatfilename, pathname] = uiputfile('*.xls', 'Save ROI stat. as xls file');
if isequal(ROIstatfilename,0) | isequal(pathname,0)
   return;
end
[pathstr,filemainname,ext,vers] = fileparts(ROIstatfilename);
xlsheader = ['The image file used for ROI calculations: ',handles.dirname,char(handles.FileNames(1))];
xlscolnames = {'Slice         ', ...
'yellow    mean','yellow   stdev','yellow     min','yellow     max','yellow  pixnum','yellow    area', ...
'magenta   mean','magenta  stdev','magenta    min','magenta    max','magenta pixnum','magenta   area', ...
'cyan      mean','cyan     stdev','cyan       min','cyan       max','cyan    pixnum','cyan      area', ...
'red       mean','red      stdev','red        min','red        max','red     pixnum','red       area', ...
'green     mean','green    stdev','green      min','green      max','green   pixnum','green     area', ...
'blue      mean','blue     stdev','blue       min','blue       max','blue    pixnum','blue      area', ...
'white     mean','white    stdev','white      min','white      max','white   pixnum','white     area', ...
'black     mean','black    stdev','black      min','black      max','black   pixnum','black     area', ...    
 };
if ispc 
    xlswrite_mod(ROIstatOut,xlsheader,xlscolnames',[filemainname,'.xls']);
else
    OutCell = cell(size(ROIstatOut,1)+2,size(ROIstatOut,2));
    OutCell{1,1} =  strrep(xlsheader,'\','\\');
    for j=1:size(xlscolnames,2); OutCell{2,j} =  xlscolnames{j}; end
    OutCell(3:end,:) = num2cell(ROIstatOut);
    cell2csv([filemainname,'.txt'],OutCell);
end
cd(curdir);


%%  --- Executes during object creation, after setting all properties.
function ImaListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImaListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


%%  --- Executes on selection change in ImaListbox.
function ImaListbox_Callback(hObject, eventdata, handles)
% hObject    handle to ImaListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ImaListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ImaListbox

if not(isfield(handles,'FileNames'));return;end%return if no file was opened 
set(handles.ImaAxes,'selected','on');

%set(get(handles.ImaAxes,'parent'),'Interruptible','on');
%set(get(handles.ImaAxes,'parent'),'DoubleBuffer','off');
%get(get(handles.ImaAxes,'parent'));


%%  --- Executes during object creation, after setting all properties.
function ImaList2box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imaList2box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


%%  --- Executes on selection change in imaList2box.
function ImaList2box_Callback(hObject, eventdata, handles)
% hObject    handle to imaList2box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns imaList2box contents as cell array
%        contents{get(hObject,'Value')} returns selected item from imaList2box
if not(isfield(handles,'FileNames'));return;end %return if no file was opened 

%get(handles.mia_figure1)
set(handles.ImaAxes,'selected','on');

% commands for test purpuses 
% global miah
% miah.mfh = handles.mia_figure1;
% miah.ImaAxes = handles.ImaAxes;
% miah.ImaHandler = handles.ImaHandler;
% miah.ImaHandler2 = handles.ImaHandler2;

function SetImageContrast(hObject, eventdata, handles)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

%check the mouse click type: only double click can initiate the imcontrast tool  

matlab_verstruct = ver('MATLAB');
matlab_vermain = str2num(matlab_verstruct.Version(1));

mouseclick = get(handles.mia_figure1,'SelectionType');
if ~strcmp(mouseclick,'open') &  ~strcmp(mouseclick,'alt')
    return;
end

if (matlab_vermain < 7) | ( matlab_vermain >= 7 & strcmp(mouseclick,'alt'))
    prompt = {'Pixel min:','Pixel max:'};
	dlg_title = ['Input for color mapping'];
	num_lines= 1;
	%num_lines= [1,42;1,42;1,42;];
	def     = { num2str(get(handles.ColorBarMinSlider, 'Value')), ...
            num2str(get(handles.ColorBarMaxSlider, 'Value'))};
	PixInStr = inputdlg(prompt,dlg_title,num_lines,def);
	
	if isempty(PixInStr)
        return;%return if the cancel button was pressed 
	else
        NewClim = str2double(PixInStr);
    end
elseif matlab_vermain >= 7 & strcmp(mouseclick,'open')
    %if matlab_vermain >= 7 than start the imcontrast GUI tool
    %turn off the mia_pixval func. because it does work well with the
    % imcontrast function
    mia_pixval(handles.ImaHandler,'off');


    %get the current values
    CurrentImage = handles.imaVOL(:,:,handles.CurrentImgIdx);
    CurrentCdata = get(handles.ImaHandler,'cdata');

    % change the image type from RGB to intensity: imcontrast function
    % works only on intensity type image

    set(handles.ImaHandler,'cdata',CurrentImage);
    set(handles.ImaHandler,'CDataMapping','scaled');
    %set(handles.hcb,'buttonDownFcn','mia_gui(''SetImageContrast'',gcbo,[],guidata(gcbo))');
    cmapcontents = get(handles.ColorMapPopupmenu,'String');
    cmapname = cmapcontents{get(handles.ColorMapPopupmenu,'Value')};
    map=colormap(cmapname);

    % delete some variables which stop to work the imcontrast function
    % It is far to clear why these are important!!
    is_imcontrastFig_Exist = getappdata(handles.ImaAxes,'imcontrastFig');
    if ~isempty(is_imcontrastFig_Exist)
        rmappdata(handles.ImaAxes,'imcontrastFig');
    end
    is_miapixvalbutton_Exist = findobj('buttonDownFcn','mia_pixval(''ButtonDownOnImage'')');
    if ~isempty(is_miapixvalbutton_Exist)
        set(is_miapixvalbutton_Exist,'buttonDownFcn','');
    end

    % start the imcontrast and hold on the screen until finished it 
    imcontrast_h = imcontrast(handles.ImaHandler);
    set(imcontrast_h,'WindowStyle','modal');
    uiwait(imcontrast_h);

    % set the ColorBarMaxSlider and ColorBarMinSlider Values 
    % according to the new CLim 
    NewClim = get(handles.ImaAxes,'CLim');

end


if get(handles.ColorBarMaxSlider,'Min') > NewClim(1)
    set(handles.ColorBarMaxSlider, 'Min', 0.8*NewClim(1));
    set(handles.ColorBarMinSlider, 'Min', 0.8*NewClim(1));
end
if get(handles.ColorBarMaxSlider, 'Max') <  NewClim(2)
    set(handles.ColorBarMaxSlider, 'Max', 1.2*NewClim(2));
    set(handles.ColorBarMinSlider, 'Max' , 1.2*NewClim(2));
end
set(handles.ColorBarMaxSlider, 'Value', NewClim(2));
set(handles.ColorBarMinSlider, 'Value',  NewClim(1));

% change the image type from intensity  to RGB
SliderPosMax = NewClim(2);
SliderPosMin = NewClim(1);
CurrentImage = double(handles.imaVOL(:,:,handles.CurrentImgIdx));
CurrentImage_RGB = ...
    ImageRefresh(CurrentImage,SliderPosMax,SliderPosMin,handles.ColorRes,handles.ColormapIn1);
set(handles.ImaHandler,'CData',CurrentImage_RGB);
set(handles.ImaHandler,'CDataMapping','direct');
newlabels = num2cell(fixround(linspace(SliderPosMin,SliderPosMax,handles.NumOfYtickOfColorbar),handles.decimal_prec))';
set(handles.CmapAxes,'Yticklabel',newlabels);
% if 3D cursor on, rescale the related figures also
if get(handles.ThreeDcursortogglebutton,'value')
    set(get(handles.D3CursorFigData.ImaHandlerX,'parent'),'CLim',[SliderPosMin SliderPosMax]);
    set(get(handles.D3CursorFigData.ImaHandlerY,'parent'),'CLim',[SliderPosMin SliderPosMax]);
    set(get(handles.D3CursorFigData.ImaHandlerZ,'parent'),'CLim',[SliderPosMin SliderPosMax]);
end
 % if Resliced Images ON, rescale the related 3 figures also
if ishandle(handles.haxial) & ishandle(handles.hsagital) & ishandle(handles.hcoronal)
    set(get(handles.haxial,'parent'),'CLim',[SliderPosMin SliderPosMax]);
    set(get(handles.hsagital,'parent'),'CLim',[SliderPosMin SliderPosMax]);
    set(get(handles.hcoronal,'parent'),'CLim',[SliderPosMin SliderPosMax]);
end
% if sliceomatic_mia figure is ON, rescale the related figures also
if ishandle(handles.sliceomatic_haxmain)
    set(handles.sliceomatic_haxmain,'CLim',[SliderPosMin SliderPosMax]);
end
set(handles.ImaHandler,'CDataMapping','direct');


%turn off the mia_pixval func. 
mia_pixval(handles.ImaHandler,'on');
set(handles.hcb,'buttonDownFcn','mia_gui(''SetImageContrast'',gcbo,[],guidata(gcbo))');

% Update handles structure
guidata(hObject, handles);	    

%%  --- Executes during object creation, after setting all properties.
function ColorBarMaxSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ColorBarMaxSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

%%  --- Executes on slider movement.
function ColorBarMaxSlider_Callback(hObject, eventdata, handles)
% hObject    handle to ColorBarMaxSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
if isfield(handles,'FileNames')
	SliderPosMax = get(hObject,'Value');
	SliderPosMin = get(handles.ColorBarMinSlider,'Value');
	if SliderPosMax > SliderPosMin
        CurrentImage = double(handles.imaVOL(:,:,handles.CurrentImgIdx));
        CurrentImage_RGB = ...
            ImageRefresh(CurrentImage,SliderPosMax,SliderPosMin,handles.ColorRes,handles.ColormapIn1);
        set(handles.ImaHandler,'CData',CurrentImage_RGB);
        newlabels = num2cell(fixround(linspace(SliderPosMin,SliderPosMax,handles.NumOfYtickOfColorbar),handles.decimal_prec))';
        set(handles.CmapAxes,'Yticklabel',newlabels);
        % if 3D cursor on, rescale the related figures also
        if get(handles.ThreeDcursortogglebutton,'value')
            set(get(handles.D3CursorFigData.ImaHandlerX,'parent'),'CLim',[SliderPosMin SliderPosMax]);
            set(get(handles.D3CursorFigData.ImaHandlerY,'parent'),'CLim',[SliderPosMin SliderPosMax]);
            set(get(handles.D3CursorFigData.ImaHandlerZ,'parent'),'CLim',[SliderPosMin SliderPosMax]);
        end
         % if Resliced Images ON, rescale the related 3 figures also
        if ishandle(handles.haxial) & ishandle(handles.hsagital) & ishandle(handles.hcoronal)
            set(get(handles.haxial,'parent'),'CLim',[SliderPosMin SliderPosMax]);
            set(get(handles.hsagital,'parent'),'CLim',[SliderPosMin SliderPosMax]);
            set(get(handles.hcoronal,'parent'),'CLim',[SliderPosMin SliderPosMax]);
        end
        % if sliceomatic_mia figure is ON, rescale the related figures also
        if ishandle(handles.sliceomatic_haxmain)
            set(handles.sliceomatic_haxmain,'CLim',[SliderPosMin SliderPosMax]);
        end
	else
        set(hObject,'Value',SliderPosMin);
	end
	set(handles.ImaAxes,'selected','on');
end

% Update handles structure
guidata(hObject, handles);	    

%%  --- Executes during object creation, after setting all properties.
function ColorBarMinSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ColorBarMinSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


%%  --- Executes on slider movement.
function ColorBarMinSlider_Callback(hObject, eventdata, handles)
% hObject    handle to ColorBarMinSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
if isfield(handles,'FileNames')
	SliderPosMin = get(hObject,'Value');
	SliderPosMax = get(handles.ColorBarMaxSlider,'Value');
	if SliderPosMin < SliderPosMax
        CurrentImage = double(handles.imaVOL(:,:,handles.CurrentImgIdx));
        CurrentImage_RGB = ...
            ImageRefresh(CurrentImage,SliderPosMax,SliderPosMin,handles.ColorRes,handles.ColormapIn1);
        set(handles.ImaHandler,'CData',CurrentImage_RGB);
        newlabels = num2cell(fixround(linspace(SliderPosMin,SliderPosMax,handles.NumOfYtickOfColorbar),handles.decimal_prec))';
        set(handles.CmapAxes,'Yticklabel',newlabels);
        % if 3D cursor on, rescale the related figures also
        if get(handles.ThreeDcursortogglebutton,'value')
            set(get(handles.D3CursorFigData.ImaHandlerX,'parent'),'CLim',[SliderPosMin SliderPosMax]);
            set(get(handles.D3CursorFigData.ImaHandlerY,'parent'),'CLim',[SliderPosMin SliderPosMax]);
            set(get(handles.D3CursorFigData.ImaHandlerZ,'parent'),'CLim',[SliderPosMin SliderPosMax]);
        end
        % if Resliced Images ON, rescale the related 3 figures also
        if ishandle(handles.haxial) & ishandle(handles.hsagital) & ishandle(handles.hcoronal)
            set(get(handles.haxial,'parent'),'CLim',[SliderPosMin SliderPosMax]);
            set(get(handles.hsagital,'parent'),'CLim',[SliderPosMin SliderPosMax]);
            set(get(handles.hcoronal,'parent'),'CLim',[SliderPosMin SliderPosMax]);
        end
        % if Sliceomatic figure is ON, rescale the related figures also
        if ishandle(handles.sliceomatic_haxmain)
            set(handles.sliceomatic_haxmain,'CLim',[SliderPosMin SliderPosMax]);
        end
	else
        set(hObject,'Value',SliderPosMax);
	end
	set(handles.ImaAxes,'selected','on');
end
% Update handles structure
guidata(hObject, handles);	    

%%  --- Executes during object creation, after setting all properties.
function ColorBarMax2Slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ColorBarMax2Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


%%  --- Executes on slider movement.
function ColorBarMax2Slider_Callback(hObject, eventdata, handles)
% hObject    handle to ColorBarMax2Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
if isfield(handles,'FileNames2')
	SliderPosMax = get(hObject,'Value');
	SliderPosMin = get(handles.ColorBarMin2Slider,'Value');
	if SliderPosMax > SliderPosMin
        CurrentImage = double(handles.imaVOL2(:,:,handles.CurrentSlice));
        CurrentImage_RGB = ...
            ImageRefresh(CurrentImage,SliderPosMax,SliderPosMin,handles.ColorRes,handles.ColormapIn2);
        set(handles.ImaHandler2,'CData',CurrentImage_RGB);
        newlabels = num2cell(fixround(linspace(SliderPosMin,SliderPosMax,handles.NumOfYtickOfColorbar2),handles.decimal_prec))';
        set(handles.Cmap2Axes,'Yticklabel',newlabels);
        % if 3D cursor on, rescale the related figures also
        if get(handles.ThreeDcursor2togglebutton,'value')
            set(get(handles.D3CursorFigData2.ImaHandlerX,'parent'),'CLim',[SliderPosMin SliderPosMax]);
            set(get(handles.D3CursorFigData2.ImaHandlerY,'parent'),'CLim',[SliderPosMin SliderPosMax]);
            set(get(handles.D3CursorFigData2.ImaHandlerZ,'parent'),'CLim',[SliderPosMin SliderPosMax]);
        end
        % if Resliced Images ON, rescale the related 3 figures also
        if ishandle(handles.haxial2) & ishandle(handles.hsagital2) & ishandle(handles.hcoronal2)
            set(get(handles.haxial2,'parent'),'CLim',[SliderPosMin SliderPosMax]);
            set(get(handles.hsagital2,'parent'),'CLim',[SliderPosMin SliderPosMax]);
            set(get(handles.hcoronal2,'parent'),'CLim',[SliderPosMin SliderPosMax]);
        end
        % if Sliceomatic figure is ON, rescale the related figures also
        if ishandle(handles.sliceomatic_haxmain)
            set(handles.sliceomatic_haxmain,'CLim',[SliderPosMin SliderPosMax]);
        end
	else
        set(hObject,'Value',SliderPosMin);
	end
	set(handles.ImaAxes,'selected','on');
end
% Update handles structure
guidata(hObject, handles);	    

%%  --- Executes during object creation, after setting all properties.
function ColorBarMin2Slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ColorBarMin2Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


%%  --- Executes on slider movement.
function ColorBarMin2Slider_Callback(hObject, eventdata, handles)
% hObject    handle to ColorBarMin2Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
if isfield(handles,'FileNames2')
	SliderPosMin = get(hObject,'Value');
	SliderPosMax = get(handles.ColorBarMax2Slider,'Value');
	if SliderPosMin < SliderPosMax
        CurrentImage = double(handles.imaVOL2(:,:,handles.CurrentSlice));
        CurrentImage_RGB = ...
            ImageRefresh(CurrentImage,SliderPosMax,SliderPosMin,handles.ColorRes,handles.ColormapIn2);
        set(handles.ImaHandler2,'CData',CurrentImage_RGB);
        newlabels = num2cell(fixround(linspace(SliderPosMin,SliderPosMax,handles.NumOfYtickOfColorbar2),handles.decimal_prec2))';
        set(handles.Cmap2Axes,'Yticklabel',newlabels);
        % if 3D cursor on, rescale the related figures also
        if get(handles.ThreeDcursor2togglebutton,'value')
            set(get(handles.D3CursorFigData2.ImaHandlerX,'parent'),'CLim',[SliderPosMin SliderPosMax]);
            set(get(handles.D3CursorFigData2.ImaHandlerY,'parent'),'CLim',[SliderPosMin SliderPosMax]);
            set(get(handles.D3CursorFigData2.ImaHandlerZ,'parent'),'CLim',[SliderPosMin SliderPosMax]);
        end
        % if Resliced Images ON, rescale the related 3 figures also
        if ishandle(handles.haxial2) & ishandle(handles.hsagital2) & ishandle(handles.hcoronal2)
            set(get(handles.haxial2,'parent'),'CLim',[SliderPosMin SliderPosMax]);
            set(get(handles.hsagital2,'parent'),'CLim',[SliderPosMin SliderPosMax]);
            set(get(handles.hcoronal2,'parent'),'CLim',[SliderPosMin SliderPosMax]);
        end
        % if Sliceomatic figure is ON, rescale the related figures also
        if ishandle(handles.sliceomatic_haxmain)
            set(handles.sliceomatic_haxmain,'CLim',[SliderPosMin SliderPosMax]);
        end
	else
        set(hObject,'Value',SliderPosMax);
	end
	set(handles.ImaAxes,'selected','on');
end
% Update handles structure
guidata(hObject, handles);	    

%%  --- Executes during object creation, after setting all properties.
function ColorMapPopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ColorMapPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
set(hObject, 'String', {'spectral', 'spectral_inv','gray', 'gray_inv','spectralMNI', 'spectralMNI_inv',...
    'hsv', 'hot', 'bone', 'copper','pink', 'white', 'flag', 'lines', 'colorcube', 'vga','jet', 'prism', ...
    'cool', 'autumn', 'spring', 'winter','summer','custom'});

%%  --- Executes on selection change in ColorMapPopupmenu.
function ColorMapPopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to ColorMapPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ColorMapPopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ColorMapPopupmenu
global gVOLpixval;

if isfield(handles,'FileNames')
	contents = get(hObject,'String');
	axes(handles.CmapAxes);
    if strcmp(contents{get(hObject,'Value')},'custom')
        cmapeditor;
    else
        current_map = colormap([contents{get(hObject,'Value')},'(',num2str(handles.ColorRes),')']);
		r=current_map(:,1); g=current_map(:,2); b=current_map(:,3);
		CMapImgRes=[1:handles.ColorRes];
		CMapImg=cat(3,r(CMapImgRes),g(CMapImgRes),b(CMapImgRes));
		%delete(handles.hcb);% delete the current colormap image
        set(handles.hcb,'cdata',CMapImg);
        %handles.hcb = image(CMapImg);
        handles.ColormapIn1 = current_map;
        gVOLpixval.currentmap = current_map;
        
        %refresh the image
        SliderPosMax = get(handles.ColorBarMaxSlider,'Value');
        SliderPosMin = get(handles.ColorBarMinSlider,'Value');
        CurrentImage = double(handles.imaVOL(:,:,handles.CurrentImgIdx));
        CurrentImage_RGB = ImageRefresh(CurrentImage,SliderPosMax,SliderPosMin,handles.ColorRes,handles.ColormapIn1);
        set(handles.ImaHandler,'CData',CurrentImage_RGB);
        
        % Update handles structure
        guidata(hObject, handles);
    end
    axes(handles.ImaAxes);
    %set(handles.ImaAxes,'selected','on');
end


%%  --- Executes during object creation, after setting all properties.
function ColorMap2Popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ColorMap2Popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
set(hObject, 'String', {'spectral', 'spectral_inv','gray', 'gray_inv','spectralMNI', 'spectralMNI_inv',...
    'hsv', 'hot', 'bone', 'copper','pink', 'white', 'flag', 'lines', 'colorcube', 'vga','jet', 'prism', ...
    'cool', 'autumn', 'spring', 'winter','summer','custom'});

set(hObject,'Value',3);

%%  --- Executes on selection change in ColorMap2Popupmenu.
function ColorMap2Popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to ColorMap2Popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ColorMap2Popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ColorMap2Popupmenu
if isfield(handles,'FileNames2')
	contents = get(hObject,'String');
	axes(handles.Cmap2Axes);
	if strcmp(contents{get(hObject,'Value')},'custom')
          cmapeditor;
    else    
        current_map = colormap([contents{get(hObject,'Value')},'(',num2str(handles.ColorRes),')']);
        r=current_map(:,1); g=current_map(:,2); b=current_map(:,3);
		CMapImgRes=[1:handles.ColorRes];
		CMapImg=cat(3,r(CMapImgRes),g(CMapImgRes),b(CMapImgRes));
        delete(handles.hcb2);% delete the current colormap image
		handles.hcb2 = image(CMapImg);
        handles.ColormapIn2 = current_map;
        
        %refresh the image
        SliderPosMax = get(handles.ColorBarMax2Slider,'Value');
        SliderPosMin = get(handles.ColorBarMin2Slider,'Value');
        CurrentImage = double(handles.imaVOL2(:,:,handles.CurrentImgIdx));
        CurrentImage_RGB = ImageRefresh(CurrentImage,SliderPosMax,SliderPosMin,handles.ColorRes,handles.ColormapIn2);
        set(handles.ImaHandler2,'CData',CurrentImage_RGB);
        
        
        % Update handles structure
        guidata(hObject, handles);	    
    end
    set(handles.ImaAxes,'selected','on');
end




%%  --- Executes during object creation, after setting all properties.
function TransparencySlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TransparencySlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


%%  --- Executes on slider movement.
function TransparencySlider_Callback(hObject, eventdata, handles)
% hObject    handle to TransparencySlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

if not(isfield(handles,'FileNames2'));return;end %return if no 2nd. file was opened

%opacity_matrix = get(hObject,'Value') * ones(handles.scaninfo2.imfm);
%CurrentImage = double(handles.imaVOL2(:,:,handles.CurrentImgIdx));
%zero_entries = find(CurrentImage == 0);
%opacity_matrix( zero_entries ) = 0;
opacity_matrix = get(hObject,'Value');
set(handles.ImaHandler2,'AlphaData',opacity_matrix);

% Update handles structure
guidata(hObject, handles);


%%  --- Executes the RBG image generation.
function Image_RGB = CreateRGBImage(ImageIn,ImageMinMax,ColorRes,ColormapIn)
%
%CurrentImage_Rescaled = int16( fix((ColorRes-1)*double(ImageIn) / ( double(ImageMinMax(2))-double(ImageMinMax(1))  ) )+1);
CurrentImage_Rescaled = uint16( fix( (ColorRes-1) * ...
    ( (double(ImageIn)-double(ImageMinMax(1))) / (double(ImageMinMax(2))-double(ImageMinMax(1))) )   )+1);
range_zeros = (find(CurrentImage_Rescaled == 0));
CurrentImage_Rescaled(range_zeros) = 1;
Current_cmap = ColormapIn;
Image_RGB = (zeros(size(ImageIn,1),size(ImageIn,2),3));
for RGB_dim = 1:3
    colour_slab_vals = Current_cmap(CurrentImage_Rescaled, RGB_dim);
    Image_RGB(:,:,RGB_dim) = reshape( colour_slab_vals, size(ImageIn));
end

%%  --- Executes the image refresh.
function Image_out = ImageRefresh(CurrentImage,SliderPosMax,SliderPosMin,ColorRes,ColormapIn)
%
CurrentImage( find(CurrentImage > SliderPosMax )) = SliderPosMax;
CurrentImage( find(CurrentImage < SliderPosMin)) = min(CurrentImage(:));
            Image_out = ... 
CreateRGBImage(CurrentImage,[SliderPosMin SliderPosMax], ColorRes, ColormapIn);


%%  --- Executes on button press in ZoomTogglebutton.
function ZoomTogglebutton_Callback(hObject, eventdata, handles)
% hObject    handle to ZoomTogglebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of ZoomTogglebutton
if not(isfield(handles,'ImaHandler'));return;end %return if no 1st. file was previously opened

%openglinfo = opengl('data');%zoom and opengl does not work well with some  

if get(hObject,'Value')
   if get(handles.MeasureTogglebutton,'value'); 
      mia_pixval(handles.ImaHandler,'off');
      set(handles.MeasureTogglebutton,'value',0);
      set(handles.ROIbutton,'enable','off');
   end
   if get(handles.ImProfileTogglebutton,'value');
       mia_improfile('stop');
       set(handles.ImProfileTogglebutton,'value',0);
   end
   if get(handles.DetailRectangleButton,'value')
        set(handles.DetailRectangleButton,'value',0);
        RectangleHandler = findobj('tag','miarectangle');
        draggable(RectangleHandler,'off');
        delete(RectangleHandler);
        delete(findobj('name','Detail Rectangle (Delete this Fig to draw a new Rectangle)'));
		axes(handles.ImaAxes);
		set(handles.ROIbutton,'enable','off');
    end
   mia_zoompan('initialize');
   %zoom on;
   handles.zoom = 1;
else
   %zoom off;
   %set(gcf,'doublebuffer','off');
   %if strcmp(openglinfo.Renderer,'GeForce4 Ti 4200 with AGP8X/AGP/SSE2')
   %     set(handles.ImaHandler,'EraseMode','normal');
   %end
   handles.zoom = 0;
   mia_zoompan('stop');
   set(handles.ROIbutton,'enable','on');
end
%set(get(handles.ImaAxes,'children'),'EraseMode','none');
% Update handles structure
guidata(hObject, handles);

%%  --- Executes on button press in DetailRectangleButton.
function DetailRectangleButton_Callback(hObject, eventdata, handles)
% hObject    handle to DetailRectangleButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DetailRectangleButton
if not(isfield(handles,'ImaHandler'));return;end %return if no 1st. file was previously opened

if get(hObject,'Value')
    if get(handles.ImProfileTogglebutton,'value')
        mia_improfile('stop');
        set(handles.ImProfileTogglebutton,'value',0);
        set(handles.ROIbutton,'enable','on');
	end
    if get(handles.MeasureTogglebutton,'value'); 
        mia_pixval(handles.ImaHandler,'off');
        set(handles.MeasureTogglebutton,'value',0);
        set(handles.ROIbutton,'enable','off');
    end
    rectpos = [0 0 0 0];
    while rectpos(3) == 0;
        rectpos = round(getrect(handles.ImaAxes));
        if rectpos(3) == 0;
            mbh = msgbox('Use the mouse to click and DRAG the desired rectangle.','mia Info');
            uiwait(mbh);
        end
    end
    mouseclick = get(gcf,'SelectionType');
    RectangleHandler = rectangle('Position',rectpos);
    set(RectangleHandler,'linewidth',3);
    set(RectangleHandler,'edgeColor','red');
    set(RectangleHandler,'tag','miarectangle');
    dry = round(rectpos(1)):round(rectpos(1)) + round(rectpos(3)-1);
	drx = round(rectpos(2)):round(rectpos(2)) + round(rectpos(4)-1);
    
    ScreenSize = get(0,'ScreenSize');
    Pos = [0.6*ScreenSize(3)    0.1*ScreenSize(4)    0.4*ScreenSize(3)    0.35*ScreenSize(4)];
    fh = figure('name','Detail Rectangle (Delete this Fig to draw a new Rectangle)', ...
        'NumberTitle','off','menubar','none','Position',Pos, ...
        'DeleteFcn','mia_gui(''DeleteDetailRectangleWindow'',gcbo,[],guidata(gcbo))');
    colormap(handles.ColormapIn1);
    set(fh,'doubleBuffer','on');
    
    CurrentImage = handles.imaVOL(:,:,handles.CurrentImgIdx);
    cimg = CurrentImage(drx,dry);
	currect_size = size(cimg);
    
    if strcmp(mouseclick,'normal')
        if max(handles.scaninfo.imfm) < 512 &&  max(handles.scaninfo.imfm) > 256
            interpolation_factor = 2;
            ImgUdata.isintep = 1;
        elseif max(handles.scaninfo.imfm) <= 256
            interpolation_factor = 4;
            ImgUdata.isintep = 1;
        else
            interpolation_factor = 1;
            ImgUdata.isintep = 0;
        end
    else
        interpolation_factor = 1;
        ImgUdata.isintep = 0;
    end
    
    new_imfm = interpolation_factor*currect_size;
	new_xpixvect = [currect_size(1)/new_imfm(1): ...
                currect_size(1)/new_imfm(1) : currect_size(1)];
	new_ypixvect = [currect_size(2)/new_imfm(2): ...
                currect_size(2)/new_imfm(2) : currect_size(2)];
    
    if ImgUdata.isintep
        cimgout = interp2(double(cimg), new_ypixvect, new_xpixvect','linear');
    else
        cimgout = cimg;
    end
    ImgUdata.minpix = get(handles.ColorBarMinSlider,'Value');
    ImgUdata.maxpix = get(handles.ColorBarMaxSlider,'Value');
    ImgUdata.isfirstrun = 1;
    ImgUdata.new_xpixvect = new_xpixvect;
    ImgUdata.new_ypixvect = new_ypixvect;
    
	imh = imagesc(cimgout,[ImgUdata.minpix ImgUdata.maxpix]);
    axis image;
    set(imh,'tag','DetailRectangleImg');
    set(imh,'EraseMode','none');
    set(imh,'userdata',ImgUdata);
    Axh = get(imh,'parent');
    set(Axh,'tag','DetailRectangleAx');
    axis off;
    
    draggable(RectangleHandler,@mia_rectdrag);
    
else
    RectangleHandler = findobj('tag','miarectangle');
    draggable(RectangleHandler,'off');
    delete(RectangleHandler);
    delete(findobj('name','Detail Rectangle'));
	axes(handles.ImaAxes);
	%mia_pixval(handles.ImaHandler,'on');
	set(handles.ROIbutton,'enable','on');
    % Update handles structure
    guidata(hObject, handles);
end

%%  --- Executes on deleting the DetailRectangle Window.
function DeleteDetailRectangleWindow(hObject, eventdata, handles)

RectangleHandler = findobj('tag','miarectangle');
if isempty(RectangleHandler)% if the Rectangle was turned off by the "DetailRectangleButton_callback"
    return;
end
draggable(RectangleHandler,'off');
delete(RectangleHandler);
delete(findobj('name','Detail Rectangle'));

mfh = findobj('tag','mia_figure1');
handles = guidata(mfh);

rectpos = [0 0 0 0];
while rectpos(3) == 0;
    rectpos = round(getrect(handles.ImaAxes));
    if rectpos(3) == 0;
        mbh = msgbox('Use the mouse to click and DRAG the desired rectangle.','mia Info');
        uiwait(mbh);
    end
end
mouseclick = get(gcf,'SelectionType');
RectangleHandler = rectangle('Position',rectpos);
set(RectangleHandler,'linewidth',3);
set(RectangleHandler,'edgeColor','red');
set(RectangleHandler,'tag','miarectangle');
dry = round(rectpos(1)):round(rectpos(1)) + round(rectpos(3)-1);
drx = round(rectpos(2)):round(rectpos(2)) + round(rectpos(4)-1);

ScreenSize = get(0,'ScreenSize');
Pos = [0.6*ScreenSize(3)    0.1*ScreenSize(4)    0.4*ScreenSize(3)    0.35*ScreenSize(4)];
fh = figure('name','Detail Rectangle (Delete this Fig to draw a new Rectangle)', ...
        'NumberTitle','off','menubar','none','Position',Pos, ...
        'DeleteFcn','mia_gui(''DeleteDetailRectangleWindow'',gcbo,[],guidata(gcbo))');
colormap(handles.ColormapIn1);
set(fh,'doubleBuffer','on');

CurrentImage = handles.imaVOL(:,:,handles.CurrentImgIdx);
cimg = CurrentImage(drx,dry);
currect_size = size(cimg);

if strcmp(mouseclick,'normal')
    if max(handles.scaninfo.imfm) < 512 &&  max(handles.scaninfo.imfm) > 256
        interpolation_factor = 2;
        ImgUdata.isintep = 1;
    elseif max(handles.scaninfo.imfm) <= 256
        interpolation_factor = 4;
        ImgUdata.isintep = 1;
    else
        interpolation_factor = 1;
        ImgUdata.isintep = 0;
    end
else
    interpolation_factor = 1;
    ImgUdata.isintep = 0;
end

new_imfm = interpolation_factor*currect_size;
new_xpixvect = [currect_size(1)/new_imfm(1): ...
            currect_size(1)/new_imfm(1) : currect_size(1)];
new_ypixvect = [currect_size(2)/new_imfm(2): ...
            currect_size(2)/new_imfm(2) : currect_size(2)];

if ImgUdata.isintep
    cimgout = interp2(double(cimg), new_ypixvect, new_xpixvect','linear');
else
    cimgout = cimg;
end
ImgUdata.minpix = get(handles.ColorBarMinSlider,'Value');
ImgUdata.maxpix = get(handles.ColorBarMaxSlider,'Value');
ImgUdata.isfirstrun = 1;
ImgUdata.new_xpixvect = new_xpixvect;
ImgUdata.new_ypixvect = new_ypixvect;

imh = imagesc(cimgout,[ImgUdata.minpix ImgUdata.maxpix]);
axis image;
set(imh,'tag','DetailRectangleImg');
set(imh,'EraseMode','none');
set(imh,'userdata',ImgUdata);
Axh = get(imh,'parent');
set(Axh,'tag','DetailRectangleAx');
axis off;

draggable(RectangleHandler,@mia_rectdrag);
    
% mfh = findobj('tag','mia_figure1');
% mfh_handles = guidata(mfh);
% set(mfh_handles.DetailRectangleButton,'value',0);
% axes(mfh_handles.ImaAxes);
% set(mfh_handles.ROIbutton,'enable','on');
% set(mfh,'WindowButtonMotionFcn','');






%%  --- Executes on button press in ImProfileTogglebutton.
function ImProfileTogglebutton_Callback(hObject, eventdata, handles)
% hObject    handle to ImProfileTogglebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of ImProfileTogglebutton
if not(isfield(handles,'ImaHandler'));return;end %return if no 1st. file was previously opened

if get(hObject,'Value')
    if get(handles.DetailRectangleButton,'value')
        set(handles.DetailRectangleButton,'value',0);
        RectangleHandler = findobj('tag','miarectangle');
        draggable(RectangleHandler,'off');
        delete(RectangleHandler);
        delete(findobj('name','Detail Rectangle (Delete this Fig to draw a new Rectangle)'));
		axes(handles.ImaAxes);
		set(handles.ROIbutton,'enable','off');
    end
    if get(handles.MeasureTogglebutton,'value'); 
        mia_pixval(handles.ImaHandler,'off');
        %set(handles.mia_figure1,'WindowButtonMotionFcn','');
        set(handles.MeasureTogglebutton,'value',0);
        set(handles.ROIbutton,'enable','off');
    end
    if isempty(findobj('name','Image Profile'))
        ScreenSize = get(0,'ScreenSize');
        Pos = [0.6*ScreenSize(3)    0.1*ScreenSize(4)    0.4*ScreenSize(3)    0.35*ScreenSize(4)];
        fh = figure('name','Image Profile','NumberTitle','off','Position',Pos,'doubleBuffer','on');
         % create buttons for FWHM and FWTM analysis
        drawbutton_h = uicontrol('Style','pushbutton','String','FWHM Gauss', ...
            'units','normalized','Position',[0.8 0.94 0.2 0.05], 'Callback', 'mia_fwhmanalysis(''Gauss'')', ...
            'TooltipString','Calculate the FWHM and FWHT values');
         % create buttons for FWHM and FWTM analysis by NEMA
        drawbutton_h = uicontrol('Style','pushbutton','String','FWHM NEMA', ...
            'units','normalized','Position',[0.55 0.94 0.2 0.05], 'Callback', 'mia_fwhmanalysis(''NEMA'')', ...
            'TooltipString','Calculate the FWHM and FWHT values by NEMA protocol');
        %default plot
        lh = plot(0:10:200); set(lh,'Tag','Improfile_linecurve');hold on;
        lh2 = plot(0:10:200,'*'); set(lh2,'Tag','Improfile_pointcurve');hold off;
        xlabel('Distance along profile [mm]');ylabel('Pixel value');
    end
    % Update handles structure
    guidata(hObject, handles);
    mia_improfile('start');
else
    mia_improfile('stop');
	axes(handles.ImaAxes);
	%mia_pixval(handles.ImaHandler,'on');
	set(handles.ROIbutton,'enable','on');
    % Update handles structure
    guidata(hObject, handles);
end

%%  --- Executes on button press in MeasureTogglebutton.
function MeasureTogglebutton_Callback(hObject, eventdata, handles)
% hObject    handle to MeasureTogglebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if not(isfield(handles,'ImaHandler'));return;end %return if no 1st. file was previously opened

if get(hObject,'Value')
    if get(handles.DetailRectangleButton,'value')
        set(handles.DetailRectangleButton,'value',0);
        RectangleHandler = findobj('tag','miarectangle');
        draggable(RectangleHandler,'off');
        delete(RectangleHandler);
        delete(findobj('name','Detail Rectangle (Delete this Fig to draw a new Rectangle)'));
		axes(handles.ImaAxes);
		set(handles.ROIbutton,'enable','on');
    end
	if get(handles.ImProfileTogglebutton,'value')
        mia_improfile('stop');
        set(handles.ImProfileTogglebutton,'value',0);
        set(handles.ROIbutton,'enable','on');
	end
    mia_pixval(handles.ImaHandler,'on');
else
    mia_pixval(handles.ImaHandler,'off');
    %set(handles.mia_figure1,'WindowButtonMotionFcn','');
    set(handles.MeasureTogglebutton,'value',0);
    set(handles.ROIbutton,'enable','off');
end
guidata(hObject, handles);



%%  --- Executes on button press in ThreeDcursortogglebutton.
function ThreeDcursortogglebutton_Callback(hObject, eventdata, handles)
% hObject    handle to ThreeDcursortogglebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ThreeDcursortogglebutton
if not(isfield(handles,'FileNames'));return;end %return if no 1st. file was previously opened


if get(hObject,'Value')
   minpix = get(handles.ColorBarMinSlider,'Value');
   maxpix = get(handles.ColorBarMaxSlider,'Value');
   cmapcontents = get(handles.ColorMapPopupmenu,'String');
   cmapname = cmapcontents{get(handles.ColorMapPopupmenu,'Value')};
   % in case of dynamic scan load only the last "time frame" imaVOL 
   if handles.scaninfo.Frames > 1 
%        SlicesForLastFrame = [(handles.scaninfo.Frames-1)*handles.scaninfo.num_of_slice+1: ...
%                handles.scaninfo.Frames*handles.scaninfo.num_of_slice];
        SlicesForLastFrame = [(handles.CurrentFrame-1)*handles.scaninfo.num_of_slice + 1: ...
                handles.CurrentFrame*handles.scaninfo.num_of_slice];
       imaVOL = handles.imaVOL(:,:,SlicesForLastFrame);
   else
       imaVOL = handles.imaVOL;
   end
   handles.D3CursorFigData = ...
    mia_Start3dCursor(imaVOL,handles.scaninfo.pixsize,cmapname,minpix,maxpix);
   %set(handles.ThreeDcursor2togglebutton,'enable','off');
   
   set(hObject,'Value',0);
   % Update handles structure
   guidata(hObject, handles);
   mia_3dcursor_gui(handles.mia_figure1);
else
    if ishandle(handles.D3CursorFigData.FigHandlerX)
        delete(handles.D3CursorFigData.FigHandlerX);
    end
    if ishandle(handles.D3CursorFigData.FigHandlerY)
       delete(handles.D3CursorFigData.FigHandlerY);
    end
    if  ishandle(handles.D3CursorFigData.FigHandlerZ)
        delete(handles.D3CursorFigData.FigHandlerZ);
    end
    handles = rmfield(handles,'D3CursorFigData');
    %set(handles.ThreeDcursor2togglebutton,'enable','on');
end
%set(get(handles.ImaAxes,'children'),'EraseMode','none');
% Update handles structure
guidata(hObject, handles);


%%  --- Executes on button press in ThreeDcursor2togglebutton.
function ThreeDcursor2togglebutton_Callback(hObject, eventdata, handles)
% hObject    handle to ThreeDcursor2togglebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ThreeDcursor2togglebutton
if not(isfield(handles,'FileNames2'));return;end %return if no 1st. file was previously opened
if handles.scaninfo2.num_of_slice == 1;return;end % return if imaVOL only 2D 

if get(hObject,'Value')
   minpix = get(handles.ColorBarMin2Slider,'Value');;
   maxpix = get(handles.ColorBarMax2Slider,'Value');
   cmapcontents = get(handles.ColorMap2Popupmenu,'String');
   cmapname = cmapcontents{get(handles.ColorMap2Popupmenu,'Value')};
   % in case of dynamic scan load only the last "time frame" imaVOL 
   if handles.scaninfo2.Frames > 1 
       SlicesForLastFrame = [(handles.scaninfo2.Frames-1)*handles.scaninfo2.num_of_slice+1: ...
               handles.scaninfo2.Frames*handles.scaninfo2.num_of_slice];
       imaVOL = int16(smooth3(handles.imaVOL2(:,:,SlicesForLastFrame),'gaussian'));
   else
       imaVOL = handles.imaVOL2;
   end
   handles.D3CursorFigData2 = ...
    mia_Start3dCursor(imaVOL,handles.scaninfo2.pixsize,cmapname,minpix,maxpix);
   set(handles.ThreeDcursortogglebutton,'enable','off');
else
    if ishandle(handles.D3CursorFigData2.FigHandlerX)
        delete(handles.D3CursorFigData2.FigHandlerX);
    end
    if ishandle(handles.D3CursorFigData2.FigHandlerY)
       delete(handles.D3CursorFigData2.FigHandlerY);
    end
    if  ishandle(handles.D3CursorFigData2.FigHandlerZ)
        delete(handles.D3CursorFigData2.FigHandlerZ);
    end
    handles = rmfield(handles,'D3CursorFigData2');
    set(handles.ThreeDcursortogglebutton,'enable','on');
end
%set(get(handles.ImaAxes,'children'),'EraseMode','none');
% Update handles structure
guidata(hObject, handles);


%%  --- Executes on button press in ThreeDrenderingpushbutton.
function ThreeDrenderingpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ThreeDrenderingpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of
% ThreeDrenderingpushbutton
if not(isfield(handles,'FileNames'));return;end %return if no 1st. file was previously opened

%if hardware opengl processing was turn out at startup
%this should turn back for rendering  
if handles.openglinfo.UseGenericOpenGL == 1;
    feature('UseGenericOpenGL',0);
end


if isempty(get(handles.RenderingLevelEdit,'String'))
    RenderingThres=handles.VolMax*0.4;
    set(handles.RenderingLevelEdit,'String',RenderingThres);
else
    RenderingThres = str2double(get(handles.RenderingLevelEdit,'string'));
end
cmapcontents = get(handles.ColorMapPopupmenu,'String');
cmapname = cmapcontents{get(handles.ColorMapPopupmenu,'Value')};
pixsize = handles.scaninfo.pixsize;
SliderPosMin = get(handles.ColorBarMinSlider,'Value');
SliderPosMax = get(handles.ColorBarMaxSlider,'Value');

% init.the progressbar
info.color=[1 0 0];
info.title='Rendering';
info.size=1;
info.pos='bottom';
pb=progbar(info);
% in case of dynamic scan load only the last "time frame" imaVOL 
if handles.scaninfo.Frames > 1 
   SlicesForLastFrame = [(handles.scaninfo.Frames-1)*handles.scaninfo.num_of_slice+1: ...
           handles.scaninfo.Frames*handles.scaninfo.num_of_slice];
   imaVOL = int16(handles.imaVOL(:,:,SlicesForLastFrame));
else
   imaVOL = handles.imaVOL;
end
%
% The rendering is time consuming:
% the rendering runs on RenderSize*RenderSize images
%
progbar(pb,5);
RenderSize = 128;
if handles.scaninfo.imfm(1) > RenderSize
    imaVOLr = int16(zeros(RenderSize,RenderSize,handles.scaninfo.num_of_slice));
    for i = 1: handles.scaninfo.num_of_slice
        imaVOLr(:,:,i) = imresize(double(imaVOL(:,:,i)), [RenderSize RenderSize],'bilinear');
    end
else
        imaVOLr = imaVOL;
end

hrf = figure('name','3D Rendering','NumberTitle','off');
progbar(pb,10);      
DataAspectRatio = [size(handles.imaVOL,1)*pixsize(1) ...
        size(handles.imaVOL,2)*pixsize(2) size(handles.imaVOL,3)*pixsize(3)];
RdAxis = gca;
set(RdAxis,'DataAspectRatio',DataAspectRatio);
view(3);  axis off; 
axis tight;
ImaVOLs = smooth3(imaVOLr);
progbar(pb,40);  
map = colormap(cmapname);
%hiso = patch(isosurface(ImaVOLs,RenderingThres),'FaceColor',[1, .75,.65],'EdgeColor','none');
hiso = patch(isosurface(ImaVOLs,RenderingThres),'FaceColor',[1 0.4 0.4],'EdgeColor','none');
progbar(pb,60);  
hcap = patch(isocaps(imaVOLr,RenderingThres),'FaceColor','interp','EdgeColor','none');
progbar(pb,80);  
set(get(hcap,'parent'),'CLim',[SliderPosMin SliderPosMax]);
view(45,30);  axis tight; %axis fill;
lightangle(45,30);
set(gcf,'Renderer','opengl');lighting phong;
isonormals(ImaVOLs,hiso);
progbar(pb,90);
set(hcap,'AmbientStrength',.6);
set(hiso,'SpecularColorReflectance',0,'SpecularExponent',10);
axis vis3d;
zoom(1.5);
camlight; %turn on the camera lighting
close(pb);
% Try setting up the camera toolbar
%try
     cameratoolbar2;
%end
% default camera rotating theabout the object 
for i=1:36
    camorbit(RdAxis,10,10,'data',[0 0 1]);drawnow;
end
%alpha(hiso,'color'); 


%%  --- Executes during object creation, after setting all properties.
function RenderingLevelEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RenderingLevelEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function RenderingLevelEdit_Callback(hObject, eventdata, handles)
% hObject    handle to RenderingLevelEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RenderingLevelEdit as text
%        str2double(get(hObject,'String')) returns contents of RenderingLevelEdit as a double


%%  --- Executes on button press in ThreeDrendering2pushbutton.
function ThreeDrendering2pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ThreeDrendering2pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ThreeDrendering2pushbutton
if not(isfield(handles,'FileNames2'));return;end %return if no 1st. file was previously opened

%if hardware opengl processing was turn out at startup
%this should turn back for sliceomatic  
if handles.openglinfo.UseGenericOpenGL == 1;
    feature('UseGenericOpenGL',0);
end

if isempty(get(handles.RenderingLevel2Edit,'String'))
    RenderingThres=handles.VolMax2/10;
    set(handles.RenderingLevel2Edit,'String',RenderingThres);
else
    RenderingThres = str2double(get(handles.RenderingLevel2Edit,'string'));
end
cmapcontents = get(handles.ColorMap2Popupmenu,'String');
cmapname = cmapcontents{get(handles.ColorMap2Popupmenu,'Value')};
pixsize = handles.scaninfo2.pixsize;
SliderPosMin = get(handles.ColorBarMin2Slider,'Value');
SliderPosMax = get(handles.ColorBarMax2Slider,'Value');
%
% init.the progressbar
%
info.color=[1 0 0];
info.title='Rendering';
info.size=1;
info.pos='bottom';
pb=progbar(info);
%
% in case of dynamic scan load only the last "time frame" imaVOL 
%
if handles.scaninfo2.Frames > 1 
   SlicesForLastFrame = [(handles.scaninfo2.Frames-1)*handles.scaninfo2.num_of_slice+1: ...
           handles.scaninfo2.Frames*handles.scaninfo2.num_of_slice];
   imaVOL = int16(handles.imaVOL2(:,:,SlicesForLastFrame));
else
   imaVOL = handles.imaVOL;
end
%
% The rendering is time consuming:
% the rendering runs on RenderSize*RenderSize images
%
RenderSize = 128;
progbar(pb,5); 
if handles.scaninfo2.imfm(1) > RenderSize
    imaVOLr = int16(zeros(RenderSize,RenderSize,handles.scaninfo2.num_of_slice));
    for i = 1: handles.scaninfo2.num_of_slice
        imaVOLr(:,:,i) = imresize(handles.imaVOL2(:,:,i), [RenderSize RenderSize],'bilinear');
    end
else
        imaVOLr = handles.imaVOL2;
end

progbar(pb,10); 
hrf2 = figure('name','3D Rendering 2.','NumberTitle','off');     
DataAspectRatio = [size(handles.imaVOL2,1)*pixsize(1) ...
        size(handles.imaVOL2,2)*pixsize(2) size(handles.imaVOL2,3)*pixsize(3)];
RdAxis = gca;
set(RdAxis,'DataAspectRatio',DataAspectRatio);
view(3);  axis off; 
axis tight;
ImaVOLs = int16(smooth3(imaVOLr));
progbar(pb,40);  
map = colormap(cmapname);
hiso2 = patch(isosurface(ImaVOLs,RenderingThres),'FaceColor',[1, .75,.65],'EdgeColor','none');
progbar(pb,60);  
hcap2 = patch(isocaps(imaVOLr,RenderingThres),'FaceColor','interp','EdgeColor','none');
progbar(pb,80);  
set(get(hcap2,'parent'),'CLim',[SliderPosMin SliderPosMax]);
view(45,30);  axis tight; %axis fill;
lightangle(45,30);
set(gcf,'Renderer','opengl');lighting phong;
isonormals(ImaVOLs,hiso2);
progbar(pb,90);
set(hcap2,'AmbientStrength',.6);
set(hiso2,'SpecularColorReflectance',0,'SpecularExponent',10);
axis vis3d;
zoom(1.5);
camlight; %turn on the camera lighting
close(pb);
% Try setting up the camera toolbar
try
     cameratoolbar2;
end
% default camera rotating theabout the object 
for i=1:36
    camorbit(RdAxis,10,10,'data',[0 0 1]);drawnow;
end



%%  --- Executes during object creation, after setting all properties.
function RenderingLevel2Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RenderingLevel2Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function RenderingLevel2Edit_Callback(hObject, eventdata, handles)
% hObject    handle to RenderingLevel2Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RenderingLevel2Edit as text
%        str2double(get(hObject,'String')) returns contents of RenderingLevel2Edit as a double


%%  --------------------------------------------------------------------
function Tools1Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Tools1Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%%  --------------------------------------------------------------------
function FlipLR_Callback(hObject, eventdata, handles)
% hObject    handle to FlipLR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if not(isfield(handles,'FileNames'));return;end %return if no 1st. file was previously opened

if  strcmp(get(handles.FlipLR,'checked'),'off')
	set(handles.FlipLR,'checked','on');
else
    set(handles.FlipLR,'checked','off');
end
handles.imaVOL = flipdim(handles.imaVOL,2);
% Update handles structure
guidata(hObject, handles);
mia_gui('CurrentSliceEdit_Callback',handles.CurrentSliceEdit,[],handles);


%%  --------------------------------------------------------------------
function FlipUD_Callback(hObject, eventdata, handles)
% hObject    handle to FlipUD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if not(isfield(handles,'FileNames'));return;end %return if no 1st. file was previously opened

if  strcmp(get(handles.FlipUD,'checked'),'off')
	set(handles.FlipUD,'checked','on');
else
    set(handles.FlipUD,'checked','off');
end
handles.imaVOL = flipdim(handles.imaVOL,1);
% Update handles structure
guidata(hObject, handles);
mia_gui('CurrentSliceEdit_Callback',handles.CurrentSliceEdit,[],handles);

%%  --------------------------------------------------------------------
function FlipFB_Callback(hObject, eventdata, handles)
% hObject    handle to FlipFB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if not(isfield(handles,'FileNames'));return;end %return if no 1st. file was previously opened

if  strcmp(get(handles.FlipFB,'checked'),'off')
	set(handles.FlipFB,'checked','on');
else
    set(handles.FlipFB,'checked','off');
end
handles.imaVOL = flipdim(handles.imaVOL,3);
% Update handles structure
guidata(hObject, handles);
mia_gui('CurrentSliceEdit_Callback',handles.CurrentSliceEdit,[],handles);


%%  --------------------------------------------------------------------
function Tools2menu_Callback(hObject, eventdata, handles)
% hObject    handle to Tools2menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%  --------------------------------------------------------------------
function FlipLR2_Callback(hObject, eventdata, handles)
% hObject    handle to FlipLR2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if not(isfield(handles,'FileNames2'));return;end %return if no 1st. file was previously opened

if  strcmp(get(handles.FlipLR2,'checked'),'off')
	set(handles.FlipLR2,'checked','on');
else
    set(handles.FlipLR2,'checked','off');
end
handles.imaVOL2 = flipdim(handles.imaVOL2,2);
% Update handles structure
guidata(hObject, handles);
mia_gui('CurrentSliceEdit_Callback',handles.CurrentSliceEdit,[],handles);


%%  --------------------------------------------------------------------
function FlipUD2_Callback(hObject, eventdata, handles)
% hObject    handle to FlipUD2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if not(isfield(handles,'FileNames2'));return;end %return if no 1st. file was previously opened

if  strcmp(get(handles.FlipUD2,'checked'),'off')
	set(handles.FlipUD2,'checked','on');
else
    set(handles.FlipUD2,'checked','off');
end
handles.imaVOL2 = flipdim(handles.imaVOL2,1);
% Update handles structure
guidata(hObject, handles);
mia_gui('CurrentSliceEdit_Callback',handles.CurrentSliceEdit,[],handles);



%%  --------------------------------------------------------------------
function FlipFB2_Callback(hObject, eventdata, handles)
% hObject    handle to FlipFB2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if not(isfield(handles,'FileNames2'));return;end %return if no 1st. file was previously opened

if  strcmp(get(handles.FlipFB2,'checked'),'off')
	set(handles.FlipFB2,'checked','on');
else
    set(handles.FlipFB2,'checked','off');
end
handles.imaVOL2 = flipdim(handles.imaVOL2,3);
% Update handles structure
guidata(hObject, handles);
mia_gui('CurrentSliceEdit_Callback',handles.CurrentSliceEdit,[],handles);


%%  --------------------------------------------------------------------
function Reslicing_Callback(hObject, eventdata, handles)
% hObject    handle to Reslicing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%%  --------------------------------------------------------------------
function FullVolume_Callback(hObject, eventdata, handles)
% hObject    handle to FullVolume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if not(isfield(handles,'FileNames'));return;end %return if no 1st. file was previously opened
if handles.scaninfo.Frames > 1
    hm = msgbox('The is a 4D image. By! ','mia Info' );
    return;
end
if ishandle(handles.haxial2) | ishandle(handles.hsagital2) | ishandle(handles.hcoronal2)
    return; % if imaVOL2 currently resliced, function exit.
end

min_pix = get(handles.ColorBarMinSlider,'Value');
max_pix = get(handles.ColorBarMaxSlider,'Value');
SagZoomYes = 0;
WhiteBgYes = 0;
SagCorHighResYes = 0;

cmapcontents = get(handles.ColorMapPopupmenu,'String');
cmapname = cmapcontents{get(handles.ColorMapPopupmenu,'Value')};

%xysize = size(handles.imaVOL,1);
if SagZoomYes
    rectval = round(getrect(handles.ImaAxes));
    ymin=rectval(2); ymax=ymin+rectval(4); xmin=rectval(1); xmax=xmin+rectval(3);
else
    ymin=1; ymax=handles.scaninfo.imfm(1);xmin=1; xmax=handles.scaninfo.imfm(2);
end
if SagCorHighResYes
    xyres  = 2; %number of xyslices = xysize/2; slicewidth = xysize*2mm/(number of xyslices) = 4 mm  
else
    xyres  = 8; %number of xyslices = xysize/8; slicewidth = xysize*2mm/(number of xyslices) = 8 mm
end

% in case of dynamic scan load only the last "time frame" imaVOL 
if handles.scaninfo.Frames > 1 
   SlicesForLastFrame = [(handles.scaninfo.Frames-1)*handles.scaninfo.num_of_slice+1: ...
           handles.scaninfo.Frames*handles.scaninfo.num_of_slice];
   imaVOL = int16(smooth3(handles.imaVOL(:,:,SlicesForLastFrame),'gaussian'));
else
   imaVOL = handles.imaVOL;
end
[haxial, hcoronal, hsagital] = mia_imadoc(imaVOL, handles.scaninfo(1), ... 
    max_pix, min_pix, ymin, ymax, xmin, xmax, cmapname, xyres);
handles.haxial = haxial;
handles.hcoronal = hcoronal;
handles.hsagital = hsagital;

% Update handles structure
guidata(hObject, handles);


%%  --------------------------------------------------------------------
function MouseSelected_Callback(hObject, eventdata, handles)
% hObject    handle to MouseSelected (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%%  --------------------------------------------------------------------
function MIPGeneration_Callback(hObject, eventdata, handles)
% hObject    handle to MIPGeneration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if not(isfield(handles,'FileNames'));return;end %return if no 1st. file was previously opened

if handles.scaninfo.Frames > 1
    hm = msgbox('The is a 4D image. By! ','mia Info' );
    return;
end

curdir = pwd; cd(handles.dirname); 
[filename, pathname] = uiputfile('*.avi', 'Save to AVI file');
cd(curdir); 
if isequal(filename,0) | isequal(pathname,0)
   return;
end
[pathstr,filemainname,ext,vers] = fileparts(filename);
outputfilename = [pathname, filemainname,'.avi'];

SagZoomYes =0;
xysize = size(handles.imaVOL,1);
if SagZoomYes
    rectval = round(getrect(handles.ImaAxes));
    ymin=rectval(2); ymax=ymin+rectval(4); xmin=rectval(1); xmax=xmin+rectval(3);
else
    ymin=1; ymax=xysize;xmin=1; xmax=xysize;
end
cmapcontents = get(handles.ColorMapPopupmenu,'String');
cmapname = cmapcontents{get(handles.ColorMapPopupmenu,'Value')};

% in case of dynamic scan load only the last "time frame" imaVOL 
if handles.scaninfo.Frames > 1 
   SlicesForLastFrame = [(handles.scaninfo.Frames-1)*handles.scaninfo.num_of_slice+1: ...
           handles.scaninfo.Frames*handles.scaninfo.num_of_slice];
   imaVOL = int16(smooth3(handles.imaVOL(:,:,SlicesForLastFrame),'gaussian'));
else
   imaVOL = handles.imaVOL;
end

minpix = handles.VolMin;
maxpix = get(handles.ColorBarMaxSlider,'Value');

mia_doMIPavi(handles.imaVOL, handles.scaninfo, ymin, ymax, xmin, xmax,cmapname,outputfilename,minpix,maxpix);

%%  --------------------------------------------------------------------
function Reslicing2_Callback(hObject, eventdata, handles)
% hObject    handle to Reslicing2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%%  --------------------------------------------------------------------
function FullVolume2_Callback(hObject, eventdata, handles)
% hObject    handle to FullVolume2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if not(isfield(handles,'FileNames2'));return;end %return if no 1st. file was previously opened
if handles.scaninfo2.Frames > 1
    hm = msgbox('The is a 4D image. By! ','mia Info' );
    return;
end
if ishandle(handles.haxial) | ishandle(handles.hsagital) | ishandle(handles.hcoronal)
    return; % if imaVOL2 currently resliced, function exit.
end

if handles.scaninfo2.Frames > 1
    hm = msgbox('The is a 4D image. By! ','mia Info' );
    return;
end
min_pix = get(handles.ColorBarMin2Slider,'Value');
max_pix = get(handles.ColorBarMax2Slider,'Value');
SagZoomYes = 0;
SagCorHighResYes = 0;

cmapcontents = get(handles.ColorMap2Popupmenu,'String');
cmapname = cmapcontents{get(handles.ColorMap2Popupmenu,'Value')};

xysize = size(handles.imaVOL2,1);
if SagZoomYes
    rectval = round(getrect(handles.ImaAxes2));
    ymin=rectval(2); ymax=ymin+rectval(4); xmin=rectval(1); xmax=xmin+rectval(3);
else
    ymin=1; ymax=xysize;xmin=1; xmax=xysize;
end
if SagCorHighResYes
    xyres  = 2; %number of xyslices = xysize/2; slicewidth = xysize*2mm/(number of xyslices) = 4 mm  
else
    xyres  = 8; %number of xyslices = xysize/8; slicewidth = xysize*2mm/(number of xyslices) = 8 mm
end
[haxial, hcoronal, hsagital] = mia_imadoc(handles.imaVOL2, handles.scaninfo2(1), ... 
    max_pix, min_pix, ymin, ymax, xmin, xmax, cmapname, xyres);
handles.haxial = haxial;
handles.hcoronal = hcoronal;
handles.hsagital = hsagital;
% Update handles structure
guidata(hObject, handles);


%%  --------------------------------------------------------------------
function MouseSelected2_Callback(hObject, eventdata, handles)
% hObject    handle to MouseSelected2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%%  --------------------------------------------------------------------
function MIPGeneration2_Callback(hObject, eventdata, handles)
% hObject    handle to MIPGeneration2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if not(isfield(handles,'FileNames2'));return;end %return if no 1st. file was previously opened

if handles.scaninfo2.Frames > 1
    hm = msgbox('The is a 4D image. By! ','mia Info' );
    return;
end

curdir = pwd; cd(handles.dirname); 
[filename, pathname] = uiputfile('*.avi', 'Save to AVI file');
cd(curdir); 
if isequal(filename,0) | isequal(pathname,0)
   return;
end
[pathstr,filemainname,ext,vers] = fileparts(filename);
outputfilename = [pathname, filemainname,'.avi'];

SagZoomYes =0;
xysize = size(handles.imaVOL2,1);
if SagZoomYes
    rectval = round(getrect(handles.ImaAxes2));
    ymin=rectval(2); ymax=ymin+rectval(4); xmin=rectval(1); xmax=xmin+rectval(3);
else
    ymin=1; ymax=xysize;xmin=1; xmax=xysize;
end
cmapcontents = get(handles.ColorMap2Popupmenu,'String');
cmapname = cmapcontents{get(handles.ColorMap2Popupmenu,'Value')};

minpix = handles.VolMin2;
maxpix = get(handles.ColorBarMax2Slider,'Value');

mia_doMIPavi(handles.imaVOL2, handles.scaninfo2, ymin, ymax, xmin, xmax,cmapname,outputfilename,minpix,maxpix);

%%  --------------------------------------------------------------------
function Smooth3D_Callback(hObject, eventdata, handles)
% hObject    handle to Smooth3D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if not(isfield(handles,'FileNames'));return;end %return if no 1st. file was previously opened

if handles.scaninfo.Frames > 1
    hm = msgbox('The is a 4D image. By! ','mia Info' );
    return;
end
if  strcmp(get(handles.Smooth3D,'checked'),'off')
    set(handles.Smooth3D,'checked','on');
    handles.imaVOLtmp = handles.imaVOL;
    hm = msgbox('3D smoothing...','Mia Info' );
    if handles.decimal_prec == 0
        tmp = int16(smooth3(handles.imaVOL,'gaussian'));
    else
        tmp = smooth3(handles.imaVOL,'gaussian');
    end
    handles.imaVOL = tmp;
    delete(hm);
else
    set(handles.Smooth3D,'checked','off');
    handles.imaVOL = handles.imaVOLtmp;
    handles.imaVOLtmp = [];
    handles = rmfield(handles,'imaVOLtmp');
end
% Update handles structure
guidata(hObject, handles);
% Refresh the current slice
mia_gui('CurrentSliceEdit_Callback',handles.CurrentSliceEdit,[],handles);

%%  --------------------------------------------------------------------
function Smooth3D2_Callback(hObject, eventdata, handles)
% hObject    handle to Smooth3D2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if not(isfield(handles,'FileNames2'));return;end %return if no 1st. file was previously opened

if handles.scaninfo2.Frames > 1
    hm = msgbox('The is a 4D image. By! ','mia Info' );
    return;
end
if  strcmp(get(handles.Smooth3D2,'checked'),'off')
    set(handles.Smooth3D2,'checked','on');
    handles.imaVOL2tmp = handles.imaVOL2;
    hm = msgbox('3D smoothing...','Mia Info' );
    tmp = int16(smooth3(handles.imaVOL2,'gaussian'));
    handles.imaVOL2 = tmp;
    delete(hm);
else
    set(handles.Smooth3D2,'checked','off');
    handles.imaVOL2 = handles.imaVOLtmp2;
    handles.imaVOLtmp2 = [];
    handles = rmfield(handles,'imaVOL2tmp');
end
% Update handles structure
guidata(hObject, handles);
% Refresh the current slice
mia_gui('CurrentSliceEdit_Callback',handles.CurrentSliceEdit,[],handles);

%%  --------------------------------------------------------------------
function Normalization_Callback(hObject, eventdata, handles)
% hObject    handle to Normalization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if not(isfield(handles,'FileNames'));return;end %return if no 1st. file was previously opened


if  strcmp(get(handles.Normalization,'checked'),'off')
	prompt = {'Multiplification factor:'};
    dlg_title = ['Input for image rescaling'];
	%num_lines= 1;
	num_lines= [1];
    def     = {'10'};
	RescaleInStr= inputdlg(prompt,dlg_title,num_lines,def);
    
    if isempty(RescaleInStr)
        return;%return if the cancel button was pressed 
    else
        RescaleInt = str2double(RescaleInStr);
    end
    set(handles.Normalization,'checked','on');
    rescale_factor = RescaleInt(1);
    
    num_of_slice = handles.scaninfo.num_of_slice;
	imaVOLnorm = (zeros(handles.scaninfo.imfm(1),handles.scaninfo.imfm(2),num_of_slice));
    imaVOLnorm = rescale_factor * double(handles.imaVOL) ;
    
    % reset the necessary variables for image displaying
	handles.imaVOLtmpnorm = handles.imaVOL;
	handles.imaVOL =  []; handles.imaVOL = imaVOLnorm;
    handles.decimal_prec = handles.decimal_prec_default;
	handles.VolMax = double(max(handles.imaVOL(:)));
    handles.VolMin = double(min(handles.imaVOL(:)));
    handles.Framestmp = handles.scaninfo.Frames;
	handles.scaninfo.Frames = 1;
    %set the current slice and frame inexes
    handles.CurrentSlicetmp = handles.CurrentSlice;
    handles.CurrentFrametmp = handles.CurrentFrame;
	handles.CurrentFrame = 1;
    set(handles.CurrentFrameEdit,'String',handles.CurrentFrame);
    handles.CurrentImgIdxtmp = handles.CurrentImgIdx; 
	handles.CurrentImgIdx = handles.CurrentSlice;
else
    set(handles.Normalization,'checked','off');
    handles.imaVOL =  []; handles.imaVOL = handles.imaVOLtmpnorm;
    handles.imaVOLtmpnorm = [];
    handles.VolMax = double(max(handles.imaVOL(:)));
    handles.VolMin = double(min(handles.imaVOL(:)));
    if isa(handles.imaVOLtmpnorm,'int16')
    	handles.decimal_prec = 0;
    end
    handles.scaninfo.Frames = handles.Framestmp;
    handles.CurrentSlice = handles.CurrentSlicetmp;
    handles.CurrentFrame = handles.CurrentFrametmp;
    handles.CurrentImgIdx = handles.CurrentImgIdxtmp;
    set(handles.CurrentFrameEdit,'String',handles.CurrentFrame);
    set(handles.CurrentSliceEdit,'String',handles.CurrentSlice);
end

% rescale the colorbar
newlabels = num2cell(fixround(linspace(handles.VolMin,handles.VolMax,handles.NumOfYtickOfColorbar),handles.decimal_prec))';
set(handles.CmapAxes,'Yticklabel',newlabels);

% reset the ColorBar Sliders
CurrentImage = double(handles.imaVOL(:,:,handles.CurrentImgIdx));
CurrentImageMinMax = [min(CurrentImage(:)) max(CurrentImage(:)) ];
set(handles.ColorBarMaxSlider,'Min',handles.VolMin); 
set(handles.ColorBarMaxSlider,'Max',handles.VolMax);
set(handles.ColorBarMinSlider,'Min',handles.VolMin); 
set(handles.ColorBarMinSlider,'Max',handles.VolMax);
set(handles.ColorBarMaxSlider,'Value',CurrentImageMinMax(2));
set(handles.ColorBarMinSlider,'Value',CurrentImageMinMax(1));

%refresh the image
SliderPosMax = get(handles.ColorBarMaxSlider,'Value');
SliderPosMin = get(handles.ColorBarMinSlider,'Value');
CurrentImage_RGB = ImageRefresh(CurrentImage,SliderPosMax,SliderPosMin,handles.ColorRes,handles.ColormapIn1);
set(handles.ImaHandler,'CData',CurrentImage_RGB);

%Update handles structure
guidata(hObject, handles);

% Refresh the current slice
mia_gui('CurrentSliceEdit_Callback',handles.CurrentSliceEdit,[],handles);

%%  --------------------------------------------------------------------
function SUV_normalization_Callback(hObject, eventdata, handles)
% hObject    handle to SUV_normalization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if not(isfield(handles,'FileNames'));return;end %return if no 1st. file was previously opened
if handles.scaninfo.Frames > 1
    msgbox('The volume is a 4D image. By! ','mia Info' );
    return;
end

if  strcmp(get(handles.SUV_normalization,'checked'),'off')
	prompt = {'__Data for SUV calc.__ Injected Dose[mCi]:','Patient weight[kg]:' ...
            ,'isotope type (F18,C11,N13 or O15)','timediff for decaycorr.(sec)'...
            ,'Patient heigth[m] (Empty - BW norm; if not - BSA norm):'};
    dlg_title = 'Input for SUV calc.';
	num_lines= 1;
	%num_lines= [1,28;1,28;1,28;1,28;1,28];
    def     = {'10','80','F18','2400',''};
	FrameIntStr= inputdlg(prompt,dlg_title,num_lines,def);
    
    if isempty(FrameIntStr)
        return;%return if the cancel button was pressed 
    else
        FrameInt = str2double(FrameIntStr);
    end
    set(handles.SUV_normalization,'checked','on');
    injected_dose = str2double(FrameIntStr(1));%[mCi]
    bodyweight = str2double(FrameIntStr(2));%[kg]
    isotope_type =  char(FrameIntStr(3));%[F18,C11,N13 or O15]
    timediff_for_decaycorrection = str2double(FrameIntStr(4));%[sec] 
    bodyheight =  str2double(FrameIntStr(5));%[m]
    if isnan(bodyheight) | bodyheight == 0
        bodyheight = [];
    end
    imaVOLnorm = suv(handles.imaVOL, isotope_type, timediff_for_decaycorrection, ...
        injected_dose, bodyweight, bodyheight);
    if isempty(imaVOLnorm);
        disp('Error during the suv calculation!');
        return;
    end
    %
    % if scx ima was opened save the imaVOL as scx format file
    %
    if strcmp(handles.scaninfo.FileType,'vms')
        num_of_slice = 15;
        scxima_max = 32000;
        suvVOL = (flipdim(permute(imaVOLnorm,[2 1 3]),1));
        outfilename = [handles.dirname,'pc',handles.scaninfo(1).rid,'_SUV_', ...
                num2str(handles.scaninfo(1).rin),'_',num2str(handles.scaninfo(1).brn),'.ima'];
		vaxfid = fopen(outfilename,'w','vaxd');
		fwrite(vaxfid,handles.fileheader,'char');
		for j = 1 : num_of_slice
            slicemaxs(j) = max(max(suvVOL(:,:,j)));
            sliceout = round((suvVOL(:,:,j)*(scxima_max)/slicemaxs(j)));
            fwrite(vaxfid,sliceout,'ushort');
		end
		fclose(vaxfid);
		%
		% modify the CNTX and MAG mnemonics in the vax fileheader 
		%
		context = 'SUV       ';
		scxheader_edit(outfilename, context, slicemaxs);
    end
    % reset the necessary variables for image displaying
	handles.imaVOLtmpnorm = handles.imaVOL;
	handles.imaVOL =  []; handles.imaVOL = imaVOLnorm;
    handles.decimal_prec = handles.decimal_prec_default;
	handles.VolMax = double(max(handles.imaVOL(:)));
    handles.VolMin = double(min(handles.imaVOL(:)));
    handles.Framestmp = handles.scaninfo.Frames;
	handles.scaninfo.Frames = 1;
    %set the current slice and frame inexes
    handles.CurrentSlicetmp = handles.CurrentSlice;
    handles.CurrentFrametmp = handles.CurrentFrame;
	handles.CurrentFrame = 1;
    set(handles.CurrentFrameEdit,'String',handles.CurrentFrame);
    handles.CurrentImgIdxtmp = handles.CurrentImgIdx; 
	handles.CurrentImgIdx = handles.CurrentSlice;
else
    set(handles.SUV_normalization,'checked','off');
    handles.imaVOL =  []; handles.imaVOL = handles.imaVOLtmpnorm;
    handles.imaVOLtmpnorm = [];
    handles.VolMax = double(max(handles.imaVOL(:)));
    handles.VolMin = double(min(handles.imaVOL(:)));
    if isa(handles.imaVOLtmpnorm,'int16')
    	handles.decimal_prec = 0;
    end
    handles.scaninfo.Frames = handles.Framestmp;
    handles.CurrentSlice = handles.CurrentSlicetmp;
    handles.CurrentFrame = handles.CurrentFrametmp;
    handles.CurrentImgIdx = handles.CurrentImgIdxtmp;
    set(handles.CurrentFrameEdit,'String',handles.CurrentFrame);
    set(handles.CurrentSliceEdit,'String',handles.CurrentSlice);
end

% rescale the colorbar
newlabels = num2cell(fixround(linspace(handles.VolMin,handles.VolMax,handles.NumOfYtickOfColorbar),handles.decimal_prec))';
set(handles.CmapAxes,'Yticklabel',newlabels);

% reset the ColorBar Sliders
CurrentImage = double(handles.imaVOL(:,:,handles.CurrentImgIdx));
CurrentImageMinMax = [min(CurrentImage(:)) max(CurrentImage(:)) ];
set(handles.ColorBarMaxSlider,'Min',handles.VolMin); 
set(handles.ColorBarMaxSlider,'Max',handles.VolMax);
set(handles.ColorBarMinSlider,'Min',handles.VolMin); 
set(handles.ColorBarMinSlider,'Max',handles.VolMax);
set(handles.ColorBarMaxSlider,'Value',CurrentImageMinMax(2));
set(handles.ColorBarMinSlider,'Value',CurrentImageMinMax(1));

%refresh the image
SliderPosMax = get(handles.ColorBarMaxSlider,'Value');
SliderPosMin = get(handles.ColorBarMinSlider,'Value');
CurrentImage_RGB = ImageRefresh(CurrentImage,SliderPosMax,SliderPosMin,handles.ColorRes,handles.ColormapIn1);
set(handles.ImaHandler,'CData',CurrentImage_RGB);

%Update handles structure
guidata(hObject, handles);

% Refresh the current slice
mia_gui('CurrentSliceEdit_Callback',handles.CurrentSliceEdit,[],handles);



%%  --------------------------------------------------------------------
function SumFrames_Callback(hObject, eventdata, handles)
% hObject    handle to SumFrames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if not(isfield(handles,'FileNames'));return;end %return if no 1st. file was previously opened


if  strcmp(get(handles.SumFrames,'checked'),'off')
    %prompt = {'Enter the first frame number:','Enter the last frame number:' };
	prompt = {'Enter the first frame number:','Enter the last frame number:', ...
            '__Data for Normalization__ Calib (unit to nCi/ml):','Patient weight[kg]:' ...
            ,'Injected Dose[mCi]','Patient heigth[m] (Empty - BW norm; if not - BSA norm):'};
    dlg_title = ['Input for image summing /FrameMax:',num2str(handles.scaninfo.Frames),'/ '];
	%num_lines= 1;
	num_lines= [1,60;1,60;1,28;1,28;1,28;1,28];
    def     = {'1',num2str(handles.scaninfo.Frames),'1','1','1',''};
	FrameIntStr= inputdlg(prompt,dlg_title,num_lines,def);
    
    if isempty(FrameIntStr)
        return;%return if the cancel button was pressed 
    else
        FrameInt = str2double(FrameIntStr);
    end
    set(handles.SumFrames,'checked','on');
    norm_calib = FrameInt(3);
    norm_bodyweight = FrameInt(4);%[kg]
    norm_injected_dose =  FrameInt(5);%[mCi]
    norm_bodyheigth = FrameInt(6);%[m]
    
    num_of_slice = handles.scaninfo.num_of_slice;
	imaVOLsumed = (zeros(handles.scaninfo.imfm(1),handles.scaninfo.imfm(2),num_of_slice));
    % set up "frame time matrix" for time weighted image summing 
    for i=1:FrameInt(2)-FrameInt(1)+1
        ft_mat(:,:,i) = ones(handles.scaninfo.imfm(1),handles.scaninfo.imfm(2)) ...
            *handles.scaninfo.frame_lengths(FrameInt(1) + i-1);
    end
    % framelength weighted sum for selected frames 
    sumFrameLenghts = sum(handles.scaninfo.frame_lengths(FrameInt(1):FrameInt(2)));
	for i=1:num_of_slice
		CurrentSlices = [(FrameInt(1)-1)*num_of_slice + i: num_of_slice :(FrameInt(2)-1)*num_of_slice + i]; 
		imaVOLsumed(:,:,i) = sum( double(handles.imaVOL(:,:,CurrentSlices)).*ft_mat , 3) / sumFrameLenghts;
	end
    % BSA = (W^0.425 x H^0.725) x 0.007184
    % BSA = (norm_bodyweight^0.425 * norm_bodyheigth^0.725)*0.007184;
    % imaVOLsumed = norm_calib * imaVOLsumed * BSA/norm_injected_dose*1/1000; % calib, injected activity and BSA normalization
    if isnan(norm_bodyheigth) 
        imaVOLsumed = norm_calib * imaVOLsumed * norm_bodyweight/norm_injected_dose*1/1000; % calib, injected activity and BW normalization
    else
        imaVOLsumed = norm_calib * imaVOLsumed * BSA/norm_injected_dose; % calib, injected activity and BSA normalization
    end
    % reset the necessary variables for image displaying
	handles.imaVOLtmp = handles.imaVOL;
	handles.imaVOL =  []; handles.imaVOL = imaVOLsumed;
    handles.decimal_prec = handles.decimal_prec_default;
	handles.VolMax = double(max(handles.imaVOL(:)));
    handles.VolMin = double(min(handles.imaVOL(:)));
    handles.Framestmp = handles.scaninfo.Frames;
	handles.scaninfo.Frames = 1;
    %set the current slice and frame inexes
    handles.CurrentSlicetmp = handles.CurrentSlice;
    handles.CurrentFrametmp = handles.CurrentFrame;
	handles.CurrentFrame = 1;
    set(handles.CurrentFrameEdit,'String',handles.CurrentFrame);
    handles.CurrentImgIdxtmp = handles.CurrentImgIdx; 
	handles.CurrentImgIdx = handles.CurrentSlice;
else
    set(handles.SumFrames,'checked','off');
    handles.imaVOL =  []; handles.imaVOL = handles.imaVOLtmp;
    handles.imaVOLtmp = [];
    handles.VolMax = double(max(handles.imaVOL(:)));
    handles.VolMin = double(min(handles.imaVOL(:)));
    if isa(handles.imaVOLtmp,'int16')
    	handles.decimal_prec = 0;
    end
    handles.scaninfo.Frames = handles.Framestmp;
    handles.CurrentSlice = handles.CurrentSlicetmp;
    handles.CurrentFrame = handles.CurrentFrametmp;
    handles.CurrentImgIdx = handles.CurrentImgIdxtmp;
    set(handles.CurrentFrameEdit,'String',handles.CurrentFrame);
    set(handles.CurrentSliceEdit,'String',handles.CurrentSlice);
end

% rescale the colorbar
newlabels = num2cell(fixround(linspace(handles.VolMin,handles.VolMax,handles.NumOfYtickOfColorbar),handles.decimal_prec))';
set(handles.CmapAxes,'Yticklabel',newlabels);

% reset the ColorBar Sliders
CurrentImage = double(handles.imaVOL(:,:,handles.CurrentImgIdx));
CurrentImageMinMax = [min(CurrentImage(:)) max(CurrentImage(:)) ];
set(handles.ColorBarMaxSlider,'Min',handles.VolMin); 
set(handles.ColorBarMaxSlider,'Max',handles.VolMax);
set(handles.ColorBarMinSlider,'Min',handles.VolMin); 
set(handles.ColorBarMinSlider,'Max',handles.VolMax);
set(handles.ColorBarMaxSlider,'Value',CurrentImageMinMax(2));
set(handles.ColorBarMinSlider,'Value',CurrentImageMinMax(1));

%refresh the image
SliderPosMax = get(handles.ColorBarMaxSlider,'Value');
SliderPosMin = get(handles.ColorBarMinSlider,'Value');
CurrentImage_RGB = ImageRefresh(CurrentImage,SliderPosMax,SliderPosMin,handles.ColorRes,handles.ColormapIn1);
set(handles.ImaHandler,'CData',CurrentImage_RGB);

%Update handles structure
guidata(hObject, handles);

% Refresh the current slice
mia_gui('CurrentSliceEdit_Callback',handles.CurrentSliceEdit,[],handles);


%%  --------------------------------------------------------------------
function SaveAsMinc_Callback(hObject, eventdata, handles)
% hObject    handle to SaveAsMinc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if not(isfield(handles,'FileNames'));return;end %return if no 1st. file was previously opened

curdir = pwd; cd(handles.dirname); 
[filename, pathname] = uiputfile('*.mnc', 'Pick a minc-file');
cd(curdir); 
if isequal(filename,0) | isequal(pathname,0)
   return;
end

[pathstr,filemainname,ext,vers] = fileparts(filename);
outputfilename = [pathname, filemainname,'.mnc'];
% if the file is already exists it need to delete 
dirres = dir(outputfilename);
if ~isempty(dirres)
%     questdlgres = questdlg(['The ',outputfilename, ' is already exists. Do you really overwrite it?'], ...
%         'Pick a mnc file','Yes','No','default');
%     if strcomp(questdlgres,'No')
%         wresult = 0;
%         return;
%     end
    delete(outputfilename);
end


% set the cursor type to watch
SetData=setptr('watch');set(handles.mia_figure1,SetData{:});drawnow;

wresult = saveminc(outputfilename,handles.imaVOL,handles.scaninfo);

% set back the cursor type to arrow
SetData=setptr('arrow');set(handles.mia_figure1,SetData{:});

if wresult ~= 0
    hm = msgbox('Error on file saving. See the Matlab command window for details.','mia Info' );
end


%% --------------------------------------------------------------------
function SaveAsDicom_Callback(hObject, eventdata, handles)
% hObject    handle to SaveAsDicom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if not(isfield(handles,'FileNames'));return;end %return if no 1st. file was previously opened

curdir = pwd; cd(handles.dirname); 
[filename, pathname] = uiputfile('*.dcm', 'Pick a minc-file');
cd(curdir); 
if isequal(filename,0) | isequal(pathname,0)
   return;
end
[pathstr,filemainname,ext,vers] = fileparts(filename);
outputfilename = [pathname, filemainname,'.dcm'];
% set the cursor type to watch
SetData=setptr('watch');set(handles.mia_figure1,SetData{:});drawnow;

wresult = savedcm(outputfilename,handles.imaVOL,handles.scaninfo);

% set back the cursor type to arrow
SetData=setptr('arrow');set(handles.mia_figure1,SetData{:});

if wresult ~= 0
    hm = msgbox('Error on file saving. See the Matlab command window for details.','mia Info' );
end

%% --------------------------------------------------------------------
function SaveAsAnalyze_Callback(hObject, eventdata, handles)
% hObject    handle to SaveAsAnalyze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if not(isfield(handles,'FileNames'));return;end %return if no 1st. file was previously opened

curdir = pwd; cd(handles.dirname); 
[filename, pathname] = uiputfile('*.img', 'Pick a minc-file');
cd(curdir); 
if isequal(filename,0) | isequal(pathname,0)
   return;
end
[pathstr,filemainname,ext,vers] = fileparts(filename);
outputfilename = [pathname, filemainname,'.img'];

% set the cursor type to watch
SetData=setptr('watch');set(handles.mia_figure1,SetData{:});drawnow;

if handles.scaninfo.float
    precision = 32;
    wresult = saveanalyze(outputfilename,handles.imaVOL,handles.scaninfo,precision);
else
    wresult = saveanalyze(outputfilename,handles.imaVOL,handles.scaninfo);
end

% set back the cursor type to arrow
SetData=setptr('arrow');set(handles.mia_figure1,SetData{:});

if wresult ~= 0
    hm = msgbox('Error on file saving. See the Matlab command window for details.','mia Info' );
end


%% --------------------------------------------------------------------
function SaveAsEcat7_Callback(hObject, eventdata, handles)
% hObject    handle to SaveAsEcat7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if not(isfield(handles,'FileNames'));return;end %return if no 1st. file was previously opened

curdir = pwd; cd(handles.dirname); 
[filename, pathname] = uiputfile('*.v', 'Pick an ecat7 file');
cd(curdir); 
if isequal(filename,0) | isequal(pathname,0)
   return;
end
[pathstr,filemainname,ext,vers] = fileparts(filename);
outputfilename = [pathname, filemainname,'.v'];

% set the cursor type to watch
SetData=setptr('watch');set(handles.mia_figure1,SetData{:});drawnow;

wresult = saveecat(outputfilename,handles.imaVOL,handles.scaninfo);

% set back the cursor type to arrow
SetData=setptr('arrow');set(handles.mia_figure1,SetData{:});

if wresult ~= 0
    hm = msgbox('Error on file saving. See the Matlab command window for details.','mia Info' );
end


%% --------------------------------------------------------------------
function SaveAsMat_Callback(hObject, eventdata, handles)
% hObject    handle to SaveAsMat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if not(isfield(handles,'FileNames'));return;end %return if no 1st. file was previously opened

curdir = pwd; cd(handles.dirname); 
[filename, pathname] = uiputfile('*.mat', 'Pick a mat file');
cd(curdir); 
if isequal(filename,0) | isequal(pathname,0)
   return;
end
[pathstr,filemainname,ext,vers] = fileparts(filename);
outputfilename = [pathname, filemainname,'.mat'];

% set the cursor type to watch
SetData=setptr('watch');set(handles.mia_figure1,SetData{:});drawnow;

wresult = savemat(outputfilename,handles.imaVOL,handles.scaninfo);

% set back the cursor type to arrow
SetData=setptr('arrow');set(handles.mia_figure1,SetData{:});

if wresult ~= 0
    hm = msgbox('Error on file saving. See the Matlab command window for details.','mia Info' );
end



%% --------------------------------------------------------------------
function SaveAsMinc2_Callback(hObject, eventdata, handles)
% hObject    handle to SaveAsMinc2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if not(isfield(handles,'FileNames2'));return;end %return if no 1st. file was previously opened

curdir = pwd; cd(handles.dirname2); 
[filename, pathname] = uiputfile('*.mnc', 'Pick a minc-file');
cd(curdir); 
if isequal(filename,0) | isequal(pathname,0)
   return;
end
[pathstr,filemainname,ext,vers] = fileparts(filename);
outputfilename = [pathname, filemainname,'.mnc'];

% set the cursor type to watch
SetData=setptr('watch');set(handles.mia_figure1,SetData{:});drawnow;

wresult = saveminc(outputfilename,handles.imaVOL2,handles.scaninfo2);

% set back the cursor type to arrow
SetData=setptr('arrow');set(handles.mia_figure1,SetData{:});

if wresult ~= 0
    hm = msgbox('Error on file saving. See the Matlab command window for details.','mia Info' );
end

%% --------------------------------------------------------------------
function SaveAsDicom2_Callback(hObject, eventdata, handles)
% hObject    handle to SaveAsDicom2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if not(isfield(handles,'FileNames2'));return;end %return if no 1st. file was previously opened

curdir = pwd; cd(handles.dirname2); 
[filename, pathname] = uiputfile('*.dcm', 'Pick a minc-file');
cd(curdir); 
if isequal(filename,0) | isequal(pathname,0)
   return;
end
[pathstr,filemainname,ext,vers] = fileparts(filename);
outputfilename = [pathname, filemainname,'.dcm'];
% set the cursor type to watch
SetData=setptr('watch');set(handles.mia_figure1,SetData{:});drawnow;

wresult = savedcm(outputfilename,handles.imaVOL2,handles.scaninfo2);

% set back the cursor type to arrow
SetData=setptr('arrow');set(handles.mia_figure1,SetData{:});

if wresult ~= 0
    hm = msgbox('Error on file saving. See the Matlab command window for details.','mia Info' );
end


%% --------------------------------------------------------------------
function SaveAsAnalyze2_Callback(hObject, eventdata, handles)
% hObject    handle to SaveAsAnalyze2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if not(isfield(handles,'FileNames2'));return;end %return if no 1st. file was previously opened

curdir = pwd; cd(handles.dirname2); 
[filename, pathname] = uiputfile('*.img', 'Pick a minc-file');
cd(curdir); 
if isequal(filename,0) | isequal(pathname,0)
   return;
end
[pathstr,filemainname,ext,vers] = fileparts(filename);
outputfilename = [pathname, filemainname,'.img'];

% set the cursor type to watch
SetData=setptr('watch');set(handles.mia_figure1,SetData{:});drawnow;

wresult = saveanalyze(outputfilename,handles.imaVOL2,handles.scaninfo2);

% set back the cursor type to arrow
SetData=setptr('arrow');set(handles.mia_figure1,SetData{:});

if wresult ~= 0
    hm = msgbox('Error on file saving. See the Matlab command window for details.','mia Info' );
end


%% --------------------------------------------------------------------
function SaveAsEcat7_2_Callback(hObject, eventdata, handles)
% hObject    handle to SaveAsEcat7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if not(isfield(handles,'FileNames2'));return;end %return if no 1st. file was previously opened

curdir = pwd; cd(handles.dirname2); 
[filename, pathname] = uiputfile('*.v', 'Pick an ecat7 file');
cd(curdir); 
if isequal(filename,0) | isequal(pathname,0)
   return;
end
[pathstr,filemainname,ext,vers] = fileparts(filename);
outputfilename = [pathname, filemainname,'.v'];

% set the cursor type to watch
SetData=setptr('watch');set(handles.mia_figure1,SetData{:});drawnow;

wresult = saveecat(outputfilename,handles.imaVOL2,handles.scaninfo2);

% set back the cursor type to arrow
SetData=setptr('arrow');set(handles.mia_figure1,SetData{:});

if wresult ~= 0
    hm = msgbox('Error on file saving. See the Matlab command window for details.','mia Info' );
end


%% --------------------------------------------------------------------
function SaveAsMat2_Callback(hObject, eventdata, handles)
% hObject    handle to SaveAsMat_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if not(isfield(handles,'FileNames2'));return;end %return if no 1st. file was previously opened

curdir = pwd; cd(handles.dirname); 
[filename, pathname] = uiputfile('*.mat', 'Pick a mat file');
cd(curdir); 
if isequal(filename,0) | isequal(pathname,0)
   return;
end
[pathstr,filemainname,ext,vers] = fileparts(filename);
outputfilename = [pathname, filemainname,'.mat'];

% set the cursor type to watch
SetData=setptr('watch');set(handles.mia_figure1,SetData{:});drawnow;

wresult = savemat(outputfilename,handles.imaVOL2,handles.scaninfo2);

% set back the cursor type to arrow
SetData=setptr('arrow');set(handles.mia_figure1,SetData{:});

if wresult ~= 0
    hm = msgbox('Error on file saving. See the Matlab command window for details.','mia Info' );
end


%% --- Executes on button press in SliceomaticPushbutton.
function SliceomaticPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SliceomaticPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if not(isfield(handles,'FileNames'));return;end %return if no 1st. file was previously opened

if ishandle(handles.sliceomatic_haxmain);return;end  %return if sliceomatic figure is being opened

%if hardware opengl processing was turn out at startup
%this should turn back for sliceomatic  
if handles.openglinfo.UseGenericOpenGL == 1;
    feature('UseGenericOpenGL',0);
end

% in case of dynamic scan load only the last "time frame" imaVOL 
if handles.scaninfo.Frames > 1 
   SlicesForLastFrame = [(handles.scaninfo.Frames-1)*handles.scaninfo.num_of_slice+1: ...
           handles.scaninfo.Frames*handles.scaninfo.num_of_slice];
   imaVOL = int16(smooth3(handles.imaVOL(:,:,SlicesForLastFrame),'gaussian'));
else
   imaVOL = handles.imaVOL;
end

scaninfo_plus = handles.scaninfo;
cmapcontents = get(handles.ColorMapPopupmenu,'String');
scaninfo_plus.colormap = cmapcontents{get(handles.ColorMapPopupmenu,'Value')};;
scaninfo_plus.UseGenericOpenGL = handles.openglinfo.UseGenericOpenGL;

sliceomatic_mia(double(imaVOL),scaninfo_plus);
handles.sliceomatic_haxmain = findall(gcf,'tag','axmain');
SliderPosMax = get(handles.ColorBarMaxSlider,'Value');
SliderPosMin = get(handles.ColorBarMinSlider,'Value');
set(handles.sliceomatic_haxmain,'CLim',[SliderPosMin SliderPosMax]);
% Update handles structure
guidata(hObject, handles);

%% --- Executes on button press in Sliceomatic2Pushbutton.
function Sliceomatic2Pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Sliceomatic2Pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if not(isfield(handles,'FileNames2'));return;end %return if no 1st. file was previously opened

if ishandle(handles.sliceomatic_haxmain);return;end  %return if sliceomatic figure is being opened

% in case of dynamic scan load only the last "time frame" imaVOL 
if handles.scaninfo2.Frames > 1 
   SlicesForLastFrame = [(handles.scaninfo2.Frames-1)*handles.scaninfo.num_of_slice2+1: ...
           handles.scaninfo2.Frames*handles.scaninfo2.num_of_slice];
   imaVOL = int16(smooth3(handles.imaVOL2(:,:,SlicesForLastFrame),'gaussian'));
else
   imaVOL = handles.imaVOL2;
end
scaninfo2_plus = handles.scaninfo2;
cmapcontents = get(handles.ColorMap2Popupmenu,'String');
scaninfo2_plus.colormap = cmapcontents{get(handles.ColorMap2Popupmenu,'Value')};;
scaninfo2_plus.UseGenericOpenGL = handles.openglinfo.UseGenericOpenGL;

sliceomatic_mia(double(imaVOL),scaninfo2_plus);
handles.sliceomatic_haxmain = findall(gcf,'tag','axmain');
SliderPosMax = get(handles.ColorBarMaxSlider,'Value');
SliderPosMin = get(handles.ColorBarMinSlider,'Value');
set(handles.sliceomatic_haxmain,'CLim',[SliderPosMin SliderPosMax]);

% Update handles structure
guidata(hObject, handles);


%% --- Object to Target Volume Transformation
function object_out = PutIntoSameVoxelSpace(target,targetpixsize,object,objectpixsize, Fig_handle)
%%%%% The object image is the one that gets the manipulations done to it:
%%%%% The object image gets resampled so that it lies in the same voxel
%%%%% space as the target image.
%%%%% originally Written by Rajeev Raizada, May 20, 2003.
%%%%% raj@nmr.mgh.harvard.edu

% set the cursor type to watch
hm = msgbox('Transformation in progress...','mia Info' );
SetData=setptr('watch');set(hm,SetData{:});
hmc = (get(hm,'children'));
set(hmc(2),'enable','off');
pause(0.5);

M_target = diag([targetpixsize 1]);
M_object = diag([objectpixsize 1]);

%  These simply contain 4x4 affine transformation matrixes mapping from
%  the voxel coordinates (x0,y0,z0) (where the first voxel is at coordinate
%  (1,1,1)), to coordinates in millimeters (x1,y1,z1).  By default, the
%  the new coordinate system is derived from the `origin' and `vox' fields
%  of the image header.
%   
%  x1 = M(1,1)*x0 + M(1,2)*y0 + M(1,3)*z0 + M(1,4)
%  y1 = M(2,1)*x0 + M(2,2)*y0 + M(2,3)*z0 + M(2,4)
%  z1 = M(3,1)*x0 + M(3,2)*y0 + M(3,3)*z0 + M(3,4)
% 
%  Assuming that image1 has a transformation matrix M1, and image2 has a
%  transformation matrix M2, the mapping from image1 to image2 is: M2\M1
%  (ie. from the coordinate system of image1 into millimeters, followed
%  by a mapping from millimeters into the space of image2).

%%% Find the part of the object image that corresponds to the target image,
%%% (which might involve extending the object image, if the target is bigger)
%%% and interp the object image to have the same resolution as the target

for dim = 1:3,
  
  %%%% In order to interpolate the object image into the target space,
  %%%% we have to figure out which parts of the object image
  %%%% correspond to the target image.
  %%%% If the target image is bigger, then these parts may extend 
  %%%% beyond the current range of the object image.
  %%%% To find these parts, we need to figure out what voxels
  %%%% in the object-image's space would get taken up by the target
  %%%% image, if we put the target into the object's space.
  %%%% First, we find the range in voxels with respect to
  %%%% the origin the the target image spans,
  %%%% then we convert this range into millimeters, so that we can directly
  %%%% compare its range to that of the object image.
  target_vox_size_in_this_dim = M_target(dim,dim);
  
  %%%% Find out which voxel-number is where the origin is
  target_vox_origin = -M_target(dim,4) / target_vox_size_in_this_dim;
  
  %%%% Find out how many voxels the target image has either side of origin
  target_vox_range_wrt_origin = [ 1 size(target,dim) ] - target_vox_origin;
  
  %%%% Turn this voxel-range into millimeters
  target_range_in_mm = ...
        target_vox_range_wrt_origin * target_vox_size_in_this_dim;
 
  %%%% We know the range in mm that the target image spans in this dim,
  %%%% and this will be the same as the range in mm that it spans in 
  %%%% the space of the object image.
  %%%% So, we need to work out the range in object-space voxels that
  %%%% the target image will span when it gets put into object space.
  object_vox_size_in_this_dim = M_object(dim,dim);
  object_vox_origin = -M_object(dim,4) / object_vox_size_in_this_dim;

  target_range_in_object_vox_wrt_origin = ...
      target_range_in_mm / object_vox_size_in_this_dim;

  target_range_in_object_voxspace = target_range_in_object_vox_wrt_origin ...
                                      + object_vox_origin;
  
  %%%% Now we know the range that the object image needs to span
  %%%% in order for it to fit the target space.
  %%%% All we need now, in order to be able to interpolate the object
  %%%% image into the target space, is the ratio of the voxel sizes
  target_object_size_ratio = ...
      target_vox_size_in_this_dim / object_vox_size_in_this_dim;
 
  %%%% For the interp3 command, we'll make three vectors called
  %%%% range_to_send_object_into1,2,3, one for each dimension.
  %%%% These span the range of the target image in the object space,
  %%%% and go up in steps of target_object_size_ratio
  eval(['range_to_send_object_into' num2str(dim) ...
        ' = [ target_range_in_object_voxspace(1): ' ...
        '     target_object_size_ratio : ' ...
        '     target_range_in_object_voxspace(2)];']);
  
end;

%%% Now we can do the interpolation.
%%% Note that interp3 will put NaN in places where the 
%%% interped object extends beyond the range of the original
%%% object image.
%%% Note that interp3 works in x and y coords, not rows and cols,
%%% hence the orders of the first two interp vecs are switched.

object_out = ...
    interp3(double(flipdim(object,1)),range_to_send_object_into2, ...
                   range_to_send_object_into1', ...
                   range_to_send_object_into3);
object_out = flipdim(int16( object_out ),1);              

% delete the info windows
delete(hm);

%% --------------------------------------------------------------------
function CopyFigureMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CopyFigureMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if not(isfield(handles,'FileNames'));return;end %return if no 1st. file was previously opened

% get the curent colormap name 
cmapcontents = get(handles.ColorMapPopupmenu,'String');
cmapname = cmapcontents{get(handles.ColorMapPopupmenu,'Value')};

copyobj(handles.ImaAxes,figure);
set(gca,'pos',[.1 .1 .9 .8]);
colormap(cmapname);


% unset and set some propertes on the copied axe
set(gca,'tag','ImaAxesCopied');
mih = findobj(gca,'tag','MainImage');
set(mih,'ButtonDownFcn','');
set(mih,'tag','MainImageCopied');
global gVOIpixval;
set(mih,'cdata',gVOIpixval.CurrentImage);
set(mih,'CDataMapping','scaled');

colormap(cmapname);
%% --------------------------------------------------------------------
function valout = fixround(valin,precision)
% simple rounding function to cut off the necessary decimal digits
valout = round(valin*10^precision)/10^precision; 

%% --------------------------------------------------------------------
function miaControlSetup(valin,handles)
% 
if valin == 1
    set(handles.TransparencySlider,'enable','on');
    set(handles.ColorMap2Popupmenu,'enable','on');
    set(handles.ColorBarMax2Slider,'enable','on');
    set(handles.ColorBarMin2Slider,'enable','on');
    %set(handles.ThreeDcursor2togglebutton,'enable','on');
    % set the menu items
    set(handles.Tools2menu,'enable','on');
elseif valin == 0
    set(handles.ThreeDcursortogglebutton,'enable','on');
    set(handles.ThreeDrenderingpushbutton,'enable','on');
    set(handles.SliceomaticPushbutton,'enable','on');
    set(handles.SliceSlider,'enable','on');
    % set the menu items
    set(handles.Tools2menu,'enable','off');
elseif valin == 2
    set(handles.TransparencySlider,'enable','off');
    set(handles.ColorMap2Popupmenu,'enable','off');
    set(handles.ColorBarMax2Slider,'enable','off');
    set(handles.ColorBarMin2Slider,'enable','off');
    %set(handles.ThreeDcursor2togglebutton,'enable','off');
    set(handles.ThreeDcursortogglebutton,'enable','off');
    set(handles.ThreeDrenderingpushbutton,'enable','off');
    set(handles.SliceomaticPushbutton,'enable','off');
    set(handles.SliceSlider,'enable','off');
    % set the menu items
    set(handles.Tools2menu,'enable','off');
end

%% --------------------------------------------------------------------
function SaveDynFramesAsAvi_Callback(hObject, eventdata, handles)
% hObject    handle to SaveDynFramesAsAvi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if not(isfield(handles,'FileNames'));return;end %return if no 1st. file was previously opened

curdir = pwd;
cd(handles.dirname);
[FilesSelected, dir_path] = uiputfile('*.avi','Select AVI file');
cd(curdir);
if isequal(FilesSelected,0)
    return;
end

%set up the avi file
AviName = [dir_path, char(FilesSelected)];
if handles.scaninfo.frame_lengths(1) > 1 %sec
   pausetime = 1;
else 
   pausetime = handles.scaninfo.frame_lengths(1);
end
fps_val= 1/pausetime; 
mov = avifile(AviName,'fps',fps_val,'compression','Indeo5');
% set up the Movie Figure
cmapcontents = get(handles.ColorMapPopupmenu,'String');
cmapname = cmapcontents{get(handles.ColorMapPopupmenu,'Value')};
fh = figure('name','MIA: Save Frame Movie as Avi','NumberTitle','off'); 
map = colormap(cmapname); ih = imagesc(handles.imaVOL(:,:,1));
axis off;
PlotBAspectRatio = [handles.scaninfo.imfm(2) * handles.scaninfo.pixsize(2) ... 
        handles.scaninfo.imfm(1)*handles.scaninfo.pixsize(1) 1];
set(get(ih, 'Parent'),'PlotBoxAspectRatio',PlotBAspectRatio);
set(ih,'EraseMode','xor');

for i=1:handles.scaninfo.Frames
    set(ih,'CData',handles.imaVOL(:,:,i));
    drawnow;
    FR = getframe(get(ih, 'Parent'));
    mov = addframe(mov,FR);
end
mov = close(mov);
delete(fh);
set(handles.ImaAxes,'selected','on');

%% --------------------------------------------------------------------
function DynFrameMovie_Callback(hObject, eventdata, handles)
% hObject    handle to DynFrameMovie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if not(isfield(handles,'FileNames'));return;end %return if no 1st. file was previously opened

if strcmp(get(handles.DynFrameMovie,'checked'),'off')
    set(handles.DynFrameMovie,'checked','on'); 
    % set up the Movie Figure
    cmapcontents = get(handles.ColorMapPopupmenu,'String');
    cmapname = cmapcontents{get(handles.ColorMapPopupmenu,'Value')};
    fh = figure('name','MIA Frame Movie','NumberTitle','off'); 
    map = colormap(cmapname); ih = imagesc(handles.imaVOL(:,:,1));
    axis off;
    PlotBAspectRatio = [handles.scaninfo.imfm(2) * handles.scaninfo.pixsize(2) ... 
            handles.scaninfo.imfm(1)*handles.scaninfo.pixsize(1) 1];
    set(get(ih, 'Parent'),'PlotBoxAspectRatio',PlotBAspectRatio);
    set(ih,'EraseMode','xor');
    % run the movie 10X
    for j=1:10
		for i=1:handles.scaninfo.Frames
           if ~ishandle(fh)
               set(handles.DynFrameMovie,'checked','off'); 
               set(handles.ImaAxes,'selected','on');
               return;
           end 
           if strcmp(get(handles.DynFrameMovie,'checked'),'off')
                break;
           end
           set(ih,'CData',handles.imaVOL(:,:,i));
           if handles.scaninfo.frame_lengths(i) > 1 %sec
               pausetime = 1;
           else 
               pausetime = handles.scaninfo.frame_lengths(i);
           end
           pause(pausetime);
           drawnow;
		end
    end
    delete(fh);
else
    set(handles.DynFrameMovie,'checked','off'); 
    set(handles.ImaAxes,'selected','on');
end
set(handles.DynFrameMovie,'checked','off'); 
set(handles.ImaAxes,'selected','on');

%redraw the ROI if exist on the current slide
for j=1:handles.ROINumOfColor
	if ~isempty(handles.Lines(handles.CurrentSlice,j).lh)
        set(handles.Lines(handles.CurrentSlice,j).lh,'visible','on');    
	end
end
% Update handles structure
guidata(hObject, handles);


%% --- Executes on button press in RoiColor1ToggleButton.
function RoiColor1ToggleButton_Callback(hObject, eventdata, handles)
% hObject    handle to RoiColor1ToggleButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
j = 1;
for i=1:handles.ROINumOfColor
    eval(['set(handles.RoiColor',int2str(i),'ToggleButton,''value'',0);']);% red ROI color on
end
eval(['set(handles.RoiColor',int2str(j),'ToggleButton,''value'',1);']);
handles.CurrentROIColor = j;
guidata(hObject, handles);

%% --- Executes on button press in RoiColor2ToggleButton.
function RoiColor2ToggleButton_Callback(hObject, eventdata, handles)
% hObject    handle to RoiColor2ToggleButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
j = 2;
for i=1:handles.ROINumOfColor
    eval(['set(handles.RoiColor',int2str(i),'ToggleButton,''value'',0);']);% red ROI color on
end
eval(['set(handles.RoiColor',int2str(j),'ToggleButton,''value'',1);']);
handles.CurrentROIColor = j;
guidata(hObject, handles);

%% --- Executes on button press in RoiColor3ToggleButton.
function RoiColor3ToggleButton_Callback(hObject, eventdata, handles)
% hObject    handle to RoiColor3ToggleButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
j = 3;
for i=1:handles.ROINumOfColor
    eval(['set(handles.RoiColor',int2str(i),'ToggleButton,''value'',0);']);% red ROI color on
end
eval(['set(handles.RoiColor',int2str(j),'ToggleButton,''value'',1);']);
handles.CurrentROIColor = j;
guidata(hObject, handles);

%% --- Executes on button press in RoiColor4ToggleButton.
function RoiColor4ToggleButton_Callback(hObject, eventdata, handles)
% hObject    handle to RoiColor4ToggleButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
j = 4;
for i=1:handles.ROINumOfColor
    eval(['set(handles.RoiColor',int2str(i),'ToggleButton,''value'',0);']);% red ROI color on
end
eval(['set(handles.RoiColor',int2str(j),'ToggleButton,''value'',1);']);
handles.CurrentROIColor = j;
guidata(hObject, handles);

%% --- Executes on button press in RoiColor5ToggleButton.
function RoiColor5ToggleButton_Callback(hObject, eventdata, handles)
% hObject    handle to RoiColor5ToggleButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
j = 5;
for i=1:handles.ROINumOfColor
    eval(['set(handles.RoiColor',int2str(i),'ToggleButton,''value'',0);']);% red ROI color on
end
eval(['set(handles.RoiColor',int2str(j),'ToggleButton,''value'',1);']);
handles.CurrentROIColor = j;
guidata(hObject, handles);

%% --- Executes on button press in RoiColor6ToggleButton.
function RoiColor6ToggleButton_Callback(hObject, eventdata, handles)
% hObject    handle to RoiColor6ToggleButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
j = 6;
for i=1:handles.ROINumOfColor
    eval(['set(handles.RoiColor',int2str(i),'ToggleButton,''value'',0);']);% red ROI color on
end
eval(['set(handles.RoiColor',int2str(j),'ToggleButton,''value'',1);']);
handles.CurrentROIColor = j;
guidata(hObject, handles);

%% --- Executes on button press in RoiColor7ToggleButton.
function RoiColor7ToggleButton_Callback(hObject, eventdata, handles)
% hObject    handle to RoiColor7ToggleButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
j = 7;
for i=1:handles.ROINumOfColor
    eval(['set(handles.RoiColor',int2str(i),'ToggleButton,''value'',0);']);% red ROI color on
end
eval(['set(handles.RoiColor',int2str(j),'ToggleButton,''value'',1);']);
handles.CurrentROIColor = j;
guidata(hObject, handles);

%% --- Executes on button press in RoiColor8ToggleButton.
function RoiColor8ToggleButton_Callback(hObject, eventdata, handles)
% hObject    handle to RoiColor8ToggleButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
j = 8;
for i=1:handles.ROINumOfColor
    eval(['set(handles.RoiColor',int2str(i),'ToggleButton,''value'',0);']);% red ROI color on
end
eval(['set(handles.RoiColor',int2str(j),'ToggleButton,''value'',1);']);
handles.CurrentROIColor = j;
guidata(hObject, handles);




%% --------------------------------------------------------------------
function FileInfoMain_Callback(hObject, eventdata, handles)
% hObject    handle to FileInfoMain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%% --------------------------------------------------------------------
function FileInfo1stImage_Callback(hObject, eventdata, handles)
% hObject    handle to FileInfo1stImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if not(isfield(handles,'FileNames'));return;end %return if no 1st. file was previously opened
global dcminfo_ForCurrentSlice ecatinfo_ForCurrentImage;

if strcmp(handles.scaninfo.FileType,'dcm')
    if size(handles.FileNames,1) > 1
        filename = [handles.dirname,char(handles.FileNames(handles.scaninfo.ImgIdx2FileIdx(handles.CurrentImgIdx)))];
    else
        filename = [handles.dirname,char(handles.FileNames)];
    end
    dcminfo_ForCurrentSlice = dicominfo(filename);
    openvar('dcminfo_ForCurrentSlice');
elseif strcmp(handles.scaninfo.FileType,'ecat7')
    ecatinfo_ForCurrentImage = handles.ecatinfo;
    openvar('ecatinfo_ForCurrentImage');
else 
    scaninfo_cell = struct2cell(handles.scaninfo);
    scaninfo_fnames = fieldnames(handles.scaninfo);
    scaninfo_cellout = scaninfo_cell;
    num_of_field = size(scaninfo_fnames,1);
    for i= 1:num_of_field
        scaninfo_cellout{i} = [scaninfo_fnames{i},' : ',num2str(scaninfo_cell{i})];
    end

    if isempty(findobj('name','FileInfo: 1stImage'))
        roistatfh = figure('menubar','none','NumberTitle','off','name','FileInfo: 1stImage');
        lbh = uicontrol('Style','listbox','Position',[10 10 520 400],'tag','FileInfo1stImageLB');
        set(lbh,'string',scaninfo_cellout);
    else
        roistatfh = findobj('name','FileInfo: 1stImage');
        figure(roistatfh);
        lbh = findobj('tag','FileInfo1stImageLB');
        set(lbh,'string',scaninfo_cellout);
    end
end

%% --------------------------------------------------------------------
function FileInfo2stImage_Callback(hObject, eventdata, handles)
% hObject    handle to FileInfo2stImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if not(isfield(handles,'FileNames2'));return;end %return if no 1st. file was previously opened

global dcminfo_ForCurrentSlice ecatinfo_ForCurrentImage;

if strcmp(handles.scaninfo2.FileType,'dcm')
    if size(handles.FileNames,1) > 1
        filename = [handles.dirname2,char(handles.FileNames2(handles.CurrentSlice))];
    else
        filename = [handles.dirname2,char(handles.FileNames2)];
    end
    dcminfo_ForCurrentSlice = dicominfo(filename);
    openvar('dcminfo_ForCurrentSlice');
elseif strcmp(handles.scaninfo.FileType,'ecat7')
    ecatinfo_ForCurrentImage = handles.ecatinfo2;
    openvar('ecatinfo_ForCurrentImage');
else
    scaninfo_cell = struct2cell(handles.scaninfo2);
    scaninfo_fnames = fieldnames(handles.scaninfo2);
    scaninfo_cellout = scaninfo_cell;
    num_of_field = size(scaninfo_fnames,1);
    for i= 1:num_of_field
        scaninfo_cellout{i} = [scaninfo_fnames{i},' : ',num2str(scaninfo_cell{i})];
    end

    if isempty(findobj('name','FileInfo: 2ndImage'))
        roistatfh = figure('menubar','none','NumberTitle','off','name','FileInfo: 2ndImage');
        lbh = uicontrol('Style','listbox','Position',[10 10 520 400],'tag','FileInfo2ndImageLB');
        set(lbh,'string',scaninfo_cellout);
    else
        roistatfh = findobj('name','FileInfo: 2ndImage');
        figure(roistatfh);
        lbh = findobj('tag','FileInfo2ndImageLB');
        set(lbh,'string',scaninfo_cellout);
    end
end


%% --------------------------------------------------------------------
function Interpolate_Callback(hObject, eventdata, handles)
% hObject    handle to Interpolate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if not(isfield(handles,'FileNames'));return;end %return if no 1st. file was previously opened

if  strcmp(get(handles.Interpolate,'checked'),'off')
	
    prompt = {'X pixel number:','Y pixel number:','Z pixel number:'};
	dlg_title = ['Input for pixel interpolation'];
	num_lines= 1;
	%num_lines= [1,42;1,42;1,42;];
	def     = { num2str(handles.scaninfo.imfm(1)), ...
            num2str(handles.scaninfo.imfm(2)), num2str(handles.scaninfo.num_of_slice)};
	PixInStr= inputdlg(prompt,dlg_title,num_lines,def);
	
	if isempty(PixInStr)
        return;%return if the cancel button was pressed 
	else
        PixInStr = str2double(PixInStr);
	end
	%
    % calculates the new coordinates for interpolation
    %
    new_imfm(1) = PixInStr(1); 
    new_xpixvect = [double(handles.scaninfo.imfm(1))/new_imfm(1): ...
            double(handles.scaninfo.imfm(1))/new_imfm(1) : double(handles.scaninfo.imfm(1))];
    new_imfm(2) = PixInStr(2);
    new_ypixvect = [double(handles.scaninfo.imfm(2))/new_imfm(2): ...
            double(handles.scaninfo.imfm(2))/new_imfm(2) : double(handles.scaninfo.imfm(2))];
    new_num_of_slice = PixInStr(3);
    new_zpixvect = [double(handles.scaninfo.num_of_slice)/new_num_of_slice :  ... 
            double(handles.scaninfo.num_of_slice)/new_num_of_slice : double(handles.scaninfo.num_of_slice)];
    %
    % clear some variables before interpolating and
    % redrawing the volume
    %
    handles = ClearImages(handles,1);
    %
    % save the original values
    % set the new valies
    %
    handles.imaVOLtmpinterp = handles.imaVOL;
    handles.imaVOL = [];
    handles.old_imfm = handles.scaninfo.imfm;
    handles.old_num_of_slice = handles.scaninfo.num_of_slice;
    handles.old_pixsize = handles.scaninfo.pixsize;
    handles.scaninfo.imfm = new_imfm;
    handles.scaninfo.num_of_slice = new_num_of_slice;
    handles.scaninfo.pixsize(1) =  double(handles.old_pixsize(1)*handles.old_imfm(1))/new_imfm(1);
    handles.scaninfo.pixsize(2) =  double(handles.old_pixsize(2)*handles.old_imfm(2))/new_imfm(2);
    handles.scaninfo.pixsize(3) =  double(handles.old_pixsize(3)*handles.old_num_of_slice)/new_num_of_slice;
    %
    % performing the 3D interpolation
    %
    if handles.scaninfo.imfm(1) == new_imfm(1) & handles.scaninfo.imfm(2) == new_imfm(2) ...
            & new_imfm(1)*new_imfm(2)*new_num_of_slice > 256*256*50
        % if the matrix size too large the interp3 run out from the memory.
        % Switch back to inerp2 in that case and if the imfm does not
        % change
        % SETTING UP THE PROGRESS BAR
        info.color=[1 0 0];
        info.title='Interpolating';
        info.size=1;
        info.pos='topleft';
        p=progbar(info);
        progbar(p,0);
       
        ti = zeros(new_imfm(1),new_imfm(2),new_num_of_slice);
        for i = 1 : new_imfm(1)
            t = squeeze(handles.imaVOLtmpinterp(i,:,:));
            ti(i,:,:) = interp2(double(t), new_zpixvect', new_ypixvect,'linear');
            if mod(i,round(new_imfm(1)/20)) == 0
               progbar(p,round(i*100/new_imfm(1))); drawnow;
            end
        end
        if handles.scaninfo.float == 0
            handles.imaVOL = int16(ti);
        else
            handles.imaVOL = ti;
        end
       close(p); 
    else
        hm = msgbox('3D interpolating...','Mia Info' );
        if handles.scaninfo.float == 0
            handles.imaVOL = ...
                int16(interp3(double(handles.imaVOLtmpinterp), new_ypixvect, new_xpixvect', new_zpixvect));
        else
            handles.imaVOL = ...
                interp3(handles.imaVOLtmpinterp, new_ypixvect, new_xpixvect', new_zpixvect);
        end
        delete(hm);
    end
    
    set(handles.Interpolate,'checked','on');
else
    %
    % clear some variables before interpolating and
    % redrawing the volume
    %
    handles = ClearImages(handles,1);
    handles.imaVOL =  handles.imaVOLtmpinterp;
    handles.imaVOLtmpinterp = [];
    handles.scaninfo.imfm = handles.old_imfm;
    handles.scaninfo.num_of_slice = handles.old_num_of_slice;
    handles.scaninfo.pixsize = handles.old_pixsize;
    set(handles.Interpolate,'checked','off'); 
end
%
% redraw the main figure
% inititate the ImaAxes figure
%
axes(handles.ImaAxes);
set(handles.hcb,'buttonDownFcn','mia_gui(''SetImageContrast'',gcbo,[],guidata(gcbo))');

CurrentSlice = round(handles.scaninfo.num_of_slice/2);
CurrentImgIdx = handles.scaninfo.num_of_slice*(handles.scaninfo.Frames-1)+CurrentSlice;
CurrentImage = handles.imaVOL(:,:,handles.scaninfo.num_of_slice*(handles.scaninfo.Frames-1)+CurrentSlice);
CurrentImageMinMax = [min(CurrentImage(:)) max(CurrentImage(:)) ];
if CurrentImageMinMax(2) == 0
   CurrentImageMinMax(2) = max(handles.imaVOL(:));     
end
handles.VolMax = double(max(handles.imaVOL(:)));
handles.VolMin = double(min(handles.imaVOL(:)));
%  reset some handles variable
handles.CurrentSlice = CurrentSlice;
handles.CurrentFrame = handles.scaninfo.Frames;
handles.CurrentImgIdx = CurrentImgIdx;
set(handles.CurrentFrameEdit,'String',handles.CurrentFrame);
set(handles.CurrentSliceEdit,'String',handles.CurrentSlice);

%Create the RGB image%
Initial_cmap = handles.ColormapIn1;
CurrentImage_RGB = ... 
    CreateRGBImage(CurrentImage,CurrentImageMinMax,handles.ColorRes,Initial_cmap);
ImaHandler = image(CurrentImage_RGB);
set(handles.ImaAxes,'PlotBoxAspectRatioMode','manual');
PlotBAspectRatio = [ size(handles.imaVOL,2)*handles.scaninfo.pixsize(2) ...
    size(handles.imaVOL,1)*handles.scaninfo.pixsize(1) 1];
set(handles.ImaAxes,'PlotBoxAspectRatio',PlotBAspectRatio);
handles.ImaHandler = ImaHandler;
set(handles.ImaAxes,'Tag','ImaAxes');
set(handles.ImaHandler,'Tag','MainImage');
axis off;

% rescale the colorbar
newlabels = num2cell(fixround(linspace(handles.VolMin,handles.VolMax,handles.NumOfYtickOfColorbar),handles.decimal_prec))';
set(handles.CmapAxes,'Yticklabel',newlabels);

% initiate the Slice Slider
set(handles.SliceSlider,'Min',1); 
set(handles.SliceSlider,'Max',handles.scaninfo.num_of_slice);
set(handles.SliceSlider,'value',CurrentSlice);
set(handles.SliceSlider,'SliderStep',...
    [1/(handles.scaninfo.num_of_slice-1) 10/(handles.scaninfo.num_of_slice-1)] );

% reset the ColorBar Sliders
CurrentImage = double(handles.imaVOL(:,:,handles.CurrentImgIdx));
CurrentImageMinMax = [min(CurrentImage(:)) max(CurrentImage(:)) ];
set(handles.ColorBarMaxSlider,'Min',handles.VolMin); 
set(handles.ColorBarMaxSlider,'Max',handles.VolMax);
set(handles.ColorBarMinSlider,'Min',handles.VolMin); 
set(handles.ColorBarMinSlider,'Max',handles.VolMax);
set(handles.ColorBarMaxSlider,'Value',CurrentImageMinMax(2));
set(handles.ColorBarMinSlider,'Value',CurrentImageMinMax(1));
%
% inititate the ROI,VOI parameters
%
handles.ROI(handles.scaninfo.num_of_slice,handles.ROINumOfColor).BW = [];
handles.ROI(handles.scaninfo.num_of_slice,handles.ROINumOfColor).xi = [];
handles.ROI(handles.scaninfo.num_of_slice,handles.ROINumOfColor).yi = [];
handles.Lines(handles.scaninfo.num_of_slice,handles.ROINumOfColor).lh = [];
handles.VOI(handles.ROINumOfColor).tac = [];
handles.VOI(handles.ROINumOfColor).tacstd = [];
handles.VOI(handles.ROINumOfColor).tacmin = [];
handles.VOI(handles.ROINumOfColor).tacmax = [];
handles.VOI(handles.ROINumOfColor).tacvolume = [];     
%
% initiate the mia_pixval function
%
%axes(handles.ImaAxes);
global gVOIpixval;
gVOIpixval.xypixsize = handles.scaninfo.pixsize(1:2);
gVOIpixval.CurrentImage = CurrentImage;
gVOIpixval.xLim = get(handles.ImaAxes,'XLim');
gVOIpixval.yLim = get(handles.ImaAxes,'YLim');
mia_pixval(handles.ImaHandler,'on');
%    
% Update handles structure
%
guidata(hObject, handles);


%% --------------------------------------------------------------------
function ReadECAT_PM_Callback(hObject, eventdata, handles)
% hObject    handle to ReadECAT_PM(see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


 [FileName, FilePath] = uigetfile('*.pm;*.PM','Select ecat pm file');
 filename = [FilePath,FileName];
 if FileName == 0;
      imaVOL = [];scaninfo = []; hd = [];
      return;
 end
 ecat_datain = readecatvol( filename, [ -inf, -inf, -inf, -inf, -inf; inf, inf, inf, inf, inf ] );
 if isempty(ecat_datain)
     msgbox('Error on ecat pm file loading','Mia error','error');
     return;
 end
 
 fh = figure('name','Cardiac polarmap','NumberTitle','off');
 pcolor_handle = drawecatpolarmap(ecat_datain);
 




%% --------------------------------------------------------------------
function ServiceToolsMenu_Callback(hObject, eventdata, handles)
% hObject    handle to ServiceToolsMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




%% --------------------------------------------------------------------
function NEMAImageQualityMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to NEMAImageQualityMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%% --------------------------------------------------------------------
function NEMAImageQuality_SphereROIsMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to NEMAImageQuality_SphereROIsMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if not(isfield(handles,'FileNames'));return;end%return if no file was opened 

Radius = [10, 13, 17, 22, 28, 37]/2;
pixelsize = handles.scaninfo.pixsize(1);

% delete the ROIs if exists
for i=1:6
    if isobject(handles.Lines(handles.CurrentSlice,handles.ROI_NEMAQspeheresid(i)).lh)
        delete(handles.Lines(handles.CurrentSlice,handles.ROI_NEMAQspeheresid(i)).lh);
        handles.Lines(handles.CurrentSlice,handles.ROI_NEMAQspeheresid(i)).lh = [];
    end
end

matsize1 = double(handles.scaninfo.imfm(1));
matsize2 = double(handles.scaninfo.imfm(2));
for i=1 : 6
    [xcenter, ycenter] = ginput(1); 
    x0 = xcenter; y0 = ycenter; R0 = Radius(i)/pixelsize; 
    t = 0:pi/20:2*pi; 
    xi = R0*cos(t)+xcenter; 
    yi = R0*sin(t)+ycenter; 
    roi_handler = line(xi,yi,'LineWidth',2,'Color','red'); 
    %userdata.t = t; userdata.xcenter = xcenter; userdata.ycenter = ycenter; userdata.R0 = R0;
    %set(roi_handler,'userdata',userdata);
    set(roi_handler,'tag',['ROI_NEMAQ_sphere_',num2str(i)]);
    handles.Lines(handles.CurrentSlice,handles.ROI_NEMAQspeheresid(i)).lh = roi_handler;
    handles.ROI(handles.CurrentSlice,handles.ROI_NEMAQspeheresid(i)).BW = 1;
	handles.ROI(handles.CurrentSlice,handles.ROI_NEMAQspeheresid(i)).xi = xi/matsize1;
	handles.ROI(handles.CurrentSlice,handles.ROI_NEMAQspeheresid(i)).yi = yi/matsize2;
    draggable(roi_handler);
end


%
% Update handles structure
%
guidata(hObject, handles);


%% --------------------------------------------------------------------
function NEMAImageQuality_BackROIsMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to NEMAImageQuality_BackROIsMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 %handles.ROI_NEMAQbackgr = [61:120]; % 12 ROIs of each of [10, 13, 17, 22,
 %28, 37] mm   

if not(isfield(handles,'FileNames'));return;end%return if no file was opened 

Radius = [10, 13, 17, 22, 28, 37]/2;
pixelsize = handles.scaninfo.pixsize(1);
roicolor = 'yellow';
NumOfBackgrROI = 12;
NumOfSize=6;
% delete the ROIs if exists
for i=1:NumOfBackgrROI*NumOfSize
    if isobject(handles.Lines(handles.CurrentSlice,handles.ROI_NEMAQbackgr(i)).lh )
        delete(handles.Lines(handles.CurrentSlice,handles.ROI_NEMAQbackgr(i)).lh);
        handles.Lines(handles.CurrentSlice,handles.ROI_NEMAQbackgr(i)).lh = [];
    end
end

matsize1 = double(handles.scaninfo.imfm(1));
matsize2 = double(handles.scaninfo.imfm(2));
for i = 1 : NumOfBackgrROI
    [xcenter, ycenter] = ginput(1);
    for j= 1: NumOfSize
        sn = (i-1)*NumOfSize+j; 
        x0 = xcenter; y0 = ycenter; R0 = Radius(j)/pixelsize; 
        t = 0:pi/20:2*pi; 
        xi = R0*cos(t)+xcenter; 
        yi = R0*sin(t)+ycenter; 
        roi_handler = line(xi,yi,'LineWidth',2,'Color',roicolor); 
        %userdata.t = t; userdata.xcenter = xcenter; userdata.ycenter = ycenter; userdata.R0 = R0;
        %set(roi_handler,'userdata',userdata);
        set(roi_handler,'tag',['ROI_NEMAQ_backgr_',num2str(sn)]);
        handles.Lines(handles.CurrentSlice,handles.ROI_NEMAQbackgr(sn)).lh = roi_handler;
        handles.ROI(handles.CurrentSlice,handles.ROI_NEMAQbackgr(sn)).BW = 1;
        handles.ROI(handles.CurrentSlice,handles.ROI_NEMAQbackgr(sn)).xi = xi/matsize1;
        handles.ROI(handles.CurrentSlice,handles.ROI_NEMAQbackgr(sn)).yi = yi/matsize2;
        draggable(roi_handler);
    end
end

%
% Update handles structure
%
guidata(hObject, handles);

 
 
%% --------------------------------------------------------------------
function NEMAImageQuality_CalculationMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to NEMAImageQuality_CalculationMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if not(isfield(handles,'FileNames'));return;end % 1st file should be opened first

% if all necessary ROIs did not exis then return
ROIsystemComplete = 1;
for i=1:6
    if isempty(handles.Lines(handles.CurrentSlice,handles.ROI_NEMAQspeheresid(i)).lh )
        ROIsystemComplete = 0;
        break;
    end
end
NumOfBackgrROI = 12;
NumOfSize=6;
for i=1:NumOfBackgrROI*NumOfSize
    if isempty(handles.Lines(handles.CurrentSlice,handles.ROI_NEMAQbackgr(i)).lh )
        ROIsystemComplete = 0;
        break;
    end
end
if ~ROIsystemComplete;return;end

prompt = {'Hot_spehere/backgr_spehere activity concentration ratio:'};
dlg_title = ['NEMA IQ contrast calculation'];
num_lines= 1;
%num_lines= [1,42;1,42;1,42;];
def     = { '4'};
MeasuredContrastStr = inputdlg(prompt,dlg_title,num_lines,def);

if isempty(MeasuredContrastStr)
    return;%return if the cancel button was pressed 
else
    MeasuredContrast = str2double(MeasuredContrastStr);
end

respath = which('mia_gui.m');
[pathstr, name, ext, versn] = fileparts(respath); 
outdir = [pathstr,filesep,'output',filesep];
rfid = fopen([outdir,'NEMA_IQstatTmp.txt'], 'w+');
fprintf(rfid, '%-20s\t %-25s\n', 'CurrentDate = ', datestr(now));
fprintf(rfid, '\n');        
fprintf(rfid, 'Image file used for ROI statistics: \n');
fprintf(rfid, '\t"%s"\n', [handles.dirname,char(handles.FileNames(1))]);
fprintf(rfid, '\n');

matsize1 = handles.scaninfo.imfm(1);matsize2 = handles.scaninfo.imfm(2);
startNEMABackgrROIidx = 50;
startNEMAHotROIidx = 122;
csl = handles.CurrentSlice;
ciidx = handles.CurrentImgIdx;
px = [];px_num=0;
roibackgr_mean(6) = 0;
roibackgr_std(6) = 0;
roisphere_mean(6) = 0;
roisphere_std(6) = 0;
Contrast(6) = 0;
for i=1:NumOfSize
    imgt = handles.imaVOL(:,:,ciidx);
    % calculate the mean and std of background ROIs
    ROIidx = [startNEMABackgrROIidx+i:NumOfSize:startNEMABackgrROIidx+i+(NumOfBackgrROI-1)*NumOfSize];
    for k=1:NumOfBackgrROI
        roimask = poly2mask(round(handles.ROI(csl,ROIidx(k)).xi*double(matsize1)),...
            round(handles.ROI(csl,ROIidx(k)).yi*double(matsize2)),double(matsize1),double(matsize2));
        px = [px' find(roimask)']'; px_num = px_num+length(find(roimask));
    end   
    imgt_masked=imgt(px);
    roibackgr_mean(i) = mean(imgt_masked);
    roibackgr_std(i) = std(double(imgt_masked));
    % calculate the mean and std of spehere ROIs
    ROIidx = startNEMAHotROIidx+i;
    roimask = poly2mask(handles.ROI(csl,ROIidx).xi*double(matsize1),...
            handles.ROI(csl,ROIidx).yi*double(matsize2),double(matsize1),double(matsize2));
    px = find(roimask); px_num = length(find(roimask));
    imgt_masked=imgt(px);
    roisphere_mean(i) = mean(imgt_masked);
    roisphere_std(i) = std(double(imgt_masked));
end

for i=1:NumOfSize
    Contrast(i) = (roisphere_mean(i)/roibackgr_mean(i)-1)/(MeasuredContrast-1)*100;
end
% for i=5:6
%     Contrast(i) = (1-roisphere_mean(i)/roibackgr_mean(i))*100;
% end
fprintf(rfid, '%20s\t', 'Background variability = ');
    fprintf(rfid, '%10.2f\t', roibackgr_std(6)/roibackgr_mean(6)*100); % a legnagyobb ROIhoz tartozo hatterbol
    fprintf(rfid, '\n\n');

for i=1:NumOfSize
    % print the current ROI stat. values
    fprintf(rfid, '\t');
    fprintf(rfid, 'Results for sphere "%s".: \n', num2str(i));

    fprintf(rfid, '%20s\t', 'Contrast = ');
    fprintf(rfid, '%10.2f\t', Contrast(i));
    fprintf(rfid, '\n');

    fprintf(rfid, '%20s\t', 'ROI variability = ');
    fprintf(rfid, '%10.2f\t', roisphere_std(i)/roisphere_mean(i)*100);
    fprintf(rfid, '\n');
    
    fprintf(rfid, '\n\n');

end
    
    
fclose(rfid);
roifile = textread([outdir,'NEMA_IQstatTmp.txt'],'%s','delimiter','\n','whitespace','');
if isempty(findobj('name','MIA NEMAQ statistics'))
    figure('menubar','none','NumberTitle','off','name','MIA NEMAQ statistics');
    lbh = uicontrol('Style','listbox','Position',[10 10 520 400],'tag','MIANEMAQROIstatlis');
    set(lbh,'string',roifile);
else
    roistatfh = findobj('name','MIA NEMAQ statistics');
    figure(roistatfh);
    lbh = findobj('tag','MIANEMAQROIstatlis');
    set(lbh,'string',roifile);
end


% --------------------------------------------------------------------
function LesionVolumeTestMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to LesionVolumeTestMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if not(isfield(handles,'FileNames'));return;end % 1st file should be opened first

current_slice= handles.CurrentImgIdx;
number_of_slice = handles.scaninfo.num_of_slice;
imsize = double(handles.scaninfo.imfm(1));
%pixelsize = handles.scaninfo.pixsize(1);

for i =1: handles.scaninfo(1).num_of_slice
    for j=handles.ROI_LesionThres70:handles.ROI_LesionBackground
        if ~isempty(handles.ROI(i,j).BW )
            handles.ROI(i,j).BW = [];
            handles.ROI(i,j).xi = [];
            handles.ROI(i,j).yi = [];
            delete(handles.Lines(i,j).lh);
            handles.Lines(i,j).lh = [];
        end
    end
end

prompt = {'True diameter [mm]:'};
dlg_title = ['Input for lesion volume test'];
num_lines= [1];
def     = {'37'};
RescaleInStr= inputdlg(prompt,dlg_title,num_lines,def);
if isempty(RescaleInStr)
    % Update handles structure
    guidata(hObject, handles);
    return;%return if the cancel button was pressed 
else
    Diameter = str2double(RescaleInStr);
end 

%area_original = ((Diameter/2)^2*3.14/4)/(pixelsize*pixelsize);
volume_original = ((Diameter/2)^3*3.14*4/3)/(prod(handles.scaninfo.pixsize));

% exterior roi selection
rectpos = [0 0 0 0];
while rectpos(3) == 0;
    rectpos = round(getrect(gcf));
    if rectpos(3) == 0;
        mbh = msgbox('Use the mouse to click and DRAG the desired rectangle.','mia Info');
        uiwait(mbh);
    end
end
xi = [rectpos(1), rectpos(1)+rectpos(3), rectpos(1)+rectpos(3), rectpos(1),rectpos(1)];
yi = [rectpos(2), rectpos(2), rectpos(2)+rectpos(4), rectpos(2)+rectpos(4),rectpos(2)];
roi_handler = line(xi,yi,'color','red','LineWidth',2,'tag','LesionVolumeTest_ExteriorRoi');
handles.Lines(current_slice,handles.ROI_LesionExternal).lh = roi_handler;
handles.ROI(current_slice,handles.ROI_LesionExternal).BW = 1;
BW = poly2mask(xi,yi,imsize,imsize);
rangetmp = find(BW);
[ii jj ] =ind2sub([imsize imsize], rangetmp);
slices_outer = round(max([rectpos(3) rectpos(4)])/2)+1;


% background roi selection
rectpos = [0 0 0 0];
while rectpos(3) == 0;
    rectpos = round(getrect(gcf));
    if rectpos(3) == 0;
        mbh = msgbox('Use the mouse to click and DRAG the desired rectangle.','mia Info');
        uiwait(mbh);
    end
end
xi = [rectpos(1), rectpos(1)+rectpos(3), rectpos(1)+rectpos(3), rectpos(1),rectpos(1)];
yi = [rectpos(2), rectpos(2), rectpos(2)+rectpos(4), rectpos(2)+rectpos(4),rectpos(2)];
roi_handler = line(xi,yi,'color','yellow','LineWidth',2,'tag','LesionVolumeTest_BackgroundRoi');
handles.Lines(current_slice,handles.ROI_LesionBackground).lh = roi_handler;
handles.ROI(current_slice,handles.ROI_LesionBackground).BW = 1;
drawnow;
BW = poly2mask(xi,yi,imsize,imsize);
rangetmp = find(BW);
[iib jjb ] =ind2sub([imsize imsize], rangetmp);
slices_outer_back = round(max([rectpos(3) rectpos(4)])/2);
roiback_mean = 0;
for i=current_slice-slices_outer_back : current_slice + slices_outer_back
    roiback_mean = roiback_mean + mean(mean(handles.imaVOL(iib,jjb,i)));
end
roiback_mean = roiback_mean/((current_slice + slices_outer_back)-(current_slice-slices_outer_back)+1);

%define the masked imaVOL
imaVOLtmp = zeros(size(handles.imaVOL)); contVOL70 = zeros(size(handles.imaVOL)); contVOL = zeros(size(handles.imaVOL));
for i=current_slice-slices_outer : current_slice + slices_outer
    imaVOLtmp(ii,jj,i) = handles.imaVOL(ii,jj,i);
end
roimax = max(imaVOLtmp(:));
roithreshold = 0.7;
roi_thres = roimax*roithreshold; 

% calculate the 70% contours for the slices in the masked subvolume 
controi70(1).xiii = 1;
controi70(1).yiii = 1;
for i = current_slice-slices_outer : current_slice + slices_outer
    C = contourc(imaVOLtmp(:,:,i),[roi_thres roi_thres]);
    vertex_start_indexes = find(C(1,:) == roi_thres);
    num_of_vertexes = C(2,vertex_start_indexes);
    [maxnum_of_vertexes maxnum_of_vertexes_index] = max(num_of_vertexes);
    controi70(i).xiii = C(1,vertex_start_indexes(maxnum_of_vertexes_index)+1:vertex_start_indexes(maxnum_of_vertexes_index)+ maxnum_of_vertexes);
    controi70(i).yiii = C(2,vertex_start_indexes(maxnum_of_vertexes_index)+1:vertex_start_indexes(maxnum_of_vertexes_index)+ maxnum_of_vertexes);
    %line70_h = line(xiii,yiii,'color','blue','LineWidth',2);
    contVOL70(:,:,i) = poly2mask(controi70(i).xiii,controi70(i).yiii,imsize,imsize);
end
roi70meanVOL = mean(handles.imaVOL(find(contVOL70)));
volume_cont70 = sum(contVOL70(:));
volume_recovery = volume_cont70/volume_original;

% calculate the total volume contours for the slices in the masked subvolume 
controi(1).xiii = 1;
controi(1).yiii = 1;
if volume_recovery > 1; 
    recovery_step =  0.01 ;
elseif volume_recovery < 1;
    recovery_step = -0.01 ;
end
fprintf('\n');
volume_recovery_prev = volume_recovery;
while  (volume_recovery < 0.95 || volume_recovery > 1.05) &&  ...
        ~((volume_recovery_prev < 1 && volume_recovery > 1) || (volume_recovery_prev > 1 && volume_recovery < 1))
    roithreshold = roithreshold +recovery_step;
    roi_thres = roimax*roithreshold; 
    for i = current_slice-slices_outer : current_slice + slices_outer
        C = contourc(imaVOLtmp(:,:,i),[roi_thres roi_thres]);
        vertex_start_indexes = find(C(1,:) == roi_thres);
        num_of_vertexes = C(2,vertex_start_indexes);
        [maxnum_of_vertexes maxnum_of_vertexes_index] = max(num_of_vertexes);
        controi(i).xiii = C(1,vertex_start_indexes(maxnum_of_vertexes_index)+1:vertex_start_indexes(maxnum_of_vertexes_index)+ maxnum_of_vertexes);
        controi(i).yiii = C(2,vertex_start_indexes(maxnum_of_vertexes_index)+1:vertex_start_indexes(maxnum_of_vertexes_index)+ maxnum_of_vertexes);
        %line70_h = line(xiii,yiii,'color','blue','LineWidth',2);
        contVOL(:,:,i) = poly2mask(controi(i).xiii,controi(i).yiii,imsize,imsize);
    end
    volume_recovery_prev = volume_recovery;
    volume_recovery = sum(contVOL(:))/volume_original;
    fprintf('%c','.');
end
fprintf('\n');
if roithreshold == 0.7  
% ha az elozo  while ciklusba nem l�pett be a program, (mert a kezdeti volume_recovery eleve a 
% a felteteli intervallumba esett)akkor a control 
% es a contVOL valtozokat inizializalni kell
    controi = controi70;
    contVOL = contVOL70;
end  

% define the mia ROI structure elements for displaying the ROIs
for i = current_slice-slices_outer : current_slice + slices_outer
    % processing the 70% threshold lesion ROIs
    if ~isempty(controi70(i).xiii)
        roi_handler = line(controi70(i).xiii,controi70(i).yiii,'LineWidth',2,'Color',handles.ROIColorStrings(handles.ROI_LesionThres70));
        if i ~= current_slice
            set(roi_handler,'visible','off');
        end
        handles.Lines(i,handles.ROI_LesionThres70).lh = roi_handler;
        handles.ROI(i,handles.ROI_LesionThres70).BW = 1;
        handles.ROI(i,handles.ROI_LesionThres70).xi = controi70(i).xiii/imsize;
        handles.ROI(i,handles.ROI_LesionThres70).yi = controi70(i).yiii/imsize;
        % processing the total threshold lesion ROIs
        roi_handler_ = line(controi(i).xiii,controi(i).yiii,'LineWidth',2,'Color',handles.ROIColorStrings(handles.ROI_LesionThresTotal));
        if i ~= current_slice
            set(roi_handler_,'visible','off');
        end
        handles.Lines(i,handles.ROI_LesionThresTotal).lh = roi_handler_;
        handles.ROI(i,handles.ROI_LesionThresTotal).BW = 1;
        handles.ROI(i,handles.ROI_LesionThresTotal).xi = controi(i).xiii/imsize;
        handles.ROI(i,handles.ROI_LesionThresTotal).yi = controi(i).yiii/imsize;
    end
end

roimeanVOL = mean(handles.imaVOL(find(contVOL)));
C_norm = (roi70meanVOL - roiback_mean)/roiback_mean;
thresold_norm = roi_thres/(roi70meanVOL - roiback_mean);
try 
    hexcel = actxGetRunningServer('excel.application');
    current_cell_addr = hexcel.ActiveCell.Address;
    last_cell_addr = hexcel.ActiveCell.next.next.next.next.next.next.next.Address;
    hActivesheetRange = hexcel.Activesheet.get('Range',current_cell_addr ,last_cell_addr);
    hActivesheetRange.value = [roiback_mean roi70meanVOL volume_recovery roimeanVOL roimax roi_thres thresold_norm C_norm];
    hexcel.delete;
catch
    disp(['roiback_mean=',num2str(roiback_mean),' roi70meanVOL=',num2str(roi70meanVOL), ...
        ' volume_recovery=',num2str(volume_recovery),' roimeanVOL=',num2str(roimeanVOL)]);
    disp(['roimax=',num2str(roimax),' roi_thres=',num2str(roi_thres), ...
        ' thresold_norm=',num2str(thresold_norm), ' C_norm=',num2str(C_norm)] );
    disp(' ');
end
% Update handles structure
guidata(hObject, handles);
% --------------------------------------------------------------------
function LesionVolumeCalcMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to LesionVolumeCalcMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if not(isfield(handles,'FileNames'));return;end % 1st file should be opened first
if isempty(handles.lesionvolcal_slope);
    msgbox('The line parameters has not been defined for the lesion volume calculation','Mia info','warn');
    return;% if the line parameters were not defined
end 

current_slice= handles.CurrentImgIdx;
number_of_slice = handles.scaninfo.num_of_slice;
imsize = double(handles.scaninfo.imfm(1));
pixelsize = handles.scaninfo.pixsize(1);

for i =1: handles.scaninfo(1).num_of_slice
    for j=handles.ROI_LesionThres70:handles.ROI_LesionBackground
        if ~isempty(handles.ROI(i,j).BW )
            handles.ROI(i,j).BW = [];
            handles.ROI(i,j).xi = [];
            handles.ROI(i,j).yi = [];
            delete(handles.Lines(i,j).lh);
            handles.Lines(i,j).lh = [];
        end
    end
end

% exterior roi selection
rectpos = [0 0 0 0];
while rectpos(3) == 0;
    rectpos = round(getrect(gcf));
    if rectpos(3) == 0;
        mbh = msgbox('Use the mouse to click and DRAG the desired rectangle.','mia Info');
        uiwait(mbh);
    end
end
xi = [rectpos(1), rectpos(1)+rectpos(3), rectpos(1)+rectpos(3), rectpos(1),rectpos(1)];
yi = [rectpos(2), rectpos(2), rectpos(2)+rectpos(4), rectpos(2)+rectpos(4),rectpos(2)];
roi_handler = line(xi,yi,'color','red','LineWidth',2,'tag','LesionVolumeTest_ExteriorRoi');
handles.Lines(current_slice,handles.ROI_LesionExternal).lh = roi_handler;
handles.ROI(current_slice,handles.ROI_LesionExternal).BW = 1;
BW = poly2mask(xi,yi,imsize,imsize);
rangetmp = find(BW);
[ii jj ] =ind2sub([imsize imsize], rangetmp);
slices_outer = round(max([rectpos(3) rectpos(4)])/2)+1;


% background roi selection
rectpos = [0 0 0 0];
while rectpos(3) == 0;
    rectpos = round(getrect(gcf));
    if rectpos(3) == 0;
        mbh = msgbox('Use the mouse to click and DRAG the desired rectangle.','mia Info');
        uiwait(mbh);
    end
end
xi = [rectpos(1), rectpos(1)+rectpos(3), rectpos(1)+rectpos(3), rectpos(1),rectpos(1)];
yi = [rectpos(2), rectpos(2), rectpos(2)+rectpos(4), rectpos(2)+rectpos(4),rectpos(2)];
roi_handler = line(xi,yi,'color','yellow','LineWidth',2,'tag','LesionVolumeTest_BackgroundRoi');
handles.Lines(current_slice,handles.ROI_LesionBackground).lh = roi_handler;
handles.ROI(current_slice,handles.ROI_LesionBackground).BW = 1;
drawnow;
BW = poly2mask(xi,yi,imsize,imsize);
rangetmp = find(BW);
[iib jjb ] =ind2sub([imsize imsize], rangetmp);
slices_outer_back = round(max([rectpos(3) rectpos(4)])/2);
roiback_mean = 0;
for i=current_slice-slices_outer_back : current_slice + slices_outer_back
    roiback_mean = roiback_mean + mean(mean(handles.imaVOL(iib,jjb,i)));
end
roiback_mean = roiback_mean/((current_slice + slices_outer_back)-(current_slice-slices_outer_back)+1);

%define the masked imaVOL
imaVOLtmp = zeros(size(handles.imaVOL)); contVOL70 = zeros(size(handles.imaVOL)); contVOL = zeros(size(handles.imaVOL));
for i=current_slice-slices_outer : current_slice + slices_outer
    imaVOLtmp(ii,jj,i) = handles.imaVOL(ii,jj,i);
end
roimax = max(imaVOLtmp(:));
roithreshold = 0.7;
roi_thres = roimax*roithreshold; 

% calculate the 70% contours for the slices in the masked subvolume 
controi70(1).xiii = 1;
controi70(1).yiii = 1;
for i = current_slice-slices_outer : current_slice + slices_outer
    C = contourc(imaVOLtmp(:,:,i),[roi_thres roi_thres]);
    vertex_start_indexes = find(C(1,:) == roi_thres);
    num_of_vertexes = C(2,vertex_start_indexes);
    [maxnum_of_vertexes maxnum_of_vertexes_index] = max(num_of_vertexes);
    controi70(i).xiii = C(1,vertex_start_indexes(maxnum_of_vertexes_index)+1:vertex_start_indexes(maxnum_of_vertexes_index)+ maxnum_of_vertexes);
    controi70(i).yiii = C(2,vertex_start_indexes(maxnum_of_vertexes_index)+1:vertex_start_indexes(maxnum_of_vertexes_index)+ maxnum_of_vertexes);
    %line70_h = line(xiii,yiii,'color','blue','LineWidth',2);
    contVOL70(:,:,i) = poly2mask(controi70(i).xiii,controi70(i).yiii,imsize,imsize);
end
roi70meanVOL = mean(handles.imaVOL(find(contVOL70)));

% calculate the total volume contours for the slices in the masked subvolume
% using the linear equation between the thresold_norm and C_norm

C_norm = (roi70meanVOL - roiback_mean)/roiback_mean;
thresold_norm = handles.lesionvolcal_slope/C_norm + handles.lesionvolcal_intercept;
roi_thres = (roi70meanVOL - roiback_mean)*thresold_norm;
% calculate the 70% contours for the slices in the masked subvolume 
controi(1).xiii = 1;
controi(1).yiii = 1;
for i = current_slice-slices_outer : current_slice + slices_outer
    C = contourc(imaVOLtmp(:,:,i),[roi_thres roi_thres]);
    vertex_start_indexes = find(C(1,:) == roi_thres);
    num_of_vertexes = C(2,vertex_start_indexes);
    [maxnum_of_vertexes maxnum_of_vertexes_index] = max(num_of_vertexes);
    controi(i).xiii = C(1,vertex_start_indexes(maxnum_of_vertexes_index)+1:vertex_start_indexes(maxnum_of_vertexes_index)+ maxnum_of_vertexes);
    controi(i).yiii = C(2,vertex_start_indexes(maxnum_of_vertexes_index)+1:vertex_start_indexes(maxnum_of_vertexes_index)+ maxnum_of_vertexes);
    %line70_h = line(xiii,yiii,'color','blue','LineWidth',2);
    contVOL(:,:,i) = poly2mask(controi(i).xiii,controi(i).yiii,imsize,imsize);
end
roimeanVOL = mean(handles.imaVOL(find(contVOL)));
volume_cont = sum(contVOL(:))*prod(handles.scaninfo.pixsize)/1000;%[ml]

% define the mia ROI structure elements for displaying the ROIs
for i = current_slice-slices_outer : current_slice + slices_outer
    % processing the 70% threshold lesion ROIs
    if ~isempty(controi70(i).xiii)
        roi_handler = line(controi70(i).xiii,controi70(i).yiii,'LineWidth',2,'Color',handles.ROIColorStrings(handles.ROI_LesionThres70));
        if i ~= current_slice
            set(roi_handler,'visible','off');
        end
        handles.Lines(i,handles.ROI_LesionThres70).lh = roi_handler;
        handles.ROI(i,handles.ROI_LesionThres70).BW = 1;
        handles.ROI(i,handles.ROI_LesionThres70).xi = controi70(i).xiii/imsize;
        handles.ROI(i,handles.ROI_LesionThres70).yi = controi70(i).yiii/imsize;
        % processing the total threshold lesion ROIs
        roi_handler_ = line(controi(i).xiii,controi(i).yiii,'LineWidth',2,'Color',handles.ROIColorStrings(handles.ROI_LesionThresTotal));
        if i ~= current_slice
            set(roi_handler_,'visible','off');
        end
        handles.Lines(i,handles.ROI_LesionThresTotal).lh = roi_handler_;
        handles.ROI(i,handles.ROI_LesionThresTotal).BW = 1;
        handles.ROI(i,handles.ROI_LesionThresTotal).xi = controi(i).xiii/imsize;
        handles.ROI(i,handles.ROI_LesionThresTotal).yi = controi(i).yiii/imsize;
    end
end

try 
    hexcel = actxGetRunningServer('excel.application');
    current_cell_addr = hexcel.ActiveCell.Address;
    last_cell_addr = hexcel.ActiveCell.next.next.next.next.next.next.next.Address;
    hActivesheetRange = hexcel.Activesheet.get('Range',current_cell_addr ,last_cell_addr);
    hActivesheetRange.value = [roiback_mean roi70meanVOL roimax C_norm thresold_norm roi_thres roimeanVOL volume_cont];
    hexcel.delete;
catch
    disp(['roiback_mean=',num2str(roiback_mean),' roi70meanVOL=',num2str(roi70meanVOL), ...
        ' roimax=',num2str(roimax),' C_norm=',num2str(C_norm)]);
    disp(['thresold_norm=',num2str(thresold_norm),' roi_thres=',num2str(roi_thres), ...
        ' roimeanVOL=',num2str(roimeanVOL), ' volume_cont=',num2str(volume_cont)] );
    disp(' ');
end
disp(['pname: ',handles.scaninfo.pnm,' Egyenes parameterek: ',num2str(handles.lesionvolcal_slope),', ',num2str(handles.lesionvolcal_intercept)]);
% Update handles structure
guidata(hObject, handles);


% --------------------------------------------------------------------
function LesionVolumeParamsMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to LesionVolumeParamsMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if not(isfield(handles,'FileNames'));return;end % 1st file should be opened first

prompt = {'slope:','intercept:'};
dlg_title = ['Line parameters for volume calc.'];
num_lines= 1;
%num_lines= [1,42;1,42;1,42;];
if isempty(handles.lesionvolcal_slope)
    def     = { num2str(1), num2str(0.5)};
else
    def     = { num2str(handles.lesionvolcal_slope), num2str(handles.lesionvolcal_intercept)};
end
LinParams = inputdlg(prompt,dlg_title,num_lines,def);
if isempty(LinParams)
    return;%return if the cancel button was pressed 
else
    LinParams = str2double(LinParams);
end

handles.lesionvolcal_slope = LinParams(1);
handles.lesionvolcal_intercept = LinParams(2);
% Update handles structure
guidata(hObject, handles);


% --------------------------------------------------------------------
function CTImageQualityMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CTImageQualityMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function CTImageQuality_Draw5ROIsOnHeadMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CTImageQuality_Draw5ROIsOnHeadMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if not(isfield(handles,'FileNames'));return;end%return if no file was opened 

Radius = [20 20 20 20 20]/2;
pixelsize = handles.scaninfo.pixsize(1);
ROIcolorNumbers = [1:5];
% delete the first 5 color coded VOI if exists and refresh the handle
for i =1: handles.scaninfo(1).num_of_slice
    for j=ROIcolorNumbers
        if ~isempty(handles.ROI(i,j).BW )
            handles.ROI(i,j).BW = [];
            handles.ROI(i,j).xi = [];
            handles.ROI(i,j).yi = [];
            delete(handles.Lines(i,j).lh);
            handles.Lines(i,j).lh = [];
        end
    end
end
    
 % delete the related TAC values for VOIs
for j=ROIcolorNumbers
        handles.VOI(j).tac = [];
        handles.VOI(j).tacstd = [];
        handles.VOI(j).tacmin = [];
        handles.VOI(j).tacmax = [];
        handles.VOI(j).tacvolume = [];
end

matsize1 = double(handles.scaninfo.imfm(1));
matsize2 = double(handles.scaninfo.imfm(2));
for i = ROIcolorNumbers
    [xcenter, ycenter] = ginput(1); 
    x0 = xcenter; y0 = ycenter; R0 = Radius(i)/pixelsize; 
    t = 0:pi/20:2*pi; 
    xi = R0*cos(t)+xcenter; 
    yi = R0*sin(t)+ycenter; 
    roi_handler = line(xi,yi,'LineWidth',2,'Color',handles.ROIColorStrings(i)); 
    %userdata.t = t; userdata.xcenter = xcenter; userdata.ycenter = ycenter; userdata.R0 = R0;
    %set(roi_handler,'userdata',userdata);
    set(roi_handler,'tag',['ROI_NEMAQ_sphere_',num2str(i)]);
    handles.Lines(handles.CurrentSlice,i).lh = roi_handler;
    handles.ROI(handles.CurrentSlice,i).BW = 1;
	handles.ROI(handles.CurrentSlice,i).xi = xi/matsize1;
	handles.ROI(handles.CurrentSlice,i).yi = yi/matsize2;
    draggable(roi_handler);
end


%
% Update handles structure
%
guidata(hObject, handles);


% --------------------------------------------------------------------
function CTImageQuality_Draw3ROIsOnBodyMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CTImageQuality_Draw3ROIsOnBodyMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if not(isfield(handles,'FileNames'));return;end%return if no file was opened 

Radius = [20 20 20]/2;
pixelsize = handles.scaninfo.pixsize(1);
ROIcolorNumbers = [6:8];
% delete the first 5 color coded VOI if exists and refresh the handle
for i =1: handles.scaninfo(1).num_of_slice
    for j=ROIcolorNumbers
        if ~isempty(handles.ROI(i,j).BW )
            handles.ROI(i,j).BW = [];
            handles.ROI(i,j).xi = [];
            handles.ROI(i,j).yi = [];
            delete(handles.Lines(i,j).lh);
            handles.Lines(i,j).lh = [];
        end
    end
end
    
 % delete the related TAC values for VOIs
for j=ROIcolorNumbers
        handles.VOI(j).tac = [];
        handles.VOI(j).tacstd = [];
        handles.VOI(j).tacmin = [];
        handles.VOI(j).tacmax = [];
        handles.VOI(j).tacvolume = [];
end

matsize1 = double(handles.scaninfo.imfm(1));
matsize2 = double(handles.scaninfo.imfm(2));
for i = ROIcolorNumbers
    [xcenter, ycenter] = ginput(1); 
    x0 = xcenter; y0 = ycenter; R0 = Radius(ROIcolorNumbers==i)/pixelsize; 
    t = 0:pi/20:2*pi; 
    xi = R0*cos(t)+xcenter; 
    yi = R0*sin(t)+ycenter; 
    roi_handler = line(xi,yi,'LineWidth',2,'Color',handles.ROIColorStrings(i)); 
    %userdata.t = t; userdata.xcenter = xcenter; userdata.ycenter = ycenter; userdata.R0 = R0;
    %set(roi_handler,'userdata',userdata);
    set(roi_handler,'tag',['ROI_NEMAQ_sphere_',num2str(i)]);
    handles.Lines(handles.CurrentSlice,i).lh = roi_handler;
    handles.ROI(handles.CurrentSlice,i).BW = 1;
	handles.ROI(handles.CurrentSlice,i).xi = xi/matsize1;
	handles.ROI(handles.CurrentSlice,i).yi = yi/matsize2;
    draggable(roi_handler);
end


%
% Update handles structure
%
guidata(hObject, handles);