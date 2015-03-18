function varargout = UnitTest(varargin)
% UnitTest executes the unit tests for this application, and can be called 
% either independently (when testing just the latest version) or via 
% UnitTestHarness (when testing for regressions between versions).  Either 
% two or three input arguments can be passed to UnitTest as described 
% below.
%
% The following variables are required for proper execution: 
%   varargin{1}: string containing the path to the main function
%   varargin{2}: string containing the path to the test data
%   varargin{3} (optional): structure containing reference data to be used
%       for comparison.  If not provided, it is assumed that this version
%       is the reference and therefore all comparison tests will "Pass".
%
% The following variables are returned upon succesful completion when input 
% arguments are provided. If no return variables are given, the results
% will be printed to stdout.
%   varargout{1}: cell array of strings containing preamble text that
%       summarizes the test, where each cell is a line. This text will
%       precede the results table in the report.
%   varargout{2}: n x 3 cell array of strings containing the test ID in
%       the first column, name in the second, and result (Pass/Fail or 
%       numerical values typically) of the test in the third.
%   varargout{3}: cell array of strings containing footnotes referenced by
%       the tests, where each cell is a line.  This text will follow the
%       results table in the report.
%   varargout{4} (optional): structure containing reference data created by 
%       executing this version.  This structure can be passed back into 
%       subsequent executions of UnitTest as varargin{3} to compare results
%       between versions (or to a priori validated reference data).
%
% The following variables are returned when no input arguments are
% provided (required only if called by UnitTestHarness):
%   varargout{1}: string containing the application name (with .m 
%       extension)
%   varargout{2}: string containing the path to the version application 
%       whose results will be used as reference
%   varargout{3}: 1 x n cell array of strings containing paths to the other 
%       applications which will be tested
%   varargout{4}: 2 x m cell array of strings containing the name of each 
%       test suite (first column) and path to the test data (second column)
%   varargout{5}: string containing the path and name of report file (will 
%       be appended by _R201XX.md based on the MATLAB version)
%
% Below is an example of how this function is used:
%
%   % Execute unit test, printing the test results to stdout
%   UnitTest('', '../test_data/RPC_Phantom.pdf', ...
%       load('../test_data/RPC_Phantom.mat'));
%
%   % Execute unit test, storing the test results
%   [preamble, table, footnotes] = UnitTest('', ...
%       '../test_data/RPC_Phantom.pdf', ...
%       load('../test_data/RPC_Phantom.mat'));
%
%   % Execute unit test again but without reference data, this time storing 
%   % the output from UnitTest as a new reference file
%   [preamble, table, footnotes, newreference] = ...
%       UnitTest('', '../test_data/RPC_Phantom.pdf');
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

%% Return Application Information
% If UnitTest was executed without input arguments
if nargin == 0
    
    % Declare the application filename
    varargout{1} = '';

    % Declare current version directory
    varargout{2} = '';

    % Declare prior version directories
    varargout{3} = {};

    % Declare location of test data. Column 1 is the name of the 
    % test suite, column 2 is the absolute path to the file(s)
    varargout{4} = {};

    % Declare name of report file (will be appended by _R201XX.md based on 
    % the MATLAB version)
    varargout{5} = '';
    
    % Return to invoking function
    return;
end

%% Initialize Unit Testing
% Initialize static test result text variables
pass = 'Pass';
fail = 'Fail';
unk = 'N/A'; %#ok<NASGU>

% Initialize preamble text
preamble = {
    '| Input Data | Value |'
    '|------------|-------|'
};

% Initialize results cell array
results = cell(0,3);

% Initialize footnotes cell array
footnotes = cell(0,1);

% Initialize reference structure
if nargout == 4
    reference = struct;
end

%% TEST 1: XpdfInfo Unit Test
%
% DESCRIPTION: This unit test verifies that XpdfInfo runs without error and
% returns valid data.
%
% RELEVANT REQUIREMENTS: none
%
% INPUT DATA: input file RPC_Phantom.pdf, varargin{2}.info
%
% CONDITION A (+): 
%
% CONDITION B (-): 

% Add the PDF file to the preamble
preamble{length(preamble)+1} = ['| PDF File | ', varargin{2}, ' |'];

% Execute XpdfInfo in try/catch statement
try
    info = XpdfInfo(varargin{2});
    pf = pass;
    
    % If reference data exists
    if nargin == 3
        
        % If current value equals the reference
        if ~isequal(info, varargin{3}.info)
            pf = fail;
        end
    end
catch
    pf = fail;
end

% Execute XpdfInfo with bad file
try
    XpdfInfo('asd');
    pf = fail;
catch
    % Test passes if an error is thrown
end

% Execute XpdfInfo with no arguments
try
    XpdfInfo();
    pf = fail;
catch
    % Test passes if an error is thrown
end

% Add header to results table
results{size(results,1)+1,1} = 'ID';
results{size(results,1),2} = 'Test Case';
results{size(results,1),3} = 'Result';

% Add application load result
results{size(results,1)+1,1} = '1';
results{size(results,1),2} = 'XpdfInfo Result Identical';
results{size(results,1),3} = pf;

%% TEST 2/3: XpdfInfo Code Analyzer Messages, Cyclomatic Complexity
%
% DESCRIPTION: This unit test uses the checkcode() MATLAB function to check
%   each function used by the application and return any Code Analyzer
%   messages that result.  The cumulative cyclomatic complexity is also
%   computed for each function and summed to determine the total
%   application complexity.  Although this test does not reference any
%   particular requirements, it is used during development to help identify
%   high risk code.
%
% RELEVANT REQUIREMENTS: none 
%
% INPUT DATA: No input data required
%
% CONDITION A (+): Report any code analyzer messages for all functions
%   called by XpdfInfo
%
% CONDITION B (+): Report the cumulative cyclomatic complexity for all
%   functions called by XpdfInfo

% Search for required functions
fList = matlab.codetools.requiredFilesAndProducts('XpdfInfo.m');

% Initialize complexity and messages counters
comp = 0;
mess = 0;

% Loop through each dependency
for i = 1:length(fList)
    
    % Execute checkcode
    inform = checkcode(fList{i}, '-cyc');
    
    % Loop through results
    for j = 1:length(inform)
       
        % Check for McCabe complexity output
        c = regexp(inform(j).message, ...
            '^The McCabe complexity .+ is ([0-9]+)\.$', 'tokens');
        
        % If regular expression was found
        if ~isempty(c)
            
            % Add complexity
            comp = comp + str2double(c{1});
            
        else
            
            % If not an invalid code message
            if ~strncmp(inform(j).message, 'Filename', 8)
                
                % Log message
                Event(sprintf('%s in %s', inform(j).message, fList{i}), ...
                    'CHCK');

                % Add as code analyzer message
                mess = mess + 1;
            end
        end
        
    end
end

% Add code analyzer messages counter to results
results{size(results,1)+1,1} = '2';
results{size(results,1),2} = 'XpdfInfo Code Analyzer Messages';
results{size(results,1),3} = sprintf('%i', mess);

% Add complexity results
results{size(results,1)+1,1} = '3';
results{size(results,1),2} = 'XpdfInfo Cumulative Cyclomatic Complexity';
results{size(results,1),3} = sprintf('%i', comp);
    
%% TEST 4: XpdfText Unit Test
%
% DESCRIPTION: This unit test verifies that XpdfText runs without error and
% returns valid data.
%
% RELEVANT REQUIREMENTS: none
%
% INPUT DATA: input file RPC_Phantom.pdf, varargin{2}.text 
%
% CONDITION A (+): 
%
% CONDITION B (-): 

% Execute XpdfText in try/catch statement
try
    text = XpdfText(varargin{2});
    pf = pass;
    
    % If reference data exists
    if nargin == 3
        
        % If current value equals the reference
        if ~isequal(text, varargin{3}.text)
            pf = fail;
        end
    end
catch
    pf = fail;
end

% Execute XpdfText with bad file
try
    XpdfText('asd');
    pf = fail;
catch
    % Test passes if an error is thrown
end

% Execute XpdfText with no arguments
try
    XpdfText();
    pf = fail;
catch
    % Test passes if an error is thrown
end

% Add application load result
results{size(results,1)+1,1} = '4';
results{size(results,1),2} = 'XpdfText Result Identical';
results{size(results,1),3} = pf;

%% TEST 5/6: XpdfText Code Analyzer Messages, Cyclomatic Complexity
%
% DESCRIPTION: This unit test uses the checkcode() MATLAB function to check
%   each function used by the application and return any Code Analyzer
%   messages that result.  The cumulative cyclomatic complexity is also
%   computed for each function and summed to determine the total
%   application complexity.  Although this test does not reference any
%   particular requirements, it is used during development to help identify
%   high risk code.
%
% RELEVANT REQUIREMENTS: none 
%
% INPUT DATA: No input data required
%
% CONDITION A (+): Report any code analyzer messages for all functions
%   called by XpdfText
%
% CONDITION B (+): Report the cumulative cyclomatic complexity for all
%   functions called by XpdfText

% Search for required functions
fList = matlab.codetools.requiredFilesAndProducts('XpdfText.m');

% Initialize complexity and messages counters
comp = 0;
mess = 0;

% Loop through each dependency
for i = 1:length(fList)
    
    % Execute checkcode
    inform = checkcode(fList{i}, '-cyc');
    
    % Loop through results
    for j = 1:length(inform)
       
        % Check for McCabe complexity output
        c = regexp(inform(j).message, ...
            '^The McCabe complexity .+ is ([0-9]+)\.$', 'tokens');
        
        % If regular expression was found
        if ~isempty(c)
            
            % Add complexity
            comp = comp + str2double(c{1});
            
        else
            
            % If not an invalid code message
            if ~strncmp(inform(j).message, 'Filename', 8)
                
                % Log message
                Event(sprintf('%s in %s', inform(j).message, fList{i}), ...
                    'CHCK');

                % Add as code analyzer message
                mess = mess + 1;
            end
        end
        
    end
end

% Add code analyzer messages counter to results
results{size(results,1)+1,1} = '5';
results{size(results,1),2} = 'XpdfText Code Analyzer Messages';
results{size(results,1),3} = sprintf('%i', mess);

% Add complexity results
results{size(results,1)+1,1} = '6';
results{size(results,1),2} = 'XpdfText Cumulative Cyclomatic Complexity';
results{size(results,1),3} = sprintf('%i', comp);

%% TEST 7: XpdfPNG Unit Test
%
% DESCRIPTION: This unit test verifies that XpdfPNG runs without error and
% returns valid data.
%
% RELEVANT REQUIREMENTS: none
%
% INPUT DATA: input file RPC_Phantom.pdf, varargin{2}.images 
%
% CONDITION A (+): 
%
% CONDITION B (-): 

% Execute XpdfPNG in try/catch statement
try
    images = XpdfPNG(varargin{2});
    pf = pass;
    
    % If reference data exists
    if nargin == 3
        
        % If current value equals the reference
        if ~isequal(images, varargin{3}.images)
            pf = fail;
        end
    end
catch
    pf = fail;
end

% Execute XpdfPNG with bad file
try
    XpdfPNG('asd');
    pf = fail;
catch
    % Test passes if an error is thrown
end

% Execute XpdfPNG with no arguments
try
    XpdfPNG();
    pf = fail;
catch
    % Test passes if an error is thrown
end

% Add application load result
results{size(results,1)+1,1} = '7';
results{size(results,1),2} = 'XpdfPNG Result Identical';
results{size(results,1),3} = pf;

%% TEST 8/9: XpdfPNG Code Analyzer Messages, Cyclomatic Complexity
%
% DESCRIPTION: This unit test uses the checkcode() MATLAB function to check
%   each function used by the application and return any Code Analyzer
%   messages that result.  The cumulative cyclomatic complexity is also
%   computed for each function and summed to determine the total
%   application complexity.  Although this test does not reference any
%   particular requirements, it is used during development to help identify
%   high risk code.
%
% RELEVANT REQUIREMENTS: none 
%
% INPUT DATA: No input data required
%
% CONDITION A (+): Report any code analyzer messages for all functions
%   called by XpdfPNG
%
% CONDITION B (+): Report the cumulative cyclomatic complexity for all
%   functions called by XpdfPNG

% Search for required functions
fList = matlab.codetools.requiredFilesAndProducts('XpdfPNG.m');

% Initialize complexity and messages counters
comp = 0;
mess = 0;

% Loop through each dependency
for i = 1:length(fList)
    
    % Execute checkcode
    inform = checkcode(fList{i}, '-cyc');
    
    % Loop through results
    for j = 1:length(inform)
       
        % Check for McCabe complexity output
        c = regexp(inform(j).message, ...
            '^The McCabe complexity .+ is ([0-9]+)\.$', 'tokens');
        
        % If regular expression was found
        if ~isempty(c)
            
            % Add complexity
            comp = comp + str2double(c{1});
            
        else
            
            % If not an invalid code message
            if ~strncmp(inform(j).message, 'Filename', 8)
                
                % Log message
                Event(sprintf('%s in %s', inform(j).message, fList{i}), ...
                    'CHCK');

                % Add as code analyzer message
                mess = mess + 1;
            end
        end
        
    end
end

% Add code analyzer messages counter to results
results{size(results,1)+1,1} = '8';
results{size(results,1),2} = 'XpdfPNG Code Analyzer Messages';
results{size(results,1),3} = sprintf('%i', mess);

% Add complexity results
results{size(results,1)+1,1} = '9';
results{size(results,1),2} = 'XpdfPNG Cumulative Cyclomatic Complexity';
results{size(results,1),3} = sprintf('%i', comp);

%% Finish up
% Close all figures
close all force;

% If no return variables are present, print the results
if nargout == 0
    
    % Print preamble
    for j = 1:length(preamble)
        fprintf('%s\n', preamble{j});
    end
    fprintf('\n');
    
    % Loop through each table row
    for j = 1:size(results,1)
        
        % Print table row
        fprintf('| %s |\n', strjoin(results(j,:), ' | '));
       
        % If this is the first column
        if j == 1
            
            % Also print a separator row
            fprintf('|%s\n', repmat('----|', 1, size(results,2)));
        end

    end
    fprintf('\n');
    
    % Print footnotes
    for j = 1:length(footnotes) 
        fprintf('%s<br>\n', footnotes{j});
    end
    
% Otherwise, return the results as variables    
else

    % Store return variables
    if nargout >= 1; varargout{1} = preamble; end
    if nargout >= 2; varargout{2} = results; end
    if nargout >= 3; varargout{3} = footnotes; end
    if nargout >= 4; varargout{4} = reference; end
end