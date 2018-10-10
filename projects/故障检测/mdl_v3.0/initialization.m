
%% FDI design initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Np_vm=0;
% Np_omega_r=0;
% Np_omega_g=0;
% Np_tau_g=0;
% Np_P_g=0;
% Np_beta=0;


%pitch system enhanced
Ppb = [-2; -2.5];
A_f = .5*Bpb*Cpb;
Apb_E = Apb+A_f;
%Apb_E = Apb;
Lpb = place(Apb_E',Cpb',Ppb);
Lpb = Lpb';
Apb_E_bar = Apb_E-Lpb*Cpb;

%pitch system original
Lpb_FD = place(Apb',Cpb',Ppb);
Lpb_FD = Lpb_FD';
Apb_bar = Apb-Lpb_FD*Cpb;

%drive train system
A_DT = Addt(2:3,2:3);
B_DT = [Bddt(2:3,2) Addt(2:3,1)];
C_DT = [1 0 ];
P_DT = [-2; -2.5];
L_DT = place(A_DT',C_DT',P_DT);
L_DT = L_DT';
A_DT_bar = A_DT-L_DT*C_DT;
