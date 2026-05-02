<%@page contentType="text/html" pageEncoding="UTF-8"%>

<html>
    <head>
        <meta charset="UTF-8">
        <title>ESSO-SARAT Output</title>
        <link rel="stylesheet" href="Css/Menustyles.css">        
        <link rel="stylesheet" href="Css/style.css" type="text/css">
        <link rel="stylesheet" type="text/css" href="Js/vendors/leaflet-plugins/Leaflet.Coordinates-0.1.3.css">
        <link rel="stylesheet" href="Js/vendors/leaflet-plugins/Control.FullScreen.css" />
        <link rel="stylesheet" type="text/css" href="Css/TimeDimention_style.css">
        <script type="text/javascript" src="Js/vendors/jquery-2.0.0.min.js"></script>
        <script type='text/javascript' src="Js/vendors/leaflet-0.7.3/leaflet.js"></script>
        <script type="text/javascript" src="Js/vendors/leaflet-plugins/Control.FullScreen.js"></script>
        <link rel="stylesheet" type="text/css" href="Js/vendors/leaflet-0.7.3/leaflet.css">
        <script type='text/javascript' src="Js/vendors/leaflet-plugins/Leaflet.Coordinates-0.1.3.min.js"></script>
        <!-- <script src="https://unpkg.com/tokml/tokml.js"></script> -->
        <script src="Js/tokml.js"></script>
        <script src="Js/script.js"></script>
        <style type="text/css">
            .inputX{
                font-size: 30px;
            }
        </style>
        <script type='text/javascript'>//<![CDATA[
            var marker = null, map = null;
            const uniqueId = '<%= request.getParameter("request_id")%>';
            let textContent = ""; // This is used by mousemove and mouseover

            let legend = []; // This is used in loading probability regions

            function getPopUpForLKPMarker(feature, layer) {
                const popupContent = feature.properties.name;
                layer.bindPopup(popupContent);

                layer.on('mouseover', function (e) {
                    textContent = popupContent + '@';
                });
                layer.on('mouseout', function (e) {
                    textContent = "";
                });
            }

            // Mean trajectory
            function getPopupForMeanTrajectoryLayer(feature, layer) {
                    //console.log(feature);
                    const popupContent = feature.properties.name;
                    layer.bindPopup(popupContent);
                    //layer.openPopup();

                    layer.on('mouseover', function (e) {
                        textContent = popupContent + '@';
                    });
                    layer.on('mouseout', function (e) {
                        textContent = "";
                    });
            }

            function getStyleForMeanTrajectoryLayer(feature) {
                const featureProperties = feature.properties;
                if (featureProperties.hasOwnProperty("name") &&
                    featureProperties["name"] === 'MeanTrajectory') {
                    return {
                        "color": "#AF005F",
                        "weight": 5,
                        "opacity": "1"
                        //"fillColor": "black",
                        //"fillOpacity": 0.9
                    };
                }
            }

            // Complete trajectory
            function getPopupForAllTrajectoriesLayer(feature, layer) {
                const popupContent = feature.properties.name;
                layer.bindPopup(popupContent);
                //layer.openPopup();

                layer.on('mouseover', function (e) {
                    textContent = popupContent + '@';
                });
                layer.on('mouseout', function (e) {
                    textContent = "";
                });
            }

            function getStyleForAllTrajectoriesLayer(feature) {
                return {
                    // "color": "#FD6A02",
                    "color": "#A9A9A9",
                    "weight": 3,
                    "opacity": "0.9"
                };
            }

            function getPopupContentForProbabilityRegion(feature) {
                let popupContent = "";
                if (feature.properties && feature.properties.confidence) {
                    if (feature.properties.confidence == '0.05') {
                        popupContent += "5% probability";
                    } else if (feature.properties.confidence == '0.1') {
                        popupContent += "10% probability"; 
                    } else if (feature.properties.confidence == '0.15') {
                        popupContent += "15% probability"; 
                    } else if (feature.properties.confidence == '0.2') {
                        popupContent += "20% probability"; 
                    } else if (feature.properties.confidence == '0.25') {
                        popupContent += "25% probability"; 
                    } else if (feature.properties.confidence == '0.3') {
                        popupContent += "30% probability"; 
                    } else if (feature.properties.confidence == '0.35') {
                        popupContent += "35% probability"; 
                    } else if (feature.properties.confidence == '0.4') {
                        popupContent += "40% probability"; 
                    } else if (feature.properties.confidence == '0.45') {
                        popupContent += "45% probability"; 
                    } else if (feature.properties.confidence == '0.5') {
                        popupContent += "50% probability";
                    } else if (feature.properties.confidence == '0.55') {
                        popupContent += "55% probability";
                    }
                    else if (feature.properties.confidence == '0.6') {
                        popupContent += "60% probability"; 
                    }
                    else if (feature.properties.confidence == '0.6') {
                        popupContent += "65% probability"; 
                    }
                    else if (feature.properties.confidence == '0.7') {
                        popupContent += "70% probability"; 
                    } 
                    else if (feature.properties.confidence == '0.75') {
                        popupContent += "75% probability"; 
                    }
                    else if (feature.properties.confidence == '0.8') {
                        popupContent += "80% probability"; 
                    }
                    else if (feature.properties.confidence == '0.85') {
                        popupContent += "85% probability"; 
                    }
                    else if (feature.properties.confidence == '0.9') {
                        popupContent += "90% probability"; 
                    }
                    else if (feature.properties.confidence == '0.95') {
                        popupContent += "95% probability"; 
                    }
                    else if (feature.properties.confidence >= '0.95') {
                        popupContent += "100% probability";
                    }
                }
                return popupContent;
            }

            function getPopUpForProbabilityRegion(feature, layer) {
                //console.log('getPopup');
                // var popupContent = "";
                // if (feature.properties && feature.properties.confidence) {
                //     if (feature.properties.confidence == '0.05') {
                //         popupContent += "5% probability";
                //     } else if (feature.properties.confidence == '0.1') {
                //         popupContent += "10% probability"; 
                //     } else if (feature.properties.confidence == '0.15') {
                //         popupContent += "15% probability"; 
                //     } else if (feature.properties.confidence == '0.2') {
                //         popupContent += "20% probability"; 
                //     } else if (feature.properties.confidence == '0.25') {
                //         popupContent += "25% probability"; 
                //     } else if (feature.properties.confidence == '0.3') {
                //         popupContent += "30% probability"; 
                //     } else if (feature.properties.confidence == '0.35') {
                //         popupContent += "35% probability"; 
                //     } else if (feature.properties.confidence == '0.4') {
                //         popupContent += "40% probability"; 
                //     } else if (feature.properties.confidence == '0.45') {
                //         popupContent += "45% probability"; 
                //     } else if (feature.properties.confidence == '0.5') {
                //         popupContent += "50% probability";
                //     } else if (feature.properties.confidence == '0.55') {
                //         popupContent += "55% probability";
                //     }
                //     else if (feature.properties.confidence == '0.6') {
                //         popupContent += "60% probability"; 
                //     }
                //     else if (feature.properties.confidence == '0.6') {
                //         popupContent += "65% probability"; 
                //     }
                //     else if (feature.properties.confidence == '0.7') {
                //         popupContent += "70% probability"; 
                //     } 
                //     else if (feature.properties.confidence == '0.75') {
                //         popupContent += "75% probability"; 
                //     }
                //     else if (feature.properties.confidence == '0.8') {
                //         popupContent += "80% probability"; 
                //     }
                //     else if (feature.properties.confidence == '0.85') {
                //         popupContent += "85% probability"; 
                //     }
                //     else if (feature.properties.confidence == '0.9') {
                //         popupContent += "90% probability"; 
                //     }
                //     else if (feature.properties.confidence == '0.95') {
                //         popupContent += "95% probability"; 
                //     }
                //     else if (feature.properties.confidence >= '0.95') {
                //         popupContent += "100% probability";
                //     }    
                // }
                const popupContent = getPopupContentForProbabilityRegion(feature);
                layer.bindPopup(popupContent);
                layer.on('mouseover', function (e) {
                    textContent = popupContent + '@';
                });
                layer.on('mouseout', function (e) {
                    textContent = "";
                });
                //layer.bindPopup(popupContent);
            }

            function getStyleForProbabilityRegion(feature) {
                // legend.push(feature.properties.confidence);          
                let color = "#FFF";
                if (feature.properties.confidence == '0.05') {
                    color = "rgb(255, 254, 215)";
                }
                else if (feature.properties.confidence == '0.1') {
                    color = "rgb(254, 228, 148)";
                } 
                else if (feature.properties.confidence == '0.15') {
                    color = "rgb(254, 194, 77)";
                } 
                else if (feature.properties.confidence == '0.2') {
                    color = "rgb(248, 135, 31)";
                } 
                else if (feature.properties.confidence == '0.25') {
                    color = "rgb(251, 181, 154)";
                } 
                else if (feature.properties.confidence == '0.3') {
                    color = "rgb(243, 68, 48)";
                }
                else if (feature.properties.confidence == '0.35') {
                    color = "rgb(208, 27, 30)";
                } 
                else if (feature.properties.confidence == '0.4') {
                    color = "rgb(158, 53, 3)";
                }
                else if (feature.properties.confidence == '0.45') {                    
                    color = "rgb(151, 215, 183)";
                } 
                else if (feature.properties.confidence == '0.5') {                    
                    color = "rgb(94, 189, 209)";
                }
                else if (feature.properties.confidence == '0.6') {
                    color = "rgb(46, 144, 192)";
                } 
                else if (feature.properties.confidence == '0.7') {
                    color = "rgb(2, 98, 168)";
                }
                else if (feature.properties.confidence == '0.8') {                    
                    color = "rgb(0, 0, 255)";
                } 
                else if (feature.properties.confidence == '0.9') {
                    color = "rgb(64, 64, 64)";
                }
                else if (feature.properties.confidence >= '0.9') {
                    color = "rgb(0, 0, 0)";
                }
                return {
                    "color": "black",
                    "weight": 1,
                    "fillColor": color,
                    "fillOpacity": 0.9
                };
            }

            async function loadDataToMap(map) {                
                //console.log("UniqueId: " + uniqueId);
                                
                // Last Known Position
                // Tried the below with backticks but seems there is an issue
                const lkpGeoJsonUrl = "data/lkp_" + uniqueId + ".geojson";
                //console.log(lkpGeoJsonUrl);
                let response = await fetch(lkpGeoJsonUrl);
                let lkpGeoJson = await response.json();


                // Display last known position marker
                const lkpMarkerOptions = {
                    radius: 8,
                    fillColor: "#ff7800",
                    color: "#000",
                    weight: 1,
                    opacity: 1,
                    fillOpacity: 0.8
                };
                const lkpMarkerLayer = L.geoJson(lkpGeoJson, {
                    onEachFeature: getPopUpForLKPMarker
                });
                lkpMarkerLayer.addTo(map);
                lkpMarkerLayer.openPopup();

                // const meanTrajectoryGeoJsonFile = `data/meantrajectory_${uniqueId}.geojson`;
                const meanTrajectoryGeoJsonFile = "data/meantrajectory_" + uniqueId + ".geojson";
                response = await fetch(meanTrajectoryGeoJsonFile);
                let meanTrajectoryGeoJson = await response.json();

                const meanTrajectoryLayer = L.geoJson(meanTrajectoryGeoJson, {
                    onEachFeature: getPopupForMeanTrajectoryLayer,
                    style: getStyleForMeanTrajectoryLayer
                });
                
                //const allTrajectoriesGeoJsonFile = `data/trajectories_${uniqueId}.geojson`;
                const allTrajectoriesGeoJsonFile = "data/trajectories_" + uniqueId + ".geojson";
                response = await fetch(allTrajectoriesGeoJsonFile);
                let allTrajectoriesGeoJson = await response.json();

                const allTrajectoriesLayer = L.geoJson(allTrajectoriesGeoJson, {
                    onEachFeature: getPopupForAllTrajectoriesLayer,
                    style: getStyleForAllTrajectoriesLayer
                });

                const overlayLayers = {
                    'Mean Trajectory': meanTrajectoryLayer,
                    'All Trajectories': allTrajectoriesLayer
                };

                const layerControl = L.control.layers({}, overlayLayers, { collapsed: false });
                layerControl.addTo(map);

                map.on("overlayadd", (layersControlEvent) => {
                    layersControlEvent.layer.openPopup();
                });

                // map.on("overlayremove", (layersControlEvent) => {
                //     layersControlEvent.layer.closePopup();
                // });
            }

            window.onload = function () {
                var popup = null;
                var southWest = L.latLng(-60, 30),
                    northEast = L.latLng(30, 120),
                    bounds = L.latLngBounds(southWest, northEast);
// create a map in the "map" div, set the view to a given place and zoom
               
                var map = L.map('map', {
                    fullscreenControl: true,
                    maxBounds: bounds,
                    center: [20, 77],
                    maxZoom: 12,
                    minZoom: 5,
                    zoom: 5
                });
                L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
                    maxZoom: 18,
                }).addTo(map);
                
                var icon = new L.Icon.Default();  
                L.control.coordinates({
                    position: "topright",
                    decimals: 3,
                    labelTemplateLat: "Latitude: {y}",
                    labelTemplateLng: "Longitude: {x}",
                    useDMS: false,
                    enableUserInput: false
                }).addTo(map);
                
                var cDriftLegend = L.control({
                    position: 'bottomright'
                });
                /*  Testing   */
                // var cDriftLegend1 = L.control({
                //     position: 'bottomright'
                // });
                // cDriftLegend1.onAdd = function (map) {
                //     var div = L.DomUtil.create('div', 'info legend');
                //     div.innerHTML += '<h3 style="font-size:16px;color:red;padding-top:-5px">Click on a specific region on the colored area to see the probability</h3>';
                //     return div;
                // };               
                var pdfdownload = L.control({
                    position: 'topleft'
                });
                pdfdownload.onAdd = function (map) {
                    var div = L.DomUtil.create('div', 'info legend');
                    div.innerHTML += '<h3 style="background-color:#ffffff;font-size:25px;font-style: bolder"><a style="font-color:red;" role="button" href="data/pdf/bulletein-<%=request.getParameter("request_id")%>.pdf" target="_blank">Click Here to Download</a></h3>';
                    return div;
                };
                pdfdownload.addTo(map);
                
                //cDriftLegend1.addTo(map);//adding help message

                loadDataToMap(map);

                                
                const probabilityRegionsGeoJsonFile = "data/" + uniqueId + ".json";
                const kmlDocumentName = "SARAT_" + uniqueId;
                //console.log(probabilityRegionsGeoJsonFile);

                fetch(probabilityRegionsGeoJsonFile)
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network error');
                    }
                    return response.json();
                }).then(data => {
                    //Do something with the data
                    //console.log(data);
                    try {
                        const cdriftLayer = L.geoJson(data, {
                            // style: getStyleForProbabilityRegion,
                            style: (feature) => {
                                legend.push(feature.properties.confidence);
                                return getStyleForProbabilityRegion(feature);
                            },
                            onEachFeature: getPopUpForProbabilityRegion,
                        });                        
                        cdriftLayer.addTo(map);
                        cDriftLegend.onAdd = function (map) {
                            legend.sort();
                            legend_prob =$.makeArray($(legend).filter(function(i,itm){ 
                            return i == $(legend).index(itm);
                            }));
                            //legend_prob = jQuery.unique(legend).sort();
                            var div = L.DomUtil.create('div', 'info legend');
                            html = '<ul>\n'
                            for (i = 0; i < legend_prob.length; i++) {
                                console.log(legend_prob[i]);
                                //html += '<li class=p0' + legend_prob[i] * 10 + '>' + legend_prob[i] * 100 + '% probability</li>';
                                html += '<li class=p' + legend_prob[i] * 100 + '>' + legend_prob[i] * 100 + '% probability</li>';
                            }
                            html += '</ul>';
                            div.innerHTML += html;
                            return div;
                        };
                        const bounds = cdriftLayer.getBounds();
                        map.fitBounds(bounds, {maxZoom: 9});
                        cDriftLegend.addTo(map);
                        
                        let kmldownload = L.control({
                            position: 'topleft'
                        });
                        kmldownload.onAdd = function (map) {
                            let div = L.DomUtil.create('div', 'info legend');
                            div.innerHTML += '<h3 style="background-color:#ffffff;font-size:25px;font-style: bolder"><a style="font-color:red;" role="button" id="kmldownloadlink" target="_blank">Download KML</a></h3>';
                            return div;
                        };
                        kmldownload.addTo(map);

                        document.getElementById('kmldownloadlink').onclick = function(event) {
                            alert("KML Download Link was clicked!");
                            // Prevent the default action (navigation)
                            event.preventDefault();

                            function rgbToHex(r, g, b) {
                                // Convert each RGB value to a hexadecimal string
                                const rHex = r.toString(16).padStart(2, '0');
                                const gHex = g.toString(16).padStart(2, '0');
                                const bHex = b.toString(16).padStart(2, '0');
                                return "#" + rHex + gHex + bHex;
                            }
                            
                            function isRgbString(value) {
                                // Check if the value is a string
                                if (typeof value === 'string' && value) {
                                    // Check if the string starts with "rgb("
                                    return value.startsWith('rgb(');
                                }
                                return false;
                            }

                            function isHexString(value) {
                                // Check if the value is a string
                                if (typeof value === 'string' && value) {
                                    // Check if the string starts with "rgb("
                                    return value.startsWith('#');
                                }
                                return false;
                            }

                            function embedStylesAndPopup(geojson, styleFunction, popupContentFunction) {
                                let featureIndex = 1;
                                geojson.features.forEach(function(feature) {
                                    const styleObj = styleFunction(feature);
                                    //                     "color": "black",

                                    const colorVal = styleObj.color;
                                    if (isRgbString(colorVal)) {
                                        const [r, g, b] = colorVal.match(/\d+/g).map(Number);
                                        feature.properties.stroke = rgbToHex(r, g, b);
                                    } else if (isHexString(colorVal)) {
                                        feature.properties.stroke = colorVal;
                                    }
                                    
                                    feature.properties["stroke-width"] = styleObj.weight;

                                    const fillColorVal = styleObj.fillColor;
                                    if (isRgbString(fillColorVal)) {
                                        const [r, g, b] = fillColorVal.match(/\d+/g).map(Number);
                                        feature.properties.fill = rgbToHex(r, g, b);
                                    } else if (isHexString(fillColorVal)) {
                                        feature.properties.fill = fillColorVal;
                                    }

                                    feature.properties["fill-opacity"] = styleObj.fillOpacity;

                                    // feature.properties.style = styleFunction(feature);
                                    feature.properties.popupContent = popupContentFunction(feature);
                                    feature.properties.name = "Probability_Region_" + featureIndex.toString();
                                    featureIndex += 1;
                                    // console.log(feature.properties);
                                    // feature.properties.style = style;
                                });
                                return geojson;
                            }

                            let probabilityGeoJsonData = cdriftLayer.toGeoJSON();
                            probabilityGeoJsonData = embedStylesAndPopup(probabilityGeoJsonData,
                                                                         getStyleForProbabilityRegion,
                                                                         getPopupContentForProbabilityRegion);

                            let kml = tokml(probabilityGeoJsonData, {
                                                documentName: kmlDocumentName,
                                                documentDescription: 'KML for SARAT probability regions',
                                                name: 'name',
                                                description: 'popupContent',
                                                simplestyle: true
                                        });

                            // Choose a specific point within the bounding box for the logo
                            // let logoPosition = {
                            //     lat: (bounds.getSouthWest().lat + bounds.getNorthEast().lat) / 2,
                            //     lng: (bounds.getSouthWest().lng + bounds.getNorthEast().lng) / 2
                            // };

                            // var placemark = "<Placemark><name>INCOIS_Logo</name>" +
                            //     "<description>INCOIS Logo</description>" +
                            //     "<Point><coordinates>" + logoPosition.lng + "," + logoPosition.lat + ",0</coordinates>" +
                            //     "</Point>" +
                            //     "<Style><IconStyle><Icon>" +
                            //     "<href>https://sarat.incois.gov.in/sarat/Images/logo.png</href></Icon></IconStyle></Style>" +
                            //     "</Placemark>";
                            // kml = kml.replace('</kml>', placemark + '</kml>');

                            // Define the ScreenOverlay element
                            // var screenOverlay = `
                            //     <ScreenOverlay>
                            //         <name>Logo</name>
                            //         <Icon>
                            //             <href>https://sarat.incois.gov.in/sarat/Images/logo.png</href> <!-- Use absolute URL -->
                            //         </Icon>
                            //         <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
                            //         <screenXY x="0" y="1" xunits="fraction" yunits="fraction"/>
                            //         <rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>
                            //         <size x="0" y="0" xunits="fraction" yunits="fraction"/>
                            //     </ScreenOverlay>
                            // `;
                            // const groundOverlay = "<GroundOverlay><name>Logo</name>" +
                            //     "<Icon> <href>https://sarat.incois.gov.in/sarat/Images/logo.png</href>" +
                            //     "</Icon><LatLonBox><north>" + bounds.getNorthEast().lat + "</north>" +
                            //     "<south>" + bounds.getSouthWest().lat + "</south>" +
                            //     "<east>" + bounds.getNorthEast().lng + "</east>" +
                            //     "<west>" + bounds.getSouthWest().lng + "</west>" +
                            //     "</LatLonBox></GroundOverlay>";

                            // kml = kml.replace('</kml>', groundOverlay + '</kml>');

                            // Append the ScreenOverlay to the KML string
                            // kml = kml.replace('</kml>', screenOverlay + '</kml>');

                            let convertedData = 'application/vnd.google-earth.kml+xml;charset=utf-8,' + encodeURIComponent(kml);
                            let link = document.createElement('a');
                            link.setAttribute('href', 'data:' + convertedData);
                            link.setAttribute('download', "SARAT_" + uniqueId + ".kml");
                            document.body.appendChild(link);
                            link.click();
                            document.body.removeChild(link);
                        };
                    } catch (error) {
                        alert(error);
                        console.log(error);
                    }                    
                }).catch(error => {
                    alert('Unable to get probability regions data: ', error);
                });                

                map.on('mousemove', function (e) {                   
                    if (popup != null)
                        $("#popup-").remove();
                    if (true) {
                        popup = $("<div></div>", {
                            id: "popup-",
                            css: {
                                position: "absolute",                               
                                zIndex: 1002,
                                backgroundColor: "white",
                                padding: "2px",
                                border: "1px solid #ccc"
                            }
                        });
                        popup[0].style.top = (e.layerPoint.y + 10) + 'px';                       
                        popup[0].style.left = (e.layerPoint.x + 10) + 'px';                   
                        var hed = $("<div></div>", {
                            text: textContent + "(" +e.latlng.lng.toFixed(4)+","+e.latlng.lat.toFixed(4)+")",
                            css: {fontSize: "16px", }
                        }).appendTo(popup);
                        popup.appendTo("#map");
                    }
                });
            }//]]
        </script>
        <style>
            .legend ul{
                padding: 0; list-style: none;
            }
            .legend li{
                padding: 5px;   
                color:black;
                font-weight: bold;
            }
            .legend h3{
                background-color:white;
            }            
            .legend li.p5{
                background-color: rgb(255, 254, 215);                
            }
            .legend li.p10{
                background-color: rgb(254, 228, 148);                
            }
            .legend li.p15{                
                background-color: rgb(254, 194, 77);                
            }
            .legend li.p20{
                background-color: rgb(248, 135, 31);               
            }
            .legend li.p25{
                background-color: rgb(251, 181, 154);              
            }
            .legend li.p30{
                background-color: rgb(243, 68, 48);
            }
            .legend li.p35{
                background-color: rgb(208, 27, 30);
            }
            .legend li.p40{
                background-color: rgb(158, 53, 3);
            }
            .legend li.p45{
                background-color: rgb(151, 215, 183);
            }
            .legend li.p50{
                background-color: rgb(94, 189, 209);
            }
            .legend li.p60{
                background-color: rgb(46, 144, 192);                
            }
            .legend li.p70{
                background-color: rgb(2, 98, 168);                
            }
            .legend li.p80{
                background-color: rgb(0, 0, 255);
            }
            .legend li.p90{
                background-color: rgb(64, 64, 64);
            }
            .legend li.p100{
                background-color: rgb(0, 0, 0);
            }
        </style>
    </head>
    <body>
        <div id="background">
           <%@include file="Login_Header.jsp" %>
            <div class="contentpage">               
                <div id="contents">
                    <%
                        if ((session.getAttribute("userid") == null) || (session.getAttribute("userid") == "")) {
                    %>
                    <br/>
                    <%      String message = "please login";
                            response.sendRedirect("home.jsp?message=" + message);
                            return;
                        }
                    %>
                    <style type="text/css">
                        .right_inner1 .heading{
                            text-align: center;
                            width: 100%;
                            padding: 8px 0px;
                            font-family: "Candara", Arial, Helvetica, sans-serif;
                            font-size: 18px;
                            color: #005680;
                            text-transform: uppercase;
                            text-decoration:blink;
                            font-weight: 600;
                        }
                    </style>
                    <div align="center"><br>
                        <div class="right_inner1" style="width:50%;">
                            <div class="heading" id="" style="border-radius: 5px;">
                                probable Search Regions
                            </div>
                        </div>
                        
                    </div> 
                    <div align="right" style="font-size: 18px; text-decoration:blink;font-weight: 600;color:red;">
                      <!-- <marquee> <a style="color:red;font-style: bolder" role="button" href="data/pdf/bulletein-<%=request.getParameter("request_id")%>.pdf" target="_blank">Click Here to download Advisory</a></marquee> -->
                      <marquee>
                        <a style="color:red;font-style: bolder" role="button" href="data/pdf/bulletein-<%=request.getParameter("request_id")%>.pdf" target="_blank">Click Here to download Advisory</a>
                        <!-- <a style="color:red;font-style: bolder" role="button" id="kmldownloadlink" target="_blank">Click Here to download KML</a> -->
                      </marquee>
<!--                        //<marquee> <a style="color:red;font-style: bolder" role="button" href="http://172.30.2.77/sarat/data/pdf/bulletein-<%=request.getParameter("request_id")%>.pdf" target="_blank">Click Here to download Advisory</a></marquee>-->
                    </div>
                    <div style="float:center;width:100%;padding-bottom: 20px">
                        <%
                            System.out.println(request.getParameter("request_id"));
                        %>
                        <div id="map" style="height:80%; width:100%;"></div>
                    </div>
                </div>
            </div>
            <center>©INCOIS search and Rescue. All Rights Reserved</center>
        </div>
    </body>
</html>
