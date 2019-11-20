OPENQASM 3.0;
include "qelib1.inc";

qreg q[3];
creg c[3];

gate cH a,b {
h b;
sdg b;
cx a,b;
h b;
t b;
cx a,b;
t b;
h b;
s b;
x b;
s a;
 }

framechange(0) d1;
play X90p_q1 d1;
framechange(-191063) d1;
play X90m_q1 d1;
framechange(0) d1;

cH q[0],q[1];
ccx q[0],q[1],q[2];

play Xp_d0 d0;
play Xp_d1 d1;

framechange(np.pi/2) d0;
play Ym_d0 d0;
play X90p_d1 d1;
ch_barrier d0, d1, u0;
play CR90p_d1 d1;
ch_barrier d0, d1, u0;
play Xp_d0 d0;
ch_barrier d0, d1, u0;
play CR90m_d1 d1;

# acquire 
play M_m0 m0;
acquire m0 c[0];
acquire m1 c[1];
acquire m2 c[2];
play M_m1 m1;
acquire m0 c[0];
acquire m1 c[1];
acquire m2 c[2];
play M_m2 m2;
acquire m0 c[0];
acquire m1 c[1];
acquire m2 c[2];