function [result]=WriteAnalyzeHdr(name,dim,siz,pre,lim,scale,offset,origin,descr),
%  Writes the analyze header file 
%
%    [result]=WriteAnalyzeHdr(name,dim,siz,pre,lim,scale,offset,origin[,descr])
%    [result]=WriteAnalyzeHdr(name,dim,siz,pre,lim,scale,offset,origin,descr)
%    [result]=WriteAnalyzeHdr(hdr)
%
%  name      - name of image file
%  dim       - x,y,z,[t] no of pixels in each direction
%  siz       - voxel size in mm
%  pre       - precision for pictures (8 or 16)
%  lim       - max and min limits for pixel values (ex: [255 0] for 8 bit)
%  scale     - scale is scaling of pixel values
%  offset    - offset is offset in pixel values
%  origin    - origin for AC-PC plane
%  descr     - description of file, scan
%
%  hdr       - structure with all the fields mentionened above plus
%               path - path fol file
%
%  abs_pix_val = (pix_val - offset) * scale
%
%  CS, 130398
%  CS, 280100  Reading changed so routines works on both HP and Linux
%              systems
%  CS, 150200  Extended to be able to use descrion field
%  CS, 060700  Structure input (hdr) extended as possibility
%  CS, 210901  Extended with extra 'path' field in stucture hdr
%
% (c) Roger Gunn 2002 


if (nargin ~=1) & (nargin ~= 8) & (nargin ~= 9)
   ErrTxt=sprintf('WriteAnalyzeHdr, (%i) is an incorrect number of input arguments',nargin);
   error(ErrTxt);
end;
if (nargin == 8)
  descr='Header generated using WriteAnalyzeHdr';
end
if (nargin == 8) | (nargin == 9)
  path='';
end  
%
if (nargin == 1)
  hdr=name;
  %
  if (~isfield(hdr,'name'))
    error('hdr.name does not exist');
  end;
  name=hdr.name;
  if (~isfield(hdr,'dim'))
    error('hdr.dim does not exist');
  end;
  dim=hdr.dim;
  if (~isfield(hdr,'siz'))
    error('hdr.siz does not exist');
  end;
  siz=hdr.siz;
  if (~isfield(hdr,'pre'))
    error('hdr.pre does not exist');
  end;
  pre=hdr.pre;
  if (~isfield(hdr,'lim'))
    error('hdr.lim does not exist');
  end;
  lim=hdr.lim;
  if (~isfield(hdr,'scale'))
    error('hdr.scale does not exist');
  end;
  scale=hdr.scale;
  if (~isfield(hdr,'offset'))
    error('hdr.offset does not exist');
  end;
  offset=hdr.offset;
  if (~isfield(hdr,'origin'))
    origin=[0 0 0];
  else  
    origin=hdr.origin;
  end;
  if (~isfield(hdr,'descr'))
    descr='Header generated using WriteAnalyzeHdr';
  else  
    descr=hdr.descr;
  end;
  if (~isfield(hdr,'path')) | ...
    ~isempty(findstr(hdr.name,'/')) | ... 
    ~isempty(findstr(hdr.name,'\')) 
    path='';
  else  
    path=hdr.path;
    if ~isempty(path)
      cname = computer;
      if strcmp(cname(1:2),'PC')
        if (path(length(path)) ~= '\')
          path(length(path)+1) ='\';
        end
      else  
        if (path(length(path)) ~= '/')
          path(length(path)+1) ='/';
        end
      end
    end  
  end;
end
%
if (length(dim) == 3)
  dim(4)=1;
end;  
result=1;
FileName=sprintf('%s%s.hdr',path,name);
pid=fopen(FileName,'wb','ieee-be');
%
fwrite(pid,348,'int');
fwrite(pid,zeros(28,1),'char');
fwrite(pid,16384,'int');
fwrite(pid,zeros(2,1),'char');
fwrite(pid,'r','char');
fwrite(pid,zeros(1,1),'char');

fwrite(pid,4,'int16');
fwrite(pid,dim,'int16');
fwrite(pid,zeros(20,1),'char');

if (pre == 8),
  fwrite(pid,2,'int16');
elseif (pre == 16),
  fwrite(pid,4,'int16');
elseif (pre == 32),
  fwrite(pid,32,'int16');
elseif (pre == 64),
  fwrite(pid,64,'int16');
elseif (pre == 1),
  fwrite(pid,1,'int16');
else
  error('WriteAnalyzeHdr, pre parameter do not have allowable value');
end  

fwrite(pid,pre,'int16');
fwrite(pid,zeros(6,1),'char');

if (length(siz) ~= 3)
  error('WriteAnalyzeHdr, siz parameter do not have allowable value');
end;  
fwrite(pid,siz,'float32');

fwrite(pid,zeros(16,1),'char');
fwrite(pid,offset,'float32');
fwrite(pid,scale,'float32');
fwrite(pid,zeros(24,1),'char');

fwrite(pid,lim(1),'int');
fwrite(pid,lim(2),'int');

fwrite(pid,sprintf('%-80s',descr),'char');
fwrite(pid,zeros(24,1),'char');
fwrite(pid,0,'char');  % orientation

if (length(origin) ~= 3)
  error('WriteAnalyzeHdr, origin parameter do not have allowable value');
end;  
fwrite(pid,origin,'int16');  

fwrite(pid,zeros(89,1),'char'); 

fclose(pid);



