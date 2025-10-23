#!/bin/bash

# Directory containing wallpaper images
# Set the wallpaper Directory according to the below global
# variables
DIR="$HOME/.wallpapers/images/"
TRACK_FILE="$HOME/.wallpapers/config/image_list.txt"
SELECTED_FILE="$HOME/.wallpapers/config/selected_image.txt"
DATE_FILE="$HOME/.wallpapers/config/date.txt"

# Create the track file if it doesn't exist
if [[ ! -f "$TRACK_FILE" ]]; then
  find "$DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) >"$TRACK_FILE"
fi

# Create the date file if it does not exist
if [ ! -f "$DATE_FILE" ]; then
  touch "$DATE_FILE"
fi

# Get todays date and the date from the text file
TODAY=$(date +"%d-%m-%Y")
STORED_DATE=$(cat "$DATE_FILE")

# Get the selected image from the file if the two dates match
if [ "$STORED_DATE" == "$TODAY" ]; then
  selected=$(cat "$SELECTED_FILE")
else
  # Select a random image from the track file
  selected=$(shuf -n 1 "$TRACK_FILE")

  # Write the selected image and date to the corresponding files
  echo "$selected" >"$SELECTED_FILE"
  echo "$TODAY" >"$DATE_FILE"

  # Remove the selected image from the track file
  grep -v -F "$selected" "$TRACK_FILE" >"$TRACK_FILE.tmp"
  mv "$TRACK_FILE.tmp" "$TRACK_FILE"

  # Reset the track file if all images have been used
  if [[ ! -s "$TRACK_FILE" ]]; then
    find "$DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) >"$TRACK_FILE"

    grep -v -F "$selected" "$TRACK_FILE" >"$TRACK_FILE.tmp"
    mv "$TRACK_FILE.tmp" "$TRACK_FILE"
  fi
fi

# Set the selected image as the desktop background and create a blurred image in /tmp
feh --no-fehbg --bg-fill "$selected"
magick "$selected" -resize 1920x1080^ -gravity center -extent 1920x1080 -blur 0x5 "/tmp/lock.png"
