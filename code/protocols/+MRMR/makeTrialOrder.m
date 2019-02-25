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
blockLength = 24;
nBlocks = 12;
trialsPerBlock = blockLength/protocolParams.trialDuration;
blockStructure = [ones(1,blockLength/2)*2, ones(1,blockLength/2)]; % each block will be background trials, followed by stimulus trials
protocolParams.trialTypeOrder = repmat(blockStructure, 1, nBlocks); %2s are for the second item in the modulationCellArray, which is the empty trial. 1s are the pulses
protocolParams.trialTypeOrder(2,:) = ones(1,length(protocolParams.trialTypeOrder));

end