close all; clear;
global CRACK PROP CONTROL
addpath Mechanical_parameter_calibration
PaceParalleltoolbox_r2016b('cores',6)

% addpath Coupled_solver
%Mechanical and hydraulic material properties
PROP.E11  = 20.0E3;            %MPa
PROP.E22  = 10.0E3;            %MPa
PROP.nu12 = 0.2;
PROP.nu23 = 0.2;
PROP.G12 = 15.0E3/2/(1+0.2);   %MPa
PROP.eqeps_1t = 0.8E-4;
PROP.eqeps_2t = 0.9E-4;
PROP.alpha_1t = 4.0E-4;
PROP.alpha_2t = 3.5E-4;
PROP.eqeps_1s = 6.8E-4;
PROP.internal_length = 10;       %mm
PROP.plane_thickness = 1;        %mm
PROP.GI = 0.095;                  %N/mm
PROP.GII = PROP.GI;              %N/mm
PROP.sigmaMax = 1E0;             %N/mm^2  MPa
PROP.tauMax = 1E0;               %N/mm^2  MPa
PROP.lambdaN = 0.01;
PROP.lambdaT = 0.01;
PROP.alpha = 4;
PROP.beta = 4;
PROP.m = PROP.alpha*(PROP.alpha-1)*PROP.lambdaN^2/(1-PROP.alpha*PROP.lambdaN^2);
PROP.n = PROP.beta*(PROP.beta-1)*PROP.lambdaT^2/(1-PROP.beta*PROP.lambdaT^2);
PROP.deltaN = PROP.GI/PROP.sigmaMax*PROP.alpha*PROP.lambdaN*(1-PROP.lambdaN)^(PROP.alpha-1)*(PROP.alpha/PROP.m+1)*(PROP.lambdaN*PROP.alpha/PROP.m+1)^(PROP.m-1);
PROP.deltaT = PROP.GII/PROP.tauMax*PROP.alpha*PROP.lambdaT*(1-PROP.lambdaT)^(PROP.beta-1)*(PROP.beta/PROP.n+1)*(PROP.lambdaT*PROP.beta/PROP.n+1)^(PROP.n-1);
PROP.PenaltyStiffness = 1e8*PROP.sigmaMax/PROP.deltaN;
PROP.dGnt = 0;
PROP.dGtn = 0;
PROP.deltaN_conj = PROP.deltaN-PROP.deltaN*(PROP.dGnt/PROP.GI)^(1/PROP.alpha);
PROP.deltaT_conj = PROP.deltaT-PROP.deltaT*(PROP.dGtn/PROP.GI)^(1/PROP.beta);
PROP.GammaN = -PROP.GI*(PROP.alpha/PROP.m)^PROP.m ;
PROP.GammaT = (PROP.beta/PROP.n)^PROP.n ;


%Initial cracks: perforated from the boundary of borehole
CRACK  = [0 0; 323 0 ];

% read abaqus input file to obtain nodes, coordinates, connectivity, surfaces and sets;
file = 'Aniso_vertical_calibration.inp';

[EXTDISP,BNoset,BElset,Bsurface] = Preprocessor(file);

update=false;  levelSet(update);    % initiate level set value for every node
StateV_initialization(PROP);	      % Initialize problem history dependent varibles
buildNonlocalTable(PROP,BElset);       % find gauss points within nonlocal influence zone for each gauss point

% surf={'Surf-2','Surf-3','Surf-4'};
% applied_stress = [0 -1;-2 0;0 1;];
surf={};
applied_stress = [];
[EXTFORCE] = StressBoundary(Bsurface,surf,applied_stress);      % stress distributions

CONTROL.Theta = 0.6;
CONTROL.timeI = 0.0;        % Starting time
CONTROL.timeF = 0.6;        % Ending time  unit second
CONTROL.deltaT = 0.01;         % Time increment
CONTROL.Ncutting = 15;      % Allowed times of cutting back
CONTROL.Niter =20;         % Maximum number of iteration for each increment
CONTROL.TOL = 1e-5;         % Convergence tolerance
NR_calibration_solver(CONTROL,PROP,EXTFORCE,EXTDISP)	











