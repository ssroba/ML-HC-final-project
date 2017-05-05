function [periods,powers,basis]=mbest(s,m,n)

% Calculate the Periodicity Transform using the
% "M-Best" Algorithm
%
% syntax:  [periods,powers,basis]=mbest(s,m,n)
% inputs:  s = signal to decompose
%          m = number of desired basis elements (optional: default=10)
%          n = longest periodicity to look for (optional: default=length(s)/3)
% outputs: periods = basic periodicities
%          powers = norm after each new basis function (optional)
%          basis = the basis vectors found (optional)
%
% Type PTdemomb to see a demonstration of this function.
% See Sethares and Staley, "Periodicity Transform"
% IEEE Trans. Signal Processing, 1999.

[nr,nc]=size(s);
if nr>nc, s=s'; end

snorms=periodnorm(s); 
if nargin==1, m=10; n=length(s)/3; end
if nargin==2, n=length(s)/3; end
listp=zeros([1,m]); listnorm=zeros([1,m]); listbas=zeros([m,length(s)]);
if m>1, listchange=1;else listchange=0;end

% build initial list of m best periodicities

for i=1:m 
  maxnorm=0; maxp=0; maxbas=zeros([1,length(s)]);
  for p=1:n
    bas=projectp(s,p);
    if periodnorm(bas)>maxnorm
	  maxp=p; maxnorm=periodnorm(bas); maxbas=bas;
    end
  end
  listp(i)=maxp; listnorm(i)=maxnorm; listbas(i,:)=maxbas;
  s=s-maxbas;
end

% step 2: decompose basis elements and residuals

while listchange==1
  i=1;
  while i<m
    listchange=0;
    maxnorm=0;
	fact=factorp(listp(i));
    for nf=1:length(fact)
	  p=fact(nf);
      bas=projectp(listbas(i,:),p);
      if periodnorm(bas)>=maxnorm
	    maxp=p; maxnorm=periodnorm(bas); maxbas=bas;
      end
    end   
	xbigq=projectp(listbas(i,:),maxp); xsmallq=listbas(i,:)-xbigq;
	nbigq=periodnorm(xbigq); nsmallq=periodnorm(xsmallq);
	minq=min(listnorm); ptwice=length(find(listp==maxp));
	if nsmallq+nbigq>listnorm(m)+listnorm(i) & nsmallq>minq & nbigq>minq & ptwice==0
	  listchange=1;
	  listnorm=[listnorm(1:i-1),nbigq,nsmallq,listnorm(i+1:m-1)];
	  listp=[listp(1:i-1),maxp,listp(i:m-1)];
	  if i>1
	    listbas=[listbas(1:i-1,:);maxbas;xsmallq;listbas(i+1:m-1,:)];
	  else
	    listbas=[maxbas;xsmallq;listbas(2:m-1,:)];
	  end
	else
	  i=i+1;
	end
  end
end

periods=listp;
powers=listnorm/snorms;
basis=listbas;
