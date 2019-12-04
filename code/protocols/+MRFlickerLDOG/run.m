%% clear stuff
clear

%% Set the parameter structure here
%
% Who we are and what we're doing today
protocolParams.approach = 'OLApproach_TrialSequenceMR';
protocolParams.protocol = 'MRFlickerLDOG';
protocolParams.protocolOutputName = 'MRFlickerLDOG';
protocolParams.emailRecipient = 'huseyinozenc.taskin@pennmedicine.upenn.edu';
protocolParams.verbose = true;
protocolParams.simulate.oneLight = true;
protocolParams.simulate.makePlots = true;
protocolParams.simulate.radiometer = true;

% Need to figure out what "directions" is as compared to "modDirection".


%% Set up all the parameters and make Modulations
[protocolParams,LSDirection,LSBackground, ol] = MRFlickerLDOG.setAndSaveParams(protocolParams);

% set OneLight to AllMirrorsOff
ol.setAll(false);
%% Make the temporal modulations for experiment
[modulationsCellArray,temporalParams] = MRFlickerLDOG.makeTemporalModulations(LSDirection,LSBackground,protocolParams);

%% Make trial order
protocolParams = MRFlickerLDOG.makeTrialOrder(protocolParams);

%% Run the experiment.
ApproachEngine(ol,protocolParams,modulationsCellArray,temporalParams,'acquisitionNumber',[],'verbose',protocolParams.verbose);

% set OneLight to AllMirrorsOff. HMM notes that this step should be
% unnecessary, as the behavior of ApproachEngine should be accomplishing
% this automatically. However the extra line of code shouldn't hurt.
ol.setAll(false);
%% Post-Experiemnt Validations. 
MRFlickerLDOG.postExpValidation(protocolParams,ol,modDirection,background);