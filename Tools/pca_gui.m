function varargout = PCA_gui(varargin)
% PCA_GUI Application M-file for PCA_gui.fig
%    FIG = PCA_GUI launch PCA_gui GUI.
%    PCA_GUI('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 30-May-2002 14:02:29

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
	% select the desired file names 
    %[FilesSelected, dir_path] = dir_gui;
    [FilesSelected, dir_path] = uigetfiles('*.ima*','Select PET ima files');
    pause(2);
	handles.FileNames = sortrows(FilesSelected');
	handles.dirname = dir_path;
	guidata(handles.PCA_figure1,handles);
	set(handles.ImaListbox,'String',handles.FileNames,...
		'Value',1);
    output ='no';
    
    % loading the files
	num_of_files = size(handles.FileNames,1);
	for i=1:num_of_files
        filelist(i).name = char(handles.FileNames(i));
	end
	filelist = filelist';filename=[];jobinfo=1;
	%[handles.imaVOL, handles.scaninfo handles.fileheader] = loadvaxima128(filename,jobinfo,filelist,handles.dirname);
    [handles.imaVOL, handles.scaninfo handles.fileheader] = loadvaxima(filename,jobinfo,filelist,handles.dirname);
    if handles.scaninfo.imfm(1) ~= 128
        imaVOLtmp = zeros(128,128,size(handles.imaVOL,3),'uint16');
        for i=1 :size(handles.imaVOL,3);
            imaVOLtmp(:,:,i) = imresize(handles.imaVOL(:,:,i),[128 128]);
        end
        handles.imaVOL = [];
        handles.imaVOL = imaVOLtmp;
        imaVOLtmp = [];
        handles.scaninfo.imfm = [128, 128];
    end
    
    %handles.imaVOL = uint16(imaVOL); imaVOL =[];
    handles.num_of_petslices = 15;
	imsize=size(handles.imaVOL,1);
	num_of_slice = size(handles.imaVOL,3);
	%
	% Generate the time scales
	%
	handles.Frames = handles.scaninfo.Frames;
	scan_start = 0;
% 	for j=1 : handles.Frames   
%         if j>1
%             scan_start(j) =  scan_start(j-1) + handles.scaninfo(j-1).mtm/60;
%             tissue_ts(j) = scan_start(j) + (handles.scaninfo(j).mtm/60)/2;
%         else
%             tissue_ts(j) = (handles.scaninfo(j).mtm/60)/2;
%         end
%         FrameLengths(j) = (handles.scaninfo(j).mtm/60); 
% 	end

	handles.tissue_ts =  handles.scaninfo.tissue_ts/60;
	handles.FrameLengths = handles.scaninfo.frame_lengths/60;
    guidata(handles.PCA_figure1,handles);
    %
    % Ha ez már nem az elso fájlbetöltés, akkor törölni kell a 3D maszkoláshoz
    % használt korábbi handles.sumimg mezot.
    %
	if isfield(handles,'sumimg')
        handles = rmfield(handles,'sumimg');
        guidata(handles.PCA_figure1,handles);
    end
    

% --------------------------------------------------------------------
%   StartSum button Callback
% --------------------------------------------------------------------
function varargout = StartSumButton_Callback(h, eventdata, handles, varargin)
%
% Sum the last N frames and generate a montage from the slices
%
N = str2double(get(handles.SumNEdit,'String'));
NofSlice = handles.num_of_petslices;
imsize = 128;
if N<1 | N> handles.Frames
    disp('Az N értéke nem megfelelo az összegzéshez');beep;
    return
end
imaind = [];
sumimg = zeros(imsize,imsize,NofSlice);imagesummed =zeros(imsize,imsize);
for i = 1 :NofSlice
    slicetmp = handles.imaVOL(:,:,[i+(handles.Frames-N)*NofSlice: NofSlice : i+(handles.Frames-1)*NofSlice]);
    %slicetmp = imaVOL(:,:,[i : 15 : i+(handles.Frames-1)*15]);
    imagesummed(:) =0;
    for fr = 1 : N
        imagesummed = imagesummed + double(slicetmp(:,:,fr))*handles.FrameLengths(handles.Frames-N+fr);
    end
    sumimg(:,:,i) = imagesummed/sum(handles.FrameLengths(handles.Frames-N+1:handles.Frames));
end
for i=1:NofSlice
    imaind  = cat(4,imaind,fliplr(sumimg(:,:,i)));
end
fh = figure(1);
map=colormap(spectral);
hm = montage(imaind,map);
set(hm,'CDataMapping','scaled');
set(gca,'position',[0 0 1 1]); 
hc = colorbar; set(hc,'position',[0.88 0 0.075 1]);
title(['Double click on the slice you want to use for PCA.',...
        ' PET ID (brn): ', num2str(handles.scaninfo(1).brn) ]);
%
% User input for desired slice number to use for mask area
% in the transaxial slice
%
pause(1);
disp('Double click on the slice you want to use for PCA.');
[xin,yin] = getpts(figure(1)); x=xin(1);y=yin(1);
FigRes = get(gca,'PlotBoxAspectRatio');
col_num = fix(x/(FigRes(1)/4))+1;row_num = fix(y/(FigRes(1)/4))+1;SliceNumber = (row_num-1)*4+col_num;
close(fh);
handles.SelSliceNumber = SliceNumber;
handles.sumimg = sumimg;
handles.frameforsum = 0;
guidata(handles.PCA_figure1,handles);
set(handles.FrameForSumEdit,'String',num2str(handles.frameforsum));
axes(handles.ImaAxes);
%set(handles.ImaAxes,'Visible','off');
map=colormap(spectral);
imagesc(sumimg(:,:,SliceNumber));
set(handles.ImaAxes,'Yticklabel',{});
set(handles.ImaAxes,'Xticklabel',{});

% --------------------------------------------------------------------
%   StartPCA button Callback
% --------------------------------------------------------------------
function varargout = PCAStartButton_Callback(h, eventdata, handles, varargin)
Frame0 = str2double(get(handles.Frame0Edit,'String'));
Frames = handles.Frames;
sumimg = handles.sumimg;
SliceNumber = handles.SelSliceNumber;
tissue_ts = handles.tissue_ts;
imsize = 128;
imgt = zeros(imsize*imsize,Frames-Frame0);
zpx = [];
SelROIYes = get(handles.SelROICheckbox,'Value');
% Ha már léteznek PCA ábrák, akkor azokat törölni kell
if isfield(handles,'fh')
    for i=1 : size(handles.fh,2)
            if ishandle(handles.fh(i))
                delete(handles.fh(i));
            end
    end
    handles = rmfield(handles,'fh');
    guidata(handles.PCA_figure1,handles);
end
if SelROIYes
    disp('Define the ROI mask for PCA.');beep;
    BW = roipoly;
    zpx = find(BW==0);
end
% 
if size(zpx,1) > 1 
    for i=Frame0:Frames
        imgt(:,i-Frame0+1)= reshape(handles.imaVOL(:,:,SliceNumber+(i-1)*15),imsize*imsize,1);
        imgt(zpx,i-Frame0+1) = 0;
    end
else
    for i=Frame0:Frames
        imgt(:,i-Frame0+1)= reshape(handles.imaVOL(:,:,SliceNumber+(i-1)*15),imsize*imsize,1);
    end
end
px = find(sumimg(:,:,SliceNumber) > mean(mean(sumimg(:,:,SliceNumber))));
imgt_masked=imgt(px,:);
cov_img=cov(imgt_masked);
[V,D] = eig(cov_img);
DD1=diag(D);	
handles.fh(1) = figure('Position',[10 600 400 300]);            
semilogy([Frame0:Frames],DD1,'*g');
xlabel(['Factor serial number']);
ylabel(['Relative weigth of the factors']);
handles.fh(2) = figure('Position',[420 600 400 300]);
hold on;
plot(tissue_ts(Frame0:Frames),V(:,Frames-Frame0+1),'b-');
plot(tissue_ts(Frame0:Frames),V(:,Frames-Frame0),'g-');
plot(tissue_ts(Frame0:Frames),V(:,Frames-Frame0-1),'y-');
legend('1.factor','2.factor','3.factor');
xlabel(['time [min]']);
ylabel(['Scale of Factors [arb. unit]']);
handles.fh(3) = figure('Position',[10 40 400 300]);
imagesc(reshape(imgt*V(:,size(V,1)),128,128));colorbar;
title(['Factor Image 1.']);
handles.fh(4) = figure('Position',[420 40 400 300]);
imagesc(reshape(imgt*V(:,size(V,1)-1),128,128));colorbar;
title(['Factor Image 2.']);
handles.fh(5) = figure('Position',[830 40 400 300]);
imagesc(reshape(imgt*V(:,size(V,1)-2),128,128));colorbar;
title(['Factor Image 3.']);
guidata(handles.PCA_figure1,handles);
% --------------------------------------------------------------------
%   SliceForwardButton Callback
% --------------------------------------------------------------------
function varargout = SliceForwardButton_Callback(h, eventdata, handles, varargin)
if ~isfield(handles,'SelSliceNumber')
    return;
end
Frames = handles.Frames;
sumimg = handles.sumimg;
SliceNumber = handles.SelSliceNumber;    
current_frame = handles.frameforsum;
NofSlice = handles.num_of_petslices;
if current_frame < Frames
    current_frame = current_frame +1;
    axes(handles.ImaAxes);
    map=colormap(spectral);
    imagesc(handles.imaVOL(:,:,SliceNumber+(current_frame-1)*NofSlice));
    handles.frameforsum = current_frame;
    set(handles.FrameForSumEdit,'String',num2str(handles.frameforsum));
elseif current_frame == Frames
    current_frame = 0;
    axes(handles.ImaAxes);
    map=colormap(spectral);
    imagesc(sumimg(:,:,SliceNumber));
    handles.frameforsum = current_frame;
    set(handles.FrameForSumEdit,'String',num2str(handles.frameforsum));
elseif current_frame == 0
    axes(handles.ImaAxes);
    map=colormap(spectral);
    imagesc(handles.imaVOL(:,:,SliceNumber));
    handles.frameforsum = 1;
    set(handles.FrameForSumEdit,'String',num2str(handles.frameforsum));
end
set(handles.ImaAxes,'Yticklabel',{});
set(handles.ImaAxes,'Xticklabel',{});
guidata(handles.PCA_figure1,handles);
% --------------------------------------------------------------------
%   SliceBackwardButton Callback
% --------------------------------------------------------------------
function varargout = SliceBackwardButton_Callback(h, eventdata, handles, varargin)
if ~isfield(handles,'SelSliceNumber')
    return
end
Frames = handles.Frames;
sumimg = handles.sumimg;
SliceNumber = handles.SelSliceNumber;    
current_frame = handles.frameforsum;
NofSlice = handles.num_of_petslices;
if current_frame > 1
    current_frame = current_frame -1;
    axes(handles.ImaAxes);
    map=colormap(spectral);
    imagesc(handles.imaVOL(:,:,SliceNumber+(current_frame-1)*NofSlice));
    handles.frameforsum = current_frame;
    set(handles.FrameForSumEdit,'String',num2str(handles.frameforsum));
elseif current_frame == 1
    current_frame = 0;
    axes(handles.ImaAxes);
    map=colormap(spectral);
    imagesc(sumimg(:,:,SliceNumber));
    handles.frameforsum = current_frame;
    set(handles.FrameForSumEdit,'String',num2str(handles.frameforsum));
elseif current_frame == 0
    current_frame = Frames;
    axes(handles.ImaAxes);
    map=colormap(spectral);
    imagesc(handles.imaVOL(:,:,SliceNumber+(Frames-1)*NofSlice));
    handles.frameforsum = current_frame;
    set(handles.FrameForSumEdit,'String',num2str(handles.frameforsum));
end
set(handles.ImaAxes,'Yticklabel',{});
set(handles.ImaAxes,'Xticklabel',{});
guidata(handles.PCA_figure1,handles);
% --------------------------------------------------------------------
%   3DPCAStart button Callback
% --------------------------------------------------------------------
function varargout = PCA3DStartButton_Callback(h, eventdata, handles, varargin)
imsize=128;
NumOfSlice = handles.num_of_petslices;
Frame0 = str2double(get(handles.Frame0Edit,'String'));
Frames = handles.Frames;
tissue_ts = handles.tissue_ts;
% Ha már léteznek PCA ábrák, akkor azokat törölni kell
if isfield(handles,'fh')
    for i=1 : 2
        if ishandle(handles.fh(i))
            delete(handles.fh(i));
        end
    end
    handles = rmfield(handles,'fh');
    guidata(handles.PCA_figure1,handles);
end
% Ha még nincs sumimg akkor létre kell hozni
if ~isfield(handles,'sumimg')
    N=4; %az utolsó N frame összegzése
	sumimg = zeros(imsize,imsize,NumOfSlice);imagesummed =zeros(imsize,imsize);
	for i = 1 :NumOfSlice
        slicetmp = handles.imaVOL(:,:,[i+(handles.Frames-N)*NumOfSlice: NumOfSlice : i+(handles.Frames-1)*NumOfSlice]);
        %slicetmp = imaVOL(:,:,[i : 15 : i+(handles.Frames-1)*15]);
        imagesummed(:) =0;
        for fr = 1 : N
            imagesummed = imagesummed + double(slicetmp(:,:,fr))*handles.FrameLengths(handles.Frames-N+fr);
        end
        sumimg(:,:,i) = imagesummed/sum(handles.FrameLengths(handles.Frames-N+1:handles.Frames));
	end
    handles.sumimg = sumimg;
    guidata(handles.PCA_figure1,handles);
else
    sumimg = handles.sumimg;
end
% elokészület a 3DPCA-hoz
% setting up the progression bar
info.color=[1 0 0];
info.title='3DPCA progress';
info.size=1;
info.pos='topleft';
p=progbar(info);
progbar(p,0);
imgt = uint16(zeros(imsize*imsize*NumOfSlice,Frames-Frame0));
for i=Frame0:Frames
    imgt(:,i-Frame0+1)= handles.imaVOL([imsize*imsize*NumOfSlice*(i-1)+1:imsize*imsize*NumOfSlice*i])';
    progbar(p,round(i*100/(Frames-Frame0)));drawnow;
end
px = find(sumimg(:) > mean(mean(sumimg(:))));
pxz = find(sumimg(:) < mean(mean(sumimg(:))));
imgt(pxz,:) = 0; 
imgt_masked=imgt(px,:);
% start PCA main part
cov_img=cov(double(imgt_masked));
[V,D] = eig(cov_img);
DD1=diag(D);	
% end PCA main part
close(p);
handles.fh(1) = figure('Position',[10 600 400 300]);            
semilogy([Frame0:Frames],DD1,'*g');
xlabel(['Factor serial number']);
ylabel(['Relative weigth of the factors']);
handles.fh(2) = figure('Position',[420 600 400 300]);
hold on;
plot(tissue_ts(Frame0:Frames),V(:,Frames-Frame0+1),'b-');
plot(tissue_ts(Frame0:Frames),V(:,Frames-Frame0),'g-');
plot(tissue_ts(Frame0:Frames),V(:,Frames-Frame0-1),'y-');
legend('1.factor','2.factor','3.factor');
xlabel(['time [min]']);
ylabel(['Scale of Factors [arb. unit]']);
retval = pca3d_gui(imgt,V,imsize,NumOfSlice,Frame0,handles.dirname,handles.scaninfo(1),handles.fileheader);
guidata(handles.PCA_figure1,handles);
% --------------------------------------------------------------------
%   Exit(Close) button Callback
% --------------------------------------------------------------------
function varargout = ExitButton_Callback(h, eventdata, handles, varargin)
    delete(handles.PCA_figure1);
% --------------------------------------------------------------------
