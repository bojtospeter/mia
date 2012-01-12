function scaninfo = scxheader(tmpfilename);

%tmpfilename='/data/fdgdyn/animals/pet/PCNUSI______-WBFDG_____065428$W001.IMA';
%tmpfilename='PCNUSI______-WBFDG_____065428$W001.IMA';
%fclose(vaxpid);

num_of_slice = 15;
vaxpid = fopen(tmpfilename,'r','vaxd');
htmp = fread(vaxpid,28,'char');%ignoring
scaninfo.rid = strcat(char(fread(vaxpid,10,'char')))';%RID
scaninfo.rin = fread(vaxpid,1,'long'); %RIN
htmp = fread(vaxpid,26,'char');%ignoring
scaninfo.brn = fread(vaxpid,1,'long'); %brn
htmp = fread(vaxpid,44,'char');%ignoring
scaninfo.daty = fread(vaxpid,1,'int8'); %DATY
scaninfo.datm = fread(vaxpid,1,'int8'); %DATM
scaninfo.datd = fread(vaxpid,1,'int8'); %datd
scaninfo.timh = fread(vaxpid,1,'int8'); %timh
scaninfo.timm = fread(vaxpid,1,'int8'); %timm
scaninfo.tims = fread(vaxpid,1,'int8'); %tims
htmp = fread(vaxpid,27,'char');%ignoring
scaninfo.mtm = fread(vaxpid,1,'float'); %mtm
htmp = fread(vaxpid,4,'char');%ignoring
scaninfo.iso = strcat(char(fread(vaxpid,6,'char')))';%iso
if strcmp(scaninfo.iso,'F-18');% setting the iso.halftime [min]
    scaninfo.half = 109.8;
elseif strcmp(scaninfo.iso,'C-11');
    scaninfo.half = 20.3;
elseif strcmp(scaninfo.iso,'O-15');
    scaninfo.half = 2.03;   
end
htmp = fread(vaxpid,100,'char');%ignoring
scaninfo.trat = fread(vaxpid,1,'float'); %trat
htmp = fread(vaxpid,2,'char');%ignoring
imfm = fread(vaxpid,1,'int16');%imfm //fpos= 270
scaninfo.imfm = [imfm,imfm]; 
htmp = fread(vaxpid,34,'char');%ignoring //fpos= 306
scaninfo.cntx = strcat(char(fread(vaxpid,10,'char')))';%cntx
htmp = fread(vaxpid,579-316,'char');%ignoring: next pos=579 for CAL1
for i=1:num_of_slice
    scaninfo.cal(i) = fread(vaxpid,1,'float'); %CAL i
    scaninfo.min(i) = fread(vaxpid,1,'int16'); %min i
    scaninfo.mag(i) = fread(vaxpid,1,'float'); %mag i
    htmp = fread(vaxpid,93,'char');%ignoring
end
scaninfo.float = 0;
fclose(vaxpid);