function ChannelMatrix = channelEval(t_instance,cond,NamingStruc,ChannelStruct)
% [h1, h2, h3, h4 ] = deal(0);
if strcmp(cond, 'RIS_UE_Channel')
    
    M_H_Rx= 1; % Number of antennas in horizontal axis @ Rx
    M_V_Rx = 1; % Number of antennas in vertical axis @ Rx

    M_H_Tx= 16; % Number of antennas in horizontal axis @ planar (Tx)
    M_V_Tx = 16; % Number of antennas in vertical axis @ planar (Tx)

    % Loop over all RIS deployed in the cell
    for R_idx = 1 : t_instance.RIS_number
    
        RIS = eval(['t_instance.RIS_' num2str(R_idx)]); % Extract soecific RIS
        fn = fieldnames(RIS); % Extract the name of all fields
    
        Rx_channel = zeros(numel(fieldnames(NamingStruc)),M_H_Tx*M_V_Tx); % Channel for each RIS
    
        %Loop over vehicles (RX)
        for Rx_idx = 1:numel(fn)-1
        
            Rx = RIS.(fn{Rx_idx+1});
            Rx_channel(NamingStruc.(fn{Rx_idx+1}),:) = ...
                RIS_ChannelEval(Rx,M_H_Tx,M_V_Tx,M_H_Rx,M_V_Rx); % [ 1 * N_RIS]
 
        end
    
        eval(['ChannelStruct.RIS' num2str(R_idx) ' = Rx_channel']);

    end
    
    ChannelMatrix = ChannelStruct;
    
elseif strcmp(cond, 'RIS_BS_Channel')
    
    M_H_Tx = 8; % Number of antennas in horizontal axis @ planar (Tx)
    M_V_Tx = 8; % Number of antennas in vertical axis @ planar (Tx)
    
    M_H_Rx = 16; % Number of antennas in horizontal axis @ Rx
    M_V_Rx = 16; % Number of antennas in vertical axis @ Rx
    
    for BS_idx = 1:t_instance.BS_number
        
        % Loop over all RIS deployed in the cell
        for R_idx = 1 : t_instance.RIS_number
        
            Rx = eval(['t_instance.BS_' num2str(BS_idx) '.RIS_' ...
                num2str(R_idx)]); % extract soecific RIS
            Rx_channel = ...
                RIS_ChannelEval(Rx,M_H_Tx,M_V_Tx,M_H_Rx,M_V_Rx); % [N_RX * N_TX]
            eval(['ChannelStruct.BS' num2str(BS_idx), '.RIS' num2str(R_idx) ' = Rx_channel;']);
        end
    end 
    
    ChannelMatrix = ChannelStruct;
    
elseif strcmp(cond, 'BS_UE_Channel')
    
    M_H_Tx = 8; % Number of antennas in horizontal axis @ planar (Tx)
    M_V_Tx = 8; % Number of antennas in vertical axis @ planar (Tx)
    
    M_H_Rx = 1; % Number of antennas in horizontal axis @ Rx
    M_V_Rx = 1; % Number of antennas in vertical axis @ Rx
    
    for BS_idx = 1:t_instance.BS_number 
        
        eval(['fn = fieldnames(t_instance.BS_' num2str(BS_idx) ');' ]); % Extract the name of all fields

        for Rx_idx = t_instance.RIS_number+2 : numel(fn) 
        
            eval( ['Rx = t_instance.BS_' num2str(BS_idx) '.(fn{Rx_idx});'] );
            eval(['ChannelStruct.BS' num2str(BS_idx) ...
                '(NamingStruc.(fn{Rx_idx}),:) = RIS_ChannelEval(Rx,M_H_Tx,M_V_Tx,M_H_Rx,M_V_Rx)']); % [ 1 * N_Tx]
            
        end
        
    end

    ChannelMatrix = ChannelStruct;
else
    
end
end
