// =====================================================================
// Futures Market Investor -- PRISM-games case study (de-probabilised)
// ---------------------------------------------------------------------
// Source : PRISM-games, "Futures market investor" (McIver & Morgan).
//   https://www.prismmodelchecker.org/games/casestudies.php
// Original model description: see future_mi.txt
// ---------------------------------------------------------------------
// An investor trades against a market. The market (adversary) picks the price
// ceiling `cap` (input("stock"), not fixed), moves the stock value up or down
// each month within [0, cap], and may BAR reservation -- but
// only a BOUNDED number of months (otherwise it could block the investor
// forever, trivialising the game). The investor (coalition) chooses WHEN to
// reserve a position (locking an entry price) and WHEN to cash in (realising
// gain = value - entry). The strategic question: can the investor force a
// target profit whatever the market does?
//
// MODELLING SCOPE: this is a SINGLE-TRADE model -- exactly one reservation
// followed by one cash-in, after which the game ends (done = 1). Consequently
// the `bars` budget only ever applies BEFORE the reservation (the bar branch
// is unreachable once reserved == 1); it just guarantees the investor can
// eventually enter the game. A multi-trade variant (after cash-in: reset
// reserved = 0, refresh bars = 3, and accumulate gain += value - entry) is
// possible but NOT modelled here; it would not change the UNKNOWN verdict.
//
//   agent "investor" = input("investor")  -> investor: reserve / cash in (coalition)
//   agents "stock"/"market" = input(...)   -> the market (adversary)
//
// Investor forces the MAXIMAL profit (the full price range):
//   -atl "<investor>F{gain >= cap}"  (expected UNKNOWN: soundness witness --
//                                     gain = value - entry is bounded by cap, so
//                                     gain >= cap demands the perfect spread
//                                     (enter at 0, cash at cap); a worst-case
//                                     market denies it.)
// =====================================================================

int main() {
    int cap = input("stock");      // price ceiling: market-chosen, not fixed in advance
    if (cap < 0) cap = 0;          // keep the [0, cap] price range well-formed
    int v = input("stock");        // initial stock value
    if (v < 0) v = 0;
    if (v > cap) v = cap;

    int reserved = 0;              // has the investor reserved a position?
    int entry = 0;                 // price locked at reservation
    int gain = 0;                  // realised profit (after cash-in)
    int done = 0;                  // position cashed in? (single trade -> ends the game)
    int bars = input("market");    // pre-reservation only: market-chosen FINITE bar bound,
                                   // NOT fixed in advance (the proof must hold for any value).

    while (done == 0) {
        // market (adversary) moves the value, kept within [0, cap]
        int delta = input("stock");
        if (delta >= 0) { v = v + 1; } else { v = v - 1; }
        if (v < 0) v = 0;
        if (v > cap) v = cap;

        if (reserved == 0) {
            int bar = 0;
            // the market can bar reservation only while its bar budget remains
            if (bars > 0) { bar = input("market"); }   // bar reservation this month?
            if (bar > 0) {
                bars = bars - 1;              // barred (consumes the bar budget)
            } else {
                int act = input("investor");  // investor reserves now?
                if (act > 0) { reserved = 1; entry = v; }
            }
        } else {
            int act = input("investor");      // investor cashes in now?
            if (act > 0) { gain = v - entry; done = 1; }  // single trade: cash-in ends the game
        }
    }

    if ( gain >= cap ){
        win:
    }
}
