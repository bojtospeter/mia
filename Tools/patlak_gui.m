function varargout = patlak_gui(varargin)
% PATLAK_GUI Application M-file for patlak_gui.fig
%    FIG = PATLAK_GUI launch patlak_gui GUI.
%    PATLAK_GUI('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 18-Aug-2003 22:57:12

	if nargin == 0  % LAUNCH GUI
	
		fig = openfig(mfilename,'reuse');
	
		% Use system color scheme for figure:
		set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));
	
		% Generate a structure of handles to pass to callbacks, and store it. 
		handles = guihandles(fig);
		guidata(fig, handles);
	
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
%   LoadIma button Callback
% --------------------------------------------------------------------
function varargout = LoadImaButton_Callback(h, eventdata, handles, varargin)
	%[FilesSelected, dir_path] = dir_gui;
    [FilesSelected, dir_path] = uigetfiles('*.ima;*.mnc;*.dcm;','Select dynamic PET files');
	handles.FileNames = sortrows(FilesSelected');
	handles.dirname = dir_path;
    %
    % identify the file type :mnc or ima, and
    % load the appropriate imaVOL
    %
    [fpath,fname,fextension,fversion] = fileparts(char(handles.FileNames(1)));
    handles.fextension = char(fextension);
    if strcmp(char(fextension),'.ima')
        num_of_files = size(handles.FileNames,1);
		for i=1:num_of_files
            filelist(i).name = char(handles.FileNames(i));
		end
		filelist = filelist';
	    filename=[];jobinfo=1;
        [handles.imaVOL, handles.scaninfo, handles.fileheader] = loadvaxima(filename,jobinfo,filelist,handles.dirname);
    elseif strcmp(char(fextension),'.mnc')
        [handles.imaVOL, handles.scaninfo] = loadminc([handles.dirname,char(handles.FileNames(1))]);
    elseif strcmp(char(fextension),'.dcm')
        [handles.imaVOL, handles.scaninfo] = loaddcm([handles.dirname,char(handles.FileNames(1))]);
    end
    
	guidata(handles.patlak_figure1,handles);
	set(handles.ImaListbox,'String',handles.FileNames,...
		'Value',1);
% --------------------------------------------------------------------
%   PatlakStart button Callback
% --------------------------------------------------------------------
function varargout = PatlakStartButton_Callback(h, eventdata, handles, varargin)
if ~isfield(handles,'imaVOL')
    return;
end
output ='no';
%
% Preparing the input parameters for Patlak analysis:
% bloodcurve, Conc.Scale Unit, glucose,LC
%
if get(handles.Blood_txtcheckbox,'Value')
    bloodtactfile = [handles.dirname,num2str(handles.scaninfo(1).brn),'.txt'];
else
    bloodtactfile = [handles.dirname,num2str(handles.scaninfo(1).brn),'.act']; 
end
if size(dir(bloodtactfile),1) == 0
    disp(['A vérgörbe input file (',bloodtactfile,') hiányzik!']);
    return;
end
micromolScaleYES = get(handles.UnitCheckbox,'Value');
glucose = str2double(get(handles.GlucoseEdit,'String'));
LC = str2double(get(handles.LCEdit,'String'));
%
% start the patlak analysis
%  
GMRvol = patlak(handles, bloodtactfile, glucose, LC, output, micromolScaleYES);
    
% --------------------------------------------------------------------
%   Exit(Close) button Callback
% --------------------------------------------------------------------
function varargout = ExitButton_Callback(h, eventdata, handles, varargin)
    delete(handles.patlak_figure1);
% --------------------------------------------------------------------
function varargout = LCEdit_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = GlucoseEdit_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = Blood_txtcheckbox_Callback(h, eventdata, handles, varargin)
	CurrentVal = get(handles.Blood_txtcheckbox,'Value');
	if CurrentVal 
        set(handles.Blood_actcheckbox,'Value',0);
	else
        set(handles.Blood_actcheckbox,'Value',1);
	end
	guidata(h, handles);    
% --------------------------------------------------------------------
function varargout = Blood_actcheckbox_Callback(h, eventdata, handles, varargin)
CurrentVal = get(handles.Blood_actcheckbox,'Value');
	if CurrentVal 
        set(handles.Blood_txtcheckbox,'Value',0);
	else
        set(handles.Blood_txtcheckbox,'Value',1);
	end
	guidata(h, handles);    
% --------------------------------------------------------------------
function varargout = ImaListbox_Callback(h, eventdata, handles, varargin)



% --------------------------------------------------------------------
function varargout = NormPushbutton_Callback(h, eventdata, handles, varargin)
if ~isfield(handles,'imaVOL')
    return;
end
num_of_petslice = 15;
index_selected = get(handles.ImaListbox,'Value');
file_list = get(handles.ImaListbox,'String');	
handles.normfilename = file_list{index_selected};
guidata(h, handles);
filename = [handles.dirname,handles.normfilename];
thres = str2double(get(handles.NormThresEdit,'String'));
%
%load the selected file and normalize the Volume
%
[handles.imaVOL, handles.scaninfo, fileheader] = loadvaxima(filename,0);
avg = mean(handles.imaVOL(:));
handles.imaVOL(find(handles.imaVOL<avg*thres))=0;
brain_range = find(handles.imaVOL(:) > avg*thres);
brain_avg = mean(handles.imaVOL(brain_range));
imaVOLout = double(handles.imaVOL)/brain_avg;
%
% save the output files
%
outfilename = [handles.dirname,'pc',handles.scaninfo(1).rid,'_GNORM_',num2str(handles.scaninfo(1).rin), ...
        '_',num2str(handles.scaninfo(1).brn),'.ima'];

vaxfid = fopen(outfilename,'w','vaxd');
fwrite(vaxfid,fileheader,'char');
for i = 1 : num_of_petslice
    slicemaxs(i) = max(max(imaVOLout(:,:,i)));
    sliceout = rot90(imaVOLout(:,:,i)*(32000)/slicemaxs(i));
    fwrite(vaxfid,sliceout,'ushort');
end
fclose(vaxfid);
%
% modify the CNTX and MAG mnemonics in the vax fileheader 
%
context = 'GNORM     ';
scxheader_edit(outfilename, context, slicemaxs);
disp(['The Global normalization Done!']);


% --------------------------------------------------------------------
function varargout = NormThresEdit_Callback(h, eventdata, handles, varargin)
index_selected = get(handles.ImaListbox,'Value');
file_list = get(handles.ImaListbox,'String');	
handles.normfilename = file_list{index_selected};
guidata(h, handles);
filename = [handles.dirname,handles.normfilename];
thres = str2double(get(handles.NormThresEdit,'String'));
%
%load the selected file and define the parameters
%
[handles.imaVOL, handles.scaninfo] = loadvaxima(filename,0);
avg = mean(handles.imaVOL(:));
brain_range = find(handles.imaVOL(:) > avg*thres);
brain_avg = mean(handles.imaVOL(brain_range));
disp(['Átlag érték: ',num2str(avg), ...
        '; Átlag a küszöbön felül: ',num2str(brain_avg)]);
handles.imaVOL(find(handles.imaVOL<avg*thres)) = 0;
%
% view the montage 
%
imaind = [];
for i=1:15
    imaind  = cat(4,imaind,fliplr(handles.imaVOL(:,:,i)));
end
figure;
map=colormap(spectral);
hm = montage(imaind,map);
set(hm,'CDataMapping','scaled')
set(gca,'position',[0 0 1 1]); 
hc = colorbar; set(hc,'position',[0.88 0 0.075 1]);
    


% --------------------------------------------------------------------
function varargout = UnitCheckbox_Callback(h, eventdata, handles, varargin)


% --- Executes on button press in DrawBloodCurveButton.
function DrawBloodCurveButton_Callback(hObject, eventdata, handles)
% hObject    handle to DrawBloodCurveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'imaVOL')
    if get(handles.Blood_txtcheckbox,'Value')
        bloodtactfile = [handles.dirname,num2str(handles.scaninfo(1).brn),'.txt'];
	else
        bloodtactfile = [handles.dirname,num2str(handles.scaninfo(1).brn),'.act']; 
	end
	if size(dir(bloodtactfile),1) == 0
        disp(['A vérgörbe input file (',bloodtactfile,') hiányzik!']);
        return;
	end
    tissue_ts = handles.scaninfo(1).tissue_ts/60; %[min];
    frame_lengths = handles.scaninfo(1).frame_lengths/60; %[min];
    if strcmp(bloodtactfile(end-2:end),'act');
        actdata = loadtacts(bloodtactfile);
        num_of_tact = size(actdata,2)-1;
        bloodtact_index=2;
        bloodpar = eval_bloodcurve_par(actdata(1).tact,actdata(bloodtact_index).tact);
	else
        blooddata = load(bloodtactfile);
        bloodpar = eval_bloodcurve_par(blooddata(:,1),blooddata(:,2));
	end
	blood_delay=bloodpar(7);
	tissue_ts=tissue_ts+blood_delay;
	%
	%  creating the fine time and blood scale
	%
	dtime=10/60;%[10 sec]
	finesteps=round(max(tissue_ts)/dtime);
	fine_ts=dtime*(0:1:finesteps-1)';
	blood_fas=bloodcurve(fine_ts, bloodpar);
	intp_blood_as = bloodcurve(tissue_ts,bloodpar);
	%
	% plot the blood curve
	%
	bch = figure;
	plot(fine_ts,blood_fas,'-r','LineWidth',2);
	hold on;
	plot(blooddata(:,1),blooddata(:,2),'or');
	xlabel('Time [min]');
	ylabel('Activity conc. [nCi/ml]');
	title(['Blood curve',' Patientcode: ',num2str(handles.scaninfo(1).brn)]);
	pause(1);
	print(bch,'-dbmp',[handles.dirname,'bloodcurve_',num2str(handles.scaninfo(1).brn),'.bmp']);
end

