%% clear stuff
clear

%% Set the parameter structure here
%
% Who we are and what we're doing today
protocolParams.approach = 'OLApproach_TrialSequenceMR';
protocolParams.protocol = 'MRMaxFlash';
protocolParams.protocolOutputName = 'MRMaxFlash';
protocolParams.emailRecipient = 'huseyinozenc.taskin@pennmedicine.upenn.edu';
protocolParams.verbose = true;
protocolParams.simulate.oneLight = false;
protocolParams.simulate.makePlots = true;
protocolParams.simulate.radiometer = true;

% Need to figure out what "directions" is as compared to "modDirection".


%% Set up all the parameters and make Modulations
[protocolParams,modDirection,background, nullDirection, ol] = MRMaxFlash.setAndSaveParams(protocolParams);

%% Make the temporal modulations for experiment
[modulationsCellArray,temporalParams] = MRMaxFlash.makeTemporalModulations(modDirection,background,nullDirection,protocolParams);

%% Make trial order
protocolParams = MRMaxFlash.makeTrialOrder(protocolParams);

%% Run the experiment.
ApproachEngine(ol,protocolParams,modulationsCellArray,temporalParams,'acquisitionNumber',[],'verbose',protocolParams.verbose);

%% Post-Experiemnt Validations. 
%MRMaxFlash.postExpValidation(protocolParams.nValidationsPerDirection,protocolParams,ol,modDirection,background,directions);