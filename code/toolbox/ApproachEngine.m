function ApproachEngine(ol,protocolParams,modulationsCellArray,pulseParams,varargin)
% Run a trial sequence MR protcol experiment.
%
% Usage:
%    ApproachEngine(ol,protocolParams)
%
% Description:
%    Master program for running sequences of OneLight pulses/modulations in the scanner.
%
% Inputs:
%    ol (object)              An open OneLight object.
%    protocolParams (struct)  The protocol parameters structure.
%    modulationsCellArray     Cell array of the modulations struct/object
%                             that corresponds to each integer in the trial
%                             sequence specification.
%
% Outputs:
%    None.
%
% Optional key/value pairs:
%    verbose (logical)         true       Be chatty?
%    playSound (logical)       false      Play a sound when the experiment is ready.
%    acquisitionNumber (value) []         Acqusition (aka scan) number for output name
%    acquisitionOrder (vector) []         preset trial order when you dont
%                                         want random 

%% Parse
p = inputParser;
p.addParameter('verbose',true,@islogical);
p.addParameter('playSound',false,@islogical);
p.addParameter('acquisitionNumber',[],@isnumeric);
p.addParameter('acquisitionOrder',[],@isnumeric);
p.parse(varargin{:});

%% Where the data goes
savePath = fullfile(getpref(protocolParams.protocol, 'DataFilesBasePath'),protocolParams.observerID, protocolParams.todayDate, protocolParams.sessionName);
if ~exist(savePath,'dir')
    mkdir(savePath);
end

%% Get acquisition (scan) number if not set
if (isempty(p.Results.acquisitionNumber))
    protocolParams.acquisitionNumber = input('Enter acquisition (aka scan) number: ');
else
    protocolParams.acquisitionNumber = p.Results.acquisitionNumber;
end


%% Start session log
%
% Add protocol output name and acquisition (scan) number
if ~(protocolParams.simulate.oneLight)
    protocolParams = OLSessionLog(protocolParams,'Experiment','StartEnd','start');
end


%% Put together the block struct array.
%
% This describes what happens on each trial of the session.
% Once this is done we don't need the modulation data and we
% clear that just to make sure we don't use it by accident.
block = InitializeBlockStructArray(protocolParams,pulseParams,modulationsCellArray);
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
ol.setMirrors(modulationsCellArray{end}.backgroundStarts, modulationsCellArray{end}.backgroundStops);

%% Adapt to background
%
% Could wait here for a specified adaptation time

%% Set up for responses
if (p.Results.verbose), fprintf('\n* Creating keyboard listener\n'); end
mglListener('init');

%% Run the trial loop.
responseStruct = TrialSequenceMRTrialLoop(protocolParams,block,ol,modulationsCellArray,pulseParams,'verbose',p.Results.verbose);

%% Turn off key listener
mglListener('quit');

%% Save the data
%
% Save protocolParams, block, responseStruct.
% Make sure not to overwrite an existing file.
outputFile = fullfile(savePath,[protocolParams.protocolOutputName,'_', protocolParams.sessionName sprintf('_scan%d.mat', protocolParams.acquisitionNumber)]);
while (exist(outputFile,'file'))
    protocolParams.acquisitionNumber = input(sprintf('Output file %s exists, enter correct acquisition number: \n',outputFile));
    outputFile = fullfile(savePath,[protocolParams.protocolOutputName,'_' protocolParams.sessionName sprintf('_scan%d.mat', protocolParams.acquisitionNumber)]);
end
responseStruct.acquisitionNumber = protocolParams.acquisitionNumber;
save(outputFile,'protocolParams', 'block', 'responseStruct');

%% Close Session Log
OLSessionLog(protocolParams,'Experiment','StartEnd','end');


end

