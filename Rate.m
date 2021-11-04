% To Prepare channel matrix from RIS-UE and BS-UE and BS_UE
clc;
clear;

data = load('RIS_data_w_transmission.mat');
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

distance = false;
angle_distribution = false; % To get the AOD distribution 
Pl_distribution = true;
RatePathloss = false; % enable also Pl_distribution
checksorting = false; % to check if the powers are sorted 
RIS_angle_distribution = false;
RIS_angle_Config = 'LOS'; % 'LOS' or 'all'

%% Distribution of AOD from RIS 

RIS_tot_angles = NaN(1,data.time1.RIS_number);

if RIS_angle_distribution
   
    for t = 1:numel(fieldnames(data))
        
        % set 'all' if you wanna get all the angles
        % set 'LOS' if you wanna get the LOS angles
        RIS_angles = RIS_Azimuth(eval(['data.time' num2str(t)]),RIS_angle_Config); 
        RIS_tot_angles = [RIS_tot_angles;RIS_angles];
    end
    
    for i = 1:data.time1.RIS_number
       
        angles = RIS_tot_angles(:,i);
        angles = angles(~isnan(angles));
        %pd = fitdist(angles,'Kernel','Kernel','epanechnikov');
        %x_values = -180:1:180;
        %y = pdf(pd,x_values);
        figure(i);
        hold on;
        %plot(x_values,y);
        histogram(angles,60,'Normalization','probability');
        legend('all','LOS');
    end
    
end
%% To check if the path are sorted with respect to power or not
% They are soted with respect to the powers


if checksorting
   
    for t = 1:numel(fieldnames(data))
        
         t_instance = eval(['data.time' num2str(t)]);
         BS = t_instance.BS_1;
         fn = fieldnames(BS);
         powersoritng = zeros(25,numel(fn)-5);
         interactionsorting = Inf(25,numel(fn)-5);
         
         for rx_idx = 1:numel(fn)-5
             rx = BS.(fn{rx_idx+5});
             for p = 1:numel(fieldnames(rx))
                path = eval(['rx.path_id' num2str(p)]);
                powersoritng(p,rx_idx) = path.received_power;
                interactionsorting(p,rx_idx) = path.interaction;
             end
         end
         
    end
end


if distance 
    
    BS = data.time1.BS_1;
    fn = fieldnames(BS);
    RIS_pos = zeros(data.time1.RIS_number,3);
    
    BS_pos = BS.RIS_1.path_id1.coordinates(1,:);
    
    for i = 1:data.time1.RIS_number
    RIS_pos(i,:) = BS.(fn{i+1}).path_id1.coordinates(2,:);
    end
    
    distance_BS_RIS = RIS_pos - BS_pos;
    for i = 1:4
    distance_BS = sqrt(sum(abs(distance_BS_RIS(1,:)).^2));
    end
    
end

%% To get the angle distribution from BS

if angle_distribution

    for t = 1:numel(fieldnames(data))
        
       t_instance = eval(['data.time' num2str(t)]); 
       BS = t_instance.BS_1;
       AzimuthDistPlot(BS,t_instance.RIS_number);
       
    end
    
end

%% To get Path loss plot to understand if we gain by deploying RIS 
% result: Not really as the PL through RIS is very high
BS_UE_RxPower_tot = zeros(28,9);
if Pl_distribution

    for t = 1:numel(fieldnames(data))
       
        t_instance = eval(['data.time' num2str(t)]); 
        BS = t_instance.BS_1;
        [BS_UE_RxPower,BS_UE_Interact_Num] = GetBSUEAttenuation(BS,...
            t_instance.RIS_number);
        BS_UE_RxPower_tot(:,t) = BS_UE_RxPower;
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

%% To generate the complete channel

RISCoeff = eye(64);
%RISCoeff = diag(rand(1,64));
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