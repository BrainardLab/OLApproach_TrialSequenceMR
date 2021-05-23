%% clear stuff
clear

%% Set the parameter structure here
%
% Who we are and what we're doing today
protocolParams.approach = 'OLApproach_TrialSequenceMR';
protocolParams.protocol = 'MRAGTC';
protocolParams.protocolOutputName = 'AGTC';
protocolParams.emailRecipient = 'aguirreg@upenn.edu';
protocolParams.verbose = true;
protocolParams.simulate.oneLight = true;
protocolParams.simulate.makePlots = true;
protocolParams.simulate.radiometer = true;
protocolParams.takeCalStateMeasurements = false;
protocolParams.takeTempearatureMeasurements = false;

%% Set up all the parameters and make Modulations
[protocolParams,trialTypeParams,PhotoreceptorDirections,PhotoreceptorBackground, ol, directions]  = MRAGTC.setAndSaveParams(protocolParams);

%% Make the temporal modulations for experiment
[modulationsCellArray,flickerParams] = MRAGTC.makeTemporalModulations(PhotoreceptorDirections,PhotoreceptorBackground,trialTypeParams,protocolParams);

%% Create the trial order
protocolParams = MRAGTC.makeTrialOrder(protocolParams,modulationsCellArray);

%     % Add the trial order to the protocol params
%     protocolParams.trialTypeOrder = [];
%     protocolParams.trialTypeOrder(1,:) = trialOrders{protocolParams.acquisitionNumber};
%     protocolParams.trialTypeOrder(2,:) = contrastLevels;

    
%% Run the experiment
ApproachEngine(ol,protocolParams,modulationsCellArray,flickerParams,'acquisitionNumber',[],'verbose',protocolParams.verbose);

%% Post-Experiemnt Validations. 
MRAGTC.postExpValidation(protocolParams.nValidationsPerDirection,protocolParams,ol,PhotoreceptorDirections,PhotoreceptorBackground,directions);