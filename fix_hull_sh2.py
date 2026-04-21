#!/usr/bin/env python3
import os

path = r'd:\osama\INCOIS\SARAT\BackendScripts\HullSegmentV2.sh'
with open(path, 'rb') as f:
    content = f.read().decode('utf-8')

# The line we put there last time:
old_line = (
    "\t\t\t\t\t# Round each lon/lat pair to 6 decimal places (%.6f) before\r\n"
    "\t\t\t\t\t# embedding in the GeoJSON coordinates array. This matches\r\n"
    "\t\t\t\t\t# the precision used by the Python GeoJSON generators.\r\n"
    "\t\t\t\t\techo \"`awk 'NR >='$x' && NR <='$y'"
    " {printf \"[%.6f,%.6f],\\n\",$1,$2} ' $Hull_Seg | sed '$ s/,$//g'`\""
    " >>${ProbabilitiesJsonFile}"
)

# New line using substr
new_line = (
    "\t\t\t\t\t# Dynamically truncate coordinates up to 6 decimal places\r\n"
    "\t\t\t\t\t# without hardcoded formatting or zero-padding.\r\n"
    "\t\t\t\t\techo \"`awk 'NR >='$x' && NR <='$y' {"
    "x=index($1,\".\"); x=(x?x+6:length($1)); "
    "y=index($2,\".\"); y=(y?y+6:length($2)); "
    "print \"[\"substr($1,1,x)\",\"substr($2,1,y)\"],\"} ' $Hull_Seg | sed '$ s/,$//g'`\""
    " >>${ProbabilitiesJsonFile}"
)

if old_line in content:
    content = content.replace(old_line, new_line)
    with open(path, 'wb') as f:
        f.write(content.encode('utf-8'))
    print("SUCCESS")
else:
    print("NOT FOUND")
