
%% Set up all the parameters and make Modulations
% [ *NOTE: MB: I plan on making this a more robust function that will
% better fit our needs by taking in multiple directions and key/value
% pairs but in the interest of making the scan on 04/11 it will be simple.]

[protocolParams,trialTypeParams,lightFluxDirection,background, ol]  = setAndSaveParams();

%% Make the temporal modulations for experiment
[modulationsCellArray,pulseParams] = makeTemporalModulations(lightFluxDirection,background,trialTypeParams,protocolParams);

%% Run the experiment.
ApproachEngine(ol,protocolParams,modulationsCellArray,pulseParams,'acquisitionNumber',[],'verbose',protocolParams.verbose);