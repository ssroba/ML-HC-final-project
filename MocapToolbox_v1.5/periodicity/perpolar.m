function hpol = perpolar(theta,rho,line_style,d)
%POLAR	Polar coordinate plot.
%	PERPOLAR(THETA, RHO) makes a plot using polar coordinates of
%	the angle THETA, in radians, versus the radius RHO.
%	PERPOLAR(THETA,RHO,S) uses the linestyle specified in string S.
%	See PLOT for a description of legal linestyles.
%
%	See also PLOT, LOGLOG, SEMILOGX, SEMILOGY.

%	Copyright (c) 1984-94 by The MathWorks, Inc.

if nargin < 1
	error('Requires 2 or 3 input arguments.')
elseif nargin == 2 
	if isstr(rho)
		line_style = rho;
		rho = theta;
		[mr,nr] = size(rho);
		if mr == 1
			theta = 1:nr;
		else
			th = (1:mr)';
			theta = th(:,ones(1,nr));
		end
	else
		line_style = 'auto';
	end
elseif nargin == 1
	line_style = 'auto';
	rho = theta;
	[mr,nr] = size(rho);
	if mr == 1
		theta = 1:nr;
	else
		th = (1:mr)';
		theta = th(:,ones(1,nr));
	end
end
if isstr(theta) | isstr(rho)
	error('Input arguments must be numeric.');
end
if any(size(theta) ~= size(rho))
	error('THETA and RHO must be the same size.');
end

% transform data to Cartesian coordinates.
xx = rho.*cos(theta);
yy = rho.*sin(theta);

% plot data on top of grid
if strcmp(line_style,'auto')
	q = plot(xx,yy);
else
	q = plot(xx,yy,line_style);
end
if nargout > 0
	hpol = q;
end
axis('equal');axis('off');
if nargin==4
  axis([-d,d,-d,d]);
end
