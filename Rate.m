% To Prepare channel matrix from RIS-UE and BS-UE and BS_UE
% The code supports the dynamic user naming
clc;
clear;

data = load('data-3-BS-16-RIS.mat');
data = data.s;

%% Extract the initial variables needed

% Extract necessary information from data
BSnum = data.time1.BS_number;
RISnum = data.time1.RIS_number;

%% To manage the dynamic name of the vehicles
groupNum = 11; % Vehicle naming from 25-34
UserGroup = 5; % inside each group there are (27.0 27.1 27.2 27.3 27.4) 

NamingStruc = struct;

for i = 25:25+groupNum-1
    for j = 0:UserGroup-1
        
        eval(['NamingStruc.veh_' num2str(i) '_' num2str(j) '=' num2str((i-25)*UserGroup+j+1)]);
    
    end
end


H_UE_RIS = struct;

for i = 1:RISnum
    eval(['H_UE_RIS.RIS' num2str(i) '=zeros(UserGroup*groupNum,256);']);
end


H_RIS_BS = struct; 

for j = 1:BSnum
    
    for i = 1:RISnum
        
        eval(['H_RIS_BS.BS' num2str(j) '.RIS' num2str(i) '=zeros(256,64);']);

    end
    
end

H_UE_BS = struct;

for i = 1:BSnum
   eval(['H_UE_BS.BS' num2str(i) '= zeros(UserGroup*groupNum,64);' ]);
end

H_enhanced = struct;

for i = 1:BSnum
    eval(['H_enhanced.BS' num2str(i) '= zeros(UserGroup*groupNum,64);']);
end


%% Initialization

%Set transmit power (in mW)
P = 10;
%Bandwidth
B = 20e6;
%Noise figure (in dB)
noiseFiguredB = 13;
%Set the amplitude reflection coefficient
alpha = 1;
%Set number of elements @ RIS
N = 256;

%Compute the noise power in dBm
sigma2dBm = -174 + 10*log10(B) + noiseFiguredB;
sigma2 = db2pow(sigma2dBm);

distance = false; % need to be modified
angle_distribution = false; % To get the AOD distribution 
Pl_distribution = false;
RatePathloss = false; % enable also Pl_distribution
checksorting = false; % to check if the powers are sorted 
RIS_angle_distribution = false;
RIS_angle_Config = 'LOS'; % 'LOS' or 'all'
plotsvnRIS = true; 

%% Distribution of AOD from RIS(Dynamic number of Rx is not important here)

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
% (not updated to support the dynamic users)
% OLD Results: They are sorted with respect to the powers


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


if distance % needs to be checked and completed
    
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

%% To get the angle distribution from BS (works with dynamic Rx numbers)

if angle_distribution

    for t = 1:numel(fieldnames(data))
        
       t_instance = eval(['data.time' num2str(t)]); 
       
       for BS_idx = 1:BSnum
           eval(['BS = t_instance.BS_' num2str(BS_idx)]);
           AzimuthDistPlot(BS,t_instance.RIS_number);
       end
       
    end
    
end

%% To get Path loss plot to understand if we gain by deploying RIS 
% result: Not really as the PL through RIS is very high (Need to be
% modified with new formula)

BS_UE_RxPower_tot = zeros(BSnum,28);
BS_RIS_RxPower_tot = zeros(BSnum,RISnum);
if Pl_distribution

    for t = 1:numel(fieldnames(data))
       
        t_instance = eval(['data.time' num2str(t)]); 
        
        for BS_idx = 1:BSnum
            
            BS = eval(['t_instance.BS_' num2str(BS_idx)]);
            [BS_UE_RxPower,BS_UE_Interact_Num] = GetBSUEAttenuation(BS,...
            RISnum);
        
            if BS_idx == 2
                BS_UE_RxPower_tot(BS_idx,[1:8,10:28]) = BS_UE_RxPower;
            elseif BS_idx == 1
                BS_UE_RxPower_tot(BS_idx,:) = BS_UE_RxPower;
            else
                BS_UE_RxPower_tot(BS_idx,[1:25,27:28]) = BS_UE_RxPower([1:9,11:28]);
            end
        end
        

        %BS_UE_RxPower_tot(:,t) = BS_UE_RxPower;
        %BS_UE_RxPower_linear =  10.^(0.1 * BS_UE_RxPower);
        
        for BS_idx = 1:BSnum
            
            BS = eval(['t_instance.BS_' num2str(BS_idx)]);
            [BS_RIS_RxPower,BS_RIS_Interact_Num] = GetBSRISAttenuation(BS...
            ,RISnum);
            BS_RIS_RxPower_tot(BS_idx,:) = BS_RIS_RxPower;
        end
        
        [RIS_UE_RxPower,RIS_UE_Interact_Num] = ...
            GetRISUEAttenuation(t_instance,RISnum);
        
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

%% To generate the complete channel (support dynamic users)

RISCoeff = eye(256);

% Loop over time instances
for t = 1:numel(fieldnames(data))
    
   t_instance = eval(['data.time' num2str(t)]); 
   H_UE_RIS = channelEval(t_instance,...
       'RIS_UE_Channel',NamingStruc,H_UE_RIS); % UE-RIS channel 
   H_RIS_BS = channelEval(t_instance,...
       'RIS_BS_Channel',[],H_RIS_BS); % RIS_BS channel
   H_UE_BS = channelEval(t_instance,'BS_UE_Channel',NamingStruc,H_UE_BS); % UE_BS channel
   
   for BS_idx = 1:BSnum
       
       for rx_idx = 1:55
           
           eval(['H_enhanced.BS' num2str(BS_idx) ...
               '(rx_idx,:) =  H_UE_BS.BS' num2str(BS_idx) '(rx_idx,:);']);
       
           for RIS_idx = 1:RISnum
          
                RISchan = eval(['H_UE_RIS.RIS' num2str(RIS_idx) ...
                    '(' num2str(rx_idx) ',:);']);
                Bschan = eval(['H_RIS_BS.BS' num2str(BS_idx) ...
                    '.RIS' num2str(RIS_idx)]);
                eval(['H_enhanced.BS' num2str(BS_idx) ...
                    '(rx_idx,:) = H_enhanced.BS' num2str(BS_idx)...
                    '(rx_idx,:) + RISchan * RISCoeff * Bschan;'])
          
           end
      
       end
              
   end
   
   % Plot SVD for each RIS (RIS-UE)
   if plotsvnRIS
      
       for RIS_idx = 1:RISnum
           h = eval(['H_UE_RIS.RIS' num2str(RIS_idx)]);
           [~,sn,~] = svd(h);
           sn = diag(sn);
           plot(log10(sn(1:28)));
           hold on;
       end
       
       xlabel('Ordered Singular Values','FontSize',20);
       ylabel('Singular Values','FontSize',20);
       
   end
   
end