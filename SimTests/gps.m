function [sys,X0,str,ts,simStateCompliance] = gps(t,x,u,flag,P)
    switch flag
        case 0 %initialize
            [sys,X0,str,ts,simStateCompliance]=mdlInitializeSizes(P);
        case 1 %derivatives
            sys=mdlDerivatives(t,x,u,P);
        case 2 %update
            sys=mdlUpdate(t,x,u);
        case 3 %output
            sys=mdlOutputs(t,x,u);
        case 4 %get time of next var hit
            sys=mdlGetTimeOfNextVarHit(t,x,u);
        case 9 %terminate
            sys=mdlTerminate(t,x,u);
        otherwise
            DAStudio.error('Simulink:blocks:unhandledFlag', num2str(flag));     
    end
end

function [sys,X0,str,ts,simStateCompliance]=mdlInitializeSizes(P)
    sizes = simsizes;

    sizes.NumContStates  = 3;
    sizes.NumDiscStates  = 0;
    sizes.NumOutputs     = 3;
    sizes.NumInputs      = 9;
    sizes.DirFeedthrough = 0;
    sizes.NumSampleTimes = 1;   % at least one sample time is needed

    sys = simsizes(sizes);    
    X0  = P.x0;
    str = [];

    ts  = [0 0];

    simStateCompliance = 'UnknownSimState';
end

function sys=mdlDerivatives(t,x,uu,P)
    u=uu(1);
    w=uu(2);
    q=uu(3);
    theta=uu(4);
    v=uu(5);
    p=uu(6);
    r=uu(7);
    phi=uu(8);
    psi=uu(9);
    u=u+P.u0;
    roll=[
        1 0 0;
        0 cos(phi) sin(phi);
        0 -sin(phi) cos(phi)];
    pitch=[
        cos(theta), 0, -sin(theta);
        0, 1, 0;
        sin(theta), 0, cos(theta)];
    yaw=[
        cos(psi), sin(psi), 0;
        -sin(psi), cos(psi), 0;
        0, 0, 1];
    
    R=roll*pitch*yaw;
    res=R'*[u;v;w];
    pndot = res(1);    
    pedot = res(2); 
    pddot = res(3);
    
    sys = [pndot; pedot; pddot];
end

function sys=mdlUpdate(t,x,u)
    sys=[];
end

function sys=mdlOutputs(t,x,u)
    sys=x;
end

function sys=mdlGetTimeOfNextVarHit(t,x,u)
    sampleTime=1;
    sys=t+sampleTime;
end

function sys=mdlTerminate(t,x,u)
    sys=[];
end
