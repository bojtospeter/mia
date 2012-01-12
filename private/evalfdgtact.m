function evalfdgtact(tactfile,glucose) 
% function res = evalfdgtact(tactfile,glucose,bloodfile) 
% 
% created 2002.02.21 by BL 
%
global  fine_ts blood_fas tissue_as tissue_ts ...
A  B dtime  tissue_fit  dtime_scale bloodpar bloodpath error2
		
LC=0.42
glucose = glucose*180/10;
bloodfile = [];
    % unit (mMol/l to mg/100g). The glucose Mol. weight: 180 g/mol.
%
%loading the tact curves to the actdata structure
%
actdata = loadtacts(tactfile);
num_of_tact = size(actdata,2)-1;
%	
% creating the tissue and fine time scales
%
tissue_ts = actdata(1).tact;
dtime=10/60;%[10 sec]
finesteps=round(max(tissue_ts)/dtime);
fine_ts=dtime*(0:1:finesteps-1)';
%    
%reading the blood parameter file
%	
if isempty(bloodfile)
   disp('The following tact name were found in the TACT file:');
   disp(' ');
   for i=1:num_of_tact
       disp(actdata(i+1).name);
   end
   disp(' ');
   bloodtact_index = input('Which is the TACT name referring to the blood TACT? ');
   bloodpar = eval_bloodcurve_par(actdata(1).tact,actdata(bloodtact_index+1).tact);
else
    blname=bloodfile;
	eval(['load ',blname,';']);
    if isunix 
        strip_index=max(find(blname == '/'));
    else
        strip_index=max(find(blname == '\'));
    end
	blname=blname(strip_index+1:length(blname)-4);
					%-4:'.par'
	eval(['bloodpar =',blname,';']);
    bloodtact_index = 0;
end
blood_fas=bloodcurve(fine_ts);
blood_delay=bloodpar(7);
tissue_ts = tissue_ts+blood_delay;
%
% FDG kinetic analysis loop
%
h1 = figure(1);
set(h1,'Position',[10 50 300 200]);
defrange = [1:size(actdata,2)];
looprange =  find( defrange > 1 & defrange ~= bloodtact_index + 1);
results=[];
disp('Starting the FDG Kinetic analysis...');
disp(' ');
for j = looprange
    tissue_as = actdata(j).tact;
    voiname = actdata(j).name;
    disp(['The name of TACT is under processing: ',voiname]); 
    tissue_fas=interp1(tissue_ts,tissue_as,fine_ts);
%
%start the fitting of tissue curve for calculating k's
%	
    t0 = clock; 
    k0=[0.102 0.13 0.062 0.0006 0.05];
	
    % making a guess for max k(5)
    maxblood=max(blood_fas);
    where_blood_max=find(blood_fas == maxblood);
    tmax=fine_ts(where_blood_max);
    tissue_at_tmax = max(tissue_as(find(tissue_ts <= tmax)));
    %tissue_at_tmax =max(tissue_as(1:3));
    %k5max = tissue_at_tmax/maxblood;
    k5max = tissue_fas(where_blood_max)/maxblood;
    k0(5)=k5max/2;
    k=k0;
    A=[	-(k(2)+k(3)) 	k(4) 		0
        k(3) 		-k(4) 		0
    	(1-k(5))	(1-k(5))	0];
    %		1		1		0];
    B=[ 	k(1)	0	k(5)]';
    % options for optimization
    options(1)=0;		% display opt. output
    options(2)=1e-6;	%termination criteria for x
	options(3)=1;		% Termination criteria for f 
	options(4)=1e-8;	% Termination criteria for g
	%	options(16)=5e-5;	% Min perturb
	%	options(17)=0.1;	% Max perturb
	options(14)=500;	% max num. of step
	
	%	vlb=[0.0, 0.000001, 0.000001, 0.0, 0.1]; 
	vlb=[0.0, 0.0001, 0.00001, 0.0, k5max]; 
		%in order to eliminate the k2 + k3 =0 value the minimums ...
		%are set to 0.0001. This is important for calculating g 
		%in the fitfdg.m, because the g=k(1)*k(3)/(k(2)+k(3))*glucose/LC;
					
	%       vub = [1, 2, 2, 1, k5max]
	vub = [1, 2, 1, 0.1, 1];
	%	vub = [2, 3, 20, 20, 2];
	
	[k,options]=constr('fitfdg3',k0,options,vlb,vub);
	K =  k(1)*k(3)/(k(2)+k(3));  
	LCGMR=K*glucose/LC;
	elapse_time=etime(clock,t0); 
	%	eredmeny=[LCGMR, k, elapse_time, error2];
	eredmeny = [LCGMR, k, options(8)];
	%
	%plot results
	%
    figure(1);
	clf;
	maxY=max(tissue_fas);
	maxX=max(tissue_fit);
	text1=['k1= ',num2str(k(1)),' k2= ',num2str(k(2)),' k3= ', ...
		num2str(k(3)),' k4= ',num2str(k(4)),' V0= ',... 
		num2str(k(5)),'  [1/min]'];
	text2=['LGMR= ',num2str(LCGMR),' mg/min/100g'];
	text3=['K= ',num2str(K),' 1/min'];
	plot(fine_ts,blood_fas,'r-');
	hold on
	plot(fine_ts,tissue_fit,'g-');
	plot(tissue_ts,tissue_as,'bo');
	%		axis([0 60 0 1800]);
	title(['Input and fitted tissue curves.   ' ...
			,'Patient code: ',...
			'  VOI name: ', voiname,'  Printed: ',date ]);
	xlabel('time [min]');
	ylabel('Activity concentration [nCi/ml]');
			%text(round(maxX/40),round(maxY*3/5),text1);
			%text(round(maxX/40),round(maxY*1/5),text2);
	pause(3);
	
	%save res56355 fine_ts blood_fas tissue_fit -ascii;
	%save ny46_2 tissue_ts tissue_as  -ascii ;
	
	hn(j) = figure;
    set(hn(j),'Position',[310 50 300 200]);
	maxY=max(tissue_fas);
	maxX=max(tissue_fit);
	text1=['k1= ',num2str(k(1)),' k2= ',num2str(k(2)),' k3= ', ...
		num2str(k(3)),' k4= ',num2str(k(4)),' k5= ',... 
		num2str(k(5)),'  [1/min]'];
	text2=['LGMR= ',num2str(LCGMR),' mg/min/100g'];
	hold on
	plot(fine_ts,tissue_fit,'g-');
	plot(tissue_ts,tissue_as,'bo');
	title(['Input and fitted tissue curves.   ' ...
		,'Patient code: ',...
		'  VOI name: ', voiname,'  Printed: ',date ]);
	xlabel('time [min]');
	ylabel('Activity concentration [nCi/ml]');
	text(round(maxX/1000),round(maxY*3/5),text1);
	text(round(maxX/1000),round(maxY*2/5),text2);
	text(round(maxX/1000),round(maxY*1/5),text3);
	pause(3);
    results = [results; eredmeny];    
end
%
% save the results
%
resfile  = [tactfile(1:length(tactfile)-5),'_res.txt']; 
if isempty(bloodfile)
    num_of_res = num_of_tact -1;
else
    num_of_res = num_of_tact;
end
fid = fopen( resfile, 'w+');
fprintf( fid, 'VOI    LGMR    K1   K2   K3   K4   K5  Error\n');
for i= 1: num_of_res
        fprintf( fid, '%s  ', actdata(i+1).name);
        fprintf( fid, '%f  ', results( i, :));
        fprintf( fid, '\n');
end
fclose(fid);
disp(' ');
disp(['The results can be found in: ',resfile]);

%		ans=input('Do you want to print the Figure?("y=1"/"n=0"):  ');
%		if ans == 1
%			print;
%		end










