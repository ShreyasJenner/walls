#!/bin/bash

#src_folder="temp_album_dir"
src_folder="sep_images"
output_folder="output_wallpapers"
mkdir -p "$output_folder"

# Count total images
total_images=0
for img in "$src_folder"/*.{jpg,jpeg,png,bmp,gif}; do
  [ -e "$img" ] || continue
  ((total_images++))
done

if [ $total_images -eq 0 ]; then
  echo "No images found in $src_folder"
  exit 1
fi

echo "Found $total_images images. Starting processing..."

max_jobs=10

# Function to wait for background jobs if max_jobs reached
function wait_for_jobs {
  while [ $(jobs -rp | wc -l) -ge $max_jobs ]; do
    sleep 0.1
  done
}

processed=0

for img in "$src_folder"/*.{jpg,jpeg,png,bmp,gif}; do
  [ -e "$img" ] || continue

  wait_for_jobs # wait if necessary to not exceed max_jobs

  (
    # Create a unique temporary working directory for this thread
    tmp_dir=$(mktemp -d)
    filename=$(basename "$img")

    echo "Processing: $filename"

    # Step 3: Resize to 1176x2556 inside tmp_dir
    magick "$img" -resize 1176x2556\! "$tmp_dir/resized.png"

    # Step 4: Create black image of 1176x1176 inside tmp_dir
    magick -size 1176x1176 canvas:"#000000" "$tmp_dir/black.png"

    # Step 5: Overlay black image onto resized image inside tmp_dir
    magick "$tmp_dir/resized.png" "$tmp_dir/black.png" -gravity center -composite "$tmp_dir/step5.png"

    # Step 6: Apply 86% Gaussian blur approx radius inside tmp_dir
    magick "$tmp_dir/step5.png" -blur 0x110 "$tmp_dir/step6.png"

    # Step 7: Resize original image to 1176x1176 inside tmp_dir
    magick "$img" -resize 1176x1176\! "$tmp_dir/resized_square.png"

    # Step 8: Overlay resized square image to center of blurred image inside tmp_dir
    magick "$tmp_dir/step6.png" "$tmp_dir/resized_square.png" -gravity center -composite "$tmp_dir/step8.png"

    # Step 9: Move final image to output folder
    mv "$tmp_dir/step8.png" "$output_folder/$filename"

    # Step 10: Cleanup temporary directory
    rm -rf "$tmp_dir"
  ) &

  ((processed++))
done

wait # Wait for all background jobs to finish

echo "Processing complete. $processed wallpapers created."
