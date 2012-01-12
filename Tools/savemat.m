function wresult = savemat(outputfilename,imaVOL,scaninfo)
% function wresult = savemat(outputfilename,imaVOL,scaninfo)
%
% Matlab function to save imaVOL as mat format output file. 
%
% Matlab library function for MIA_gui utility. 
% University of Debrecen, PET Center/LB 2004


try
	if scaninfo.Frames > 1
        hm = msgbox('Dynamic file cannot be saved.','MIA Info' );
        wresult = 0;
        return;
	end
	
	VolumeInfo.pixelsize = scaninfo.pixsize;
	VolumeInfo.isfloat = scaninfo.float;
	VolumeInfo.image = imaVOL; 
	
	save(outputfilename,'VolumeInfo');
	
	wresult = 0;
catch
    wresult = -1;
end