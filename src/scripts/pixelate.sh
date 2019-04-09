# ~/tamagotchi/src/scripts/pixelate.sh "tamagotchi/src/assets/sprites/egg"
mkdir "$USERPROFILE/$1/pixelart"
for image in $(ls -v $USERPROFILE/$1)
do
"$USERPROFILE\pixelator/_pixelator_cmd.exe" "$USERPROFILE/$1/$image" "$USERPROFILE/$1/pixelart/$image" --pixelate 2 --colors 8 --palette_mode adaptive --enhance 2 --smooth 2 --smooth_iterations 1 --refine_edges 250 --stroke outside --stroke_opacity 1 --stroke_on_colors_diff 0 --background "#00000000" --stroke_color "#000000ff" --palette_file ""
done

# "C:\Users\GoVirus\pixelator/_pixelator_cmd.exe" "C:\Users\GoVirus\tamagotchi\src\assets\sprites\eat\1.png" "C:\Users\GoVirus\pixelator/__preview_pic.png" --pixelate 2 --colors 8 --palette_mode adaptive --enhance 2 --smooth 2 --smooth_iterations 1 --refine_edges 250 --stroke outside --stroke_opacity 1 --stroke_on_colors_diff 0 --background "#00000000" --stroke_color "#000000ff"    --palette_file ""