#!/bin/bash

input_folder="temp_album_dir"
output_folder="output_images"
mkdir -p "$output_folder"

# Initialize counter
counter=0

for img in "$input_folder"/*.{jpg,jpeg,png}; do
  # Skip if no files match
  [[ -e "$img" ]] || continue

  # Increment counter
  ((count++))

  filename=$(basename "$img")
  name="${filename%.*}"

  echo "Walling ${name} (${count}/${total})"

  # resize original to 1179x2556
  magick "$img" -resize 1179x2556\! "$output_folder/${name}_resized.png"

  # Apply strong gaussian blur (approx 86% intensity visually)
  # Gaussian blur radius and sigma can be tuned; here radius=0 (auto), sigma=20 for strong blur
  magick "$output_folder/${name}_resized.png" -blur 0x40 "$output_folder/${name}_blurred.png"

  # Resize original to 1179x1179
  magick "$img" -resize 1179x1179\! "$output_folder/${name}_small.png"

  # Overlay small resized image onto blurred image (centered)
  # Using -gravity center to position overlay and composite
  magick "$output_folder/${name}_blurred.png" \
    "$output_folder/${name}_small.png" -gravity center -composite \
    -quality 90 "$output_folder/${name}.jpg"

  # Cleanup intermediate images
  rm "$output_folder/${name}_resized.png" "$output_folder/${name}_blurred.png" "$output_folder/${name}_small.png"
done
