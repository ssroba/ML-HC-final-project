function circleplot(q,scale,ptype)
% Plot periodic waveform q around a circle
%     syntax: circleplot(q,scale,ptype)
%     inputs: q = periodic waveform to plot
%             scale = multiply radius by scale factor (optional =1)
%             ptype = plot types (see plot command, optional)
if nargin==1
  scale=1; ptype='auto';
end
if nargin==2
  ptype='auto';
end
diameter=1/scale;
l=length(q);
q=[q,q(1)];
q=q-mean(q);
theta=-(0:2*pi/l:2*pi)+pi/2;
m=max(q)-min(q);
if max(abs(q))==0
  qq=q;
else
  qq=1+q/m;
end
perpolar(theta,qq,ptype,1.5*diameter)
hold on
if length(q)>100
  c=ones(size(q));
else
  c=ones(size(1:101));
  theta=0:2*pi/100:2*pi;
end
perpolar(theta,c,'.',1.5*diameter);
hold off
