function actdata = loadtacts(actfile)
% function actdata = loadtacts(actfile)
%
% Reading IDA format act file.
% The actdata is a structure containing the 
% TACT names and curves in the following manner:
%
%   ith curve name    actdata(i).name
%   ith curve         actdata(i).tact
%   The i = 1 case contain the time scale.

fid = fopen(actfile);
fscanf( fid, '%s%',1);fscanf( fid, '%s%',1);%ignoring the first 2 line
num_of_tact = fscanf( fid, '%2d',1);
num_of_point = fscanf( fid, '%2d',1);
%
%reading  the time scale
%
actdata(1).name='tissue_ts';
actdata(1).tact = fscanf( fid, '%f',[num_of_point 1]);%reading the time scale
%
%reading the tact curves
%
for j=1:num_of_tact
    actdata(j+1).name = fscanf( fid, '%s%',1);
    fscanf( fid, '%s%',1);%ignoring the slice ident. numbers(eg.:101)
    for i=1:num_of_point
        tmptact(i) = fscanf( fid, '%f',1);
        fscanf( fid, '%f',1);%ignoring the STDEV values
    end
    actdata(j+1).tact =tmptact'; 
end
fclose(fid);

