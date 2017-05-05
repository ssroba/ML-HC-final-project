% find highly composite numbers
N=10000;
q=zeros(1,N);
for i=1:N
	q(i)=length(factor(i));
end
[qm,qi]=max(q)

g10=find(q>10);
q(g10)
