echo "--- BUILDING ---"
bash build.sh
echo "--- Termination ---"
bash termination.sh
echo "--- Guarantee ---"
bash guarantee.sh
echo "--- Recurrence ---"
bash recurrence.sh
echo "--- CTL ---"
bash ctl.sh
echo "--- Regression diff ---"
diff -x "*.out" -r diff/ logs/ 
echo "--- CLEANING ---"
bash clean.sh