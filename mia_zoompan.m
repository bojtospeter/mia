function mia_zoompan(action)
% mia_zoompan  Pan and zoom the current image 
% with left and right mouse button 
%
% Matlab library function for mia_gui utility. 
% University of Debrecen, PET Center/LB 2003

% Hints come from axdrag.m  (Ned Gulley, March 2003) and
% view3d.m (Torsten Vogel 09.04.1999 )

persistent x0 dx
global gVOIpixval

CurrentAxes = gVOIpixval.CurrentAxes;
CurrentImage = get(CurrentAxes,'children');
CurrentFigure = get(CurrentAxes,'parent');

switch action
    
case 'initialize'
    AxData.xLim = gVOIpixval.xLim;
    AxData.yLim = gVOIpixval.yLim;
    AxData.old_pt = 0;
    if  strcmp(get(CurrentFigure,'renderer'),'OpenGL')
        AxData.old_opengl = 1;
    else
         AxData.old_opengl = 0;
     end
    set(CurrentAxes,'UserData',AxData);
    set(CurrentImage,'ButtonDownFcn','mia_zoompan start');
    set(gcf,'DoubleBuffer','on');
    
case 'start'
    %set(gcf,'Units','pixel');
    set(CurrentAxes,'Units','pixel');
    set(CurrentFigure,'WindowButtonMotionFcn','mia_zoompan move');
    currentPoint = get(CurrentFigure,'CurrentPoint');
    x0 = currentPoint;
    mia_zoompan move;
	
case 'move'
    AxData = get(CurrentAxes,'UserData');
    if AxData.old_opengl == 1
        set(CurrentFigure,'renderer','painters');
    end
    mouseclick = get(CurrentFigure,'SelectionType');
    if strcmp(mouseclick,'extend') 
        % not used
    elseif strcmp(mouseclick,'alt') % pan mode
        currentPoint = get(CurrentFigure,'CurrentPoint');
        dx = currentPoint - x0;
        x0 = currentPoint;
        ap = get(CurrentAxes,'Position');
        xLim = get(CurrentAxes,'XLim');
        yLim = get(CurrentAxes,'YLim');
        set(CurrentAxes,'XLim',xLim-(diff(xLim)*dx(1)/ap(3)), ...
           'YLim',yLim+(diff(yLim)*dx(2)/ap(4)));
        set(CurrentFigure,'WindowButtonUpFcn','mia_zoompan zoompanoff');
    elseif strcmp(mouseclick,'normal')% zoom mode
        AxData.old_pt = get(0,'PointerLocation');
        set(CurrentAxes,'UserData',AxData);
        set(CurrentFigure,'WindowButtonMotionFcn','mia_zoompan zoom');
        set(CurrentFigure,'WindowButtonUpFcn','mia_zoompan zoompanoff');
    elseif strcmp(mouseclick,'open')% restore the original image     
        xLimNew = AxData.xLim;
        yLimNew = AxData.yLim;
        set(CurrentAxes,'XLim',xLimNew,'YLim',yLimNew);
        set(CurrentFigure,'WindowButtonUpFcn','mia_zoompan zoompanoff');
    end

case 'zoom'
        AxData = get(CurrentAxes,'UserData');
        old_pt = AxData.old_pt;
        new_pt = get(0,'PointerLocation');
        dy = (new_pt(2) - old_pt(2))/abs(old_pt(2))*5;
        zoomFactor = (1-dy);
        
        xLim=get(CurrentAxes,'XLim');
        yLim=get(CurrentAxes,'YLim');
     	xLimNew = [0 zoomFactor*diff(xLim)] + xLim(1) + (1-zoomFactor)*diff(xLim)/2;
        yLimNew = [0 zoomFactor*diff(yLim)] + yLim(1) + (1-zoomFactor)*diff(yLim)/2;	
		set(CurrentAxes,'XLim',xLimNew,'YLim',yLimNew)    
		
		AxData.old_pt  = new_pt;
		set(CurrentAxes,'UserData',AxData);
        
case 'zoompanoff'
    set(CurrentFigure,'WindowButtonMotionFcn','');
    set(CurrentFigure,'WindowButtonUpFcn','');
    AxData = get(CurrentAxes,'UserData');
    if  AxData.old_opengl;
            set(CurrentFigure,'renderer','opengl');
    end
        
case 'stop'
    set(CurrentFigure,'WindowButtonMotionFcn','');
    set(CurrentFigure,'WindowButtonUpFcn','');
    set(CurrentFigure,'WindowButtonDownFcn','');
    set(CurrentImage,'ButtonDownFcn','');
    %set(gcbf,'Units','normalized');
    set(CurrentAxes,'Units','normalized');        
   
end

   
