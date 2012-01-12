function varargout = PCA3D_gui(varargin)
%function varargout = PCA3D_gui(varargin)
% PCA3D_GUI Application M-file for PCA3D_gui.fig
%    FIG = PCA3D_GUI launch PCA3D_gui GUI.
%    PCA3D_GUI('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 04-Sep-2001 01:59:16

% LAUNCH GUI
if nargin == 8  % LAUNCH GUI
	fig = openfig(mfilename,'reuse');

	% Use system color scheme for figure:
	set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);
    handles.imgt = varargin{1};
    handles.V = varargin{2};
    handles.imsize = varargin{3};
    handles.NumOfSlice = varargin{4};
    handles.Frame0 = varargin{5};
    handles.dirname = varargin{6};
    handles.scaninfo = varargin{7};
    handles.fileheader = varargin{8};
    guidata(handles.PCA3D_figure,handles);
    imsize = handles.imsize;
    NumOfSlice = handles.NumOfSlice;
    % plot the factor images
    PCAimg1 = reshape(double(handles.imgt)*handles.V(:,size(handles.V,1)),imsize,imsize,NumOfSlice);
    PCAimg2 = reshape(double(handles.imgt)*handles.V(:,size(handles.V,1)-1),imsize,imsize,NumOfSlice);
    PCAimg3 = reshape(double(handles.imgt)*handles.V(:,size(handles.V,1)-2),imsize,imsize,NumOfSlice);
    axes(handles.axes1);
    map=colormap(spectral);
    imagesc(PCAimg1(:,:,1));
    axes(handles.axes2);
    map=colormap(spectral);
    imagesc(PCAimg2(:,:,1));
    axes(handles.axes3);
    map=colormap(spectral);
    imagesc(PCAimg3(:,:,1));
    handles.PCAimg1 = PCAimg1;
    handles.PCAimg2 = PCAimg2;
    handles.PCAimg3 = PCAimg3;
    guidata(handles.PCA3D_figure,handles);
    
	if nargout > 0
		varargout{1} = fig;
	end
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
	
	try
		if (nargout)
			[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
		else
			feval(varargin{:}); % FEVAL switchyard
		end
	catch
		disp(lasterr);
	end
	
end


%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and 
%| sets objects' callback properties to call them through the FEVAL 
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the 
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.
% --------------------------------------------------------------------
function varargout = SBack1Button_Callback(h, eventdata, handles, varargin)
imsize = handles.imsize;
NumOfSlice  =  handles.NumOfSlice;
PCAimg1 = handles.PCAimg1;
current_slice = str2double(get(handles.Frame1edit,'String'));

if current_slice > 1
    current_slice = current_slice -1;
    
elseif current_slice == 1
    current_slice = NumOfSlice;
end
axes(handles.axes1);
%map=colormap(spectral);
imagesc(PCAimg1(:,:,current_slice));
set(handles.Frame1edit,'String',num2str(current_slice));

% --------------------------------------------------------------------
function varargout = SForw1Button_Callback(h, eventdata, handles, varargin)
imsize = handles.imsize;
NumOfSlice  =  handles.NumOfSlice;
PCAimg1 = handles.PCAimg1;
current_slice = str2double(get(handles.Frame1edit,'String'));

if current_slice < NumOfSlice
    current_slice = current_slice +1;
    
elseif current_slice == NumOfSlice
    current_slice = 1;
end
axes(handles.axes1);
%map=colormap(spectral);
imagesc(PCAimg1(:,:,current_slice));
set(handles.Frame1edit,'String',num2str(current_slice));
% --------------------------------------------------------------------
function varargout = Frame1edit_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = SBack2Button_Callback(h, eventdata, handles, varargin)
imsize = handles.imsize;
NumOfSlice  =  handles.NumOfSlice;
PCAimg2 = handles.PCAimg2;
current_slice = str2double(get(handles.Frame2edit,'String'));

if current_slice > 1
    current_slice = current_slice -1;
    
elseif current_slice == 1
    current_slice = NumOfSlice;
end
axes(handles.axes2);
%map=colormap(spectral);
imagesc(PCAimg2(:,:,current_slice));
set(handles.Frame2edit,'String',num2str(current_slice));

% --------------------------------------------------------------------
function varargout = SForw2Button_Callback(h, eventdata, handles, varargin)
imsize = handles.imsize;
NumOfSlice  =  handles.NumOfSlice;
PCAimg2 = handles.PCAimg2;
current_slice = str2double(get(handles.Frame2edit,'String'));

if current_slice < NumOfSlice
    current_slice = current_slice +1;
    
elseif current_slice == NumOfSlice
    current_slice = 1;
end
axes(handles.axes2);
%map=colormap(spectral);
imagesc(PCAimg2(:,:,current_slice));
set(handles.Frame2edit,'String',num2str(current_slice));
% --------------------------------------------------------------------
function varargout = Frame2edit_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = SBack3Button_Callback(h, eventdata, handles, varargin)
imsize = handles.imsize;
NumOfSlice  =  handles.NumOfSlice;
PCAimg3 = handles.PCAimg3;
current_slice = str2double(get(handles.Frame3edit,'String'));

if current_slice > 1
    current_slice = current_slice -1;
    
elseif current_slice == 1
    current_slice = NumOfSlice;
end
axes(handles.axes3);
%map=colormap(spectral);
imagesc(PCAimg3(:,:,current_slice));
set(handles.Frame3edit,'String',num2str(current_slice));
% --------------------------------------------------------------------
function varargout = Frame3edit_Callback(h, eventdata, handles, varargin)

imsize = handles.imsize;
NumOfSlice  =  handles.NumOfSlice;
PCAimg3 = handles.PCAimg3;
current_slice = str2double(get(handles.Frame3edit,'String'));

if current_slice < NumOfSlice
    current_slice = current_slice +1;
    
elseif current_slice == NumOfSlice
    current_slice = 1;
end
axes(handles.axes3);
%map=colormap(spectral);
imagesc(PCAimg3(:,:,current_slice));
set(handles.Frame3edit,'String',num2str(current_slice));

% --------------------------------------------------------------------
function varargout = KompNumberEdit_Callback(h, eventdata, handles, varargin)
KompNumber = str2double(get(handles.KompNumberEdit,'String'));
if KompNumber > size(handles.V,1) |  KompNumber < 1
    return;
end
imsize = handles.imsize;
NumOfSlice = handles.NumOfSlice;
% plot the factor images
PCAimg3 = reshape(double(handles.imgt)*handles.V(:,size(handles.V,1)-KompNumber+1),imsize,imsize,NumOfSlice);
handles.PCAimg3 = PCAimg3;
axes(handles.axes3);
imagesc(PCAimg3(:,:,1));
set(handles.Frame3edit,'String',num2str(1));
guidata(handles.PCA3D_figure,handles);


% --------------------------------------------------------------------
function varargout = SaveImagebutton_Callback(h, eventdata, handles, varargin)
KompNumber = str2double(get(handles.KompNumberEdit,'String'));
if KompNumber > size(handles.V,1) |  KompNumber < 1
    return;
end
NumOfSlice = handles.NumOfSlice;
imgout = handles.PCAimg3;
scaninfo = handles.scaninfo;
outfilename = [handles.dirname,'pc',scaninfo.rid,'_PCA',num2str(KompNumber),'_',num2str(scaninfo.rin), ...
        '_',num2str(scaninfo.brn),'.ima'];
% Negatív értékek eliminálása/PCAimg3 -> +min(PCAimg3(:))/
imgout = imgout + abs(min(imgout(:)));
% eliminálás vége
vaxfid = fopen(outfilename,'w','vaxd');
fwrite(vaxfid,handles.fileheader,'char');
for i = 1 : NumOfSlice
    slicemaxs(i) = max(max(imgout(:,:,i)));
    sliceout = rot90(imgout(:,:,i)*(32000)/slicemaxs(i));
    fwrite(vaxfid,sliceout,'ushort');
end
fclose(vaxfid);
%
% modify the CNTX and MAG mnemonics in the vax fileheader 
%
context = ['PCA',num2str(KompNumber),'      '];
scxheader_edit(outfilename, context, slicemaxs);
