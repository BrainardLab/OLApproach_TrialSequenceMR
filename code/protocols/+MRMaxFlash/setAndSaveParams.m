function [protocolParams,modDirection,modBackground, ol, directions]  = setAndSaveParams(protocolParams)


% setAndSaveParams
%
% Description:
%   Define the parameters for the MRContrastResponseFunction protocol of the
%   OLApproach_TrialSequenceMR approach, and then invoke each of the
%   steps required to set up and run a session of the experiment.




% Number of trials
%
% Should be an integer multiple of number of trial types

% We are thinking here of 28, 12 second trials. Each trial is either the
% flashing lights or the dark, mirrors off state. The total acquisition
% time would be 336 seconds.
protocolParams.nTrials = 28;
protocolParams.contrastLevels = ones(1,protocolParams.nTrials);


%% Field size and pupil size.
%
% These are used to construct photoreceptors for validation for directions
% (e.g. light flux) where they are not available in the direction file.
% They are checked for consistency with direction parameters that specify
% these fields in OLAnalyzeDirectionCorrectedPrimaries.
% [* NOTE: DHB, MB: Need to fix up how these make it to validations.]
% [* NOTE: DHB, MB: Someday want to pull these out of background and direction
%    parameters altogether.]
observerParams.fieldSizeDegrees = 60;
observerParams.pupilDiameterMm = 8;
protocolParams.observerParams = observerParams;

%% Trial timing parameters.
%
% Trial duration - total time for each trial.
protocolParams.trialDuration = 12;

% There is a minimum time at the start of each trial where the background
% is presented.  Then the actual trial start time is chosen based on a
% random draw from the jitter parameters.
protocolParams.trialBackgroundTimeSec = 0;                 % Time background is on before stimulus can start
protocolParams.trialMinJitterTimeSec = 0;                  % Minimum time after background Time before step
protocolParams.trialMaxJitterTimeSec = 0;                  % Phase shifts in seconds

% Set ISI time in seconds
protocolParams.isiTime = 0;

%% Attention task parameters
%
% Currently, if you have an attention event then all trial types
% must have the same duration, and the attention event duration
% must match the trial duration.  These constraints could be relaxed
% by making the attentionSegmentDuration part of the trialType parameter
% set and by generalizing the way attention event information is generated
% within routine InitializeBlockStructArray.
%
% Also note that we assume that the dimming is visible when presented at
% any moment within any trial, even if the contrast is zero on that trial
% or it is a minimum contrast decrement, etc.  Would have to worry about how
% to handle this if that assumption is not valid.
protocolParams.attentionTask = true;
protocolParams.attentionSegmentDuration = 4;
protocolParams.attentionEventDuration = 0.5;
protocolParams.attentionMarginDuration = 1;
protocolParams.attentionEventProb = 1/100;
protocolParams.postAllTrialsWaitForKeysTime = 1;

%% OneLight parameters
protocolParams.boxName = 'BoxD';
protocolParams.calibrationType = 'BoxDRandomizedLongCableDStubbyEyePiece1_ND00';
protocolParams.takeCalStateMeasurements = true;
protocolParams.takeTempearatureMeasurements = true;

%% Validation parameters
protocolParams.nValidationsPerDirection = 5;

%% Information we prompt for and related
commandwindow;
protocolParams.observerID = GetWithDefault('>> Enter <strong>user name</strong>', 'HERO_xxxx');
protocolParams.observerAge = GetWithDefault('>> Enter <strong>observer age</strong>:', 32);
protocolParams.todayDate = datestr(now, 'yyyy-mm-dd');protocolParams.todayDate = datestr(now, 'yyyy-mm-dd');
protocolParams.sessionName = GetWithDefault('>> Enter <strong>session name</strong>:', 'session_1');



%% Parameters
%
% We'll use the new CIE XYZ functions.  These should match what is in the
% dictionary for the modulations.
whichXYZ = 'xyzCIEPhys10';

%% Define altnernate dictionary functions.
backgroundAlternateDictionary = 'OLBackgroundParamsDictionary_MR';
directionAlternateDictionary = 'OLDirectionParamsDictionary_MR';

%% Set calibration structure for OneLight.
% set up the calibrationStructure
% Check that prefs are as expected, as well as some parameter sanity checks/adjustments
if (~strcmp(getpref('OneLightToolbox','OneLightCalData'),getpref(protocolParams.approach,'OneLightCalDataPath')))
    error('Calibration file prefs not set up as expected for an approach');
end
cal = OLGetCalibrationStructure('CalibrationType',protocolParams.calibrationType,'CalibrationDate','latest');

%% Load cmfs
eval(['tempXYZ = load(''T_' whichXYZ ''');']);
eval(['T_xyz = SplineCmf(tempXYZ.S_' whichXYZ ',683*tempXYZ.T_' whichXYZ ',cal.describe.S);']);

%% Hello
fprintf('<strong>%s</strong>, observer age %d\n',protocolParams.calibrationType, protocolParams.observerAge);

%% Get native chromaticity for this cal
nativeXYZ = T_xyz*OLPrimaryToSpd(cal,0.5*ones(size(cal.computed.pr650M,2),1));
nativexyY = XYZToxyY(nativeXYZ);
fprintf('\tDevice native half on xyY: %0.3f %0.3f %0.1f\n',nativexyY(1),nativexyY(2),nativexyY(3));

%% Set target xyY for background.
%
% Here we use the native half one, but you can type in what you want.
targetxyY = nativexyY;
fprintf('\tUsing target background xyY: %0.3f %0.3f %0.01\n',targetxyY(1),targetxyY(2),targetxyY(3));


%% Open the session
%
% The call to OLSessionLog sets up info in protocolParams for where
% the logs go.
protocolParams = OLSessionLog(protocolParams,'OLSessionInit');
%% At this point, we have all the parameters for today.
%
% SAVE PARMETERS INTO Parameters DATA TREE
modulationSavePath = fullfile(getpref('MRMaxFlash','parameterFilesBasePath'),protocolParams.observerID,protocolParams.todayDate);
if ~exist(modulationSavePath)
    mkdir(modulationSavePath)
end

modulationSaveName = fullfile(modulationSavePath,'scanParamters.mat');
save(modulationSaveName,'cal','observerParams','protocolParams','trialTypeParams');


%% Open the OneLight
ol = OneLight('simulate',protocolParams.simulate.oneLight,'plotWhenSimulating',protocolParams.simulate.makePlots); drawnow;

%% Let user get the radiometer set up
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


lightFluxDirectionParams = OLDirectionParamsFromName('LightFlux_450_450_18','alternateDictionaryFunc','OLDirectionParamsDictionary_MR');
lightFluxDirectionParams.primaryHeadRoom = .00;
[modDirection, modBackground] = OLDirectionNominalFromParams(lightFluxDirectionParams, calibration,'alternateBackgroundDictionaryFunc','OLBackgroundParamsDictionary_MR');



modDirection.describe.observerAge = protocolParams.observerAge;
modDirection.describe.photoreceptorClasses = modDirection.describe.directionParams.photoreceptorClasses;
modDirection.describe.T_receptors = modDirection.describe.directionParams.T_receptors;


fprintf('*\tStarting Valiadtion: pre-corrections\n');

if ~(protocolParams.simulate.oneLight)
    takeTemperatureMeasurements = true;
else
    takeTemperatureMeasurements = false;
end

%takeTemperatureMeasurements = GetWithDefault('Take Temperature Measurements ?', false);
if (takeTemperatureMeasurements ~= true) && (takeTemperatureMeasurements ~= 1)
    takeTemperatureMeasurements = false;
else
    takeTemperatureMeasurements = true;
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



T_receptors = modDirection.describe.directionParams.T_receptors; % the T_receptors will be the same for each direction, so just grab one
for ii = 1:protocolParams.nValidationsPerDirection
    
    OLValidateDirection(modDirection, background, ol, radiometer, ...
        'receptors', T_receptors, 'label', 'precorrection', ...
        'temperatureProbe', theLJdev, ...
        'measureStateTrackingSPDs', measureStateTrackingSPDs);
    postreceptoralContrast = ComputePostreceptoralContrastsFromLMSContrasts(modDirection.describe.validation(ii).contrastActual(1:3,1));
    modDirection.describe.validation(ii).postreceptoralContrastActual = postreceptoralContrast;
    if ~(protocolParams.simulate.radiometer)
        save(fullfile(savePath, 'MaxMelDirection.mat'), 'MaxMelDirection');
        save(fullfile(savePath, 'MaxMelBackground.mat'), 'MaxMelBackground');
    end
end
%% Correction direction, validate post correction
fprintf('*\tStarting Corrections\n');
lightlevelScalar = OLMeasureLightlevelScalar(ol, cal, radiometer);

if ~(protocolParams.simulate.radiometer)
    % only correct if we're not simulating the radiometer
    nullDirection = OLDirection_unipolar.Null(calibration);
    OLCorrectDirection(background, nullDirection, ol, radiometer, ...
        'smoothness', 0.1, ...
        'temperatureProbe', theLJdev, ...
        'measureStateTrackingSPDs', measureStateTrackingSPDs);
    OLCorrectDirection(modDirection, background, ol, radiometer, ...
        'smoothness', 0.1, ...
        'temperatureProbe', theLJdev, ...
        'measureStateTrackingSPDs', measureStateTrackingSPDs);
    for ii = length(modDirection.describe.validation)+1:length(modDirection.describe.validation)+protocolParams.nValidationsPerDirection
        OLValidateDirection(modDirection, background, ol, radiometer, ...
            'receptors', T_receptors, 'label', 'postcorrection', ...
            'temperatureProbe', theLJdev, ...
            'measureStateTrackingSPDs', measureStateTrackingSPDs);
        postreceptoralContrast = ComputePostreceptoralContrastsFromLMSContrasts(modDirection.describe.validation(ii).contrastActual(1:3,1));
        modDirection.describe.validation(ii).postreceptoralContrastActual = postreceptoralContrast;
        if ~(protocolParams.simulate.radiometer)
            
            save(fullfile(savePath, 'MaxMelDirection.mat'), 'MaxMelDirection');
            save(fullfile(savePath, 'MaxMelBackground.mat'), 'MaxMelBackground');
        end
    end
end



%% Save Corrected Primaries:
correctedSavePath = fullfile(getpref('MRMaxFlash','DirectionCorrectedPrimariesBasePath'),protocolParams.observerID,protocolParams.todayDate);
if ~exist(correctedSavePath)
    mkdir(correctedSavePath)
end
modulationSaveName = fullfile(correctedSavePath,'correctedPrimaries.mat');
save(modulationSaveName,'MaxMelDirection','MaxMelBackground');



%% Close PR-670
if exist('radiometer', 'var')
    try
        radiometer.shutDown
    end
end

