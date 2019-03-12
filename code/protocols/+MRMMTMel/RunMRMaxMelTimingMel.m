%% clear stuff
clear

%% Set the parameter structure here
%
% Who we are and what we're doing today
protocolParams.approach = 'OLApproach_TrialSequenceMR';
protocolParams.protocol = 'MRMMTMel';
protocolParams.protocolOutputName = 'MRMMTMel';
protocolParams.emailRecipient = 'hmcadams@sas.upenn.edu';
protocolParams.verbose = true;
protocolParams.simulate.oneLight = true;
protocolParams.simulate.makePlots = true;
protocolParams.simulate.radiometer = true;

%% Set up all the parameters and make Modulations
[protocolParams,MaxMelDirection,MaxMelBackground,ol]  = MRMMTMel.setAndSaveParams(protocolParams);
plotFig = figure;
summarizeValidation(MaxMelDirection);
%% Make the temporal modulations for experiment
[melModulationsCellArray,  pulseParams] = MRMMTMel.makeTemporalModulations(MaxMelDirection,MaxMelBackground, protocolParams);

%% Run the Melanopsin acquisition.
protocolParams.trialType = 'melanopsin';
protocolParams.acquisitionNumber = input('Enter acquisition (aka scan) number: ');
protocolParams = MRMMTMel.makeTrialOrder(protocolParams, protocolParams.acquisitionNumber);
ApproachEngine(ol,protocolParams,melModulationsCellArray,pulseParams,'acquisitionNumber',protocolParams.acquisitionNumber,'verbose',protocolParams.verbose);

%% Post-Experiemnt Validations. 
MRMMTMel.postExpValidation(protocolParams,ol,MaxMelDirection,MaxMelBackground);