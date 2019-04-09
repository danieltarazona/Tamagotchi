echo "Creating the executable..."
raco exe main.rkt
echo "Making a standalone distribution..."
raco distribute pandasushi main
rm main
echo "Making a zipfile for the distribution..."
zip -r pandasushi pandasushi
rm -rf pandasushi
if [ ! -f pandasushi.zip ]; then
    echo "Failed!"
    exit 1
else
    echo "Done!"
    exit 0
fi