echo off
% Demonstration of the Best Frequency periodicity algorithm.
% See W. A. Sethares and T. W. Staley, "Periodicity Transforms"
% IEEE Transactions on Signal Processing, 1999
% for a detailed statement of the algorithms.

clf reset
clc
echo on

% Demonstration of the best frequency periodicity transform
% First, a simple case consisting of two periodic sequences

n=round(20*rand)+3; m=round(30*rand)+3; qqn=sin(1:.2:n); qqm=sin(1:.22:m);		
	
% The periodic signals qqn and qqm are of length
disp([length(qqn), length(qqm)])
% which changes each time you run this demo

len=lcm(length(qqn),length(qqm));
qn=perextend(qqn,len);		% periodically extend qqn to qn of length len
qm=perextend(qqm,len);		% periodically extend qqm to qm of length len
z=qn+qm; z=z-mean(z);		% z is the sum of qn and qm, contains both periodicities
plot(z)
pause	% press any key to continue
clc

% Now we decompose z = qn + qm into its constituent elements
% by invoking the bestfrequency periodicity routine

[per,pow,bas]=bestfrequency(z);

% The algorithm has found 
disp(length(per))
% different periodicities in z. These are
disp(per)
echo off
for i=1:length(per)
  tn=length(qqn)/per(i); dn=tn-round(tn);
  tm=length(qqm)/per(i); dm=tm-round(tm);
  if abs(dn)<abs(dm)
    mes=['          ',num2str(length(qqn)),' is approximately ', num2str(round(tn)),' times ',num2str(per(i))];
  else
    mes=['          ',num2str(length(qqm)),' is approximately ', num2str(round(tm)),' times ',num2str(per(i))];
  end
  disp(mes)
end
echo on
% In all likelihood, these are closely related to the periods of qqn and qqm
% The Best Frequency algorithm often behaves ike this, returning
% "harmonics" rather than the periodicities themselves

pause	% press any key to continue
clc

% Each of these found periodicities are output by the algorithm,
% and can be plotted to give a clear idea of the decomposition of z

clf
for i=1:length(per)
   subplot(length(per),1,i),plot(bas(i,1:len))
   l=['period ',num2str(per(i))];
   ylabel(l);
end
xlabel('periodic decomposition of signal z into basis elements');

pause	% press any key to continue
clc

% Now let's explore the behavior of the bestfrequency algorithm
% a bit. How well does this work when the signals are noisy, when
% they are not exactly periodic? We now add 50% noise
% to the signal

clf
z=z+rand(size(z)); z=z-mean(z);	% z is no longer (exactly) periodic
plot(z)

% Decompose (the noisy z) into its constituent elements

[per,pow,bas]=bestfrequency(z);

% The algorithm has found 
disp(length(per))
% different periodicities in z. These are
disp(per)
echo off
for i=1:length(per)
  tn=length(qqn)/per(i);
  tm=length(qqm)/per(i);
  if abs(tn-round(tn))<abs(tm-round(tm))
    mes=['          ',num2str(length(qqn)),' is approximately ', num2str(round(tn)),' times ',num2str(per(i))];
  else
    mes=['          ',num2str(length(qqm)),' is approximately ', num2str(round(tm)),' times ',num2str(per(i))];
  end
  disp(mes)
end
echo on
% In all likelihood, these are closely related to the periods of qqn and qqm
% The Best Frequency algorithm often behaves ike this, returning
% "harmonics" rather than the periodicities themselves

pause	% press any key to continue
clc


% You might now wish to play with the bestfrequency 
% Periodicity Transform. You can find out more about it
% by typing:
%               help bestfrequency
% or you might look up the article "Periodicity Transforms"
% by Sethares and Staley in the IEEE Trans. Signal Processing, 1999.
