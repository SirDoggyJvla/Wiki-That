import os
import shutil

paths = [
    "/home/simon/Zomboid/Workshop/Wiki-That/Contents/mods/Wiki That!/42/media/lua",
    "/home/simon/Zomboid/Workshop/Wiki-That/Contents/mods/Wiki That!/common/media/lua",
]

for path in paths:
    wikithat_folder = os.path.join(path, "WikiThat!")
    
    if os.path.exists(wikithat_folder):
        # Get all items in the WikiThat! folder
        for item in os.listdir(wikithat_folder):
            source = os.path.join(wikithat_folder, item)
            destination = os.path.join(path, item)
            
            # Copy file or directory
            if os.path.isfile(source):
                shutil.copy2(source, destination)
            elif os.path.isdir(source):
                if os.path.exists(destination):
                    shutil.rmtree(destination)
                shutil.copytree(source, destination)