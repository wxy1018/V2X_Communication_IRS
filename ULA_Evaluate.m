function ULA_response = ULA_Evaluate(lambda,N,Azimuth)
% To evaluate normalized antenna vector for Uniform Linear Array 
% Inputs: 
%   lambda: Wavelength
%   N: Number of antenna array 
%   Azimuth: Azimuth of Arrival/Departure
% 
% Output:
%   ULA_response: Antenna response

d = lambda/2; % antenna spacing 

ULA_response = zeros(N,length(Azimuth));

for n = 1:length(Azimuth)

    ULA_response(:,n) = 1 / sqrt(N) * exp(1i*2*pi*d/lambda*sin(Azimuth(n))*(0:N-1)');

end
