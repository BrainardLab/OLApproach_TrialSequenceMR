%% Clear prior vars
clear;

%% set temp exp vars
commandwindow;
protocolParams.observerID = GetWithDefault('>> Enter <strong>user name</strong>', 'HERO_xxxx');
protocolParams.todayDate = datestr(now, 'yyyy-mm-dd');

%% Load the parameters and make Modulations fro prior exp. 
% Load modulation start/stops
correctedSavePath = fullfile(getpref('MRContrastResponseFunction','DirectionCorrectedPrimariesBasePath'),protocolParams.observerID,protocolParams.todayDate);
modulationSaveName = fullfile(correctedSavePath,'correctedPrimaries.mat');
load(modulationSaveName) 

% Load protocol params
modulationSavePath = fullfile(getpref('MRContrastResponseFunction','parameterFilesBasePath'),protocolParams.observerID,protocolParams.todayDate);
modulationSaveName = fullfile(modulationSavePath,'scanParamters.mat');
load(modulationSaveName);

trialTypeParams.contrastLevels = [1,0];

%% Creat OneLight Object
ol = OneLight('simulate',protocolParams.simulate.oneLight,'plotWhenSimulating',protocolParams.simulate.makePlots); drawnow;

%% Make the temporal modulations for experiment
[modulationsCellArray,pulseParams] = makeTemporalModulations(lightFluxDirection,background,trialTypeParams,protocolParams);

%% Run the experiment.
%
% create set trial order 
protocolParams.contrastLevels = [1,0];
acquisitionOrder = repmat([2 1],[1, 14]); % off then on 
protocolParams.protocolOutputName = 'Flash';
ApproachEngine(ol,protocolParams,modulationsCellArray,pulseParams,'acquisitionNumber',1,'verbose',protocolParams.verbose, 'acquisitionOrder', acquisitionOrder);

%% Post-Experiemnt Validations. 
postExpValidation(protocolParams.nValidationsPerDirection,protocolParams,ol,lightFluxDirection,background);