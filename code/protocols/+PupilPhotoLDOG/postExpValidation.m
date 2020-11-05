function [] = postExpValidation(protocolParams,ol,LplusSDirection,LminusSDirection,RodMelDirection,LightFluxDirection,modBackground)

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


for ii = 1:protocolParams.nValidationsPerDirection   
    OLValidateDirection(LplusSDirection, modBackground, ol, radiometer, 'receptors', LplusSDirection.describe.directionParams.T_receptors, 'label', 'postexperiment');    
    OLValidateDirection(LminusSDirection, modBackground, ol, radiometer, 'receptors', LminusSDirection.describe.directionParams.T_receptors, 'label', 'postexperiment');    
    OLValidateDirection(RodMelDirection, modBackground, ol, radiometer, 'receptors', RodMelDirection.describe.directionParams.T_receptors, 'label', 'postexperiment');    
    OLValidateDirection(LightFluxDirection, modBackground, ol, radiometer, 'receptors', RodMelDirection.describe.directionParams.T_receptors, 'label', 'postexperiment');    
end


%% Save post experiment validations:
% save directionObjects
directionObjectsSavePath = fullfile(getpref('MRScotoLDOG', 'DirectionObjectsBasePath'), protocolParams.observerID,protocolParams.todayDate);
if ~exist(directionObjectsSavePath)
    mkdir(directionObjectsSavePath)
end

directionObjectSaveName = fullfile(directionObjectsSavePath,'directionObject.mat');
save(directionObjectSaveName,'LplusSDirection','LminusSDirection','RodMelDirection','LightFluxDirection','modBackground');

%% Close PR-670
if exist('radiometer', 'var')
    try
        radiometer.shutDown
    end
end