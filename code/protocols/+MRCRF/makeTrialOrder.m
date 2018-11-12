function protocolParams = makeTrialOrder(protocolParams,modulationsCellArray,varargin)
% Generate the trial order for the MRCRF experiment.
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

%% Get trial order
directionOrder = repmat(1:size(modulationsCellArray,1),6,1);

if isempty(p.Results.acquisitionOrder)
    nRepeatsPerTrialType = protocolParams.nTrials/(size(modulationsCellArray,2)-1); % the -1 is to exclude the bacground starts/stops from the calculation
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