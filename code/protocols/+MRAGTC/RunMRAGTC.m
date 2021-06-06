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
protocolParams.simulate.oneLight = false;
protocolParams.simulate.makePlots = false;
protocolParams.simulate.radiometer = false;
protocolParams.performCorrection = false;
protocolParams.takeCalStateMeasurements = false;
protocolParams.takeTempearatureMeasurements = false;

%% Set up all the parameters and make Modulations
[protocolParams,trialTypeParams,PhotoreceptorDirections,PhotoreceptorBackground, ol, directionTypes]  = MRAGTC.setAndSaveParams(protocolParams);

%% Make the temporal modulations for experiment
[modulationsCellArray,flickerParams] = MRAGTC.makeTemporalModulations(PhotoreceptorDirections,PhotoreceptorBackground,trialTypeParams,protocolParams);

%% Set the OL to the stimulus background
ol.setMirrors(modulationsCellArray{end}.backgroundStarts, modulationsCellArray{end}.backgroundStops);

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