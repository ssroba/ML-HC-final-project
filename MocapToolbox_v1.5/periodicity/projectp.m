function baselem=projectp(s,p)

% Find the closest p-periodic vector to the vector s by
% projecting s onto the periodic subspace P_p
%
% syntax: baselem=projectp(s,p)
% inputs: s = vector to project
%         p = desired period
% outputs: baselem = basis element is the p-periodic
%                    vector closest to s
%
% See Sethares and Staley, "The Periodicity Transform"
% IEEE Trans. Signal Processing, 1998.

n=length(s);
nones=ones([1,n]);
baselem=0*nones;
for shift=0:p-1
  ind=(shift+1):p:n;
  baselem(ind)=nones(ind)*sum(s(ind))/length(ind);
end
