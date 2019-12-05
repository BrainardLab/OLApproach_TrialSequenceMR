function [T_energyNormalized,T_quantalIsomerizations,nominalLambdaMax] = GetCaninePhotoreceptorSS(S, photoreceptorClasses, fieldSizeDegrees, ageInYears,...
    pupilDiameterMm, lambdaMaxShift, fractionPigmentBleached, vesselOxyFraction, vesselOverallThicknessUm)
% Produces photopigment sensitivities for canine photoreceptors
%
% Syntax:
% [T_energyNormalized,T_quantalIsomerizations,nominalLambdaMax] = GetCaninePhotoreceptorSS(S, photoreceptorClasses, fieldSizeDegrees, ageInYears, pupilDiameterMm,
%   lambdaMaxShift, fractionPigmentBleached, vesselOxyFraction, vesselOverallThicknessUm)
%
% Description:
%   Modified from GetHumanPhotoreceptorSS, which lives in the
%   SilentSubstitutionToolbox. Please see that routine for details
%   regarding the inputs and outputs.
%
%   I suspect that much of the code prior to the "Loop through the
%   photoreceptorClasses" stage could be removed or at least greatly
%   reduced, but have not taken this on yet.
%

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

%% Loop through the photoreceptorClasses
for ii = 1:length(photoreceptorClasses)
    theClass = photoreceptorClasses{ii};
    whichClass = ii;
    
    % Get lambdaMaxShift to use for this class.
    if (length(lambdaMaxShift) == 1)
        lambdaMaxShiftUse = lambdaMaxShift;
    elseif (length(lambdaMaxShift) == length(photoreceptorClasses))
        lambdaMaxShiftUse = lambdaMaxShift(whichClass);
    else
        error('Input lambdaMaxShift does not have an allowable dimension.');
    end
    
    switch theClass
        case 'MelCanine'
            % Melanopsin
            photoreceptors.species = 'Canine';
            photoreceptors.types = {'Melanopsin'};
            photoreceptors.nomogram.S = [380 2 201];
            photoreceptors.axialDensity.source = 'Value provided directly';
            photoreceptors.axialDensity.value = 0.015;
            photoreceptors.nomogram.source = 'Govardovskii';
            photoreceptors.nomogram.lambdaMax = 480;
            nominalLambdaMaxTmp = photoreceptors.nomogram.lambdaMax;
            photoreceptors.quantalEfficiency.source = 'Generic';
            photoreceptors.fieldSizeDegrees = 10;  % This value is used in the CIE lens transmittance calcs, so not relevant here.
            photoreceptors.ageInYears = 32; % This value is used in the CIE lens transmittance calcs, so not relevant here.
            photoreceptors.pupilDiameter.value = 3;  % This value is used in the CIE lens transmittance calcs, so not relevant here.
            photoreceptors.lensDensity.source = 'None'; % We will add the dog lens in a moment
            photoreceptors.macularPigmentDensity.source = 'None';

            % Add the canine lens density field
            photoreceptors = MRFlickerLDOG.addCanineLensDensity(photoreceptors);

            % Fill in the photoreceptors
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
            photoreceptors.fieldSizeDegrees = fieldSizeDegrees(ii);
            photoreceptors.ageInYears = ageInYears;
            photoreceptors.pupilDiameter.value = pupilDiameterMm;

            % Add the canine lens density field
            photoreceptors = MRFlickerLDOG.addCanineLensDensity(photoreceptors);

            % Fill in the photoreceptors
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
            photoreceptors.fieldSizeDegrees = fieldSizeDegrees(ii);
            photoreceptors.ageInYears = ageInYears;
            photoreceptors.pupilDiameter.value = pupilDiameterMm;

            % Add the canine lens density field
            photoreceptors = MRFlickerLDOG.addCanineLensDensity(photoreceptors);

            % Fill in the photoreceptors
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
            photoreceptors.fieldSizeDegrees = fieldSizeDegrees(ii);
            photoreceptors.ageInYears = ageInYears;
            photoreceptors.pupilDiameter.value = pupilDiameterMm;

            % Add the canine lens density field
            photoreceptors = MRFlickerLDOG.addCanineLensDensity(photoreceptors);

            % Fill in the photoreceptors
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
for ii = 1:size(T_energyNormalized)
    T_energyNormalized(ii,:) = T_energyNormalized(ii,:)/max(T_energyNormalized(ii,:));
end

%% Check
if (length(nominalLambdaMax) ~= length(photoreceptorClasses))
    error('\t * Failed to fill in a nominalLambdaMax somewhere');
end
