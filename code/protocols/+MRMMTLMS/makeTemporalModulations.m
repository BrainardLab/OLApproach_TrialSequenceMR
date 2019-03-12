function [LMSModulationsCellArray, pulseParams] = makeTemporalModulations(LMSDirection,LMSBackground,protocolParams)



%% Make modulations
%
% Make temporal waveform for my experiment
pulseParams = OLWaveformParamsFromName('MaxContrastPulse'); % get generic pulse parameters
pulseParams.stimulusDuration = 2; % 2 second pulses
[PulseWaveform, pulseTimestep] = OLWaveformFromParams(pulseParams); 



LMS200PulseModulation = OLAssembleModulation([LMSBackground, LMSDirection], [ones(1, length(PulseWaveform)); PulseWaveform]);
LMSModulationsCellArray{1} = LMS200PulseModulation;

% also make a modulation with 0% contrast. this will be akin to just
% showing the background
LMSEmptyModulation = OLAssembleModulation([LMSBackground, LMSDirection], [ones(1, length(PulseWaveform)); zeros(1,length(PulseWaveform))]);


%% Get the background starts and stops
% the last entry needs to to be a cell entry with the background starts and
% stops

[tempCell.backgroundStarts, tempCell.backgroundStops] =OLPrimaryToStartsStops(LMSBackground.differentialPrimaryValues,LMSBackground.calibration);
LMSModulationsCellArray = [LMSModulationsCellArray, LMSEmptyModulation, repmat({tempCell},1,1)];

%% Save modulations
modulationSavePath = fullfile(getpref('MRMMTLMS','modulationsBasePath'),protocolParams.observerID,protocolParams.todayDate);
if ~exist(modulationSavePath)
    mkdir(modulationSavePath)
end
modulationSaveName = fullfile(modulationSavePath,'modulations.mat');
save(modulationSaveName,'LMSModulationsCellArray','pulseParams','protocolParams', 'LMSDirection');

end



