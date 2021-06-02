function protocolParams = makeTrialOrder(protocolParams,modulationsCellArray,varargin)
% Generate the trial order for the MRAGTC experiment.
%
% Usage:
%     protocolParams = makeTrialOrder(protocolParams,modulationsCellArray,varargin)
%
% Description:
%    Takes in the protocolParams and modulationCellArray and returns a
%    randomly permuted trial order.
%
% Inputs:
%    protocolParams (struct)  -The protocol parameters structure.
%    modulationsCellArray     -Cell array of the modulations struct/object
%                              that corresponds to each integer in the trial
%                              sequence specification.
%
% Outputs:
%    protocolParams           -Updated protocolParams struct with the trial order.
%
% Optional key/value pairs:
%    acquisitionOrder (vector) []         preset trial order when you dont
%                                         want random


p = inputParser;
p.addParameter('acquisitionOrder',[],@isnumeric);
p.parse(varargin{:});


%% Define some basic values
nDirections = size(modulationsCellArray,1);
nContrasts = size(modulationsCellArray,2)-1; % the -1 is to exclude the bacground starts/stops from the calculation
nTrials = protocolParams.nTrials;
nReps = nTrials / (nDirections*nContrasts);

if (floor(nReps) ~= nReps)
    error('Number trials not integer multiple of number of trial types.');
end


%% Counter-balanced trial order
% For the special case of an experiment with 5 direction types, and one
% contrast level, we will use a deBruijn sequence that has the 5th (blank)
% stimulus at the start and the end, and is the same sequence played
% forwards and backwards across odd and even acquisitions.

% Use a pre-defined deBruijn sequence here for this special case
if nDirections==5 && nContrasts==1 && nTrials==25
    if mod(protocolParams.acquisitionNumber,2)
        deBruijn = [5,1,1,3,4,4,5,2,1,5,4,1,2,4,2,3,5,3,1,4,3,3,2,2,5];
        protocolParams.trialTypeOrder = [ones(1,nTrials);deBruijn];
    else
        deBruijn = [5,2,2,3,3,4,1,3,5,3,2,4,2,1,4,5,1,2,5,4,4,3,1,1,5];
        protocolParams.trialTypeOrder = [ones(1,nTrials);deBruijn];
    end
    
else
    
    % Create a random order
    directionOrder = repmat(1:size(modulationsCellArray,1),nReps*nContrasts,1);
    
    if isempty(p.Results.acquisitionOrder)
        nRepeatsPerTrialType = protocolParams.nTrials/(size(modulationsCellArray,2)-1); % the -1 is to exclude the background starts/stops from the calculation
        if (floor(nRepeatsPerTrialType) ~= nRepeatsPerTrialType)
            error('Number trials not integer multiple of number of trial types.');
        end
        protocolParams.trialTypeOrder = [];
        for ii = 1:nRepeatsPerTrialType
            protocolParams.trialTypeOrder = [protocolParams.trialTypeOrder 1:(size(modulationsCellArray,2)-1)];  % the -1 is to exclude the bacground starts/stops from the calculation
        end
    else
        protocolParams.trialTypeOrder = p.Results.acquisitionOrder;
    end
    protocolParams.trialTypeOrder = [protocolParams.trialTypeOrder;directionOrder(:)'];
    
    %randomly shuffle columns
    cols = size(protocolParams.trialTypeOrder,2);
    P = randperm(cols);
    protocolParams.trialTypeOrder = protocolParams.trialTypeOrder(:,P);
    
end


