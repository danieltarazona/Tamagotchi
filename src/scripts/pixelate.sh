# ~/tamagotchi/src/scripts/pixelate.sh "tamagotchi/src/assets/sprites/egg"
# "$USERPROFILE\pixelator/_pixelator_cmd.exe" "$USERPROFILE/tamagotchi/src/assets/sprites/egg/1.png" "$USERPROFILE/tamagotchi/src/assets/sprites/egg/test.png" --pixelate 2 --colors 8 --palette_mode adaptive --enhance 2 --smooth 2 --smooth_iterations 1 --refine_edges 250 --stroke outside --stroke_opacity 1 --stroke_on_colors_diff 0 --background "#00000000" --stroke_color "#000000ff" --palette_file ""
cd "$USERPROFILE/pixelator"
chmod 750 _pixelator_cmd.exe
"$USERPROFILE\pixelator/_pixelator_cmd.exe" --license
rm -rf "$USERPROFILE/$1/pixelart"
mkdir "$USERPROFILE/$1/pixelart"
for image in $(ls -v $USERPROFILE/$1);
do
"./_pixelator_cmd.exe" "$USERPROFILE/$1/$image" "$USERPROFILE/$1/pixelart/$image" --pixelate 2 --colors 8 --palette_mode adaptive --enhance 2 --smooth 2 --smooth_iterations 1 --refine_edges 250 --stroke outside --stroke_opacity 1 --stroke_on_colors_diff 0 --background "#00000000" --stroke_color "#000000ff" --palette_file ""
#cp "C:\Users\GoVirus\pixelator/__preview_pic.png" "$USERPROFILE/$1/pixelart/"
#mv "$USERPROFILE/$1/pixelart/__preview_pic.png" "$USERPROFILE/$1/pixelart/$image"
text="_original"
rm "$USERPROFILE/$1/pixelart/$image$text" 
echo $image
done
