function [imaVOL,scaninfo] = loadcube(filename)
%function [imaVOL,scaninfo] = loadcube(filename)
%
% Matlab library function for MIA_gui utility. 
% University of Debrecen, PET Center/LB 2004
% test version

%try
	if nargin == 0
         [FileName, FilePath] = uigetfile('*.cub','Select a cub file');
         filename = [FilePath,FileName];
         if FileName == 0;
              imaVOL = [];scaninfo = [];
              return;
         end
    end
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% open cube file & get the needed image parameters (scaninfo)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%
	% get the Pixel size info by a dialogbox 
	%
    prompt = {['Enter the X size in [mm] :'],['Enter the Y size in [mm] :'],['Enter the Z size in [mm] :']};
	dlg_title = 'Input for pixel sizes';
	num_lines= 1;
	def     = {'1','1','1'};
	scaninfo.pixsize  = str2double(inputdlg(prompt,dlg_title,num_lines,def))';
    %
	% get the imagesize info by a dialogbox 
	%
    prompt = {['Enter image size (eg. 256):']};
	dlg_title = 'Input for Image Size';
	num_lines= 1;
	def     = {'256'};
	imformat  = str2double(inputdlg(prompt,dlg_title,num_lines,def));
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
	scaninfo.trat       = [];
	scaninfo.cntx      = [];	
	scaninfo.cal       = [];
	scaninfo.min       = [];
	scaninfo.mag       = [];
    % cube specific part
    scaninfo.imfm  	        = [imformat imformat];
	scaninfo.num_of_slice   = imformat;
    scaninfo.start_times    = [];
	scaninfo.frame_lengths  = [];
	scaninfo.tissue_ts      = [];%[min];
	scaninfo.Frames         = 1;
    scaninfo.float = 0;
    scaninfo.FileType    = 'cub';
    % image definition 
    info.color=[1 0 0];
	info.title='Loading cube file';
	info.size=1;
    info.pos='topleft';
	p=progbar(info);
	progbar(p,0);
    imaVOL = int16(zeros(imformat,imformat,imformat));
	fid = fopen(filename, 'rb','native');
	if fid == -1
        disp('Impossible to open the file');
        fclose(fid);
        return;
	else   
        for i=1:imformat
            progbar(p,round(i*100/imformat));drawnow;
            status = fseek(fid,288,'bof');
            status = fseek(fid,(i-1)*imformat*imformat*2,'cof');
            imaVOL(:,:,i) = fread(fid,[imformat imformat],'ushort')';
            imaVOL(:,:,i) = fliplr(imaVOL(:,:,i));
        end
    end;
    fclose(fid);
    close(p);
        
% catch %in case of any error
%     ErrorOnDicomOpening = lasterr
%     close(p);
%     imaVOL = [];scaninfo = [];
% end
