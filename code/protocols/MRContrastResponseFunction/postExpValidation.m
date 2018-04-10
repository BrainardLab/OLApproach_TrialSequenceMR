function [] = postExpValidation(numValidations,protocolParams,ol,lightFluxDirection,background)

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

%% Get receptors from other direction
calibration = OLGetCalibrationStructure('CalibrationType',protocolParams.calibrationType);
lmsDirectionParams = OLDirectionParamsFromName('MaxLMS_unipolar_275_60_667');
lmsDirection = OLDirectionNominalFromParams(lmsDirectionParams, calibration, 'observerAge', protocolParams.observerAge);
receptors = lmsDirection.describe.directionParams.T_receptors;

for ii = 1:numValidations
    OLValidateDirection(lightFluxDirection,background,ol,radiometer,'receptors', receptors, 'label', 'post-experiment');
end