import os
from PIL import Image
from tqdm import tqdm

def lower_res_image(image, new_height=128):
    width, height = image.size
    aspect_ratio = width / height
    new_width = int(aspect_ratio * new_height)
    image = image.resize((new_width, new_height), Image.Resampling.LANCZOS)
    return image

def load_image(image_path):
    with Image.open(image_path) as img:
        return img.copy()
    
def reframe_transparent_borders(image):
    # remove borders around the object that are fully transparent
    bbox = image.getbbox()
    if bbox:
        return image.crop(bbox)
    return image  # if the image is fully transparent, return as is

if __name__ == "__main__":
    image_folder = "./image/vehicle_renders"
    image_folder = os.path.abspath(image_folder)
    output_folder = "./Contents/mods/Wiki That!/common/media/ui/vehicle_icons"
    output_folder = os.path.abspath(output_folder)

    os.makedirs(output_folder, exist_ok=True)

    for filename in tqdm(os.listdir(image_folder), desc="Processing images", unit="file"):
        if not filename.endswith(".png"):
            continue
        
        input_path = os.path.join(image_folder, filename)
        output_path = os.path.join(output_folder, filename)
        
        img = load_image(input_path)
        img = reframe_transparent_borders(img)
        img = lower_res_image(img, new_height=64)
        img.save(output_path)
