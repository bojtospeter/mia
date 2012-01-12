function mia_rectdrag(RectangleHandler)

global gVOIpixval

ImaHandler = findobj('Tag','MainImage');
CurrentImage = gVOIpixval.CurrentImage;

drp = get(RectangleHandler,'position');
dry = round(drp(1)):round(drp(1)) + round(drp(3)-1);
drx = round(drp(2)):round(drp(2)) + round(drp(4)-1);

drih = findobj('tag','DetailRectangleImg');
ImgUdata = get(drih,'userdata');
%
% without the next IF segment during the first pass
% the figure will not refresh correctly later. (!?) 
%
if ImgUdata.isfirstrun
    AxHandler = findobj('tag','DetailRectangleAx');
    axes(AxHandler);
    cimg = CurrentImage(drx,dry);
    if ImgUdata.isintep
        cimgout = interp2(double(cimg), ImgUdata.new_ypixvect, ImgUdata.new_xpixvect','linear');
    else
        cimgout = cimg;
    end
    drih = imagesc(cimgout,[ImgUdata.minpix ImgUdata.maxpix]);
    axis image;
    set(drih,'tag','DetailRectangleImg');
    set(drih,'EraseMode','none');
    ImgUdata.isfirstrun = 0;
    set(drih,'userdata',ImgUdata);
    axis off;
    axes(get(ImaHandler,'parent'));
end
cimg = CurrentImage(drx,dry);

if ImgUdata.isintep
    cimgout = interp2(double(cimg), ImgUdata.new_ypixvect, ImgUdata.new_xpixvect','linear');
else
    cimgout = cimg;
end
set(drih,'CData',cimgout);