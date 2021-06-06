function [protocolParams,trialTypeParams,PhotoreceptorDirections,PhotoreceptorBackground, ol, directionTypes]  = setAndSaveParams(protocolParams)


% setAndSaveParams
%
% Description:
%   Define the parameters for the MRAGTC protocol of the
%   OLApproach_TrialSequenceMR approach, and then invoke each of the
%   steps required to set up and run a session of the experiment.


%% Trial type information.
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
trialTypeParams.contrastLevels = [1];
trialTypeParams.frequency = [2, 4, 1, 4, 0.0];
protocolParams.contrastLevels =  trialTypeParams.contrastLevels;

protocolParams.maxContrastPerDirection = [0.09,0.25,0.25,0.90,0]; 


% Number of trials
%
% Should be an integer multiple of number of trial types
protocolParams.nTrials = 25;

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
observerParams.pupilDiameterMm = 5; % Corresponds to 1 cd/m2 background
protocolParams.observerParams = observerParams;

%% Trial timing parameters.
%
% Trial duration - total time for each trial.
protocolParams.trialDuration = 8;

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
protocolParams.attentionSegmentDuration = protocolParams.trialDuration;
protocolParams.attentionEventDuration = 0.5;
protocolParams.attentionMarginDuration = protocolParams.trialDuration/6;
protocolParams.attentionEventProb = 3/24;
protocolParams.postAllTrialsWaitForKeysTime = 1;

%% OneLight parameters
protocolParams.boxName = 'BoxD';
protocolParams.calibrationType = 'BoxDRandomizedLongCableAStubbyEyePiece_ND00';


%% Validation parameters
protocolParams.nValidationsPerDirection = 5;

%% Information we prompt for and related
commandwindow;
protocolParams.observerID = GetWithDefault('>> Enter <strong>subject name</strong>', 'HERO_xxxx');
protocolParams.observerAge = GetWithDefault('>> Enter <strong>subject age</strong>:', 32);
protocolParams.todayDate = datestr(now, 'yyyy-mm-dd');
protocolParams.sessionName = GetWithDefault('>> Enter <strong>session name</strong>:', 'session_1');

%% Parameters
%
% We'll use the new CIE XYZ functions.  These should match what is in the
% dictionary for the modulations.
whichXYZ = 'xyzCIEPhys10';

%% Define altnernate dictionary functions.
backgroundAlternateDictionary = 'MRAGTC.OLBackgroundParamsDictionary_Color';
directionAlternateDictionary = 'MRAGTC.OLDirectionParamsDictionary_Color';

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
modulationSavePath = fullfile(getpref('MRAGTC','parameterFilesBasePath'),protocolParams.observerID,protocolParams.todayDate);
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
% Get basic parameters.  These ask for essentially no contrast and have
% very tight constraints on the desired chromaticity and luminance.
PhotoreceptorBackgroundParams = OLDirectionParamsFromName('ConeDirectedBackground', ...
    'alternateDictionaryFunc', directionAlternateDictionary);

% Make sure we are consistent about which XYZ functions we are using.
PhotoreceptorBackgroundParams.whichXYZ = whichXYZ;

% Set desired background xyY
PhotoreceptorBackgroundParams.desiredxy = targetxyY(1:2);
PhotoreceptorBackgroundParams.desiredLum = targetxyY(3);

% Get the background.  This also makes a light flux modulation, but we ignore that.
%
% Indeed, what we're doing here is overloading the function that can make a
% light flux modulation just to get a desired background. The particular
% parameters are asking for a very low contrast light flux modulation with
% specified background properties.
[~, PhotoreceptorBackground] = OLDirectionNominalFromParams(PhotoreceptorBackgroundParams, cal, ...
    'alternateBackgroundDictionaryFunc', backgroundAlternateDictionary);

%% Get direction base parameters.
%
% These get tweaked for different directions.
PhotoreceptorDirectedParams = OLDirectionParamsFromName('ConeDirected', ...
    'alternateDictionaryFunc', directionAlternateDictionary);
PhotoreceptorDirectedParams.photoreceptorClasses = {'LConeTabulatedAbsorbance','MConeTabulatedAbsorbance','SConeTabulatedAbsorbance','LConeTabulatedAbsorbance','MConeTabulatedAbsorbance','SConeTabulatedAbsorbance','Rods','Rods'};
PhotoreceptorDirectedParams.fieldSizeDegrees = [2 2 2 15 15 15 2 15];

%% Direction counter
nDirections = 0;

%% Make direction 1, L-M
%
% Make a copy of the base parameters and set contrasts for an
% L-M modulation.
%
% The contrast was chosen by hand to be the highest
% we can get in this direction. If you make it much larger, you will not
% get equal and opposite contrasts as desired.  One could automate the
% search for the max feasible contrast, but doing it by hand goes pretty
% quickly.
nDirections = nDirections+1;
directions{nDirections} = 'PhotoreceptorDirection1';
directionTypes{nDirections} = 'LminusM';
PhotoreceptorDirectedParams1 = PhotoreceptorDirectedParams;
maxContrast = protocolParams.maxContrastPerDirection(1);
PhotoreceptorDirectedParams1.modulationContrast = maxContrast.*[-1 1 -1 1];
PhotoreceptorDirectedParams1.whichReceptorsToIsolate = [1 2 4 5];
PhotoreceptorDirectedParams1.primaryHeadRoom = 0;

% Make direction. For contrast reporting to come out, we need some name matching
% between direction and background, which is why the background gets copied
% here.
PhotoreceptorBackground1 = PhotoreceptorBackground;
[PhotoreceptorDirection1] = OLDirectionNominalFromParams(PhotoreceptorDirectedParams1, cal, ...
    'observerAge',protocolParams.observerAge, ...
    'background',PhotoreceptorBackground1, ...
    'alternateBackgroundDictionaryFunc', backgroundAlternateDictionary);

%% Make direction 2, L+M+S
%
% Only need to rewrite key parameters
nDirections = nDirections+1;
directions{nDirections} = 'PhotoreceptorDirection2';
directionTypes{nDirections} = 'LMS';

% We say which cones we want at a target contrast in the whichReceptorsToIsolate field.
% The otherclasses get their contrasts pegged at zero. The indices refer to
% the order of cones specified above.
%
% Again, the contrast was chosen by hand.
PhotoreceptorDirectedParams2 = PhotoreceptorDirectedParams;
maxContrast = protocolParams.maxContrastPerDirection(2);
PhotoreceptorDirectedParams2.modulationContrast = maxContrast.*[1 1 1 1 1 1];
PhotoreceptorDirectedParams2.whichReceptorsToIsolate = [1 2 3 4 5 6];
PhotoreceptorDirectedParams2.primaryHeadRoom = 0;
PhotoreceptorBackground2 = PhotoreceptorBackground;
[PhotoreceptorDirection2] = OLDirectionNominalFromParams(PhotoreceptorDirectedParams2, cal, ...
    'observerAge',protocolParams.observerAge, ...
    'background',PhotoreceptorBackground2, ...
    'alternateBackgroundDictionaryFunc', backgroundAlternateDictionary);

%% Make direction 3, S isolating
%
% Only need to rewrite key parameters
nDirections = nDirections+1;
directions{nDirections} = 'PhotoreceptorDirection3';
directionTypes{nDirections} = 'S';

% We say which cones we want at a target contrast in the whichReceptorsToIsolate field.
% The otherclasses get their contrasts pegged at zero. The indices refer to
% the order of cones specified above.
%
% Again, the contrast was chosen by hand.
PhotoreceptorDirectedParams3 = PhotoreceptorDirectedParams;
maxContrast = protocolParams.maxContrastPerDirection(3);
PhotoreceptorDirectedParams3.modulationContrast = maxContrast.*[1 1];
PhotoreceptorDirectedParams3.whichReceptorsToIsolate = [3 6];
PhotoreceptorDirectedParams3.primaryHeadRoom = 0;
PhotoreceptorBackground3 = PhotoreceptorBackground;
[PhotoreceptorDirection3] = OLDirectionNominalFromParams(PhotoreceptorDirectedParams3, cal, ...
    'observerAge',protocolParams.observerAge, ...
    'background',PhotoreceptorBackground3, ...
    'alternateBackgroundDictionaryFunc', backgroundAlternateDictionary);

%% Make direction 4, Omni: L+M+S+rod
%
% Only need to rewrite key parameters
nDirections = nDirections+1;
directions{nDirections} = 'PhotoreceptorDirection4';
directionTypes{nDirections} = 'Omni';

% We say which cones we want at a target contrast in the whichReceptorsToIsolate field.
% The otherclasses get their contrasts pegged at zero. The indices refer to
% the order of cones specified above.
%
% Again, the contrast was chosen by hand.
PhotoreceptorDirectedParams4 = PhotoreceptorDirectedParams;
maxContrast = protocolParams.maxContrastPerDirection(4);
PhotoreceptorDirectedParams4.modulationContrast = maxContrast.*[1 1 1 1 1 1 1 1];
PhotoreceptorDirectedParams4.whichReceptorsToIsolate = [1 2 3 4 5 6 7 8];
PhotoreceptorDirectedParams4.primaryHeadRoom = 0;
PhotoreceptorBackground4 = PhotoreceptorBackground;
[PhotoreceptorDirection4] = OLDirectionNominalFromParams(PhotoreceptorDirectedParams4, cal, ...
    'observerAge',protocolParams.observerAge, ...
    'background',PhotoreceptorBackground4, ...
    'alternateBackgroundDictionaryFunc', backgroundAlternateDictionary);


%% Make direction 5, Zero contrast (and thus the unchanging background)
%
% Only need to rewrite key parameters
nDirections = nDirections+1;
directions{nDirections} = 'PhotoreceptorDirection5';
directionTypes{nDirections} = 'blank';

% We say which cones we want at a target contrast in the whichReceptorsToIsolate field.
% The otherclasses get their contrasts pegged at zero. The indices refer to
% the order of cones specified above.
%
% Again, the contrast was chosen by hand.
PhotoreceptorDirectedParams5 = PhotoreceptorDirectedParams;
maxContrast = protocolParams.maxContrastPerDirection(5);
PhotoreceptorDirectedParams5.modulationContrast = maxContrast.*[1 1 1 1 1 1];
PhotoreceptorDirectedParams5.whichReceptorsToIsolate = [1 2 3 4 5 6];
PhotoreceptorDirectedParams5.primaryHeadRoom = 0;
PhotoreceptorBackground5 = PhotoreceptorBackground;
[PhotoreceptorDirection5] = OLDirectionNominalFromParams(PhotoreceptorDirectedParams5, cal, ...
    'observerAge',protocolParams.observerAge, ...
    'background',PhotoreceptorBackground5, ...
    'alternateBackgroundDictionaryFunc', backgroundAlternateDictionary);


%% Report on nominal contrasts we obtained
% Get receptor sensitivities used, so that we can get cone contrasts out below.
receptorStrings = PhotoreceptorDirection1.describe.directionParams.photoreceptorClasses;
fieldSizes = PhotoreceptorDirection1.describe.directionParams.fieldSizeDegrees;
protocolParams.receptors = GetHumanPhotoreceptorSS(PhotoreceptorDirection1.calibration.describe.S,receptorStrings,fieldSizes,protocolParams.observerAge,6,[],[]);

% Loop and report
for dd = 1:length(directions)
    
    % Get contrasts. Code assumes matched naming of direction and
    % background objects, so that the string substitution works to get the
    % background object from the direction object.
    direction = eval(directions{dd});
    
    % Hello for this direction
    fprintf('<strong>%s</strong>\n', directionTypes{dd});

    background = eval(strrep(directions{dd},'Direction','Background'));
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
nominalSavePath = fullfile(getpref('MRAGTC','DirectioNominalBasePath'),protocolParams.observerID,protocolParams.todayDate);


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


%% Optional spectral correction
if protocolParams.performCorrection
    
    fprintf('*\tStarting Validation: pre-correction\n');
    
    for jj = 1:length(directions)
        for ii = 1:protocolParams.nValidationsPerDirection
            preCorrectionValidation = OLValidateDirection(eval(directions{jj}),PhotoreceptorBackground,ol,radiometer,'receptors', protocolParams.receptors, 'label', strcat(directionTypes{jj},'_pre-correction'));
        end
        fprintf('*\tValidation Done: pre-correction\n');
    end
    
    
    %% Correction direction, validate post correction
    fprintf('*\tStarting Corrections\n');
    lightlevelScalar = OLMeasureLightlevelScalar(ol, cal, radiometer);
    OLCorrectDirection(PhotoreceptorBackground,OLDirection_unipolar.Null(cal),ol,radiometer,...
        'smoothness', .01,...
        'lightlevelScalar',lightlevelScalar);
    for qq = 1:length(directions)
        OLCorrectDirection(eval(directions{qq}),PhotoreceptorBackground,ol,radiometer,...
            'receptors', protocolParams.receptors, ...
            'smoothness', .01,...
            'lightlevelScalar',lightlevelScalar);
        fprintf('*\tCorrection Done\n');
    end
    
end

fprintf('*\tStarting Validation: pre-experiment\n');
for mm = 1:length(directions)
    for kk = 1:protocolParams.nValidationsPerDirection
        postCorrectionValidation = OLValidateDirection(eval(directions{mm}),PhotoreceptorBackground,ol,radiometer,'receptors', protocolParams.receptors, 'label', strcat(directionTypes{mm},'_post-correction'));
    end
    fprintf('*\tValidation Done: post-experiment\n');
end


% Assemble the set of modulations
PhotoreceptorDirections = {PhotoreceptorDirection1,PhotoreceptorDirection2,PhotoreceptorDirection3,PhotoreceptorDirection4,PhotoreceptorDirection5};


%% Save Corrected Primaries:
correctedSavePath = fullfile(getpref('MRAGTC','DirectionCorrectedPrimariesBasePath'),protocolParams.observerID,protocolParams.todayDate);
if ~exist(correctedSavePath)
    mkdir(correctedSavePath)
end
modulationSaveName = fullfile(correctedSavePath,'correctedPrimaries.mat');
save(modulationSaveName,'PhotoreceptorDirections','PhotoreceptorBackground');


%% Close PR-670
if exist('radiometer', 'var')
    try
        radiometer.shutDown
    end
end

