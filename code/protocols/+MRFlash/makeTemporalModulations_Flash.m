function [modulationsCellArray,pulseParams] = makeTemporalModulations_Flash(lightFluxDirection,background,trialTypeParams,protocolParams)


%% Make modulations
% 
% Make temporal waveform for my experiment 
pulseParams = OLWaveformParamsFromName('MaxContrastSinusoid');
pulseParams.frequency = 16;
pulseParams.stimulusDuration = 12; % in sec
pulseParams.timeStep = 1/100;
[waveforms,timestep]=OLWaveformFromParams(pulseParams); 

%% Prepare modulations for each trial type
%
% This is code that has to understand about what is in the trialTypes
% structure.  ApproachEngine doesn't need to know, because here we produce
% primary values versus time (aka modulations).
for ii = 1:length(trialTypeParams.contrastLevels)
    lmsDirectionScaled = trialTypeParams.contrastLevels(ii) .* lightFluxDirection;
    modulationsCellArray{ii} = OLAssembleModulation([background, lmsDirectionScaled],[ones(size(waveforms)); waveforms]);
end

%% Get the background starts and stops
% the last entry need to to be a cell entry with the background starts and
% stops
index = length(modulationsCellArray) + 1;
[modulationsCellArray{index}.backgroundStarts, modulationsCellArray{index}.backgroundStops] = OLPrimaryToStartsStops(background.differentialPrimaryValues,background.calibration);

%% Save modulations
modulationSavePath = fullfile(getpref('MRCRF','modulationsBasePath'),protocolParams.observerID,protocolParams.todayDate);
if ~exist(modulationSavePath)
    mkdir(modulationSavePath)                          
end
modulationSaveName = fullfile(modulationSavePath,'modulations.mat');
save(modulationSaveName,'modulationsCellArray','pulseParams','protocolParams','lightFluxDirection');


