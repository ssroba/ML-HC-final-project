function [periods,powers,basis]=bestfrequency(s,m)

% Calculate the Periodicity Transform using the
% "Best Frequency" Algorithm
%
% syntax:  [periods,powers,basis]=bestfrequency(s,m)
% inputs:  s = signal to decompose
%          m = number of desired basis elements (optional: default=10)
% outputs: periods = basic periodicities
%          powers = norm after each new basis function (optional)
%          basis = the basis vectors found (optional)
%
% Type PTdemobf to see a demonstration of this function.
% See Sethares and Staley, "Periodicity Transforms"
% IEEE Trans. Signal Processing, 1999.

[nr,nc]=size(s);
n=max(nr,nc);
if nr>nc, s=s'; end
snorms=periodnorm(s);
if nargin==1, m=10; end
listp=zeros([1,m]); listnorm=zeros([1,m]); listbas=zeros([m,n]);
ssf=(0:round(n/2))/n;

% find best periodicities using FFT

i=1;
while i<m
  y=fft(s);
  absfft=abs(y(1:floor(n/2+1)));
  [maxn,maxf]=max(absfft);
  if maxf==1
    p=1;
  elseif maxf==2
    p=n/2;
  else
    p=round(1/ssf(maxf));
  end
  if isempty(find(listp==p));
    bas=projectp(s,p);
    listp(i)=p; listnorm(i)=periodnorm(bas); listbas(i,:)=bas;
    s=s-bas;
    i=i+1;
  else
    i=m;
  end
end

% massage output

[y,in]=sort(listnorm);
in=fliplr(in);
z=find(listnorm~=0);
in=in(1:length(z));
periods=listp(in);
powers=listnorm(in)/snorms;
basis=listbas(in,:);
