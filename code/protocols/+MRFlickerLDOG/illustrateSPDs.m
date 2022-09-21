% Illustration of photoreceptor SPDs and modulations
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
[protocolParams,LplusSDirection,LminusSDirection,RodMelDirection,LightFluxDirection,modBackground, ol] = ...
    MRFlickerLDOG.setAndSaveParams(protocolParams);

Sin = LplusSDirection.calibration.describe.S;
Sout = [350 1 400];

wavelengthSupport = SToWls(Sin);

figHandle = figure();
subplot(3,2,1)
plot(wavelengthSupport,LplusSDirection.describe.directionParams.T_receptors');
box off

subplot(3,2,3)
vals = (LightFluxDirection.SPDdifferentialDesired+modBackground.SPDdifferentialDesired)./Sin(2);
plot(wavelengthSupport,vals)
hold on
vals = modBackground.SPDdifferentialDesired./Sin(2);
plot(wavelengthSupport,vals,'Color',[0.5 0.5 0.5])
box off

subplot(3,2,4)
vals = (LplusSDirection.SPDdifferentialDesired+modBackground.SPDdifferentialDesired)./Sin(2);
plot(wavelengthSupport,vals)
hold on
vals = modBackground.SPDdifferentialDesired./Sin(2);
plot(wavelengthSupport,vals,'Color',[0.5 0.5 0.5])
box off

subplot(3,2,5)
vals = (RodMelDirection.SPDdifferentialDesired+modBackground.SPDdifferentialDesired)./Sin(2);
plot(wavelengthSupport,vals)
hold on
vals = modBackground.SPDdifferentialDesired./Sin(2);
plot(wavelengthSupport,vals,'Color',[0.5 0.5 0.5])
box off

subplot(3,2,6)
vals = (LminusSDirection.SPDdifferentialDesired+modBackground.SPDdifferentialDesired)./Sin(2);
plot(wavelengthSupport,vals)
hold on
vals = modBackground.SPDdifferentialDesired./Sin(2);
plot(wavelengthSupport,vals,'Color',[0.5 0.5 0.5])
box off


