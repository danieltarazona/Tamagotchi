echo "Creating the executable..."
cd $USERPROFILE/tamagotchi/src
echo "Building..."
rm -rf $USERPROFILE/tamagotchi/build
mkdir $USERPROFILE/tamagotchi/build
raco exe --gui -v $USERPROFILE/tamagotchi/src/main.rkt
mv $USERPROFILE/tamagotchi/src/main.exe $USERPROFILE/tamagotchi/build/
cd $USERPROFILE/tamagotchi/build
echo "Making a standalone distribution..."
raco distribute PandaSushi main.exe
# rm $USERPROFILE/tamagotchi/src/build/main.exe
mv main.exe PandaSushi.exe
echo "Making a zipfile for the distribution..."
cp -r $USERPROFILE/tamagotchi/src/assets $USERPROFILE/tamagotchi/build/PandaSushi
zip -r PandaSushi PandaSushi 
rm -rf PandaSushi
rm PandaSushi.exe
if [ ! -f pandasushi.zip ]; then
    echo "Failed!"
    exit 1
else
    echo "Done!"
    exit 0
fi
