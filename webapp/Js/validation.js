/* 
* Script to validate main Page
*/
var errMessage;

function parseDate(input) {
    var parts = input.split(/-|:| /);
    return new Date(parts[0], parts[1] - 1, parts[2], parts[3], parts[4], parts[5]);
}

async function verifyLandOcean(latitude, longitude) {
    // const formData = new FormData();
    // formData.append('latitude', latitude);
    // formData.append('longitude', longitude);
    const params = new URLSearchParams();
    params.append('latitude', latitude);
    params.append('longitude', longitude);

    try {
        const response = await fetch('LandCheck.jsp', {
            method: 'POST',
            // body: formData
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: params
        });

        if (! response.ok) {
            throw new Error(`HTTP error in validating Land/Ocean! status: ${response.status}`);
        }

        const result = await response.json();
        
        if (result.error) {
            alert("Land/Ocean Validation failed: " + result.error);
            // document.getElementById("form1").submit(); // Submit the form if valid
            return false;
        }

        if (! result.isOcean) {
            alert("INPUT_ERROR: Latitude '" + latitude + "', Longitude: '" + longitude + "' is on land. Please select a point in the ocean.");            
        }
        return result.isOcean;
    } catch (error) {
        console.error('Error:', error);
        alert("An error occurred during land/ocean validation.");
        return false;
    }
}

async function verifyLatitudeLongitude() {
    const inputLatitudeElement = document.getElementById("latitude");
    if (! inputLatitudeElement) {
        alert("ERROR: Could not get input latitude element.");
        return false;
    }
    const inputLatitudeVal = inputLatitudeElement.value;

    const latitudeMin = -26;
    const latitudeMax = 24;
    if (inputLatitudeVal < latitudeMin || inputLatitudeVal > latitudeMax) {
        alert("INPUT_ERROR: Please enter latitude between " + latitudeMin.toString() + " and " + latitudeMax.toString());
        return false;
    }

    const inputLongitudeElement = document.getElementById("longitude");
    if (! inputLongitudeElement) {
        alert("ERROR: Could not get input longitude element.");
        return false;
    }
    const inputLongitudeVal = inputLongitudeElement.value;

    const longitudeMin = 45;
    const longitudeMax = 108;
    if (inputLongitudeVal < longitudeMin || inputLongitudeVal > longitudeMax) {
        alert("INPUT_ERROR: Please enter longitude between " + longitudeMin.toString() + " and " + longitudeMax.toString());
        return false;
    }
    return await verifyLandOcean(inputLatitudeVal, inputLongitudeVal);
}

function checkForm() {
    // Get release mode
    var releaseMode = document.querySelector('input[name="release_mode"]:checked').value;
    
    // Verify last known time/date
    var sFrom_date= document.forms["input_form"]["From_date"].value;
    var sTo_date=document.forms["input_form"]["To_date"].value;
    var fd=parseDate(sFrom_date);
    var td=parseDate(sTo_date);
    if (sFrom_date === null || sFrom_date === "" ) {   
        alert("Last_Known_Time should not empty");
        return false;                           
    }
    
    if (sTo_date===null||sTo_date==="") {  
        alert("Simulation Time should not be Empty");
        return false;                         
    }
    
    if (fd>td) {
        alert("Simulation Time should be after Last_Known_Time only");
        return false;
    }
    
    // Calculate the difference in milliseconds
    const differenceInMilliseconds = Math.abs(td - fd);
           
    // Convert milliseconds to minutes
    const differenceInMinutes = differenceInMilliseconds / (1000 * 60);
            
    // Check if the difference is at least 15 minutes
    if (differenceInMinutes < 15) {
        alert("Simulation Time should be atleast 15 minutes from the Last_Known_Time");
        return false;
    }

    // MODE-SPECIFIC VALIDATION
    if (releaseMode === 'single') {
        // SINGLE RELEASE MODE
        var selectedFormat = document.querySelector('input[name="latlong"]:checked').value;
        var latitude = document.forms["input_form"]["latitude"].value;
        var longitude = document.forms["input_form"]["longitude"].value;
        
        if (!latitude || !longitude) {
            if (selectedFormat === 'dms') {
                alert("Please fill all DMS fields and click 'Calculate DD' button");
            } else if (selectedFormat === 'ddm') {
                alert("Please fill all DDM fields and click 'Calculate DD' button");
            } else {
                alert("Please enter Latitude and Longitude");
            }
            return false;
        }

        verifyLatitudeLongitude().then((isValid) => {
            if (isValid) {
                HTMLFormElement.prototype.submit.call(document.forms["input_form"]);
            }
        }).catch((error) => {
            console.log(error);
            alert("Error while validating the input latitude/longitude combination.");
        });

    } else if (releaseMode === 'multi_location') {
        // MULTIPLE LOCATION RELEASE MODE
        var multi_lkt = document.getElementById("multi_lkt").value;
        if (!multi_lkt || multi_lkt === "") {
            alert("Please select Release Time (LKT) for Multiple Location Release");
            return false;
        }

        // Validate that at least 2 locations are provided
        var locations = document.querySelectorAll('.location-set');
        var validLocations = 0;
        
        locations.forEach(function(locDiv) {
            var latInput = locDiv.querySelector('.location-latitude');
            var lonInput = locDiv.querySelector('.location-longitude');
            if (latInput.value && lonInput.value) {
                validLocations++;
            }
        });

        if (validLocations < 2) {
            alert("Please provide at least 2 locations for Multiple Location Release");
            return false;
        }

        // Validate all provided locations
        var allValid = true;
        locations.forEach(function(locDiv) {
            var latInput = locDiv.querySelector('.location-latitude');
            var lonInput = locDiv.querySelector('.location-longitude');
            
            if ((latInput.value && !lonInput.value) || (!latInput.value && lonInput.value)) {
                alert("Please provide both latitude and longitude for all locations");
                allValid = false;
                return;
            }
        });

        if (allValid) {
            HTMLFormElement.prototype.submit.call(document.forms["input_form"]);
        }

    } else if (releaseMode === 'continuous_source') {
        // CONTINUOUS MOVING SOURCE MODE
        var cont_start_lat = document.getElementById("cont_start_lat").value;
        var cont_start_lon = document.getElementById("cont_start_lon").value;
        var cont_end_lat = document.getElementById("cont_end_lat").value;
        var cont_end_lon = document.getElementById("cont_end_lon").value;
        var cont_start_time = document.getElementById("cont_start_time").value;
        var cont_end_time = document.getElementById("cont_end_time").value;

        if (!cont_start_lat || !cont_start_lon) {
            alert("Please provide Start Position (Latitude and Longitude)");
            return false;
        }

        if (!cont_end_lat || !cont_end_lon) {
            alert("Please provide End Position (Latitude and Longitude)");
            return false;
        }

        if (!cont_start_time || cont_start_time === "") {
            alert("Please select Start Time for Continuous Moving Source");
            return false;
        }

        if (!cont_end_time || cont_end_time === "") {
            alert("Please select End Time for Continuous Moving Source");
            return false;
        }

        // Parse and validate times
        var startTime = parseDate(cont_start_time);
        var endTime = parseDate(cont_end_time);
        
        if (startTime >= endTime) {
            alert("End Time must be after Start Time");
            return false;
        }

        HTMLFormElement.prototype.submit.call(document.forms["input_form"]);
    }

    // Always return false to not submit the form;
    return false;
}