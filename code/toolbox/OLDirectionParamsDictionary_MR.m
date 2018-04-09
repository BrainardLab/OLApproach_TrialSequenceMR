function dictionary = OLDirectionParamsDictionary_MR()
% Defines a dictionary with parameters for named nominal directions
%
% Syntax:
%   dictionary = OLDirectionParamsDictionary_MR()
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
%    dictionary - Dictionary with all parameters for all desired directions
%
% Notes:
%    None.
%
% See also: 
%    OLBackgroundParamsDictionary

% History:
%    03/31/18  dhb  Created from OneLightToolbox version. Remove
%                   alternateDictionaryFunc key/value pair, since this
%                   would be called as the result of that.
%    04/09/18  jv   created from OLApproach_Test version. Removed
%                   everything but LightFlux entry.

%% Initialize dictionary
dictionary = containers.Map();

%% LightFlux_450_450_18
% Direction for 1.8x (80% contrast) light flux bipolar modulation
%   Chrom x = .45, y = .45
%   Flux factor = 1.8 (80% contrast)
params = OLDirectionParams_LightFluxChrom;
params.baseName = 'LightFlux';
params.polarType = 'bipolar';
params.lightFluxDesiredXY = [0.45,0.45];
params.lightFluxDownFactor = 1.8;
params.name = OLDirectionNameFromParams(params);
params.backgroundName = 'LightFlux_450_450_18';
if OLDirectionParamsValidate(params)
    % All validations OK. Add entry to the dictionary.
    dictionary(params.name) = params;
end

end