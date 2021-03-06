function s = spectral_inv(m)
%SPECTRAL Black-purple-blue-green-yellow-red-white color map.
%
%         map = spectral(num_colors)
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
%         Spectral version made by Gabriel Leger, MBIC, MNI (c) 1993

if nargin < 1, m = size(get(gcf,'colormap'),1); end

n = fix(3/8*m);

base = [
 1.0000    1.0000    1.0000    1.0000
    2.0000    0.9804    0.9804    0.9804
    3.0000    0.9412    0.9412    0.9412
    4.0000    0.2510         0    0.8784
    5.0000    0.1882         0    0.9412
    6.0000         0    0.3137    0.9412
    7.0000         0    0.6902    0.9412
    8.0000         0    0.9412    0.9412
    9.0000    0.0627    0.9412    0.9412
   10.0000    0.3137    0.9412    0.8784
   11.0000    0.3137    0.9412    0.3137
   12.0000    0.3765    0.9412         0
   13.0000    0.9412    0.9412         0
   14.0000    0.9412    0.9412    0.2510
   15.0000    0.9412    0.9098    0.2510
   16.0000    0.9412    0.6275         0
   17.0000    0.9412    0.1255         0
   18.0000    0.9412         0    0.4392
   19.0000    0.9412         0    0.6275
   20.0000    0.9412    0.7529    0.8784
   21.0000    0.9412    0.7529    0.8784
];

n = length(base);

X0 = linspace (1, n, m);

s = table(base,X0)';
