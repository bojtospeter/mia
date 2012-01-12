function pcolor_handle = drawecatpolarmap(ecatdatastruct)
% pcolor_handle = drawecatpolarmap(ecatdatastruct)
%

m = 15; % number of ring
n = 36; % number of sector/ring at the rings: 1:12
ecatdata = ecatdatastruct.vol{1};
hd = ecatdatastruct.hd{1};
%
% define the polarmapdata using the vector reading from the
% ecatvol. 
%
polmapdata = zeros(m,n);
% the sector number is 36 from 1. to 12. ring   
for i= 1: m-3;
     polmapdata(i,:) = ecatdata([(i-1)*36+1 : i*36]);
end
% the sector number is 18 at ring of 13 
i=i+1;
datatmp = ecatdata([12*36+1: 12*36 + 18]);
polmapdata(i,[1:2:35]) = datatmp;
polmapdata(i,[2:2:36]) = datatmp;
% the sector number is 9 at ring of 14 
i=i+1; 
datatmp = ecatdata([12*36 + 18 + 1 : 12*36 + 18 + 9]);
polmapdata(i,[1:4:33]) = datatmp;
polmapdata(i,[2:4:34]) = datatmp;
polmapdata(i,[3:4:35]) = datatmp;
polmapdata(i,[4:4:36]) = datatmp;

i=i+1; % the sector number is 1 at ring of 15 
datatmp = ecatdata(end);
polmapdata(i,:) = datatmp;
%scaling the sectors by the ecathdr scaling factor
polmapdatatmp = flipdim(polmapdata/max(polmapdata(:)),1);
%
% create the polarmap by the matlab pcolor function
%
pcolordata = zeros(m+1,n+1);
% the next 2 lines "rotate" the map to the desired position 
pcolordata(1:15,1:35) = polmapdatatmp(:,2:36);
pcolordata(1:15,36) = polmapdatatmp(:,1);
r = (0:m)'/(m);
theta = pi*linspace(1,-1,n+1);
Y = r*cos(theta);
X = r*sin(theta);
pcolor_handle = pcolor(X,Y,pcolordata);
shading flat;
axis equal tight off;
map = colormap('cardiac_cmap');
colorbar;
% create annotation text for heart position info.
annotation_text_h = annotation(...
  gcf,'textbox',...
  'Position',[0.01429 0.01667 0.2393 0.15],...
  'FitHeightToText','off',...
  'LineStyle','none',...
  'FontUnits','normalized',...
  'FontSize',0.03,...
  'String',{'        Anterior','Septal         Lateral','         Inferior'});

