function [periodall,powersall,basall]=small2large(s,thresh,numper)

% Calculate the Periodicity Transform using the
% "Small To Large" algorithm
%
% syntax: [periodall,powersall,basall]=small2large(s,thresh,numper)
% inputs: s = signal to decompose
%         thresh = P_p must remove at least this percent of 
%                  power in order to be counted
%         numper = max periodicity to look for
%                  (optional: default = length(s)/2)
% outputs: periodall = the periodicities discovered
%          powersall = norm of residual after projection onto P_period
%          basall = basis elements found (optional)
%
% Type PTdemos2l to see a demonstration of this function.
% See Sethares and Staley, "Periodicity Transforms"
% IEEE Trans. Signal Processing, 1999.

[nr,nc]=size(s); if nr>nc, s=s'; end
periodall=[];
powersall=[];
basall=[];
snorms=periodnorm(s);
if nargin==2
  numper=length(s)/2;
end
for period=1:numper
  bas=projectp(s,period);
  r=s-bas;
  normimp=(periodnorm(s)-periodnorm(r))/snorms;
  if normimp>thresh
    s=r;
	periodall=[periodall, period];
    powersall=[powersall, normimp];
	basall=[basall; bas];
  end
end
