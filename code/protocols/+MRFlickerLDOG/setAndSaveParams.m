function [protocolParams,LplusSDirection,LminusSDirection,RodMelDirection,modBackground, ol]  = setAndSaveParams(protocolParams)


% setAndSaveParams
%
% Description:
%   Define the parameters for the MRContrastResponseFunction protocol of the
%   OLApproach_TrialSequenceMR approach, and then invoke each of the
%   steps required to set up and run a session of the experiment.




% Number of trials
%
% Should be an integer multiple of number of trial types

% We are thinking here of 36, 12 second trials. Each trial is either the
% flashing lights or the dark, mirrors off state. The total acquisition
% time would be 336 seconds.
protocolParams.nTrials = 36;
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
protocolParams.attentionSegmentDuration = 12;
protocolParams.attentionEventDuration = 0.5;
protocolParams.attentionMarginDuration = 1;
protocolParams.attentionEventProb = 1/10000;
protocolParams.postAllTrialsWaitForKeysTime = 1;

%% OneLight parameters
protocolParams.boxName = 'BoxC';
protocolParams.calibrationType = 'BoxCRandomizedLongCableAEyePiece2';
protocolParams.takeCalStateMeasurements = true;
protocolParams.takeTempearatureMeasurements = true;

%% Validation parameters
protocolParams.nValidationsPerDirection = 5;

%% Information we prompt for and related
commandwindow;
protocolParams.observerID = GetWithDefault('>> Enter <strong>user name</strong>', 'Nxxx');
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
% Here we use the native half on, but you can type in what you want.
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
modulationSavePath = fullfile(getpref('MRFlickerLDOG','parameterFilesBasePath'),protocolParams.observerID,protocolParams.todayDate);
if ~exist(modulationSavePath)
    mkdir(modulationSavePath)
end

modulationSaveName = fullfile(modulationSavePath,'scanParamters.mat');
save(modulationSaveName,'cal','observerParams','protocolParams');


%% Open the OneLight
ol = OneLight('simulate',protocolParams.simulate.oneLight,'plotWhenSimulating',protocolParams.simulate.makePlots); drawnow;

% Background is one-half full on (all mirrors on)
halfOnSettings = 0.5 .* OLDirection_unipolar.FullOn(cal);

% grab photoreceptors
S = cal.describe.S;
photoreceptorClasses = { 'LConeCanine', 'SConeCanine', 'Melanopsin', 'RodCanine'};

fieldSize = 27.5;
observerAge = 32;
pupilDiameter = 4.7;
lambdaMaxShift = [-5,9,0,0];

for ii = 1:length(photoreceptorClasses)
    T_receptors(ii,:) = MRFlickerLDOG.GetCaninePhotoreceptorSS(S,...
        photoreceptorClasses(ii),...
        fieldSize,...
        observerAge,...
        pupilDiameter,...
        lambdaMaxShift(ii));
end

% common direction params to all directions
directionParams = OLDirectionParams_Bipolar;
directionParams.pupilDiameterMm = pupilDiameter;
directionParams.fieldSizeDegrees = fieldSize;
directionParams.photoreceptorClasses = photoreceptorClasses;
directionParams.T_receptors = T_receptors;
directionParams.directionsYoked = 1;
directionParams.directionsYokedAbs = 1;



%% Create the L+S direction
directionParams.whichReceptorsToIgnore = [];
directionParams.whichReceptorsToIsolate = [1, 2];
directionParams.whichReceptorsToMinimize = [];
directionParams.modulationContrast = [0.35 0.35];
directionParams.primaryHeadRoom = 0.005;

% add common background to the direction
directionParams.background = halfOnSettings;

% Create this direction
[LplusSDirection, modBackground] = OLDirectionNominalFromParams(directionParams, cal);


%% Create the L-S direction
directionParams.whichReceptorsToIgnore = [];
directionParams.whichReceptorsToIsolate = [1, 2];
directionParams.whichReceptorsToMinimize = [];
directionParams.modulationContrast = [0.25 -0.25];
directionParams.primaryHeadRoom = 0.005;

% add common background to the direction
directionParams.background = halfOnSettings;

% Create this direction
[LminusSDirection, ~] = OLDirectionNominalFromParams(directionParams, cal);



%% Create the Rod+Mel direction
directionParams.whichReceptorsToIgnore = [];
directionParams.whichReceptorsToIsolate = [3, 4];
directionParams.whichReceptorsToMinimize = [];
directionParams.modulationContrast = [0.5 0.5];
directionParams.primaryHeadRoom = 0.005;

% add common background to the direction
directionParams.background = halfOnSettings;

% Create this direction
[RodMelDirection, ~] = OLDirectionNominalFromParams(directionParams, cal);



%% Perform pre-stimulus validation.
% Make spectroradiographic measurements prior to the experiment.
% Note that this will ultimately likely occur after stimulus correction
% (spectrum seeking or correction to contrast), but this step has not yet
% been implemented.
% Note also that this code as currently written will not say anything about
% contrast -- this requires the specification of photoreceptors, which has
% not been done.

% set up radiometer
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

% perform validations
for ii = 1:protocolParams.nValidationsPerDirection   
    OLValidateDirection(LplusSDirection, modBackground, ol, radiometer, 'receptors', T_receptors, 'label', 'preexperiment');    
    OLValidateDirection(LminusSDirection, modBackground, ol, radiometer, 'receptors', T_receptors, 'label', 'preexperiment');    
    OLValidateDirection(RodMelDirection, modBackground, ol, radiometer, 'receptors', T_receptors, 'label', 'preexperiment');    
end

% turn off radiometer
if exist('radiometer', 'var')
    try
        radiometer.shutDown
    end
end

% save directionObjects
directionObjectsSavePath = fullfile(getpref('MRFlickerLDOG', 'DirectionObjectsBasePath'), protocolParams.observerID,protocolParams.todayDate);
if ~exist(directionObjectsSavePath)
    mkdir(directionObjectsSavePath)
end

directionObjectSaveName = fullfile(directionObjectsSavePath,'directionObject.mat');
save(directionObjectSaveName,'LplusSDirection','LminusSDirection','RodMelDirection','modBackground');


end 