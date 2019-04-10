touch $2
awk '{ sub("\r$", ""); print }' $1 > $2
rm $1
mv $2 $1
