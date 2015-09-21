function info = XpdfInfo(varargin)
% XpdfInfo returns PDF information by executing the Xpdf pdfinfo command.
% This function acts as a MATLAB wrapper for pdfinfo and will return a
% structure containing the PDF information returned from this Xpdf command.
% See below for the information retrieved.  This function was created from
% pdfinfo version 3.04.  pdfinfo is Copyrighted (1996-2014) by Glyph & Cog, 
% LLC and distributed under the GNU GPL version 2 license.
%
% The following variables are required for proper execution: 
%   varargin: cell array of strings containing the full PDF file name. 
%       The name can be provided either as a single string (in varargin{1})
%       containing the path and file, or as separate strings.  If separate 
%       strings are provided, they are concatenated using fullfile()
%
% The following variables are returned upon successful completion:
%   info: a structure containing the following fields: title, subject,
%       keywords, author, creator, producer, creationdate, moddate, tagged,
%       form, pages, encrypted, pagesize, mediabox, cropbox, bleedbox, 
%       trimbox, artbox, filesize, optimized, and version.  Note that page
%       size is in units of pts, while file size is in bytes.
%
% Below is an example of how this function is used:
%  
%   % Retrieve info from test.pdf
%   info = XpdfInfo('/path/to/file/', 'test.pdf');
%
%   % Print the author
%   fprintf('%s\n', info.author);
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
        Event('XpdfInfo requires at least one input argument', 'ERROR');
    else
        error('XpdfInfo requires at least one input argument');
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
    
% Initialize empty return variable
info = struct;

% Execute pdfinfo with -box flag, retrieving results
[status, cmdout] = system([XpdfWhich('pdfinfo'), ' -box "', ...
    fullfile(varargin{1:nargin}), '"']);

% If status is 0 (successful)
if status == 0
    
    % Split result into lines
    arr = strsplit(cmdout, '\n');
    
    % Loop through result lines
    for i = 1:length(arr)
       
        % If line contains title
        if strncmp('Title:', arr{i}, 6)
            info.title = arr{i}(17:end);
            continue;
            
        % Otherwise, if line contains subject
        elseif strncmp('Subject:', arr{i}, 8)
            info.subject = arr{i}(17:end);
            continue;
            
        % Otherwise, if line contains keywords
        elseif strncmp('Keywords:', arr{i}, 9)
            info.keywords = arr{i}(17:end);
            continue;
            
        % Otherwise, if line contains author
        elseif strncmp('Author:', arr{i}, 7)
            info.author = arr{i}(17:end);
            continue;
            
        % Otherwise, if line contains creator
        elseif strncmp('Creator:', arr{i}, 8)
            info.creator = arr{i}(17:end);
            continue;
            
        % Otherwise, if line contains producer
        elseif strncmp('Producer:', arr{i}, 9)
            info.producer = arr{i}(17:end);
            continue;
       
        % Otherwise, if line contains creationdate
        elseif strncmp('CreationDate:', arr{i}, 13)
            if ~isempty(regexpi(arr{i}(17:end), ...
                    '[a-z]+\s+[a-z]+\s+\d+\s+\d+:\d+:\d+\s+\d+', 'ONCE'))
                info.creationdate = datetime(arr{i}(17:end), 'InputFormat', ...
                    'eee MMM dd HH:mm:ss yyyy');
            elseif ~isempty(regexpi(arr{i}(17:end), ...
                    '\d+/\d+/\d+\s+\d+:\d+:\d+', 'ONCE'))
                info.creationdate = datetime(arr{i}(17:end), 'InputFormat', ...
                    'MM/dd/yy HH:mm:ss');
            end
            continue;
            
        % Otherwise, if line contains moddate
        elseif strncmp('ModDate:', arr{i}, 8)
            if ~isempty(regexpi(arr{i}(17:end), ...
                    '[a-z]+\s+[a-z]+\s+\d+\s+\d+:\d+:\d+\s+\d+', 'ONCE'))
                info.moddate = datetime(arr{i}(17:end), 'InputFormat', ...
                    'eee MMM dd HH:mm:ss yyyy');
            elseif ~isempty(regexpi(arr{i}(17:end), ...
                    '\d+/\d+/\d+\s+\d+:\d+:\d+', 'ONCE'))
                info.moddate = datetime(arr{i}(17:end), 'InputFormat', ...
                    'MM/dd/yy HH:mm:ss');
            end
            continue;
        
        % Otherwise, if line contains tagged
        elseif strncmp('Tagged:', arr{i}, 7)
            if strcmp(arr{i}(17:end), 'yes')
                info.tagged = true;
            elseif strcmp(arr{i}(17:end), 'no')
                info.tagged = false;
            else
                info.tagged = arr{i}(17:end);
            end
            continue;
            
        % Otherwise, if line contains form
        elseif strncmp('Form:', arr{i}, 5)
            info.form = arr{i}(17:end);
            continue;
        
        % Otherwise, if line contains pages
        elseif strncmp('Pages:', arr{i}, 6)
            info.pages = str2double(arr{i}(17:end));
            continue;
        
        % Otherwise, if line contains encrypted
        elseif strncmp('Encrypted:', arr{i}, 10)
            if strcmp(arr{i}(17:end), 'yes')
                info.encrypted = true;
            elseif strcmp(arr{i}(17:end), 'no')
                info.encrypted = false;
            else
                info.tagged = arr{i}(17:end);
            end
            continue;
        
        % Otherwise, if line contains page size
        elseif strncmp('Page size:', arr{i}, 10)
            info.pagesize = str2double(regexp(arr{i}(17:end), ...
                '^([0-9]+) x ([0-9]+)', 'once', 'tokens'));
            continue;
            
        % Otherwise, if line contains mediabox
        elseif strncmp('MediaBox:', arr{i}, 9)
            info.mediabox = str2double(regexp(arr{i}(17:end), ...
                '^\s+([0-9\.]+)\s+([0-9\.]+)\s+([0-9\.]+)\s+([0-9\.]+)', ...
                'once', 'tokens'));
            continue;
            
        % Otherwise, if line contains cropbox
        elseif strncmp('CropBox:', arr{i}, 8)
            info.cropbox = str2double(regexp(arr{i}(17:end), ...
                '^\s+([0-9\.]+)\s+([0-9\.]+)\s+([0-9\.]+)\s+([0-9\.]+)', ...
                'once', 'tokens'));
            continue;
            
        % Otherwise, if line contains bleedbox
        elseif strncmp('BleedBox:', arr{i}, 9)
            info.bleedbox = str2double(regexp(arr{i}(17:end), ...
                '^\s+([0-9\.]+)\s+([0-9\.]+)\s+([0-9\.]+)\s+([0-9\.]+)', ...
                'once', 'tokens'));
            continue;
        
        % Otherwise, if line contains trimbox
        elseif strncmp('TrimBox:', arr{i}, 8)
            info.timbox = str2double(regexp(arr{i}(17:end), ...
                '^\s+([0-9\.]+)\s+([0-9\.]+)\s+([0-9\.]+)\s+([0-9\.]+)', ...
                'once', 'tokens'));
            continue;
            
        % Otherwise, if line contains artbox
        elseif strncmp('ArtBox:', arr{i}, 7)
            info.artbox = str2double(regexp(arr{i}(17:end), ...
                '^\s+([0-9\.]+)\s+([0-9\.]+)\s+([0-9\.]+)\s+([0-9\.]+)', ...
                'once', 'tokens'));
            continue;
            
        % Otherwise, if line contains file size
        elseif strncmp('File size:', arr{i}, 10)
            info.filesize = str2double(regexp(arr{i}(17:end), ...
                '^([0-9]+)', 'once', 'tokens'));
            continue;
        
        % Otherwise, if line contains optimized
        elseif strncmp('Optimized:', arr{i}, 10)
            if strcmp(arr{i}(17:end), 'yes')
                info.optimized = true;
            elseif strcmp(arr{i}(17:end), 'no')
                info.optimized = false;
            else
                info.tagged = arr{i}(17:end);
            end
            continue;
            
        % Otherwise, if line contains PDf version
        elseif strncmp('PDF version:', arr{i}, 10)
            info.version = arr{i}(17:end);
            continue;
            
        end
    end
 
% Otherwise execution was unsuccessful
else
    if exist('Event', 'file') == 2
        Event(sprintf('pdfinfo failed with return status %i', status), ...
            'ERROR');
    else
        error('pdfinfo failed with return status %i', status);
    end
end

% Clear temporary variables
clear status cmdout arr i;
