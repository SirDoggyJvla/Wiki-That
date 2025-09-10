import json
import os
import requests

def parse_read_to_write(data, r2w):
    for E in r2w:
        category = E['category']
        id_field = E['id']
        file_name = E['file']
        second_id = E.get('second_id', None)
        print(f"Processing category '{category}' with id field '{id_field}' into file '{file_name}'")
        result = _read_json_entry(data, category, id_field, second_id)
        file_path = os.path.join(path_to_lua, file_name)
        _dict_to_lua_table(result, file_path, descriptor=E.get('descriptor', None))

def _download_dictionary():
    url = "https://raw.githubusercontent.com/Vaileasys/pz-wiki_parser/main/resources/page_dictionary.json"
    response = requests.get(url)
    if response.status_code == 200:
        with open('./scripts/page_dictionary.json', 'w', encoding='utf-8') as f:
            f.write(response.text)
    else:
        raise Exception(f"Failed to download file: {response.status_code}")

def _read_json_entry(data, category, id_field, second_id=None):
    result = {}
    for page_name, entry in data.get(category, {}).items():
        id = entry.get(id_field)
        if id:
            for i in id:
                if second_id is None:
                    result[i] = page_name
                else:
                    for s in entry.get(second_id, []):
                        kwargs = {second_id: s}
                        formated_id = i.format(**kwargs)
                        result[formated_id] = page_name
    return result

def _dict_to_lua_table(d, file_path, descriptor=None):
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(f'-- THIS FILE IS AUTO-GENERATED. DO NOT EDIT MANUALLY.\n')
        if descriptor:
            f.write(f'-- {descriptor}\n')
        f.write('return {\n')
        for key, value in d.items():
            if isinstance(value, dict):
                f.write(f'    ["{key}"] = {{\n')
                for k, v in value.items():
                    if isinstance(v, str):
                        f.write(f'        {k} = "{v}",\n')
                    elif isinstance(v, list):
                        f.write(f'        {k} = {{\n')
                        for item in v:
                            if isinstance(item, str):
                                f.write(f'            "{item}",\n')
                            else:
                                f.write(f'            {item},\n')
                        f.write('        },\n')
                    else:
                        f.write(f'        {k} = {v},\n')
                f.write('    },\n')
            else:
                # Handle simple key-value pairs (e.g., string to string)
                if isinstance(value, str):
                    escaped_value = value.replace('"', '\\"')
                    f.write(f'    ["{key}"] = "{escaped_value}",\n')
                else:
                    f.write(f'    ["{key}"] = {value},\n')
        f.write('}\n')


if __name__ == "__main__":
    path_to_lua = "Contents/mods/Wiki That!/common/media/lua/shared/data"
    read_to_write = [
        {"category": "item", "id": "item_id", "file": "WT_items.lua", "descriptor": "Item dictionary"},
        {"category": "fluid", "id": "fluid_id", "file": "WT_fluids.lua", "descriptor": "Fluid dictionary"},
        {"category": "vehicle", "id": "vehicle_id", "file": "WT_vehicles.lua", "descriptor": "Vehicle dictionary"},
        {"category": "tile", "id": "item_id", "second_id": "sprite_id", "file": "WT_moveables.lua", "descriptor": "Moveable dictionary"},
    ]

    # https://github.com/Vaileasys/pz-wiki_parser/blob/main/resources/page_dictionary.json
    _download_dictionary()
    with open('./scripts/page_dictionary.json', 'r', encoding='utf-8') as f:
        data = json.load(f)

    os.makedirs(path_to_lua, exist_ok=True)

    parse_read_to_write(data, read_to_write)



