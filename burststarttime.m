function OUT=burststarttime(filename)

%BURSTSTARTTIME Check the starting time of the burst according to ISDAT
%
% 
% 
% 
%  
% By Anders Tjulin 13/8-2002

warning('caa:cleanup',...
'Function %s is deprecated and will be removed on May 1, 2004.\nUse %s instead',
...
mfilename,'c_efw_burst_st')

if nargin<1
  error "You need at least a filename"
end

% Get the data

fid = fopen(filename,'r','s');
data = fread(fid,10,'uint32');

time1=data(5);time2=data(6);
OUT=fromepoch(time1);
OUT(end)=OUT(end)+time2/1e9;

fclose(fid);
