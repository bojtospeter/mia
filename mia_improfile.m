function mia_improfile(action)
% mia_improfile
%
% Compute pixel-value cross-sections along line segments.
% Click left mouse button to start, and right button 
% to finish up a line segment
%
% Matlab library function for mia_gui utility. 
% University of Debrecen, PET Center/LB 2003

global gVOIpixval

CurrentAxes = gVOIpixval.CurrentAxes;
CurrentImage = get(CurrentAxes,'children');
CurrentFigure = get(CurrentAxes,'parent');
pixelsize = gVOIpixval.xypixsize(1);

switch action
    
case 'start'
    SetData = setptr('addpole'); set(CurrentFigure,SetData{:});
    set(CurrentImage,'ButtonDownFcn','mia_improfile initialize');
    AxData.x0 = 0;
	AxData.y0 = 0;
	AxData.line = [];
	set(CurrentAxes,'UserData',AxData);
    %get(CurrentFigure,'pointer')
    %get(CurrentFigure)
    
case 'initialize'
    AxData = get(CurrentAxes,'UserData');
    if ishandle(AxData.line)
        delete(AxData.line);
    end
    % Set the initial point (x0,y0)
	pt = get(CurrentAxes, 'CurrentPoint');
	AxData.x0 = pt(1,1);
	AxData.y0 = pt(1,2);
	AxData.line = line('Parent', CurrentAxes, ...
       'erasemode', 'xor', ...
       'color', [1 0 0], ...
       'Xdata', [AxData.x0 AxData.x0], ...
       'Ydata', [AxData.y0 AxData.y0],'LineWidth',2);
	set(CurrentAxes,'UserData',AxData);
    set(CurrentFigure,'WindowButtonMotionFcn','mia_improfile move');
    set(CurrentFigure,'WindowButtonUpFcn','mia_improfile moveoff');
    mia_improfile('move');
    drawnow;
    
case 'move'
    AxData = get(CurrentAxes,'UserData');
    pt = get(CurrentAxes, 'CurrentPoint');
	x = pt(1,1); y = pt(1,2);
    set(AxData.line, 'XData', [AxData.x0 x], 'YData', [AxData.y0 y]);
    
    % select the Image Profile figure window
    if isempty(findobj('name','Image Profile'))
        ScreenSize = get(0,'ScreenSize');
        Pos = [0.6*ScreenSize(3)    0.1*ScreenSize(4)    0.4*ScreenSize(3)    0.35*ScreenSize(4)];
        fh = figure('name','Image Profile','NumberTitle','off','Position',Pos,'doubleBuffer','on');
        
        % create buttons for FWHM and FWTM analysis by Gauss curve
        drawbutton_h = uicontrol('Style','pushbutton','String','FWHM Gauss', ...
            'units','normalized','Position',[0.8 0.94 0.2 0.05], 'Callback', 'mia_fwhmanalysis(''Gauss'')', ...
            'TooltipString','Calculate the FWHM and FWHT values by Gauss curve fitting');
         % create buttons for FWHM and FWTM analysis by NEMA
        drawbutton_h = uicontrol('Style','pushbutton','String','FWHM NEMA', ...
            'units','normalized','Position',[0.55 0.94 0.2 0.05], 'Callback', 'mia_fwhmanalysis(''NEMA'')', ...
            'TooltipString','Calculate the FWHM and FWHT values by NEMA protocol');
        %default plot
        lh = plot(0:10:200); set(lh,'Tag','Improfile_linecurve');hold on;
        lh2 = plot(0:10:200,'*'); set(lh2,'Tag','Improfile_pointcurve');hold off;
        xlabel('Distance along profile [mm]');ylabel('Pixel value');
    else
        fh = findobj('name','Image Profile');
        %delete the fitted curves if exists
        lfittedh = findobj(fh,'tag','FittedProfileGauss');
        if ishandle(lfittedh)
            delete(lfittedh);
            delete(findobj(fh,'tag','FittedProfileLine4'));
            delete(findobj(fh,'tag','FittedProfileLine7'));
            delete(findobj(fh,'tag','legend'));
            delete(findobj('tag','FittedCurveText'));
        end
        lfittedlh = findobj(fh,'tag','FittedProfileLine1');
        if ishandle(lfittedlh)
            delete(findobj(fh,'tag','FittedProfileLine1'));
            delete(findobj(fh,'tag','FittedProfileLine2'));
            delete(findobj(fh,'tag','FittedProfileLine3'));
            delete(findobj(fh,'tag','FittedProfileLine4'));
            delete(findobj(fh,'tag','FittedProfileLine5'));
            delete(findobj(fh,'tag','FittedProfileLine6'));
            delete(findobj(fh,'tag','FittedProfileLine7'));
            delete(findobj(fh,'tag','legend'));
            delete(findobj('tag','FittedCurveText'));
        end
	end
    %figure(fh);
    lh = findobj(fh,'Tag','Improfile_linecurve');%get the line handler
    lh2 = findobj(fh,'Tag','Improfile_pointcurve');%get the pointcurve handler
    %plot the profile
    if diff([AxData.x0 x]) ~= 0
        [cx,cy,c] = improfile(double(gVOIpixval.CurrentImage),[AxData.x0 x],[AxData.y0 y]);
        xalongprof = linspace(0,sqrt((cx(1)-cx(end))^2 + (cy(1)-cy(end))^2),length(c))';
        set(lh,'YData',c,'Xdata',pixelsize*xalongprof);
        set(lh2,'YData',c,'Xdata',pixelsize*xalongprof);
        drawnow;
    end
    figure(CurrentFigure);
    %mia_improfile('move');

case 'moveoff'
    set(CurrentFigure,'WindowButtonMotionFcn','');
    set(CurrentFigure,'WindowButtonUpFcn','');
    
case 'stop'
    AxData = get(CurrentAxes,'UserData');
    %if ishandle(AxData.line)
    if ~isempty(AxData)
        delete(AxData.line);
    end
    SetData=setptr('arrow');set(CurrentFigure,SetData{:}); 
    set(CurrentFigure,'WindowButtonMotionFcn','');
    set(CurrentFigure,'WindowButtonUpFcn','');
    set(get(CurrentAxes,'children'),'ButtonDownFcn','');
end
