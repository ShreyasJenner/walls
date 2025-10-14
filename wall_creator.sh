#!/bin/bash

src_folder="input_images"
output_folder="output_wallpapers"

mkdir -p "$output_folder"

for img in "$src_folder"/*.{jpg,jpeg,png,bmp,gif}; do
  [ -e "$img" ] || continue

  filename=$(basename "$img")

  # Step 3: Resize to 1179x2556
  magick "$img" -resize 1179x2556\! resized.png

  # Step 4: Create black image of 1179x1179
  magick -size 1179x1179 canvas:"#000000" black.png

  # Step 5: Overlay black image onto resized image (black overlays top-left corner)
  magick resized.png black.png -gravity center -composite step5.png

  # Step 6: Apply 86% Gaussian blur (approximate radius)
  magick step5.png -blur 0x120 step6.png

  # Step 7: Resize original image to 1179x1179
  magick "$img" -resize 1179x1179\! resized_square.png

  # Step 8: Overlay resized square image to center of blurred image
  magick step6.png resized_square.png -gravity center -composite step8.png

  # Step 9: Save final image to output folder
  mv step8.png "$output_folder/$filename"

  # Step 10: Delete intermediate images
  rm resized.png black.png step5.png step6.png resized_square.png
done
