clear; clc;close all;

define_constants;

case_comments = ...
    {' Power Flow Data for 118-bus, 186-branch case',...
    '  National Renewable Energy Lab (NREL) 118-bus Transmission Network',...
    '  From the Paper:',...
    '  [1] Pena, Ivonne, Carlo Brancucci Martinez-Anido, and Bri-Mathias Hodge. "An extended IEEE 118-bus test system with high renewable penetration." IEEE Transactions on Power Systems 33, no. 1 (2018): 281-289.',...
    '@article{pena2018extended,',...
      'title={An extended IEEE 118-bus test system with high renewable penetration},',...
      'author={Pena, Ivonne and Martinez-Anido, Carlo Brancucci and Hodge, Bri-Mathias},',...
      'journal={IEEE Transactions on Power Systems},',...
      'volume={33},',...
      'number={1},',...
      'pages={281--289},',...
      'year={2018},',...
      'publisher={IEEE}',...
    '}'
    '  original case by I. Pena, C.B. Martinez-Anido, and B. Hodge.',...
    '  this matpower case is created by X. Geng',...
    'Matpower'
    };

excase = 'case118';

thiscase = 'case_nrel118';
exmpc = loadcase(excase);

%% Some Parameters
nbus = 118; nbranch = 186;
% npv = 1; ncap = 4;
% ngen = 1+npv+ncap; % substation and photovoltaic
mpc.bus = zeros(nbus, size(exmpc.bus,2));
mpc.branch = zeros(nbranch, size(exmpc.branch,2));

%% Per Unit Value Settings
mpc.version = '2';
mpc.baseMVA = 1; % 1MVA
basekV = 12; %12kV, thus Z_base = 144Ohm
baseOhm = (basekV*1e3)^2 / mpc.baseMVA / 1e6;
assert(baseOhm == 144); % number from [1]

%% Bus Settings
mpc.bus(:,BUS_I) =(1:nbus)';
mpc.bus(:, BASE_KV) = basekV; % kV
mpc.bus(:, BUS_TYPE) = PQ;
mpc.bus(1, BUS_TYPE) = REF;
mpc.bus(:, GS) = 0; mpc.bus(:, BS) = 0; 
mpc.bus(:, BUS_AREA) = 1; 
mpc.bus(:, VM) = 1;
mpc.bus(:, VA) = 0;
mpc.bus(:, ZONE) = 1;
mpc.bus(:, VMAX) = 1.1;
mpc.bus(:, VMIN) = 0.9;

% Real/Reactive Loads
load_buses = round([...
3 
5 
6 
7 
8 
9 
10
11
12
14
16
17
18
19
22
24
25
27
28
29
31
32
33
34
35
36
37
38
39
40
41
42
43
44
46
47
48
50
52
54
55
56]);

load_MVA = [...
0.057 
0.121 
0.049 
0.053 
0.047 
0.068 
0.048
0.067
0.094
0.057
0.053
0.057
0.112
0.087
0.063
0.135
0.100
0.048
0.038
0.044
0.053
0.223
0.123
0.067
0.094
0.097
0.281
0.117
0.131
0.030
0.046
0.054
0.083
0.057
0.134
0.045
0.196
0.045
0.315
0.061
0.055
0.130  ];% all in MVA

mpc.bus(load_buses, PD) = load_MVA*0.9; % all in MVA
mpc.bus(load_buses, QD) = load_MVA*sqrt(1-0.9^2); % all in MVA

%% Shunt Capacitors
cap_buses = [19;21;30;53];
cap_MVar = 0.6*ones(length(cap_buses),1); % MVar
% If regarded as negative reactive loads
% mpc.bus(cap_buses, QD) = mpc.bus(cap_buses, QD) - cap_MVar;
mpc.bus(cap_buses, BUS_TYPE) = PV;

%% Photovoltaic Panels
mpc.bus(45, BUS_TYPE) = PV; % the only Photovoltaic Panel

%% Generator Settings
INF_CAP = sum(load_MVA)*10;
mpc.gen = zeros(ngen, size(exmpc.gen,2));
mpc.gen(:,GEN_BUS) = round( [1;45;cap_buses] );
% Regard the PV panels are pure
mpc.gen(:, QMAX) = [INF_CAP;0;cap_MVar];
mpc.gen(:, QMIN) = [-INF_CAP;0;-cap_MVar];
mpc.gen(:, VG) = 1;
mpc.gen(:,MBASE) = mpc.baseMVA;
mpc.gen(:,GEN_STATUS) = 1;
pv_capacity = 5; %MW
mpc.gen(:, PMAX) = [INF_CAP; pv_capacity; zeros(ncap,1)];
mpc.gen(:, PMIN) = [-INF_CAP; 0; zeros(ncap,1)];
% did not find gencost information in the paper
mpc.gencost = repmat([	2	0	0	2	30	0] , ngen, 1);

%% Branch Settings
RX_Ohm = [...
0.160 0.388
0.824 0.315
0.144 0.349
1.026 0.421
0.741 0.466
0.528 0.468
0.358 0.314
2.032 0.798
0.502 0.441
0.372 0.327
1.431 0.999
0.429 0.377
0.671 0.257
0.457 0.401
1.008 0.385
0.153 0.134
0.971 0.722
1.885 0.721
0.138 0.334
0.251 0.096
1.818 0.695
0.225 0.542
0.127 0.028
0.284 0.687
0.171 0.414
0.414 0.386
0.210 0.196
0.395 0.369
0.248 0.232
0.279 0.260
0.205 0.495
0.263 0.073
0.071 0.171
0.625 0.273
0.510 0.209
2.018 0.829
1.062 0.406
0.610 0.238
2.349 0.964
0.115 0.278
0.159 0.384
0.934 0.383
0.506 0.163
0.095 0.195
1.915 0.769
0.157 0.379
1.641 0.670
0.081 0.196
1.727 0.709
0.112 0.270
0.674 0.275
0.070 0.170
2.041 0.780
0.813 0.334
0.141 0.340];

mpc.branch(:, [BR_R, BR_X]) = RX_Ohm / baseOhm; % in Ohm
mpc.branch(:, BR_STATUS) = 1;
mpc.branch(:,ANGMIN) = -360; mpc.branch(:,ANGMAX) = 360;

result = runopf(mpc);
assert(result.success);

mpc.gen(:, PG) = result.gen(:, PG); mpc.gen(:, QG) = result.gen(:, QG);

savecase(thiscase, case_comments, mpc);
