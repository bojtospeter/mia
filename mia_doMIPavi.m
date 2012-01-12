function mia_doMIPavi(imaVOL, scaninfo, ymin, ymax, xmin, xmax,petcolormap,outputfilename,minpix,maxpix)
%function mia_doMIPavi(imaVOL, scaninfo, ymin, ymax, xmin, xmax, petcolormap,outputfilename,minpix,maxpix)
%
% MIP (maximal intensity projection) avi file generation
%
% Matlab library function for mia_gui utility. 
% University of Debrecen, PET Center/LB 2003

MIPresize = 0;
MIPsmoothYes = 0;
pixsize = scaninfo.pixsize;
%
% The MIP generation is time consuming:
% the process runs on MPISize*MIPSize images
%
MIPSize = 200;
%DataAspectRatio = [size(imaVOL,3)*pixsize(3) size(imaVOL,1)*pixsize(1) 1] ;
volsiz=size(imaVOL);
projsize = round(sqrt(volsiz(1)^2+volsiz(2)^2))+10;
PlotBoxAspectRatio = [projsize*pixsize(1) size(imaVOL,3)*pixsize(3)  1];
if scaninfo.imfm(1) > MIPSize
    %
	% setting up the progression bar
	%
	info.color=[1 0 0];
	info.title='MIP avi preparing ...';
	info.size=1;
	info.pos='topleft';
	p=progbar(info);
    imaVOLin = uint16(zeros(MIPSize,MIPSize,scaninfo.num_of_slice));
    for i = 1: scaninfo.num_of_slice
        progbar(p,round(i/scaninfo.num_of_slice*100));
        imaVOLin(:,:,i) = imresize(imaVOL(:,:,i), [MIPSize MIPSize],'bilinear');
        %imaVOLr(:,:,i) = imresize(imaVOL(:,:,i), [MIPSize MIPSize]);
    end
    close(p);
else
        imaVOLin = imaVOL;
end

imaVOL = [];
%
% setting up the progression bar
%
info.color=[1 0 0];
info.title='MIP avi generation';
info.size=1;
info.pos='topleft';
p=progbar(info);
progbar(p,5);

if MIPresize
    imatmp = uint16(imaVOL(ymin:ymax,xmin:xmax,:));
    newsiz1 = round(size(imatmp,1)/2); newsiz2 = round(size(imatmp,2)/2);
    imaVOLin = zeros(newsiz1,newsiz2,size(imatmp,3));
    for i=1:num_of_slice
       imaVOLin(:,:,i) = imresize(squeeze(imatmp(:,:,i)),[newsiz1 newsiz2]);   
    end
else
    %imaVOLin = uint16(imaVOL(ymin:ymax,xmin:xmax,:));
end
if MIPsmoothYes
    fprintf('Smoothing the volume for MIP generation...'); 
    imatmp = smooth3(imaVOLin,'gaussian');
    imaVOLin = uint16(imatmp);
    imatmp=[];
end

volsiz=size(imaVOLin);
projsize = round(sqrt(volsiz(1)^2+volsiz(2)^2))+10;
deltaalfa=10;
projections = zeros(projsize,volsiz(3),360/deltaalfa);

% start the MIP generation
for i=0:360/deltaalfa-1
    rotalfa = i*deltaalfa; 
    imaVOLtmp = imrotate(imaVOLin,rotalfa);
    voltmpsiz = size(imaVOLtmp);
    x0=round((projsize-voltmpsiz(2))/2);
    %projections(x0:x0+voltmpsiz(2)-1,:,i+1) = smooth2(squeeze(max(imaVOLtmp)));
    projections(x0:x0+voltmpsiz(2)-1,:,i+1) = (squeeze(max(imaVOLtmp)));
    if i > 3 ;progbar(p,round(i*100/(360/deltaalfa)));drawnow;end
end
disp(' ');
close(p);
%mov = avifile([dirname,'MIP_',num2str(scaninfo.brn),'.avi'],'fps',12,'compression','none');
mov = avifile(outputfilename,'fps',12,'compression','none');
hf = figure('NumberTitle','off','name','MIP slices','renderer','opengl');
MIPAxis = gca;
set(MIPAxis,'PlotBoxAspectRatio',PlotBoxAspectRatio);
hold on;
map=colormap(petcolormap);
%%%%%%colormap(spectral);%%%%%%%
for k=1:360/deltaalfa;
    imagesc(rot90(projections(:,:,k)),[minpix maxpix]);
    %set(MIPAxis,'PlotBoxAspectRatio',PlotBoxAspectRatio);
    hchild = get(gcf,'children');set(hchild,'visible','off')
    tmpframe = getframe(gca);
    mov = addframe(mov,tmpframe);
end
mov = close(mov);
delete(hf);
