function res = get(dobj,var_s)
% GETV(dobj, var_s) Get a variable
%
% $Revision$  $Date$

% ----------------------------------------------------------------------------
% "THE BEER-WARE LICENSE" (Revision 42):
% <yuri@irfu.se> wrote this file.  As long as you retain this notice you
% can do whatever you want with this stuff. If we meet some day, and you think
% this stuff is worth it, you can buy me a beer in return.   Yuri Khotyaintsev
% ----------------------------------------------------------------------------

error(nargchk(nargin,2,2))

if ~ischar(var_s), error('VAR_S must be a stirng'), end
		
switch var_s
	case 'VariableAttributes'
		res = dobj.VariableAttributes;
	case 'GlobalAttributes'
		dobj.GlobalAttributes
	otherwise
		error(['cannot get : ' var_s])
end