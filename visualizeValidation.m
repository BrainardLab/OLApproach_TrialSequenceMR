% validation information is stored within direction objects. 
% For example, load one up: 
load('/Users/ldogexperimenter/Dropbox (Aguirre-Brainard Lab)/LDOG_data/Experiments/OLApproach_TrialSequenceMR/MRMaxFlash/DirectionObjects/N293/2019-11-21/directionObject.mat')

% this will load up the modDirection object, which contains the relevant
% information
% modDirection contains the sub-subfields modDirection.describe.validation
% For your experiment, the validation subfield should be 10 units longer,
% corresponding to 5 measurements taken prior to the experiment, and 5
% measurements taken after the experiment

% to get luminance check out the luminance subfield: (example showing the
% first validation measure)
modDirection.describe.validation(1).luminanceActual
% this contains 5 values: 1) luminance of the background (for the bipolar
% modulation, all half-on), 2) luminance of the positive arm (all mirrors
% on), 3) luminance of the negative arm (all mirrors off), 4) difference in
% luminance between background and positive arm, 5) difference in luminance
% between background and negative arm

% to visualize the spectra:
% background spd:
backgroundSPD = modDirection.describe.validation(1).SPDbackground.measuredSPD;
% positive arm:
positiveArmSPD = modDirection.describe.validation(1).SPDcombined(1).measuredSPD;
% negative arm:
negativeArmSPD = modDirection.describe.validation(1).SPDcombined(2).measuredSPD;

% visualize SPDs;
figure; hold on;
wavelengths = modDirection.calibration.describe.S(1):modDirection.calibration.describe.S(2): modDirection.calibration.describe.S(1) + modDirection.calibration.describe.S(2)*modDirection.calibration.describe.S(3) - modDirection.calibration.describe.S(2);
plot(wavelengths, backgroundSPD);
plot(wavelengths, positiveArmSPD);
plot(wavelengths, negativeArmSPD);
legend('Background', 'Positive Arm', 'Negative Arm');
xlabel('Wavelength')
ylabel('Power')