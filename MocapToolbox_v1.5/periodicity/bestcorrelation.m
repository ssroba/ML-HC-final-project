function [periods,powers,basis]=bestcorrelation(s,ratpower,numiter,longper)

% Calculate the Periodicity Transform using the
% "Best Correlation" algorithm
%
% syntax:  [periods,powers,basis]=bestcorrelation(s,ratpower,numiter,longper)
% inputs:  s = signal to decompose
%          ratpower = decrease in (ratio of) norm needed to continue (optional)
%          numiter = max number of basis elements (optional)
%          longper = longest period to look for (optional)
% outputs: periods = basic periodicities
%          powers = norm after each new basis function
%          basis = the basis vectors found (optional)
%
% Type PTdemobc to see a demonstration of this function.
% See Sethares and Staley, "Periodicity Transforms"
% IEEE Trans. Signal Processing, 1999.

[nr,nc]=size(s);
n=max(nr,nc);
if nr>nc, s=s'; end
if nargin==1
 ratpower=0.01;
 numiter=10;
 longper=round(n/3);
elseif nargin==2
 numiter=10;
 longper=round(n/3);
elseif nargin==3
 longper=round(n/3);
end
numt=0;
periods=[]; basis=[]; powers=[];
nzeros=zeros([1,n]); nones=ones([1,n]); nzeros=0*nones;
snorms=periodnorm(s); oldnorm=snorms;

% find the p-periodic basis element most highly correlated with s

while numt<numiter
  numt=numt+1;
  maxcor=0;
  for k=1:longper
    for shift=0:k-1
	
	  % project s onto each p-periodic basis vector,
	  % the one with the largest correlation "wins" this round
	  	
	  ind=(shift+1):k:n;
      cor=abs(sum(s(ind)));
	  if cor>maxcor
	    maxcor=cor;
		maxp=k;
	  end
	end
  end
  
  % project s onto maxp-periodic subspace
  
  bas=projectp(s,maxp);
  s=s-bas;
  normtest=(oldnorm-periodnorm(s))/snorms;
  if normtest>ratpower
    periods=[periods, maxp];
	powers=[powers, normtest];
    basis=[basis; bas];
	oldnorm=periodnorm(s);
  else
    numt=numiter;
  end
end
