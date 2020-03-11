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
% frequencySet = [0, 1/24, 1/12, 1/6];
% We run the pupillometry with different stimulus frequencies for the
% photoreceptor directions:
%   L+S: 1/6 Hz
%   LightFlux: 1/12 Hz
%   RodMel: 1/12 Hz

trialOrders{1} = [4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4];
trialOrders{2} = [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3];
trialOrders{3} = [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3];
trialOrders{4} = [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3];
trialOrders{5} = [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3];
trialOrders{6} = [4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4];
trialOrders{7} = [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3];
trialOrders{8} = [4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4];
trialOrders{9} = [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3];
trialOrders{10} = [4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4];
trialOrders{11} = [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3];
trialOrders{12} = [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3];
trialOrders{13} = [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3];
trialOrders{14} = [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3];
trialOrders{15} = [4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4];
trialOrders{16} = [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3];
trialOrders{17} = [4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4];
trialOrders{18} = [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3];


%% Define the contrast levels
% These are always maximal
contrastLevels = [1,1,1,1,1,1,1,1,1,1,1,1,1,1];

%% Define the direction orders
directionOrders{1} = 'LplusS';
directionOrders{2} = 'LightFlux';
directionOrders{3} = 'RodMel';
directionOrders{4} = 'LightFlux';
directionOrders{5} = 'RodMel';
directionOrders{6} = 'LplusS';
directionOrders{7} = 'RodMel';
directionOrders{8} = 'LplusS';
directionOrders{9} = 'LightFlux';
directionOrders{10} = 'LplusS';
directionOrders{11} = 'LightFlux';
directionOrders{12} = 'RodMel';
directionOrders{13} = 'LightFlux';
directionOrders{14} = 'RodMel';
directionOrders{15} = 'LplusS';
directionOrders{16} = 'RodMel';
directionOrders{17} = 'LplusS';
directionOrders{18} = 'LightFlux';



%% Loop until we are done pupilling
stillMeasuring = true;
while stillMeasuring

    % Which acquisition should we run?
    acquisitionNumber = input('Enter acquisition number (1-18 pupil; 99 to stop measuring pupil): ');
    
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
% frequencySet = [0, 4, 8, 16, 32, 64];
% We use different stimulation frequencies for the different post-receptor
% directions:
%   L+S: 32 Hz
%   L-S: 4 Hz
%   RodMel: 4 Hz
trialOrders{20} = [5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1];
trialOrders{21} = [2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1];
trialOrders{22} = [2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1];
trialOrders{23} = [2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1];
trialOrders{24} = [2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1];
trialOrders{25} = [5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1];
trialOrders{26} = [2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1];
trialOrders{27} = [5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1];
trialOrders{28} = [2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1];
trialOrders{29} = [5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1];
trialOrders{30} = [2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1];
trialOrders{31} = [2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1];
trialOrders{32} = [2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1];
trialOrders{33} = [2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1];
trialOrders{34} = [5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1];
trialOrders{35} = [2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1];
trialOrders{36} = [5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1,5,1];
trialOrders{37} = [2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1];

%% Define the contrast levels
% These are always maximal
contrastLevels = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];

%% Define the direction orders
directionOrders{20} = 'LplusS';
directionOrders{21} = 'LminusS';
directionOrders{22} = 'RodMel';
directionOrders{23} = 'LminusS';
directionOrders{24} = 'RodMel';
directionOrders{25} = 'LplusS';
directionOrders{26} = 'RodMel';
directionOrders{27} = 'LplusS';
directionOrders{28} = 'LminusS';
directionOrders{29} = 'LplusS';
directionOrders{30} = 'LminusS';
directionOrders{31} = 'RodMel';
directionOrders{32} = 'LminusS';
directionOrders{33} = 'RodMel';
directionOrders{34} = 'LplusS';
directionOrders{35} = 'RodMel';
directionOrders{36} = 'LplusS';
directionOrders{37} = 'LminusS';


%% Loop until we are done scanning
stillMeasuring = true;
while stillMeasuring

    % Which acquisition should we run?
    acquisitionNumber = input('Enter acquisition number (20-37 fMRI; 99 to stop scanning): ');
    
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
    protocolParams.trialTypeOrder = [];
    protocolParams.trialTypeOrder(1,:) = trialOrders{protocolParams.acquisitionNumber};
    protocolParams.trialTypeOrder(2,:) = contrastLevels;
    
    %% Run the experiment.
    ApproachEngine(ol,protocolParams,modulationsCellArray,temporalParams,'acquisitionNumber',acquisitionNumber,'verbose',protocolParams.verbose);
    
end

%% Post-Experiemnt Validations.
MRFlickerLDOG.postExpValidation(protocolParams,ol,LplusSDirection,LminusSDirection,RodMelDirection,LightFluxDirection,modBackground);

