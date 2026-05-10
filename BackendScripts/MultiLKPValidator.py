#!/usr/bin/env python3
"""
MultiLKPValidator.py - Multi-Location Release Point Validator
Validates all locations in multi-release mode using existing land-check logic
Author: SARAT V3
"""

import sys
import json
import subprocess
import os
from datetime import datetime

class MultiLKPValidator:
    """Validates multiple seeding locations"""
    
    def __init__(self, config_file, sarat_home="/home/osf/SearchAndRescueTool"):
        self.config_file = config_file
        self.sarat_home = sarat_home
        self.case_id = None
        self.validation_results = []
        self.land_check_script = f"{sarat_home}/BackendScripts/LandCheckingFromConvexHullV2.py"
        
    def load_config(self):
        """Load release configuration JSON"""
        try:
            with open(self.config_file, 'r') as f:
                self.config = json.load(f)
            self.case_id = self.config.get('unique_id', 'unknown')
            return True
        except Exception as e:
            print(f"ERROR: Failed to load config: {e}")
            return False
    
    def validate_location(self, location_idx, latitude, longitude):
        """
        Validate single location using land-ocean check
        Returns: (valid, message)
        """
        location_num = location_idx + 1
        
        print(f"[Validator] Checking location {location_num}: ({latitude}, {longitude})")
        
        # Coordinate range check
        if latitude < -90 or latitude > 90:
            msg = f"Location {location_num}: Invalid latitude {latitude}"
            print(f"ERROR: {msg}")
            return False, msg
        
        if longitude < -180 or longitude > 180:
            msg = f"Location {location_num}: Invalid longitude {longitude}"
            print(f"ERROR: {msg}")
            return False, msg
        
        # Land-ocean check using existing script
        try:
            # Call existing land check script
            result = subprocess.run(
                ['python3', self.land_check_script, 
                 str(latitude), str(longitude), 
                 f"{self.case_id}_loc{location_num}",
                 f"{self.sarat_home}/case{self.case_id}"],
                capture_output=True,
                text=True,
                timeout=10
            )
            
            if result.returncode != 0:
                msg = f"Location {location_num}: Land check failed - Object on land"
                print(f"ERROR: {msg}")
                print(result.stderr)
                return False, msg
            
            msg = f"Location {location_num}: Valid (ocean)"
            print(f"OK: {msg}")
            return True, msg
            
        except subprocess.TimeoutExpired:
            msg = f"Location {location_num}: Land check timeout"
            print(f"ERROR: {msg}")
            return False, msg
        except Exception as e:
            msg = f"Location {location_num}: Land check error - {str(e)}"
            print(f"ERROR: {msg}")
            return False, msg
    
    def validate_all_locations(self):
        """Validate all locations based on release mode"""
        if not self.load_config():
            return False
        
        mode = self.config.get('mode', 'single')
        print(f"\n[Validator] Validating {mode} mode - {self.case_id}")
        
        if mode == 'single':
            return self.validate_single()
        elif mode == 'multi_location':
            return self.validate_multi_location()
        elif mode == 'continuous_source':
            return self.validate_continuous_source()
        else:
            print(f"ERROR: Unknown mode '{mode}'")
            return False
    
    def validate_single(self):
        """Validate single release location"""
        try:
            config = self.config['seeding_configs'][0]
            location = config['locations'][0]
            
            lat = float(location['latitude'])
            lon = float(location['longitude'])
            
            valid, msg = self.validate_location(0, lat, lon)
            self.validation_results.append({'location': 1, 'valid': valid, 'message': msg})
            
            return valid
            
        except Exception as e:
            print(f"ERROR: Exception validating single location: {e}")
            return False
    
    def validate_multi_location(self):
        """Validate all locations in multi-location mode"""
        try:
            config = self.config['seeding_configs'][0]
            locations = config['locations']
            location_count = config['location_count']
            
            if len(locations) < 2:
                print(f"ERROR: Multi-location requires 2+ locations, got {len(locations)}")
                return False
            
            if len(locations) != location_count:
                print(f"WARNING: Location count mismatch: {len(locations)} vs {location_count}")
            
            all_valid = True
            for loc_idx, location in enumerate(locations):
                lat = float(location['latitude'])
                lon = float(location['longitude'])
                
                valid, msg = self.validate_location(loc_idx, lat, lon)
                self.validation_results.append({
                    'location': loc_idx + 1,
                    'valid': valid,
                    'message': msg
                })
                
                if not valid:
                    all_valid = False
            
            return all_valid
            
        except Exception as e:
            print(f"ERROR: Exception validating multi-location: {e}")
            return False
    
    def validate_continuous_source(self):
        """Validate start, end, and sampled points in continuous source mode"""
        try:
            config = self.config['seeding_configs'][0]
            release_points = config['release_points']
            
            print(f"[Validator] Validating {len(release_points)} trajectory points")
            
            # Always check first and last points
            check_indices = [0, len(release_points) - 1]
            
            # Also check middle point if enough points
            if len(release_points) > 4:
                check_indices.append(len(release_points) // 2)
            
            check_indices = sorted(set(check_indices))
            
            all_valid = True
            for check_idx in check_indices:
                point = release_points[check_idx]
                lat = float(point['latitude'])
                lon = float(point['longitude'])
                time = point['release_time']
                
                print(f"[Validator] Point {check_idx + 1}/{len(release_points)} at {time}")
                valid, msg = self.validate_location(check_idx, lat, lon)
                
                self.validation_results.append({
                    'point': check_idx + 1,
                    'time': time,
                    'valid': valid,
                    'message': msg
                })
                
                if not valid:
                    all_valid = False
            
            if not all_valid:
                print(f"ERROR: Trajectory crosses land at one or more points")
                return False
            
            print(f"OK: Trajectory validated (checked {len(check_indices)} representative points)")
            return True
            
        except Exception as e:
            print(f"ERROR: Exception validating continuous source: {e}")
            return False
    
    def get_validation_report(self):
        """Generate validation report as JSON"""
        return {
            'timestamp': datetime.now().isoformat(),
            'case_id': self.case_id,
            'mode': self.config.get('mode'),
            'total_locations': len(self.validation_results),
            'valid_locations': sum(1 for r in self.validation_results if r['valid']),
            'results': self.validation_results,
            'overall_status': 'PASS' if all(r['valid'] for r in self.validation_results) else 'FAIL'
        }
    
    def write_validation_report(self, output_file=None):
        """Write validation report to file"""
        if not output_file:
            output_file = f"validation_report_{self.case_id}.json"
        
        report = self.get_validation_report()
        
        with open(output_file, 'w') as f:
            json.dump(report, f, indent=4)
        
        print(f"\nValidation report written to: {output_file}")
        return output_file


def main():
    """CLI interface"""
    if len(sys.argv) < 2:
        print("Usage: python3 MultiLKPValidator.py <config_file> [output_report]")
        print("  config_file: release_config_UNIQ_ID.json")
        print("  output_report: optional output file for validation report")
        sys.exit(1)
    
    config_file = sys.argv[1]
    output_report = sys.argv[2] if len(sys.argv) > 2 else None
    
    if not os.path.exists(config_file):
        print(f"ERROR: Config file not found: {config_file}")
        sys.exit(1)
    
    validator = MultiLKPValidator(config_file)
    
    if not validator.validate_all_locations():
        print("\nERROR: Validation failed")
        sys.exit(1)
    
    # Write report
    if output_report:
        validator.write_validation_report(output_report)
    else:
        report = validator.get_validation_report()
        print(f"\nValidation Report:")
        print(json.dumps(report, indent=2))
    
    print(f"\n[Validator] Overall Status: {report['overall_status']}")
    sys.exit(0 if report['overall_status'] == 'PASS' else 1)


if __name__ == '__main__':
    main()
