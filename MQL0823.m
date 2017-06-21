function v=MQL0823
v=zeros(410,5000);%pre-allocate memory for Matlab
rou=1.2; %rou is the density of water,which unit is kg/m3
mu=0.000018;%mu is the dynamic viscosity of water,which unit is Pa*s (kg/(m*s))
Vy0=16.454;%Vy0 is the initial velocity, which unit is m/s
Vc=-45.7/60; %Vc is the cutting speed, which unit is m/s
g=9.81; %g is the standard gravity, which unit is m/s^2
L1=0.41645*10^(-3); %Dimension along the X direction,its unit is m
L2=4.76*10^(-3); %Dimension along the Y direction,its unit is m
B1=1.27*10^(-3); %Dimension along the Z direction,unit=m
%a=0.025; %a is the cutting criteria for dP/dy transformation
b=-0.0875; %b is the constant term in the L(y) function
Zmean=-2.68817*10^(-7);
xmax=400;
dx=L1/xmax;
dy=dx;
ymax=round(L2/dy)

%Initialize the boundary conditions
for i=2:xmax+1
    v(i,1)=Vy0;
    v(i,ymax+2)=0;
end

for j=1:ymax+2
    v(1,j)=Vc;
    v(xmax+2,j)=0;
end
%Specify Initial Guess Values
for i=2:xmax+1
    for j=2:ymax+1
        v(i,j)=0.95*v(i,j-1);
    end
end

%Move in the Trapizoidal Boundary
xstartpoint=xmax+2;
for j=1:ymax+2
    v(xstartpoint,j)=0;
    if j/12==round(j/12), xstartpoint=xstartpoint-1;end
end

%Calculate DP/DY using 0.05 Cut-Off
xstartpoint=xmax+2;
for j=2:1000
    if j/12==round(j/12), xstartpoint=xstartpoint-1; end
    L=L1+b*(j-2)*dy;
    for i=2:xstartpoint-1
    DPDY(i,j)=(-9)*Vc*(b^2)*Zmean*(dy^2)/((L^4)*4);
    end
end
%Interpolate DP/DY
t=[1 1045];
  f=[DPDY(2,1000) 0];
  tt=linspace(1,1045,1045);
  DPDYINT=interp1(t,f,tt,'pchip');


for j=1001:2043 % 1043 rows
    if j/12==round(j/12), xstartpoint=xstartpoint-1; end
    for i=2:xstartpoint-1
    DPDY(i,j)=DPDYINT(j-999);
    end
end

for j=2044:ymax+1 % 1511 rows
    if j/12==round(j/12), xstartpoint=xstartpoint-1; end
    for i=2:xstartpoint-1
    DPDY(i,j)=0;
    end
end

%Iterations for Calculation Velocity Profile
for k=1:120000
    xstartpoint=xmax+2;
  for j=2:ymax+1
      L=L1+b*(j-2)*dy;
    if j/12==round(j/12), xstartpoint=xstartpoint-1; end
    for i=2:xstartpoint-1
        TERM1=(v(i,j+1)+v(i,j-1)+v(i+1,j)+v(i-1,j))/4;
        TERM2=dy*v(i,j)*rou*(v(i,j+1)-v(i,j-1))/(8*mu);
        TERM4=rou*g*(dy^2)/(L*4);
        v(i,j)=TERM1-TERM2-TERM4-DPDY(i,j);
        if v(i,j)<0, v(i,j)=0; end
        if k>5000&&v(i,j)<0.00001, DPDY(i,j)=0;end
    end
  end
end