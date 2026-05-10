#!/usr/bin/env python3
"""
Multi-Release Seeding Handler
Processes three seeding modes: Single Release, Multiple Location Release, Continuous Moving Source
Author: SARAT V3
"""

import sys
import json
import math
from datetime import datetime, timedelta

class ReleaseMode:
    """Handle different particle seeding modes"""
    
    SINGLE = "single"
    MULTI_LOCATION = "multi_location"
    CONTINUOUS_SOURCE = "continuous_source"

class MultiReleaseHandler:
    """
    Processes release mode inputs and generates lwseed configuration
    """
    
    def __init__(self, release_mode, unique_id, output_dir):
        self.mode = release_mode
        self.uniq_id = unique_id
        self.output_dir = output_dir
        self.lwseed_data = []
        
    def parse_datetime(self, dt_str):
        """Parse datetime string in format YYYY-MM-DD HH:MM:SS"""
        try:
            return datetime.strptime(dt_str, "%Y-%m-%d %H:%M:%S")
        except ValueError:
            raise ValueError(f"Invalid datetime format: {dt_str}")
    
    def validate_coordinates(self, lat, lon):
        """Validate coordinate ranges"""
        if not (-90 <= lat <= 90):
            raise ValueError(f"Latitude {lat} out of range [-90, 90]")
        if not (-180 <= lon <= 180):
            raise ValueError(f"Longitude {lon} out of range [-180, 180]")
        return True
    
    def handle_single_release(self, latitude, longitude, lkt_str, simulation_end_str, seeding_duration_hours=12):
        """
        CASE 1: Single Release
        One location, one time, all particles from single point
        """
        self.validate_coordinates(latitude, longitude)
        lkt = self.parse_datetime(lkt_str)
        sim_end = self.parse_datetime(simulation_end_str)
        
        # Calculate seeding window
        seeding_start = lkt
        seeding_end = lkt + timedelta(hours=seeding_duration_hours)
        
        # Ensure seeding doesn't exceed simulation time
        if seeding_end > sim_end:
            seeding_end = sim_end
        
        lwseed_entry = {
            "mode": self.SINGLE,
            "location_count": 1,
            "locations": [
                {
                    "index": 1,
                    "latitude": latitude,
                    "longitude": longitude,
                    "release_time": lkt_str
                }
            ],
            "seeding_window_start": seeding_start.isoformat(),
            "seeding_window_end": seeding_end.isoformat(),
            "seeding_duration_hours": seeding_duration_hours,
            "particle_count": 50000,
            "particle_distribution": "single_point"
        }
        
        self.lwseed_data.append(lwseed_entry)
        return lwseed_entry
    
    def handle_multi_location_release(self, locations, multi_lkt_str, simulation_end_str, seeding_duration_hours=12):
        """
        CASE 2: Multiple Location Release
        Multiple LKPs, single LKT (all locations release at same time)
        Particles distributed equally across all locations
        """
        if len(locations) < 2:
            raise ValueError("Multi-location mode requires at least 2 locations")
        
        multi_lkt = self.parse_datetime(multi_lkt_str)
        sim_end = self.parse_datetime(simulation_end_str)
        
        # Validate all locations
        validated_locations = []
        for idx, loc in enumerate(locations, 1):
            lat = float(loc.get('latitude'))
            lon = float(loc.get('longitude'))
            self.validate_coordinates(lat, lon)
            validated_locations.append({
                "index": idx,
                "latitude": lat,
                "longitude": lon,
                "release_time": multi_lkt_str
            })
        
        # Calculate seeding window
        seeding_start = multi_lkt
        seeding_end = multi_lkt + timedelta(hours=seeding_duration_hours)
        
        if seeding_end > sim_end:
            seeding_end = sim_end
        
        # Distribute particles equally
        total_particles = 50000
        particles_per_location = total_particles // len(validated_locations)
        
        lwseed_entry = {
            "mode": self.MULTI_LOCATION,
            "location_count": len(validated_locations),
            "locations": validated_locations,
            "seeding_window_start": seeding_start.isoformat(),
            "seeding_window_end": seeding_end.isoformat(),
            "seeding_duration_hours": seeding_duration_hours,
            "total_particle_count": total_particles,
            "particles_per_location": particles_per_location,
            "particle_distribution": "equal_across_locations"
        }
        
        self.lwseed_data.append(lwseed_entry)
        return lwseed_entry
    
    def interpolate_position(self, start_pos, end_pos, start_time, end_time, current_time):
        """
        Linear interpolation of position between start and end
        Returns interpolated (lat, lon) at current_time
        """
        total_duration = (end_time - start_time).total_seconds()
        elapsed = (current_time - start_time).total_seconds()
        
        if total_duration == 0:
            return start_pos
        
        fraction = elapsed / total_duration
        
        lat = start_pos[0] + (end_pos[0] - start_pos[0]) * fraction
        lon = start_pos[1] + (end_pos[1] - start_pos[1]) * fraction
        
        return (lat, lon)
    
    def handle_continuous_moving_source(self, start_lat, start_lon, end_lat, end_lon, 
                                        start_time_str, end_time_str, simulation_end_str, 
                                        interpolation_interval_minutes=30):
        """
        CASE 3: Continuous Moving Source
        Object moves from start to end position over time interval
        Particles continuously seeded along trajectory
        """
        self.validate_coordinates(start_lat, start_lon)
        self.validate_coordinates(end_lat, end_lon)
        
        start_time = self.parse_datetime(start_time_str)
        end_time = self.parse_datetime(end_time_str)
        sim_end = self.parse_datetime(simulation_end_str)
        
        if start_time >= end_time:
            raise ValueError("Start time must be before end time")
        
        # Generate interpolated seeding points
        interpolation_interval = timedelta(minutes=interpolation_interval_minutes)
        current_time = start_time
        release_points = []
        
        while current_time <= end_time:
            lat, lon = self.interpolate_position(
                (start_lat, start_lon),
                (end_lat, end_lon),
                start_time,
                end_time,
                current_time
            )
            
            release_points.append({
                "latitude": round(lat, 6),
                "longitude": round(lon, 6),
                "release_time": current_time.isoformat(),
                "timestamp_minutes_from_start": round((current_time - start_time).total_seconds() / 60)
            })
            
            current_time += interpolation_interval
        
        # Ensure end point is included
        if release_points[-1]['release_time'] != end_time.isoformat():
            release_points.append({
                "latitude": end_lat,
                "longitude": end_lon,
                "release_time": end_time.isoformat(),
                "timestamp_minutes_from_start": round((end_time - start_time).total_seconds() / 60)
            })
        
        # Total particles distributed across time steps
        total_particles = 50000
        particles_per_step = total_particles // len(release_points) if release_points else total_particles
        
        lwseed_entry = {
            "mode": self.CONTINUOUS_SOURCE,
            "start_position": {"latitude": start_lat, "longitude": start_lon},
            "end_position": {"latitude": end_lat, "longitude": end_lon},
            "start_time": start_time_str,
            "end_time": end_time_str,
            "interpolation_interval_minutes": interpolation_interval_minutes,
            "release_points_count": len(release_points),
            "release_points": release_points,
            "total_particle_count": total_particles,
            "particles_per_release_point": particles_per_step,
            "particle_distribution": "continuous_along_trajectory"
        }
        
        self.lwseed_data.append(lwseed_entry)
        return lwseed_entry
    
    def write_lwseed_config(self, output_filename=None):
        """Write lwseed configuration to JSON file"""
        if not output_filename:
            output_filename = f"lwseed_config_{self.uniq_id}.json"
        
        output_path = f"{self.output_dir}/{output_filename}"
        
        with open(output_path, 'w') as f:
            json.dump({
                "unique_id": self.uniq_id,
                "mode": self.mode,
                "generated_at": datetime.now().isoformat(),
                "seeding_configs": self.lwseed_data
            }, f, indent=4)
        
        return output_path
    
    def generate_lwseed_input_file(self, output_base_filename=None):
        """
        Generate traditional lwseed .in format from lwseed_data
        This is for backward compatibility with existing simulation engine
        """
        if not output_base_filename:
            output_base_filename = f"lwseed_{self.uniq_id}"
        
        lines = []
        
        if self.mode == self.SINGLE:
            config = self.lwseed_data[0]
            loc = config['locations'][0]
            lines.append(f"NPART {config['particle_count']}")
            lines.append(f"LAT {loc['latitude']}")
            lines.append(f"LON {loc['longitude']}")
            lines.append(f"LKUNITS 0")
            lines.append(f"IRELEASE 1")
            
        elif self.mode == self.MULTI_LOCATION:
            config = self.lwseed_data[0]
            # For multi-location, create separate entries per location
            for loc_idx, loc in enumerate(config['locations'], 1):
                lines.append(f"# Location {loc_idx} of {config['location_count']}")
                lines.append(f"NPART {config['particles_per_location']}")
                lines.append(f"LAT {loc['latitude']}")
                lines.append(f"LON {loc['longitude']}")
                lines.append(f"LKUNITS 0")
                lines.append(f"IRELEASE {loc_idx}")
                lines.append("")
        
        elif self.mode == self.CONTINUOUS_SOURCE:
            config = self.lwseed_data[0]
            # For continuous source, add interpolated points
            for point_idx, point in enumerate(config['release_points'], 1):
                lines.append(f"# Release point {point_idx} at {point['release_time']}")
                lines.append(f"NPART {config['particles_per_release_point']}")
                lines.append(f"LAT {point['latitude']}")
                lines.append(f"LON {point['longitude']}")
                lines.append(f"LKUNITS 0")
                lines.append(f"IRELEASE {point_idx}")
                lines.append("")
        
        # Write to file
        output_path = f"{self.output_dir}/{output_base_filename}.in"
        with open(output_path, 'w') as f:
            f.write('\n'.join(lines))
        
        return output_path


def main():
    """CLI interface for MultiReleaseHandler"""
    
    if len(sys.argv) < 4:
        print("Usage: python MultiReleaseHandler.py <mode> <release_config_json> <output_dir>")
        print("  mode: single, multi_location, or continuous_source")
        print("  release_config_json: JSON file with mode-specific parameters")
        print("  output_dir: Directory for output files")
        sys.exit(1)
    
    mode = sys.argv[1]
    config_file = sys.argv[2]
    output_dir = sys.argv[3]
    
    # Load configuration
    with open(config_file, 'r') as f:
        config = json.load(f)
    
    # Create handler
    unique_id = config.get('unique_id', 'unknown')
    handler = MultiReleaseHandler(mode, unique_id, output_dir)
    
    # Process based on mode
    try:
        if mode == ReleaseMode.SINGLE:
            handler.handle_single_release(
                latitude=config['latitude'],
                longitude=config['longitude'],
                lkt_str=config['lkt'],
                simulation_end_str=config['simulation_end'],
                seeding_duration_hours=config.get('seeding_duration_hours', 12)
            )
        
        elif mode == ReleaseMode.MULTI_LOCATION:
            handler.handle_multi_location_release(
                locations=config['locations'],
                multi_lkt_str=config['multi_lkt'],
                simulation_end_str=config['simulation_end'],
                seeding_duration_hours=config.get('seeding_duration_hours', 12)
            )
        
        elif mode == ReleaseMode.CONTINUOUS_SOURCE:
            handler.handle_continuous_moving_source(
                start_lat=config['start_lat'],
                start_lon=config['start_lon'],
                end_lat=config['end_lat'],
                end_lon=config['end_lon'],
                start_time_str=config['start_time'],
                end_time_str=config['end_time'],
                simulation_end_str=config['simulation_end'],
                interpolation_interval_minutes=config.get('interpolation_interval_minutes', 30)
            )
        
        else:
            raise ValueError(f"Unknown release mode: {mode}")
        
        # Write outputs
        config_path = handler.write_lwseed_config()
        lwseed_path = handler.generate_lwseed_input_file()
        
        print(f"SUCCESS: Generated lwseed configuration")
        print(f"Config: {config_path}")
        print(f"Input: {lwseed_path}")
        
    except Exception as e:
        print(f"ERROR: {str(e)}")
        sys.exit(1)


if __name__ == "__main__":
    main()
