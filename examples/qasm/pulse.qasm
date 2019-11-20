//Rewriting the code in pulse definitions backend=alt_almaden
// pulses defined for specific devices

// declare channels
dch d0;
dch d1;
uch u0;
mch m0;
mch m1;

// declare registers
creg c[3];

// user could add custom pulses
pulse x90p_q0  [(0.004,0.009),
                (0.029,0.05),
                (0.8,-0.355)];
//fill this out OR just get from the library
pulse x90m_q0 [(0.004,0.009),
               (0.029,0.05),
               (0.8,-0.355)];

//include pulses
//included lib above

gate u3(theta, phi, lambda) a {
    framechange(-lambda) d0;
    play x90p_q0 d0;
    framechange(-theta) d0;
    play x90m_q0 d0;
    framechange(-phi) d0;
}

////
//gate u3(theta, phi, lambda) a {
//    framechange(-lambda) d1;
//    play x90p_q1 d1;
//    framechange(-theta) d1;
//    play x90m_q1 d1;
//    framechange(-phi) d1;
//}


//usage: u3(pi, pi, pi)

gate u2(phi, lambda) a {
    framechange(-lambda) d0;
    play y90p_q0 d0;
    framechange(-phi) d0;
}

gate u1(lambda) a {
    framechange(-lambda) d0;
}

gate x a {
    play xp_d0 d0;
}


gate id a {
    play qId_d0 d0;
}

gate measure a {
    play m_m0 m0;
    acquire m0 c[0];
    acquire m1 c[1];
    acquire m2 c[2];
    // continue on for all qubits ...
}

gate cx a, b {
    framechange(pi/2) d0;
    play ym_d0 d0;
    play x90p_d1 d1;
    ch_barrier d0, d1, u0;
    play cR90p_d1 d1;
    ch_barrier d0, d1, u0;
    play xp_d0 d0;
    ch_barrier d0, d1, u0;
    play cR90m_d1 d1;
}