function imgmontage(imain,TitleString)

PrintYes = 0;
NumOfSlice = 15; 
imaind = [];
for i=1:NumOfSlice
    imaind  = cat(4,imaind,fliplr(imain(:,:,i)));
end
figure;
map=colormap(spectral);
hm = montage(imaind,map);
set(hm,'CDataMapping','scaled');
set(gca,'position',[0 0 1 1]); 
hc = colorbar; set(hc,'position',[0.88 0 0.075 1]);
Title(TitleString);
pause(2);
if PrintYes
    printname = ['F:\tmp\',num2str(scaninfo(1).brn),'_GMR'];
    print( gcf, '-dbitmap', printname);
end