function varargout = mia_3dcursor_gui(varargin)
% MIA_3DCURSOR_GUI M-file for mia_3dcursor_gui.fig
%      MIA_3DCURSOR_GUI, by itself, creates a new MIA_3DCURSOR_GUI or raises the existing
%      singleton*.
%
%      H = MIA_3DCURSOR_GUI returns the handle to a new MIA_3DCURSOR_GUI or the handle to
%      the existing singleton*.
%
%      MIA_3DCURSOR_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MIA_3DCURSOR_GUI.M with the given input arguments.
%
%      MIA_3DCURSOR_GUI('Property','Value',...) creates a new MIA_3DCURSOR_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mia_3dcursor_gui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mia_3dcursor_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mia_3dcursor_gui

% Last Modified by GUIDE v2.5 13-Jun-2004 02:08:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mia_3dcursor_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @mia_3dcursor_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before mia_3dcursor_gui is made visible.
function mia_3dcursor_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mia_3dcursor_gui (see VARARGIN)

% set the main figure to the possible most upper position 
ScreenSize = get(0,'screenSize');
Position0 = get(handles.mia_3dcursor_figure,'Position');

set(handles.mia_3dcursor_figure,'Position',[Position0(1),  ... 
    ScreenSize(4)-Position0(4)*4.8 , Position0(3), Position0(4)]);

% Choose default command line output for mia_3dcursor_gui
handles.output = hObject;

if ishandle(varargin{1}) % figure handle 
        % store the handle to main_gui figure 
        handles.mia_mainfigure = varargin{1};
else % handles structure 
        % save the handle for MainGUI's figure in the handles 
        %structure. 
        % get it from the handles structure that was used as input% 
       main_gui_handles = varargin{1}; 
       handles.mia_mainfigure = main_gui_handles.main_gui; 
end 
mia_mainfigure_handles = guidata(handles.mia_mainfigure);
axes(handles.CmapAxesOn3dCursorFig);
CMapImg = get(mia_mainfigure_handles.hcb,'cdata');
miaYlabels = get(mia_mainfigure_handles.CmapAxes,'Yticklabel');
miaYticks = get(mia_mainfigure_handles.CmapAxes,'Ytick');
set(handles.mia_mainfigure,'Visible','off');
set(handles.mia_3dcursor_figure,'DeleteFcn','mia_3dcursor_gui(''SliceModebutton_Callback'',gcbo,[],guidata(gcbo))');

handles.hcb = image(permute(CMapImg,[2 1 3]));
set(handles.CmapAxesOn3dCursorFig,'Yticklabel',{});
set(handles.CmapAxesOn3dCursorFig,'Xticklabel',miaYlabels);
set(handles.CmapAxesOn3dCursorFig,'Xtick',miaYticks);
set(handles.hcb,'tag','ColorbarImageOn3dCursorFig');
set(handles.hcb,'buttonDownFcn','mia_3dcursor_gui(''SetImageContrast'',gcbo,[],guidata(gcbo))');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mia_3dcursor_gui wait for user response (see UIRESUME)
% uiwait(handles.mia_3dcursor_figure);


% --- Outputs from this function are returned to the command line.
function varargout = mia_3dcursor_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function SetImageContrast(hObject, eventdata, handles)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

%check the mouse click type: only double click can initiate the imcontrast tool  

matlab_verstruct = ver('MATLAB');
matlab_vermain = str2num(matlab_verstruct.Version(1));

mouseclick = get(handles.mia_3dcursor_figure,'SelectionType');
if ~strcmp(mouseclick,'open') &  ~strcmp(mouseclick,'alt')
    return;
end
mia_mainfigure_handles = guidata(handles.mia_mainfigure);

if (matlab_vermain < 7) | ( matlab_vermain >= 7 & strcmp(mouseclick,'alt'))
    prompt = {'Pixel min:','Pixel max:'};
	dlg_title = ['Input for color mapping'];
	num_lines= 1;
	%num_lines= [1,42;1,42;1,42;];
	def     = { num2str(get(mia_mainfigure_handles.ColorBarMinSlider, 'Value')), ...
            num2str(get(mia_mainfigure_handles.ColorBarMaxSlider, 'Value'))};
	PixInStr = inputdlg(prompt,dlg_title,num_lines,def);
	
	if isempty(PixInStr)
        %if the cancel button was pressed 
        NewClim = get(get(mia_mainfigure_handles.D3CursorFigData.ImaHandlerZ,'parent'),'CLim');
	else
        NewClim = str2double(PixInStr);
        if isnan(str2double(PixInStr(1))) | isnan(str2double(PixInStr(2)))
            %if one of LIMIT value was not filled in
            NewClim = get(get(mia_mainfigure_handles.D3CursorFigData.ImaHandlerZ,'parent'),'CLim');
        end
    end
elseif matlab_vermain >= 7 & strcmp(mouseclick,'open')
    %if matlab_vermain >= 7 than start the imcontrast GUI tool
    %turn off the mia_pixval func. because it does work well with the
    % imcontrast function
    mia_Zpixval(mia_mainfigure_handles.D3CursorFigData.FigHandlerZ,'off');
    
    figure(mia_mainfigure_handles.D3CursorFigData.FigHandlerZ);
    % delete some variables which stop to work the imcontrast function
    % It is far to clear why these are important!!
    is_imcontrastFig_Exist = getappdata(gca,'imcontrastFig');
    if ~isempty(is_imcontrastFig_Exist)
        rmappdata(gca,'imcontrastFig');
    end
    
    % start the imcontrast and hold on the screen until finished it
    imcontrast_h = imcontrast(mia_mainfigure_handles.D3CursorFigData.ImaHandlerZ);
    set(imcontrast_h,'WindowStyle','modal');
    uiwait(imcontrast_h);

    % set the ColorBarMaxSlider and ColorBarMinSlider Values 
    % according to the new CLim 
    NewClim = get(get(mia_mainfigure_handles.D3CursorFigData.ImaHandlerZ,'parent'),'CLim');
end


% change the image type from intensity  to RGB
SliderPosMax = NewClim(2);
SliderPosMin = NewClim(1);
% rescale the related 3D cursor figures also
set(get(mia_mainfigure_handles.D3CursorFigData.ImaHandlerY,'parent'),'CLim',[SliderPosMin SliderPosMax]);
set(get(mia_mainfigure_handles.D3CursorFigData.ImaHandlerX,'parent'),'CLim',[SliderPosMin SliderPosMax]);
set(get(mia_mainfigure_handles.D3CursorFigData.ImaHandlerZ,'parent'),'CLim',[SliderPosMin SliderPosMax]);

%guidata(handles.mia_mainfigure,mia_mainfigure_handles);

mia_Zpixval(mia_mainfigure_handles.D3CursorFigData.FigHandlerZ,'on');
handles.NewClim = NewClim;
% Update handles structure
guidata(hObject, handles);	    



% --- Executes on button press in SliceModebutton.
function SliceModebutton_Callback(hObject, eventdata, handles)
% hObject    handle to SliceModebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SliceModebutton

mia_mainfigure_handles = guidata(handles.mia_mainfigure);

delete(mia_mainfigure_handles.D3CursorFigData.FigHandlerY);




