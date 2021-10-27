function angledist = RIS_Azimuth(scenario,conf)

angledist = NaN(numel(fieldnames(scenario.RIS_1))-1,scenario.RIS_number);

for ris_idx = 1:scenario.RIS_number
   
    RIS = eval(['scenario.RIS_' num2str(ris_idx)]);
    fn = fieldnames(RIS);

    for rx_idx = 1:numel(fn)-1
    
        rx = RIS.(fn{rx_idx+1});
        path = rx.path_id1;
        
        if strcmp(conf, 'all')
            
            angledist(rx_idx,ris_idx) = path.departure_phi;
        
        elseif strcmp(conf, 'LOS') && path.interaction == 0
            
            angledist(rx_idx,ris_idx) = path.departure_phi;

        end  
    end
  
end

end