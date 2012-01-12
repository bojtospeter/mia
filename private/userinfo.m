function status = userinfo;

miafullpath = which('mia.m');
[miapath, name, ext, versn] = fileparts(miafullpath);
inf_filename = [miapath,filesep,'private',filesep,'userinf.txt'];
fid = fopen(inf_filename,'a+');

if fid == -1;
    status = -2
    return;
end

fprintf( fid, '%s', datestr(now));
[status ,cname] = dos('set computername');
[status ,uname] = dos('set username');
fprintf( fid, '%s', '; ');
fprintf( fid, '%s', uname);
fprintf( fid, '%s', '; ');
fprintf( fid, '%s\n', cname);
fclose(fid);
