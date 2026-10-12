#!/bin/bash

WALLPAPER_DIRECTORY="$HOME/Pictures/Wallpapers"

# PICTURES=($(find -L "$WALLPAPER_DIRECTORY" -type f -iname "*.png" -iname "*.jpeg" -iname "*.jpg" -iname "*.webp" -iname "*.gif"))
PICTURES=($(find -L "$WALLPAPER_DIRECTORY" -type f \( \
        -name "*.png" -o \
        -name "*.jpeg" -o \
        -name "*.jpg" -o \
        -name "*.webp" -o \
        -name "*.gif" \
    \)
))

MONITORS=($(awww query | awk -F ': ' '/[0-9]+x[0-9]+/ {print $2}'))

for MONITOR in "${MONITORS[@]}"
do
        RANDOM_WALLPAPER=${PICTURES[$(($RANDOM % ${#PICTURES[@]}))]}
        awww img $RANDOM_WALLPAPER \
                -o $MONITOR \
                --transition-fps 60 \
                --transition-type any \
                --transition-duration 1 \
                --transition-bezier ".43,1.19,1,.4"
done

# for PIC in "${PICTURES[@]};"
# do
#         echo "$PIC"
# done
#
