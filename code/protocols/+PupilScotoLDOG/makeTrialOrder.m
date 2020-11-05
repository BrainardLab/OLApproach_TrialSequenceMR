function protocolParams = makeTrialOrder(protocolParams,varargin)
% Generate the trial order for the MRMMT experiment. Just a dummy order for
% now.
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
repElement = [1 2];
% The item from the modulation cell array
protocolParams.trialTypeOrder(1,:) = repmat(repElement,1,protocolParams.nTrials./length(repElement));
% The relative contrast
protocolParams.trialTypeOrder(2,:) = ones(1,protocolParams.nTrials);

