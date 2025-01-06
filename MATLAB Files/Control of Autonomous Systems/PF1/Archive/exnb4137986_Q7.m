clc; clear; close all;
format compact

% State space stuff
syms P1 P2 u Ts

X = [P1;
     P2]

Xdot = [X(1)*X(2)-X(1);
        -4/3*X(1)*X(2)+2/3*X(2)+u]

d_X = [X(1) + Ts*(Xdot(1));
       X(2) + Ts*(Xdot(2))]

syms x1 x2

Xdot = subs(Xdot, [P1, P2], [x1, x2])

% Calculate EQ Points
eq = solve(subs(Xdot == [0; 0], u, 0), [x1, x2]);
xeq1 = double([eq.x1(1);
               eq.x2(1)])
xeq2 = double([eq.x1(2);
               eq.x2(2)])
disp(' ');
disp('Equilibrium points (x1, x2):');
disp([xeq1, xeq2]);
disp(' ');

% Jacobian
dfdx = [diff(Xdot(1),x1) diff(Xdot(1),x2);
        diff(Xdot(2),x1), diff(Xdot(2), x2)]

% This is for me to use in Simulink, so it can compute
% the A matrix from the chosen equilibrium point. I'm aware
% that the assignment said to consider the equilibrium point not
% in the origin, but I wanted to also check out the other one.
matlabFunction(dfdx, 'File', 'computeA', 'Vars', {x1, x2});

A1 = double(subs(dfdx, [x1, x2], [xeq1(1), xeq1(2)]))

A2 = double(subs(dfdx, [x1, x2], [xeq2(1), xeq2(2)]))

B = double([diff(Xdot(1), u);
            diff(Xdot(2), u)])

e = eig(A2)
poles = real(e);
% Check the real parts of the eigenvalues
disp(" ")
disp('Real parts of the eigenvalues: ')
disp(poles)
disp(" ")
if all(poles < 0)
    disp('The system is stable.');
elseif any(poles > 0)
    disp('The system is unstable.');
else
    disp('The system is marginally stable.');
end