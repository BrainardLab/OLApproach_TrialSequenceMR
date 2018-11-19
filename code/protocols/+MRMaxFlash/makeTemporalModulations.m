function [modulationsCellArray,temporalParams] = makeTemporalModulations(modDirection,modBackground,protocolParams)



%% Make modulations
%
% Make temporal waveform for my experiment
temporalParams = OLWaveformParamsFromName('MaxContrastSinusoid');
temporalParams.frequency = 16;
temporalParams.stimulusDuration = 12; % in sec
temporalParams.timeStep = 1/100;
waveforms = OLWaveformFromParams(temporalParams);

% First make the trial type that has maximal flicker
flickerModulation = OLAssembleModulation([modBackground, modDirection],[ones(size(waveforms)); waveforms]);

% Now make a trial type with 0% contrast and thus no flicker
emptyModulation = OLAssembleModulation([modBackground, modDirection], [ones(size(waveforms)); zeros(size(waveforms))]);

% Now create a third entry that is the background state to be used before
% and after the experiment
[backgroundState.backgroundStarts, backgroundState.backgroundStops] =OLPrimaryToStartsStops(modBackground.differentialPrimaryValues,modBackground.calibration);

% Assemble the three types into a single cell array
modulationsCellArray = {flickerModulation, emptyModulation, backgroundState};


%% Save modulations
modulationSavePath = fullfile(getpref('MRMaxFlash','modulationsBasePath'),protocolParams.observerID,protocolParams.todayDate);
if ~exist(modulationSavePath)
    mkdir(modulationSavePath)
end
modulationSaveName = fullfile(modulationSavePath,'modulations.mat');
save(modulationSaveName,'modulationsCellArray','temporalParams');


