// QFT and measure, version 2
OPENQASM 3.0;
include "qelib1.inc";
qreg q[4];
creg c0[1];
creg c1[1];
creg c2[1];
creg c3[1];
h q;
barrier q;
h q[0];

// measure 
pulse M_m0 m0;
acquire m0 c0[0];

if(c0==1) framechange(-pi/2) d1;

h q[1];

measure q[1] -> c1[0];

pulse M_m1 m1;
acquire m1 c1[0];

if(c0==1) framechange(-pi/4) d2;
if(c1==1) framechange(-pi/2) d2;

h q[2];

pulse M_m2 m2;
acquire m2 c2[0];

if(c0==1) u1(pi/8) q[3];
if(c1==1) u1(pi/4) q[3];
if(c2==1) u1(pi/2) q[3];

h q[3];

pulse M_m3 m3;
acquire m3 c3[0];