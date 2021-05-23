function [modulationsCellArray,flickerParams] = makeTemporalModulations(directedDirection,background,trialTypeParams,protocolParams)

if ~iscell(directedDirection)
    directedDirection{1} = directedDirection;
end

%% Make modulations
%
% Define the waveform parameters common to all modulation directions
flickerParams = OLWaveformParamsFromName('MaxContrastSinusoid');
flickerParams.stimulusDuration = protocolParams.trialDuration;
flickerParams.timeStep = 1/100;

for jj = 1:length(directedDirection)
    
    % Update the flicker frequency for this direction
    flickerParams.frequency = trialTypeParams.frequency(jj);
    waveforms = OLWaveformFromParams(flickerParams);
    
    %% Prepare modulations for each trial type
    %
    % This is code that has to understand about what is in the trialTypes
    % structure.  ApproachEngine doesn't need to know, because here we produce
    % primary values versus time (aka modulations).
    for ii = 1:length(trialTypeParams.contrastLevels)
        ConeDirectionScaled = trialTypeParams.contrastLevels(ii) .* directedDirection{jj};
        modulationsCellArray{jj,ii} = OLAssembleModulation([background, ConeDirectionScaled],[ones(size(waveforms)); waveforms]);
    end
end

%% Get the background starts and stops
% the last entry needs to to be a cell entry with the background starts and
% stops
[tempCell.backgroundStarts, tempCell.backgroundStops] =OLPrimaryToStartsStops(background.differentialPrimaryValues,background.calibration);
modulationsCellArray = [modulationsCellArray , repmat({tempCell},length(directedDirection),1)]; 

%% Save modulations
modulationSavePath = fullfile(getpref('MRAGTC','modulationsBasePath'),protocolParams.observerID,protocolParams.todayDate);
if ~exist(modulationSavePath)
    mkdir(modulationSavePath)
end
modulationSaveName = fullfile(modulationSavePath,'modulations.mat');
save(modulationSaveName,'modulationsCellArray','flickerParams','protocolParams','directedDirection');


