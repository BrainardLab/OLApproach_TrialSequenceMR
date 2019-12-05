function [modulationsCellArray,temporalParams] = makeTemporalModulations(modDirection,modBackground, protocolParams)


frequencySet = [0, 4, 8, 16, 32, 64];

%% Make modulations
%
% Make temporal waveform for my experiment
temporalParams = OLWaveformParamsFromName('MaxContrastSinusoid');
temporalParams.stimulusDuration = 12; % in sec
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
modulationSaveName = fullfile(modulationSavePath,'modulations.mat');
save(modulationSaveName,'modulationsCellArray','temporalParams');


