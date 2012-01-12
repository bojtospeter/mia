function [imaVOL, scan_info, fileheader] = loadvaxima(filename,jobinfo,filelis,dirname,doubleYes)
% function [imaVOL,scaninfo] = loadvaxima(filename,jobinfo,filelis,dirname,doubleYes))

% This function loads a VAX format PC4069 scanner
% image file to the imaVOL matrix.
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
%   doubleYes   -   0, 1.
%                   0 - imaVOL type is uint16
%                   1 - imaVOL type is double
%                   
%   examples:
%   [imaVOL,scaninfo] = loadvaxima('c:\pet\PCMAJOM_____-FDGBRAINIT065520$9*.ima');
%   [imaVOL,scaninfo] = loadvaxima('c:\pet\PCMAJOM_____-FDGBRAINIT065520$9*.ima',1);
%   [imaVOL,scaninfo, fileheader] = loadvaxima('',1,currentfilelist,'c:\pet\');


%filename='pet\PCMAJOM_____-FDGBRAINIT065520$9001.IMA';
    num_of_slice = 15;
    ima_max = 32000;

% If filelis input presented, the filename input ignored 
    if nargin > 2 & nargin  < 5
        filename=[];
        doubleYes = 0;
    elseif nargin == 0
         [FilesSelected, dir_path] = uigetfiles('*.ima','Select image file');
         if dir_path == 0;
              imaVOL = [];scaninfo = [];
              return;
         end
         FileNames = sortrows(FilesSelected');
		 dirname = dir_path;
		 [fpath,fname,fextension,fversion] = fileparts(char(FileNames(1)));
		 fextension = char(fextension);
		 fname = char(fname);
         num_of_files = size(FileNames,1);
         for i=1:num_of_files
             filelist(i).name = char(FileNames(i));
         end
         filelis = filelist';
         filename=[];jobinfo=1;
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
    elseif nargin < 5
        doubleYes = 0;
    end
    
    num_of_file = size(filelis,1);
    if num_of_file == 0
        disp('No files were found!');
        imaVOL=[];
        return;
    elseif num_of_file == 1
        doubleYes = 1;
        decay_correction = 0;
    elseif num_of_file > 1
        doubleYes = 0;
        decay_correction = 1;
    end    
    scaninfo = scxheader([dirname,filelis(1).name]);
    imsize = scaninfo.imfm(1);
    if doubleYes == 0
        imaVOL = uint16(zeros(imsize,imsize,num_of_slice*num_of_file));
    elseif doubleYes == 1
        imaVOL = (zeros(imsize,imsize,num_of_slice*num_of_file));
    end
    % SETTING UP THE PROGRESS BAR
    if jobinfo
        info.color=[1 0 0];
		info.title='Ima fájlok olvasása és normálása';
		info.size=1;
        info.pos='topleft';
		p=progbar(info);
		progbar(p,0);
    end
    
    scantime = 0;%min
%     if jobinfo
%         disp('Files names used for imaVOL generation:');
%         disp(' ');
%     end
    for j=1 : num_of_file
        tmpfilename = [dirname,filelis(j).name];
        if jobinfo
            %disp(tmpfilename);
            progbar(p,round(j*100/num_of_file));drawnow;
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
            if doubleYes == 0
                scaninfo(1).float = 0;
                %imaVOL(:,:,(j-1)*num_of_slice + i) = int16(permute(imatmp,[2 1 3])*image_factor);
                imaVOL(:,:,j*num_of_slice - i+1) = int16(permute(imatmp,[2 1 3])*image_factor);
                %imaVOL(:,:,(j-1)*num_of_slice + i) = int16(flipdim(permute(imatmp,[2 1 3]),2)*image_factor);
            elseif doubleYes == 1
                scaninfo(1).float = 1;
                imaVOL(:,:,(j-1)*num_of_slice + i) =  permute(imatmp,[2 1 3])*image_factor;
                %imaVOL(:,:,(j-1)*num_of_slice + i) = (flipdim(permute(imatmp,[2 1 3]),2)*image_factor);
            end
            %imaVOL(:,:,(j-1)*num_of_slice + i) = uint16(rot90(imatmp)*image_factor);
            %imaVOL(:,:,j*num_of_slice - i+1) = uint16(rot90(imatmp,-1)*image_factor);
        end
        fclose(vaxpid);
        fileheader = hvax;
    end
    % set up the scan type : wholebody or not wholebody
    scantypestring_infilename = filelis(1).name(find(filelis(1).name == '$')+1);
    if strcmp(lower(scantypestring_infilename),'w')
        iswholebodyscan = 1;
    else
        iswholebodyscan = 0;
    end
    start_times  = 0; Frames = size(scaninfo,2);
    if ~iswholebodyscan
    %creating tissue(framemidtime), frame_lengths and start_times scales
    %and append to the 1. "scaninfo" structure
		for j=1 : Frames   
            if j>1
                start_times (j) =  start_times (j-1) + scaninfo(j-1).mtm;
                tissue_ts(j) = start_times (j) + (scaninfo(j).mtm)/2;
            else
                tissue_ts(j) = (scaninfo(j).mtm)/2;
            end
            frame_lengths(j) = (scaninfo(j).mtm); 
        end
        scaninfo(1).pixsize = [2 2 6.5];
        scaninfo(1).start_times = start_times;
        scaninfo(1).frame_lengths = frame_lengths;
        scaninfo(1).tissue_ts = tissue_ts;
        scaninfo(1).Frames = Frames;
        scaninfo(1).FileType    = 'vms';
        scaninfo(1).num_of_slice = num_of_slice;
    else
        scaninfo(1).pixsize = [2 2 6.5];
        scaninfo(1).start_times = [];
        scaninfo(1).frame_lengths = scaninfo(1).mtm*Frames;
        scaninfo(1).tissue_ts = [];
        scaninfo(1).Frames = 1;
        scaninfo(1).FileType    = 'vms';
        scaninfo(1).num_of_slice = num_of_slice*num_of_file;
    end
    
    if jobinfo
        close(p);
    end
    scan_info = scaninfo(1);
    
    