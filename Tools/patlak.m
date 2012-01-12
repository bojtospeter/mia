function  GMRvol = patlak(handles,bloodtactfile,glucose,LC,output,micromolScaleYES)
%function  GMRvol = patlak(filelist,dirname,bloodtactfile,glucose,LC,output,micromolScaleYES)
% function  patlak(filename,bloodtactfile,glucoseLC,output,micromolScaleYES)
%
% MATLAB modul for calculating Kpat and Vd Patlak parameter's and images slice by slice
% using user defined mask's on the slices.
% This function is usually called by patlak_gui.m the GUI of patlak analysis.   

% 
% University of Debrecen, PET CENTER
% History
% 30/06/1996 /BL
% 15/12/1996 /BL Building the blood_curve_par.m and bloodcurve.m moduls to use
% 		 fine blood curve for integral calculation
% 20/04/2002 enable the VAX format input/output file format 
warning off;
%imapath='c:\data\';
%
% user input constants
%
%LC = 1;
glucose=glucose*180/10; %MW of glucose = 180 g/mol 
if micromolScaleYES
    gluc_conv_fact = 18;
    glucose=glucose/gluc_conv_fact; %This conversion for micromol/g/min GMR unit
else
    gluc_conv_fact = 1;
end
%
% preparing the necessary variables
%
t0 = clock;
ImageSizeForCalc = 128;
num_of_petslice = handles.scaninfo(1).num_of_slice;
brn=handles.scaninfo(1).brn;
ImageSize = handles.scaninfo(1).imfm;
Frames = handles.scaninfo(1).Frames;
imaVOL128 = uint16(zeros(ImageSizeForCalc, ImageSizeForCalc, Frames*num_of_petslice));
%
% resizing the dyn frames for ImageSizeForCalc pixel res. 
%
% SETTING UP THE PROGRESS BAR
info.color=[1 0 0];
info.title='Resizing the images';
info.size=1;
info.pos='topleft';
p=progbar(info);
progbar(p,0);
for i=1:Frames*num_of_petslice
    if mod(i,num_of_petslice)
        progbar(p,round(i*100/Frames*num_of_petslice));drawnow;
    end
    imaVOL128(:,:,i) = imresize(handles.imaVOL(:,:,i),[ImageSizeForCalc ImageSizeForCalc]);
end
close(p);
%defining the tissue(framemidtime) and scan_start time scale 
tissue_ts = handles.scaninfo(1).tissue_ts/60; %[min]
frame_lengths = handles.scaninfo(1).frame_lengths/60; %[min]
%
% loading the blood curve
%
if strcmp(bloodtactfile(end-2:end),'act');
    actdata = loadtacts(bloodtactfile);
    num_of_tact = size(actdata,2)-1;
    bloodtact_index=2;
    bloodpar = eval_bloodcurve_par(actdata(1).tact,actdata(bloodtact_index).tact);
else
    blooddata = load(bloodtactfile);
    bloodpar = eval_bloodcurve_par(blooddata(:,1),blooddata(:,2));
end
blood_delay=bloodpar(7);
tissue_ts=tissue_ts+blood_delay;
%
%  creating the fine time and blood scale
%
dtime=10/60;%[10 sec]
finesteps=round(max(tissue_ts)/dtime);
fine_ts=dtime*(0:1:finesteps-1)';
blood_fas=bloodcurve(fine_ts, bloodpar);
intp_blood_as = bloodcurve(tissue_ts,bloodpar);
%
% plot the blood curve
%
figure;
plot(fine_ts,blood_fas,'-r');
xlabel('Time [min]');
ylabel('Activity conc. [nCi/ml]');
title(['Blood curve',' Patientcode: ',num2str(handles.scaninfo(1).brn)]);
pause(3);
%
%calculating the integrated blood function at the time points of tissue_ts
%
int_blood_as = zeros(size(tissue_ts));
for i=2:length(tissue_ts); 
        int_blood_as(i) = trapz(tissue_ts(1:i),intp_blood_as(1:i));         
end
intint_blood_as=zeros(size(int_blood_as));
for i=2:length(tissue_ts); 
	intint_blood_as(i) = trapz(tissue_ts(1:i),int_blood_as(1:i));
end
%
%declaring the output matrixes
%
sliceVOL = zeros(ImageSizeForCalc,ImageSizeForCalc,num_of_petslice);
K_images=zeros(ImageSize, ImageSize, num_of_petslice);
Bl_k1_images = zeros(ImageSize, ImageSize, num_of_petslice);
Bl_k2_images = zeros(ImageSize, ImageSize, num_of_petslice);
Bl_k3_images = zeros(ImageSize, ImageSize, num_of_petslice);
Bl_k4_images = zeros(ImageSize, ImageSize, num_of_petslice);
%
% Start the calculation loop by slices
%
disp(' ');
disp('Start the Patlak analysis:');
F0=20;%The number of time points for calculating Kpat and Vd values.
%tissue_ts(F0:Frames)
patlak_x  = int_blood_as(F0:Frames)'./intp_blood_as(F0:Frames)';
% SETTING UP THE PROGRESS BAR
info.color=[1 0 0];
info.title='Patlak analysis';
info.size=1;
info.pos='topleft';
p=progbar(info);
progbar(p,0);
for slice= 1 : num_of_petslice
%for slice= 5 : 5
    progbar(p,round(slice*100/num_of_petslice));drawnow;    
    % Selecting the pixels where the activity higher then the average
    % All calculaton will perform on these pixels
    slicerange = [slice:num_of_petslice:Frames*num_of_petslice];
    sliceVOL = imaVOL128(:,:,slicerange);
    imagesummed = zeros(ImageSizeForCalc,ImageSizeForCalc);
	for fr = 1 :Frames
        imagesummed = imagesummed + double(sliceVOL(:,:,fr))*frame_lengths(fr);
    end
	avg = mean(mean(imagesummed));
	imgmask = imagesummed > avg;
	px        = find( imgmask );	
	tissue_as = zeros(size(px,1),Frames);
	for fr = 1: Frames
        temp = sliceVOL(:,:,fr);
        tissue_as(:,fr) = temp(px);
    end
	Kpat_img  = zeros(ImageSizeForCalc, ImageSizeForCalc);
    Bl_I_K_img =  zeros(ImageSizeForCalc, ImageSizeForCalc);
    Bl_I_k1_img =  zeros(ImageSizeForCalc, ImageSizeForCalc);
    Bl_I_k2_img =  zeros(ImageSizeForCalc, ImageSizeForCalc);
    Bl_I_k3_img =  zeros(ImageSizeForCalc, ImageSizeForCalc);
    %Bl_II_K_img =  zeros(ImageSizeForCalc, ImageSizeForCalc);
    %Bl_II_k1_img =  zeros(ImageSizeForCalc, ImageSizeForCalc);
    %Bl_II_k2_img =  zeros(ImageSizeForCalc, ImageSizeForCalc);
    %Bl_II_k3_img =  zeros(ImageSizeForCalc, ImageSizeForCalc);
    
	fprintf(['slice= ',num2str(slice), '  number of pixels = ',num2str(length(px)),' ']);
	for j=1:length(px)
	% perform the PATLAK analysis
        patlak_y  = tissue_as(j,F0:Frames)'./intp_blood_as(F0:Frames)';
		patlakres = ([ ones(size(patlak_x)) patlak_x]\patlak_y)';
        Kpat_img(px(j)) = patlakres(2); 
    % perform the BLOMQVIST analysis
        %Csak akkor számol a program k1,k2,k3 értékeket ha a patlakres(2)*glucose/LC > 0.2 mg/100g/min
        if patlakres(2)*glucose/LC > 1/gluc_conv_fact;
			%calculate the integrated tissue curve
            int_tissue_as=zeros(size(tissue_ts));
			for i=2:length(tissue_ts); 
			  int_tissue_as(i) = trapz(tissue_ts(1:i),tissue_as(j,1:i));
            end
            %calculate the double integrated tissue curve for Blomqvist II. method
			%intint_tissue_as=zeros(size(tissue_ts));
			%for i=2:length(tissue_ts); 
			 % intint_tissue_as(i) = trapz(tissue_ts(1:i),int_tissue_as(1:i));
            %end
            %%create the Blomqvist II. matrix and solving the linear Bl II. eq.
			%Bl_int_II = [intp_blood_as' int_blood_as' -int_tissue_as' intint_blood_as' -intint_tissue_as'];
			%Bl_KII = Bl_int_II(F0:Frames,:)\tissue_as(j,F0:Frames)';
			%Bl_kII(5) = Bl_KII(1);
			%Bl_kII(1) = Bl_KII(2)- Bl_KII(1)*Bl_KII(3);
			%k34tmp = (Bl_KII(4) - Bl_KII(1)*Bl_KII(5))/Bl_kII(1);
			%Bl_kII(2) = Bl_KII(3) - k34tmp;
			%Bl_kII(4) = Bl_KII(5)/Bl_kII(2);
			%Bl_kII(3) = k34tmp - Bl_kII(4);
			%Bl_KII = Bl_kII(1)*Bl_kII(3)/(Bl_kII(2)+Bl_kII(3));
            %Bl_II_k1_img(px(j)) = Bl_kII(1); Bl_II_k2_img(px(j)) = Bl_kII(2); Bl_II_k3_img(px(j)) = Bl_kII(3);
			%Bl_II_k4_img(px(j)) = Bl_kII(4); Bl_II_K_img(px(j)) = Bl_KII;
       
            %create the Blomqvist I. matrix and solving the linear Bl I. eq.
			Bl_int=[int_blood_as' intint_blood_as' -int_tissue_as'];
			Bl_K=Bl_int\tissue_as(j,:)';
			Bl_KI=Bl_K(2)/Bl_K(3); 
			Bl_kI(1) = Bl_K(1); Bl_kI(3) = Bl_K(2)/Bl_K(1); ...
			Bl_kI(2) = Bl_K(3)-Bl_kI(3);
            Bl_I_k1_img(px(j)) = Bl_kI(1); Bl_I_k2_img(px(j)) = Bl_kI(2); Bl_I_k3_img(px(j)) = Bl_kI(3);
			Bl_I_K_img(px(j)) = Bl_KI;
        end
        if  mod(j,100) == 0
		  fprintf ('.');
	    end
	end
    disp(' ');
    %
    % zero padding the negativ elements
    %
	Zrange = find(Kpat_img < 0);        Kpat_img(Zrange) = 0;
    Zrange = find(Bl_I_K_img < 0); 	    Bl_I_K_img(Zrange) = 0;
    %Zrange = find(Bl_II_K_img < 0); 	Bl_II_K_img(Zrange) = 0;
    % also kuszob alkalmazasa
	%Zrange = find(Bl_II_k1_img < 0); 	Bl_II_k1_img(Zrange) = 0;
	%Zrange = find(Bl_II_k2_img < 0);    Bl_II_k2_img(Zrange) = 0;	 
	%Zrange = find(Bl_II_k3_img < 0);    Bl_II_k3_img(Zrange) = 0;
    %Zrange = find(Bl_II_k4_img < 0);    Bl_II_k4_img(Zrange) = 0;
    Zrange = find(Bl_I_k1_img < 0); 	Bl_I_k1_img(Zrange) = 0;
	Zrange = find(Bl_I_k2_img < 0);     Bl_I_k2_img(Zrange) = 0;	 
	Zrange = find(Bl_I_k3_img < 0);     Bl_I_k3_img(Zrange) = 0;
	% felso kuszob alkalmazasa
	%Zrange = find(Bl_II_k1_img > 1);  	Bl_II_k1_img(Zrange) = 0;
	%Zrange = find(Bl_II_k2_img > 3);    Bl_II_k2_img(Zrange) = 0;	 
	%Zrange = find(Bl_II_k3_img > 1);  Bl_II_k3_img(Zrange) = 0;
    %Zrange = find(Bl_II_k4_img > 0.1);  Bl_II_k4_img(Zrange) = 0;
    Zrange = find(Bl_I_k1_img > 1);  	Bl_I_k1_img(Zrange) = 0;
	Zrange = find(Bl_I_k2_img > 3);     Bl_I_k2_img(Zrange) = 0;	 
	Zrange = find(Bl_I_k3_img > 0.1);   Bl_I_k3_img(Zrange) = 0;
    %
    %Smoothing and reinterpolating the results
    %
    %imatmp = conv2(Kpat_img,kernel(2,'gaussian'),'same');
    K_images(:,:,slice)= conv2(Kpat_img,kernel(2,'gaussian'),'same')*glucose/LC;
    %imatmp = conv2(Bl_I_k1_img,kernel(2,'gaussian'),'same');
    Bl_k1_images(:,:,slice)= conv2(Bl_I_k1_img,kernel(2,'gaussian'),'same');
	%imatmp = conv2(Bl_I_k2_img,kernel(2,'gaussian'),'same');
    Bl_k2_images(:,:,slice)= conv2(Bl_I_k2_img,kernel(2,'gaussian'),'same');
	%imatmp = conv2(Bl_I_k3_img,kernel(2,'gaussian'),'same');
    Bl_k3_images(:,:,slice)= conv2(Bl_I_k3_img,kernel(2,'gaussian'),'same');
    %imatmp = conv2(Bl_II_k4_img,kernel(2,'gaussian'),'full');
    %Bl_k4_images(:,:,slice)= imresize(imatmp,[ImageSize ImageSize]);
end
close(p);
%
% Plotting result montage of GMR images 
%
if micromolScaleYES
    unitstring = 'GMR Patlak images [microM/g/min]';
else
    unitstring = 'GMR Patlak images [mg/100g/min]';
end
save patlak_tst;
imgmontage(K_images,[unitstring,' Patientcode: ',num2str(handles.scaninfo(1).brn)]);
disp('Saving the results...');

if strcmp(output,'yes') 
    GMRvol = K_images;
else
    GMRvol =[];
end
if strcmp(handles.scaninfo(1).FileType,'mnc') |  strcmp(handles.scaninfo(1).FileType,'vms')%Only GMR output file at MNC case 
    outfilename = [handles.dirname,num2str(handles.scaninfo(1).brn),'_LGMR_', ...
            num2str(handles.scaninfo(1).rin),'.mnc'];
    handles.scaninfo.Frames = 1;
    handles.scaninfo.cntx = 'LGMR';
    wresult = saveminc(outfilename,K_images,handles.scaninfo(1));
    return;
end
%
% Save the files at scx ima case
%
K_images = (flipdim(permute(K_images,[2 1 3]),2));
Bl_k1_images = (flipdim(permute(Bl_k1_images,[2 1 3]),2));
Bl_k2_images = (flipdim(permute(Bl_k2_images,[2 1 3]),2));
Bl_k3_images = (flipdim(permute(Bl_k3_images,[2 1 3]),2));
%
% save the output GMR file
%
K_images = (flipdim(permute(K_images,[2 1 3]),1));
Bl_k1_images = (flipdim(permute(Bl_k1_images,[2 1 3]),1));
Bl_k2_images = (flipdim(permute(Bl_k2_images,[2 1 3]),1));
Bl_k3_images = (flipdim(permute(Bl_k3_images,[2 1 3]),1));
outfilename = [handles.dirname,'pc',handles.scaninfo(1).rid,'_LGMR_',num2str(handles.scaninfo(1).rin), ...
        '_',num2str(handles.scaninfo(1).brn),'.ima'];

vaxfid = fopen(outfilename,'w','vaxd');
fwrite(vaxfid,handles.fileheader,'char');
for i = 1 : num_of_petslice
    slicemaxs(i) = max(max(K_images(:,:,i)));
    sliceout = (K_images(:,:,i)*(32000)/slicemaxs(i));
    fwrite(vaxfid,sliceout,'ushort');
end
fclose(vaxfid);
%
% modify the CNTX and MAG mnemonics in the vax fileheader 
%
context = 'LGMR      ';
scxheader_edit(outfilename, context, slicemaxs);
disp(['Done! The elapsed time :',num2str(etime(clock,t0)/60),' min']);

%
% Plotting result montage of k1..k3 images 
%
imgmontage(Bl_k1_images,['GMR k1 images [1/min]',' Patientcode: ',num2str(handles.scaninfo(1).brn)]);
imgmontage(Bl_k2_images,['GMR k2 images [1/min]',' Patientcode: ',num2str(handles.scaninfo(1).brn)]);
imgmontage(Bl_k3_images,['GMR k3 images [1/min]',' Patientcode: ',num2str(handles.scaninfo(1).brn)]);
%
%
% SAVE the k1...k3 images to file
%
% save the output k1 files
%
outfilename = [handles.dirname,'pc',handles.scaninfo(1).rid,'_k1____',num2str(handles.scaninfo(1).rin), ...
        '_',num2str(handles.scaninfo(1).brn),'.ima'];

vaxfid = fopen(outfilename,'w','vaxd');
fwrite(vaxfid,handles.fileheader,'char');
for i = 1 : num_of_petslice
    slicemaxs(i) = max(max(Bl_k1_images(:,:,i)));
    sliceout = (Bl_k1_images(:,:,i)*(32000)/slicemaxs(i));
    fwrite(vaxfid,sliceout,'ushort');
end
fclose(vaxfid);
%
% modify the CNTX and MAG mnemonics in the vax fileheader 
%
context = 'k1        ';
scxheader_edit(outfilename, context, slicemaxs);
%
% save the output k2 files
%
outfilename = [handles.dirname,'pc',handles.scaninfo(1).rid,'_k2____',num2str(handles.scaninfo(1).rin), ...
        '_',num2str(handles.scaninfo(1).brn),'.ima'];

vaxfid = fopen(outfilename,'w','vaxd');
fwrite(vaxfid,handles.fileheader,'char');
for i = 1 : num_of_petslice
    slicemaxs(i) = max(max(Bl_k2_images(:,:,i)));
    sliceout = (Bl_k2_images(:,:,i)*(32000)/slicemaxs(i));
    fwrite(vaxfid,sliceout,'ushort');
end
fclose(vaxfid);
%
% modify the CNTX and MAG mnemonics in the vax fileheader 
%
context = 'k2        ';
scxheader_edit(outfilename, context, slicemaxs);
%
% save the output k3 files
%
outfilename = [handles.dirname,'pc',handles.scaninfo(1).rid,'_k3____',num2str(handles.scaninfo(1).rin), ...
        '_',num2str(handles.scaninfo(1).brn),'.ima'];

vaxfid = fopen(outfilename,'w','vaxd');
fwrite(vaxfid,handles.fileheader,'char');
for i = 1 : num_of_petslice
    slicemaxs(i) = max(max(Bl_k3_images(:,:,i)));
    sliceout = (Bl_k3_images(:,:,i)*(32000)/slicemaxs(i));
    fwrite(vaxfid,sliceout,'ushort');
end
fclose(vaxfid);
%
% modify the CNTX and MAG mnemonics in the vax fileheader 
%
context = 'k3        ';
scxheader_edit(outfilename, context, slicemaxs);








