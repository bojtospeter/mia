function cell2csv(csvName,cellArray,delimeter)
% function cell2csv(csvName,cellArray,delimeter)
% Writes Cell-Array content into csv.
% 
% csvName = Name of the csvfile to save.
% cellarray = Name of the Cell Array where the data is in
% delimeter = seperating character: default is '\t'

% by Sylvain Fiedler, KA, 2004

if nargin == 2
    delimeter = '\t';
end

datei = fopen(csvName,'w');
for z=1:size(cellArray,1)
    for s=1:size(cellArray,2)
        
        var = eval(['cellArray{z,s}']);
        
        if size(var,1) == 0
            break;
            %var = '';
        end
        
        if isnumeric(var) == 1
            var = num2str(var);
        end
        
        fprintf(datei,var);
        
        if s ~= size(cellArray,2)
            fprintf(datei,delimeter);
        end
    end
    fprintf(datei,'\n');
end
fclose(datei);