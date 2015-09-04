function images = XpdfPNG(varargin)
% XpdfPNG returns PNG images for a PDF by executing the pdftopng command.
% This function acts as a MATLAB wrapper for pdftopng and will return a
% cell array of image arrays containing the PDF text returned from this 
% Xpdf command. This function was created from pdftopng version 3.04.  
% pdftopng is Copyrighted (1996-2014) by Glyph & Cog, LLC and distributed
% under the GNU GPL version 2 license.
%
% The following variables are required for proper execution: 
%   varargin: cell array of strings containing the full or PDF file name. 
%       The name can be provided either as a single string (in varargin{1})
%       containing the path and file, or as separate strings.  If separate 
%       strings are provided, they are concatenated using fullfile()
%
% The following variables are returned upon successful completion:
%   images: an p x 1 cell array of images containing the 300 DPI PNG images 
%       for p pages. Each image is an m x n x 3 truecolor image array.
%
% Below is an example of how this function is used:
%  
%   % Retrieve info from test.pdf
%   images = XpdfPNG('/path/to/file/', 'test.pdf');
%
%   % Display the first page
%   image(images{1});
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

% Declare DPI to save images at
dpi = 300;

% Check that at least one input argument exists
if nargin == 0
    if exist('Event', 'file') == 2
        Event('XpdfPNG requires at least one input argument', 'ERROR');
    else
        error('XpdfPNG requires at least one input argument');
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
    Event(['Extracting pdf images from ', fullfile(varargin{1:nargin})]);
    tic;
end
    
% Execute XpdfInfo to retrieve the number of pages
info = XpdfInfo(varargin{1:nargin});

% Initialize empty return variable, with size equal to the number of pages
images = cell(info.pages, 1);

% Create file name root to store images in the temp directory
tmpName = [tempdir, 'pdftopng'];

% Execute pdftopng, retrieving results
[status, ~] = system(sprintf('%s -r %i "%s" %s', XpdfWhich('pdftopng'), ...
    dpi, fullfile(varargin{1:nargin}), tmpName));

% If status is 0 (successful)
if status == 0
         
    % Loop through each page
    for i = 1:info.pages

        % Store imread to images cell array
        try
            images{i} = imread(sprintf('%s-%06i.png', tmpName, i), 'png');
            
        % Catch any image read errors
        catch err
            if exist('Event', 'file') == 2
                Event(getReport(err, 'extended', 'hyperlinks', 'off'), ...
                    'ERROR');
            else
                rethrow err;
            end
        end
    end
    
% Otherwise execution was unsuccessful
else
    if exist('Event', 'file') == 2
        Event(sprintf('pdftopng failed with return status %i', status), ...
            'ERROR');
    else
        error('pdftopng failed with return status %i', status);
    end
end

% Clear temporary variables
clear status tmpName i;

% Log start
if exist('Event', 'file') == 2
    Event(sprintf('Extraction completed successfully in %0.3f seconds', toc));
end
