function [modulationsCellArray,pulseParams] = makeTemporalModulations(MaxMelDirection,MaxMelBackground,trialTypeParams,protocolParams)



%% Make modulations
%
% Make temporal waveform for my experiment
pulseParams = OLWaveformParamsFromName('MaxContrastPulse'); % get generic pulse parameters
pulseParams.stimulusDuration = 4; % 4 second pulses
[Pulse400Waveform, pulseTimestep] = OLWaveformFromParams(pulseParams); % 4 second pulse waveform max contrast


Mel400PulseModulation = OLAssembleModulation([MaxMelBackground, MaxMelDirection], [ones(1, length(Pulse400Waveform)); Pulse400Waveform]);
modulationsCellArray{1} = Mel400PulseModulation;

% also make a modulation with 0% contrast. this will be akin to just
% showing the background
EmptyModulation = OLAssembleModulation([MaxMelBackground, MaxMelDirection], [ones(1, length(Pulse400Waveform)); zeros(1,length(Pulse400Waveform))]);


%% Get the background starts and stops
% the last entry needs to to be a cell entry with the background starts and
% stops
[tempCell.backgroundStarts, tempCell.backgroundStops] =OLPrimaryToStartsStops(MaxMelBackground.differentialPrimaryValues,MaxMelBackground.calibration);
modulationsCellArray = [modulationsCellArray, EmptyModulation, repmat({tempCell},1,1)];

%% Save modulations
modulationSavePath = fullfile(getpref('MRMMT','modulationsBasePath'),protocolParams.observerID,protocolParams.todayDate);
if ~exist(modulationSavePath)
    mkdir(modulationSavePath)
end
modulationSaveName = fullfile(modulationSavePath,'modulations.mat');
save(modulationSaveName,'modulationsCellArray','pulseParams','protocolParams','MaxMelDirection');



