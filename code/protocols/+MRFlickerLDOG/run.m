%% clear stuff
clear

%% Set the parameter structure here
%
% Who we are and what we're doing today
protocolParams.approach = 'OLApproach_TrialSequenceMR';
protocolParams.protocol = 'MRFlickerLDOG';
protocolParams.protocolOutputName = 'MRFlickerLDOG';
protocolParams.emailRecipient = 'huseyinozenc.taskin@pennmedicine.upenn.edu';
protocolParams.verbose = true;
protocolParams.simulate.oneLight = false;
protocolParams.simulate.makePlots = false;
protocolParams.simulate.radiometer = false;


%% Set up all the parameters and make Modulations
[protocolParams,LplusSDirection,LminusSDirection,RodMelDirection,LightFluxDirection,modBackground, ol] = ...
    MRFlickerLDOG.setAndSaveParams(protocolParams);


%% Set the OneLight to the background
[backgroundStarts, backgroundStops] = OLPrimaryToStartsStops(modBackground.differentialPrimaryValues,modBackground.calibration);
ol.setMirrors(backgroundStarts, backgroundStops);




%%%%%%%%%%%%%%%%%%%%%%%
%% CONDUCT PUPILLOMETRY
%%

%% Define the trial orders
trialOrders{1} = [2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 4, 4, 4];
trialOrders{2} = [2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 4, 4, 4];
trialOrders{3} = [2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 4, 4, 4];

%% Define the contrast levels
% These are always maximal
contrastLevels = [1,1,1,1,1,1,1,1,1,1,1,1,1,1];

%% Define the direction orders
directionOrders{1} = 'LightFlux';
directionOrders{2} = 'LplusS';
directionOrders{3} = 'RodMel';


%% Loop until we are done pupilling
stillMeasuring = true;
while stillMeasuring

    % Which acquisition should we run?
    acquisitionNumber = input('Enter acquisition number (1-3 pupil; 99 to stop measuring pupil): ');
    
    % Check if we are done scanning
    if acquisitionNumber==99
        stillMeasuring = false;
        continue
    else
        % Store the acquisition number in the protocol params
        protocolParams.acquisitionNumber = acquisitionNumber;
    end

    % Get the temporal modulations for this acquisition
    switch directionOrders{protocolParams.acquisitionNumber}
        case 'LightFlux'
            [modulationsCellArray,temporalParams,protocolParams] = MRFlickerLDOG.makeTemporalModulationsPupil(LightFluxDirection,modBackground,protocolParams);
        case 'LplusS'
            [modulationsCellArray,temporalParams,protocolParams] = MRFlickerLDOG.makeTemporalModulationsPupil(LplusSDirection,modBackground,protocolParams);
        case 'RodMel'
            [modulationsCellArray,temporalParams,protocolParams] = MRFlickerLDOG.makeTemporalModulationsPupil(RodMelDirection,modBackground,protocolParams);
    end
    
    % Add the trial order to the protocol params
    protocolParams.trialTypeOrder(1,:) = trialOrders{protocolParams.acquisitionNumber};
    protocolParams.trialTypeOrder(2,:) = contrastLevels;
    
    %% Run the experiment.
    ApproachEngine(ol,protocolParams,modulationsCellArray,temporalParams,'acquisitionNumber',acquisitionNumber,'verbose',protocolParams.verbose);
    
end




%%%%%%%%%%%%%%%%%%%%%%%
%% CONDUCT fMRI
%%


%% Define the trial orders
trialOrders{4} = [5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1];
trialOrders{5} = [2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1];
trialOrders{6} = [2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1];
trialOrders{7} = [2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1];
trialOrders{8} = [2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1];
trialOrders{9} = [5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1];
trialOrders{10} = [2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1];
trialOrders{11} = [5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1];
trialOrders{12} = [2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1];

%% Define the contrast levels
% These are always maximal
contrastLevels = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];

%% Define the direction orders
directionOrders{4} = 'LplusS';
directionOrders{5} = 'LminusS';
directionOrders{6} = 'RodMel';
directionOrders{7} = 'LminusS';
directionOrders{8} = 'RodMel';
directionOrders{9} = 'LplusS';
directionOrders{10} = 'RodMel';
directionOrders{11} = 'LplusS';
directionOrders{12} = 'LminusS';

%% Loop until we are done scanning
stillMeasuring = true;
while stillMeasuring

    % Which acquisition should we run?
    acquisitionNumber = input('Enter acquisition number (4-12 fMRI; 99 to stop scanning): ');
    
    % Check if we are done scanning
    if acquisitionNumber==99
        stillMeasuring = false;
        continue
    else
        % Store the acquisition number in the protocol params
        protocolParams.acquisitionNumber = acquisitionNumber;
    end

    % Get the temporal modulations for this acquisition
    switch directionOrders{protocolParams.acquisitionNumber}
        case 'LplusS'
            [modulationsCellArray,temporalParams,protocolParams] = MRFlickerLDOG.makeTemporalModulationsFMRI(LplusSDirection,modBackground,protocolParams);
        case 'LminusS'
            [modulationsCellArray,temporalParams,protocolParams] = MRFlickerLDOG.makeTemporalModulationsFMRI(LminusSDirection,modBackground,protocolParams);
        case 'RodMel'
            [modulationsCellArray,temporalParams,protocolParams] = MRFlickerLDOG.makeTemporalModulationsFMRI(RodMelDirection,modBackground,protocolParams);
    end
    
    % Add the trial order to the protocol params
    protocolParams.trialTypeOrder(1,:) = trialOrders{protocolParams.acquisitionNumber};
    protocolParams.trialTypeOrder(2,:) = contrastLevels;
    
    %% Run the experiment.
    ApproachEngine(ol,protocolParams,modulationsCellArray,temporalParams,'acquisitionNumber',acquisitionNumber,'verbose',protocolParams.verbose);
    
end

%% Post-Experiemnt Validations.
MRFlickerLDOG.postExpValidation(protocolParams,ol,LplusSDirection,LminusSDirection,RodMelDirection,LightFluxDirection,modBackground);

