function [haxial, hcoronal, hsagital] = imadoc(imaVOL, scaninfo, max_pix, min_pix, ymin, ymax, xmin, xmax, petcolormap, xyres)
%function imadoc(imaVOL, scaninfo, max_pix, min_pix, ymin, ymax, xmin, xmax, petcolormap, xyres,MIPaviYes,MIPsmoothYes)
%
warning off;
sagsize = xmax-xmin+1;
corsize = ymax-ymin+1;
imsize = scaninfo.imfm;
num_of_slice = scaninfo.num_of_slice;
pixsize = scaninfo.pixsize;
xsize = imsize; zsize = round(num_of_slice*pixsize(3)/pixsize(1));
% init.the progressbar
info.color=[1 0 0];
info.title='Reslicing';
info.size=1;
info.pos='bottomright';
pb=progbar(info);
%
%cut off the high  and low activity level
%
%rrmax = find(imaVOL>max_pix); rrmin = find(imaVOL<min_pix);
%imaVOL(rrmax) = max_pix; imaVOL(rrmin) = 0;
% 
% transaxial montage
% creating index image to enable the montage option
%
progbar(pb,5);
%fprintf('Creating transaxial images ');
imaind = [];
if num_of_slice > 50 
    tran = uint16(zeros(corsize,sagsize,floor((num_of_slice-1)/2)));
    imaind = uint16(zeros(corsize,sagsize,1,floor((num_of_slice-1)/2)));
	for i=1:floor((num_of_slice-1)/2)
        tran(:,:,i) = (sum((imaVOL(ymin:ymax,xmin:xmax,(i-1)*2+1:i*2)),3)/2);
	end
    pixsize3 = pixsize(3)*2;
    for i= 1:floor((num_of_slice-1)/2)
        imatmp = conv2(tran(:,:,i),kernel(2,'gaussian'),'same');
        imaind(:,:,1,i) = imatmp;
	end
else
	tran = uint16(zeros(corsize,sagsize,num_of_slice));
	for i=1:num_of_slice
        tran(:,:,i) = imaVOL(ymin:ymax,xmin:xmax,i);
	end
	%
	% smoothing the slices
	%
	for i= 1:num_of_slice
        %imatmp = conv2(tran(:,:,i),kernel(2,'gaussian'),'same');
        %imaind(:,:,1,i) = imatmp;
        imaind(:,:,1,i) = tran(:,:,i);
	end
    pixsize3 = pixsize(3);
end
progbar(pb,20);
tran=[];
% set up the figure
scrsz = get(0,'ScreenSize');
PlotLeft =  scrsz(3)/8; PlotBottom =  scrsz(4)/4;
PlotHeight = scrsz(4)/2;
PlotBAspectRatio = [size(imaVOL,1)*pixsize(1) size(imaVOL,2)*pixsize(2) 1];
PlotWidth = PlotHeight*PlotBAspectRatio(1)/PlotBAspectRatio(2); 
titleout=['Axial Slices. Slice width = ',num2str(pixsize3),'mm. Scan ID: ',num2str(scaninfo.brn)];
figure('Position',[PlotLeft PlotBottom PlotWidth PlotHeight],'Name',titleout,'NumberTitle','off','renderer','opengl');
% plot the montage
map=colormap(petcolormap);
haxial = montage(imaind,map);
set(get(haxial,'parent'),'Clim',[min_pix max_pix]);
set(haxial,'CDataMapping','scaled');
set(gca,'position',[0 0 1 1]); 
hc = colorbar; set(hc,'position',[0.86 0.2 0.1 0.6]);  set(hc,'PlotBoxAspectRatio',[1 10 1]);
progbar(pb,30);
%
% Coronal montage
% resize the sag matrix to the real image ratio
%
%disp(' ');
%fprintf('Creating coronal images');
cor = uint16(zeros(sagsize,zsize,imsize/xyres));
imaind=uint16(zeros(sagsize,zsize,1,imsize/xyres));
corstep = [1:xyres:imsize];
corrange = find(corstep > ymin & corstep < ymax);
for i = corrange 
    cor(:,:,i) = imresize(squeeze(sum((imaVOL( (i-1)*xyres+1:i*xyres,xmin:xmax,:)),1)/xyres),[sagsize zsize]);
end
%
%generate index image for montage
%
for i = corrange 
    imaind(:,:,1,i) = cor(:,:,i);
end
cor=[];
for i = 1: length(corrange) 
    zz(i)= length(find( imaind(:,:,:,i)>max_pix*0.1  ) );
end
rrimaind = find(zz >0);
progbar(pb,40);
%
% smoothing the intresting images
%
%for i= rrimaind
%    imatmp = conv2(imaind(:,:,1,i),kernel(2,'gaussian'),'same');
%    imaind(:,:,1,i) = imatmp;
%end
%
% set up the figure
%
PlotLeft =  scrsz(3)*2/8; PlotBottom =  scrsz(4)/4;
PlotHeight = scrsz(4)/2;
PlotBAspectRatio = [size(imaVOL,2)*pixsize(2) size(imaVOL,3)*pixsize(3) 1];
PlotWidth = PlotHeight*PlotBAspectRatio(2)/PlotBAspectRatio(3); 
titleout=['Coronal Slices (U->D). Slice width = ',num2str(pixsize(2)*xyres),'mm. Scan ID: ',num2str(scaninfo.brn)];
figure('Position',[PlotLeft PlotBottom PlotWidth PlotHeight],'Name',titleout,'NumberTitle','off','renderer','opengl');
%
% do the montage
%
map=colormap(petcolormap);
hcoronal = montage(imaind(:,:,:,rrimaind),map);
set(get(hcoronal,'parent'),'Clim',[min_pix max_pix]);
set(hcoronal,'CDataMapping','scaled'); 
set(gca,'position',[0 0 1 1]); 
hc = colorbar; set(hc,'position',[0.86 0.2 0.1 0.6]); set(hc,'PlotBoxAspectRatio',[1 10 1]);
imaind=[];
progbar(pb,60);
%
% Sagittal montage
%
%disp(' ');
%fprintf('Creating sagittal images');
sag = uint16(zeros(corsize,zsize,imsize/xyres));
imaind = uint16(zeros(corsize,zsize,1,imsize/xyres));
for i=1:imsize/xyres
    sag(:,:,i) = imresize(squeeze(sum( imaVOL(ymin:ymax,(i-1)*xyres+1:i*xyres,:), 2)/xyres),[corsize zsize]);
end
%generate index image for montage
for i=1:imsize/xyres
    imaind(:,:,1,i) = sag(:,:,i);
end
sag=[];
progbar(pb,80);
%find images containing information
for i=1:imsize/xyres
zz(i)= length(find( imaind(:,:,:,i)>max_pix*0.1  ) );
end
rrimaind = find(zz >0);
% smoothing the intresting images
%for i= rrimaind
%    imatmp = conv2(imaind(:,:,1,i),kernel(2,'gaussian'),'same');
%    imaind(:,:,1,i) = imatmp;
%end
progbar(pb,90);
%
% set up the figure
%
PlotLeft =  scrsz(3)*3/8; PlotBottom =  scrsz(4)/4;
PlotHeight = scrsz(4)/2;
PlotBAspectRatio = [size(imaVOL,1)*pixsize(1) size(imaVOL,3)*pixsize(3) 1];
PlotWidth = PlotHeight*PlotBAspectRatio(1)/PlotBAspectRatio(3); 
titleout=['Sagittal Slices (L->R). Slice width = ',num2str(pixsize(1)*xyres),'mm. Scan ID: ',num2str(scaninfo.brn)];
figure('Position',[PlotLeft PlotBottom PlotWidth PlotHeight],'Name',titleout,'NumberTitle','off','renderer','opengl');
map=colormap(petcolormap);
hsagital = montage(imaind(:,:,:,rrimaind),map);
set(get(hsagital,'parent'),'Clim',[min_pix max_pix]);
set(hsagital,'CDataMapping','scaled');
set(gca,'position',[0 0 1 1]);
hc = colorbar; set(hc,'position',[0.86 0.2 0.1 0.6]); set(hc,'PlotBoxAspectRatio',[1 10 1]);
%disp(' ');
%disp('Reslicing Done!');
progbar(pb,100);
% delete th progress bar
close(pb);

% --------------------------------------------------------------------
