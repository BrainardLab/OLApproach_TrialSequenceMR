function Experiment(ol,protocolParams,varargin)
%%Experiment  Run a trial sequence MR protcol experiment.
%
% Usage:
%    Experiment(ol,protocolParams)
%
% Description:
%    Master program for running sequences of OneLight pulses/modulations in the scanner.
%
% Input:
%    ol (object)              An open OneLight object.
%    protocolParams (struct)  The protocol parameters structure.
%
% Output:
%    None.
%
% Optional key/value pairs:
%    verbose (logical)         true       Be chatty?
%    playSound (logical)       false      Play a sound when the experiment is ready.
%    scanNumber (value)        []         Scan number for output name
 
%% Parse
p = inputParser;
p.addParameter('verbose',true,@islogical);
p.addParameter('playSound',false,@islogical);
p.addParameter('acquisitionNumber',[],@isnumeric);
p.parse(varargin{:});
 
%% Where the data goes
savePath = fullfile(getpref(protocolParams.protocol, 'DataFilesBasePath'),protocolParams.observerID, protocolParams.todayDate, protocolParams.sessionName);
if ~exist(savePath,'dir')
    mkdir(savePath);
end
 
%% Get scan number if not set
if (isempty(p.Results.acquisitionNumber))
    protocolParams.acquisitionNumber = input('Enter scan number: ');
else
    protocolParams.acquisitionNumber = p.Results.acquisitionNumber;
end
    
%% Start session log
%
% Add protocol output name and scan number
protocolParams = OLSessionLog(protocolParams,'Experiment','StartEnd','start');
 
%% Get the modulation starts/stops for each trial type
%
% Get path and filenames.  Check that someone has not
% done something unexpected in the calling program.
modulationDir = fullfile(getpref(protocolParams.protocol, 'ModulationStartsStopsBasePath'), protocolParams.observerID,protocolParams.todayDate,protocolParams.sessionName);
for mm = 1:length(protocolParams.modulationNames)
    fullModulationNames = sprintf('ModulationStartsStops_%s_%s', protocolParams.modulationNames{mm}, protocolParams.directionNames{mm});
    fullModulationNames = strcat(fullModulationNames, sprintf('_trialType_%s',num2str(mm)));
    pathToModFile = [fullModulationNames '.mat'];
    modulationRead = load(fullfile(modulationDir, pathToModFile));
    modulationData(mm)= modulationRead.modulationData;
    modulation{mm} = modulationData(mm).modulation;
    frameDuration(mm) = modulationData(mm).modulationParams.timeStep;
end
 
%% Put together the block struct array.
%
% This describes what happens on each trial of the session.
% Once this is done we don't need the modulation data and we
% clear that just to make sure we don't use it by accident.
block = InitializeBlockStructArray(protocolParams,modulationData);
clear modulationData;
 
%% Begin the experiment
%
% Play a sound to say hello.
if (p.Results.playSound)
    t = linspace(0, 1, 10000);
    y = sin(330*2*pi*t);
    sound(y, 20000);
end
 
%% Set the background
%
% Use the background for the first trial as the background to set.
ol.setMirrors(block(1).modulationData.modulation.background.starts, block(1).modulationData.modulation.background.stops); 
 
%% Adapt to background
%
% Could wait here for a specified adaptation time
 
%% Set up for responses
if (p.Results.verbose), fprintf('\n* Creating keyboard listener\n'); end
mglListener('init');
 
%% Run the trial loop.
tic
responseStruct = TrialSequenceMRTrialLoop(protocolParams,block,ol,'verbose',p.Results.verbose);
toc
%% Turn off key listener
mglListener('quit');
 
%% Save the data
%
% Save protocolParams, block, responseStruct.
% Make sure not to overwrite an existing file.
outputFile = fullfile(savePath,[protocolParams.sessionName '_' protocolParams.protocolOutputName sprintf('_scan%d.mat',protocolParams.acquisitionNumber)]);
while (exist(outputFile,'file'))
    protocolParams.acquisitionNumber = input(sprintf('Output file %s exists, enter correct scan number: \n',outputFile));
    outputFile = fullfile(savePath,[protocolParams.sessionName sprintf('_scan%d.mat',protocolParams.acquisitionNumber)]);
end
responseStruct.acquisitionNumber = protocolParams.acquisitionNumber;
save(outputFile,'protocolParams', 'block', 'responseStruct');
 
%% Close Session Log
OLSessionLog(protocolParams,'Experiment','StartEnd','end');
 
 
end
 


