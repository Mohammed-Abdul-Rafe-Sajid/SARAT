import java.io.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;
import org.json.JSONObject;

/**
 * Store.java - Main servlet for SARAT form submission handling
 * Processes single release, multi-location, and continuous moving source modes
 * Version: 3.0 (Multi-Release Support)
 */
public class Store extends HttpServlet {
    
    private static final long serialVersionUID = 1L;
    private static final String LOG_PREFIX = "[SARAT-Store] ";
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            // Log request
            System.out.println(LOG_PREFIX + "Form submission received");
            
            // Get unique ID (required parameter)
            String uniq_id = request.getParameter("uniq_id");
            if (uniq_id == null || uniq_id.isEmpty()) {
                uniq_id = System.currentTimeMillis() + "_" + (int)(Math.random() * 1000);
            }
            System.out.println(LOG_PREFIX + "Unique ID: " + uniq_id);
            
            // Get release mode (default to 'single' for backward compatibility)
            String releaseMode = request.getParameter("release_mode");
            if (releaseMode == null || releaseMode.isEmpty()) {
                releaseMode = "single";
            }
            System.out.println(LOG_PREFIX + "Release Mode: " + releaseMode);
            
            // Validate release mode
            List<String> validModes = Arrays.asList("single", "multi_location", "continuous_source");
            if (!validModes.contains(releaseMode)) {
                sendErrorResponse(response, out, 
                    "ERROR: Invalid release mode '" + releaseMode + "'. Must be: single, multi_location, or continuous_source");
                return;
            }
            
            // Get output directory
            ServletContext context = getServletContext();
            String outputDir = context.getRealPath("/data");
            File dataDirFile = new File(outputDir);
            if (!dataDirFile.exists()) {
                dataDirFile.mkdirs();
            }
            
            String caseOutputDir = outputDir + "/" + uniq_id;
            new File(caseOutputDir).mkdirs();
            
            // Create MultiReleaseModeProcessor
            MultiReleaseModeProcessor processor = new MultiReleaseModeProcessor(
                releaseMode, 
                uniq_id, 
                caseOutputDir
            );
            
            try {
                // Parse and validate mode-specific parameters
                System.out.println(LOG_PREFIX + "Parsing " + releaseMode + " mode parameters");
                Map<String, Object> releaseParams = MultiReleaseModeProcessor
                        .parseReleaseParameters(releaseMode, request.getParameterMap());
                
                System.out.println(LOG_PREFIX + "Parameters parsed successfully");
                
                // Generate configuration JSON
                String configJson = processor.generateReleaseConfigJson(releaseParams);
                System.out.println(LOG_PREFIX + "Configuration generated");
                
                // Write configuration to file
                String configFilePath = processor.writeConfigFile(configJson);
                System.out.println(LOG_PREFIX + "Config file written: " + configFilePath);
                
                // Store in session for later use
                request.getSession().setAttribute("release_config", configJson);
                request.getSession().setAttribute("uniq_id", uniq_id);
                request.getSession().setAttribute("release_mode", releaseMode);
                
                // Execute lwseed generation
                System.out.println(LOG_PREFIX + "Executing MultiReleaseHandler.py");
                MultiReleaseModeProcessor.ProcessResult handlerResult = 
                        processor.executeMultiReleaseHandler(configFilePath);
                
                if (!handlerResult.isSuccess()) {
                    sendErrorResponse(response, out, 
                        "ERROR: Failed to generate lwseed configuration:\n" + handlerResult.getMessage());
                    return;
                }
                
                System.out.println(LOG_PREFIX + "lwseed generation successful");
                System.out.println(LOG_PREFIX + "Output:\n" + handlerResult.getMessage());
                
            } catch (IllegalArgumentException e) {
                // User input validation error
                System.err.println(LOG_PREFIX + "Validation error: " + e.getMessage());
                sendErrorResponse(response, out, "VALIDATION ERROR: " + e.getMessage());
                return;
            } catch (Exception e) {
                // System error
                System.err.println(LOG_PREFIX + "System exception: " + e.getMessage());
                e.printStackTrace();
                sendErrorResponse(response, out, 
                    "ERROR: Exception during multi-release processing: " + e.getMessage());
                return;
            }
            
            // Execute backend simulation processing script
            System.out.println(LOG_PREFIX + "Starting backend processing");
            try {
                executeBackendScript(uniq_id, releaseMode, caseOutputDir);
            } catch (Exception e) {
                System.err.println(LOG_PREFIX + "Backend script error: " + e.getMessage());
                e.printStackTrace();
                sendErrorResponse(response, out, 
                    "ERROR: Backend processing failed: " + e.getMessage());
                return;
            }
            
            // Success - redirect to output page
            System.out.println(LOG_PREFIX + "Redirecting to output page");
            request.setAttribute("message", "SUCCESS: Simulation submitted for " + releaseMode + " mode");
            request.setAttribute("uniq_id", uniq_id);
            request.setAttribute("release_mode", releaseMode);
            
            request.getRequestDispatcher("/output.jsp").forward(request, response);
            
        } catch (Exception e) {
            System.err.println(LOG_PREFIX + "Unexpected error in doPost: " + e.getMessage());
            e.printStackTrace();
            try {
                sendErrorResponse(response, out, 
                    "ERROR: Unexpected system error: " + e.getMessage());
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        } finally {
            out.close();
        }
    }
    
    /**
     * Execute backend simulation processing script
     */
    private void executeBackendScript(String uniqueId, String releaseMode, String outputDir) 
            throws Exception {
        
        String scriptPath = getServletContext().getRealPath("/") 
                + "/../BackendScripts/InfilePreparationV2.sh";
        
        System.out.println(LOG_PREFIX + "Backend script: " + scriptPath);
        System.out.println(LOG_PREFIX + "Unique ID: " + uniqueId);
        System.out.println(LOG_PREFIX + "Release Mode: " + releaseMode);
        
        ProcessBuilder pb = new ProcessBuilder(
            "bash",
            scriptPath,
            uniqueId,
            releaseMode
        );
        
        pb.directory(new File(outputDir));
        pb.redirectErrorStream(true);
        
        Process process = pb.start();
        
        // Capture output
        StringBuilder output = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(process.getInputStream()))) {
            String line;
            while ((line = reader.readLine()) != null) {
                output.append(line).append("\n");
                System.out.println(LOG_PREFIX + "Backend: " + line);
            }
        }
        
        int exitCode = process.waitFor();
        System.out.println(LOG_PREFIX + "Backend script exit code: " + exitCode);
        
        if (exitCode != 0) {
            throw new Exception("Backend script failed with exit code " + exitCode 
                    + ":\n" + output.toString());
        }
    }
    
    /**
     * Send error response
     */
    private void sendErrorResponse(HttpServletResponse response, PrintWriter out, String message) 
            throws IOException {
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        out.println("<html>");
        out.println("<head><title>SARAT - Error</title></head>");
        out.println("<body>");
        out.println("<div style='color: red; font-family: monospace; padding: 20px;'>");
        out.println("<h2>Error Processing Request</h2>");
        out.println("<pre>" + message.replace("<", "&lt;").replace(">", "&gt;") + "</pre>");
        out.println("<a href='Main.jsp'>Back to Form</a>");
        out.println("</div>");
        out.println("</body>");
        out.println("</html>");
    }
    
    @Override
    public String getServletInfo() {
        return "SARAT Multi-Release Seeding Servlet (v3.0)";
    }
}
