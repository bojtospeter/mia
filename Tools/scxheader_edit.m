function scxheader_edit(outfilename, context, slicemaxs);

%tmpfilename='/data/fdgdyn/animals/pet/PCNUSI______-WBFDG_____065428$W001.IMA';
%tmpfilename='PCNUSI______-WBFDG_____065428$W001.IMA';
%fclose(vaxpid);

num_of_slice = 15;
vaxfid = fopen(outfilename,'r+','vaxd');
fseek(vaxfid,305,-1);
fwrite(vaxfid,context,'char');%cntx

fseek(vaxfid,584,-1); %ignoring: next pos=579 for CAL1 for i=1:num_of_slice
fwrite(vaxfid,slicemaxs(1),'float32'); %mag i
fseek(vaxfid,584 + 103,-1); %CAL i and min i
for i=2:num_of_slice 
    fwrite(vaxfid,slicemaxs(i),'float32'); %mag i
    fseek(vaxfid,584+i*103,-1); %CAL i and min i
end
fclose(vaxfid);