%% clear stuff
clear

%% Set the parameter structure here
%
% Who we are and what we're doing today
protocolParams.approach = 'OLApproach_TrialSequenceMR';
protocolParams.protocol = 'MRMMTLMS';
protocolParams.protocolOutputName = 'MRMMTLMS';
protocolParams.emailRecipient = 'hmcadams@sas.upenn.edu';
protocolParams.verbose = true;
protocolParams.simulate.oneLight = true;
protocolParams.simulate.makePlots = true;
protocolParams.simulate.radiometer = true;

%% Set up all the parameters and make Modulations
[protocolParams, LMSDirection,LMSBackground,ol]  = MRMMTLMS.setAndSaveParams(protocolParams);
plotFig = figure;
summarizeValidation(LMSDirection);

%% Make the temporal modulations for experiment
[LMSModulationsCellArray, pulseParams] = MRMMTLMS.makeTemporalModulations(LMSDirection,LMSBackground,protocolParams);

%% Run the LMS acquisition.
protocolParams.trialType = 'LMS';
protocolParams.acquisitionNumber = input('Enter acquisition (aka scan) number: ');
protocolParams = MRMMTLMS.makeTrialOrder(protocolParams, protocolParams.acquisitionNumber);
ApproachEngine(ol,protocolParams,LMSModulationsCellArray,pulseParams,'acquisitionNumber',protocolParams.acquisitionNumber,'verbose',protocolParams.verbose);

%% Post-Experiemnt Validations. 
MRMMTLMS.postExpValidation(protocolParams, ol, LMSDirection, LMSBackground);