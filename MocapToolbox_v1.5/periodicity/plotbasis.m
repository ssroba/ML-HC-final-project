lenper=length(per);
numplotx=ceil(sqrt(lenper));
numploty=ceil(lenper/numplotx);
for i=1:lenper
  subplot(numploty,numplotx,i)
  hold on
  b=bas(i,1:per(i));
  circleplot(b,per(i)/max(per))
  l=['period ',num2str(per(i)),' power ',num2str(round(100*pow(i))/100)];
  axis('on')
  xlabel(l)
end
