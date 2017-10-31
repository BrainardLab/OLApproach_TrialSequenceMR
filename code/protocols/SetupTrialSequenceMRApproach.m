%%SetupTrialSequenceMRAppraoch  Do the protocol indpendent steps required to run a trial sequence MR protocol.
%
% Description:
%   Do the protocol indpendent steps required to run a protocol.  
%   These are:
%     Do the calibration (well, that doesn't happen here but you need to do it.)
%     Make the nominal background primaries.
%     Make the nominal direction primaries.

%% Parameters
%
% Who we are
approachParams.approach = 'OLApproach_TrialSequenceMR';

% List of all calibrations used in this approach
approachParams.calibrationTypes = {'BoxBRandomizedLongCableDStubby1_ND00', 'BoxBRandomizedLongCableDStubby1_ND03'};

% List of all backgrounds used in this approach
approachParams.backgroundNames = {'MelanopsinDirected_275_80_667', 'LMSDirected_275_80_667', 'MelanopsinDirected_600_80_667', 'LMSDirected_600_80_667', 'LightFlux_540_380_50', 'LightFlux_330_330_20'};

% List of all directions used in this approach
approachParams.directionNames = {'MaxMel_600_80_667', 'MaxLMS_600_80_667', 'LightFlux_540_380_50', 'LightFlux_330_330_20'};

%%  Make the backgrounds
for cc = 1:length(approachParams.calibrationTypes)
    tempApproachParams= approachParams;
    tempApproachParams.calibrationType = approachParams.calibrationTypes{cc};  
    OLMakeBackgroundNominalPrimaries(tempApproachParams);
end

%%  Make the directions
for cc = 1:length(approachParams.calibrationTypes)
    tempApproachParams = approachParams;
    tempApproachParams.calibrationType = approachParams.calibrationTypes{cc};  
    OLMakeDirectionNominalPrimaries(tempApproachParams,'verbose',false);
end

