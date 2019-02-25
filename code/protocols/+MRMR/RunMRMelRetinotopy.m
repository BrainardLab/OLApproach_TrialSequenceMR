%% clear stuff
clear

%% Set the parameter structure here
%
% Who we are and what we're doing today
protocolParams.approach = 'OLApproach_TrialSequenceMR';
protocolParams.protocol = 'MRMR';
protocolParams.protocolOutputName = 'MR';
protocolParams.emailRecipient = 'hmcadams@sas.upenn.edu';
protocolParams.verbose = true;
protocolParams.simulate.oneLight = true;
protocolParams.simulate.makePlots = true;
protocolParams.simulate.radiometer = true;

%% Set up all the parameters and make Modulations
[protocolParams,MaxMelDirection,MaxMelBackground,LMSDirection,LMSBackground,ol]  = MRMR.setAndSaveParams(protocolParams);

%% Make the temporal modulations for experiment
[melModulationsCellArray, LMSModulationsCellArray, pulseParams] = MRMR.makeTemporalModulations(MaxMelDirection,MaxMelBackground,LMSDirection,LMSBackground,protocolParams);

%% Make trial order
protocolParams = MRMR.makeTrialOrder(protocolParams);

%% Run the Melanopsin acquisition.
protocolParams.trialType = 'melanopsin';
ApproachEngine(ol,protocolParams,melModulationsCellArray,pulseParams,'acquisitionNumber',[],'verbose',protocolParams.verbose);

%% Run the LMS acquisition.
protocolParams.trialType = 'LMS';
ApproachEngine(ol,protocolParams,LMSModulationsCellArray,pulseParams,'acquisitionNumber',[],'verbose',protocolParams.verbose);

%% Post-Experiemnt Validations. 
MRMR.postExpValidation(protocolParams,ol,MaxMelDirection,MaxMelBackground, LMSDirection, LMSBackground);