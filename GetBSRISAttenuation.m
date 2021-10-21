function [RxPower,NumInteraction] = GetBSRISAttenuation(BS,...
    RISnum)

NumInteraction = [];
RxPower = [];
fn = fieldnames(BS);

for rx_idx = 2:1+RISnum
    
    rx = BS.(fn{rx_idx});
    RxPower = [RxPower rx.path_id1.received_power];
    NumInteraction = [NumInteraction rx.path_id1.interaction];
    
end

end
