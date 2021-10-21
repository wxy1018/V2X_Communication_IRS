% To Prepare channel matrix from RIS-UE and BS-UE and BS_UE

data = load('NewData.mat');
data = data.s;

angle_distribution = false; % To get the AOD distribution 
Pl_distribution = true;

if angle_distribution

    for t = 1:numel(fieldnames(data))
        
       t_instance = eval(['data.time' num2str(t)]); 
       BS = t_instance.BS_1;
       AzimuthDistPlot(BS,t_instance.RIS_number);
       
    end
    
end

if Pl_distribution

    for t = 1:numel(fieldnames(data))
       
        t_instance = eval(['data.time' num2str(t)]); 
        BS = t_instance.BS_1;
        [BS_UE_RxPower,BS_UE_Interact_Num] = GetBSUEAttenuation(BS,...
            t_instance.RIS_number);
        [BS_RIS_RxPower,BS_RIS_Interact_Num] = GetBSRISAttenuation(BS...
            ,t_instance.RIS_number);
        [RIS_UE_RxPower,RIS_UE_Interact_Num] = ...
            GetRISUEAttenuation(t_instance,t_instance.RIS_number);
        EndtoEndPL = RIS_UE_RxPower + BS_RIS_RxPower';
        EndtoEndPL = max(EndtoEndPL,[],1);
        
        plot(BS_UE_RxPower);
        hold on;
        plot(EndtoEndPL);
        legend('DirectPath1','Through RIS1','DirectPath2','Through RIS2',...
            'DirectPath3','Through RIS3','DirectPath4','Through RIS4',...
            'DirectPath5','Through RIS5','DirectPath6','Through RIS6',...
            'DirectPath7','Through RIS7','DirectPath8','Through RIS8',...
            'DirectPath9','Through RIS9');
        
    end
    
end
RISCoeff = ones(64);
% Loop over time instances
for t = 1:9
    
   t_instance = eval(['data.time' num2str(t)]); 
   [h_RIS1_UE, h_RIS2_UE, h_RIS3_UE, h_RIS4_UE] = channelEval(t_instance,...
       'RIS_UE_Channel'); % UE-RIS channel 
   [h_BS_RIS1, h_BS_RIS2, h_BS_RIS3, h_BS_RIS4] = channelEval(t_instance,...
       'RIS_BS_Channel'); % RIS_BS channel
   [h_BS_UE,~,~,~] = channelEval(t_instance,'BS_UE_Channel'); % UE_BS chan
   
   H_enhanced = h_BS_UE + h_RIS1_UE * RISCoeff * h_BS_RIS1 + h_RIS2_UE * RISCoeff * h_BS_RIS2 + ...
       h_RIS3_UE * RISCoeff * h_BS_RIS3 + h_RIS4_UE * RISCoeff* h_BS_RIS4;
   
end