% RunMRContrastResponseFunction
%
% Description:
%   Define the parameters for the MRContrastResponseFunction protocol of the
%   OLApproach_TrialSequenceMR approach, and then invoke each of the
%   steps required to set up and run a session of the experiment.

% History:
%  06/28/17  dhb  Added first history comment.
%            dhb  Move params.photoreceptorClasses into the dictionaries.
%            dhb  Move params.useAmbient into the dictionaries.
%  04/05/18  dhb, mb  A lot of stuff happened that no one wrote here.  Now
%                 starting up again.

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
protocolParams.simulate.oneLight = true;
protocolParams.simulate.makePlots = false;
protocolParams.simulate.radiometer = true;

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
trialTypeParams.contrastLevels = [0.8, 0.4, 0.2, 0.1, 0.05, 0.0];

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
LightFluxDirectionParams = OLDirectionParamsFromName('LightFlux_450_450_18','alternateDictionaryFunc','OLDirectionParamsDictionary_MR');
LightFluxDirectionParams.primaryHeadRoom = .00;
[LightFluxDirection, background] = OLDirectionNominalFromParams(LightFluxDirectionParams, calibration,'alternateBackgroundDictionaryFunc','OLBackgroundParamsDictionary_MR');

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
LMSDirectionParams = OLDirectionParamsFromName('MaxLMS_unipolar_275_60_667');
LMSDirection = OLDirectionNominalFromParams(LMSDirectionParams, calibration, 'observerAge', protocolParams.observerAge);
receptors = LMSDirection.describe.directionParams.T_receptors;

preCorrectionValidation = OLValidateDirection(LightFluxDirection,background,ol,radiometer,'receptors', receptors, 'label', 'pre-correction');





%% Correction direction, validate post correction
OLCorrectDirection(LightFluxDirection,background,ol,radiometer);
postCorrectionValidation = OLValidateDirection(LightFluxDirection,background,ol,radiometer,'receptors', receptors, 'label', 'post-correction');





%% Make modulations
% 
% Make temporal waveform for my experiment 
pulseParams = OLWaveformParamsFromName('MaxContrastSinusoid');
pulseParams.frequency = 2;
pulseParams.stimulusDuration = 12; % in sec
pulseParams.timeStep = 1/60;
[waveforms,timestep]=OLWaveformFromParams(pulseParams); 

%% Prepare modulations for each trial type
%
% This is code that has to understand about what is in the trialTypes
% structure.  ApproachEngine doesn't need to know, because here we produce
% primary values versus time (aka modulations).
for ii = 1:length(trialTypeParams.contrastLevels)
    lmsDirectionScaled = trialTypeParams.contrastLevels(ii) .* LightFluxDirection;
    modulationsCellArray{ii} = OLAssembleModulation([background, LightFluxDirection],[ones(size(waveforms)); waveforms]);
end

%% Get the background starts and stops
% the last entry need to to be a cell entry with the background starts and
% stops
index = length(modulationsCellArray) + 1;
[modulationsCellArray{index}.backgroundStarts, modulationsCellArray{index}.backgroundStops] = OLPrimaryToStartsStops(background.differentialPrimaryValues,background.calibration);

%% Save modulations
modulationSavePath = fullfile(getpref('MRContrastResponseFunction','modulationsBasePath'),protocolParams.observerID,protocolParams.todayDate);
if ~exist(modulationSavePath)
    mkdir(modulationSavePath)                          
end
modulationSaveName = fullfile(modulationSavePath,'modulations.mat');
save(modulationSaveName,'modulationsCellArray','pulseParams','protocolParams','lmsDirection');



%% Run experiment
%
% Part of a protocol is the desired number of scans.  Calling the Experiment routine
% is for one scan.

% Set trial sequence.  Possibly it goes into Experiment.
ApproachEngine(ol,protocolParams,modulationsCellArray,pulseParams,'acquisitionNumber',[],'verbose',protocolParams.verbose);

%% Let user get the radiometer set up and do post-experiment validation
%
% Some sort of logging and ke
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
OLValidateDirection(LightFluxDirection,background,ol,radiometer,'receptors', receptors, 'label', 'post-experiment');