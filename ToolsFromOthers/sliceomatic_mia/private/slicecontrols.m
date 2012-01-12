function slicecontrols(fig,onoff)
% Convert figure to contain controls for manipulating slices.

  d = getappdata(fig, 'sliceomatic');
  
  if onoff

    set(0,'currentfigure',fig);
    set([d.axx d.axy d.axz] ,'handlevisibility','on');
    
    set(fig,'currentaxes',d.axx);
    set(d.axx, 'xlim',[1 size(d.data,2)],...
               'ylim',[1 5]);
    set(d.pxx, 'vertices',[ 1 1 -1; size(d.data,2) 1 -1; size(d.data,2) 5 -1; 1 5 -1],...
               'faces',[ 1 2 3 ; 1 3 4]);
    title('X Slice Controller');
    
    set(fig,'currentaxes',d.axy);
    set(d.axy, 'xlim',[1 5],...
               'ylim',[1 size(d.data,1)]);
    set(d.pxy, 'vertices',[ 1 1 -1; 1 size(d.data,1) -1; 5 size(d.data,1) -1; 5 1 -1],...
               'faces',[ 1 2 3 ; 1 3 4]);
    title('Y Slice');

    set(fig,'currentaxes',d.axz);
    set(d.axz, 'xlim',[1 5],...
               'ylim',[1 size(d.data,3)]);
    set(d.pxz, 'vertices',[ 1 1 -1; 1 size(d.data,3) -1; 5 size(d.data,3) -1; 5 1 -1],...
               'faces',[ 1 2 3 ; 1 3 4]);
    title('Z Slice');

    set([d.axx d.axy d.axz] ,'handlevisibility','off');

  else
    
    % Disable these controls.  Perhaps hide all slices?
    
  end
                   
