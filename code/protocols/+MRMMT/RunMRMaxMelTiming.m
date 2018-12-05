%% clear stuff
clear

%% Set the parameter structure here
%
% Who we are and what we're doing today
protocolParams.approach = 'OLApproach_TrialSequenceMR';
protocolParams.protocol = 'MRMMT';
protocolParams.protocolOutputName = 'MMT';
protocolParams.emailRecipient = 'hmcadams@sas.upenn.edu';
protocolParams.verbose = true;
protocolParams.simulate.oneLight = true;
protocolParams.simulate.makePlots = true;
protocolParams.simulate.radiometer = true;

%% Set up all the parameters and make Modulations
[protocolParams,MaxMelDirection,MaxMelBackground, ol]  = MRMMT.setAndSaveParams(protocolParams);

%% Make the temporal modulations for experiment
[modulationsCellArray,pulseParams] = MRMMT.makeTemporalModulations(MaxMelDirection,MaxMelBackground,protocolParams);

%% Make trial order
protocolParams = MRMMT.makeTrialOrder(protocolParams);

%% Run the experiment.
ApproachEngine(ol,protocolParams,modulationsCellArray,pulseParams,'acquisitionNumber',[],'verbose',protocolParams.verbose);

%% Post-Experiemnt Validations. 
MRMMT.postExpValidation(protocolParams.nValidationsPerDirection,protocolParams,ol,MaxMelDirection,MaxMelBackground);