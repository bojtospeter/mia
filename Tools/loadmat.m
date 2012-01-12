function [imaVOL,scaninfo] = loadmat(filename)
%function [imaVOL,scaninfo] = loadmat(filename)
%
% Matlab library function for MIA_gui utility. 
% University of Debrecen, PET Center/LB 2004
% test version 23/06/2004

try
	if nargin == 0
         [FileName, FilePath] = uigetfile('*.mat','Select a mat file');
         filename = [FilePath,FileName];
         if FileName == 0;
              imaVOL = [];scaninfo = [];
              return;
         end
    end
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% open the mat file & get the needed image parameters (scaninfo)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hm = msgbox('The mat file is opening ...','MIA Info' );
	SetData=setptr('watch');set(hm,SetData{:});
	hmc = (get(hm,'children'));
	set(hmc(2),'enable','off');
    
    StructureIn = load(filename);
    VolumeInfo = StructureIn.VolumeInfo;
    StructureIn = [];
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
    if ~isfield(VolumeInfo,'pixelsize')
    	hmb = msgbox('The mat file does not include the necessary VolumeInfo structure (VolumeInfo.pixelsize)', ...
            'MIA Info' );
        imaVOL = [];scaninfo = [];
        delete(hm);return;
    end
    scaninfo.pixsize  = VolumeInfo.pixelsize;
    if ~isfield(VolumeInfo,'isfloat')
    	hm = msgbox('The mat file does not include the necessary VolumeInfo structure (VolumeInfo.isfloat)' ...
            ,'MIA Info' );
        imaVOL = [];scaninfo = [];
        delete(hm);return;
    end
    scaninfo.float  = VolumeInfo.isfloat;
    if ~isfield(VolumeInfo,'image')
    	hmb = msgbox('The mat file does not include the necessary VolumeInfo structure (VolumeInfo.image)' ...
            ,'MIA Info' );
        imaVOL = [];scaninfo = [];
        delete(hm);return;
    end
    if scaninfo.float
        imaVOL  = VolumeInfo.image;
    else
        imaVOL  = int16(VolumeInfo.image);
    end
    %
    scaninfo.imfm  	        = [size(imaVOL,1) size(imaVOL,2)];
	scaninfo.num_of_slice   = size(imaVOL,3);
    scaninfo.start_times    = [];
	scaninfo.frame_lengths  = [];
	scaninfo.tissue_ts      = [];%[min];
	scaninfo.Frames         = 1;
    scaninfo.FileType    = 'mat';
    
    delete(hm);    
catch %in case of any error
      ErrorOnMatOpening = lasterr
      delete(hm);
      imaVOL = [];scaninfo = [];
end
