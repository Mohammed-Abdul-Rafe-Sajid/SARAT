import os
import sys
import subprocess
import shutil

sarat_root_dir = "/home/osf/SearchAndRescueTool"

ferret_command = "/usr/local/ferret/bin/ferret"
ferret_script = f"{sarat_root_dir}/landoceancheck.jnl"

def isLonLatInOcean(lon, lat):
    output = subprocess.check_output([ferret_command, "-script", ferret_script, lon, lat])
    output_f = float(output)
    if output_f < 0:
        print(f"{lon}, {lat}: Ocean: {output_f}")
        return True
    
    print(f"{lon}, {lat}: Land: {output_f}")
    return False


def generateFinalConvexHull(sarat_unique_id):
    sarat_hull_file_basename = f"hull_{sarat_unique_id}.dat"
    sarat_hull_file_path = os.path.join(sarat_root_dir, sarat_hull_file_basename)
    if not os.path.isfile(sarat_hull_file_path) or os.path.getsize(sarat_hull_file_path) <= 0:
        print(f"Unable to find the input hull file {sarat_hull_file_path} or its size is zero", file = sys.stderr)
        sys.exit(2)

    sarat_finalhull_file_basename = f"finalconvexhull_{sarat_unique_id}.dat"
    sarat_finalhull_file_path = os.path.join(sarat_root_dir, sarat_finalhull_file_basename)

    try:
        # Update area_<run_number>.dat also according to the pruned out values. make a backup
        # in case
        sarat_area_file_basename = f"area_{sarat_unique_id}.dat"
        sarat_area_file_original_basename = f"area_original_{sarat_unique_id}.dat"
        sarat_area_file_path = f"{sarat_root_dir}/{sarat_area_file_basename}"
        sarat_area_file_original_path = f"{sarat_root_dir}/{sarat_area_file_original_basename}"
        
        shutil.copy2(sarat_area_file_path, sarat_area_file_original_path)

        area_list = []
        with open(sarat_area_file_original_path, "rt") as saratAreaFileFd:
            for area_line in saratAreaFileFd:
                area_line = area_line.strip()
                area_list.append(area_line)



        output_tuples_list = []
        output_area_index_list = []
        with open(sarat_hull_file_path, "rt") as saratHullFileFd:
            line_counter = 0
            area_counter = 0
            lonlat_tuples_list = []
            atleast_one_point_in_ocean = False

            for hull_file_line in saratHullFileFd:
                # split with None sep causes the split to happen on multiple whitespaces and also leading/trailing whitespaces are removed
                lon, lat = hull_file_line.split()
                if isLonLatInOcean(lon, lat):
                    atleast_one_point_in_ocean = True

                line_counter = line_counter + 1
                lonlat_tuples_list.append((lon, lat))                
                if line_counter == 4:
                    # The 4th one is usually the start one of the next polygon
                    if atleast_one_point_in_ocean:
                        for tuple_lon,tuple_lat in lonlat_tuples_list:
                            output_tuples_list.append((tuple_lon, tuple_lat))

                        output_area_index_list.append(area_counter)
                    
                    lonlat_tuples_list.clear()
                    atleast_one_point_in_ocean = False
                    line_counter = 1
                    area_counter = area_counter + 1
                    # lonlat_tuples_list.append((lon, lat))

        with open(sarat_finalhull_file_path, "wt") as saratFinalHullFileFd:
            for output_tuple_lon, output_tuple_lat in output_tuples_list:
                saratFinalHullFileFd.write(f"{output_tuple_lon} {output_tuple_lat}\n")

        with open(sarat_area_file_path, "wt") as saratAreaFileFd:
            for output_area_index in output_area_index_list:
                saratAreaFileFd.write(f"{area_list[output_area_index]}\n")

    except Exception as ex:
        print(f"Exception while reading input hull file {sarat_hull_file_path}. Error: {str(ex)}", file = sys.stderr)
        sys.exit(2)

    


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <SARAT_REQUEST_UNIQUE_ID>")
        sys.exit(2)

    generateFinalConvexHull(sys.argv[1])
    