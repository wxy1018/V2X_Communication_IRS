function AzimuthDistPlot(BaseStation,RISnum)
% This function does a histogram plot of all AOA in presence/absence of RIS
% in each time instance

%% Initilaization

AOD_total = [];
fn = fieldnames(BaseStation);

%% Only paath between UE and Vehicles

for Rx_idx = 2+RISnum:numel(fn)
   
    Rx = BaseStation.(fn{Rx_idx});
    
    for p = 1: numel(fieldnames(Rx))
       
        % Extract data of the path
        Path_data = eval(['Rx.path_id' num2str(p)]);
        AOD = Path_data.departure_phi; % Azimuth of Arrival
        AOD_total = [AOD_total AOD];
    
    end
    
end

pd = fitdist(AOD_total(:),'Kernel','Kernel','epanechnikov');
x_values = -180:1:180;
y = pdf(pd,x_values);
figure(1);
plot(x_values,y);
hold on;

figure(2);
histogram(AOD_total);
hold on;

%% To include the AOA values from RIS to BS
for Rx_idx = 2:1+RISnum
   
    Rx = BaseStation.(fn{Rx_idx});
    
    for p = 1: numel(fieldnames(Rx))
       
        % Extract data of the path
        Path_data = eval(['Rx.path_id' num2str(p)]);
        AOD = Path_data.arrival_phi; % Azimuth of Arrival
        AOD_total = [AOD_total AOD];
    
    end
    
end

figure(2);
histogram(AOD_total);
legend('Without RIS','With RIS');

pd = fitdist(AOD_total(:),'Kernel','Kernel','epanechnikov');
x_values = -180:1:180;
y = pdf(pd,x_values);
figure(1);
plot(x_values,y);
legend('Without RIS','With RIS');

end