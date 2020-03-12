%% clear stuff
clear

%% Set the parameter structure here
%
% Who we are and what we're doing today
protocolParams.approach = 'OLApproach_TrialSequenceMR';
protocolParams.protocol = 'MRScoto_LDOG';
protocolParams.protocolOutputName = 'MRScoto_LDOG';
protocolParams.emailRecipient = 'huseyinozenc.taskin@pennmedicine.upenn.edu';
protocolParams.verbose = true;
protocolParams.simulate.oneLight = false;
protocolParams.simulate.makePlots = false;
protocolParams.simulate.radiometer = false;


%% Set up all the parameters and make Modulations
[protocolParams,LplusSDirection,LminusSDirection,RodMelDirection,LightFluxDirection,modBackground, ol] = ...
    MRScoto_LDOG.setAndSaveParams(protocolParams);


%% Set the OneLight to the background
[backgroundStarts, backgroundStops] = OLPrimaryToStartsStops(modBackground.differentialPrimaryValues,modBackground.calibration);
ol.setMirrors(backgroundStarts, backgroundStops);




%%%%%%%%%%%%%%%%%%%%%%%
%% CONDUCT PUPILLOMETRY
%%

%% Define the trial orders
% frequencySet = [0, 1/24, 1/12, 1/6];
% Under scotopic conditions, we always used 1/12 Hz for the pupil
% modulation

trialOrders = [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3];


%% Define the contrast levels
% These are always maximal
contrastLevels = [1,1,1,1,1,1,1,1,1,1,1,1,1,1];

%% Define the direction orders
% Under scotopic conditions, we will always use LightFlux
directionOrders = 'LightFlux';


%% Loop until we are done pupilling
stillMeasuring = true;
while stillMeasuring

    % Which acquisition should we run?
    acquisitionNumber = input('Enter pupil acquisition number (99 to stop measuring pupil): ');
    
    % Check if we are done scanning
    if acquisitionNumber==99
        stillMeasuring = false;
        continue
    else
        % Store the acquisition number in the protocol params
        protocolParams.acquisitionNumber = acquisitionNumber;
    end

    % Get the temporal modulations for this acquisition
    [modulationsCellArray,temporalParams,protocolParams] = MRScoto_LDOG.makeTemporalModulationsPupil(LightFluxDirection,modBackground,protocolParams);
    
    % Add the trial order to the protocol params
    protocolParams.trialTypeOrder = [];
    protocolParams.trialTypeOrder(1,:) = trialOrders;
    protocolParams.trialTypeOrder(2,:) = contrastLevels;
    
    %% Run the experiment.
    ApproachEngine(ol,protocolParams,modulationsCellArray,temporalParams,'acquisitionNumber',acquisitionNumber,'verbose',protocolParams.verbose);
    
end




%%%%%%%%%%%%%%%%%%%%%%%
%% CONDUCT fMRI
%%


%% Define the trial orders
% frequencySet = [0, 12];
% We use 12 Hz for the modulation under scotopic conditions
trialOrders = [2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1];

%% Define the contrast levels
% These are always maximal
contrastLevels = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];

%% Define the direction orders
directionOrders = 'LightFlux';


%% Loop until we are done scanning
stillMeasuring = true;
while stillMeasuring

    % Which acquisition should we run?
    acquisitionNumber = input('Enter fMRI acquisition number (20+ for fMRI; 99 to stop scanning): ');
    
    % Check if we are done scanning
    if acquisitionNumber==99
        stillMeasuring = false;
        continue
    else
        % Store the acquisition number in the protocol params
        protocolParams.acquisitionNumber = acquisitionNumber;
    end

    % Get the temporal modulations for this acquisition
    [modulationsCellArray,temporalParams,protocolParams] = MRScoto_LDOG.makeTemporalModulationsFMRI(LightFluxDirection,modBackground,protocolParams);
    
    % Add the trial order to the protocol params
    protocolParams.trialTypeOrder = [];
    protocolParams.trialTypeOrder(1,:) = trialOrders;
    protocolParams.trialTypeOrder(2,:) = contrastLevels;
    
    %% Run the experiment.
    ApproachEngine(ol,protocolParams,modulationsCellArray,temporalParams,'acquisitionNumber',acquisitionNumber,'verbose',protocolParams.verbose);
    
end

%% Post-Experiemnt Validations.
MRScoto_LDOG.postExpValidation(protocolParams,ol,LplusSDirection,LminusSDirection,RodMelDirection,LightFluxDirection,modBackground);

