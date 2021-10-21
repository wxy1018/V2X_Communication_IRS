function [RxPower, NumInteraction] = GetBSUEAttenuation(BS,RISnum)
% To get the PL attenuation from BS to each vehicles

NumInteraction = [];
RxPower = [];
fn = fieldnames(BS);

for rx_idx = 2+RISnum:numel(fn)
    
    rx = BS.(fn{rx_idx});
    RxPower = [RxPower rx.path_id1.received_power];
    NumInteraction = [NumInteraction rx.path_id1.interaction];
    
end

end
    