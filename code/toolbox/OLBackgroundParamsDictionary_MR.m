function dictionary = OLBackgroundParamsDictionary_MR()
% Defines a dictionary with parameters for named nominal backgrounds
%
% Syntax:
%   dictionary = OLBackgroundParamsDictionary_MR()
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
%    None.
%
% Notes:
%    None.
%
% See also: 
%    OLBackgroundParams, OLBackgroundNomimalFromParams,
%    OLDirectionParamsDictionary,

% History:
%    03/31/18  dhb  Created from OneLightToolbox version. Remove
%                   alternateDictionaryFunc key/value pair, since this
%                   would be called as the result of that.
%    04/09/18  jv   created from OLApproach_Test version. Removed
%                   everything but LightFlux entry.

% Initialize dictionary
dictionary = containers.Map();

%% LightFlux_450_450_18
% Background for 1.8x (80% contrast) light flux bipolar modulation
%   Chrom x = .45, y = .45
%   Flux factor = 1.8 (80% contrast)
params = OLBackgroundParams_LightFluxChrom;
params.baseName = 'LightFlux';
params.lightFluxDesiredXY = [0.45,0.45];
params.lightFluxDownFactor = 1.8;
params.primaryHeadRoom = 0.005;
params.lambda = 0;
params.spdToleranceFraction = 0.005;
params.optimizationTarget = 'maxLum';
params.primaryHeadroomForInitialMax = 0.05;
params.maxScaleDownForStart = 1.8;
params.name = OLBackgroundNameFromParams(params);
if OLBackgroundParamsValidate(params)
    % All validations OK. Add entry to the dictionary.
    dictionary(params.name) = params;
end

end