function [dataVOL,singles,scaninfo,hvax] = loadvaxdata(filename)
% function [dataVOL,singles,scaninfo] = loadvaxdata(filename)
%
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
% Reading the file header
%
scaninfo = scxheader(filename);
%
% reading the singles and the coincidences counts
%
vaxpid = fopen(filename,'r','vaxd');
hvax = fread(vaxpid,4096,'char');%skip the header
singles=fread(vaxpid,num_of_crystal,'uint32');
dataVOL = zeros(num_of_projection,num_of_member,num_of_slice);
for i=1:num_of_slice
    dataVOL(:,:,i)=fread(vaxpid,[num_of_member num_of_projection],'ushort')';
end
fclose(vaxpid);
    