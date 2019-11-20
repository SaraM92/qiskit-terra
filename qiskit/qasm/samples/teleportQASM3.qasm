OPENQASM 3.0;
include "qelib1.inc";
qreg q[3];
creg c[3];

// declare channels
dch d0;
dch d1;
uch uch0;
mch m0;
mch m1;

framechange(-0.1) d0;
play x90p_q0 d0;
framechange(-0.3) d0;
play x90m_q0 d0;
framechange(-0.2) d0;


h q[1];
cx q[1],q[2];

barrier q;

framechange(pi/2) d0;
play ym_d0 d0;
play x90p_d1 d1;
ch_barrier d0, d1, uch0;
play cR90p_d1 d1;
ch_barrier d0, d1, uch0;
play xp_d0 d0;
ch_barrier d0, d1, uch0;
play cR90m_d1 d1;

h q[0];

play m_m0 m0;
acquire a0 c[0];

play m_m1 m1;
acquire a0 c[1];

if(c0==1) z q[2];
if(c1==1) play xp_d2 d2;

play m_m2 m2;
acquire a0 c[2];