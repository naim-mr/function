// =====================================================================
// Kaminsky DNS Cache-Poisoning -- PRISM case study (de-probabilised)
// ---------------------------------------------------------------------
// Source : N. Alexiou, S. Basagiannis, P. Katsaros, T. Deshpande, S. Smolka,
//   "Formal Analysis of the Kaminsky DNS Cache-Poisoning Attack Using
//    Probabilistic Model Checking", HASE 2010.
// Original model description: see kaminsky_dns.txt
// ---------------------------------------------------------------------
// The intruder floods the victim resolver with forged responses, each GUESSING
// the source-port id (the proposed fix randomises it over [1, maxport], so the
// intruder must also guess it, on top of the query id). The cache is poisoned
// iff a forged response's guessed port MATCHES the resolver's (random) port
// before the legitimate answer arrives. The paper shows the attack probability
// is ~ A/maxport (a 1/N law) -- > 0 but < 1, decreasing with the port range.
//
// We therefore model it as the ATTACKER's reachability of cache poisoning. The
// intruder commits its guess BEFORE the resolver's random port is revealed
// (blind guessing), so it cannot FORCE a match: expected UNKNOWN/FALSE -- the
// qualitative core of "attack probability = 1/N < 1" (port randomisation
// defeats a SURE attack). With the fix off (maxport = 1) the guess always
// matches and poisoning is forced.
//
//   agent "atk" = input("atk")  -> intruder: source-port guesses (coalition)
//   agent "res" = input("res")  -> resolver: random source port (adversary)
//
// Can the intruder force cache poisoning?
//   -atl "<atk>F{poisoned == 1}"   (expected UNKNOWN: cannot guarantee the guess)
// =====================================================================

int main() {
    int maxport = input("res");   // size of the source-port range (the fix): arbitrary
    if (maxport < 1) maxport = 1;
    int poisoned = 0;
    int tries = input("atk");     // bounded number of forged responses (guesses)
    if (tries < 0) tries = 0;
    while (tries > 0 && poisoned == 0) {
        int guess = input("atk");   // intruder commits a source-port guess (blind)
        int port  = input("res");   // resolver's randomised source port this query
        if (port < 1) port = 1;
        if (port > maxport) port = maxport;
        if (guess == port) { poisoned = 1; }   // correct guess -> cache poisoned
        tries = tries - 1;
    }
}
