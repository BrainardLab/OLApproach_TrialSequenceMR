function [] = postExpValidation(numValidations,protocolParams,ol,directedDirection,background,directionTypes)

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


for jj = 1:length(directedDirection)
    for ii = 1:numValidations
        OLValidateDirection(directedDirection{jj},background,ol,radiometer,'receptors', protocolParams.receptors , 'label', ['post-experiment-', directionTypes{jj}]);
    end
end



%% Save post experiment validations:
correctedSavePath = fullfile(getpref('MRAGTC','DirectionCorrectedValidationBasePath'),protocolParams.observerID,protocolParams.todayDate);
if ~exist(correctedSavePath)
    mkdir(correctedSavePath)
end
modulationSaveName = fullfile(correctedSavePath,'postExpValidations.mat');
save(modulationSaveName,'directedDirection','background');

%% Close PR-670
if exist('radiometer', 'var')
    try
        radiometer.shutDown
    end
end