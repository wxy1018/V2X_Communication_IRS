function ULA_response = ULA_Evaluate(lambda,N,Angle)
% To evaluate normalized antenna vector for Uniform Linear Array 
% Inputs: 
%   lambda: Wavelength
%   N: Number of antenna array 
%   Angle: Azimuth of Arrival/Departure
% 
% Output:
%   ULA_response: Antenna response

d = lambda/2; % antenna spacing 

ULA_response = zeros(N,length(Angle));

for n = 1:length(Angle)

    ULA_response(:,n) = 1 / sqrt(N) * exp(1i*2*pi*d/lambda*sin(Angle(n))*(0:N-1)');

end
