<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="org.json.JSONObject" %>
<%@ page import="java.io.*" %>
<%
    String latitude = request.getParameter("latitude");
    String longitude = request.getParameter("longitude");

    JSONObject jsonResponse = new JSONObject();
    if (latitude == null || longitude == null) {
        System.out.printf("LandCheck(): Did not get input latitude/longitude in required format.\n");
        jsonResponse.put("error", "Error in received input latitude/longitude");
        response.setContentType("application/json");
        response.getWriter().write(jsonResponse.toString());
    } else {
        // latitude/longitude is not null
        final String saratRootDir = "/home/osf/SearchAndRescueTool";
        final String ferretCmd = "/usr/local/ferret/bin/ferret";
        final String ferretLandCheckScript = saratRootDir + "/landoceancheck.jnl";

        // Command to run the Ferret script
        String command = ferretCmd + " -script " + ferretLandCheckScript + " " + longitude + " " + latitude;
        System.out.printf("Running land/ocean check using command '%s'\n", command);

        try {
            // Execute the Ferret script
            Process process = Runtime.getRuntime().exec(command);
            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            StringBuilder output = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                output.append(line);
            }
            reader.close();

            // Check the output of the Ferret script for validation
            double outputDouble = Double.parseDouble(output.toString());
            if (outputDouble < 0) {
                // Ocean
                jsonResponse.put("isOcean", true);
            } else {
                jsonResponse.put("isOcean", false);
            }
        } catch (IOException e) {
            //jsonResponse.put("isOcean", false);
            jsonResponse.put("error", "Error executing landoceancheck: " + e.getMessage());
        }
        response.setContentType("application/json");
        response.getWriter().write(jsonResponse.toString());
    }
%>