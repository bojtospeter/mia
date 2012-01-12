function mia_fwhmanalysis(type_string)


fh = findobj('name','Image Profile');
%delete the fitted curve if exists
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

%get the line handler
lh = findobj(fh,'Tag','Improfile_linecurve');%get the line handler
YData = get(lh,'YData');
XData = get(lh,'XData');

if strcmp(type_string,'Gauss') 
    s = fitoptions('Method','NonlinearLeastSquares',...
                   'Lower',[0,0,0],...
                   'Upper',[2*max(YData),max(XData),max(XData)],...
                   'Startpoint',[max(YData),mean(XData), mean(XData)]);
    f = fittype('a*exp(-((x-b)/c)^2)','options',s);

    SetData=setptr('watch');set(fh,SetData{:});
    [fitres, gof2] = fit(XData',YData',f);
    SetData=setptr('arrow');set(fh,SetData{:});

    figure(fh);
    hold on;
    lfittedh = plot(fitres);
    xlabel('Distance along profile [mm]');ylabel('Pixel value');
    set(lfittedh,'tag','FittedProfileGauss');

    fittedpars = coeffvalues(fitres);
    coeffofvar = fittedpars(3);
    FWHM = 2* coeffofvar*sqrt(log(2));
    FWTM = 2* coeffofvar*sqrt(log(10));
    x1=fittedpars(2)-coeffofvar*sqrt(log(2));x2=x1+FWHM;
    lfittedl4h = plot([x1,x2],[fittedpars(1)/2 fittedpars(1)/2],'g');
    set(lfittedl4h,'tag','FittedProfileLine4');
    x1=fittedpars(2)-coeffofvar*sqrt(log(10));x2=x1+FWTM;
    lfittedl7h = plot([x1,x2],[fittedpars(1)/10 fittedpars(1)/10],'c');
    set(lfittedl7h,'tag','FittedProfileLine7');
    
elseif strcmp(type_string,'NEMA')
    % FWHM end FWTM calculation according to the NEMA protocoll. See the
    % details in the "NEMA Standards Publication NU 1-2001.
    % Performance Measurements of Scintillation Cameras" documentation,
    % section of 2.1.4.
    
    % find the max Y value by parabolic fitting
    figure(fh);
    maxYpos = find(max(YData)==YData);
    fitrange=[maxYpos-1,maxYpos,maxYpos+1];
    pp = polyfit(XData(fitrange),YData(fitrange),2);
    maxY = polyval(pp,-pp(2)/(2*pp(1)));
    hold on;
    Ypar = polyval(pp,XData); posrange=find(Ypar>maxY/2);
    x1=XData(posrange(1)); x2=2*(-pp(2)/(2*pp(1))-x1)+x1; xx=[x1:(x2-x1)/100:x2];
    lfittedl1h = plot(xx,polyval(pp,xx),'r');
    set(lfittedl1h,'tag','FittedProfileLine1');
    %FWHM determination
    % find the nearest two neighboring points of the half peak value
    nopeak=0;
    for i=1:length(YData)
        if maxYpos-i < 1; nopeak = 1; break;end
        if YData(maxYpos-i) < maxY/2
            xpos1lower = maxYpos-i;
            xpos1higher = maxYpos-i+1;
            break;
        end
    end
    for i=1:length(YData)
        if maxYpos+i > length(YData); nopeak = 1; break;end
        if YData(maxYpos+i) < maxY/2
            xpos2higher = maxYpos+i;
            xpos2lower = maxYpos+i-1;
            break;
        end
    end
    if(~nopeak)
        %linear interpolation between the adjacents points
        fr1 =[xpos1lower xpos1higher];
        fr2 = [xpos2lower xpos2higher];
        linep1 = polyfit(XData(fr1),YData(fr1),1);
        linep2 = polyfit(XData(fr2),YData(fr2),1);
        lfittedl2h = plot(XData(fr1),polyval(linep1,XData(fr1)),'g');
        lfittedl3h = plot(XData(fr2),polyval(linep2,XData(fr2)),'g');
        set(lfittedl2h,'tag','FittedProfileLine2');
        set(lfittedl3h,'tag','FittedProfileLine3');
        x2 = (maxY/2-linep2(2))/linep2(1); x1= (maxY/2-linep1(2))/linep1(1);
        FWHM = x2-x1;
        lfittedl4h = plot([x1,x2],[maxY/2 maxY/2],'g');
        set(lfittedl4h,'tag','FittedProfileLine4');
    else
        FWHM = NaN;
    end
    %FWTM determination
    % find the nearest two neighboring points of the half peak value 
    nopeak = 0;
    for i=1:length(YData)
        if maxYpos-i < 1; nopeak = 1; break;end
        if YData(maxYpos-i) < maxY/10
            xpos1lower = maxYpos-i;
            xpos1higher = maxYpos-i+1;
            break;
        end
    end
    for i=1:length(YData)
        if maxYpos+i > length(YData); nopeak = 1; break;end
        if YData(maxYpos+i) < maxY/10
            xpos2higher = maxYpos+i;
            xpos2lower = maxYpos+i-1;
            break;
        end
    end
    if(~nopeak)
        %linear interpolation between the adjacents points
        fr1 =[xpos1lower xpos1higher];
        fr2 = [xpos2lower xpos2higher];
        linep1= polyfit(XData(fr1),YData(fr1),1);
        linep2= polyfit(XData(fr2),YData(fr2),1);
        lfittedl5h = plot(XData(fr1),polyval(linep1,XData(fr1)),'c');
        lfittedl6h = plot(XData(fr2),polyval(linep2,XData(fr2)),'c');
        set(lfittedl5h,'tag','FittedProfileLine5');
        set(lfittedl6h,'tag','FittedProfileLine6');
        x2 = (maxY/10-linep2(2))/linep2(1); x1= (maxY/10-linep1(2))/linep1(1);
        FWTM = x2-x1;
        lfittedl7h = plot([x1,x2],[maxY/10 maxY/10],'c');
        set(lfittedl7h,'tag','FittedProfileLine7');
    else
        FWTM = NaN;
    end
end

texth = text(round(max(XData)*0.05),round(max(YData)*0.9), ...
    {['FWHM = ',num2str(FWHM,2),' mm'],['FWTM = ',num2str(FWTM,2),' mm']});
set(texth,'tag','FittedCurveText');

hold off;


