echo "Creating the executable..."
cd $USERPROFILE/tamagotchi/src
echo "Building..."
rm -rf build
mkdir $USERPROFILE/tamagotchi/src/build
raco exe --gui -v $USERPROFILE/tamagotchi/src/main.rkt
mv $USERPROFILE/tamagotchi/src/main.exe build/
cd $USERPROFILE/tamagotchi/src/build
echo "Making a standalone distribution..."
raco distribute pandasushi main.exe
# rm $USERPROFILE/tamagotchi/src/build/main.exe
mv main.exe PandaSushi.exe
echo "Making a zipfile for the distribution..."
zip -r PandaSushi pandasushi
rm -rf pandasushi
if [ ! -f pandasushi.zip ]; then
    echo "Failed!"
    exit 1
else
    echo "Done!"
    exit 0
fi
