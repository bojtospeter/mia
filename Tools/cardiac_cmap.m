function s = cardiac_cmap(m)
%cardiac color map for "bulleyes" polarmap figures.
%
%         map = cardiac_cmap(num_colors)
%
% SPECTRAL(M) returns an M-by-3 matrix containing a "spectral" colormap.
% SPECTRAL, by itself, is the same length as the current colormap.
%
% For example, to reset the colormap of the current figure:
%
%           colormap(spectral)
%
% See also HSV, GRAY, PINK, HOT, COOL, BONE, COPPER, FLAG,
%          COLORMAP, RGBPLOT.

% $Id: spectral.m,v 1.4 1997/10/20 18:23:22 greg Rel $
% $Name: emma_v0_9_5 $

%         Copyright (c) 1984-92 by The MathWorks, Inc.
%         cardiac_cmap version made by LB UDEB, PET center 2005 

if nargin < 1, m = size(get(gcf,'colormap'),1); end

n = fix(3/8*m);

base = [
 1.0000         0         0         0
    2.0000    0.0690         0    0.0789
    3.0000    0.1381         0    0.1578
    4.0000    0.2071         0    0.2367
    5.0000    0.2761         0    0.3155
    6.0000    0.3409         0    0.3895
    7.0000    0.4014         0    0.4584
    8.0000    0.4430         0    0.5052
    9.0000    0.4721         0    0.5376
   10.0000    0.4888         0    0.5554
   11.0000    0.4986         0    0.5653
   12.0000    0.5085         0    0.5751
   13.0000    0.5183         0    0.5850
   14.0000    0.4966         0    0.5949
   15.0000    0.4590         0    0.6047
   16.0000    0.4056         0    0.6146
   17.0000    0.3340         0    0.6245
   18.0000    0.2588         0    0.6343
   19.0000    0.1800         0    0.6442
   20.0000    0.1127         0    0.6570
   21.0000    0.0593         0    0.6732
   22.0000    0.0197         0    0.6929
   23.0000    0.0066         0    0.7192
   24.0000         0         0    0.7471
   25.0000         0         0    0.7767
   26.0000         0    0.0038    0.8047
   27.0000         0    0.0153    0.8293
   28.0000         0    0.0353    0.8510
   29.0000         0    0.0510    0.8549
   30.0000         0    0.0627    0.8549
   31.0000         0    0.0784    0.8588
   32.0000         0    0.0902    0.8588
   33.0000         0    0.1059    0.8627
   34.0000         0    0.3294    0.8667
   35.0000         0    0.5529    0.8667
   36.0000         0    0.5882    0.8549
   37.0000         0    0.6149    0.8221
   38.0000         0    0.6332    0.7671
   39.0000         0    0.6571    0.6905
   40.0000         0    0.6663    0.6286
   41.0000         0    0.6667    0.5767
   42.0000         0    0.6573    0.4661
   43.0000         0    0.6268    0.2117
   44.0000         0    0.6284    0.0235
   45.0000         0    0.6919         0
   46.0000         0    0.7643         0
   47.0000         0    0.8367         0
   48.0000    0.0005    0.9089         0
   49.0000    0.0440    0.9734         0
   50.0000    0.3013    0.9989         0
   51.0000    0.6541    0.9951         0
   52.0000    0.8309    0.9674         0
   53.0000    0.9237    0.9234         0
   54.0000    0.9713    0.8566         0
   55.0000    0.9961    0.7729         0
   56.0000    1.0000    0.6595         0
   57.0000    1.0000    0.4635         0
   58.0000    0.9966    0.1690         0
   59.0000    0.9590    0.0126         0
   60.0000    0.8923         0         0
   61.0000    0.8423    0.0017    0.0017
   62.0000    0.8296    0.0898    0.0898
   63.0000    0.8943    0.4680    0.4680
   64.0000    1.0000    1.0000    1.0000
];

n = length(base);

X0 = linspace (1, n, m);

s = table(base,X0)';
