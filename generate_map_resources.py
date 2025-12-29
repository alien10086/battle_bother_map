import xml.etree.ElementTree as ET
import os
import uuid

# --- Configuration ---
XML_FILE_PATH = 'assets/hexagonTerrain_sheet.xml'
OUTPUT_DIR = 'resource/map'
TEXTURE_RESOURCE_PATH = 'res://assets/hexagonTerrain_sheet.png'
# This UID is found in the existing .tres files and should be consistent
TEXTURE_EXT_RESOURCE_UID = 'uid://b2fb7lkugqaas'
# ---

def generate_tres_files():
    """
    Parses the TextureAtlas XML and generates individual .tres files for each SubTexture.
    """
    # Ensure the output directory exists
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    print(f"Output directory '{OUTPUT_DIR}' ensured.")

    # Clean up old .tres files in the directory, except for files that shouldn't be removed.
    for item in os.listdir(OUTPUT_DIR):
        if item.endswith(".tres"):
            print(f"Removing old file: {item}")
            os.remove(os.path.join(OUTPUT_DIR, item))

    # Parse the XML file
    try:
        tree = ET.parse(XML_FILE_PATH)
        root = tree.getroot()
    except FileNotFoundError:
        print(f"Error: XML file not found at '{XML_FILE_PATH}'")
        return
    except ET.ParseError:
        print(f"Error: Failed to parse XML file at '{XML_FILE_PATH}'")
        return

    # Godot .tres file template
    tres_template = (
        '[gd_resource type="AtlasTexture" load_steps=2 format=3 uid="uid://{resource_uid}"]\n\n'
        '[ext_resource type="Texture2D" uid="{texture_uid}" path="{texture_path}" id="1_ovi56"]\n\n'
        '[resource]\n'
        'atlas = ExtResource("1_ovi56")\n'
        'region = Rect2({x}, {y}, {width}, {height})\n'
    )

    # Process each SubTexture
    for sub_texture in root.findall('SubTexture'):
        name = sub_texture.get('name')
        x = sub_texture.get('x')
        y = sub_texture.get('y')
        width = sub_texture.get('width')
        height = sub_texture.get('height')

        if not all([name, x, y, width, height]):
            print(f"Skipping SubTexture with missing attributes: {sub_texture.attrib}")
            continue

        # Generate a unique UID for the resource itself
        resource_uid = str(uuid.uuid4()).replace('-', '')[:12]

        # Format the content for the .tres file
        tres_content = tres_template.format(
            resource_uid=resource_uid,
            texture_uid=TEXTURE_EXT_RESOURCE_UID,
            texture_path=TEXTURE_RESOURCE_PATH,
            x=x,
            y=y,
            width=width,
            height=height
        )

        # Determine the output filename
        base_name = os.path.splitext(name)[0]
        output_filename = os.path.join(OUTPUT_DIR, f"{base_name}.tres")

        # Write the new .tres file
        try:
            with open(output_filename, 'w') as f:
                f.write(tres_content)
            print(f"Successfully generated: {output_filename}")
        except IOError as e:
            print(f"Error writing to file {output_filename}: {e}")

    print("\nFinished generating all .tres files.")

if __name__ == "__main__":
    generate_tres_files()
