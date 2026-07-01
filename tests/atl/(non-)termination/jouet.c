int main() {
      int n1 = ?;    // adversary sets up pile 1 (arbitrary, unbounded)
      if (n1 < 0) { n1 = 0; }
      int n2 = ?;    // adversary sets up pile 2 (arbitrary, unbounded)
      if (n2 < 0) { n2 = 0; }
      int turn = 1;             // 1 = Player 1 (coalition) to move, 2 = Player 2 (adversary)
      while (n1 > 0 || n2 > 0) {
          int pile;
          int amt;
          if (turn == 1) {
              pile = ?;   // Player 1 picks a pile
              amt  = ?;   // Player 1 picks how many tokens to remove
          } else {
              pile = ?;   // Player 2 picks a pile
              amt  = ?;   // Player 2 picks how many tokens to remove
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
