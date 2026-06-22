// =====================================================================
// grub2 "back-to-28" auth bypass (CVE-2015-8370) -- robust reachability
// ---------------------------------------------------------------------
// Source : BINSEC CAV'21 artifact, "Not All Bugs Are Created Equal".
//   https://github.com/binsec/cav2021-artifacts (bintest/grub2)
//   Paper : https://binsec.github.io/assets/publications/papers/2021-cav.pdf
// Original C / SSE config: see originals/grub.c , originals/grub.config.ini
// ---------------------------------------------------------------------
// Robust reachability  =  <<controlled>> F bug :  a bug is robustly
// reachable iff the attacker (controlled input) can trigger it WHATEVER
// the uncontrolled input does. Here ALL input is attacker-controlled
// (the keystrokes), so robust = standard reachability.
//
// The bug: backspace decrements cur_len with no underflow check; the
// off-by-two bound test then lets a write land before the buffer, onto
// the canary (the grub username-input overflow).
//
//   agent "attacker" = input("attacker")  -> keystrokes (controlled)
//
// Attacker can set the canary (robustly reachable):
//   -atl "<attacker>F{canary == 1}"
// =====================================================================

int main() {
    int cur_len = 0;
    int canary = 0;
    while (true) {
        int key = input("attacker");   // attacker-controlled keystroke
        if (key == 1) {                // backspace: NO underflow check (the bug)
            cur_len = cur_len - 1;
        } else {                       // a printable character
            if (cur_len + 2 < 16) {    // off-by-two bound check (buf_size = 16)
                if (cur_len < 0) {     // underflowed index writes onto the canary
                    canary = 1;
                }
                cur_len = cur_len + 1;
            }
        }
    }
}
