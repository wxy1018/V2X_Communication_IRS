function [h1,h2, h3, h4] = channelEval(t_instance,cond)
[h1, h2, h3, h4 ] = deal(0);
if strcmp(cond, 'RIS_UE_Channel')
    
    M_H_Rx= 1; % Number of antennas in horizontal axis @ Rx
    M_V_Rx = 1; % Number of antennas in vertical axis @ Rx

    M_H_Tx= 8; % Number of antennas in horizontal axis @ planar (Tx)
    M_V_Tx = 8; % Number of antennas in vertical axis @ planar (Tx)

    % Loop over all RIS deployed in the cell
    for R_idx = 1 : t_instance.RIS_number
    
        RIS = eval(['t_instance.RIS_' num2str(R_idx)]); % extract soecific RIS
        fn = fieldnames(RIS); % Extract the name of all fields
    
        Rx_channel = zeros(numel(fn)-1,M_H_Tx*M_V_Tx); % Channel for each RIS
    
        %Loop over vehicles (RX)
        for Rx_idx = 1:numel(fn)-1
        
            Rx = RIS.(fn{Rx_idx+1});
            Rx_channel(Rx_idx,:) = ...
                RIS_ChannelEval(Rx,M_H_Tx,M_V_Tx,M_H_Rx,M_V_Rx); % [ 1 * N_Tx]
 
        end
    
        eval(['h' num2str(R_idx) '=Rx_channel']);
    end
    
elseif strcmp(cond, 'RIS_BS_Channel')
    
    M_H_Tx = 8; % Number of antennas in horizontal axis @ planar (Tx)
    M_V_Tx = 8; % Number of antennas in vertical axis @ planar (Tx)
    
    M_H_Rx = 8; % Number of antennas in horizontal axis @ Rx
    M_V_Rx = 8; % Number of antennas in vertical axis @ Rx
   
    % Loop over all RIS deployed in the cell
    for R_idx = 1 : t_instance.RIS_number
        
        Rx = eval(['t_instance.BS_1.RIS_' ...
            num2str(R_idx)]); % extract soecific RIS
        Rx_channel = ...
            RIS_ChannelEval(Rx,M_H_Tx,M_V_Tx,M_H_Rx,M_V_Rx); % [N_RX * N_TX]
        eval(['h' num2str(R_idx) '=Rx_channel']);
    end
    
elseif strcmp(cond, 'BS_UE_Channel')
    
    M_H_Tx = 8; % Number of antennas in horizontal axis @ planar (Tx)
    M_V_Tx = 8; % Number of antennas in vertical axis @ planar (Tx)
    
    M_H_Rx = 1; % Number of antennas in horizontal axis @ Rx
    M_V_Rx = 1; % Number of antennas in vertical axis @ Rx
    
    extData = 5;
        
    fn = fieldnames(t_instance.BS_1); % Extract the name of all fields
    Rx_channel = zeros(numel(fn) - extData,M_H_Tx*M_V_Tx); % Channel for each RIS
    

    for Rx_idx = 1 : numel(fn) - extData
        
        Rx = t_instance.BS_1.(fn{Rx_idx + extData});
        Rx_channel(Rx_idx,:) = ...
                RIS_ChannelEval(Rx,M_H_Tx,M_V_Tx,M_H_Rx,M_V_Rx); % [ 1 * N_Tx]
            
    end
    
    h1 = Rx_channel;
    
else
    
end
end
