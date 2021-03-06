% RunMRMaxMelPulse
%
% Description:
%   Define the parameters for the MRMaxMelPulse protocol of the
%   OLApproach_TrialSequenceMR approach, and then invoke each of the
%   steps required to set up and run a session of the experiment.

% 6/28/17  dhb  Added first history comment.
%          dhb  Move params.photoreceptorClasses into the dictionaries.
%          dhb  Move params.useAmbient into the dictionaries.
% 09/20/17 dhb, gka, hmm  Copy over the CRF version and start editing.

%% Clear
clear; close all;

%% Set the parameter structure here
%
% Who we are and what we're doing today
protocolParams.approach = 'OLApproach_TrialSequenceMR';
protocolParams.protocol = 'MRMaxMelPulse';
protocolParams.protocolOutputName = 'MMP';
protocolParams.emailRecipient = 'jryan@mail.med.upenn.edu';
protocolParams.verbose = true;
protocolParams.simulate.oneLight = true;
protocolParams.simulate.makePlots = true;

%% Modulations used in this experiment
% 
% The set of arrays in this cell should have the same length, the entries get paired.
%
% Do not change the order of these directions without also fixing up
% the Demo and Experimental programs, which are counting on this order.
%
% The first trial type has its contrast set to 0 below, and is a blank
% trial, despite the fact that you might think it involved a modulation.
protocolParams.modulationNames = {'MaxContrast3sPulse' ...
    'MaxContrast3sPulse' ...
    'MaxContrast3sPulse' ...
    'MaxContrast3sPulse' ...
    };
                              
protocolParams.directionNames = {...
    'MaxMel_600_80_667'...
    'MaxMel_600_80_667'...
    'MaxLMS_600_80_667'...
    'LightFlux_540_380_50'...
    };

% Flag as to whether to run the correction/validation at all for each direction.
% You set to true here entries for the unique directions, so as not
% to re-correct the same file more than once. This saves time.
%
% Note that, for obscure and boring reasons, the first entry in this cell array
% needs to be true.  That should never be a problem, because we always want to
% validate each direction once and only once, and it is as easy to validate the
% first occurrance of a direction as a subsequent one.
protocolParams.doCorrectionAndValidationFlag = {...
    true, ...
    false, ...
    true, ...
    true, ...
    };

% This is also related to directions.  This determines whether the
% correction gets done using the radiometer (set to false) or just by
% simulation (set to true, just uses nominal spectra on each iteration of
% the correction.) Usually you will want all of these to be false, unless
% you've determined that for the particular box and directions you're
% working with you don't need the extra precision provided by spectrum
% correction.
protocolParams.correctBySimulation = [...
    false ...
    false ...
    false ...
    false ...
    ];

% Could add a validate by simulation flag here, if we ever get to a point
% where we want to trust the nominal spectra.

% Contrasts to use, relative to the powerLevel = 1 modulation in the
% directions file.
%
% Setting a contrast to 0 provides a blank trial type.
protocolParams.trialTypeParams = [...
    struct('contrast',0) ...
    struct('contrast',1) ...
    struct('contrast',1) ...
    struct('contrast',1) ...
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
protocolParams.trialDuration = 16;

% There is a minimum time at the start of each trial where
% the background is presented.  Then the actual trial
% start time is chosen based on a random draw from
% the jitter parameters.
protocolParams.trialBackgroundTimeSec = 0;
protocolParams.trialMinJitterTimeSec = 1;                  % Time before step
protocolParams.trialMaxJitterTimeSec = 3;                  % Phase shifts in seconds

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
protocolParams.attentionSegmentDuration = 16;
protocolParams.attentionEventDuration = 0.5;
protocolParams.attentionMarginDuration = 2;
protocolParams.attentionEventProb = 1;
protocolParams.postAllTrialsWaitForKeysTime = 1;
protocolParams.attentionEligibleTrialTypes = [1];

%% Set trial sequence
%
% Modulation and direction indices match on each trial, so we just specify
% them once in a single array.
nTrialTypes = length(protocolParams.modulationNames);
protocolParams.trialTypeOrder = [randperm(nTrialTypes),randperm(nTrialTypes),randperm(nTrialTypes),randperm(nTrialTypes)];
protocolParams.nTrials = length(protocolParams.trialTypeOrder);
      
%% OneLight parameters
protocolParams.boxName = 'BoxB';  
protocolParams.calibrationType = 'BoxBRandomizedLongCableDStubby1_ND00';
protocolParams.takeCalStateMeasurements = true;
protocolParams.takeTemperatureMeasurements = false;

% Validation parameters
protocolParams.nValidationsPerDirection = 2;

% Information we prompt for and related
commandwindow;
protocolParams.observerID = GetWithDefault('>> Enter <strong>user name</strong>', 'HERO_xxxx');
protocolParams.observerAgeInYrs = GetWithDefault('>> Enter <strong>observer age</strong>:', 32);
protocolParams.todayDate = datestr(now, 'yyyy-mm-dd');

%% Use these to test reporting on validation and spectrum seeking
%
% Spectrum Seeking: /MELA_data/Experiments/OLApproach_Psychophysics/DirectionCorrectedPrimaries/Jimbo/081117/session_1/...
% Validation: /MELA_data/Experiments/OLApproach_Psychophysics/DirectionValidationFiles/Jimbo/081117/session_1/...
% protocolParams.observerID = 'tired';
% protocolParams.observerAgeInYrs = 32;
% protocolParams.todayDate = '2017-09-01';
% protocolParams.sessionName = 'session_1';
% protocolParams.sessionLogDir = '/Users1/Dropbox (Aguirre-Brainard Lab)/MELA_data/Experiments/OLApproach_TrialSequenceMR/MRContrastResponseFunction/SessionRecords/michael/2017-09-01/session_1';
% protocolParams.fullFileName = '/Users1/Dropbox (Aguirre-Brainard Lab)/MELA_data/Experiments/OLApproach_TrialSequenceMR/MRContrastResponseFunction/SessionRecords/michael/2017-09-01/session_1/david_session_1.log';

%% Check that prefs are as expected, as well as some parameter sanity checks/adjustments
if (~strcmp(getpref('OneLightToolbox','OneLightCalData'),getpref(protocolParams.approach,'OneLightCalDataPath')))
    error('Calibration file prefs not set up as expected for an approach');
end

% Sanity check on modulations
if (length(protocolParams.modulationNames) ~= length(protocolParams.directionNames))
    error('Modulation and direction names cell arrays must have same length');
end

%% Open the OneLight
ol = OneLight('simulate',protocolParams.simulate.oneLight,'plotWhenSimulating',protocolParams.simulate.makePlots); drawnow;

%% Let user get the radiometer set up
radiometerPauseDuration = 0;
ol.setAll(true);
commandwindow;
fprintf('- Focus the radiometer and press enter to pause %d seconds and start measuring.\n', radiometerPauseDuration);
input('');
ol.setAll(false);
pause(radiometerPauseDuration);

%% Open the session
%
% The call to OLSessionLog sets up info in protocolParams for where
% the logs go.
protocolParams = OLSessionLog(protocolParams,'OLSessionInit');

%% Make the corrected modulation primaries
%
% Could add check to OLMakeDirectionCorrectedPrimaries that pupil and field size match
% in the direction parameters and as specified in protocol params here, if the former
% are part of the direction. Might have to pass protocol params down into the called
% routine. Could also do this in other routines below, I think.
OLMakeDirectionCorrectedPrimaries(ol,protocolParams,'verbose',protocolParams.verbose);

% This routine is mainly to debug the correction procedure, not particularly
% useful once things are humming along.  One would use it if the validations
% are coming out badly and it was necessary to track things down.
% OLCheckPrimaryCorrection(protocolParams);

%% Make the modulation starts and stops
OLMakeModulationStartsStops(protocolParams.modulationNames,protocolParams.directionNames, protocolParams,'verbose',protocolParams.verbose);

%% Validate direction corrected primaries prior to experiemnt
OLValidateDirectionCorrectedPrimaries(ol,protocolParams,'Pre');
OLAnalyzeDirectionCorrectedPrimaries(protocolParams,'Pre');

%% Run experiment
%
% Part of a protocol is the desired number of scans.  Calling the Experiment routine
% is for one scan.
ApproachEngine(ol,protocolParams,'acquisitionNumber',[],'verbose',protocolParams.verbose);

%% Let user get the radiometer set up
ol.setAll(true);
commandwindow;
fprintf('- Focus the radiometer and press enter to pause %d seconds and start measuring.\n', radiometerPauseDuration);
input('');
ol.setAll(false);
pause(radiometerPauseDuration);

%% Validate direction corrected primaries post experiment
OLValidateDirectionCorrectedPrimaries(ol,protocolParams,'Post');
OLAnalyzeDirectionCorrectedPrimaries(protocolParams,'Post');
