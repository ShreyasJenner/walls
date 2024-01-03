'''convert \
    -size 1920x1080 \
    xc:black \
    -fill white \
    -pointsize 28 \
    -gravity center \
    -annotate +0+0 "$(cat notes.txt)" \
    -gravity west \
    -geometry +0+0 \
    notes.png
'''

## text file notes.txt stores lines that will be placed in image
convert -size 1920x1080 xc:black notes.png
ffmpeg -i notes.png -vf "drawtext=textfile=notes.txt:fontcolor=white:fontsize=28:x=(W-tw)/2:y=(H-th)/2" -c:a copy output.png


feh --bg-scale output.png
