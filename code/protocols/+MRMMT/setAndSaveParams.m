function [protocolParams,trialTypeParams,MaxMelDirection,MaxMelBackground, ol, directions]  = setAndSaveParams(protocolParams)


% setAndSaveParams
%
% Description:
%   Define the parameters for the MRContrastResponseFunction protocol of the
%   OLApproach_TrialSequenceMR approach, and then invoke each of the
%   steps required to set up and run a session of the experiment.



%% Trial type information.

trialTypeParams.contrastLevels = [1];

% Number of trials
%
% Should be an integer multiple of number of trial types
protocolParams.nTrials = 24;
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
protocolParams.trialDuration = 4;

% There is a minimum time at the start of each trial where
% the background is presented.  Then the actual trial
% start time is chosen based on a random draw from
% the jitter parameters.
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
protocolParams.attentionEventProb = 2/3;
protocolParams.postAllTrialsWaitForKeysTime = 1;

%% OneLight parameters
protocolParams.boxName = 'BoxD';
protocolParams.calibrationType = 'BoxDRandomizedLongCableDStubbyEyePiece1_ND00';
protocolParams.takeCalStateMeasurements = true;
protocolParams.takeTempearatureMeasurements = true;

%% Validation parameters
% [* NOTE: DHB, MB: Need a pre-reg document. We have a standard that we use
%    with respect to validations.  Ask Harry for the language.]
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
backgroundAlternateDictionary = 'MRMMT.OLBackgroundParamsDictionary_MaxMel';
directionAlternateDictionary = 'MRMMT.OLDirectionParamsDictionary_MaxMel';

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
modulationSavePath = fullfile(getpref('MRMMT','parameterFilesBasePath'),protocolParams.observerID,protocolParams.todayDate);
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

%% Make a background of specified luminance and chromaticity
%

MaxMelBackgroundParams = OLDirectionParamsFromName('MaxMel_chrom_unipolar_600_80_4000', ...
    'alternateDictionaryFunc', directionAlternateDictionary);



%% Get direction base parameters.
%
MaxMelParams = OLDirectionParamsFromName('MaxMel_chrom_unipolar_600_80_4000', 'alternateDictionaryFunc', directionAlternateDictionary);
[ MaxMelDirection, MaxMelBackground ] = OLDirectionNominalFromParams(MaxMelParams, cal, 'observerAge',protocolParams.observerAge, 'alternateBackgroundDictionaryFunc', backgroundAlternateDictionary);
MaxMelDirection.describe.observerAge = protocolParams.observerAge;
MaxMelDirection.describe.photoreceptorClasses = MaxMelDirection.describe.directionParams.photoreceptorClasses;
MaxMelDirection.describe.T_receptors = MaxMelDirection.describe.directionParams.T_receptors;


%% Report on nominal contrasts we obtained
% Get receptor sensitivities used, so that we can get cone contrasts out below.
receptorStrings = MaxMelDirection.describe.directionParams.photoreceptorClasses;
fieldSizes = [MaxMelDirection.describe.directionParams.fieldSizeDegrees, MaxMelDirection.describe.directionParams.fieldSizeDegrees, MaxMelDirection.describe.directionParams.fieldSizeDegrees, MaxMelDirection.describe.directionParams.fieldSizeDegrees];
protocolParams.receptors = GetHumanPhotoreceptorSS(MaxMelDirection.calibration.describe.S,receptorStrings,fieldSizes,protocolParams.observerAge,6,[],[]);

directions{1} = 'MaxMel_chrom_unipolar_600_80_4000';
% Loop and report
for dd = 1:length(directions)
    % Hello for this direction
    fprintf('<strong>%s</strong>\n', directions{dd});
    
    % Get contrasts. Code assumes matched naming of direction and background objects,
    % so that the string substitution works to get the background object
    % from the direction object.
    direction = MaxMelDirection;
    background = MaxMelBackground;
    [~, excitations, excitationDiffs] = direction.ToDesiredReceptorContrast(background,protocolParams.receptors);
    
    % Grab the relevant contrast information from the OLDirection object an
    % and report. Keep pos and neg contrast explicitly separate. These
    % should match in magnitude but be flipped in sign.
    for j = 1:size(protocolParams.receptors,1)
        fprintf('  * <strong>%s, %0.1f degrees</strong>: contrast pos = %0.1f, neg = %0.1f%%\n',receptorStrings{j},fieldSizes(j),100*excitationDiffs(j,1)/excitations(j,1),100*excitationDiffs(j,2)/excitations(j,1));
    end
    
    % Chromaticity and luminance
    backgroundxyY = XYZToxyY(T_xyz*OLPrimaryToSpd(cal,background.differentialPrimaryValues));
    fprintf('\n');
    fprintf('   * <strong>Background x, y, Y</strong>: %0.3f, %0.3f, %0.1f cd/m2\n',backgroundxyY(1),backgroundxyY(2),backgroundxyY(3));
    
    fprintf('\n\n');
end

%% Save Nominal Primaries:
%nominalSavePath = fullfile(getpref('MRContrastResponseFunction','DirectionNominalBasePath'),protocolParams.observerID,protocolParams.todayDate);
% if ~exist(nominalSavePath)
%     mkdir(nominalSavePath)
% end
% modulationSaveName = fullfile(nominalSavePath,'nominalPrimaries.mat');
% save(modulationSaveName,'colorDirection','ConeDirectedBackground');

%% Validate pre-correction
% [* NOTE: DHB, MB: Ask Joris: a) Will this keep pre and post validations
%          straight? b) What is the idea about how we store this aspect of
%          the data.  Just write out the direciton and background objects
%          at this stage?]
% [* NOTE: JV: Reply: a) I've added the kwarg 'label', which can take any
%          string/charvector as label. I've named these 'pre-correction'
%          and 'post-correction'. The validation struct also stores the
%          actual (differential) primary values that it validated, so
%          that's another way to check whether validation is pre/post
%          correction.
%          b) Saving out the direction and background objects will save out
%          the validations stored in them as well. You can also extract the
%          validation struct from the object, or by taking it as an output
%          argument from OLValidateDirection.]
% [* NOTE: Add loop here for number of validations]


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



T_receptors = MaxMelDirection.describe.directionParams.T_receptors; % the T_receptors will be the same for each direction, so just grab one
for ii = 1:protocolParams.nValidationsPerDirection
    
    OLValidateDirection(MaxMelDirection, MaxMelBackground, ol, radiometer, ...
        'receptors', T_receptors, 'label', 'precorrection', ...
        'temperatureProbe', theLJdev, ...
        'measureStateTrackingSPDs', measureStateTrackingSPDs);
    postreceptoralContrast = ComputePostreceptoralContrastsFromLMSContrasts(MaxMelDirection.describe.validation(ii).contrastActual(1:3,1));
    MaxMelDirection.describe.validation(ii).postreceptoralContrastActual = postreceptoralContrast;
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
    OLCorrectDirection(MaxMelBackground, nullDirection, ol, radiometer, ...
        'smoothness', 0.1, ...
        'temperatureProbe', theLJdev, ...
        'measureStateTrackingSPDs', measureStateTrackingSPDs);
    OLCorrectDirection(MaxMelDirection, MaxMelBackground, ol, radiometer, ...
        'smoothness', 0.1, ...
        'temperatureProbe', theLJdev, ...
        'measureStateTrackingSPDs', measureStateTrackingSPDs);
    for ii = length(MaxMelDirection.describe.validation)+1:length(MaxMelDirection.describe.validation)+protocolParams.nValidationsPerDirection
        OLValidateDirection(MaxMelDirection, MaxMelBackground, ol, radiometer, ...
            'receptors', T_receptors, 'label', 'postcorrection', ...
            'temperatureProbe', theLJdev, ...
            'measureStateTrackingSPDs', measureStateTrackingSPDs);
        postreceptoralContrast = ComputePostreceptoralContrastsFromLMSContrasts(MaxMelDirection.describe.validation(ii).contrastActual(1:3,1));
        MaxMelDirection.describe.validation(ii).postreceptoralContrastActual = postreceptoralContrast;
        if ~(protocolParams.simulate.radiometer)
            
            save(fullfile(savePath, 'MaxMelDirection.mat'), 'MaxMelDirection');
            save(fullfile(savePath, 'MaxMelBackground.mat'), 'MaxMelBackground');
        end
    end
end



%% Save Corrected Primaries:
correctedSavePath = fullfile(getpref('MRMMT','DirectionCorrectedPrimariesBasePath'),protocolParams.observerID,protocolParams.todayDate);
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

