function res = suv_batchmode;
% function res = suv_batchmode;
%
%   Calculating suv images for a list of scx ima files. The file list 
%   and the necessary parameters (imaVOL, isotope_type, 
%   timediff_for_decaycorrection, injected_dose, bodyweight, bodyheight) 
%   need to write in an excel file.
%   The timediff_for_decaycorrection_sec value stands for the
%   differences between the injection time and the scan start time in sec.
%   The result are the SUV scaled scx vms format ima images. The output 
%   name convention is: rid_SUV_rin_brn.ima 
%
%   The process use the suv.m and the xls2struct.m functions. See the help.
%
% University of Debrecen, PET Center/LB 2004

num_of_petslice = 15;
scxima_max = 32000;

[xlsfilename, pathname] = uigetfile('*.xls', 'Load xls file');
if isempty(xlsfilename); res = 0;return; end

[excelstruct] = xls2struct([pathname,xlsfilename]);
% the excelstruct (and the imported excel file) should contain
% the following elements (columns):
% filename,	isotope, timediff_for_decaycorrection_sec, injected_dose_mCi, bodyweight_kg, bodyheight_m
% The timediff_for_decaycorrection_sec value stands for the time
% differences between the injection time and the scan start time.
curdir = pwd;
cd(pathname);
%
% SETTING UP THE PROGRESS BAR
%
info.color=[1 0 0];
info.title='Calculating suv images';
info.size=1;
info.pos='topleft';
p=progbar(info);
progbar(p,0);
%
for i=1:size(excelstruct.filename,1)
    [imaVOL,scaninfo,scxhdr] = loadvaxima(char(excelstruct.filename(i)));
    isotope_type = char(excelstruct.isotope(i));
    timediff_for_decaycorrection = excelstruct.timediff_for_decaycorrection_sec(i)+scaninfo.mtm/2;
    injected_dose = excelstruct.injected_dose_mCi(i);
    bodyweight = excelstruct.bodyweight_kg(i);
    bodyheight = excelstruct.bodyheight_m(i);
    if isnan(bodyheight) | bodyheight == 0
        bodyheight = [];
    end
    suvVOL = suv(imaVOL, isotope_type, timediff_for_decaycorrection, injected_dose, bodyweight, bodyheight);
    if isempty(suvVOL);
        close(p);
        res = 0;
        return;
    end
    %save the resulted suv file as scx format file
    suvVOL = (flipdim(permute(suvVOL,[2 1 3]),1));
    outfilename = ['pc',scaninfo(1).rid,'_SUV_',num2str(scaninfo(1).rin), ...
        '_',num2str(scaninfo(1).brn),'.ima'];
	vaxfid = fopen(outfilename,'w','vaxd');
	fwrite(vaxfid,scxhdr,'char');
	for j = 1 : num_of_petslice
        slicemaxs(j) = max(max(suvVOL(:,:,j)));
        sliceout = round((suvVOL(:,:,j)*(scxima_max)/slicemaxs(j)));
        fwrite(vaxfid,sliceout,'ushort');
	end
	fclose(vaxfid);
	%
	% modify the CNTX and MAG mnemonics in the vax fileheader 
	%
	context = 'SUV       ';
	scxheader_edit(outfilename, context, slicemaxs);
    imaVOL = [];suvVOl = []; scaninfo = []; scxhdr = [];
    progbar(p,round(100*i/size(excelstruct.filename,1)));drawnow;
end
cd(curdir);
close(p);
res = 1;