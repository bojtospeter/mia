function [imaVOL, scaninfo, fileheader] = loadvaxima128(filename,jobinfo,filelis,dirname)
% function [imaVOL, scaninfo] = loadvaxima128(filename,jobinfo,filelis,dirname)
%
% This function loads VAX format PC4069 scanner
% image file to the 128x128 basesize imaVOL matrix. If the 
% origin size 256x256 the program will resice it to 128x128 by gaussian 
% interpolation
%
%   scaninfo    -   structure containing some important header mnemonic of
%                   VAX PC file
%   fileheader  -   the full header of the VAX PC file(for later
%                   processing: saving a new file, etc..)
%
%   filename    -   the name of the VMS files (wildcard is accepted)
%   jobinfo     -   if 1, the function will display the used filenames
%   filelis     -   structure where filelis(i).name contains the ith filename 
%                   to be load 
%   dirname     -   if FILELIS argin supplied, dirname should contain the directory
%                   name where the FILELIS came from
%                   
%   examples:
%   [imaVOL,scaninfo] = loadvaxima128('c:\pet\PCMAJOM_____-FDGBRAINIT065520$9*.ima');
%   [imaVOL,scaninfo] = loadvaxima128('c:\pet\PCMAJOM_____-FDGBRAINIT065520$9*.ima',1);
%   [imaVOL,scaninfo,fileheader] = loadvaxima128('',1,currentfilelist,'c:\pet\');

    num_of_slice = 15;
    ImsizeOut = 128;
    ima_max = 32000;
    decay_correction = 1;
    
% SETTING UP THE PROGRESS BAR

    info.color=[1 0 0];
	info.title='Ima fájlok olvasása és normálása';
	info.size=1;
    info.pos='topleft';
	p=progbar(info);
	progbar(p,0);
    
% If filelis input presented, the filename input ignored 
    if nargin > 2
        filename=[];
    else
%
% find the directory name from the filename     
%
        if isunix 
            per_index = find(filename == '/');
        else
            per_index = find(filename == '\');
        end
        if isempty(per_index)
            dirname = '';
        else
            rootend = per_index(length(per_index));
            dirname = filename(1:rootend);
        end
%    
% generating the file list and defining the imaVOL matrix
%
        filelis= dir(filename);
    end
    if nargin < 2
        jobinfo=0;
    end
    num_of_file = size(filelis,1);
    if num_of_file == 0
        disp('No files were found!');
        imaVOL=[];
        return;
    end    
    scaninfo = scxheader([dirname,filelis(1).name]);
    imsize = scaninfo.imfm; 
    imaVOL = uint16(zeros(ImsizeOut,ImsizeOut,num_of_file*num_of_slice));
    sacninfo = [];
    
    scantime = 0;%min
    if jobinfo 
        disp('Opening the files and reading the slices: ');
    end
 %
 %  Start the reading loop
 %
    for j=1 : num_of_file
        progbar(p,round(j*100/num_of_file));drawnow;
        tmpfilename = [dirname,filelis(j).name];
        if jobinfo
            disp(tmpfilename);
        end
        scaninfo(j) = scxheader(tmpfilename);
        vaxpid = fopen(tmpfilename,'r','vaxd');
        hvax = fread(vaxpid,4096,'char');
        scanmidtime = scantime + (scaninfo(j).mtm/60)/2;
        scantime = scantime + scaninfo(j).mtm/60;
        for i=1 : num_of_slice
            scale_factor = scaninfo(j).mag(i)/ima_max;%*scaninfo.cal(i);
            if decay_correction
                decay_factor = 2^(scanmidtime/scaninfo(j).half);
            else
                decay_factor =1;
            end
            image_factor = scale_factor*decay_factor;
            imatmp = fread(vaxpid,[imsize imsize],'ushort');            
            if scaninfo(j).min(i) < 0
            % if the image contain negativ values these pixels should 0 padding.
            % These pixel values are larger then ima_max = 32000 as represented in the image file
                range_negativ = find(imatmp > ima_max);
                imatmp(range_negativ) = 0;
            end
            imatmp = fliplr(rot90(imatmp,-1))*image_factor;
            %smoothing and resizing the images to ImsizeOut*ImsizeOut matrix
            if imsize > ImsizeOut
                %imatmp = conv2(imatmp,kernel(2,'gaussian'),'full');
                imaVOL(:,:,(j-1)*num_of_slice + i) = uint16(imresize(imatmp,[ImsizeOut ImsizeOut])); 
            else
                imaVOL(:,:,(j-1)*num_of_slice + i) = uint16(imatmp);
                %imaVOL(:,:,j*num_of_slice - i+1) = rot90(imatmp,-1)*image_factor;    
            end
        end
        fclose(vaxpid);
        fileheader = hvax;
    end
    close(p);
    
    
    