function [Wresult] = saveanalyze(outputfilename,imaVOL,scaninfo,precision,fileformat)
% function [Wresult] = saveanalyze(outputfilename,imaVOL,scaninfo,precision,fileformat)
%
% Matlab function to save analyse format output file. 
% This function use the WriteAnalyzeImg function from CNR by CS.
%
% Matlab library function for MIA_gui utility. 
% University of Debrecen, PET Center/LB 2003
Wresult = -1;

if scaninfo.Frames > 1
    hm = msgbox('Dynamic file cannot be saved.','MIA Info' );
    Wresult = 0;
    return;
end

if nargin == 3
   hdrout.pre = 16;
   hdrout.fileformat = 'ieee-be';
elseif nargin == 4
   hdrout.pre=precision;
   hdrout.fileformat = 'ieee-be'; 
elseif nargin == 5
   hdrout.pre=precision;
   hdrout.fileformat = fileformat; 
end
hm = msgbox('Saving analyze file. Please wait.','MIA Info' );
SetData=setptr('watch');set(hm,SetData{:});
hmc = get(hm,'children');
set(hmc(2),'enable','off');
drawnow;

hdrout.name = outputfilename;
dims =  [scaninfo.imfm(2) scaninfo.imfm(1) scaninfo.num_of_slice];
hdrout.dim = dims;
hdrout.siz = scaninfo.pixsize;
%
% creating the row image for WriteAnalyzeImg function
%
imaVOLByRow = [];
%for i=1:hdrout.dim(3)
%   imatrans = flipud(rot90(imaVOL(:,:,i),-1));  
%   imaVOLByRow = [imaVOLByRow reshape(imatrans,[1 hdrout.dim(1)*hdrout.dim(2)])];
%end
imatrans = permute(flipdim(imaVOL,1),[2 1 3]);
imaVOLByRow = reshape(imatrans,[1 hdrout.dim(1)*hdrout.dim(2)*hdrout.dim(3)]);

max_pix = max(double(imaVOLByRow(:)));
min_pix = min(double(imaVOLByRow(:)));
hdrout.scale = (max_pix-min_pix)/(2^hdrout.pre-1);
hdrout.offset = -min_pix/hdrout.scale;
hdrout.lim(1) = 2^hdrout.pre; hdrout.lim(2)=0;
hdrout.origin=[0 0 0];
hdrout.path='';
hdrout.descr = scaninfo.cntx;
imaVOLByRow_scaled = fix(double(imaVOLByRow)/hdrout.scale + hdrout.offset);
Wresult = writeanalyzeimg(hdrout,imaVOLByRow_scaled);
delete(hm);
Wresult = 0;
