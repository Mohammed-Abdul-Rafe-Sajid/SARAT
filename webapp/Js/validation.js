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
        alert("Search_Time should not be Empty");
        return false;                         
    }
    
    if (fd>td) {
        alert("Search_Time should be after Last_Known_Time only");
        return false;
    }
    
    // Calculate the difference in milliseconds
    const differenceInMilliseconds = Math.abs(td - fd);
           
    // Convert milliseconds to minutes
    const differenceInMinutes = differenceInMilliseconds / (1000 * 60);
            
    // Check if the difference is at least 15 minutes
    if (differenceInMinutes < 15) {
        alert("Search_Time should be atleast 15 minutes from the Last_Known_Time");
        return false;
    }

    verifyLatitudeLongitude().then((isValid) => {
        if (isValid) {
            // Submit form
            // document.forms["input_form"].submit();

            // The above call is not working because there is a button with name submit
            // that is overriding the submit function; so we use the prototype call
            HTMLFormElement.prototype.submit.call(document.forms["input_form"]);
        }
    }).catch((error) => {
        console.log(error);
        alert("Error while validating the input latitude/longitude combination.");
    });

    // Always return false to not submit the form;
    return false;
}