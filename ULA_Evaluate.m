function ULA_response = ULA_Evaluate(lambda,N,Angle)
d = lambda/2; % antenna spacing 

ULA_response = zeros(N,length(Angle));

for n = 1:length(Angle)

    ULA_response(:,n) = 1 / sqrt(N) * exp(1i*2*pi*d/lambda*sin(Angle(n))*(0:N-1)');

end
