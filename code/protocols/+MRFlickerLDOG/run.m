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
%% CONDUCT fMRI
%%


%% Define the trial orders
% frequencySet = [0, 4, 8, 16, 32, 64];
% We use different stimulation frequencies for the different
% post-receptoral directions:
%   L+S: 32 Hz
%   L-S: 4 Hz
%   LF: 16 Hz
trialOrders{1} = [5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1];
trialOrders{2} = [2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1];
trialOrders{3} = [4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1];
trialOrders{4} = [5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1];
trialOrders{5} = [2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1];
trialOrders{6} = [4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1];
trialOrders{7} = [5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1];
trialOrders{8} = [2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1];
trialOrders{9} = [4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1];
trialOrders{10} = [5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1];
trialOrders{11} = [2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1];
trialOrders{12} = [4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1];
trialOrders{13} = [5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1];
trialOrders{14} = [2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1];
trialOrders{15} = [4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1];
trialOrders{16} = [5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1];
trialOrders{17} = [2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1];
trialOrders{18} = [4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1,4,1];


%% Define the contrast levels
% These are always maximal
contrastLevels = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];

%% Define the direction orders
directionOrders{1} = 'LplusS';
directionOrders{2} = 'LminusS';
directionOrders{3} = 'LightFlux';
directionOrders{4} = 'LplusS';
directionOrders{5} = 'LminusS';
directionOrders{6} = 'LightFlux';
directionOrders{7} = 'LplusS';
directionOrders{8} = 'LminusS';
directionOrders{9} = 'LightFlux';
directionOrders{10} = 'LplusS';
directionOrders{11} = 'LminusS';
directionOrders{12} = 'LightFlux';
directionOrders{13} = 'LplusS';
directionOrders{14} = 'LminusS';
directionOrders{15} = 'LightFlux';
directionOrders{16} = 'LplusS';
directionOrders{17} = 'LminusS';
directionOrders{18} = 'LightFlux';


%% Loop until we are done scanning
stillMeasuring = true;
while stillMeasuring

    % Which acquisition should we run?
    acquisitionNumber = input('Enter acquisition number (1-18 fMRI; 99 to stop scanning): ');
    
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
        case 'LightFlux'
            [modulationsCellArray,temporalParams,protocolParams] = MRFlickerLDOG.makeTemporalModulationsFMRI(LightFluxDirection,modBackground,protocolParams);
    end
    
    % Add the trial order to the protocol params
    protocolParams.trialTypeOrder = [];
    protocolParams.trialTypeOrder(1,:) = trialOrders{protocolParams.acquisitionNumber};
    protocolParams.trialTypeOrder(2,:) = contrastLevels;
    
    %% Run the experiment.
    ApproachEngine(ol,protocolParams,modulationsCellArray,temporalParams,'acquisitionNumber',acquisitionNumber,'verbose',protocolParams.verbose);
    
end

%% Post-Experiemnt Validations.
MRFlickerLDOG.postExpValidation(protocolParams,ol,LplusSDirection,LminusSDirection,RodMelDirection,LightFluxDirection,modBackground);

