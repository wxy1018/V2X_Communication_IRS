function H = RIS_ChannelEval(Rx,M_H_Tx,M_V_Tx,M_H_Rx,M_V_Rx)
%% Initialization the parameters

N_Rx = M_V_Rx * M_H_Rx; % Total number of elements  @ Rx 

N_Tx = M_V_Tx * M_H_Tx; % Total number of elements @ planar @ Tx 

fc = 28e9; % Central frequency
c = physconst('LightSpeed'); % Speed of light
lambda = c / fc; % wavelength

fn = fieldnames(Rx);

H = zeros(N_Rx,N_Tx);

% Loop over all path
for p = 1: numel(fn)% To count for all path pls put ''numel(fn)''
    
    % Extract data of the path
    Path_data = eval(['Rx.path_id' num2str(p)]);
    PL_dBm = Path_data.received_power;
    PL_linear = 10 ^ ((PL_dBm-30)/10);
    Phase = Path_data.phase;
    Phase_rad = Phase * pi / 180;
    Betha = PL_linear* exp(1i*Phase_rad); % channel complex coefficient
    
    AOA = Path_data.arrival_phi; % Azimuth of Arrival
    AOA_rad = AOA * pi / 180;

    EOA = Path_data.arrival_theta; % Elevation of Arrival
    EOA_rad = EOA * pi / 180;

    AOD = Path_data.departure_phi; % Azimuth of Departure
    AOD_rad = AOD * pi / 180;

    EOD = Path_data.departure_theta; % Elevation of Departure
    EOD_rad = EOD * pi / 180;
    
    %% Evaluate channel for each path
    
    responseVector = UPA_Evaluate(lambda,M_V_Rx,M_H_Rx,...
        AOA_rad,EOA_rad); % Response vector @ Rx
    
    % The output of the function would be [N_Tx * numPath]
    steeringVector = UPA_Evaluate(lambda,M_V_Tx,M_H_Tx,...
        AOD_rad,EOD_rad); % Steering vector @ Tx
    
    % Channel Model 
    H = H + sqrt(N_Tx*N_Rx) * Betha * ...
        responseVector * steeringVector'; % [N_Rx * N_Tx]

end

end