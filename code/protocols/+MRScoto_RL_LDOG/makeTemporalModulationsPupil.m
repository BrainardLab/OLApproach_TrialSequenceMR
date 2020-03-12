function [modulationsCellArray,temporalParams, protocolParams] = makeTemporalModulationsPupil(modDirection,modBackground, protocolParams)

frequencySet = [0, 1/24, 1/12, 1/6];



%% Trial timing parameters.
%
% Trial duration - total time for each trial.
protocolParams.trialDuration = 24;

% There is a minimum time at the start of each trial where the background
% is presented.  Then the actual trial start time is chosen based on a
% random draw from the jitter parameters.
protocolParams.trialBackgroundTimeSec = 0;                 % Time background is on before stimulus can start
protocolParams.trialMinJitterTimeSec = 0;                  % Minimum time after background Time before step
protocolParams.trialMaxJitterTimeSec = 0;                  % Phase shifts in seconds

% Set ISI time in seconds
protocolParams.isiTime = 0;

%% Attention task parameters
%
% Currently, if you have an attention event then all trial types
% must have the same duration, and the attention event duration
% must match the trial duration.  These constraints could be relaxed
% by making the attentionSegmentDuration part of the trialType parameter
% set and by generalizing the way attention event information is generated
% within routine InitializeBlockStructArray.
%
% Also note that we assume that the dimming is visible when presented at
% any moment within any trial, even if the contrast is zero on that trial
% or it is a minimum contrast decrement, etc.  Would have to worry about how
% to handle this if that assumption is not valid.
protocolParams.attentionTask = true;
protocolParams.attentionSegmentDuration = 24;
protocolParams.attentionEventDuration = 0.5;
protocolParams.attentionMarginDuration = 1;
protocolParams.attentionEventProb = 1/10000;
protocolParams.postAllTrialsWaitForKeysTime = 1;




%% Make modulations
%
% Make temporal waveform for my experiment
temporalParams = OLWaveformParamsFromName('MaxContrastSinusoid');
temporalParams.stimulusDuration = 24; % in sec
temporalParams.timeStep = 1/100;

% First make a modulation with 0% contrast and thus no flicker
temporalParams.frequency = 1; % Give this some non-zero frequency so it doesn't break
waveforms = OLWaveformFromParams(temporalParams);
modulationsCellArray{1} = OLAssembleModulation([modBackground, modDirection], [ones(size(waveforms)); zeros(size(waveforms))]);

% Now loop through the non-zero frequencies
for ii = 2:length(frequencySet)

    % Create maximum flicker at this frequency
    temporalParams.frequency = frequencySet(ii);
    waveforms = OLWaveformFromParams(temporalParams);
    flickerModulation = OLAssembleModulation([modBackground, modDirection],[ones(size(waveforms)); waveforms]);

    % Store the modulation in the cell arrray
    modulationsCellArray{ii} = flickerModulation;

end

% Now create a final entry that is the background state to be used before
% and after the experiment
[backgroundState.backgroundStarts, backgroundState.backgroundStops] = OLPrimaryToStartsStops(modBackground.differentialPrimaryValues,modBackground.calibration);

% Assemble the three types into a single cell array
modulationsCellArray{end+1} = backgroundState;


%% Save modulations
modulationSavePath = fullfile(getpref('MRFlickerLDOG','modulationsBasePath'),protocolParams.observerID,protocolParams.todayDate);
if ~exist(modulationSavePath)
    mkdir(modulationSavePath)
end
modulationSaveName = fullfile(modulationSavePath,'modulationsPupil.mat');
save(modulationSaveName,'modulationsCellArray','temporalParams');


