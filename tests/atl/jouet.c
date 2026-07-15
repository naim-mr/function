// =====================================================================
  // 2-Pile Nim -- Classical Strategic Example (native ATL benchmark)
  // ---------------------------------------------------------------------
  // Source : C. L. Bouton, "Nim, A Game with a Complete Mathematical Theory,"
  //   Annals of Mathematics 3(1/4), 1901 (restricted here to two piles).
  // ---------------------------------------------------------------------
  // Two piles of n1, n2 tokens (adversary-chosen, unbounded). Players
  // alternate; on its turn, a player removes any positive number of tokens
  // from one nonempty pile. Normal play: the player who takes the last
  // token wins (equivalently, the player unable to move loses).
  //
  //   agent "p1" = input("p1")  -> Player 1 (coalition, angelic)
  //   agent "p2" = input("p2")  -> Player 2 (adversary); also sets up the
  //                                 initial pile sizes n1, n2
  //
  // Bouton's theorem, 2-pile case: a position is losing for the player to
  // move iff n1 == n2 (the opponent mirrors every move on the other pile).
  // Off the diagonal, the mover wins by equalising the piles, then mirroring.
  //
  // -atl "<p1>F{n1==0 && n2==0 && turn==2}"   (Player 1 takes the last token)
  //   expected UNKNOWN overall (false on the diagonal n1==n2, where Player 2
  //   wins by mirroring), with sufficient precondition n1 != n2 -- i.e. the
  //   analysis should split into two symmetric leaves n1 > n2 / n1 < n2 and
  //   automatically rediscover Bouton's P-position criterion for two piles.
  // =====================================================================

  int main() {
      int n1 = input("p2");    // adversary sets up pile 1 (arbitrary, unbounded)
      if (n1 < 0) { n1 = 0; }
      int n2 = input("p2");    // adversary sets up pile 2 (arbitrary, unbounded)
      if (n2 < 0) { n2 = 0; }
      int turn = 1;             // 1 = Player 1 (coalition) to move, 2 = Player 2 (adversary)
      while (n1 > 0 || n2 > 0) {
          int pile;
          int amt;
          if (turn == 1) {
              pile = input("p1");   // Player 1 picks a pile
              amt  = input("p1");   // Player 1 picks how many tokens to remove
          } else {
              pile = input("p2");   // Player 2 picks a pile
              amt  = input("p2");   // Player 2 picks how many tokens to remove
          }
          // normalise to a legal move: a nonempty pile, 1..size tokens
          if (n1 == 0) { pile = 2; }
          else if (n2 == 0) { pile = 1; }
          else if (pile != 2) { pile = 1; }
          if (amt < 1) { amt = 1; }
          if (pile == 1) {
              if (amt > n1) { amt = n1; }
              n1 = n1 - amt;
          } else {
              if (amt > n2) { amt = n2; }
              n2 = n2 - amt;
          }
          turn = 3 - turn;      // alternate mover
      }
  }