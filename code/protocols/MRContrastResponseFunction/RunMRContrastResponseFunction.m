clear
%% Set up all the parameters and make Modulations
% [ *NOTE: MB: I plan on making this a more robust function that will
% better fit our needs by taking in multiple directions and key/value
% pairs but in the interest of making the scan on 04/11 it willb be simple.]

[protocolParams,trialTypeParams,ConeDirectedDirections,ConeDirectedBackground, ol, directions]  = setAndSaveParams();

%% Make the temporal modulations for experiment
[modulationsCellArray,pulseParams] = makeTemporalModulations(ConeDirectedDirections,ConeDirectedBackground,trialTypeParams,protocolParams);

%% Run the experiment.
ApproachEngine(ol,protocolParams,modulationsCellArray,pulseParams,'acquisitionNumber',[],'verbose',protocolParams.verbose);

%% Post-Experiemnt Validations. 
postExpValidation(protocolParams.nValidationsPerDirection,protocolParams,ol,ConeDirectedDirections,ConeDirectedBackground,directions);