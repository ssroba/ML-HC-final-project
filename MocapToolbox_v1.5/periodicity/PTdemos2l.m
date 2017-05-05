echo off
% Demonstration of the Small To Large periodicity algorithm.
% See W. A. Sethares and T. W. Staley, "Periodicity Transforms"
% IEEE Transactions on Signal Processing, 1999
% for a detailed statement of the algorithms.

clf reset
clc
echo on

% Demonstration of the small-to-large periodicity transform
% First, a simple case consisting of two (random) periodic sequences
% of qn with period n and qm with period m

n=13;
m=14;
qqn=1.3*(rand(size(1:n))-0.5);	% make random sequence qqn of length n
qqm=0.7*(rand(size(1:m))-0.5);	% make random sequence qqm of length m
qn=perextend(qqn,lcm(n,m));		% periodically extend qqn to qn of length lcm(n,m)
qm=perextend(qqm,lcm(n,m));		% periodically extend qqm to qm of length lcm(n,m)
z=qn+qm;						% z is the sum of qn and qm, contains both periodicities
plot(z)

% Now we can use the various periodicity transforms to
% decompose z = qn + qm into its constituent elements
% First we use the "small2large" algorithm
% (as always in matlab, type "help small2large"
% to learn more about individual functions)

pause	% press any key to continue
clc

% Now invoke the small2large periodicity routine

[per,pow,bas]=small2large(z,0.2);

% The algorithm has found 
disp(length(per))
% different periodicities in z.
% In all likelihood, these are the two periods n and m
disp(per)
% Each of these periodicities removes 
disp(pow)
% percent of the "energy" (as measured by the periodicity norm)
% from the original signal z.
pause	% press any key to continue
clc

% Each of these found periodicities are output by the algorithm,
% and can be plotted to give a clear idea of the decomposition of z

clf
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

% Now let's explore the behavior of the small2large algorithm
% a bit. Let's lower the threshold so that we look for
% periodicities with smaller power.
% Here we change it from 0.2 (20% of the energy) to 0.01 (1% of the energy)

[per,pow,bas]=small2large(z,0.01);

% The algorithm has now found 
disp(length(per))
% different periodicities in z, which are
disp(per)
% Each of these periodicities removes 
disp(pow)
% percent of the "energy" from z (as measured by the periodicity norm)

pause	% press any key to continue
clc

% Each of these found periodicities are output by the algorithm,
% and can be plotted to give a clear idea of the decomposition of z

clf
for i=1:length(per)
   subplot(length(per),1,i),plot(bas(i,1:lcm(n,m)))
   l=['period ',num2str(per(i))];
   ylabel(l);
end
xlabel('second periodic decomposition of signal z into basis elements');

% Again, the sum of these signals equals z, since the difference is
disp(max(abs(z-sum(bas)))) % z - sum of all the found basis elements
% But wait - why is this decomposition different?

pause	% press any key to continue
clc

% It is different because the m=14 periodicity is actually
% composed of smaller periodicities within!

% How well does this work when the signals are noisy, when
% they are not exactly periodic? We now add some small noise
% to the signal

clf
z=z+0.3*(rand(size(z))-0.5);	% z is no longer (exactly) periodic
plot(z)

% Decompose (the noisy z) into its constituent elements

[per,pow,bas]=small2large(z,0.1);

pause	% press any key to continue
clc

% The algorithm has found 
disp(length(per))
% different periodicities in z, with periods
disp(per)
% Each of these periodicities removes 
disp(pow)
% percent of the "energy" (as measured by the periodicity norm)
% from the original signal z.

pause	% press any key to continue
clc

% Each of these found periodicities are output by the algorithm,
% and can be easily plotted to give a clear idea of the decomposition of z

clf
for i=1:length(per)
   subplot(length(per),1,i),plot(bas(i,1:lcm(n,m)))
   l=['period ',num2str(per(i))];
   ylabel(l);
end
xlabel('periodic decomposition of noisy z into basis elements');

pause	% press any key to continue
clc

% Observe that the sum of these signals is no longer equal
% to the original signal z, due to the nonperiodic noise.

disp(max(abs(z-sum(bas)))) % z - sum of all the found basis elements

% The basis vectors are also not (exactly) the same as before,
% since the noise itself contains (small) periodicities.
% This final plot shows z (in green), the sum of the basis vectors (in red),
% and the error between them (in blue). 

clf
plot(z,'g')
hold on
plot(sum(bas),'r')
plot(z-sum(bas),'b')

pause	% press any key to continue
clc

% You might now wish to play with the small2large 
% Periodicity Transform. You can find out more about it
% by typing:
%               help small2large
% or you might look up the article "Periodicity Transforms"
% by Sethares and Staley in the IEEE Trans. Signal Processing, 1999.
