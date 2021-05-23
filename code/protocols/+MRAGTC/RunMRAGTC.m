%% clear stuff
clear

%% Set the parameter structure here
%
% Who we are and what we're doing today
protocolParams.approach = 'OLApproach_TrialSequenceMR';
protocolParams.protocol = 'MRAGTC';
protocolParams.protocolOutputName = 'AGTC';
protocolParams.emailRecipient = 'aguirreg@upenn.edu';
protocolParams.verbose = true;
protocolParams.simulate.oneLight = true;
protocolParams.simulate.makePlots = true;
protocolParams.simulate.radiometer = true;
protocolParams.takeCalStateMeasurements = false;
protocolParams.takeTempearatureMeasurements = false;

%% Set up all the parameters and make Modulations
[protocolParams,trialTypeParams,PhotoreceptorDirections,PhotoreceptorBackground, ol, directionTypes]  = MRAGTC.setAndSaveParams(protocolParams);

%% Make the temporal modulations for experiment
[modulationsCellArray,flickerParams] = MRAGTC.makeTemporalModulations(PhotoreceptorDirections,PhotoreceptorBackground,trialTypeParams,protocolParams);

%% While not done
stillScanning = true;
while stillScanning
    acquisitionNumber = input('Enter acquisition (aka scan) number (99 to exit): ');

    if acquisitionNumber == 99
        
        % Done scanning
        stillScanning=false;

    else
        
        % Store the acquisition number
        protocolParams.acquisitionNumber = acquisitionNumber;
        
        % Create the trial order
        protocolParams = MRAGTC.makeTrialOrder(protocolParams,modulationsCellArray);

        % Run the experiment
        ApproachEngine(ol,protocolParams,modulationsCellArray,flickerParams,'acquisitionNumber',protocolParams.acquisitionNumber,'verbose',protocolParams.verbose);

    end
end

%% Post-Experiemnt Validations. 
MRAGTC.postExpValidation(protocolParams.nValidationsPerDirection,protocolParams,ol,PhotoreceptorDirections,PhotoreceptorBackground,directionTypes);