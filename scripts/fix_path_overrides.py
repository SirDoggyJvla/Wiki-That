import os
import shutil

paths = [
    "/home/simon/Zomboid/Workshop/Wiki-That/Contents/mods/Wiki That!/42/media/lua/client",
    "/home/simon/Zomboid/Workshop/Wiki-That/Contents/mods/Wiki That!/common/media/lua/server",
    "/home/simon/Zomboid/Workshop/Wiki-That/Contents/mods/Wiki That!/common/media/lua/shared"
]

### DON'T RUN TWICE ON THE SAME FILES

def recurse_copy_and_empty(src, dest):
    if os.path.isfile(src):
        shutil.copy2(src, dest)
        with open(src, 'w', encoding='utf-8') as f:
            f.write('')
    elif os.path.isdir(src):
        os.makedirs(dest, exist_ok=True)
        for item in os.listdir(src):
            s_item = os.path.join(src, item)
            d_item = os.path.join(dest, item)
            recurse_copy_and_empty(s_item, d_item)

input("DO NOT RUN THIS SCRIPT TWICE ON THE SAME FILES. PRESS ENTER TO CONTINUE...")
for path in paths:
    wikithat_folder = os.path.join(path, "WikiThat!")
    os.makedirs(wikithat_folder, exist_ok=True)
    
    # Get all items in the parent path (excluding WikiThat! folder)
    for item in os.listdir(path):
        if item == "WikiThat!":
            continue
        source = os.path.join(path, item)
        destination = os.path.join(wikithat_folder, item)
        
        # Copy file or directory
        recurse_copy_and_empty(source, destination)