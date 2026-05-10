/**
 * MultiReleaseModeProcessor.java
 * Handles parsing and processing of three particle seeding modes in Store servlet
 * Frontend submission → Backend mode-specific processing pipeline
 * 
 * Integration: Modify Store servlet to call this processor with request parameters
 */

import java.io.*;
import java.util.*;
import java.text.SimpleDateFormat;
import java.util.Date;
import org.json.JSONObject;
import org.json.JSONArray;

public class MultiReleaseModeProcessor {
    
    private String releaseMode;
    private String uniqueId;
    private String outputDirectory;
    private String processScriptPath; // Path to InfilePreparationV2.sh
    
    public MultiReleaseModeProcessor(String releaseMode, String uniqueId, String outputDir) {
        this.releaseMode = releaseMode;
        this.uniqueId = uniqueId;
        this.outputDirectory = outputDir;
        this.processScriptPath = "/path/to/BackendScripts/InfilePreparationV2.sh";
    }
    
    /**
     * Parse form submission parameters based on release mode
     * Called by Store servlet after form validation
     */
    public static Map<String, Object> parseReleaseParameters(
            String releaseMode,
            Map<String, String[]> parameterMap) throws Exception {
        
        Map<String, Object> result = new HashMap<>();
        result.put("release_mode", releaseMode);
        result.put("unique_id", parameterMap.get("uniq_id")[0]);
        result.put("simulation_end", parameterMap.get("lkt")[0]); // From frontend's lkt (simulation end)
        
        if ("single".equals(releaseMode)) {
            result.putAll(parseSingleReleaseParams(parameterMap));
        } else if ("multi_location".equals(releaseMode)) {
            result.putAll(parseMultiLocationParams(parameterMap));
        } else if ("continuous_source".equals(releaseMode)) {
            result.putAll(parseContinuousSourceParams(parameterMap));
        } else {
            throw new IllegalArgumentException("Unknown release mode: " + releaseMode);
        }
        
        return result;
    }
    
    /**
     * CASE 1: Single Release Mode
     * Standard existing functionality - single location, single time
     * Parameters: latitude, longitude, lkt
     */
    private static Map<String, Object> parseSingleReleaseParams(Map<String, String[]> params) {
        Map<String, Object> result = new HashMap<>();
        
        double latitude = Double.parseDouble(params.get("latitude")[0]);
        double longitude = Double.parseDouble(params.get("longitude")[0]);
        String lkt = params.get("lkt")[0]; // Release time
        
        // Validate coordinates
        if (latitude < -90 || latitude > 90) {
            throw new IllegalArgumentException("Latitude out of range: " + latitude);
        }
        if (longitude < -180 || longitude > 180) {
            throw new IllegalArgumentException("Longitude out of range: " + longitude);
        }
        
        result.put("mode", "single");
        result.put("latitude", latitude);
        result.put("longitude", longitude);
        result.put("lkt", lkt);
        result.put("seeding_duration_hours", 
                   params.containsKey("seeding_duration") ? 
                   Integer.parseInt(params.get("seeding_duration")[0]) : 12);
        
        return result;
    }
    
    /**
     * CASE 2: Multiple Location Release
     * Multiple locations released at same time
     * Frontend sends: location_1_latitude, location_1_longitude, location_2_latitude, etc.
     * And: multi_lkt (release time for all locations)
     */
    private static Map<String, Object> parseMultiLocationParams(Map<String, String[]> params) {
        Map<String, Object> result = new HashMap<>();
        List<Map<String, Object>> locations = new ArrayList<>();
        
        String multi_lkt = params.get("multi_lkt")[0];
        
        // Parse all location_N_latitude and location_N_longitude pairs
        int locationCount = 0;
        for (String paramName : params.keySet()) {
            if (paramName.startsWith("location_") && paramName.endsWith("_latitude")) {
                String indexStr = paramName.replaceFirst("location_", "").replaceFirst("_latitude", "");
                try {
                    int index = Integer.parseInt(indexStr);
                    
                    double latitude = Double.parseDouble(params.get(paramName)[0]);
                    double longitude = Double.parseDouble(
                            params.get("location_" + index + "_longitude")[0]);
                    
                    // Validate
                    if (latitude < -90 || latitude > 90) {
                        throw new IllegalArgumentException(
                                "Location " + index + " latitude out of range: " + latitude);
                    }
                    if (longitude < -180 || longitude > 180) {
                        throw new IllegalArgumentException(
                                "Location " + index + " longitude out of range: " + longitude);
                    }
                    
                    Map<String, Object> location = new HashMap<>();
                    location.put("index", index);
                    location.put("latitude", latitude);
                    location.put("longitude", longitude);
                    location.put("release_time", multi_lkt);
                    
                    locations.add(location);
                    locationCount++;
                    
                } catch (NumberFormatException e) {
                    // Skip invalid indices
                }
            }
        }
        
        if (locations.size() < 2) {
            throw new IllegalArgumentException(
                    "Multi-location mode requires at least 2 locations, got: " + locations.size());
        }
        
        result.put("mode", "multi_location");
        result.put("locations", locations);
        result.put("multi_lkt", multi_lkt);
        result.put("location_count", locationCount);
        result.put("seeding_duration_hours",
                   params.containsKey("seeding_duration") ?
                   Integer.parseInt(params.get("seeding_duration")[0]) : 12);
        
        return result;
    }
    
    /**
     * CASE 3: Continuous Moving Source
     * Object moves from start_position to end_position over time range
     * Frontend sends: start_lat, start_lon, end_lat, end_lon, start_time, end_time
     */
    private static Map<String, Object> parseContinuousSourceParams(Map<String, String[]> params) {
        Map<String, Object> result = new HashMap<>();
        
        double start_lat = Double.parseDouble(params.get("start_lat")[0]);
        double start_lon = Double.parseDouble(params.get("start_lon")[0]);
        double end_lat = Double.parseDouble(params.get("end_lat")[0]);
        double end_lon = Double.parseDouble(params.get("end_lon")[0]);
        String start_time = params.get("start_time")[0];
        String end_time = params.get("end_time")[0];
        
        // Validate coordinates
        if (start_lat < -90 || start_lat > 90) {
            throw new IllegalArgumentException("Start latitude out of range: " + start_lat);
        }
        if (start_lon < -180 || start_lon > 180) {
            throw new IllegalArgumentException("Start longitude out of range: " + start_lon);
        }
        if (end_lat < -90 || end_lat > 90) {
            throw new IllegalArgumentException("End latitude out of range: " + end_lat);
        }
        if (end_lon < -180 || end_lon > 180) {
            throw new IllegalArgumentException("End longitude out of range: " + end_lon);
        }
        
        result.put("mode", "continuous_source");
        result.put("start_lat", start_lat);
        result.put("start_lon", start_lon);
        result.put("end_lat", end_lat);
        result.put("end_lon", end_lon);
        result.put("start_time", start_time);
        result.put("end_time", end_time);
        result.put("interpolation_interval_minutes",
                   params.containsKey("interpolation_interval") ?
                   Integer.parseInt(params.get("interpolation_interval")[0]) : 30);
        
        return result;
    }
    
    /**
     * Convert parsed parameters to JSON configuration for MultiReleaseHandler.py
     */
    public String generateReleaseConfigJson(Map<String, Object> releaseParams) throws Exception {
        JSONObject config = new JSONObject();
        
        config.put("unique_id", releaseParams.get("unique_id"));
        config.put("mode", releaseParams.get("release_mode"));
        config.put("simulation_end", releaseParams.get("simulation_end"));
        config.put("timestamp", new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss")
                .format(new Date()));
        
        String mode = (String) releaseParams.get("mode");
        
        if ("single".equals(mode)) {
            config.put("latitude", releaseParams.get("latitude"));
            config.put("longitude", releaseParams.get("longitude"));
            config.put("lkt", releaseParams.get("lkt"));
            config.put("seeding_duration_hours", releaseParams.get("seeding_duration_hours"));
            
        } else if ("multi_location".equals(mode)) {
            JSONArray locArray = new JSONArray();
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> locations = 
                    (List<Map<String, Object>>) releaseParams.get("locations");
            
            for (Map<String, Object> loc : locations) {
                JSONObject locJson = new JSONObject();
                locJson.put("index", loc.get("index"));
                locJson.put("latitude", loc.get("latitude"));
                locJson.put("longitude", loc.get("longitude"));
                locJson.put("release_time", loc.get("release_time"));
                locArray.put(locJson);
            }
            
            config.put("locations", locArray);
            config.put("multi_lkt", releaseParams.get("multi_lkt"));
            config.put("location_count", releaseParams.get("location_count"));
            config.put("seeding_duration_hours", releaseParams.get("seeding_duration_hours"));
            
        } else if ("continuous_source".equals(mode)) {
            config.put("start_lat", releaseParams.get("start_lat"));
            config.put("start_lon", releaseParams.get("start_lon"));
            config.put("end_lat", releaseParams.get("end_lat"));
            config.put("end_lon", releaseParams.get("end_lon"));
            config.put("start_time", releaseParams.get("start_time"));
            config.put("end_time", releaseParams.get("end_time"));
            config.put("interpolation_interval_minutes", 
                       releaseParams.get("interpolation_interval_minutes"));
        }
        
        return config.toString(4); // Pretty print with 4-space indent
    }
    
    /**
     * Write configuration JSON to file
     */
    public String writeConfigFile(String configJson) throws IOException {
        String filename = "release_config_" + uniqueId + ".json";
        String filepath = outputDirectory + "/" + filename;
        
        FileWriter fw = new FileWriter(filepath);
        fw.write(configJson);
        fw.close();
        
        return filepath;
    }
    
    /**
     * Execute MultiReleaseHandler.py to generate lwseed configuration
     */
    public ProcessResult executeMultiReleaseHandler(String configFilePath) throws Exception {
        String pythonScript = new File(
                getClass().getResource("/").toURI()
        ).getParent() + "/MultiReleaseHandler.py";
        
        ProcessBuilder pb = new ProcessBuilder(
                "python3",
                pythonScript,
                releaseMode,
                configFilePath,
                outputDirectory
        );
        
        pb.redirectErrorStream(true);
        Process process = pb.start();
        
        StringBuilder output = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(process.getInputStream()))) {
            String line;
            while ((line = reader.readLine()) != null) {
                output.append(line).append("\n");
            }
        }
        
        int exitCode = process.waitFor();
        
        return new ProcessResult(exitCode, output.toString());
    }
    
    /**
     * Main entry point from Store servlet
     * Chain: Form submission → parseReleaseParameters → generateReleaseConfigJson 
     *        → writeConfigFile → executeMultiReleaseHandler
     */
    public ProcessResult processModeSubmission(Map<String, String[]> formParameters) throws Exception {
        // Parse release-mode-specific parameters
        Map<String, Object> releaseParams = parseReleaseParameters(releaseMode, formParameters);
        
        // Generate JSON config
        String configJson = generateReleaseConfigJson(releaseParams);
        
        // Write config file
        String configPath = writeConfigFile(configJson);
        
        // Execute Python handler
        return executeMultiReleaseHandler(configPath);
    }
    
    /**
     * Result wrapper for process execution
     */
    public static class ProcessResult {
        public int exitCode;
        public String output;
        
        public ProcessResult(int exitCode, String output) {
            this.exitCode = exitCode;
            this.output = output;
        }
        
        public boolean isSuccess() {
            return exitCode == 0;
        }
        
        public String getMessage() {
            return output;
        }
    }
}
