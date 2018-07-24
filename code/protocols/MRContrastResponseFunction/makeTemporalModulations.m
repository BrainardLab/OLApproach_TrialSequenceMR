function [modulationsCellArray,pulseParams] = makeTemporalModulations(directedDirection,background,trialTypeParams,protocolParams)

if ~iscell(directedDirection)
    directedDirection{1} = directedDirection;
end

%% Make modulations
%
% Make temporal waveform for my experiment
pulseParams = OLWaveformParamsFromName('MaxContrastSinusoid');
pulseParams.frequency = 10;
pulseParams.stimulusDuration = 12; % in sec
pulseParams.timeStep = 1/100;
[waveforms,timestep]=OLWaveformFromParams(pulseParams);

for jj = 1:length(directedDirection)
    
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
modulationsCellArray = [modulationsCellArray , repmat({tempCell},4,1)]; 

%% Save modulations
modulationSavePath = fullfile(getpref('MRContrastResponseFunction','modulationsBasePath'),protocolParams.observerID,protocolParams.todayDate);
if ~exist(modulationSavePath)
    mkdir(modulationSavePath)
end
modulationSaveName = fullfile(modulationSavePath,'modulations.mat');
save(modulationSaveName,'modulationsCellArray','pulseParams','protocolParams','directedDirection');


