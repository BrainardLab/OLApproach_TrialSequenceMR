%% clear stuff
clear

%% Set the parameter structure here
%
% Who we are and what we're doing today
protocolParams.approach = 'OLApproach_TrialSequenceMR';
protocolParams.protocol = 'PupilScotoLDOG';
protocolParams.protocolOutputName = 'PupilScotoLDOG';
protocolParams.emailRecipient = 'huseyinozenc.taskin@pennmedicine.upenn.edu';
protocolParams.verbose = true;
protocolParams.simulate.oneLight = false;
protocolParams.simulate.makePlots = false;
protocolParams.simulate.radiometer = true;


%% Set up all the parameters, make modulations, validate stimuli
[protocolParams,LplusSDirection,LminusSDirection,RodMelDirection,LightFluxDirection,modBackground, ol] = ...
    PupilScotoLDOG.setAndSaveParams(protocolParams);


%% Set the OneLight to the background
[backgroundStarts, backgroundStops] = OLPrimaryToStartsStops(modBackground.differentialPrimaryValues,modBackground.calibration);
ol.setMirrors(backgroundStarts, backgroundStops);


%% Tell the operator to add the casette to the light path
fprintf('\nAdd the casette to the light path to create scotopic conditions\n');


%%%%%%%%%%%%%%%%%%%%%%%
%% CONDUCT PUPILLOMETRY
%%


%% Define the trial orders
% Sinusoidal modulations, chosen from the frequencySet = [0, 1/24, 1/12, 1/6];
trialOrders = {...
    [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3],...
    [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3],...
    [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3],...
    [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3],...
    [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3],...
    [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3],...
    [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3],...
    [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3],...
    [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3],...
    };

%% Define the direction orders
% Chosen from the set: {'LightFlux','RodMel','LplusS'};
directionOrders = {...
    'LightFlux',...
    'LightFlux',...
    'LightFlux',...
    'RodMel',...
    'RodMel',...
    'RodMel',...
    'LplusS',...
    'LplusS',...
    'LplusS',...
    };


%% Define the contrast levels
% These are always maximal
contrastLevels = [1,1,1,1,1,1,1,1,1,1,1,1,1,1];

%% Loop until we are done pupilling
stillMeasuring = true;
while stillMeasuring

    % Which acquisition should we run?
    acquisitionNumber = input('Enter pupil acquisition number (1-9; 99 to stop measuring pupil): ');
    
    % Check if we are done scanning
    if acquisitionNumber==99
        stillMeasuring = false;
        continue
    else
        % Store the acquisition number in the protocol params
        protocolParams.acquisitionNumber = acquisitionNumber;
    end

    % Get the temporal modulations for this acquisition
    switch directionOrders{acquisitionNumber}
        case 'LightFlux'
            [modulationsCellArray,temporalParams,protocolParams] = PupilScotoLDOG.makeTemporalModulationsPupil(LightFluxDirection,modBackground,protocolParams);
        case 'RodMel'
            [modulationsCellArray,temporalParams,protocolParams] = PupilScotoLDOG.makeTemporalModulationsPupil(RodMelDirection,modBackground,protocolParams);
        case 'LplusS'
            [modulationsCellArray,temporalParams,protocolParams] = PupilScotoLDOG.makeTemporalModulationsPupil(LplusSDirection,modBackground,protocolParams);
    end
    
    % Add the trial order to the protocol params
    protocolParams.trialTypeOrder = [];
    protocolParams.trialTypeOrder(1,:) = trialOrders{acquisitionNumber};
    protocolParams.trialTypeOrder(2,:) = contrastLevels;
    
    %% Run the experiment.
    ApproachEngine(ol,protocolParams,modulationsCellArray,temporalParams,'acquisitionNumber',acquisitionNumber,'verbose',protocolParams.verbose);
    
end


%% Tell the operator to remove the casette from the light path
fprintf('\nRemove the casette to the light path prior to stimulus validation\n');


%% Post-Experiemnt Validations.
PupilScotoLDOG.postExpValidation(protocolParams,ol,LplusSDirection,LminusSDirection,RodMelDirection,LightFluxDirection,modBackground);

