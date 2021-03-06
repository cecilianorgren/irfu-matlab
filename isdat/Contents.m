% ISDAT Toolbox.
% Version 2.0 (R12.1) 31-March-2002
%
% Basic Database connectivity.
%   Mat_DbOpen	- Opens a connection to an ISDAT server.
%
% High-end Database connectivity (Lite family).
%   isGetContentLite - Get list of dataset contents on an ISDAT server.
%   isGetDataLite    - Get science data from ISDAT server.
%
% Utilities
%   toepoch	- Convert a [YYYY MM DD hh mm ss] time format to seconds since 1970.
%   fromepoch	- Convert seconds since 1970 to [YYYY MM DD hh mm dd] time format.
%   isPartionIntervals - Partition time intervals.
%   isAddISDATlogo     - Puts an ISDAT logo onto a plot.