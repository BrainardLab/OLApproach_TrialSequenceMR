function [] = postExpValidation(protocolParams,ol,modDirection,modBackground)

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
   
    OLValidateDirection(modDirection, modBackground, ol, radiometer, 'label', 'postexperiment');
    
end



%% Save post experiment validations:
% save directionObjects
directionObjectsSavePath = fullfile(getpref('MRMaxFlash', 'DirectionObjectsBasePath'), protocolParams.observerID,protocolParams.todayDate);
if ~exist(directionObjectsSavePath)
    mkdir(directionObjectsSavePath)
end

directionObjectSaveName = fullfile(directionObjectsSavePath,'directionObject.mat');
save(directionObjectSaveName,'modDirection','modBackground');

%% Close PR-670
if exist('radiometer', 'var')
    try
        radiometer.shutDown
    end
end