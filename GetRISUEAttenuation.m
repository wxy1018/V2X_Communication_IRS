function [RxPower,NumInteraction] = GetRISUEAttenuation(t_instance,RISnum);

rxnum = numel(fieldnames(t_instance.RIS_1))-1;
NumInteraction = zeros(RISnum,rxnum);
RxPower = zeros(RISnum,rxnum);

for Ris_idx = 1:RISnum

    RIS = eval(['t_instance.RIS_' num2str(Ris_idx)]);
    fn = fieldnames(RIS);
    for rx_idx = 1:numel(fn)-1
       
        rx = RIS.(fn{rx_idx+1});
        RxPower(Ris_idx,rx_idx) = rx.path_id1.received_power;
        NumInteraction(Ris_idx,rx_idx) = rx.path_id1.interaction;
        
    end
    
end


end
    