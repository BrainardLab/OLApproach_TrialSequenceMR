%% clear stuff
clear

%% Set the parameter structure here
%
% Who we are and what we're doing today
protocolParams.approach = 'OLApproach_TrialSequenceMR';
protocolParams.protocol = 'MRMMTCombined';
protocolParams.protocolOutputName = 'MRMMTCombined';
protocolParams.emailRecipient = 'hmcadams@sas.upenn.edu';
protocolParams.verbose = true;
protocolParams.simulate.oneLight = true;
protocolParams.simulate.makePlots = true;
protocolParams.simulate.radiometer = true;

%% Set up all the parameters and make Modulations
[protocolParams,MaxMelDirection,MaxMelBackground,LMSDirection,LMSBackground,ol]  = MRMMTCombined.setAndSaveParams(protocolParams);
plotFig = figure;
summarizeValidation(LMSDirection);
plotFig = figure;
summarizeValidation(MaxMelDirection);
%% Make the temporal modulations for experiment
[melModulationsCellArray, LMSModulationsCellArray, pulseParams] = MRMMTCombined.makeTemporalModulations(MaxMelDirection,MaxMelBackground,LMSDirection,LMSBackground,protocolParams);

%% Run the Melanopsin acquisition.
protocolParams.trialType = 'melanopsin';
protocolParams.acquisitionNumber = input('Enter acquisition (aka scan) number: ');
protocolParams = MRMMTCombined.makeTrialOrder(protocolParams, protocolParams.acquisitionNumber);
ApproachEngine(ol,protocolParams,melModulationsCellArray,pulseParams,'acquisitionNumber',protocolParams.acquisitionNumber,'verbose',protocolParams.verbose);

%% Run the LMS acquisition.
protocolParams.trialType = 'LMS';
protocolParams.acquisitionNumber = input('Enter acquisition (aka scan) number: ');
protocolParams = MRMMTCombined.makeTrialOrder(protocolParams, protocolParams.acquisitionNumber);
ApproachEngine(ol,protocolParams,LMSModulationsCellArray,pulseParams,'acquisitionNumber',protocolParams.acquisitionNumber,'verbose',protocolParams.verbose);

%% Post-Experiemnt Validations. 
MRMMTCombined.postExpValidation(protocolParams,ol,MaxMelDirection,MaxMelBackground, LMSDirection, LMSBackground);