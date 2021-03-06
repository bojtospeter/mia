function [imaVOL,scaninfo] = loadminc(filename)
%function [imaVOL,scaninfo] = loadminc(filename)
%
% Function to load minc format input file. 
% This function use the emma_v0_9_5 utility from MNI.
%
% Matlab library function for MIA_gui utility. 
% University of Debrecen, PET Center/LB 2003
if nargin == 0
     [FileName, FilePath] = uigetfile('*.mnc','Select minc file');
     filename = [FilePath,FileName];
     if FileName == 0;
          imaVOL = [];scaninfo = [];
          return;
     end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% open minc file & get the needed image parameters (scaninfo)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
isEmmaExist = which('openimage');
if isempty(isEmmaExist);
          imaVOL = [];scaninfo = [];
          disp('');
          disp('For reading minc file you should install the EMMA package from MNI.');
          disp('For more info see the MIA help');
          disp('');
          return;
end

handle   = openimage( filename );
jobinfo = 1;
% SETTING UP THE PROGRESS BAR
if jobinfo
    info.color=[1 0 0];
	info.title='Loading minc file';
	info.size=1;
    info.pos='topleft';
	p=progbar(info);
	progbar(p,0);
end
%
% get info from minc file and save them in the scaninfo structure 
%
scaninfo.pnm	   = miinquire ( filename, 'attvalue', 'patient', 'full_name');	
scaninfo.brn       = miinquire ( filename, 'attvalue', 'patient',   'brn');
scaninfo.rid	   = miinquire ( filename, 'attvalue', 'scanditronix', 'RID');	
scaninfo.rin	   = miinquire ( filename, 'attvalue', 'study',   'study_rin');		
scaninfo.daty	   = miinquire ( filename, 'attvalue', 'study',   'start_year');
scaninfo.datm	   = miinquire ( filename, 'attvalue', 'study',   'start_month');
scaninfo.datd      = miinquire ( filename, 'attvalue', 'study',   'start_day');
scaninfo.timh	   = miinquire ( filename, 'attvalue', 'study',   'start_hour');
scaninfo.timm	   = miinquire ( filename, 'attvalue', 'study',   'start_minute');
scaninfo.tims	   = miinquire ( filename, 'attvalue', 'study',   'start_seconds');	
scaninfo.mtm       = [];
scaninfo.iso 	   = miinquire ( filename, 'attvalue', 'acquisition', 'radionuclide');
scaninfo.half      = miinquire ( filename, 'attvalue', 'acquisition', 'radionuclide_halflife')/60;%min
scaninfo.trat       = [];
scaninfo.imfm  	    = getimageinfo(handle,'ImageSize')';
scaninfo.cntx      = miinquire ( filename, 'attvalue', 'study',   'cntx');
scaninfo.cal       = [];
scaninfo.min       = [];
scaninfo.mag       = [];
pixsizex = miinquire ( filename, 'attvalue', 'xspace',   'step');
pixsizey = miinquire ( filename, 'attvalue', 'yspace',   'step');
pixsizez = miinquire ( filename, 'attvalue', 'zspace',   'step');
x_start = miinquire ( filename, 'attvalue', 'xspace',   'start');
if isempty(x_start)
    x_start = 0;
end
y_start = miinquire ( filename, 'attvalue', 'yspace',   'start');
if isempty(y_start)
    y_start = 0;
end
z_start = miinquire ( filename, 'attvalue', 'zspace',   'start');
if isempty(z_start)
    z_start = 0;
end
scaninfo.pixsize = abs([pixsizex pixsizey pixsizez]); % abs: Strange could happen
scaninfo.space_start = ([x_start y_start z_start]);
if scaninfo.pixsize(3) == 0 
   button = questdlg('The Z pixel size is 0! Do you want to continue?',...
'Continue Operation','Yes','No','No');
	if strcmp(button,'No')
        imaVOL = [];
        scaninfo = [];
        return;
    else
        prompt = {['Enter Z pixel size(mm) /X,Y size are '...
                        ,num2str(scaninfo.pixsize(1)),',',num2str(scaninfo.pixsize(2)),'/ :']};
		dlg_title = 'Input for pixel size';
		num_lines= 1;
		def     = {'1'};
		scaninfo.pixsize(3)  = str2double(inputdlg(prompt,dlg_title,num_lines,def));
    end
end
scaninfo.start_times     = getimageinfo(handle,'FrameTimes')';
scaninfo.frame_lengths    = getimageinfo(handle,'FrameLengths')';
scaninfo.tissue_ts  = getimageinfo(handle,'MidFrameTimes')';%[min];
scaninfo.Frames     = length(scaninfo.tissue_ts);
if scaninfo.Frames == 0
    scaninfo.Frames = 1;
end
scaninfo.num_of_slice    = getimageinfo(handle,'NumSlices');
MinMax = getimageinfo(handle,'minmax'); 
if MinMax(2) == round(MinMax(2)) || ~isempty(strfind(scaninfo.cntx,'wbfdg'))  % if imaVOL type is not float
    scaninfo.float = 0;
else
    scaninfo.float = 1;
end
scaninfo.FileType    = 'mnc';
%
% creating the imaVOL
%
if scaninfo.Frames > 1
    imaVOL = int16(zeros(scaninfo.imfm(1),scaninfo.imfm(2),scaninfo.num_of_slice*scaninfo.Frames));
	for j=1:scaninfo.Frames
        progbar(p,round(j*100/scaninfo.Frames));drawnow;
        for i=1 : scaninfo.num_of_slice
            %imaVOL(:,:,(j-1)*scaninfo.num_of_slice + i) = rot90(int16( ...
            %    reshape(getimages(handle,i,j),[scaninfo.imfm(2) scaninfo.imfm(1)]) ),1);
            imaVOL(:,:,(j-1)*scaninfo.num_of_slice + i) =  int16(permute( ...
            reshape( getimages(handle,i,j),[scaninfo.imfm(2) scaninfo.imfm(1)]) ,[2 1]) );
        end
	end
else
    if scaninfo.float
         imaVOL = (zeros(scaninfo.imfm(1),scaninfo.imfm(2),scaninfo.num_of_slice*scaninfo.Frames));
        for i=1 : scaninfo.num_of_slice
            progbar(p,round(i*100/scaninfo.num_of_slice));drawnow;
            %imaVOL(:,:,i) = (int16(rot90( ...
            imaVOL(:,:,i) = (permute( ...
                reshape( getimages(handle,i),[scaninfo.imfm(2) scaninfo.imfm(1)]) ,[2 1]) );
        end
    else
        if MinMax(2) <= 2^15
            imaVOL = int16(zeros(scaninfo.imfm(1),scaninfo.imfm(2),scaninfo.num_of_slice*scaninfo.Frames));
        else
            imaVOL = int32(zeros(scaninfo.imfm(1),scaninfo.imfm(2),scaninfo.num_of_slice*scaninfo.Frames));
        end
        for i=1 : scaninfo.num_of_slice
            progbar(p,round(i*100/scaninfo.num_of_slice));drawnow;
            %imaVOL(:,:,i) = (int16(rot90( ...
            imaVOL(:,:,i) = int16(permute( ...
                reshape( getimages(handle,i),[scaninfo.imfm(2) scaninfo.imfm(1)]) ,[2 1]) );
        end
    end
end
%
% Close the Progress Bar
%
if jobinfo
        close(p);
end