clc;
clear;

data = load('data-3-BS-16-RIS.mat');
data = data.s;

RISnum = data.time1.RIS_number;

RIS_angle_Config = 'LOS'; % 'LOS' or 'all'

RIS_tot_angles = NaN(1,RISnum);

 for t = 1:numel(fieldnames(data))
        
        % set 'all' if you wanna get all the angles
        % set 'LOS' if you wanna get the LOS angles
        RIS_angles = RIS_Azimuth(eval(['data.time' num2str(t)]),RIS_angle_Config); 
        RIS_tot_angles = [RIS_tot_angles;RIS_angles];
        
 end
    
for i = 1:RISnum
       
        angles = RIS_tot_angles(:,i);
        angles = angles(~isnan(angles));

        figure(i);
        hold on;
        histogram(angles,60,'Normalization','probability');
        legend(RIS_angle_Config);
        
end

