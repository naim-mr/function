echo "--- BUILDING ---"
dune build
echo "--- Termination ---"
bash termination.sh
echo "--- Guarantee ---"
bash guarantee.sh
echo "--- Recurrence ---"
bash recurrence.sh
echo "--- CTL ---"
bash ctl.sh
echo "--- Regression diff ---"
echo "--- CLEANING ---"
dune clean