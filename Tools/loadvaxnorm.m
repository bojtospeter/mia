function normVOL = loadvaxnorm(filename)
% function normVOL = loadvaxnorm(filename)
%
if nargin == 0
     [FileName, FilePath] = uigetfile('norm*.dat','Select GE4096 norm file');
     filename = [FilePath,FileName];
     if FileName == 0;
          dataVOL = [];scaninfo = []; singles = []; hvax = [];
          return;
     end
end
num_of_slice = 15;
num_of_projection = 512;
num_of_member = 96;
num_of_crystal = 4096;
%
% Checking the file input
%
filelis= dir(filename);
num_of_file = size(filelis,1);
if num_of_file == 0
    disp('No data file was found!');
    dataVOL=[];
    return;
end
%
% reading the norm values
%
vaxpid = fopen(filename,'r','vaxd');
hvax = fread(vaxpid,4096,'char');%skip the header
normVOL = zeros(num_of_projection,num_of_member,num_of_slice);
for i=1:num_of_slice
    normVOL(:,:,i)=fread(vaxpid,[num_of_member num_of_projection],'float')';
end
fclose(vaxpid);   