function [h_RIS1_UE, h_RIS2_UE, h_RIS3_UE] = RemoveUser(h_RIS1_UE, h_RIS2_UE, ...
       h_RIS3_UE)
   % To remove one user that is not common along BS and RIS
   h_RIS1_UE(10,:) = [];
   h_RIS2_UE(10,:) = [];
   h_RIS3_UE(10,:) = [];
   
end