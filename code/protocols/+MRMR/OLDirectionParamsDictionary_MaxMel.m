function dictionary = OLDirectionParamsDictionary_MaxMel(varargin)
% Defines a dictionary with parameters for named nominal directions
%
% Syntax:
%   dictionary = OLDirectionParamsDictionary()
%
% Description:
%    Define a dictionary of named directions of modulation, with
%    corresponding nominal parameters. Types of directions, and their
%    corresponding fields, are defined in OLDirectionParamsDefaults,
%    and validated by OLDirectionParamsValidate.
%
% Inputs:
%    None.
%
% Outputs:
%    dictionary - dictionary with all parameters for all desired directions
%
% Optional key/value pairs:
%    'alternateDictionaryFunc' - String with name of alternate dictionary
%                          function to call. This must be a function on the
%                          path. Default of empty results in using this
%                          function.
%
% Notes:
%    None.
%
% See also: OLBackgroundParamsDictionary

% History:
%    06/22/17  npc  Wrote it. 06/28/18  dhb  backgroundType ->
%                   backgroundName. Use names of routine that creates
%                   backgrounds.
%              dhb  Add name field. 
%              dhb  Explicitly set contrasts in each case, rather than rely
%                   on defaults. 
%              dhb  Bring in params.photoreceptorClasses.  These go with
%                   directions/backgrounds. 
%              dhb  Bring in params.useAmbient. This goes with directions/
%                   backgrounds.
%    07/05/17  dhb  Bringing up to speed. :
%    07/19/17  npc  Added a type for each background. For now, there is 
%                   only one type: 'pulse'. Defaults and checking are done 
%                   according to type. params.photoreceptorClasses is now a
%                   cell array
%    07/22/17  dhb  No more modulationDirection field. 
%    07/23/17  dhb  Comment field meanings. 
%    07/27/17  dhb  Light flux entry 
%    01/24/18  dhb,jv  Finished adding support for modulations
%              jv   Renamed direction types: pulse is now unipolar,
%                   modulation is now bipolar
%	 01/25/18  jv	Extract defaults generation, validation of params.
%    02/15/18  jv   Parameters are now objects
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

%% Initialize dictionary
dictionary = containers.Map();





%% MaxMel_chrom_unipolar_600_80_4000
% Direction for maximum unipolar contrast Mel step
%   Field size: 27.5 deg
%   Pupil diameter: 6 mm
%   Unipolar contrast: 400%

params = OLDirectionParams_Unipolar;
params.baseName = 'MaxMel_chrom';
params.baseModulationContrast = 4;
params.fieldSizeDegrees = 60;
params.pupilDiameterMm = 8.0;
params.photoreceptorClasses = {'LConeTabulatedAbsorbance','MConeTabulatedAbsorbance','SConeTabulatedAbsorbance','Melanopsin'};
params.backgroundName = 'MelDirected_chrom_600_80_4000';

% These are the options that go to OLPrimaryInvSolveChrom
params.targetContrast = [0 0 0 params.baseModulationContrast];
params.search.primaryHeadroom = 0.003;
params.search.primaryTolerance = 1e-6;
params.search.checkPrimaryOutOfRange = true;
params.search.lambda = 0;
params.search.whichSpdToPrimaryMin = 'leastSquares';
params.search.chromaticityTolerance = 0.03;
params.search.lumToleranceFraction = 0.2;
params.search.optimizationTarget = 'receptorContrast';
params.search.primaryHeadroomForInitialMax = 0.003;
params.search.maxSearchIter = 3000;
params.search.verbose = false;

params.name = OLDirectionNameFromParams(params);
if OLDirectionParamsValidate(params)
    dictionary(params.name) = params;
end

%% LMS_chrom_unipolar_600_80_2000
% Direction for maximum unipolar contrast Mel step
%   Field size: 27.5 deg
%   Pupil diameter: 6 mm
%   Unipolar contrast: 400%

params = OLDirectionParams_Unipolar;
params.baseName = 'LMS_chrom';
params.baseModulationContrast = 2;
params.fieldSizeDegrees = 60;
params.pupilDiameterMm = 8.0;
params.photoreceptorClasses = {'LConeTabulatedAbsorbance','MConeTabulatedAbsorbance','SConeTabulatedAbsorbance','Melanopsin'};
params.backgroundName = 'LMSDirected_chrom_600_80_2000';

% These are the options that go to OLPrimaryInvSolveChrom
params.targetContrast = [params.baseModulationContrast params.baseModulationContrast params.baseModulationContrast 0];
params.search.primaryHeadroom = 0.003;
params.search.primaryTolerance = 1e-6;
params.search.checkPrimaryOutOfRange = true;
params.search.lambda = 0;
params.search.whichSpdToPrimaryMin = 'leastSquares';
params.search.chromaticityTolerance = 0.03;
params.search.lumToleranceFraction = 0.2;
params.search.optimizationTarget = 'receptorContrast';
params.search.primaryHeadroomForInitialMax = 0.003;
params.search.maxSearchIter = 3000;
params.search.verbose = false;

params.name = OLDirectionNameFromParams(params);
if OLDirectionParamsValidate(params)
    dictionary(params.name) = params;
end

end