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
[AnalImg, hdr] = readanalyzeimg2(filename);%
progbar(p,80);
%
% get info from minc file and save them in the scaninfo structure 
%
scaninfo.pnm	   = [];
scaninfo.brn       = [];
scaninfo.rid	   = [];
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
scaninfo.imfm  	   = [hdr.dim(2) hdr.dim(1)];
scaninfo.cntx      = hdr.descr;
scaninfo.cal       = [];
scaninfo.min       = [];
scaninfo.mag       = [];
scaninfo.pixsize = abs(hdr.siz);%abs : the SPM can save values where hdr.siz < 0 
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
scaninfo.frame_lengths    = [];
scaninfo.tissue_ts  = [];
scaninfo.Frames     = 1;
if scaninfo.Frames == 0
    scaninfo.Frames = 1;
end
scaninfo.num_of_slice    = hdr.dim(3);
scaninfo.FileType    = 'analyse';

scaled_max = max(AnalImg(:))*hdr.scale;
firsttwo_digit = fix(100*(scaled_max - fix(scaled_max)));
if firsttwo_digit == 0 & scaled_max > 32 %int16 case
	SegmentedmriImg = round((AnalImg-hdr.offset)*hdr.scale);
	imaVOL_ = int16(reshape( (AnalImg-hdr.offset)*hdr.scale , [hdr.dim(1) hdr.dim(2) hdr.dim(3)] ) );
	progbar(p,90);
	imaVOL = flipdim(permute(imaVOL_,[2 1 3]),1);
    scaninfo.float = 0;
else % float case
    %SegmentedmriImg = ((AnalImg-hdr.offset)*hdr.scale);
	imaVOL_ = reshape( (AnalImg-hdr.offset)*hdr.scale , [hdr.dim(1) hdr.dim(2) hdr.dim(3)] );
	progbar(p,90);
	imaVOL = flipdim(permute(imaVOL_,[2 1 3]),1);
    scaninfo.float = 1;
end

close(p);