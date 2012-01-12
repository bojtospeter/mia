function varargout = TACTgui(varargin)
% function varargout = dirlistbox(varargin)
warning off;
if nargin <= 1   % LAUNCH GUI
	if nargin == 0 
		initial_dir = pwd;
	elseif nargin == 1 & exist(varargin{1},'dir')  
		initial_dir = varargin{1};
	else
		errordlg('Input argument must be a valid directory','Input Argument Error!')
		return
	end
	% Open FIG-file
	fig = openfig(mfilename,'reuse');	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);
	% Populate the listbox1 and the statusinfo items
	load_listbox(initial_dir,handles);
    set(handles.statusinfo,'String','Evaluation is not running');
	% Return figure handle as first output argument
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
% ------------------------------------------------------------
% Callback for list box - open .fig with guide, otherwise use open
% ------------------------------------------------------------
function varargout = listbox1_Callback(h, eventdata, handles, varargin)
if strcmp(get(handles.figure1,'SelectionType'),'open')
	index_selected = get(handles.listbox1,'Value');
	file_list = get(handles.listbox1,'String');	
	handles.actfilename = file_list{index_selected};
	if  handles.is_dir(handles.sorted_index(index_selected))
		cd (handles.actfilename)
		load_listbox(pwd,handles)
	else
        [path,name,ext,ver] = fileparts(handles.actfilename);
	    if strcmp(ext,'.seq') | strcmp(ext,'.txt')  
		   eval(['open ',handles.actfilename]);
        end
		try
        	actdata = loadtacts(handles.actfilename);
            load_VOIlistbox(actdata,handles);
		catch
			errordlg(lasterr,'File Type Error','modal')
		end	
   end
end
% ------------------------------------------------------------
% Read the current directory and sort the names
% ------------------------------------------------------------
function load_listbox(dir_path,handles)
%dir_path = [dir_path,'\*.act'];
cd (dir_path)
dir_struct = dir(dir_path);
%
% sort the list: first the directory list, next the filelist
%
filenames = {dir_struct.name}';
dirrange = find([dir_struct.isdir]'); filerange = find(~[dir_struct.isdir]');
files = filenames(filerange); dirs = filenames(dirrange);
[list1,sindex1] = sortrows(lower(dirs));
[list2,sindex2] = sortrows(lower(files));
sorted_names = [dirs(sindex1); files(sindex2)];
sorted_index = [dirrange(sindex1); filerange(sindex2)];
%[sorted_names,sorted_index] = sortrows({dir_struct.name}');
handles.file_names = sorted_names;
handles.is_dir = [dir_struct.isdir];
handles.sorted_index = [sorted_index];
guidata(handles.figure1,handles);
set(handles.listbox1,'String',handles.file_names,...
	'Value',1);
set(handles.text1,'String',pwd);
%--------------------------------------------------------------------
% Read the current VOI list and write to the VOIListBOX 
% ------------------------------------------------------------
function load_VOIlistbox(actdata,handles)
[sorted_names,sorted_index] = sortrows({actdata(2:end).name}');
handles.VOI_names = sorted_names;
guidata(handles.figure1,handles);
set(handles.VOI_listbox,'String',handles.VOI_names,...
	'Value',1);

% --------------------------------------------------------------------
function varargout = listbox1_ButtonDownFcn(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = exitbutton_Callback(h, eventdata, handles, varargin)
delete(handles.figure1);
% --------------------------------------------------------------------
function varargout = text1_Callback(h, eventdata, handles, varargin)
dir_path = get(handles.text1,'String');
cd (dir_path)
dir_struct = dir(dir_path);
%
% sort the list: first the directory list, next the filelist
%
filenames = {dir_struct.name}';
dirrange = find([dir_struct.isdir]'); filerange = find(~[dir_struct.isdir]');
files = filenames(filerange); dirs = filenames(dirrange);
[list1,sindex1] = sortrows(lower(dirs));
[list2,sindex2] = sortrows(lower(files));
sorted_names = [dirs(sindex1); files(sindex2)];
sorted_index = [dirrange(sindex1); filerange(sindex2)];
%[sorted_names,sorted_index] = sortrows({dir_struct.name}');
handles.file_names = sorted_names;
handles.is_dir = [dir_struct.isdir];
handles.sorted_index = [sorted_index];
guidata(handles.figure1,handles);
set(handles.listbox1,'String',handles.file_names,...
	'Value',1);
% --------------------------------------------------------------------
function varargout = glocose_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = VOI_listbox_Callback(h, eventdata, handles, varargin)
if strcmp(get(handles.figure1,'SelectionType'),'open')
	index_selected = get(handles.VOI_listbox,'Value');
	VOIlist = get(handles.VOI_listbox,'String');	
	bloodVOIname = VOIlist{index_selected};
    glucose = str2double(get(handles.glucose,'String'));
    injact = str2double(get(handles.injact,'String'));
    bodyweight = str2double(get(handles.bodyweight,'String'));
	try
        bloodVOIname = [];
    	EvalFDGtact_ingui(handles.actfilename,glucose,bloodVOIname,bodyweight,injact,handles);
        set(handles.statusinfo,'String','Evaluation of TACT curves is done.');
	catch
		errordlg(lasterr,'File Type Error','modal')
	end	
end
% --------------------------------------------------------------------
function varargout = CloseAllFigure_Callback(h, eventdata, handles, varargin)
close all;
%----------------------------------------------------------------------
function LoadFDGtact_ingui(handles) 
% function LoadFDGtact(handles) 
% 
% created 2002.02.21 by BL 
%
actdata = loadtacts(tactfile);
load_VOIlistbox(actdata,handles);

%----------------------------------------------------------------------
function EvalFDGtact_ingui(tactfile, glucose, bloodVOIname, bodyweight, injact, handles) 
% function res = evalfdgtact(tactfile,glucose,bloodfile) 
% 
% created 2002.02.21 by BL 
%
global  fine_ts blood_fas tissue_as tissue_ts ...
A  B dtime  tissue_fit  dtime_scale bloodpar bloodpath err
		
LC=0.42;
glucose = glucose*180/10;
bloodfile = [];
    % unit (mMol/l to mg/100g). The glucose Mol. weight: 180 g/mol.
%
%loading the tact curves to the actdata structure
%
actdata = loadtacts(tactfile);
num_of_tact = size(actdata,2)-1;
%	
% creating the tissue and fine time scales
%
tissue_ts = actdata(1).tact;
dtime=10/60;%[10 sec]
finesteps=round(max(tissue_ts)/dtime);
fine_ts=dtime*(0:1:finesteps-1)';
%    
%reading the blood parameter file
%	
if ~isempty(bloodVOIname)
    bloodtact_index=2;
    i=2;
    while ~strcmp(actdata(i).name,bloodVOIname)
        i=i+1;
    end
    bloodtact_index = i;
    set(handles.statusinfo,'String','Start the blood curve fitting procedure ... ');
    bloodpar = eval_bloodcurve_par(actdata(1).tact,actdata(bloodtact_index).tact);
else
    [FilesSelected, dir_path] = uigetfiles('*.txt','Blood txt input');
    bloodtactfile = [dir_path,char(FilesSelected)]; 
    blooddata = load(bloodtactfile);
    bloodpar = eval_bloodcurve_par(blooddata(:,1),blooddata(:,2));
    bloodtact_index = 0;
end
blood_fas=bloodcurve(fine_ts, bloodpar);
blood_delay=bloodpar(7);
tissue_ts = tissue_ts+blood_delay;
%
% FDG kinetic analysis loop
%
defrange = [1:size(actdata,2)];
looprange =  find( defrange > 1 & defrange ~= bloodtact_index);
results = [];
for j = looprange
    tissue_as = actdata(j).tact;
    voiname  = actdata(j).name;
    disp(['The name of TACT is under processing: ',voiname]);
    set(handles.statusinfo,'String',['The name of TACT is under processing: ',voiname]);
    pause(3);
    tissue_fas=interp1(tissue_ts,tissue_as,fine_ts);
%
%start the fitting of tissue curve for calculating k's
%	
    t0 = clock; 
    k0=[0.102 0.13 0.062 0.0006 0.05];
	
    % making a guess for max k(5)
    maxblood=max(blood_fas);
    where_blood_max=find(blood_fas == maxblood);
    tmax=fine_ts(where_blood_max);
    tissue_at_tmax = max(tissue_as(find(tissue_ts <= tmax)));
    %tissue_at_tmax =max(tissue_as(1:3));
    %k5max = tissue_at_tmax/maxblood;
    k5max = tissue_fas(where_blood_max)/maxblood;
    k0(5)=k5max/2;
    k=k0;
    A=[	-(k(2)+k(3)) 	k(4) 		0
        k(3) 		-k(4) 		0
    	(1-k(5))	(1-k(5))	0];
    %		1		1		0];
    B=[ 	k(1)	0	k(5)]';
    % options for optimization
    options(1)=1;		% display opt. output
    options(2)=1e-6;	%termination criteria for x
	options(3)=1;		% Termination criteria for f 
	options(4)=1e-8;	% Termination criteria for g
	%	options(16)=5e-5;	% Min perturb
	%	options(17)=0.1;	% Max perturb
	options(14)=500;	% max num. of step
	
	%	vlb=[0.0, 0.000001, 0.000001, 0.0, 0.1]; 
	vlb=[0.0, 0.0001, 0.00001, 0.0, k5max]; 
		%in order to eliminate the k2 + k3 =0 value the minimums ...
		%are set to 0.0001. This is important for calculating g 
		%in the fitfdg.m, because the g=k(1)*k(3)/(k(2)+k(3))*glucose/LC;
					
	%       vub = [1, 2, 2, 1, k5max]
	vub = [1, 2, 1, 0.1, 1];
	%	vub = [2, 3, 20, 20, 2];
	[k,options]=constr('fitfdg3',k0,options,vlb,vub);
	K =  k(1)*k(3)/(k(2)+k(3));  
	LCGMR=K*glucose/LC;
    %
    %SUV calculation
    %
    scan_time(1) = 2*tissue_ts(1);%scan_time currently is not used for suv calc
    for i=2:length(tissue_ts)
        scan_time(i)=scan_time(i-1)+2*(tissue_ts(i)-scan_time(i-1));
    end
    suv = sum(tissue_as(end-3:end))/4; %the last 4 frame (the last 20 min) is used for suv calc.    
    suv = suv *bodyweight/injact*1/1000; %activity and bodyweight normalization
	%	eredmeny=[LCGMR, k, elapse_time, error2];
	eredmeny = [LCGMR, k, suv, err];
	%
	%plot results
	%
    hn(j) = figure('Position',[10 40 600 250]);
    subplot(1,2,1);
	maxY=max(tissue_fas);
	maxX=max(tissue_fit);
	plot(fine_ts,blood_fas,'r-');
	hold on
	plot(fine_ts,tissue_fit,'g-');
	plot(tissue_ts,tissue_as,'bo');
	%		axis([0 60 0 1800]);
	title(['Blood and fitted tissue curves']);
	xlabel('time [min]');
	ylabel('Activity concentration [nCi/ml]');
			%text(round(maxX/40),round(maxY*3/5),text1);
			%text(round(maxX/40),round(maxY*1/5),text2);
	pause(3);
	
	%save res56355 fine_ts blood_fas tissue_fit -ascii;
	%save ny46_2 tissue_ts tissue_as  -ascii ;
	
	subplot(1,2,2);
	maxY=max(tissue_fas);
	maxX=max(tissue_fit);
	text1=['k1 = ',num2str(k(1)),' k2 = ',num2str(k(2)),' k3 = ', ...
		num2str(k(3)),' k4 = ',num2str(k(4)),' v0 = ',... 
		num2str(k(5)),'  [1/min]'];
	text2=['LGMR = ',num2str(LCGMR),' mg/min/100g  SUV = ',num2str(suv)];
    text3=['K= ',num2str(K),' 1/min'];
	hold on
	plot(fine_ts,tissue_fit,'g-');
	plot(tissue_ts,tissue_as,'bo');
	title(['Input and fitted tissue curves.   ' ...
		,'Patient code: ',...
		'  VOI name: ', voiname,'  Printed: ',date ]);
	xlabel('time [min]');
	ylabel('Activity concentration [nCi/ml]');
	text(round(maxX/500),round(maxY*3/5),text1);
	text(round(maxX/500),round(maxY*2/5),text2);
	text(round(maxX/500),round(maxY*1/5),text3);
	pause(3);
    results = [results; eredmeny];    
end
%
% save the results
%
resfile  = [tactfile(1:length(tactfile)-5),'_res.txt']; 
if ~isempty(bloodVOIname)
    num_of_res = num_of_tact -1;
else
    num_of_res = num_of_tact;
end
VOInames = {actdata(looprange).name}';
voiprint = cell2struct(VOInames,'name',2);
fid = fopen( resfile, 'w+');
fprintf( fid, 'VOI  LGMR    K1  K2  K3  K4  v0  SUV Error\n');
for i= 1: num_of_res
        voiname = VOInames(i);
        fprintf( fid, '%s  ', voiprint(i).name);
        fprintf( fid, '%f  ', results( i, :));
        fprintf( fid, '\n');
end
fclose(fid);
disp(' ');
disp(['The results can be found in: ',resfile]);

%		ans=input('Do you want to print the Figure?("y=1"/"n=0"):  ');
%		if ans == 1
%			print;
%		end








% --------------------------------------------------------------------
function varargout = bodyweight_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = injact_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = statusinfo_Callback(h, eventdata, handles, varargin)

