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
protocolParams.simulate.oneLight = true;
protocolParams.simulate.makePlots = false;
protocolParams.simulate.radiometer = true;


%% Set up all the parameters and make Modulations
[protocolParams,LplusSDirection,LminusSDirection,RodMelDirection,modBackground, ol] = ...
    MRFlickerLDOG.setAndSaveParams(protocolParams);

%% Define the trial orders
trialOrders{1} = [5,2,2,1,6,5,3,2,6,4,2,4,6,1,2,5,6,3,6,6,2,3,5,5,4,4,1,3,1,5,1,1,4,3,3,4];
trialOrders{2} = [1,5,5,1,1,3,6,5,2,2,4,6,2,3,3,1,2,5,6,1,6,6,3,2,6,4,3,4,4,5,3,5,4,1,4,2];
trialOrders{3} = [2,4,6,3,5,5,4,4,5,2,6,1,6,2,2,3,6,6,4,1,3,1,1,2,1,5,1,4,3,3,2,5,6,5,3,4];
trialOrders{4} = [5,2,2,1,6,5,3,2,6,4,2,4,6,1,2,5,6,3,6,6,2,3,5,5,4,4,1,3,1,5,1,1,4,3,3,4];
trialOrders{5} = [1,5,5,1,1,3,6,5,2,2,4,6,2,3,3,1,2,5,6,1,6,6,3,2,6,4,3,4,4,5,3,5,4,1,4,2];
trialOrders{6} = [2,4,6,3,5,5,4,4,5,2,6,1,6,2,2,3,6,6,4,1,3,1,1,2,1,5,1,4,3,3,2,5,6,5,3,4];
trialOrders{7} = [5,2,2,1,6,5,3,2,6,4,2,4,6,1,2,5,6,3,6,6,2,3,5,5,4,4,1,3,1,5,1,1,4,3,3,4];
trialOrders{8} = [1,5,5,1,1,3,6,5,2,2,4,6,2,3,3,1,2,5,6,1,6,6,3,2,6,4,3,4,4,5,3,5,4,1,4,2];
trialOrders{9} = [2,4,6,3,5,5,4,4,5,2,6,1,6,2,2,3,6,6,4,1,3,1,1,2,1,5,1,4,3,3,2,5,6,5,3,4];

%% Define the contrast levels
% These are always maximal
contrastLevels = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];

%% Define the direction orders
directionOrders{1} = 'LplusS';
directionOrders{2} = 'LminusS';
directionOrders{3} = 'RodMel';
directionOrders{4} = 'LminusS';
directionOrders{5} = 'RodMel';
directionOrders{6} = 'LplusS';
directionOrders{7} = 'RodMel';
directionOrders{8} = 'LplusS';
directionOrders{9} = 'LminusS';

%% Loop until we are done scanning
stillScanning = true;
while stillScanning

    % Which acquisition should we run?
    acquisitionNumber = input('Enter acquisition (aka scan) number (99 to stop scanning): ');
    
    % Check if we are done scanning
    if acquisitionNumber==99
        stillScanning = false;
        continue
    else
        % Store the acquisition number in the protocol params
        protocolParams.acquisitionNumber = acquisitionNumber;
    end
    
    % Get the temporal modulations for this acquisition
    switch directionOrders{protocolParams.acquisitionNumber}
        case 'LplusS'
            [modulationsCellArray,temporalParams] = MRFlickerLDOG.makeTemporalModulations(LplusSDirection,modBackground,protocolParams);
        case 'LminusS'
            [modulationsCellArray,temporalParams] = MRFlickerLDOG.makeTemporalModulations(LminusSDirection,modBackground,protocolParams);
        case 'RodMel'
            [modulationsCellArray,temporalParams] = MRFlickerLDOG.makeTemporalModulations(RodMelDirection,modBackground,protocolParams);
    end
    
    % Add the trial order to the protocol params
    protocolParams.trialTypeOrder(1,:) = trialOrders{protocolParams.acquisitionNumber};
    protocolParams.trialTypeOrder(2,:) = contrastLevels;
    
    %% Run the experiment.
    ApproachEngine(ol,protocolParams,modulationsCellArray,temporalParams,'acquisitionNumber',acquisitionNumber,'verbose',protocolParams.verbose);
    
end

%% Post-Experiemnt Validations.
MRFlickerLDOG.postExpValidation(protocolParams,ol,LplusSDirection,LminusSDirection,RodMelDirection,modBackground);

