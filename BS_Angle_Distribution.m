clc;
clear;

data = load('data-3-BS-16-RIS.mat');
data = data.s;

BSnum = data.time1.BS_number;
RISnum = data.time1.RIS_number;

for t = 1:numel(fieldnames(data))
        
   t_instance = eval(['data.time' num2str(t)]); 
       
   for BS_idx = 1:BSnum
       eval(['BS = t_instance.BS_' num2str(BS_idx)]);
       AzimuthDistPlot(BS,RISnum);
   end
       
end