import os
import requests
from dotenv import load_dotenv
import spotipy
from spotipy.oauth2 import SpotifyOAuth

load_dotenv()

scope = "user-library-read"
download_folder = "source_images"
os.makedirs(download_folder, exist_ok=True)

sp = spotipy.Spotify(auth_manager=SpotifyOAuth(scope=scope))

albums = []
results = sp.current_user_saved_albums(limit=50)
while results:
    albums.extend(results['items'])
    results = sp.next(results) if results.get('next') else None

total = len(albums)
for idx, item in enumerate(albums, start=1):
    album = item['album']
    name = album['name']
    safe_name = "".join(c for c in name if c.isalnum() or c in " _-").rstrip()
    filename = f"{album['id']}_{safe_name}.jpg"
    path = os.path.join(download_folder, filename)
    if os.path.exists(path):
        print(f"Skipping ({idx}/{total}): {name} (already downloaded)")
        continue
    print(f"Downloading ({idx}/{total}): {name}")
    url_640 = next((img['url'] for img in album['images']
                    if img['height']==640 and img['width']==640), None)
    if not url_640:
        print(f"No 640x640 image for: {name}")
        continue
    resp = requests.get(url_640, stream=True)
    if resp.status_code == 200:
        with open(path, 'wb') as f:
            for chunk in resp.iter_content(1024):
                f.write(chunk)

