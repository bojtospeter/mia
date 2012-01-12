function appdata = sliceomaticsetdata(d)
% SLICEOMATICSETDATA(rawdata) - Create the data used for
% sliceomatic in the appdata D.
  
% Simplify the isonormals
  disp('Smoothing for IsoNormals...');
  d.smooth=smooth3(d.data);  % ,'box',5);
  d.reducenumbers=[floor(size(d.data,2)/20)...
                   floor(size(d.data,1)/20)...
                   floor(size(d.data,3)/20) ];
  d.reducenumbers(d.reducenumbers==0)=1;
  % Vol vis suite takes numbers in X/Y form.
  ly = 1:d.reducenumbers(1):size(d.data,2);
  lx = 1:d.reducenumbers(2):size(d.data,1);
  lz = 1:d.reducenumbers(3):size(d.data,3);

  d.reducelims={ ly lx lz };
  disp('Generating reduction volume...');
  d.reduce= reducevolume(d.data,d.reducenumbers);
  d.reducesmooth=smooth3(d.reduce,'box',5);
  
  appdata = d;