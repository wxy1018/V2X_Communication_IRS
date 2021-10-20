function ULA_response = ULA_Evaluate(lambda,N,AOD)
d = lambda/2; % antenna spacing 

ULA_response = zeros(N,length(AOD));

for n = 1:length(AOD)

    ULA_response(:,n) = 1 / sqrt(N) * exp(1i*2*pi*d/lambda*sin(AOD(n))*(0:N-1)');

end
