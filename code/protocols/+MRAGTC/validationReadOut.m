% A simple script to process the validation file and report contrasts


directionNames = {'L-M','LMS','S','Omni'};
receptorNames = {'L_2°','M_2°','S_2°','L_10°','M_10°','S_10°','rod_2°','rod_10°'};

for dd = 1:4
    for ii = 1:5
        k(:,:,ii)=directedDirection{dd}.describe.validation(end-5+ii).contrastActual;
    end
    contrasts = round(100.*median(k,3),1);
    fprintf(['\n' directionNames{dd} ':\n']);
    for rr=1:length(receptorNames)
        fprintf(['\t' receptorNames{rr} ': %2.1f, %2.1f \n'],contrasts(rr,:))
    end
end


protocolParams.boxName = 'BoxD';
protocolParams.calibrationType = 'BoxDRandomizedLongCableAStubbyEyePiece_ND00';
cal = OLGetCalibrationStructure('CalibrationType',protocolParams.calibrationType,'CalibrationDate','latest');

whichXYZ = 'xyzCIEPhys10';
eval(['tempXYZ = load(''T_' whichXYZ ''');']);
eval(['T_xyz = SplineCmf(tempXYZ.S_' whichXYZ ',683*tempXYZ.T_' whichXYZ ',cal.describe.S);']);

backgroundxyY = XYZToxyY(T_xyz*OLPrimaryToSpd(cal,background.differentialPrimaryValues));
fprintf('\n');
fprintf('   * <strong>Background x, y, Y</strong>: %0.3f, %0.3f, %0.1f cd/m2\n',backgroundxyY(1),backgroundxyY(2),backgroundxyY(3));
