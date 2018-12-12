function [] = postExpValidation(protocolParams,ol,MaxMelDirection,MaxMelBackground)

%% Let user get the radiometer set up and do post-experiment validation
%
if protocolParams.simulate.radiometer
    radiometer = [];
else
    radiometerPauseDuration = 0;
    ol.setAll(true);
    commandwindow;
    fprintf('- Focus the radiometer and press enter to pause %d seconds and start measuring.\n', radiometerPauseDuration);
    input('');
    ol.setAll(false);
    pause(radiometerPauseDuration);
    radiometer = OLOpenSpectroRadiometerObj('PR-670');
end


if ~(protocolParams.simulate.oneLight)
    takeTemperatureMeasurements = false;
else
    takeTemperatureMeasurements = false;
end

%takeTemperatureMeasurements = GetWithDefault('Take Temperature Measurements ?', false);
if (takeTemperatureMeasurements ~= true) && (takeTemperatureMeasurements ~= 1)
    takeTemperatureMeasurements = false;
else
    takeTemperatureMeasurements = false;
end

if (takeTemperatureMeasurements)
    % Gracefully attempt to open the LabJack
    [takeTemperatureMeasurements, quitNow, theLJdev] = OLCalibrator.OpenLabJackTemperatureProbe(takeTemperatureMeasurements);
    if (quitNow)
        return;
    end
else
    theLJdev = [];
end
measureStateTrackingSPDs = true;



T_receptors = MaxMelDirection.describe.directionParams.T_receptors; % the T_receptors will be the same for each direction, so just grab one
for ii = length(MaxMelDirection.describe.validation)+1:length(MaxMelDirection.describe.validation)+protocolParams.nValidationsPerDirection
    
    OLValidateDirection(MaxMelDirection, MaxMelBackground, ol, radiometer, ...
        'receptors', T_receptors, 'label', 'postexperiment', ...
        'temperatureProbe', theLJdev, ...
        'measureStateTrackingSPDs', measureStateTrackingSPDs);
    postreceptoralContrast = ComputePostreceptoralContrastsFromLMSContrasts(MaxMelDirection.describe.validation(ii).contrastActual(1:3,1));
    MaxMelDirection.describe.validation(ii).postreceptoralContrastActual = postreceptoralContrast;
end



%% Save post experiment validations:
directionObjectSavePath = fullfile(getpref('MRMMT','DirectionObjectsBasePath'),protocolParams.observerID,[protocolParams.todayDate, '_' protocolParams.sessionName]);
if ~exist(directionObjectSavePath)
    mkdir(directionObjectSavePath)
end
directionSaveName = fullfile(directionObjectSavePath,'MaxMel.mat');
save(directionSaveName,'MaxMelDirection','MaxMelBackground');

%% Close PR-670
if exist('radiometer', 'var')
    try
        radiometer.shutDown
    end
end

end