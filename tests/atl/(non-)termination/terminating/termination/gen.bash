yourfilenames=`ls ./*.c`
for eachfile in $yourfilenames
do
	base=$(basename "$eachfile" .c)
	json="${base}.json"
	echo '{"property":"AF{exit:true}"}' > "$json"
done
