% To Prepare channel matrix from RIS-UE and BS-UE and BS_UE
clc;
clear;

data = load('NewData.mat');
data = data.s;

%Set transmit power (in mW)
P = 10;
%Bandwidth
B = 20e6;
%Noise figure (in dB)
noiseFiguredB = 13;
%Set the amplitude reflection coefficient
alpha = 1;
%Set number of elements
N = 64;

%Compute the noise power in dBm
sigma2dBm = -174 + 10*log10(B) + noiseFiguredB;
sigma2 = db2pow(sigma2dBm);

angle_distribution = false; % To get the AOD distribution 
Pl_distribution = true;
RatePathloss = true;

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
        BS_UE_RxPower_linear =  10.^(0.1 * BS_UE_RxPower);
        
        [BS_RIS_RxPower,BS_RIS_Interact_Num] = GetBSRISAttenuation(BS...
            ,t_instance.RIS_number);
        
        [RIS_UE_RxPower,RIS_UE_Interact_Num] = ...
            GetRISUEAttenuation(t_instance,t_instance.RIS_number);
        
        EndtoEndPL = RIS_UE_RxPower + BS_RIS_RxPower';
        EndtoEndPL = max(EndtoEndPL,[],1);
        EndtoEndPL_linear = 10.^(0.1 * EndtoEndPL);
        
        figure(3);
        plot(BS_UE_RxPower,'-o');
        hold on;
        plot(EndtoEndPL,'-*');
        legend('DirectPath1','Through RIS1','DirectPath2','Through RIS2',...
            'DirectPath3','Through RIS3','DirectPath4','Through RIS4',...
            'DirectPath5','Through RIS5','DirectPath6','Through RIS6',...
            'DirectPath7','Through RIS7','DirectPath8','Through RIS8',...
            'DirectPath9','Through RIS9');
        
        if RatePathloss
            
            RateSISO = log2(1+ P * BS_UE_RxPower_linear / sigma2);
            RateRIS = log2(1 + P/sigma2 * (sqrt(BS_UE_RxPower_linear) + N...
                * alpha * sqrt(EndtoEndPL_linear)).^2);
            
            figure(4);
            plot(RateSISO,'-o');
            hold on;
            plot(RateRIS,'-*');
            legend('DirectPath1','Through RIS1','DirectPath2','Through RIS2',...
            'DirectPath3','Through RIS3','DirectPath4','Through RIS4',...
            'DirectPath5','Through RIS5','DirectPath6','Through RIS6',...
            'DirectPath7','Through RIS7','DirectPath8','Through RIS8',...
            'DirectPath9','Through RIS9');
            
            improvement = log10((RateRIS - RateSISO) ./ RateSISO); 
            figure(5);
            plot(improvement);
        end
        
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