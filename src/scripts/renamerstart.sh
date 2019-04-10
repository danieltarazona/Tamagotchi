i=$2
for file in $(ls -v $USERPROFILE/$1);
do
    mv $USERPROFILE/$1/$file $USERPROFILE/$1/$i.png
    i=$((i+1))
done