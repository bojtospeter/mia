function [imaVOL,scaninfo] = loadanalyze(filename)
%function [imaVOL,scaninfo] = loadanalyze(filename)
%
% Matlab function to load analyze format file. 
% This function use the ReadAnalyzeImg function from CNR by CS.
% University of Debrecen, PET Center/LB 2003

if nargin == 0
     [FileName, FilePath] = uigetfile('*.img','Select img file');
     filename = [FilePath,FileName];
     if FileName == 0;
          imaVOL = [];scaninfo = [];
          return;
     end
end
jobinfo =1;
% SETTING UP THE PROGRESS BAR
if jobinfo
    info.color=[1 0 0];
	info.title='Opening analyze file';
	info.size=1;
    info.pos='topleft';
	p=progbar(info);
	progbar(p,10);
end

%[AnalImg, hdr] = readanalyzeimg2(filename);%
% [datain,frame_times] = DEPICT__read_analyze(filename);
% if strcmp(datain.precision,'Unknown');% try the previous version
%    [imaVOL,scaninfo] = loadanalyze_(filename);
%    return;
% end

%hdr = datain.hdr;
% AnalImg = datain.data;
frame_times = [];
hdr = analyze75info(filename);
AnalImg = analyze75read(hdr);

progbar(p,80);
%
% get info from minc file and save them in the scaninfo structure 
%
scaninfo.pnm	   = [];
scaninfo.rid	   = hdr.DatabaseName;
scaninfo.rin	   = [];	
scaninfo.daty	   = [];
scaninfo.datm	   = [];
scaninfo.datd      = [];
scaninfo.timh	   = [];
scaninfo.timm	   = [];
scaninfo.tims	   = [];
scaninfo.mtm       = [];
scaninfo.iso 	   = [];
scaninfo.half      = [];
scaninfo.trat      = [];
scaninfo.imfm  	   = [hdr.Dimensions(1) hdr.Dimensions(2)];
scaninfo.cntx      = hdr.Descriptor;
scaninfo.cal       = [];
scaninfo.min       = [];
scaninfo.mag       = [];
scaninfo.pixsize = abs(hdr.PixelDimensions);%abs : the SPM can save values where hdr.siz < 0 
if scaninfo.pixsize(3) == 0 
   button = questdlg('The Z pixel size is 0!! Do you want to continue?',...
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
scaninfo.start_times     = [];
if hdr.Dimensions(4) > 1
    if ~isempty(frame_times)
        scaninfo.tissue_ts  = frame_times;
        
        scaninfo.frame_lengths = zeros(size(frame_times));
        scaninfo.frame_lengths(2:end) = diff(2*frame_times);
        scaninfo.frame_lengths(1) = frame_times(1)*2;
        
        scaninfo.Frames     = length(frame_times);
    else % generate linear indexing for timescale if no tim file supplied
        scaninfo.frame_lengths    = 60*ones(1,hdr.Dimensions(4));
        scaninfo.tissue_ts  = 60*[1:1:hdr.Dimensions(4)];
        scaninfo.Frames     = length(scaninfo.tissue_ts);
    end
else
    scaninfo.frame_lengths    = [];
    scaninfo.tissue_ts  = [];
    scaninfo.Frames     = 1;
end
if scaninfo.Frames == 0
    scaninfo.Frames = 1;
end
scaninfo.num_of_slice    = hdr.Dimensions(3);
scaninfo.FileType    = 'analyse';

% scaled_max = max(AnalImg(:))*hdr.scale;
% firsttwo_digit = fix(100*(scaled_max - fix(scaled_max)));
% if firsttwo_digit == 0 & scaled_max > 32 %int16 case
% 	SegmentedmriImg = round((AnalImg-hdr.offset)*hdr.scale);
% 	imaVOL_ = int16(reshape( (AnalImg-hdr.offset)*hdr.scale , [hdr.dim(1) hdr.dim(2) hdr.dim(3)] ) );
% 	progbar(p,90);
% 	imaVOL = flipdim(permute(imaVOL_,[2 1 3]),1);
%     scaninfo.float = 0;
% else % float case
%     %SegmentedmriImg = ((AnalImg-hdr.offset)*hdr.scale);
% 	imaVOL_ = reshape( (AnalImg-hdr.offset)*hdr.scale , [hdr.dim(1) hdr.dim(2) hdr.dim(3)] );
% 	progbar(p,90);
% 	imaVOL = flipdim(permute(imaVOL_,[2 1 3]),1);
%     scaninfo.float = 1;
% end

imaVOL = reshape(flipdim(permute(AnalImg,[2 1 3 4]),1),[hdr.Dimensions(1) hdr.Dimensions(2) ...
    hdr.Dimensions(3)*hdr.Dimensions(4)]); 
if strcmp(hdr.HdrDataType,'Float')
    scaninfo.float = 1;
else
    scaninfo.float = 0;
end

close(p);