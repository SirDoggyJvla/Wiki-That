import os
from PIL import Image

image_folder = "../image/vehicle_renders"
output_folder = "../image/vehicle_renders_lower_res"

os.makedirs(output_folder, exists_ok=True)

def lower_res_image(image_path, output_path):
    with Image.open(image_path) as img:
        img = img.resize((img.width // 2, img.height // 2), Image.ANTIALIAS)
        img.save(output_path)

for filename in os.listdir(image_folder):
    if filename.endswith(".png"):
        input_path = os.path.join(image_folder, filename)
        output_path = os.path.join(output_folder, filename)
        lower_res_image(input_path, output_path)
        print(f"Processed {filename} to lower resolution.")
    else:
        print(f"Skipped {filename}, not a PNG file.")
        continue