function wresult = savedcm(outputfilename,imaVOL,scaninfo)
% function wresult = savedcm(outputfilename,imaVOL,scaninfo)
%
% Matlab function to save dcm format output file. 
% The function use the Matlab dicomrwrite procedure.
%
% Matlab library function for MIA_gui utility. 
% University of Debrecen, PET Center/LB 2003

wresult = -1;

if scaninfo.Frames > 1
    hm = msgbox('Dynamic file cannot be saved.','MIA Info' );
    wresult = 0;
    return;
end

hm = msgbox('Dicom saving...','MIA Info' );
maxVOL = max(imaVOL(:));
num_of_digit_infile = ceil(log10(size(imaVOL,3)));
[pathstr, mainname, ext, versn] = fileparts(outputfilename); 
if (round(double(maxVOL)) ~= maxVOL)%if imaVOL float
    imaVOL = imaVOL*2^16/maxVOL;
    imaout = uint16(reshape(imaVOL,[scaninfo.imfm 1 scaninfo.num_of_slice]));
    disp('Warning!');
    disp('The image type is float. SAVEDCM converts it to UINT16 for saving. Take care!');
    disp('');
    for i=1:size(imaVOL,3)
        digit_ext = [get_zeros(num_of_digit_infile-ceil(log10(i+0.0001))),num2str(i)];
        outname = [mainname,'_',digit_ext,'.dcm'];
        status = dicomwrite(imaout(:,:,1,i), outname,'ObjectType','CT Image Storage', ...
        'PixelSpacing',scaninfo.pixsize(1:2)','SliceThickness',scaninfo.pixsize(3), ...
        'NumberOfSlices',scaninfo.num_of_slice,'Modality','PET', ...
        'RescaleSlope',maxVOL/2^16,'RescaleIntercept',0,'InstanceNumber',i);
    end
else
    imaout = reshape(imaVOL,[scaninfo.imfm 1 scaninfo.num_of_slice]);
    for i=1:size(imaVOL,3)
        digit_ext = [get_zeros(num_of_digit_infile-ceil(log10(i+0.0001))),num2str(i)];
        outname = [mainname,'_',digit_ext,'.dcm'];
        status = dicomwrite(imaout(:,:,1,i), outname,'ObjectType','CT Image Storage', ...
        'PixelSpacing',scaninfo.pixsize(1:2)','SliceThickness',scaninfo.pixsize(3), ...
        'NumberOfSlices',scaninfo.num_of_slice,'Modality','PET', ...
        'InstanceNumber',i);
    end
end

delete(hm);
wresult = 0;

function zerostring = get_zeros(numofzeros)

zerostring = '';
for i=1:numofzeros
    zerostring = [zerostring '0'];
end

