function executable = XpdfWhich(command)
% XpdfWhich attempts to find the location of the provided Xpdf command.  
% This function is part of the xpdf_tools submodule, and is called by the
% other functions to determine how to execute the command.  The command is
% first searched for in the system path; if not found, the function will
% successively search through each path provided in the paths variable 
% until it is found. 
%
% This function is compatible with linux, Macintosh OSX, and Windows 7 and
% later operating systems. Xpdf is Copyrighted (1996-2014) by Glyph & Cog, 
% LLC and distributed under the GNU GPL version 2 license.
%
% The following variables are required for proper execution: 
%   command: string containing the Xpdf command to be executed (pdftotext)
%
% The following variables are returned upon successful completion:
%   executable: string containing the path and command name to the command.
%       If the function was not found, this string will be empty.
%
% Below is an example of how this function is used:
%  
%   % Search for the function 'pdftotext'
%   executable = XpdfWhich('pdftotext');
%
%   % If found, execute it on a PDF file test.pdf, saving results to
%   % test.txt
%   if ~isempty(executable) {
%       system([executable, ' ./test.pdf ./test.txt']);
%   }
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

% Declare empty return variable
executable = '';

% Declare additional paths to search within. The first column of this cell
% array is the machine type (linux, mac, or win), and the second is the
% path. Paths are relative to this function.
paths = {
    'linux'     'xpdfbin-linux-3.04/bin64'
    'mac'       'xpdfbin-mac-3.04/bin64'
    'win'       'xpdfbin-win-3.04/bin64'
};

% Determine path of current application
[path, ~, ~] = fileparts(mfilename('fullpath'));

%% Search System Path
% If the system is unix-based
if isunix
    
    % Execute which command
    [status, cmdout] = system(['which ', command]);
    
    % If status is 0 (successful) and the system was found
    if status == 0 && ~isempty(cmdout)
        
        % Store path found and stop searching
        executable = strrep(cmdout, ' ', '\ ');
        return;
    end
    
% Otherwise, if Windows
elseif ispc
    
    % Execute where command (will only work on Windows Server 2003 and
    % later systems)
    [status, cmdout] = system(['where ', command, '.exe']);
    
    % If status is 0 (successful) and the system was found
    if status == 0 && ~strcmp(cmdout(1:4), 'INFO')
        
        % Store path found and stop searching
        executable = strrep(cmdout, ' ', '\ ');
        return;
    end
end

%% Search Additional Paths
for i = 1:size(paths, 1)
   
    % If the system is linux and the command exists
    if strcmp(paths{i,1}, 'linux') && isunix && ~ismac && ...
            exist(fullfile(path, paths{i,2}, command), 'file') == 2
            
        % Store path found and stop searching
        executable = ...
            strrep(fullfile(path, paths{i,2}, command), ' ', '\ ');
        return;
        
    % Otherwise, if Mac
    elseif strcmp(paths{i,1}, 'mac') && ismac && ...
            exist(fullfile(path, paths{i,2}, command), 'file') == 2
    
        % Store path found and stop searching
        executable = ...
            strrep(fullfile(path, paths{i,2}, command), ' ', '\ ');
        return;
        
    % Otherwise, if Windows
    elseif strcmp(paths{i,1}, 'win') && ispc && ...
            exist(path, fullfile(paths{i,2}, [command, '.exe']), 'file') == 2
        
        % Store path found (with .exe appended) and stop searching
        executable = ...
            strrep(fullfile(path, paths{i,2}, [command, '.exe']), ' ', '\ ');
        return;
    end
end
