function [protocolParams,trialTypeParams,lightFluxDirection,background, ol]  = setAndSaveParams()


% setAndSaveParams
%
% Description:
%   Define the parameters for the MRContrastResponseFunction protocol of the
%   OLApproach_TrialSequenceMR approach, and then invoke each of the
%   steps required to set up and run a session of the experiment.

% History:
%  06/28/17  mab  Attemting to split into scanner friendly funcitons.


%% Clear
clear; close all;

%% Set the parameter structure here
%
% Who we are and what we're doing today
protocolParams.approach = 'OLApproach_TrialSequenceMR';
protocolParams.protocol = 'MRContrastResponseFunction';
protocolParams.protocolOutputName = 'CRF';
protocolParams.emailRecipient = 'micalan@sas.upenn.edu';
protocolParams.verbose = true;
protocolParams.simulate.oneLight = false;
protocolParams.simulate.makePlots = false;
protocolParams.simulate.radiometer = false;

% Trial type information.
%
% A set of arrays of the same length that paired up 
% determine what primaries get generated for each
% trial type.
%
% This specification needs to be matched up to the code below that
% makes the modulations for each trial type.
%
% At present, we're just varying contrast for one direction.
% Max contrast is 80% so i am setting the scalars to get [80, 40, 20, 10,
% 5, 0]
trialTypeParams.contrastLevels = [1, 0.5, 0.25, 0.125, 0.0625, 0.0]; 

% Number of trials
%
% Should be an integer multiple of number of trial types
protocolParams.nTrials = 6;

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
protocolParams.attentionSegmentDuration = 12;
protocolParams.attentionEventDuration = 0.5;
protocolParams.attentionMarginDuration = 2;
protocolParams.attentionEventProb = 2/3;
protocolParams.postAllTrialsWaitForKeysTime = 1;

%% OneLight parameters
protocolParams.boxName = 'BoxD';
protocolParams.calibrationType = 'BoxDRandomizedLongCableBEyePiece2_ND01';
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
protocolParams.todayDate = datestr(now, 'yyyy-mm-dd');

%% Check that prefs are as expected, as well as some parameter sanity checks/adjustments
if (~strcmp(getpref('OneLightToolbox','OneLightCalData'),getpref(protocolParams.approach,'OneLightCalDataPath')))
    error('Calibration file prefs not set up as expected for an approach');
end
calibration = OLGetCalibrationStructure('CalibrationType',protocolParams.calibrationType);

%% Open the session
%
% The call to OLSessionLog sets up info in protocolParams for where
% the logs go.
protocolParams = OLSessionLog(protocolParams,'OLSessionInit');

%% At this point, we have all the parameters for today.
%
% SAVE PARMETERS INTO Parameters DATA TREE
modulationSavePath = fullfile(getpref('MRContrastResponseFunction','parameterFilesBasePath'),protocolParams.observerID,protocolParams.todayDate);
if ~exist(modulationSavePath)
    mkdir(modulationSavePath)                          
end
modulationSaveName = fullfile(modulationSavePath,'scanParamters.mat');
save(modulationSaveName,'calibration','observerParams','protocolParams','trialTypeParams');


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

%% Make background and directions that we are about to use
% 
% SAVE THESE IN NominalPrimaries DATA TREE
lightFluxDirectionParams = OLDirectionParamsFromName('LightFlux_450_450_18','alternateDictionaryFunc','OLDirectionParamsDictionary_MR');
lightFluxDirectionParams.primaryHeadRoom = .00;
[lightFluxDirection, background] = OLDirectionNominalFromParams(lightFluxDirectionParams, calibration,'alternateBackgroundDictionaryFunc','OLBackgroundParamsDictionary_MR');

%% Save Nominal Primaries: 
nominalSavePath = fullfile(getpref('MRContrastResponseFunction','DirectioNominalBasePath'),protocolParams.observerID,protocolParams.todayDate);
if ~exist(nominalSavePath)
    mkdir(nominalSavePath)                          
end
modulationSaveName = fullfile(nominalSavePath,'nominalPrimaries.mat');
save(modulationSaveName,'lightFluxDirection','background');


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

% Get some receptors, clunky but works
lmsDirectionParams = OLDirectionParamsFromName('MaxLMS_unipolar_275_60_667');
lmsDirection = OLDirectionNominalFromParams(lmsDirectionParams, calibration, 'observerAge', protocolParams.observerAge);
receptors = lmsDirection.describe.directionParams.T_receptors;

for ii = 1:protocolParams.nValidationsPerDirection
    preCorrectionValidation = OLValidateDirection(lightFluxDirection,background,ol,radiometer,'receptors', receptors, 'label', 'pre-correction');
end

%% Correction direction, validate post correction
OLCorrectDirection(lightFluxDirection,background,ol,radiometer);

for jj = 1:protocolParams.nValidationsPerDirection
    postCorrectionValidation = OLValidateDirection(lightFluxDirection,background,ol,radiometer,'receptors', receptors, 'label', 'post-correction');
end

%% Save Corrected Primaries: 
nominalSavePath = fullfile(getpref('MRContrastResponseFunction','DirectionCorrectedPrimariesBasePath'),protocolParams.observerID,protocolParams.todayDate);
if ~exist(nominalSavePath)
    mkdir(nominalSavePath)                          
end
modulationSaveName = fullfile(nominalSavePath,'correctedPrimaries.mat');
save(modulationSaveName,'lightFluxDirection','background');


%% Close PR-670
if exist('radiometer', 'var')
   try
       radiometer.shutDown
   end
end

