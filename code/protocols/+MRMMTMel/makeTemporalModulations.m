function [melModulationsCellArray, pulseParams] = makeTemporalModulations(MaxMelDirection,MaxMelBackground,protocolParams)



%% Make modulations
%
% Make temporal waveform for my experiment
pulseParams = OLWaveformParamsFromName('MaxContrastPulse'); % get generic pulse parameters
pulseParams.stimulusDuration = 2; % 2 second pulses
[PulseWaveform, pulseTimestep] = OLWaveformFromParams(pulseParams); 

Mel400PulseModulation = OLAssembleModulation([MaxMelBackground, MaxMelDirection], [ones(1, length(PulseWaveform)); PulseWaveform]);
melModulationsCellArray{1} = Mel400PulseModulation;


% also make a modulation with 0% contrast. this will be akin to just
% showing the background
melEmptyModulation = OLAssembleModulation([MaxMelBackground, MaxMelDirection], [ones(1, length(PulseWaveform)); zeros(1,length(PulseWaveform))]);


%% Get the background starts and stops
% the last entry needs to to be a cell entry with the background starts and
% stops
[tempCell.backgroundStarts, tempCell.backgroundStops] =OLPrimaryToStartsStops(MaxMelBackground.differentialPrimaryValues,MaxMelBackground.calibration);
melModulationsCellArray = [melModulationsCellArray, melEmptyModulation, repmat({tempCell},1,1)];


%% Save modulations
modulationSavePath = fullfile(getpref('MRMMTMel','modulationsBasePath'),protocolParams.observerID,protocolParams.todayDate);
if ~exist(modulationSavePath)
    mkdir(modulationSavePath)
end
modulationSaveName = fullfile(modulationSavePath,'modulations.mat');
save(modulationSaveName,'melModulationsCellArray', 'pulseParams','protocolParams','MaxMelDirection');

end



