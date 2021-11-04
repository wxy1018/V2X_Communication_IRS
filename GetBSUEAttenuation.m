function [RxPower, NumInteraction] = GetBSUEAttenuation(BS,RISnum)
% To get the PL attenuation from BS to each vehicles

NumInteraction = [];
%RxPower = [];
RxPower = zeros(1,28);
fn = fieldnames(BS);

for rx_idx = 2+RISnum:numel(fn)
    
    rx = BS.(fn{rx_idx});
    for p = 1:numel(fieldnames(rx))
        path = eval(['rx.path_id' num2str(p)]);
        if path.interaction == 0
            RxPower(1,rx_idx-5) = path.received_power;
        end
    end
    %RxPower = [RxPower rx.path_id1.received_power];
    %NumInteraction = [NumInteraction rx.path_id1.interaction];
    
end

end
    