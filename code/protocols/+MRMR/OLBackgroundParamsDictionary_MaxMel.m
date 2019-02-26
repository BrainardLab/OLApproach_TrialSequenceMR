function dictionary = OLBackgroundParamsDictionary(varargin)
% Defines a dictionary with parameters for named nominal backgrounds
%
% Syntax:
%   dictionary = OLBackgroundParamsDictionary()
%
% Description:
%    Define a dictionary of named backgrounds of modulation, with
%    corresponding nominal parameters.
%
% Inputs:
%    None.
%
% Outputs:
%    dictionary         -  Dictionary with all parameters for all desired
%                          backgrounds
%
% Optional key/value pairs:
%    'alternateDictionaryFunc' - String with name of alternate dictionary
%                          function to call. This must be a function on the
%                          path. Default of empty results in using this
%                          function.
%
% Notes:
%    * TODO:
%          i) add type 'BackgroundHalfOn' - Primaries set to 0.5;
%          ii) add type 'BackgroundEES' - Background metameric to an equal 
%              energy spectrum, scaled in middle of gamut.
%
% See also: 
%    OLBackgroundParams, OLDirectionParamsDictionary.

% History:
%    06/28/17  dhb  Created from direction version.
%    06/28/18  dhb  backgroundType -> backgroundName. Use names of routine 
%                   that creates backgrounds.
%              dhb  Add name field.
%              dhb  Bring in params.photoreceptorClasses.  These go with 
%                   directions/backgrounds.
%              dhb  Bring in params.useAmbient.  This goes with directions/
%                   backgrounds.
%    06/29/18  dhb  More extended names to reflect key parameters, so that 
%                   protocols can check
%    07/19/17  npc  Added a type for each background. For now, there is 
%                   only one type: 'basic'. 
%                   Defaults and checking are done according to type. 
%                   params.photoreceptorClasses is now a cell array.
%    07/22/17  dhb  No more modulationDirection field.
%    01/25/18  jv   Extract default params generation, validation.
%    02/07/18  jv   Updated to use OLBackgroundParams objects
%    03/26/18  jv, dhb Fix type in modulationContrast field of
%                   LMSDirected_LMS_275_60_667.
%    03/31/18  dhb  Add alternateDictionaryFunc key/value pair.
%              dhb  Delete obsolete notes and see alsos.
%    04/09/18  dhb  Removing light flux parameters. Use a local dictionary!

% Parse input
p = inputParser;
p.KeepUnmatched = true;
p.addParameter('alternateDictionaryFunc','',@ischar);
p.parse(varargin{:});

% Check for alternate dictionary, call if so and then return.
% Otherwise this is the dictionary function and we execute it.
% The alternate function must be on the path.
if (~isempty(p.Results.alternateDictionaryFunc))
    dictionaryFunction = str2func(sprintf('@%s',p.Results.alternateDictionaryFunc));
    dictionary = dictionaryFunction();
    return;
end

% Initialize dictionary
dictionary = containers.Map();


%% MelDirected_chrom_275_60_400
% Background to allow maximum unipolar contrast Mel modulations
%   Field size: 27.5 deg
%   Pupil diameter: 6 mm
%   Unipolar contrast: 400%
params = OLBackgroundParams_Optimized;
params.baseName = 'MelDirected_chrom';
params.baseModulationContrast = 4;
params.fieldSizeDegrees = 60;
params.pupilDiameterMm = 8;
params.photoreceptorClasses = {'LConeTabulatedAbsorbance','MConeTabulatedAbsorbance','SConeTabulatedAbsorbance','Melanopsin'};

% These are the options that go to OLPrimaryInvSolveChrom
params.desiredxy = [0.5964,0.3813];
%params.desiredLum = 315;
params.whichXYZ = 'xyzCIEPhys10';
params.targetContrast = [0 0 0 params.baseModulationContrast];
params.search.primaryHeadroom = 0.003;
params.search.primaryTolerance = 1e-6;
params.search.checkPrimaryOutOfRange = true;
params.search.lambda = 0;
params.search.whichSpdToPrimaryMin = 'leastSquares';
params.search.chromaticityTolerance = 0.03;
params.search.lumToleranceFraction = 0.1;
params.search.optimizationTarget = 'receptorContrast';
params.search.primaryHeadroomForInitialMax = 0.003;
params.search.maxSearchIter = 3000;
params.search.verbose = false;

params.name = OLBackgroundNameFromParams(params);
if OLBackgroundParamsValidate(params)
    dictionary(params.name) = params;
end

%% LMSDirected_chrom_600_80_2000
% Background to allow maximum unipolar contrast Mel modulations
%   Field size: 27.5 deg
%   Pupil diameter: 6 mm
%   Unipolar contrast: 400%
params = OLBackgroundParams_Optimized;
params.baseName = 'LMSDirected_chrom';
params.baseModulationContrast = 2;
params.fieldSizeDegrees = 60;
params.pupilDiameterMm = 8;
params.photoreceptorClasses = {'LConeTabulatedAbsorbance','MConeTabulatedAbsorbance','SConeTabulatedAbsorbance','Melanopsin'};

% These are the options that go to OLPrimaryInvSolveChrom
params.desiredxy = [0.574, 0.364];
%params.desiredLum = 161.1;
params.whichXYZ = 'xyzCIEPhys10';
params.targetContrast = [params.baseModulationContrast params.baseModulationContrast params.baseModulationContrast 0];
params.search.primaryHeadroom = 0.003;
params.search.primaryTolerance = 1e-6;
params.search.checkPrimaryOutOfRange = true;
params.search.lambda = 0;
params.search.whichSpdToPrimaryMin = 'leastSquares';
params.search.chromaticityTolerance = 0.03;
params.search.lumToleranceFraction = 0.1;
params.search.optimizationTarget = 'receptorContrast';
params.search.primaryHeadroomForInitialMax = 0.003;
params.search.maxSearchIter = 3000;
params.search.verbose = false;

params.name = OLBackgroundNameFromParams(params);
if OLBackgroundParamsValidate(params)
    dictionary(params.name) = params;
end



end