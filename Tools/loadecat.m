function [imaVOL, scaninfo, hd] = loadecat(filename)
%function [imaVOL,scaninfo,hd] = loadecat(filename)
% This function loads ecat6.4 or ecat7(even dynamic) format input files. 
% On reading it uses the ecatfile.m, readecatvol.m procedures coming 
% from Flemming Hermansen (Aarhus University Hospitals).
%
% Matlab library function for MIA_gui utility. 
% University of Debrecen, PET Center/LB 2003


if nargin == 0
     [FileName, FilePath] = uigetfile('*.v;*.V;*.i;*.S','Select ecat file');
     filename = [FilePath,FileName];
     if FileName == 0;
          imaVOL = [];scaninfo = []; hd = [];
          return;
     end
end
[fpath,fname,fextension,fversion] = fileparts(char(filename));

jobinfo =1;
% SETTING UP THE PROGRESS BAR
if jobinfo
    info.color=[1 0 0];
	info.title='Opening ecat file';
	info.size=1;
    info.pos='topleft';
	p=progbar(info);
	progbar(p,10);
end
ecat_datain = readecatvol( filename, [ -inf, -inf, -inf, -inf, -inf; inf, inf, inf, inf, inf ] );
%[ fid, message1 ]       = ecatfile( 'open', filename );
%[ matranges, message2 ] = ecatfile( 'matranges', fid );
%[ vol, hd, message3 ]   = ecatfile( 'read', fid, matranges(1,:)  );
%message4                = ecatfile( 'close', fid );
hd = ecat_datain.hd{1};

progbar(p,80);
%
% get info from minc file and save them in the scaninfo structure 
%
scaninfo.pnm	   = hd.mh.patient_name;
scaninfo.brn       = hd.mh.patient_id;
scaninfo.rid	   = [];
scaninfo.rin	   = [];	
scaninfo.daty	   = [];
scaninfo.datm	   = [];
scaninfo.datd      = [];
scaninfo.timh	   = [];
scaninfo.timm	   = [];
scaninfo.tims	   = [];
scaninfo.mtm       = [];
scaninfo.iso 	   = hd.mh.isotope_name;
scaninfo.half      = hd.mh.isotope_halflife;
scaninfo.trat      = [];
if ~strcmp(char(fextension),'.S')
    scaninfo.imfm  	   = hd.sh.xyz_dimension(1:2);
else
    scaninfo.imfm  	   = [hd.sh.num_r_elements hd.sh.num_angles];
end
scaninfo.cntx      = hd.mh.study_description;
scaninfo.cal       = [];
scaninfo.min       = [];
scaninfo.mag       = [];
if ~strcmp(char(fextension),'.S')
    scaninfo.pixsize =  hd.sh.xyz_pixel_size*10;%mm
else
    scaninfo.pixsize =  [1 1 1];
end
scaninfo.start_times     =  ecat_datain.times(:,1)';
scaninfo.frame_lengths    =  ecat_datain.times(:,4)';
scaninfo.tissue_ts  =  ecat_datain.times(:,2)';
scaninfo.Frames     = size(ecat_datain.times(:,1),1);
if ~strcmp(char(fextension),'.S')
    scaninfo.num_of_slice    = hd.sh.xyz_dimension(3);
else
    scaninfo.num_of_slice    = hd.sh.num_z_elements(1);
end
scaninfo.FileType    = hd.mh.file_system;
scaninfo.float = 1;
suvfact = 1;
if hd.mh.ecat_calibration_factor == 1 || hd.mh.ecat_calibration_factor == 0
    % if no quantification(calib fact = 1), the ECAT file scaling factor tends to 10^-6-7
    % which is unpracticle to display. In that case I set the calib factor to 10000 arbitrarily.   
    calibration_factor = 100;
else
    calibration_factor = hd.mh.ecat_calibration_factor;
    suvyes = 1;
    if suvyes
        suvfact = (hd.mh.patient_weight*1000)/hd.mh.dosage;
    end
end

if  scaninfo.Frames == 1
    scale_factor = calibration_factor*hd.sh.scale_factor;
    %decay_factor = 2^( scaninfo.tissue_ts(i)/hd.mh.isotope_halflife);
    if isfield(hd.sh,'decay_corr_fctr')
        decay_factor = hd.sh.decay_corr_fctr;
    else
        decay_factor = 1;
    end
    vol = double(ecat_datain.vol{1})*scale_factor*suvfact;
    if ~strcmp(char(fextension),'.S')
        imaVOL = flipdim(permute(vol,[2 1 3]),3);
    else
        imaVOL = permute(vol,[2 1 3]);
    end
else
    imaVOL = zeros(scaninfo.imfm(1),scaninfo.imfm(2),scaninfo.num_of_slice,scaninfo.Frames);
    for i=1:scaninfo.Frames
        scale_factor = calibration_factor*ecat_datain.hd{i}.sh.scale_factor;
%       decay_factor = 2^( scaninfo.tissue_ts(i)/hd.mh.isotope_halflife);
        decay_factor = ecat_datain.hd{i}.sh.decay_corr_fctr;
%       vv = ecat_datain.vol{i};
%       disp([num2str(i),' ',num2str(max(vv(:))),' ', num2str(min(vv(:))),' ', ...
%             num2str(decay_factor), ' ',num2str(scale_factor)] );
        vol = double(ecat_datain.vol{i})*scale_factor*suvfact;
        imaVOL(:,:,:,i) =  flipdim(permute(vol,[2 1 3]),3);   
    end
end
progbar(p,95);
% zero padding the negativ elements
%imaVOL(find(imaVOL < 0)) = 0;

progbar(p,100);
if jobinfo
    close(p);
end