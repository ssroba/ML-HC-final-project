echo off
% Demonstration of the M-Best and M-Best (with gamma modified) 
% periodicity transforms.
% See W. A. Sethares and T. W. Staley, "Periodicity Transforms"
% IEEE Transactions on Signal Processing, 1999
% for a detailed statement of the algorithms

clf reset
clc
echo on

% Demonstration of the M-Best periodicity transform
% First, a simple case consisting of two (random) periodic sequences
% of qn with period n and qm with period m

n=13;
m=19;
qqn=rand(size(1:n));			% make random sequence qqn of length n
qqm=rand(size(1:m));			% make random sequence qqm of length m
qn=perextend(qqn,2*lcm(n,m));	% periodically extend qqn to qn 
qm=perextend(qqm,2*lcm(n,m));	% periodically extend qqm to qm 
z=qn+qm; z=z-mean(z);			% z is the sum of qn and qm, contains both periodicities
plot(z)

% Now we can use the various periodicity transforms to
% decompose z = qn + qm into its constituent elements
% First we use the "M-best" algorithm
% (as always in matlab, type "help mbest"
% to learn more about individual functions)

pause	% press any key to continue
clc

% Now invoke the M-Best periodicity routine

[per,pow,bas]=mbest(z,5);

% The algorithm has found 
disp(length(per))
% different periodicities in z. These are
disp(per)
% Where did these come from?
% Observe that most of these are integer multiples of either n
disp(per/n)
% or multiples of m
disp(per/m)
% thus we are seeing the algorithm choose the longer
% periodicites over the shorter (recall that a n-periodic
% sequence is also kn-periodic for all integers k)
pause	% press any key to continue
clc

% The M-Best (with gamma modification) 
% is designed to treat all the periodicities equally,
% de-emphasizing the longer ones in comparison to the M-Best

[per,pow,bas]=mbestgam(z,5);

% The algorithm has found 
disp(length(per))
% different periodicities in z.
% In all likelihood, these are the two periods n and m
disp(per)
% Each of these periodicities has strength
disp(pow)
% Now thats more like it!
% The periodicities with strength zero appear because 
% we asked for 5, even though there are only two. 
pause	% press any key to continue
clc

% Each of these found periodicities are output by the algorithm,
% and can be plotted to give a clear idea of the decomposition of z

clf; lper=find(pow>0.01);
for i=1:length(lper)
   subplot(length(lper),1,i),plot(bas(lper(i),1:lcm(n,m)))
   l=['period ',num2str(per(lper(i)))];
   ylabel(l);
end
xlabel('periodic decomposition of signal z into basis elements');

% Observe that the sum of these basis signals is equal
% to the original signal z (up to machine precision).
disp(max(abs(z-sum(bas))))  % z - sum of all the found basis elements
pause	% press any key to continue
clc

% Now let's explore the behavior of the M-Best (gamma) algorithm
% How well does this work when the signals are noisy, when
% they are not exactly periodic? We now add 50% noise to z

clf
z=z+rand(size(z)); z=z-mean(z);		% z is no longer periodic
plot(z)

% Decompose (the noisy z) into its constituent elements

[per,pow,bas]=mbestgam(z,5);

% The algorithm has found 
disp(length(per))
% different periodicities in z, with periods
disp(per)
% Each of these periodicities has strength 
disp(pow)
% Thus, it has found the same periodicities as before,
% plus some new ones that are a result of the noise sequence
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

% You might now wish to play with the M-Best (gamma)
% Periodicity Transform. You can find out more about it
% by typing:
%               help mbest    or
%               help mbestgam
% or you might look up the article "Periodicity Transforms"
% by Sethares and Staley in the IEEE Trans. Signal Processing, 1999.
