function q=perextend(w,n);

% q=perextend(w,n)
% periodically extend w by concatenating it to itself
% until it reaches length n

ss=size(w);
if ss(1)>ss(2)
  w=w';
end
q=w;
while length(q)<n
  q=[q,q];
end
q=q(1:n);
