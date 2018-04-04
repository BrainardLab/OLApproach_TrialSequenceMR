% RunMRContrastResponseFunction
%
% Description:
%   Define the parameters for the MRContrastResponseFunction protocol of the
%   OLApproach_TrialSequenceMR approach, and then invoke each of the
%   steps required to set up and run a session of the experiment.

% 6/28/17  dhb  Added first history comment.
%          dhb  Move params.photoreceptorClasses into the dictionaries.
%          dhb  Move params.useAmbient into the dictionaries.

%% Clear
clear; close all;

%% Set the parameter structure here
%
% Who we are and what we're doing today
protocolParams.approach = 'OLApproach_TrialSequenceMR';
protocolParams.protocol = 'MRContrastResponseFunction';
protocolParams.protocolOutputName = 'CRF';
protocolParams.emailRecipient = 'jryan@mail.med.upenn.edu';
protocolParams.verbose = true;
protocolParams.simulate.oneLight = true;
protocolParams.simulate.makePlots = true;
protocolParams.simulate.radiometer = true;

% Contrasts to use, relative to the powerLevel = 1 modulation in the
% directions file.
protocolParams.trialTypeParams = [...
    struct('contrast',0.8) ...
    struct('contrast',0.4) ...
    struct('contrast',0.2) ...
    struct('contrast',0.1) ...
    struct('contrast',0.05) ...
    struct('contrast',0.0) ...
    ];

%% Field size and pupil size.
%
% These are used to construct photoreceptors for validation for directions
% (e.g. light flux) where they are not available in the direction file.
% They are checked for consistency with direction parameters that specify
% these fields in OLAnalyzeDirectionCorrectedPrimaries.
protocolParams.fieldSizeDegrees = 60;
protocolParams.pupilDiameterMm = 8;

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

%% Set trial sequence
%
% RECODE THIS SO IT WORKS BETTER!!!!!!!!!!!!!!!!!
%
% Modulation and direction indices match on each trial, so we just specify
% them once in a single array.
protocolParams.trialTypeOrder = [randperm(6),randperm(6),randperm(6),randperm(6)];
protocolParams.nTrials = length(protocolParams.trialTypeOrder);

%% OneLight parameters
protocolParams.boxName = 'BoxB';
protocolParams.calibrationType = 'BoxBRandomizedLongCableDStubby1_ND00';
protocolParams.takeCalStateMeasurements = true;        % ask david about this

%% Validation parameters
protocolParams.nValidationsPerDirection = 2; % talk to david about this

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

%% Open the session
%
% The call to OLSessionLog sets up info in protocolParams for where
% the logs go.
protocolParams = OLSessionLog(protocolParams,'OLSessionInit');

%% HERE WE NEED TO MAKE JUST THE NOMINAL BACKGROUNDS AND
% DIRECTIONS THAT WE ARE ABOUT TO USE, AND STORE IN APPROPRIATE
% DATA DIRECTORY. 
%

lmsDirectionParams = OLDirectionParamsFromName('MaxLMS_bipolar_275_60_667');
lmsDirectionParams.primaryHeadRoom = .00;
[lmsDirection, background] = OLDirectionNominalFromParams(lmsDirectionParams, calibration, 'observerAge', protocolParams.observerAge);


%% Validations
receptors = lmsDirection.describe.directionParams.T_receptors;
OLValidateDirection(lmsDirection,background,ol,radiometer,'receptors', receptors);

%% Corrections will go here at some point 
%validate after?

%% Make modulations
% make pulse for my experiment 
pulseParams = OLWaveformParamsFromName('MaxContrastSinusoid');
pulseParams.frequency = 8;
pulseParams.stimulusDuration = 12; % in sec
pulseParams.timeStep = 1/100;
[waveforms,timestep]=OLWaveformFromParams(pulseParams); 
modulation = OLAssembleModulation([background, lmsDirection],[ones(size(waveforms)); waveforms]);

m


%% Run experiment
%
% Part of a protocol is the desired number of scans.  Calling the Experiment routine
% is for one scan.
Experiment(ol,protocolParams,'acquisitionNumber',[],'verbose',protocolParams.verbose);

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

