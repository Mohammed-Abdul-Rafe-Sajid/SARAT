import os
import json

def get_color(prob):
    # KML colors are aabbggrr (hex)
    # Replicating Leaflet colors:
    # >70: #800026 -> KML: ff260080
    # >50: #BD0026 -> KML: ff2600bd
    # >30: #E31A1C -> KML: ff1c1ae3
    # >20: #FC4E2A -> KML: ff2a4efc
    # >10: #FD8D3C -> KML: ff3c8dfd
    # >5 : #FEB24C -> KML: ff4cb2fe
    # >1 : #FED976 -> KML: ff76d9fe
    # else #FFEDA0 -> KML: ffa0edff
    
    if prob > 70: return 'ff260080'
    elif prob > 50: return 'ff2600bd'
    elif prob > 30: return 'ff1c1ae3'
    elif prob > 20: return 'ff2a4efc'
    elif prob > 10: return 'ff3c8dfd'
    elif prob > 5: return 'ff4cb2fe'
    elif prob > 1: return 'ff76d9fe'
    else: return 'ffa0edff'

def geojson_to_kml(geojson_path, kml_path):
    with open(geojson_path, 'r') as f:
        data = json.load(f)
        
    kml = ['<?xml version="1.0" encoding="UTF-8"?>',
           '<kml xmlns="http://www.opengis.net/kml/2.2">',
           '<Document>']
           
    features = data.get('features', [])
    for idx, feature in enumerate(features):
        geom_type = feature.get('geometry', {}).get('type')
        coords = feature.get('geometry', {}).get('coordinates', [])
        props = feature.get('properties', {})
        
        prob = props.get('probability', props.get('max_probability', 0))
        poly_type = props.get('type', 'grid_cell')
        
        # Style
        color = get_color(prob)
        if poly_type == 'bounding_box':
            # transparent fill, thick border
            kml.append('<Style id="style_{}">'.format(idx))
            kml.append('<LineStyle><color>ff0000ff</color><width>3</width></LineStyle>')
            kml.append('<PolyStyle><color>00ffffff</color></PolyStyle>')
            kml.append('</Style>')
        else:
            # solid fill, thin border
            kml.append('<Style id="style_{}">'.format(idx))
            kml.append('<LineStyle><color>ff000000</color><width>1</width></LineStyle>')
            kml.append('<PolyStyle><color>{}</color></PolyStyle>'.format(color))
            kml.append('</Style>')

        kml.append('<Placemark>')
        kml.append('<name>{}</name>'.format(poly_type))
        kml.append('<description>Probability: {}%</description>'.format(prob))
        kml.append('<styleUrl>#style_{}</styleUrl>'.format(idx))
        
        if geom_type == 'Polygon':
            kml.append('<Polygon><outerBoundaryIs><LinearRing><coordinates>')
            coord_str = " ".join(["{},{},0".format(lon, lat) for lon, lat in coords[0]])
            kml.append(coord_str)
            kml.append('</coordinates></LinearRing></outerBoundaryIs></Polygon>')
        
        kml.append('</Placemark>')
        
    kml.append('</Document></kml>')
    
    with open(kml_path, 'w') as f:
        f.write("\n".join(kml))

def convert_all(case_dir):
    import glob
    files = glob.glob(os.path.join(case_dir, "interval_*.geojson"))
    for f in files:
        kml_file = f.replace('.geojson', '.kml')
        geojson_to_kml(f, kml_file)
        print("Generated:", kml_file)

if __name__ == '__main__':
    convert_all("case6687")
