function exportAscii(var,vs,comment)
%exportAscii export variable into ascii file with comments
% exportAscii(var,var_name_s,comment)
% exportAscii(var,var_name_s)             % no additional comment
% exportAscii(var)                        % var_name_s is the same as the name of var
%
% Information written into the header of file is based on var_name_s string
% If comment is given it is added to the header
%
% File  {var_name_s}.dat is saved into current directory
%
% Example:
%	exportAscii(diE3p1234)
%	exportAscii(Etemp,'diE3p1234')
%	exportAscii(Etemp,'diE3p1234','electric field is high pass filtered at 3Hz')
%
% $Revision$  $Date$
%

% Copyright 2004 Yuri Khotyaintsev

if nargin<3, comment='';end
if nargin==1, vs=inputname(1); end
if nargin<1, help exportAscii;return; end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% P 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if regexp(vs,'^P[1-4]$')==1

	cl_id = vs(2);
	inst = 'EFW';
	sig = 'E';
	sen = '1234';
	frame = 'SC';
	var_labels = {['P' sen]};
 	var_units =  {'-V'};
	com = 'this signal is averaged from all probes available at the time';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% raw E p12 and p34
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif regexp(vs,'wE[1-4]p(12|34)')==1

	cl_id = vs(3);
	inst = 'EFW';
	sig = 'E';
	sen = vs(4:6);
	frame = 'SC';
	var_labels = {['E' sen]};
  var_units =  {'mV/m'};

	% remove averages
	cp = ClusterProc('./');
	var = corrADCOffset(cp,var);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% spin fits E p12 and p34
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif regexp(vs,'diEs[1-4]p(12|34)')==1

	cl_id = vs(5);
	inst = 'EFW';
	sig = 'E';
	sen = ['spin fits ' vs(6:8)];
	frame = 'DSI,  Ez==0 : not measured';
	var_labels = {'Ex','Ey','Ez'};
  var_units =  {'mV/m','mV/m','mV/m'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% despun full resolution E
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif regexp(vs,'diE[1-4]p1234')==1

	cl_id = vs(4);
	inst = 'EFW';
	sig = 'E';
	sen = vs(5:9);
	frame = 'DSI,  Ez==0 : not measured';
	var_labels = {'Ex','Ey','Ez'};
  var_units =  {'mV/m','mV/m','mV/m'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% despun full resolution E with assumption E.B = 0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif regexp(vs,'diE[1-4]')==1

	cl_id = vs(4);
	inst = 'EFW';
	sig = 'E';
	sen = 'p1234';
	frame = 'DSI,  approximately the same as GSE';
	var_labels = {'Ex','Ey','Ez','(B,spin)'};
  var_units =  {'mV/m','mV/m','mV/m','deg'};
  com = 'Ez is not measured but calculated from E.B=0\nEz is not reliable when magnetic field B is close to the spin plane\n%% The last column shows the angle of B with respect to the spin plane (B,spin)';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% full resolution E in GSE coordinates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif regexp(vs,'E[1-4]')==1

	cl_id = vs(2);
	inst = 'EFW';
	sig = 'E';
	sen = 'p1234';
	frame = 'GSE,  E along spin axis is not measured, but calculated from E.B=0';
	var_labels = {'Ex','Ey','Ez','(B,spin)'};
  var_units =  {'mV/m','mV/m','mV/m','deg'};
  com = 'Ez is not reliable when magnetic field B is close to the spin plane\n%% The last column shows the angle of B with respect to the spin plane (B,spin)';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% full resolution satellite potential and derived density
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif regexp(vs,'NVps[1-4]')==1

	cl_id = vs(5);
	inst = 'EFW';
	sig = 'P, probe to spacecraft potential';
	sen = 'p1234';
	frame = '';
	var_labels = {'NVps','Vps'};
  var_units =  {'cc','V'};
  com = 'probe to spacecraft potential Vps is approximately \n%% the same as satellite potential with respect to plasma.\n%% density NVps is derived from Vps based on empirical fit \n%% It is NOT true density';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% phase
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif regexp(vs,'A[1-4]')

	cl_id = vs(2);
	inst = 'ephemeris';
	sig = 'phase';
	sen = '';
	frame = 'SC';
	var_labels = {'phase'};
  var_units =  {'deg'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% dump without headers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif regexp(vs,'dump')

  fid = fopen([inputname(1) '.dat'],'w');
  for j=1:size(var,1),
    if var(j,1)>5e8 % assume first column time in isdat epoch
      d=sprintf('%4.0f %2.0f %2.0f %2.0f %2.0f %7.4f ',fromepoch(var(j,1)));
      fprintf(fid,[d num2str(var(j,2:end)) '\n']);
    else
      fprintf(fid,[num2str(var(j,1:end)) '\n']);
    end
  end
  fclose(fid);
  return
else
	warning('Wariable name not recognized, will do nothing.')
	return
end

t0=toepoch(fromepoch(var(1,1)).*[1 1 1 0 0 0]);
t0_s=datestr(datenum(fromepoch(t0)),0);
var(:,1) = var(:,1) - t0;

%t0_s = datestr(datenum(fromepoch(var(1,1))));
%var(:,1) = var(:,1) - var(1,1);

sz = size(var);
n_data = sz(2) - 1; % number of data columns - time
var_s =    'time       ';
var_unit = '[s]        ';
mask = '%10.4f ';

if		strcmp(sig,'E'),		units = 'mV/m';
elseif	strcmp(sig,'phase'),	units = 'deg';
else,	units = 'undef';
end

for i=1:n_data
	var_length_nine=strvcat(var_labels{i},'         ');
	var_unit_length_nine=strvcat(['[' var_units{i} ']'],'         ');
  var_s = [var_s var_length_nine(1,:) ];
	var_unit = [var_unit var_unit_length_nine(1,:)];
	mask = [mask '%8.3f '];
end

fid = fopen([vs '.dat'],'w');
fprintf(fid,['%% this file was created on ' date ' \n%%\n']);
fprintf(fid,['%% SC:        Cluster ' cl_id ' \n']);
fprintf(fid,['%% Intrument: ' inst ' \n']);
fprintf(fid,['%% Signal:    ' sig ' \n']);
fprintf(fid,['%% Sensor:    ' sen ' \n']);
fprintf(fid,['%% Coord Sys: ' frame ' \n%%\n']);
fprintf(fid,['%% comment:   ' com ' \n%%\n']);
if comment,
  comm=tokenize(comment,'\n');
  for j=1:size(comm,2),
    fprintf(fid,['%%   ' comm{1,j} ' \n']);
  end
end
fprintf(fid,['%% Time from: ' t0_s ' \n%%\n']);
fprintf(fid,['%% ' var_s ' \n']);
fprintf(fid,['%% ' var_unit ' \n']);
fprintf(fid,[mask '\n'],var');
fclose(fid);

