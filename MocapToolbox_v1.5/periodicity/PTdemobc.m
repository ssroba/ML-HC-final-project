echo off
% Demonstration of the Best Correlation periodicity algorithm.
% See W. A. Sethares and T. W. Staley, "Periodicity Transforms"
% IEEE Transactions on Signal Processing, 1999
% for a detailed statement of the algorithms

clf reset
clc
echo on

% Demonstration of the best correlation periodicity transform
% First, a simple case consisting of two spikey periodic sequences
% of qn with period n=13 and qm with period m=14

n=13; m=14;
qqn=[8 0 0 -4 0 0 -1 0 0 1 1 -1 -1]+rand(size(1:n));	
qqm=[-6 3 -1 -4 1 -1 -1 1 -3 1 -1 0 4 -4]+rand(size(1:m));	
qn=perextend(qqn,lcm(n,m));		% periodically extend to length lcm(n,m)
qm=perextend(qqm,lcm(n,m));		% periodically extend to length lcm(n,m)
z=qn+qm; z=z-mean(z);			% z is the sum of qn and qm with DC bias removed
plot(z)								

% Now we can use the various periodicity transform to
% decompose z = qn + qm into its constituent elements
% First we use the "best correlation" algorithm
% (as always in matlab, type "help bestcorrelation"
% to learn more about individual functions)

pause	% press any key to continue
clc

% Invoke the bestcorrelation periodicity routine

[per,pow,bas]=bestcorrelation(z);

% The algorithm has found 
disp(length(per))
% different periodicities in z.
% In all likelihood, these contain the two periods n and m
disp(per)
% Each of these periodicities removes 
disp(pow)
% percent of the "energy" (as measured by the periodicity norm)
% from the original signal z.
pause	% press any key to continue
clc

% Each of these found periodicities are output by the algorithm,
% and can be plotted to give a clear idea of the decomposition of z

clg
for i=1:length(per)
   subplot(length(per),1,i),plot(bas(i,1:lcm(n,m)))
   l=['period ',num2str(per(i))];
   ylabel(l);
end
xlabel('periodic decomposition of signal z into basis elements');

% Observe that the sum of these basis signals is equal
% to the original signal z (up to machine precision).
disp(max(abs(z-sum(bas))))  % z - sum of all the found basis elements
pause	% press any key to continue
clc

% Lets do it again for different sequences of length n=12 and m=14
n=12; m=14;
qqn=[5 0 0 0 0 4 0 0 0 0 -4 0]+rand(size(1:n));	
qqm=[-4 0 0 0 0 0 0 -5 0 0 0 0 0 0]+rand(size(1:m));	
qn=perextend(qqn,lcm(n,m));		% periodically extend to length lcm(n,m)
qm=perextend(qqm,lcm(n,m));		% periodically extend to length lcm(n,m)
z=qn+qm; z=z-mean(z);			% z is the sum of qn and qm with DC bias removed
plot(z)								

% Now invoke the bestcorrelation periodicity routine

[per,pow,bas]=bestcorrelation(z);

% The algorithm has found 
disp(length(per))
% different periodicities in z.
% In all likelihood, these contain the two periods n and m
% as well as some of the "subperiods"
disp(per)
% Each of these periodicities removes 
disp(pow)
% percent of the "energy" (as measured by the periodicity norm)
% from the original signal z.
pause	% press any key to continue
clc

% Each of these found periodicities are output by the algorithm,
% and can be plotted to give a clear idea of the decomposition of z

clg
for i=1:length(per)
   subplot(length(per),1,i),plot(bas(i,1:lcm(n,m)))
   l=['period ',num2str(per(i))];
   ylabel(l);
end
xlabel('periodic decomposition of signal z into basis elements');

% Observe that the sum of these basis signals is equal
% to the original signal z (up to machine precision).
disp(max(abs(z-sum(bas))))  % z - sum of all the found basis elements
pause	% press any key to continue
clc

% You might now wish to play with the bestcorrelation 
% Periodicity Transform. You can find out more about it
% by typing:
%               help bestcorrelation
% or you might look up the article "Periodicity Transforms"
% by Sethares and Staley in the IEEE Trans. Signal Processing, 1999.
