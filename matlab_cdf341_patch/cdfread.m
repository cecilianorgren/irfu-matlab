function [out, info] = cdfread(filename, varargin)
%CDFREAD Read the data from a CDF file.
%   DATA = CDFREAD(FILE) reads all of the variables from each record of
%   FILE.  DATA is a cell array, where each row is a record and each
%   column a variable.  Every piece of data from the CDF file is read and
%   returned. 
% 
%   Note:  When working with large data files, use of the
%   'CombineRecords' option can significantly improve performance.
%
%   DATA = CDFREAD(FILE, 'Records', RECNUMS, ...) reads particular
%   records from a CDF file.  RECNUMS is a vector of one or more
%   zero-based record numbers to read.  DATA is a cell array with
%   length(RECNUM) number of rows.  There are as many columns as
%   variables.
% 
%   DATA = CDFREAD(FILE, 'Variables', VARNAMES, ...) reads the variables
%   in the cell array VARNAMES from a CDF file.  DATA is a cell array
%   with length(VARNAMES) number of columns.  There is a row for each
%   record requested.
% 
%   DATA = CDFREAD(FILE, 'Slices', DIMENSIONVALUES, ...) reads specified
%   values from one variable in the CDF file.  The matrix DIMENSIONVALUES
%   is an m-by-3 array of "start", "interval", and "count" values.  The
%   "start" values are zero-based.
%
%   The number of rows in DIMENSIONVALUES must be less than or equal to
%   the number dimensions of the variable.  Unspecified rows are filled
%   with the values [0 1 N] to read every value from those dimensions.
% 
%   When using the 'Slices' parameter, only one variable can be read at a
%   time, so the 'Variables' parameter must be used.
% 
%   DATA = CDFREAD(FILE, 'CombineRecords', TF, ...) combines all of the
%   records into a cell array with only one row (1-by-N) if TF is true.
%   Because variables in CDF files can contain non-scalar data, the default
%   value (false) causes the data to be read into an M-by-N cell array,
%   where M is the maximum number of record among the variables and N is the 
%   number of variables requested. For CDF_EPOCH and CDF_TIME_TT2000 data,
%   its time is automatically converted into MATLAB's datenum. (To overwrite
%   the conversion, use 'KeepEpochAsIs' option.) However, for
%   CDF_EPOCH16 data, it still returns the default form, time in UTC string.
%   (Use the 'ConvertEpochToDatenum' option to return MATLAB datenum.)
%   Specifying the 'CombineRecords' parameter with a true value of TF can
%   greatly improve the speed of importing large CDF datasets and reduce
%   the size of the MATLAB cell array containing the data.
%
%   When TF is true, all records for each variable are combined into one
%   cell in the output cell array.  The data of scalar variables is
%   imported into a column array.  Importing non-scalar and string data
%   extends the dimensionality of the imported variable.  For example,
%   importing 1000 records of a 1-byte variable with dimensions 20-by-30
%   yields a cell containing a 20-by-30-by-1000 UINT8 array. For data
%   from non-record variant variables, as their values never change from 
%   record to record, a single record is returned. 
%
%   When using the 'Variables' parameter to read one variable, if the
%   'CombineRecords' parameter is true, the result is an M-by-N numeric
%   or character array; the data is not put into a cell array. 
%
%   DATA = CDFREAD(FILE, 'ConvertEpochToDatenum', TF, ...) converts CDF 
%   epoch data values to MATLAB datenum if TF is true. Normally, it is used 
%   with the parameter 'CombineRecords' to return an array. If not, a N-by-1
%   cell is returned. If TF is false (the default), CDF_EPOCH data type values
%   are wrapped in CDFEPOCH objects and CDF_TIME_TT2000 in CDFTT2000 objects,
%   which can hurt performance for large datasetsr. For CDF_EPOCH16 data type,
%   time in picoseconds, and CDF_TIME_TT2000, time in nanoseconds with leap
%   seconds, this option  will cause the loss of the high time resolution and
%   not properly present the time at a leap second time.
%
%   DATA = CDFREAD(FILE, 'ConvertEpochToDatestr', TF, ...) converts CDF
%   epoch data values to MATLAB datestr if TF is true. This option is
%   similar to 'ConvertEpochToDatenum', with each CDF epoch returning as the 
%   form: dd-mmm-yyyy hh:mm:ss (all sub-milliseconds info is not displayed).
%   To display sub-milliseconds, use the 'CDFEpochToString' option.
%
%   DATA = CDFREAD(FILE, 'KeepEpochAsIs', TF, ...) whether to keep CDF 
%   Epoch data values as is.  If TF is set as true, no data conversion
%   from CDF epoch to MATLAB datenum is performed. The data values can
%   be written back to CDF later again without MATLAB datenum to CDF epoch
%   conversion. The data will be kept as doubles for CDF_EPOCH data, array
%   of doubles for CDF_EPOCH16 data, or INT64 (mxINT64_CLASS) for
%   CDF_TIME_TT2000..
%
%   DATA = CDFREAD(FILE, 'CDFEpochToString', TF, ...) whether to return 
%   CDF Epoch data values in strings, instead of numeric values. If TF
%   is set to true, each epoch data will be presented in the form of
%   dd-mon-yyyy hh:mm:ss.mmm for CDF_EPOCH data type, or
%   dd-mon-yyyy hh:mm:ss.mmm:uuu:nnn:ppp for CDF_EPOCH16 data type.
%
%   DATASTRUCT = CDFREAD(FILE, 'Structure', TF, ...) returns a structure
%   array (instead of a cell array) that contains the following
%   fields for each member (a variable) in the array if TF is true:
%       VariableName - variable name
%       Data - variable data in M-by-1 cell array without 'CombineRecords'
%              option, or a multi-dimensional array with 'CombineRecords'
%       Attributes - a structure that contains all the attributes that
%                    associated with this variable
%
%   [DATA, INFO] = CDFREAD(FILE, ...) also returns details about the CDF
%   file in the INFO structure.
%
%   Notes:
%
%     CDFREAD creates temporary files when accessing CDF files.  The
%     current working directory must be writable.
%
%     To maximize performance, specify true to the 'CombineRecords' and
%     'ConvertEpochToDatenum', 'ConvertEpochToDatestr', 'KeepEpochAsIs'
%     or 'CDFEpochToString' parameters.
%
%     It is currently not possible to provide a set of records to read
%     (using the 'Records' parameter) and to combine records (using the
%     'CombineRecords' parameter).
%
%     'ConvertEpochToDatenum', 'ConvertEpochToDatestr', 'KeepEpochAsIs' 
%     and 'CDFEpochToString' are mutually exclusive.
%
%     CDF_EPOCH16 data type currently is converted to its UTC string if
%     not specified with 'KeepEpochAsIs' option. Either use 
%     'ConvertEpochToDatenum' option, or use 
%     epoch16todatenum script once the strings are returned, to convert the
%     data/time to MATLAB's datenum.
%
%   Examples:
%
%   % Read all of the data from the file, example.cdf, the inefficient way.
%
%   data = cdfread('example');
%
%   % Read all of the data from the same file, the most efficient way.
%
%   data = cdfread('example', 'CombineRecords', true);
%
%   % Read the same file as above and also return any CDF EPOCH or EPOCH16
%     variable data in the string form (dd-mon-yyyy hh:mm:ss.mmm for EPOCH or 
%     dd-mon-yyyy hh:mm:ss.mmm.uuu.nnn.ppp for EPOCH16) if they exist.
%
%   data = cdfread('example', 'CombineRecords', true, ...
%                             'CDFEpochtoString', true);
%
%   % Read just the data from variable "Time".
%
%   data = cdfread('example', ...
%                  'Variable', {'Time'});
%
%   % Read the first value in the first dimension, the second value in
%   % the second dimension, the first and third values in the third
%   % dimension, and all of the values in the remaining dimension of
%   % the variable "multidimensional".  
%
%   data = cdfread('example', ...
%                  'Variable', {'multidimensional'}, ...
%                  'Slices', [0 1 1; 1 1 1; 0 2 2]);
%
%   % The example above is analogous to reading the whole variable 
%   % into a variable called "data" and then using matrix indexing, 
%   % as follows:
%
%   data = cdfread('example', ...
%                  'Variable', {'multidimensional'});
%   data{1}(1, 2, [1 3], :)
%
%   % Collapse the records from a dataset and convert CDF epoch data type
%   % to MATLAB datenums.
%
%   data = cdfread('example', ...
%                  'CombineRecords', true, ...
%                  'ConvertEpochtoDatenum', true);
%
%   % Displays the name of the variable being processed.
%
%   data = cdfread('example', 'ShowProgress', true);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also CDFEPOCH, CDFTT2000, CDFINFO, CDFWRITE, CDFUPDATE.

%   Copyright 1984-2009 The MathWorks, Inc.

% HISTORY:
%   November 13, 2007  David Han    The following changes have been made to
%                                   cdfreadc.c:
%                                     - Added a logic to read CDF_EPOCH and 
%                                       CDF_EPOCH16 data.
%                                     - Modified to return variable attributes
%                                       besides the variable data.
%                                     - Modified to read all the records in one 
%                                       read by default.
%
%                                   Removed the cdfepoch routine since it 
%                                      1) doesn't work with some CDF files
%                                      2) is no longer needed with the new
%                                          cdfreadc.c 
%
%                                   No longer calls the find_records function
%                                   (since all the variable data records are
%                                   read in one read by default).
%                                     
%                                   cdfread.m now returns a structure (instead
%                                   of just variable data) that contains the
%                                   following fields for each variable:
%
%                                       VariableName - variable name
%                                       Data - variable data
%                                       Attributes - a structure that contains
%                                                    all the attributes that 
%                                                    associated with this
%                                                    variable
%
%                                   Added the 'ShowProgress' option that 
%                                   displays the name of the variable being
%                                   processed.  This option can be useful if
%                                   a CDF file contains a lot of variables or
%                                   takes a long time to read all the 
%                                   variables.
%
%                     Mike Liu      Addendum... For the backward compatibility:
%                                      1) cdfepoch object is still supported, 
%                                         but it can't handle CDF_EPOCH16 data
%                                      2) data returned as a structure is now 
%                                         an option 
%
%   October 20, 2008  Mike Liu      The following change has been made to
%                                   cdfreadc.c:
%                                     - Handled combining 'CombineRecords' and 
%                                       'ConvertEpochToDatenum' options 
%   February 4, 2009  Mike Liu      Added a dummy call to cdfreadc after normal
%                                   calls. Previously, each cdfreadc call
%                                   involves open/close the CDF file while 
%                                   reading a variable's data. Now, only the
%                                   first cdfreadc call opens the file,
%                                   but it does not close the file anymore.
%                                   Instead, the dummy cdfreadc call 
%                                   closes the file after all cdfreadc
%                                   calls are done. 
%
%   February 23, 2009  Mike Liu     Added 'KeepEpochAsIs' option to keep
%                                   CDF epoch values in MATLAB. Added 
%                                   'ConvertEpochToDatestr' option. Not call 
%                                   convert_epoch anymore as CDF epoch values
%                                   to MATLAB datenum conversion is done in 
%                                   cdfreadc (much faster) and it calls 
%                                   cdfepoch directly if needed.
%   September 9, 2011  Mike Liu     Changed to return UTC strings for
%                                   CDF_EPOCH16 as the default. Use 
%                                   epoch16todatenum to convert the strings
%                                   to MATLAB's datenum if
%                                   'ConvertEpochToDatenum' option is specified.
%   March 5, 2013  Mike Liu         Changed to 'KeepEpochAsIs' option to allow
%                                   returning CDF_EPOCH16 data into array of
%                                   doubles, instead of string.
%

%
% Process arguments.
%

if (nargin < 1)
    error('MATLAB:cdfread:inputArgumentCount', ...
          'CDFREAD requires at least one input argument.')
end

if (nargout > 2)
    error('MATLAB:cdfread:outputArguments', ...
          'CDFREAD requires two or fewer output argument.')
end

[args, msg, structure, show_progress] = parse_inputs(varargin{:});

if (~isempty(msg))
    error('MATLAB:cdfread:badInputArguments', '%s', msg)
end

validate_inputs(args);

%
% Verify existence of filename.
%

% Get full filename.
fid = fopen(filename);

if (fid == -1)
  
    % Look for filename with extensions.
    fid = fopen([filename '.cdf']);
    
    if (fid == -1)
        fid = fopen([filename '.CDF']);
    end
    
end

if (fid == -1)
    error('MATLAB:cdfread:fileOpen', 'Couldn''t open file (%s).', filename)
else
    filename = fopen(fid);
    fclose(fid);
end

% CDFlib's OPEN_ routine is flakey when the extension ".cdf" is used.
% Strip the extension from the file before calling the MEX-file.

if ((length(filename) > 4) && (isequal(lower(filename((end-3):end)), '.cdf')))
    filename((end-3):end) = '';
end

%
% Get information about the variables.
%

info = cdfinfo(filename);

if (isempty(args.Variables))
    args.Variables = info.Variables(:, 1)';
end

% To make indexing info.Variables easier, reorder it to match the values in
% args.Variables and remove unused values. Deblank variable list because
% the intersection is based on the predicate of equality of strings.
% Inconsistent trailing blanks in variable names from args and info may cause
% inadvertent mismatch and consequent failure.
[int, idx1, idx2] = intersect(deblank(args.Variables), ...
                              deblank(info.Variables(:, 1)));

if (length(int) < length(args.Variables))
    
    % Determine which requested variables do not exist in the CDF.
    invalid = setdiff(args.Variables, int);
    
    msg = 'The following requested variables are not in this CDF:';
    msg = [msg sprintf('\n\t%s',invalid{:})];
    
    error('MATLAB:cdfread:variableNotFound', '%s', msg)
    
end

% Remove unused variables.
info.Variables = info.Variables(idx2, :);

% Reorder the variables to match the order of args.Variables.
[tmp, reorder_idx] = sort(idx1);
info.Variables = info.Variables(reorder_idx, :);

if (~structure) 
  if (isempty(args.Records))
    args.Records = find_records(info.Variables);
  elseif (any(args.Records < 0))
    error('MATLAB:cdfread:recordNumber', 'Record values must be nonnegative.')
  end
end

%
% Read each variable.
%

if (length(args.Variables) == 1)

    % Special case for single variable.
    if (info.Variables{3} == 0)
      out = [];
      return;
    end
    if (isequal(lower(info.Variables{4}), 'epoch16') && ...
        (~args.CDFEpochToString && ~args.ConvertEpochToDatestr && ...
         ~args.ConvertEpochToDatenum && ~args.KeepEpochAsIs))
      error('MATLAB:cdfread:Epoch16', ...
            'Variable "%s", a CDF_EPOCH16, is retrieved into UTC-string.\nUse epoch16todatenum to convert to MATLAB datenum at index %d', ...
            info.Variables{1}); 
    end
    if (~isempty(args.Slices))
        [args.Slices, msg] = parse_slice_vals(args.Slices, info.Variables);
        if (~isempty(msg))
            error('MATLAB:cdfread:sliceValue', '%s', msg)
        end
    else
        args.Slices = fill_slice_vals([], info.Variables);
    end
    [data, attrs] = cdfreadc(filename, args.Variables{1}, args.Records, ...
                             args.Slices, args.CombineRecords, ...
                             args.ConvertEpochToDatenum, structure, ...
                             args.KeepEpochAsIs, args.CDFEpochToString, ...
                             args.ConvertEpochToDatestr);
    [dataX, dummy] = cdfreadc('to_close', args.Variables{1}, args.Records, ...
                              args.Slices, args.CombineRecords, ...
                              args.ConvertEpochToDatenum, false, ...
                              args.KeepEpochAsIs, args.CDFEpochToString, ...
                              args.ConvertEpochToDatestr);

    if (~structure)
      if (isequal(lower(info.Variables{4}), 'tt2000'))
        if (args.CombineRecords || args.ConvertEpochToDatenum)
          out = data;
        else
          if (length(data) > 1)
            for p = 1:length(data)
              if (length(data{p}) > 1)
                for q = 1:length(data{p})
                  databb(q) = cdftt2000(data{p}(q,1));
                end
                dataaa{p,1} = databb;
              else
                dataaa(p,1) = cdftt2000(data{p});
              end
            end
            out = dataaa;
          else
            out = cdfepoch(data);
          end
        end
      elseif (isequal(lower(info.Variables{4}), 'epoch'))
        if (args.ConvertEpochToDatenum || args.CDFEpochToString || ...
            args.KeepEpochAsIs || args.ConvertEpochToDatestr || ...
            args.CombineRecords)
          out = data;
        else
          if (~args.ConvertEpochToDatenum)
            %
            % None option - set up for cdfepoch object
            %
            if (length(data) > 1)
              for p = 1:length(data)
                if (length(data{p}) > 1)
                  for q = 1:length(data{p})
                    databb(q) = cdfepoch(data{p}(q,1));
                  end
                  dataaa{p,1} = databb;
                else
                  dataaa(p,1) = cdfepoch(data{p});
                end
              end
              out = dataaa;
            else
              out = cdfepoch(data);
            end
          else
            out = data;
          end
        end
      elseif (isequal(lower(info.Variables{4}), 'epoch16') && ...
              args.ConvertEpochToDatenum)
          ss = size (data);
          for q=1:ss(1)
            datax(q,1) = epoch16todatenum(data{q,1});
          end
          out = datax;
      else
        out = data;
      end
    else
      out.VariableName = args.Variables{1};
      out.Data = data;
      out.Attributes = attrs;
    end

elseif ((~isempty(args.Slices)) && (length(args.Variables) ~= 1))

    error('MATLAB:cdfread:sliceValue', 'Specifying variable slices requires just one variable.')

else
  if (structure)
    % Regular reading.
    out1 = cell(length(args.Variables),3);
    for p = 1:length(args.Variables)
        if (show_progress)
            fprintf ('%d) Reading variable "%s"\n', p, args.Variables{p});
        end
        if (info.Variables{p, 3} == 0)
          continue;
        end
        if (isequal(lower(info.Variables{p, 4}), 'epoch16') && ...
            (~args.CDFEpochToString && ~args.ConvertEpochToDatestr && ...
             ~args.ConvertEpochToDatenum))
          warning('MATLAB:cdfread:Epoch16', ...
                  'Variable "%s" is a CDF_EPOCH16 is retrieved into UTC-string.\nUse epoch16todatenum to convert to MATLAB datenum at index %d', ...
                  args.Variables{p}, p);
        end
 
        args.Slices = fill_slice_vals([], info.Variables(p,:));
        out1{p,1} = args.Variables{p};
        [datax, attrs]  = cdfreadc(filename, args.Variables{p}, args.Records, ...
                                   args.Slices, args.CombineRecords, ...
                                   args.ConvertEpochToDatenum, true, ...
                                   args.KeepEpochAsIs, ...
                                   args.CDFEpochToString, ...
                                   args.ConvertEpochToDatestr);
        if (isequal(lower(info.Variables{p, 4}), 'epoch16') && ...
            args.ConvertEpochToDatenum)
          if (args.CombineRecords)
            datay = cell (1, 1);
            datay = epoch16todatenum(datax{1,p});
            out1{p,2} = {datay};
          else
            ss = size (datax);
            datay = cell(ss);
            for q=1:ss(1)
              for r=1:ss(2)
                datay(r,q) = epoch16todatenum(datax{r,q});
              end
            end
            out1{p,2} = datay;
          end
        else
          out1{p,2} = datax;
        end
        out1{p,3} = attrs;
    end
    [dataX, dummy]  = cdfreadc('to_close', args.Variables{1}, args.Records, ...
                                args.Slices, args.CombineRecords, ...
                                args.ConvertEpochToDatenum, false, ...
                                args.KeepEpochAsIs, ... 
                                args.CDFEpochToString, ...
                                args.ConvertEpochToDatestr);

    % Change a cell array to an array of structures.
    fields = {'VariableName', 'Data', 'Attributes'};
    out = cell2struct(out1, fields, 2); 
    if (~structure)
      out = arrayfun(@(x)x.Data,out,'UniformOutput',false);
    end

  else

    if (args.CombineRecords)
        data = cell(1, length(args.Variables));
    else
        data = cell(length(args.Records), length(args.Variables));
    end

    for p = 1:length(args.Variables)
        if (show_progress)
            fprintf ('%d) Reading variable "%s"\n', p, args.Variables{p});
        end
        if (info.Variables{p, 3} == 0)
          continue;
        end

        if (isequal(lower(info.Variables{p, 4}), 'epoch16') && ...
            (~args.CDFEpochToString && ~args.ConvertEpochToDatestr && ...
             ~args.ConvertEpochToDatenum && ~args.KeepEpochAsIs))
          warning('MATLAB:cdfread:Epoch16', ...
                  'Variable "%s" is a CDF_EPOCH16 is retrieved into UTC-string.\nUse epoch16todatenum to convert to MATLAB datenum at index %d ', ...
                  args.Variables{p}, p);
        end
       
        args.Slices = fill_slice_vals([], info.Variables(p,:));
        if (info.Variables{p, 5}(1) == 'F')

            % Special case for variables which don't vary by record.
            [xdata, dummy] = cdfreadc(filename, args.Variables{p}, 0, ...
                                      args.Slices, ...
                                      args.CombineRecords, ...
                                      args.ConvertEpochToDatenum, false, ...
                                      args.KeepEpochAsIs, ...
                                      args.CDFEpochToString, ...
                                      args.ConvertEpochToDatestr);
            if (args.CombineRecords)
              if (isequal(lower(info.Variables{p, 4}), 'epoch16') && ...
                  args.ConvertEpochToDatenum)
                data(p) = epoch16todatenum(xdata{1,p});
              else
                data{p} = xdata;
              end
            else
              if (isequal(lower(info.Variables{p, 4}), 'epoch16') && ...
                  args.ConvertEpochToDatenum)
                data(:,p) = repmat(epoch16todatenum(xdata{1,1}), ...
                                   length(args.Records), 1);
              else
                data{p} = xdata;
              end
            end

        else

            [xdata, dummy] = cdfreadc(filename, args.Variables{p}, ...
                                      args.Records, args.Slices, ...
                                      args.CombineRecords, ...
                                      args.ConvertEpochToDatenum, ... 
                                      false, ...
                                      args.KeepEpochAsIs, ...
                                      args.CDFEpochToString, ...
                                      args.ConvertEpochToDatestr);
            if (args.CombineRecords)
              if (isequal(lower(info.Variables{p, 4}), 'epoch16') && ...
                  args.ConvertEpochToDatenum)
                s =size(xdata);
                for x=1:s(1)
                  ydata(x,1) = epoch16todatenum(xdata{x,1});
                end
                data{p} = ydata;
              else
                data{p} = xdata;
              end
            else
              % M-by-N cell array....
              % Convert epoch data.
              if (isequal(lower(info.Variables{p, 4}), 'tt2000'))
                if (args.ConvertEpochToDatenum)
                  for q = 1:length(xdata)
                    data(q,p) = xdata(q);
                  end
                else
                  for q = 1:length(xdata)
                    if (length(xdata{q}) > 1)
                      for r = 1:length(xdata{q})
                        databb(r,1) = cdftt2000(xdata{q}(r,1));
                      end
                      data{q,p} = databb;
                    else
                      data{q,p} = cdftt2000(xdata{q});
                    end
                  end
                end
              elseif (isequal(lower(info.Variables{p, 4}), 'epoch'))
                if (args.CDFEpochToString || args.KeepEpochAsIs || ...
                    args.ConvertEpochToDatenum || args.ConvertEpochToDatestr)
                  for q = 1:length(xdata)
                    data(q,p) = xdata(q);
                  end
                elseif (~args.ConvertEpochToDatenum)
                  %
                  % None option case - set up to cdfepoch object
                  %
                  if (length(xdata) > 1)
                    for q = 1:length(xdata)
                      if (length(xdata{q}) > 1)
                        for r = 1:length(xdata{q})
                          databb(r,1) = cdfepoch(xdata{q}(r,1));
                        end
                        data{q,p} = databb;
                      else
                        data{q,p} = cdfepoch(xdata{q});
                      end
                    end
                  end
                else
                  data{1,p} = cdfepoch(xdata);
                end
              elseif (isequal(lower(info.Variables{p, 4}), 'epoch16'))
                if (args.ConvertEpochToDatenum)
                  for q = 1:length(xdata)
                    data{q,p} = epoch16todatenum(xdata{q,1});
                  end
                else
                  data(:,p) = xdata;
                end
              else
                data(:,p) = xdata;
              end
            end

        end

    end
    [dataX, dummy]  = cdfreadc('to_close', args.Variables{1}, args.Records, ...
                               args.Slices, args.CombineRecords, ...
                               args.ConvertEpochToDatenum, false, ...
                               args.KeepEpochAsIs, args.CDFEpochToString, ...
                               args.ConvertEpochToDatestr);
    out = data;
  end
end


%%%
%%% Function find_records
%%%

function records = find_records(var_details)

% Find which variables to consider.
rec_values = [var_details{:, 3}];
max_record = max(rec_values);

if (isempty(max_record))
  records = [];
else
  records = 0:(max_record - 1);
end



%%%
%%% Function parse_fill_vals
%%%

function [slices, msg] = parse_slice_vals(slices, var_details)

msg = '';

% Find the number of dimensions that the CDF recognizes.  This is given
% explicitly in the variance specification as the number of values to the
% right of the '/' (i.e., the length of the variance string minus two).
vary = var_details{5};
num_cdf_dims = size(vary, 2) - 2;


%
% Check the user-provided slice values.
%

if (num_cdf_dims < size(slices, 1))
    msg = sprintf(['Number of slice rows (%d) exceeds number of' ...
                   ' dimensions (%d) in CDF variable.'], ...
                  size(slices, 1), num_cdf_dims);
    return
end

if (any(slices(:,1) < 0))
    
    msg = 'Slice indices must be nonnegative.';
    return
    
elseif (any(slices(:,2) < 1))
    
    msg = 'Slice interval values must be positive.';
    return
    
elseif (any(slices(:,3) < 1))
    
    msg = 'Slice count values must be positive.';
    return
    
end

for p = 1:size(slices,1)
    
    % Indices are zero-based.
    max_idx = var_details{2}(p) - 1;
    last_requested = slices(p,1) + (slices(p,3) - 1) * slices(p,2);
    
    if (last_requested > max_idx)
        
        msg = sprintf(['Slice values for dimension %d exceed maximum' ...
                       ' index (%d).'], p, max_idx);
        return
        
    end
end


%
% Append unspecified slice values.
%
slices = fill_slice_vals(slices, var_details);



%%%
%%% Function fill_slice_vals
%%%

function slices = fill_slice_vals(slices, var_details)

dims = var_details{2};
vary = var_details{5};
num_cdf_dims = size(vary, 2) - 2;

if (num_cdf_dims > size(slices, 1))
    
    % Fill extra dimensions.
    for p = (size(slices, 1) + 1):(num_cdf_dims)
        slices(p, :) = [0 1 dims(p)];
    end
    
elseif (num_cdf_dims == 0)
    
    % Special case for scalar values.
    slices = [0 1 1];
    
end



%%%
%%% Function parse_inputs
%%%

function [args, msg, structure, show_progress] = parse_inputs(varargin)
% Set default values
show_progress = false;
structure = false;
args.CombineRecords = false;
args.ConvertEpochToDatenum = false;
args.ConvertEpochToDatestr = false;
args.KeepEpochAsIs = false;
args.CDFEpochToString = false;
args.Records = [];
args.Slices = [];
args.Variables = {};

msg = '';

% Parse arguments based on their number.
if (nargin > 0)
    paramStrings = {'variables'
                    'records'
                    'slices'
                    'convertepochtodatenum'
                    'convertepochtodatestr'
                    'keepepochasis'
                    'combinerecords'
                    'structure'
                    'cdfepochtostring'
                    'showprogress'};
    
    % For each pair
    for k = 1:2:length(varargin)
       param = lower(varargin{k});
       
            
       if (~ischar(param))
           msg = 'Parameter name must be a string.';
           return
       end

       idx = strmatch(param, paramStrings);
       
       if (isempty(idx))
           msg = sprintf('Unrecognized parameter name "%s".', param);
           return
       elseif (length(idx) > 1)
           msg = sprintf('Ambiguous parameter name "%s".', param);
           return
       end
    
       switch (paramStrings{idx})
       case 'variables'
           
           if (k == length(varargin))
               msg = 'No variables specified.';
               return
           else
               
               args.Variables = varargin{k + 1};
               
               if (~iscell(args.Variables))
                   args.Variables = {args.Variables};
               end
               
               for p = 1:length(args.Variables)
                   if (~ischar(args.Variables{p}))
                       msg = 'All variable names must be strings.';
                       return
                   end
               end
           end
           
       case 'records'
           
           if (k == length(varargin))
               msg = 'No records specified.';
               return
           else
               
               records = varargin{k + 1};
               
               if ((~isa(records, 'double')) || ...
                   (length(records) ~= numel(records)) || ...
                   (any(rem(records, 1))))
                   
                   msg = 'Record list must be a vector of integers.';
                   
               end
               
               args.Records = records;
           end
           
       case 'slices'
           
           if (k == length(varargin))
               msg = 'No slice values specified.';
               return
           else
               
               slices = varargin{k + 1};
               
               if ((~isa(slices, 'double')) || ...
                   (size(slices, 2) ~= 3) || ...
                   (~isempty(find(rem(slices, 1) ~= 0))))
                   
                   msg = 'Variable slice values must be n-by-3 array of integers.';
                   return
               end
               
               args.Slices = slices;
           end
           
       case 'convertepochtodatenum'
           
           if (k == length(varargin))
               msg = 'No epoch conversion value specified.';
               return
           else
               convert = varargin{k + 1};
               if (numel(convert) ~= 1)
                   msg = 'Epoch conversion value must be a scalar logical.';
               end
               
               if (islogical(convert))
                   args.ConvertEpochToDatenum = convert;
               elseif (isnumeric(convert))
                   args.ConvertEpochToDatenum = logical(convert);
               else
                   msg = 'Epoch conversion value must be a scalar logical.';
               end
           end

       case 'convertepochtodatestr'

           if (k == length(varargin))
               msg = 'No epoch conversion value specified.';
               return
           else
               convert = varargin{k + 1};
               if (numel(convert) ~= 1)
                   msg = 'Epoch conversion value must be a scalar logical.';
               end

               if (islogical(convert))
                   args.ConvertEpochToDatestr = convert;
               elseif (isnumeric(convert))
                   args.ConvertEpochToDatestr = logical(convert);
               else
                   msg = 'Epoch conversion value must be a scalar logical.';
               end
           end

       case 'combinerecords'
           
           if (k == length(varargin))
               msg = 'Missing "CombineRecord" value.';
               return
           else
               combine = varargin{k + 1};
               if (numel(combine) ~= 1)
                   msg = 'The "CombineRecord" value must be a scalar logical.';
               end
               
               if (islogical(combine))
                   args.CombineRecords = combine;
               elseif (isnumeric(combine))
                   args.CombineRecords = logical(combine);
               else
                   msg = 'The "CombineRecord" value must be a scalar logical.';
               end
           end

       case 'showprogress'
  
           if (k == length(varargin))
               msg = 'Missing "ShowProgress" value.';
               return
           else
               sp = varargin{k + 1};
               if (numel(sp) ~= 1)
                   msg = 'The "ShowProgress" value must be a scalar logical.';
               end
  
               if (islogical(sp))
                   show_progress = sp;
               elseif (isnumeric(sp))
                   show_progress = logical(sp);
               else
                   msg = 'The "ShowProgress" value must be a scalar logical.';
               end
           end
 
       case 'structure'
  
           if (k == length(varargin))
               msg = 'Missing "Structure" value.';
               return
           else
               sp = varargin{k + 1};
               if (numel(sp) ~= 1)
                   msg = 'The "Structure" value must be a scalar logical.';
               end
  
               if (islogical(sp))
                   structure = sp;
               elseif (isnumeric(sp))
                   structure = logical(sp);
               else
                   msg = 'The "Structure" value must be a scalar logical.';
               end
           end

       case 'keepepochasis'

           if (k == length(varargin))
               msg = 'No KeepEpochAsIs value specified.';
               return
           else
               keepasis = varargin{k + 1};
               if (numel(keepasis) ~= 1)
                   msg = 'KeepEpochAsIs value must be a scalar logical.';
               end

               if (islogical(keepasis))
                   args.KeepEpochAsIs = keepasis;
               elseif (isnumeric(keepasis))
                   args.KeepEpochAsIs = logical(keepasis);
               else
                   msg = 'KeepEpochAsIs value must be a scalar logical.';
               end
           end
 
       case 'cdfepochtostring'

           if (k == length(varargin))
               msg = 'No CDFEpochToString value specified.';
               return
           else
               epochtostring = varargin{k + 1};
               if (numel(epochtostring) ~= 1)
                   msg = 'CDFEpochToString value must be a scalar logical.';
               end

               if (islogical(epochtostring))
                   args.CDFEpochToString = epochtostring;
               elseif (isnumeric(epochtostring))
                   args.CDFEpochToString = logical(epochtostring);
               else
                   msg = 'CDFEpochToString value must be a scalar logical.';
               end
           end
 
       end  % switch
    end  % for

end  % if (nargin > 1)



function epochs = convert_epoch(epoch_nums, convertToDatenum)
%CONVERT_EPOCH   Convert numeric epoch values to CDFEPOCH objects.

% Note: MATLAB datenums are the number of days since 00-Jan-0000, while the
%       CDF epoch is the number of milliseconds since 01-Jan-0000. 

% Convert values from milliseconds to MATLAB serial dates.
ml_nums = (epoch_nums ./ 86400000) + 1;

% Convert MATLAB serial dates to CDFEPOCH objects.
if (convertToDatenum)
    epochs = ml_nums;
else
    epochs = cdfepoch(ml_nums);
end



function validate_inputs(args)
%VALIDATE_INPUTS   Ensure that the mutually exclusive options weren't provided.

if ((args.CombineRecords) && (~isempty(args.Records)))
    error('MATLAB:cdfread:combineRecordSubset', '%s\n%s', ...
          'You cannot currently combine a subset of records.', ...
          'Specify only one of ''CombineRecords'' and ''Records''.')
end

if (args.ConvertEpochToDatenum && args.ConvertEpochToDatestr)
    error('MATLAB:cdfread:Epochmutualexclusive', '%s\n', ...
          'Specify only one of ''ConvertEpochToDatenum'' and ''ConvertEpochToDatestr''.')
end

if (args.ConvertEpochToDatenum && args.KeepEpochAsIs)
    error('MATLAB:cdfread:Epochmutualexclusive', '%s\n', ...
          'Specify only one of ''ConvertEpochToDatenum'' and ''KeepEpochAsIs''.')
end

if (args.ConvertEpochToDatestr && args.KeepEpochAsIs)
    error('MATLAB:cdfread:Epochmutualexclusive', '%s\n', ...
          'Specify only one of ''ConvertEpochToDatestr'' and ''KeepEpochAsIs''.')
end

if (args.CDFEpochToString && args.KeepEpochAsIs)
    error('MATLAB:cdfread:Epochmutualexclusive', '%s\n', ...
          'Specify only one of ''CDFEpochToString'' and ''KeepEpochAsIs''.')
end

if (args.CDFEpochToString && args.ConvertEpochToDatenum)
    error('MATLAB:cdfread:Epochmutualexclusive', '%s\n', ...
          'Specify only one of ''CDFEpochToString'' and ''ConvertEpochToDatenum''.')
end

if (args.CDFEpochToString && args.ConvertEpochToDatestr)
    error('MATLAB:cdfread:Epochmutualexclusive', '%s\n', ...
          'Specify only one of ''CDFEpochToString'' and ''ConvertEpochToDatestr''.')
end

