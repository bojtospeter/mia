function par = blood_curve_par2(bloodfile,taskindex)
% function parameters = blood_curve_par(bloodfile,taskindex)
% This modul gets the fitted blood_curve parameters. The analytical 
% form of the fitted curve taken from D.Feng at al. Models for 
% computer simulation studies of ... ,Int J. biomed comput, 32(1993) 95-110 
%
%
% Inputs: 
%	bloodfile - 	filename of the measured blood curve (with path) 
%	taskindex -	0 or 1
%			1 : the modul will create a file including the 
%			parameteres. The filename: 'bloodfile'.par
%			0 : no file output  
% Outputs:	
%	parameters=[A1 A2 A3 lambda1 lambda2 lambda3 tau] and
%	a file named 'bloodfile'.par, if the taskindex = 1.
%		
%  
%	
% DOTE PET CENTER	
% Used own moduls: 	fitblood.m;	bloodcurve.m;	
% History:
% 30/07/1996 BL

global blood_as blood_ts bloodpar

%per_index=find(bloodfile == '/');
%rootend=per_index(length(per_index)-1);
%root=bloodfile(1:rootend);
%bloodpath=['./'];
per_index=find(bloodfile == '/');
if per_index ~= []
    rootend = per_index(length(per_index));
    root=bloodfile(1:rootend);
else
    rootend = 0;
    root = '';
end
bloodpath=root;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% loading the blood curve
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%blname=[bloodpath,bloodfile];
blname=bloodfile;
blname
eval(['load ',blname,';'])
strip_index=max(find(blname == '/'));
%blname=blname(strip_index+1:length(blname)-4);
blname =bloodfile(rootend+1:length(bloodfile)-4);
                    %-4:'.txt'
blood=[];
eval(['blood =',blname,';']);
blood_ts=blood(:,1);
blood_as=blood(:,2);
% set the activity = 0 at t= 0
blood_ts=[0,blood_ts']';
blood_as0=[0,blood_as']';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set the bloodcurve Y scale to 100. It is needed 
% for the parameter's initial values (p0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
max_blood_as=max(blood_as0);
blood_as=100/max_blood_as*blood_as0; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%start the the fitting of tissue curve for calculating k's
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('');
disp('start the fitting procedure ... ');
disp('');
tic; 

%p0=[1000 10 10 -1 -0.1 -0.01 0.5];
p0=[850 20 20 -4.1 -0.12 -0.01 0.1];
%p0=[A1 A2 A3 lambda1 lambda2 lambda3 tau]. The fitted curve taken from :
% D.Feng at al. Models for computer simulation studies of ... ,
% Int J. biomed comput, 32(1993) 95-110

 
options(1)=0;%display opt. output
options(2)=1e-4;%termination criteria for x
options(3)=1;% Termination criteria for f 
%options(4)=1e-4;% Termination criteria for g
%options(16)=1e-4;% Min perturb
%options(17)=0.1;%Max perturb
options(14)=2000;%max num. of step
vlb=[10, 1, 1, -5, -1, -0.1 0.1];
%vlb=[10, 1, 1, -10, -10, -0.1 0.001];
vub = [1000, 100, 100, -0.001, -0.001, -0.001 1];
%vub = [10000, 1000, 1000, -0.0001, -0.0001, -0.0001 1];
par=constr('fitblood',p0,options,vlb,vub); 

maxt=round(max(blood_ts))+1;
dt=maxt/500;
fine_ts=[0:dt:maxt]';



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% reset the Y scale, plot and save the results 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
par([1:3])=par([1:3])*max_blood_as/100;
bloodpar=par;

%plot results
figure;
clf;
maxt=round(max(blood_ts))+1;
Nof_dt=500;	% number of division on the fine time scale
dt=maxt/Nof_dt;
fine_ts=[0:dt:maxt]';
blood_fit_as=bloodcurve(fine_ts);

maxY=max(blood_fit_as);
maxX=maxt;

plot(fine_ts,blood_fit_as,'g-');
hold on;
plot(blood_ts,blood_as0,'rx');
title(['Input and fitted blood curves        /Patient code: '...
,blname, ' Printed:',date,' /']);
xlabel('time [min]');
ylabel('Cb(t) [nCi/ml]');
pause(4);

if taskindex == 1
	eval(['save ',bloodpath,blname,'.par',' par',' -ascii']);
end
