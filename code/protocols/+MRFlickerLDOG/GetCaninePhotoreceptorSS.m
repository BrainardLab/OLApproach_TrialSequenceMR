function [T_energyNormalized,T_quantalIsomerizations,nominalLambdaMax] = GetCaninePhotoreceptorSS(S, photoreceptorClasses, fieldSizeDegrees, ageInYears,...
    pupilDiameterMm, lambdaMaxShift, fractionPigmentBleached, vesselOxyFraction, vesselOverallThicknessUm)
% [T_energyNormalized,T_quantalIsomerizations,nominalLambdaMax] = GetHumanPhotoreceptorSS(S, photoreceptorClasses, fieldSizeDegrees, ageInYears, pupilDiameterMm,
%   lambdaMaxShift, fractionPigmentBleached, vesselOxyFraction, vesselOverallThicknessUm)
%
% Produces photopigment sensitivities that we often need, and allowing
% variation in age and lambda-max.  T_energyNormalized are the sensitivities
% in energy units, normalized to max of 1.  T_quantalIosmerizations are the
% probability of an isomerization for quantal unit input.
%
% If empty variables are passed for any of the following variables, defaults will be assumed.
%
% Input:
%   S (1x3)                         - Wavelength spacing.
%                                     Default: [380 2 201]
%   photoreceptorClasses (cell)     - Cell with names of photoreceptor classes.
%                                     Supported options: 'LConeTabulatedAbsorbance', 'MConeTabulatedAbsorbance', 'SConeTabulatedAbsorbance',
%                                                        'LConeTabulatedAbsorbance2Deg', 'MConeTabulatedAbsorbance2Deg', 'SConeTabulatedAbsorbance2Deg',
%                                                        'LConeTabulatedAbsorbance10Deg', 'MConeTabulatedAbsorbance10Deg', 'SConeTabulatedAbsorbance10Deg',
%                                                        'LConeTabulatedAbsorbancePenumbral', 'MConeTabulatedAbsorbancePenumbral', 'SConeTabulatedAbsorbancePenumbral',
%                                                        'Melanopsin',
%                                                        'Rods',
%                                                        'LConeSSNomogramLegacy', 'MConeSSNomogramLegacy','MConeSSNomogramLegacy'
%                                                        'LCone10DegTabulatedSS', 'MCone10DegTabulatedSS', 'SCone10DegTabulatedSS',
%                                                        'LCone2DegTabulatedSS', 'MCone2DegTabulatedSS', 'SCone2DegTabulatedSS'
%                                     Note: See below for a description of each of these options.
%                                     Default: {'LConeTabulatedAbsorbance' ; 'MConeTabulatedAbsorbance' ; 'SConeTabulatedAbsorbance'}
%   fieldSizeDegrees (1x1)          - Field size in degrees. Can be a
%                                     scalar or a vector with same length
%                                     as photoreceptorClasses. In this
%                                     case, each receptor sensitivity is
%                                     computed with the corresponding field
%                                     size. Default: 10
%   ageInYears (1x1)                - Observer age in years.
%                                     Default: 32
%   pupilDiameterMm (1x1)           - Pupil diameter in mm.
%                                     Default: 3
%   lambdaMaxShift                  - Shift of lambda-max.
%                                     Can be scalar, in which case same value is used for all classes.  Or a
%                                     vector of same length as photoreceptorClasses.
%                                     Default: 0
%   fractionPigmentBleached         - Fraction of pigment bleached.
%                                     Vector of same size as number of photoreceptor classes.
%                                     Default: 0 for each entry.
%   vesselOxyFraction               - Fraction of oxygenated blood assumed.
%                                     Default: 0.85
%   vesselOverallThicknessUm        - Thickness of vessel in um
%                                     Default: 5
% Output:
%   T_energyNormalized              - Spectral sensitivities in energy
%                                     units (normalized to max.).
%   T_quantaIsomerization           - Spectral sensitivities in quanta
%                                     units.  These may be used to compute
%                                     isomerizations from retinal illuminance
%   nominalLambdaMax                - Peak of photopigment absorption spectrum spectral sensitivities (no density taken into account).
%                                     This does not take any shift in lambdaMax applied into account.  In a a few cases it is sort
%                                     of made up because there was no explicit underlying absorption spectrum.
%
% NOTES:
%   A) The Penumbral variants take into account an estimate of the absorption spectrum of hemoglobin as seen through retinal
%   blood vessels.
%
%   B) Not all variants have a meaningful T_quantalIsomerizations variable returned.  When we don't have that sensitivity
%   easily, a vector of NaN's of the right size is returned instead.
%
%   C) The 'Legacy' versions are estimates that we used in some of our early work and that we now don't think are as good as the current ones.
%   They are still here because sometimes we need to figure out what we did in the past.
%
%   D) Passed fractionBleached numbers don't affect rod, melanopsin, or tabulated cone calculations.
%   We throw an error if any of these ever receives a non-zero value.  Also, you cannot use different fraction bleached values
%   for two different variants of the same cone class (e.g. 'LConeTabulatedAbsorbance' and 'LConeTabulatedAbsorbancePenumbral'). To
%   work around, make two seprate calls, each with the appropriate fraction bleached.
%
%   E) If you pass lambdaMaxShift as a scalar, the same value of lambdaMaxShift is applied to all classes computed within a single call to this function.
%   This seems unlikely to be a good behavior, but I am keeping it for backwards compatibility. You can now also pass lambdaMaxShift as a vector
%   to specify a different shift for each photoreceptor class, which seems more sensible.
%
%   F) Description of the possible photoreceptor classes
%
%   LMS cone fundamentals, calculated from the tabulated Stockman-Sharpe
%   absorbances. These are fully adjustable:
%       'LConeTabulatedAbsorbance', 'MConeTabulatedAbsorbance', 'SConeTabulatedAbsorbance'
%
%   LMS cone fundamentals, calculated from the tabulated Stockman-Sharpe
%   absorbances, but ignoring the 'field size' input parameter, and pegging it to 2 and 10 deg:, respectively.
%   These respect the age parameter but are not otherwise adjustable:
%       2 deg: 'LConeTabulatedAbsorbance2Deg', 'MConeTabulatedAbsorbance2Deg', 'SConeTabulatedAbsorbance2Deg'
%       10 deg: 'LConeTabulatedAbsorbance10Deg', 'MConeTabulatedAbsorbance10Deg', 'SConeTabulatedAbsorbance10Deg'
%
%   LMS penumbral cone fundmantals, calculated from the tabulated Stockman-Sharpe
%   absorbances and incorporating filtering due to retinal vessels. These are fully adjustable:
%       'LConeTabulatedAbsorbancePenumbral', 'MConeTabulatedAbsorbancePenumbral', 'SConeTabulatedAbsorbancePenumbral'
%
%   Melanopsin, calculated using the Govardovskii nomogram at 480 nm as defined in
%   PTB's DefaultPhotoreceptors. This is fully adjustable:
%       'Melanopsin'
%
%   Rods, calculated using the Govardovskii nomogram at 491 nm as defined in
%   PTB's DefaultPhotoreceptors. This is fully adjustable:
%       'Rods'
%
%   LMS cone fundamentals, calculated using the Stockman-Sharpe nomogram
%   (not recommended). This is included only for legacy purposes and might
%   be removed at some point. Don't use these:
%       'LConeSSNomogramLegacy', 'MConeSSNomogramLegacy','MConeSSNomogramLegacy'
%
%   LMS cone fundamentals defined in T_cones_ss2 and T_cones_ss10. Does not
%   adjust the filtering parameters or other individual differences
%   parameters. Provided mostly to have a unified interface to get these
%   spectral sensitivities.
%       2 deg: 'LCone2DegTabulatedSS', 'MCone2DegTabulatedSS', 'SCone2DegTabulatedSS'
%       10 deg: 'LCone10DegTabulatedSS', 'MCone10DegTabulatedSS', 'SCone10DegTabulatedSS
%
%  G) The nominal lambda-max values returned for the spectral sensitivities based on the
%  tabulated absorbances for the open-field cones are 555.3, 525.1 and
%  419.5 nm. These are given on p. 33 in CIE 2006:170.

% 7/20/17   ms    Updated options and comments.
% 1/21/14   ms    Wrote it based on old code.
% 5/24/14   dhb   Remove vestigal references to a returned labels variable.
% 5/26/14   dhb   Fix bug: 'Melanopsin-2' was being computed with a shift of -1.
%           dhb   Simplify return interface.  Add many comments.
%           dhb   Return isomerization sensitivities for hemoglobin variants.
% 11/21/14  ms    Cleaned up and commented
% 12/12/14  dhb   More cleaning and comments.
%                 This now takes hemoglobin parameters.
%                 Manuel did this but didn't leave a comment.  I pushed the
%                 responsibility for prompting up to the caller.
% 10/22/15  dhb   Added note about how the lambdaMaxShift parameter works when it is a scalar.
%           dhb   Allow passing lambdaMax as a vector.
%           dhb   Make return nominalLambdaMax take the shift into account,
%                 and always fill in something.
%           dhb   Apply lambdaMaxShift in a few cases where it did not apply before.
% 10/25/15  dhb   Change back so that nominalLambdaMax returned does NOT take the shift into account.
% 12/4/15   ms    Added 2-deg Stockman-Sharp fundamentals.
% 2/9/16    ms    Added penumbral cones from tabulated absorbances
% 7/22/17   dhb   Multiply penumbral quantal sensitivities in isomerization units by blood transmittance, too.
% 7/22/17   dhb   Add some error checking for a case where we just previously had a comment about an edge case
%                 where fraction bleached specification could go south, and a comment about the workaround.
% 7/20/18   dhb   Allow fieldSizeDegrees to be a vector of same length as
%                 photoreceptor classes.

%% Set defaults

% Wavelength sampling
if (nargin < 1 | isempty(S))
    S = [380 2 201];
end

% Photoreceptor classes to generate
if (nargin < 2 | isempty(photoreceptorClasses))
    photoreceptorClasses = {'LConeTabulatedAbsorbance' ; ...
        'MConeTabulatedAbsorbance' ; ...
        'SConeTabulatedAbsorbance'};
end

% Field size
if (nargin < 3 | isempty(fieldSizeDegrees))
    fieldSizeDegrees = 10;
end

% Observer age
% If the passed observer age is <20 or >80, we assume that the observer is
% 20 or 80 respectively, which are the maximum ages given by the CIE standard.
if (nargin < 4 | isempty(ageInYears))
    ageInYears = 32;
end
if ageInYears < 20
    ageInYears = 20;
    %fprintf('Observer age truncated at 20\n');
end
if ageInYears > 80
    ageInYears = 80;
    %fprintf('Observer age truncated at 80\n');
end

% Pupil diameter
if (nargin < 5 | isempty(pupilDiameterMm))
    pupilDiameterMm = 3;
end

% Shift of pigment lambda max from nominal value, and some
% sanity checks on what we get.
if (nargin < 6 | isempty(lambdaMaxShift))
    lambdaMaxShift = zeros(1, length(photoreceptorClasses));
end
if (length(lambdaMaxShift) == 1 & length(photoreceptorClasses) ~= 1 & lambdaMaxShift ~= 0)
    error('* A scalar but non-zero lambdaMaxShift was passed.  This will not lead to good things.  Fix it.')
end
if (length(lambdaMaxShift) ~= 1 & length(lambdaMaxShift) ~= length(photoreceptorClasses))
    error('* lambdaMaxShift passed as a vector with length not equally to number of photoreceptor classes.');
end

% Fraction pigment bleached
if (nargin < 7 | isempty(fractionPigmentBleached))
    if length(photoreceptorClasses) > 1
        fractionPigmentBleached = zeros(length(photoreceptorClasses),1);
    else
        fractionPigmentBleached = 0;
    end
end

% Vessel oxygenation
if (nargin < 8 | isempty(vesselOxyFraction))
    vesselOxyFraction = 0.85;
end

% Vessel thickness
if (nargin < 9 | isempty(vesselOverallThicknessUm))
    vesselOverallThicknessUm = 5;
end

%% Assign empty vectors
T_quanta = [];
T_energyNormalized = [];
T_quantalIsomerizations = [];
nominalLambdaMax = [];

%% Promote fieldSizeDegrees to a vector if it is a scalar
if (length(fieldSizeDegrees) == 1)
    fieldSizeDegrees = fieldSizeDegrees*ones(length(photoreceptorClasses),1);
end
for i = 1:length(photoreceptorClasses)
    theClass = photoreceptorClasses{i};
    whichClass = i;
    
    % Get lambdaMaxShift to use for this class.
    if (length(lambdaMaxShift) == 1)
        lambdaMaxShiftUse = lambdaMaxShift;
    elseif (length(lambdaMaxShift) == length(photoreceptorClasses))
        lambdaMaxShiftUse = lambdaMaxShift(whichClass);
    else
        error('Input lambdaMaxShift does not have an allowable dimension.');
    end
    
    switch theClass
        case 'Melanopsin'
            % Melanopsin
            photoreceptors = DefaultPhotoreceptors('LivingHumanMelanopsin');
            photoreceptors.nomogram.S = S;
            nominalLambdaMaxTmp = photoreceptors.nomogram.lambdaMax;
            photoreceptors.nomogram.lambdaMax = nominalLambdaMaxTmp+lambdaMaxShiftUse;
            photoreceptors.fieldSizeDegrees = fieldSizeDegrees(i);
            photoreceptors.ageInYears = ageInYears;
            photoreceptors.pupilDiameter.value = pupilDiameterMm;
            photoreceptors = FillInPhotoreceptors(photoreceptors);
            
            % Add to the receptor vector
            T_energyNormalized = [T_energyNormalized ; photoreceptors.energyFundamentals];
            T_quantalIsomerizations = [T_quantalIsomerizations ; photoreceptors.isomerizationAbsorptance];
            nominalLambdaMax = [nominalLambdaMax nominalLambdaMaxTmp];

        case 'RodCanine'
            % Rods
            photoreceptors = DefaultPhotoreceptors('LivingDog');
            photoreceptors.nomogram.S = S;
            nominalLambdaMaxTmp = photoreceptors.nomogram.lambdaMax;
            photoreceptors.nomogram.lambdaMax = nominalLambdaMaxTmp;
            photoreceptors.fieldSizeDegrees = fieldSizeDegrees(i);
            photoreceptors.ageInYears = ageInYears;
            photoreceptors.pupilDiameter.value = pupilDiameterMm;
            photoreceptors = FillInPhotoreceptors(photoreceptors);
            
            % Add to the receptor vector
            T_energyNormalized = [T_energyNormalized ; photoreceptors.energyFundamentals];
            T_quantalIsomerizations = [T_quantalIsomerizations ; photoreceptors.isomerizationAbsorptance];
            nominalLambdaMax = [nominalLambdaMax nominalLambdaMaxTmp];

            % Return the third entry
            T_energyNormalized = T_energyNormalized(3,:);
            T_quantalIsomerizations = T_quantalIsomerizations(3,:);
            nominalLambdaMax = nominalLambdaMax(3);

        case 'LConeCanine'
            % L Cone
            photoreceptors = DefaultPhotoreceptors('LivingDog');
            photoreceptors.nomogram.S = S;
            nominalLambdaMaxTmp = photoreceptors.nomogram.lambdaMax;
            photoreceptors.nomogram.lambdaMax = nominalLambdaMaxTmp;
            photoreceptors.fieldSizeDegrees = fieldSizeDegrees(i);
            photoreceptors.ageInYears = ageInYears;
            photoreceptors.pupilDiameter.value = pupilDiameterMm;
            photoreceptors = FillInPhotoreceptors(photoreceptors);
            
            % Add to the receptor vector
            T_energyNormalized = [T_energyNormalized ; photoreceptors.energyFundamentals];
            T_quantalIsomerizations = [T_quantalIsomerizations ; photoreceptors.isomerizationAbsorptance];
            nominalLambdaMax = [nominalLambdaMax nominalLambdaMaxTmp];

            % Return the third entry
            T_energyNormalized = T_energyNormalized(1,:);
            T_quantalIsomerizations = T_quantalIsomerizations(1,:);
            nominalLambdaMax = nominalLambdaMax(1);

        case 'SConeCanine'
            % S cone
            photoreceptors = DefaultPhotoreceptors('LivingDog');
            photoreceptors.nomogram.S = S;
            nominalLambdaMaxTmp = photoreceptors.nomogram.lambdaMax;
            photoreceptors.nomogram.lambdaMax = nominalLambdaMaxTmp;
            photoreceptors.fieldSizeDegrees = fieldSizeDegrees(i);
            photoreceptors.ageInYears = ageInYears;
            photoreceptors.pupilDiameter.value = pupilDiameterMm;
            photoreceptors = FillInPhotoreceptors(photoreceptors);
            
            % Add to the receptor vector
            T_energyNormalized = [T_energyNormalized ; photoreceptors.energyFundamentals];
            T_quantalIsomerizations = [T_quantalIsomerizations ; photoreceptors.isomerizationAbsorptance];
            nominalLambdaMax = [nominalLambdaMax nominalLambdaMaxTmp];

            % Return the third entry
            T_energyNormalized = T_energyNormalized(2,:);
            T_quantalIsomerizations = T_quantalIsomerizations(2,:);
            nominalLambdaMax = nominalLambdaMax(2);

    end
end

%% Normalize energy sensitivities.
%
% They might already be normalized in most cases, but this makes sure.
for i = 1:size(T_energyNormalized)
    T_energyNormalized(i,:) = T_energyNormalized(i,:)/max(T_energyNormalized(i,:));
end

%% Check
if (length(nominalLambdaMax) ~= length(photoreceptorClasses))
    error('\t * Failed to fill in a nominalLambdaMax somewhere');
end
