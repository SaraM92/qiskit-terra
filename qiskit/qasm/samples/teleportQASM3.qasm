OPENQASM 3.0;
include "qelib1.inc";
qreg q[3];
creg c0[1];
creg c1[1];
creg c2[1];

framechange(-0.1) d0;
pulse X90p_q0 d0;
framechange(-0.3) d0;
pulse X90m_q0 d0;
framechange(-0.2) d0;

h q[1];
cx q[1],q[2];
barrier q;

framechange(np.pi/2) d0;
pulse Ym_d0 d0;
pulse X90p_d1 d1;
ch_barrier d0, d1, u0;
pulse CR90p_d1 d1;
ch_barrier d0, d1, u0;
pulse Xp_d0 d0;
ch_barrier d0, d1, u0;
pulse CR90m_d1 d1;

h q[0];

pulse M_m0 m0;
acquire a0 c0[0];

pulse M_m1 m1;
acquire a0 c1[0];
if(c0==1) z q[2];

if(c1==1) pulse Xp_d2 d2;

pulse M_m2 m2;
acquire a0 c2[0];