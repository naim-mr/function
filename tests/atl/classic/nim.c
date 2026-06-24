// =====================================================================
// Nim (subtraction game {1,2,3}) -- classic two-player game
// ---------------------------------------------------------------------
// Background : turn-based zero-sum game, standard textbook ATL/synthesis
//              example. P-positions are the multiples of 4 (last to move
//              wins). With 7 tokens the first mover ("me") has a winning
//              strategy: take 3, leaving 4, then mirror the opponent.
// Original model: see originals/nim.txt
// ---------------------------------------------------------------------
//   agent "me"  = input("me")   -> coalition (angelic), moves first
//   agent "opp" = input("opp")  -> adversary
//
// First mover has a winning strategy (TRUE):
//   -atl "<me>F{win == 0}"
// =====================================================================

int main() {
    int tokens = 7;
    int turn = 0;     // 0 = "me" to move, 1 = "opp" to move
    int win = -1;     // player id that took the last token
    while (tokens > 0) {
        int take;
        if (turn == 0) {
            take = input("me");    // angelic
        } else {
            take = input("opp");   // adversary
        }
        if (take < 1) { take = 1; }
        if (take > 3) { take = 3; }
        if (take > tokens) { take = tokens; }
        tokens = tokens - take;
        if (tokens == 0) {
            win = turn;            // whoever took the last token wins
        }
        turn = 1 - turn;
    }
    while (1) {}                // observe the winner
}
