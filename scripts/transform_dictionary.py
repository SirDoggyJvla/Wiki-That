import json
import os
import requests

def parse_read_to_write(data, r2w, path_to_lua):
    for E in r2w:
        category = E['category']
        id_field = E['id']
        file_name = E['file']
        second_id = E.get('second_id', None)
        print(f"Processing category '{category}' with id field '{id_field}' into file '{file_name}'")
        result = _read_json_entry(data, category, id_field, second_id)
        file_path = os.path.join(path_to_lua, file_name)
        _dict_to_lua_table(result, file_path, descriptor=E.get('descriptor', None), E=E)

def _download_dictionary():
    url = "https://raw.githubusercontent.com/Vaileasys/pz-wiki_parser/main/resources/page_dictionary.json"
    response = requests.get(url)
    if response.status_code == 200:
        with open('./scripts/page_dictionary.json', 'w', encoding='utf-8') as f:
            f.write(response.text)
    else:
        raise Exception(f"Failed to download file: {response.status_code}")

def _read_json_entry(data, category, id_field, second_id=None, multi_id=None):
    result = {}

    # check if category exists, if it doesn't it's not normal behavior
    if category not in data:
        raise ValueError(f"Category '{category}' not found in data.")

    # parse each entry in the specified category
    for page_name, entry in data[category].items():
        id = entry.get(id_field) # this retrieves a list
        
        if id is None:
            continue

        # parse every id in the list
        for i in id:
            # handle second id formatting
            if second_id is not None:
                for s in entry.get(second_id, []):
                    kwargs = {second_id: s}
                    formated_id = i.format(**kwargs)
                    
                    # id can be:
                    # the_id_10+11+12+13
                    # need to split by + and format to have:
                    # the_id_10  the_id_11  the_id_12  the_id_13
                    if '+' in formated_id:
                        ids = format_multi_tile_id(formated_id)
                        for the_id in ids:
                            result[the_id] = page_name
                        continue # end multi id case
                    
                    result[formated_id] = page_name
                continue # end second id case

            if '+' in i:
                ids = format_multi_tile_id(i)
                for the_id in ids:
                    result[the_id] = page_name
                continue # end multi id case

            result[i] = page_name
                
    return result


def format_multi_tile_id(id):
    """
    Format a multi-tile ID into individual IDs.
    An ID can be like: `the_id_10+11+12+13`.
    This function will split it into:
    - the_id_10
    - the_id_11
    - the_id_12
    - the_id_13

    Args:
        id (str): The formatted multi-tile ID string.

    Returns:
        list: List of individual tile ID strings.
    """
    # prepare parts
    parts = id.split('+')
    early_part = parts[0].split('_')[0:-1]
    early_part = '_'.join(early_part) + '_'

    # for each parts, format it to a proper ID
    ids = []
    for part in parts:
        part = part.split('_')[-1]
        part = early_part + part
        ids.append(part)
        
    return ids


def _dict_to_lua_table(d, file_path, descriptor=None, E=None):
    """
    Format a Python dictionary to a Lua table in a file.

    Args:
        d (dict): The dictionary to convert.
        file_path (str): Path to the output Lua file.
        descriptor (str, optional): Description to add as a comment. Defaults to None.
    """
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(f'-- THIS FILE IS AUTO-GENERATED. DO NOT EDIT MANUALLY.\n')
        if descriptor:
            f.write(f'-- {descriptor}\n')
        f.write('return {\n')
        if "phantom_table" in E:
            phantom_table = E["phantom_table"]
            f.write(f'    ["{phantom_table}"] = {{\n')
            f.write('        -- This is a phantom table to store additional mappings.\n')
            f.write('    },\n')
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
    path_to_lua = "Contents/mods/Wiki That!/common/media/lua/shared/WikiThat!/data"

    """
        category: the top-level key in the JSON (e.g., "item", "vehicle", etc.)
        id: the key within each entry to use as the dictionary key (e.g., "rm_guid", "type", etc.)
        second_id: (optional) a secondary key to format the id (e.g., "sprite_id")
        file: the output Lua file name
        descriptor: (optional) a comment to describe the dictionary's purpose inside the Lua file
    """
    with open('./scripts/read_to_write.json', 'r', encoding='utf-8') as f:
        read_to_write = json.load(f)

    # https://github.com/Vaileasys/pz-wiki_parser/blob/main/resources/page_dictionary.json
    _download_dictionary()
    with open('./scripts/page_dictionary.json', 'r', encoding='utf-8') as f:
        data = json.load(f)

    os.makedirs(path_to_lua, exist_ok=True)

    parse_read_to_write(data, read_to_write, path_to_lua)



