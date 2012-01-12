function	[d,frame_times] = DEPICT__read_analyze(file,Z,T);

% Read in Analyze format Image Volumes
% 
%
% Usage
%
% d = DEPICT__Read_Analyze(file);
% Reads in all image data and attributes into the structure d.
%
% d = DEPICT__Read_Analyze(file,Z,T);
% Reads in chosen planes and frames and attributes into the structure d.
% Z and T are vectors e.g. Z=1:31;T=1:12; or Z=[24 26];T=[1 3 5];
%
% [d,frame_times] = DEPICT__Read_Analyze(file);
% Reads in all image data and attributes into the structure d. For 4D case if midframe
% times (in sec) are in a separate text file named "filename.tim"  
% the function will read the midframe times to frame_times vector
% This feature added by University of Debrecen, PET Center/Ivan Valastyan
% 2004. 
% 
% Original version:
% (c) Roger Gunn 2002

warning off MATLAB:nonIntegerTruncatedInConversionToChar

machine_format = 'b';

% Read Header Information
d=Read_Analyze_Hdr(file,machine_format);

frame_times=[];
if ( strcmpi(d.hdr.aux_file, 'exist-time-frames------')==1 )
    [fpathstr,fname,fext,fversn] = fileparts(file);
    frame_times=load([fpathstr filesep fname '.tim']);    
end
% Read Image Data

if ~isempty(d)&~strcmp(d.precision,'Unknown')
   
   if nargin==1|strcmp(d.precision,'uint1')
      
      % Read in Whole Analyze Volume
      fid = fopen([d.file_path d.file_name '.img'],'r',machine_format);
      if fid > -1
        d.data=int16(zeros(d.dim));
        for t=1:d.dim(4)
               d.data(:,:,:,t)=reshape(int16(fread(fid,d.dim(1)*d.dim(2)*d.dim(3), d.precision)*d.scale),d.dim(1),d.dim(2),d.dim(3));
        end;
        
  
         fclose(fid);
      else
         errordlg('Check Image File: Existence, Permissions ?','Read Error'); 
      end;
      
      if nargin==3
         if prod(double(Z>0))&prod(double(Z<=d.dim(3)))&prod(double(T>0))&prod(double(T<=d.dim(4)))
            d.data=int16(d.data(:,:,Z,T));
            d.Z=Z;
            d.T=T;
         else
            errordlg('Incompatible Matrix Identifiers !','Read Error');  
         end
      end
      
   elseif nargin==3
      
      % Read in Chosen Planes and Frames
      if prod(double(Z>0))&prod(double(Z<=d.dim(3)))&prod(double(T>0))&prod(double(T<=d.dim(4)))
         fid = fopen([d.file_path d.file_name '.img'],'r',machine_format);
         if fid > -1
            d.data=int16(zeros(d.dim(1),d.dim(2),length(Z),length(T)));
            for t=1:length(T)
               for z=1:length(Z)
                  status=fseek(fid,d.hdr.byte*((T(t)-1)*prod(d.dim(1:3))+(Z(z)-1)*prod(d.dim(1:2))),'bof');
                  d.data(:,:,z,t)=d.scale*int16(fread(fid,[d.dim(1) d.dim(2)],d.precision));
               end
            end
            d.Z=Z;
            d.T=T;
            fclose(fid);
         else
            errordlg('Check Image File: Existence, Permissions ?','Read Error'); 
         end;
      else
         errordlg('Incompatible Matrix Identifiers !','Read Error'); 
      end;
   else
      errordlg('Unusual Number of Arguments','Read Error');
   end;
else
   %if strcmp(d.precision,'Unknown');errordlg('Unknown Data Type (Precision?)','Read Error');end
    if strcmp(d.precision,'Unknown');hh = warndlg('Unknown Data Type (Precision?)','Read Error');end
end;

return;



function d=Read_Analyze_Hdr(file,machine_format);

% Read Analyze Header information into the structure d
% Adapted from John Ashburners spm_hread.m

if ispc 
    separator			='\';
else 
    separator			='/';
end;

%file      		= file(file~=' ');
file_l    		= length(file);
if file(file_l-3)=='.';file=file(1:(file_l-4));file_l = length(file);end;
d.file_path		= file(1:max(findstr(file,separator)));
if isempty(d.file_path); 
   d.file_path	= './';
   d.file_name	= file;
else
   d.file_name	= file((max(findstr(file,separator))+1):file_l);
end

fid   				= fopen([d.file_path d.file_name '.hdr'],'r',machine_format);

if fid > -1
   
   % read (struct) header_key
   %---------------------------------------------------------------------------
   fseek(fid,0,'bof');
   
   d.hdr.sizeof_hdr 		= fread(fid,1,'int32');
   d.hdr.data_type  		= deblank(setstr(fread(fid,10,'char'))');
   d.hdr.db_name    		= deblank(setstr(fread(fid,18,'char'))');
   d.hdr.extents    		= fread(fid,1,'int32');
   d.hdr.session_error   	= fread(fid,1,'int16');
   d.hdr.regular    		= deblank(setstr(fread(fid,1,'char'))');
   d.hdr.hkey_un0    		= deblank(setstr(fread(fid,1,'char'))');
   
   
   
   % read (struct) image_dimension
   %---------------------------------------------------------------------------
   fseek(fid,40,'bof');
   
   d.hdr.dim    			= fread(fid,8,'int16');
   d.hdr.vox_units    		= deblank(setstr(fread(fid,4,'char'))');
   d.hdr.cal_units    		= deblank(setstr(fread(fid,8,'char'))');
   d.hdr.unused1			= fread(fid,1,'int16');
   d.hdr.datatype			= fread(fid,1,'int16');
   d.hdr.bitpix				= fread(fid,1,'int16');
   d.hdr.dim_un0			= fread(fid,1,'int16');
   d.hdr.pixdim				= fread(fid,8,'float');
   d.hdr.vox_offset			= fread(fid,1,'float');
   d.hdr.funused1			= fread(fid,1,'float');
   d.hdr.funused2			= fread(fid,1,'float');
   d.hdr.funused3			= fread(fid,1,'float');
   d.hdr.cal_max			= fread(fid,1,'float');
   d.hdr.cal_min			= fread(fid,1,'float');
   d.hdr.compressed			= fread(fid,1,'int32');
   d.hdr.verified			= fread(fid,1,'int32');
   d.hdr.glmax				= fread(fid,1,'int32');
   d.hdr.glmin				= fread(fid,1,'int32');
   
   % read (struct) data_history
   %---------------------------------------------------------------------------
   fseek(fid,148,'bof');
   
   d.hdr.descrip			= deblank(setstr(fread(fid,80,'char'))');
   d.hdr.aux_file			= deblank(setstr(fread(fid,24,'char'))');
   d.hdr.orient				= fread(fid,1,'char');
   d.hdr.origin				= fread(fid,5,'uint16');
   d.hdr.generated			= deblank(setstr(fread(fid,10,'char'))');
   d.hdr.scannum			= deblank(setstr(fread(fid,10,'char'))');
   d.hdr.patient_id			= deblank(setstr(fread(fid,10,'char'))');
   d.hdr.exp_date			= deblank(setstr(fread(fid,10,'char'))');
   d.hdr.exp_time			= deblank(setstr(fread(fid,10,'char'))');
   d.hdr.hist_un0			= deblank(setstr(fread(fid,3,'char'))');
   d.hdr.views				= fread(fid,1,'int32');
   d.hdr.vols_added			= fread(fid,1,'int32');
   d.hdr.start_field		= fread(fid,1,'int32');
   d.hdr.field_skip			= fread(fid,1,'int32');
   d.hdr.omax				= fread(fid,1,'int32');
   d.hdr.omin				= fread(fid,1,'int32');
   d.hdr.smax				= fread(fid,1,'int32');
   d.hdr.smin				= fread(fid,1,'int32');
   
   fclose(fid);
   
   % Put important information in main structure
   %---------------------------------------------------------------------------
   
   d.dim    	  				= d.hdr.dim(2:5)';
   vox 						= d.hdr.pixdim(2:5)';
   if 	vox(4)==0 vox(4)=[];end
   d.vox       				= vox;
   d.vox_units       		= d.hdr.vox_units;
   d.vox_offset	    		= d.hdr.vox_offset;
   scale     				= d.hdr.funused1;
   d.scale     			  	= ~scale + scale;
   d.global					= [d.hdr.glmin d.hdr.glmax];
   d.calib					= [d.hdr.cal_min d.hdr.cal_max];
   d.calib_units			= d.hdr.cal_units;
   d.origin    				= d.hdr.origin(1:3)';
   d.descrip   				= d.hdr.descrip(1:max(find(d.hdr.descrip)));
   switch d.hdr.datatype
   case 1
      d.precision 	= 'uint1';
      d.hdr.byte 	= 0;
   case 2
      d.precision 	= 'uint8';
      d.hdr.byte 	= 1;
   case 4
      d.precision 	= 'int16';
      d.hdr.byte 	= 2;
   case 8
      d.precision 	= 'int32';
      d.hdr.byte 	= 4;
   case 16
      d.precision 	= 'float';
      d.hdr.byte 	= 4;
   case 64
      d.precision 	= 'double';
      d.hdr.byte 	= 8;
   otherwise
       d.precision 	= 'Unknown';
       d.hdr.byte 	= 0;
   end
   
else
   d=[];
   errordlg('Check Header File: Existence, Permissions ?','Read Error'); 
end


return;