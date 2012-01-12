function suvVOL = suv(imaVOL,isotope_type,timediff_for_decaycorrection,injected_dose,bodyweight,bodyheight)
%function suvVOL = suv(imaVOL,isotope_type,timediff_for_decaycorrection,injected_dose,bodyweight,bodyheight)
%  Normalize a volume to SUV (standard uptake value) scale
%  Inputs:  
%       imaVOL                          - input volume (3dim x,y,z) scaled in [nCi/ml]
%       isotope_type                    - F18, C11, N13, O15
%       timediff_for_decaycorrection    =: scanmidtime - injection time [sec]     
%       injected_dose                   - the injected dose [mCi]
%       bodyweight                      - weight of the patient [kg]
%       bodyheight                      - height of the patient [m]
%
% DEOEC PET Center/LB 2004

if nargin  < 5
    disp('At least 5 input parameters to be supplied!');
elseif nargin  == 5
    bodyheight = [];
end
suvVOL = [];
switch isotope_type
	case 'C11'
        isotope_half_time = 20.4*60;% [sec]        
	case 'F18'
        isotope_half_time = 109.8*60;% [sec]             
	case 'O15'
        isotope_half_time = 122.24;% [sec]           
	case 'N13'
        isotope_half_time = 9.97*60;% [sec]
    otherwise isotope_half_time = [];
end
if isempty(isotope_half_time)
        msgbox('No valid isotop definition was found!','SUV calc. warning','warn');
        return;
end
if isempty(bodyheight) 
    suvVOL = double(double(imaVOL).*2^(timediff_for_decaycorrection/isotope_half_time)) * bodyweight/injected_dose*1/1000; 
else
    BSA = (bodyweight^0.425 * bodyheight^0.725)*0.007184;
    suvVOL = double(double(imaVOL).*2^(timediff_for_decaycorrection/isotope_half_time)) * BSA/injected_dose; 
end