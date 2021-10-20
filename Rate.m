% To Prepare channel matrix from RIS-UE and BS-UE and BS_UE

data = load('NewData.mat');
data = data.s;

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