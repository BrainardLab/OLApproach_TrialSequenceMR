function protocolParams = makeTrialOrder(protocolParams, acquisitionNumber, varargin)
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




%% Get trial order
pathToFunction = mfilename('fullpath');
[path] = fileparts(pathToFunction);
load(fullfile(path, 'mSequences.mat'));
seqs(seqs == 0) = 2;

protocolParams.trialTypeOrder = seqs(acquisitionNumber,:);
protocolParams.trialTypeOrder(2,:) = ones(1,length(protocolParams.trialTypeOrder));

end