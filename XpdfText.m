function text = XpdfText(varargin)
% XpdfText returns PDF text by executing the Xpdf pdftotext command.
% This function acts as a MATLAB wrapper for pdftotext and will return a
% cell array of cells containing the PDF text returned from this Xpdf 
% command. This function was created from pdftotext version 3.04.  
% pdftotext is Copyrighted (1996-2014) by Glyph & Cog, LLC and distributed
% under the GNU GPL version 2 license.
%
% The following variables are required for proper execution: 
%   varargin: cell array of strings containing the full or PDF file name. 
%       The name can be provided either as a single string (in varargin{1})
%       containing the path and file, or as separate strings.  If separate 
%       strings are provided, they are concatenated using fullfile()
%
% The following variables are returned upon successful completion:
%   text: an n x 1 cell array of cells containing the text data for n 
%       pages. Each cell contains an m x 1 cell array of strings, where m 
%       is the number of lines on that page. Note that pdftotext is 
%       executed with the -table flag.
%
% Below is an example of how this function is used:
%  
%   % Retrieve info from test.pdf
%   text = XpdfText('/path/to/file/', 'test.pdf');
%
%   % Print the text from the first page
%   fprintf('%s\n', text{1}{1:end});
%
% Author: Mark Geurts, mark.w.geurts@gmail.com
% Copyright (C) 2015 University of Wisconsin Board of Regents
%
% This program is free software: you can redistribute it and/or modify it 
% under the terms of the GNU General Public License as published by the  
% Free Software Foundation, either version 3 of the License, or (at your 
% option) any later version.
%
% This program is distributed in the hope that it will be useful, but 
% WITHOUT ANY WARRANTY; without even the implied warranty of 
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General 
% Public License for more details.
% 
% You should have received a copy of the GNU General Public License along 
% with this program. If not, see http://www.gnu.org/licenses/.

% Check that at least one input argument exists
if nargin == 0
    if exist('Event', 'file') == 2
        Event('XpdfText requires at least one input argument', 'ERROR');
    else
        error('XpdfText requires at least one input argument');
    end
end

% Check that the file exists
if exist(fullfile(varargin{1:nargin}), 'file') ~= 2
    if exist('Event', 'file') == 2
        Event(['The file ', fullfile(varargin{1:nargin}), ' was not found'], ...
            'ERROR');
    else
        error(['The file ', fullfile(varargin{1:nargin}), ' was not found']);
    end
end

% Log start
if exist('Event', 'file') == 2
    Event(['Extracting pdf text from ', fullfile(varargin{1:nargin})]);
    tic;
end
    
% Execute XpdfInfo to retrieve the number of pages
info = XpdfInfo(varargin{1:nargin});

% Initialize empty return variable, with size equal to the number of pages
text = cell(info.pages, 1);

% Loop through each page
for i = 1:info.pages

    % Create temporary file to store text
    tmpName = [tempname, '.txt'];

    % Execute pdftotext with -table flag for this page, retrieving results
    [status, ~] = system(sprintf('%s -table -f %i -l %i "%s" %s', ...
        XpdfWhich('pdftotext'), i, i, fullfile(varargin{1:nargin}), ...
        tmpName));

    % If status is 0 (successful)
    if status == 0

        % Attempt to open file handle to temp file
        fid = fopen(tmpName, 'r');

        % If file handle is not valid
        if fid < 3

            % Throw an error
            if exist('Event', 'file') == 2
                Event(['A file handle could not be opened to ', tmpName], ...
                    'ERROR');
            else
                error(['A file handle could not be opened to ', tmpName]);
            end

        % Otherwise, return results from file    
        else

            % Retrieve first line
            tline = fgetl(fid);

            % Loop through lines
            while ischar(tline)

                % Store line in return variable
                text{i}{length(text{i})+1} = tline;

                % Retrieve next line
                tline = fgetl(fid);
            end
        end
        
        % Close file handle
        fclose(fid);

    % Otherwise execution was unsuccessful
    else
        if exist('Event', 'file') == 2
            Event(sprintf('pdftotext failed with return status %i', status), ...
                'ERROR');
        else
            error('pdftotext failed with return status %i', status);
        end
    end
end

% Clear temporary variables
clear status tmpName fid tline i;

% Log finish
if exist('Event', 'file') == 2
    Event(sprintf('Text extraction completed successfully in %0.3f seconds', toc));
end
