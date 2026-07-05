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
        <script src="Js/jszip.min.js"></script>
        <script src="Js/script.js"></script>
        <style type="text/css">
            .inputX{
                font-size: 30px;
            }
        </style>
        <script type='text/javascript'>//<![CDATA[

            var marker = null, map = null;

            // FOR TESTING: Hardcoding case 6687
            // const uniqueId = '<%= request.getParameter("request_id")%>';
            const uniqueId = '6687';
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
                const popupContent = getPopupContentForProbabilityRegion(feature);
                layer.bindPopup(popupContent);
                layer.on('mouseover', function (e) {
                    textContent = popupContent + '@';
                });
                layer.on('mouseout', function (e) {
                    textContent = "";
                });
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
                // Tried the below with backticks but seems there is an issue/conflict with jQuery $ handling
                const lkpGeoJsonUrl = "data/lkp_" + uniqueId + ".geojson";
                //console.log(lkpGeoJsonUrl);
                let response = await fetch(lkpGeoJsonUrl);
                let lkpGeoJson = await response.json();

                const lkpCoordinates = lkpGeoJson.features[0].geometry.coordinates;


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

                // Mean trajectory
                const meanTrajectoryGeoJsonFile = "data/meantrajectory_" + uniqueId + ".geojson";
                response = await fetch(meanTrajectoryGeoJsonFile);
                let meanTrajectoryGeoJson = await response.json();

                const _meanTrajLayer = L.geoJson(meanTrajectoryGeoJson, {
                    onEachFeature: getPopupForMeanTrajectoryLayer,
                    style: getStyleForMeanTrajectoryLayer
                });
                
                // All trajectories
                const allTrajectoriesGeoJsonFile = "data/trajectories_" + uniqueId + ".geojson";
                response = await fetch(allTrajectoriesGeoJsonFile);
                let allTrajectoriesGeoJson = await response.json();

                const _allTrajLayer = L.geoJson(allTrajectoriesGeoJson, {
                    onEachFeature: getPopupForAllTrajectoriesLayer,
                    style: getStyleForAllTrajectoriesLayer
                });

                // Store to module-level variables for switchVisualMode
                meanTrajectoryLayer  = _meanTrajLayer;
                allTrajectoriesLayer = _allTrajLayer;

                // Add to map by default
                meanTrajectoryLayer.addTo(map);
                allTrajectoriesLayer.addTo(map);


                // Probability regions
                const probabilityRegionsGeoJsonFile = "data/" + uniqueId + ".json";
                const kmlDocumentName = "SARAT_" + uniqueId;

                try {
                    const response = await fetch(probabilityRegionsGeoJsonFile);
                    if (!response.ok) {
                        alert("Failed to get probability region data from the server");
                        return;
                    }
                    const data = await response.json();
                    const cdriftLayer = L.geoJson(data, {
                            // style: getStyleForProbabilityRegion,
                            style: (feature) => {
                                legend.push(feature.properties.confidence);
                                return getStyleForProbabilityRegion(feature);
                            },
                            onEachFeature: getPopUpForProbabilityRegion,
                    });                        
                    cdriftLayer.addTo(map);
                    v2CdriftLayer = cdriftLayer; // store for mode switching

                    const cDriftLegend = L.control({
                        position: 'bottomright'
                    });
                    const bounds = cdriftLayer.getBounds();
                    map.fitBounds(bounds, {maxZoom: 9});

                    // cDriftLegend needs to be added only after cDriftLayer because
                    // legend data structure is populated from getStyleForProbabilityRegions
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
                    cDriftLegend.addTo(map);
                        
                    let kmldownload = L.control({
                        position: 'topleft'
                    });
                    kmldownload.onAdd = function (map) {
                        let div = L.DomUtil.create('div', 'info legend');
                        div.innerHTML += '<h3 style="background-color:#ffffff;font-size:25px;font-style: bolder"><a style="font-color:red;" role="button" id="kmldownloadlink" target="_blank">Download KMZ</a></h3>';
                        return div;
                    };
                    kmldownload.addTo(map);

                    document.getElementById('kmldownloadlink').onclick = async function(event) {
                        alert("KMZ Download Link was clicked!");
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

                        let logoPosition;
                        if (lkpCoordinates) {

                            logoPosition = {
                                lat: lkpCoordinates[1],
                                lng: lkpCoordinates[0]
                            };
                        } else {
                            // If LKP is not available, take from the bounds
                            logoPosition = {
                                lat: (bounds.getSouthWest().lat + bounds.getNorthEast().lat) / 2,
                                lng: (bounds.getSouthWest().lng + bounds.getNorthEast().lng) / 2
                            };
                        }
                        console.log(logoPosition);

                        // Read image from the server
                        const logoData = await fetch('Images/logo.png');
                        const blob = await logoData.blob();
                        const reader = new FileReader();
                        reader.readAsDataURL(blob);
                        reader.onloadend = async function() {
                            const base64data = reader.result.split(',')[1]; // Get the Base64 part

                            var placemark = "<Placemark><name>INCOIS_Logo</name>" +
                                "<description>INCOIS Logo</description>" +
                                "<Point><coordinates>" + logoPosition.lng + "," + logoPosition.lat + ",0</coordinates>" +
                                "</Point>" +
                                "<Style>" +
                                "<IconStyle>" +
                                "<Icon>" +
                                "<href>Images/logo.png</href>" +
                                "</Icon>" +
                                "<scale>1.0</scale>" +
                                "</IconStyle>" +
                                "<LabelStyle>" +
                                "<scale>0</scale>" +
                                "</LabelStyle>" +
                                "</Style>" +
                                "</Placemark>";
                            kml = kml.replace('</Document>', placemark + '</Document>');
                            // Create a new JSZip instance
                            var zip = new JSZip();

                            // Add the KML file to the ZIP archive
                            zip.file('doc.kml', kml);

                            // Add the Base64 encoded image to the ZIP archive
                            zip.file('Images/logo.png', base64data, {base64: true});

                            // --- ADD V3 TIME-BASED INTERVAL KMLs ---
                            // If heatmap index data is available, load each interval period
                            // and generate a separate KML file in the KMZ.
                            if (heatmapIndexData && heatmapIndexData.files) {
                                for (let i = 0; i < heatmapIndexData.files.length; i++) {
                                    const fileName = heatmapIndexData.files[i];
                                    const kmlFileName = fileName.replace('.geojson', '.kml');
                                    let intervalName = "Interval_" + i;
                                    if (heatmapIndexData.intervals && heatmapIndexData.intervals[i]) {
                                        // Format as Hours_Start_End
                                        intervalName = "Hours_" + heatmapIndexData.intervals[i][0] + "_" + heatmapIndexData.intervals[i][1];
                                    }
                                    
                                    try {
                                        // --- NEW: Fetch pre-generated KML directly ---
                                        let resp = await fetch('data/' + kmlFileName);
                                        if (resp.ok) {
                                            let kmlContent = await resp.text();
                                            zip.file('Intervals/' + intervalName + '.kml', kmlContent);
                                        } else {
                                            console.warn("KML file not found: " + kmlFileName);
                                            
                                            /* 
                                            // --- OLD: Fallback to local conversion if KML fetch fails ---
                                            let geoResp = await fetch('data/' + fileName);
                                            if (geoResp.ok) {
                                                let geojson = await geoResp.json();
                                                geojson = embedStylesAndPopup(geojson, getStyleForProbabilityRegion, getPopupContentForProbabilityRegion);
                                                let intervalKml = tokml(geojson, {
                                                                    documentName: 'SARAT_' + uniqueId + '_' + intervalName,
                                                                    documentDescription: 'KML for SARAT probability region ' + intervalName,
                                                                    name: 'name',
                                                                    description: 'popupContent',
                                                                    simplestyle: true
                                                            });
                                                zip.file('Intervals/' + intervalName + '.kml', intervalKml);
                                            }
                                            */
                                        }
                                    } catch(e) {
                                        console.error("Failed to fetch KML for interval", fileName, e);
                                    }
                                }
                            }
                            // ----------------------------------------

                            // Generate the KMZ file and trigger download
                            zip.generateAsync({ type: 'blob' }).then(function(content) {
                                var link = document.createElement('a');
                                link.href = URL.createObjectURL(content);
                                link.download = "SARAT_" + uniqueId + ".kmz";
                                document.body.appendChild(link);
                                link.click();
                                document.body.removeChild(link);
                            });
                        };
                       
                        // let convertedData = 'application/vnd.google-earth.kml+xml;charset=utf-8,' + encodeURIComponent(kml);
                        // let link = document.createElement('a');
                        // link.setAttribute('href', 'data:' + convertedData);
                        // link.setAttribute('download', "SARAT_" + uniqueId + ".kml");
                        // document.body.appendChild(link);
                        // link.click();
                        // document.body.removeChild(link);
                    };
                } catch (error) {
                    if (typeof(error) === 'object') {
                        alert("Error occurred: " + error.message);
                    } else {
                        alert("Error occurred: " + error);
                    }
                }
            }

            // ============================================
            // VISUAL MODE CONTROL (V2 / V3)
            // ============================================
            let currentMap = null;
            let heatmapIndexData = null;  // kept for KMZ download compatibility

            // Active layers tracking
            let v2CdriftLayer  = null;    // V2 probability region layer
            let v2LayerControl = null;    // V2 mean/all trajectory layer control
            let meanTrajectoryLayer = null;
            let allTrajectoriesLayer = null;

            // V3 layers: keyed by interval index
            let v3IntervalLayers = {};      // geoJSON layers per interval
            let v3ArrowLayers    = {};      // Leaflet LayerGroup of arrow markers per interval
            let v3IndexData      = null;    // interval_index_{id}.json
            let currentVectorData = null;   // current_vectors_{id}.json (loaded once)

            let currentVisualMode = 'v2'; // 'v2' or 'v3'

            // --------------------------------------------------
            // Init: load V3 metadata on startup
            // --------------------------------------------------
            async function initVisualModeControl() {
                var timestamp = new Date().getTime();
                // Load V3 interval index
                try {
                    const resp = await fetch('data/interval_index_' + uniqueId + '.json?t=' + timestamp);
                    if (resp.ok) {
                        v3IndexData    = await resp.json();
                        heatmapIndexData = v3IndexData;  // KMZ download compat
                        console.log('[V3] Interval index loaded:', v3IndexData.total_intervals, 'intervals');
                    }
                } catch(e) { console.log('[V3] Interval index unavailable:', e); }

                // Build the visual-mode Leaflet control
                buildVisualModeControl();
            }

            // --------------------------------------------------
            // Build visual mode control (Trajectories, V2/V3 radios, V3 interval check list)
            // --------------------------------------------------
            function buildVisualModeControl() {
                var VisualModeControl = L.Control.extend({
                    options: { position: 'topright' },
                    onAdd: function(map) {
                        var container = L.DomUtil.create('div', 'visual-mode-control');
                        L.DomEvent.disableClickPropagation(container);
                        L.DomEvent.disableScrollPropagation(container);

                        container.innerHTML =
                            '<div id="v2TrajectoryPanel">' +
                              '<div class="vmc-title">Trajectories</div>' +
                              '<label class="vmc-label"><input type="checkbox" id="cbMeanTraj" checked> Mean Trajectory</label>' +
                              '<label class="vmc-label"><input type="checkbox" id="cbAllTraj" checked> All Trajectories</label>' +
                              '<div style="margin-top:6px;border-top:1px solid #ccc;padding-top:4px;"></div>' +
                            '</div>' +
                            '<div class="vmc-title">Visual Mode</div>' +
                            '<label class="vmc-label"><input type="radio" name="visualMode" id="radioV2" value="v2" checked> V2 Visual</label>' +
                            '<label class="vmc-label"><input type="radio" name="visualMode" id="radioV3" value="v3"> V3 Visual</label>' +
                            '<div id="v3IntervalPanel" style="display:none;margin-top:6px;border-top:1px solid #ccc;padding-top:6px;">' +
                              '<div class="vmc-title" style="font-size:11px;">Time Intervals</div>' +
                              '<div id="v3CheckboxList"></div>' +
                            '</div>';

                        // Checkbox listeners for Trajectories
                        L.DomEvent.on(container.querySelector('#cbMeanTraj'), 'change', function() {
                            if (currentVisualMode !== 'v2') return;
                            if (this.checked) {
                                if (meanTrajectoryLayer) meanTrajectoryLayer.addTo(currentMap);
                            } else {
                                if (meanTrajectoryLayer && currentMap.hasLayer(meanTrajectoryLayer)) currentMap.removeLayer(meanTrajectoryLayer);
                            }
                        });
                        L.DomEvent.on(container.querySelector('#cbAllTraj'), 'change', function() {
                            if (currentVisualMode !== 'v2') return;
                            if (this.checked) {
                                if (allTrajectoriesLayer) allTrajectoriesLayer.addTo(currentMap);
                            } else {
                                if (allTrajectoriesLayer && currentMap.hasLayer(allTrajectoriesLayer)) currentMap.removeLayer(allTrajectoriesLayer);
                            }
                        });

                        // Populate V3 interval checkboxes
                        if (v3IndexData && v3IndexData.files) {
                            var listDiv = container.querySelector('#v3CheckboxList');
                            v3IndexData.files.forEach(function(file, idx) {
                                var label = 'Interval ' + idx;
                                if (v3IndexData.intervals && v3IndexData.intervals[idx]) {
                                    var iv = v3IndexData.intervals[idx];
                                    label = 'Hours ' + iv[0] + ' – ' + iv[1];
                                }
                                var row = document.createElement('label');
                                row.className = 'vmc-label';
                                row.innerHTML = '<input type="checkbox" class="v3-interval-cb" data-file="' + file + '" data-idx="' + idx + '"> ' + label;
                                listDiv.appendChild(row);
                            });
                            // Attach change handlers
                            container.querySelectorAll('.v3-interval-cb').forEach(function(cb) {
                                L.DomEvent.on(cb, 'change', function() {
                                    var idx = parseInt(this.getAttribute('data-idx'));
                                    var file = this.getAttribute('data-file');
                                    console.log('[V3 Checkbox] Toggle: idx=' + idx + ', checked=' + this.checked);
                                    if (this.checked) {
                                        loadV3Interval(idx, file);
                                    } else {
                                        removeV3Interval(idx);
                                    }
                                });
                            });
                        } else {
                            container.querySelector('#v3IntervalPanel').innerHTML +=
                                '<div style="font-size:11px;color:#888;">No V3 data available</div>';
                        }

                        // Radio button handlers
                        container.querySelector('#radioV2').addEventListener('change', function() {
                            if (this.checked) switchVisualMode('v2');
                        });
                        container.querySelector('#radioV3').addEventListener('change', function() {
                            if (this.checked) switchVisualMode('v3');
                        });

                        return container;
                    }
                });

                new VisualModeControl().addTo(currentMap);
            }

            // --------------------------------------------------
            // Switch visual mode
            // --------------------------------------------------
            function switchVisualMode(mode) {
                currentVisualMode = mode;
                console.log('[VisualMode] Switch to:', mode);
                if (mode === 'v2') {
                    // Show V2 layers based on Trajectories checkboxes state
                    var meanChecked = document.getElementById('cbMeanTraj').checked;
                    var allChecked = document.getElementById('cbAllTraj').checked;

                    if (meanChecked && meanTrajectoryLayer) meanTrajectoryLayer.addTo(currentMap);
                    if (allChecked && allTrajectoriesLayer) allTrajectoriesLayer.addTo(currentMap);
                    if (v2CdriftLayer) v2CdriftLayer.addTo(currentMap);

                    // Show V2 panel, hide V3 panel
                    var trajPanel = document.getElementById('v2TrajectoryPanel');
                    if (trajPanel) trajPanel.style.display = 'block';
                    var panel = document.getElementById('v3IntervalPanel');
                    if (panel) panel.style.display = 'none';

                    // Clear V3 interval and velocity animation layers
                    clearAllV3Layers();
                } else {
                    // Hide V2 layers
                    if (v2CdriftLayer && currentMap.hasLayer(v2CdriftLayer)) currentMap.removeLayer(v2CdriftLayer);
                    if (meanTrajectoryLayer && currentMap.hasLayer(meanTrajectoryLayer)) currentMap.removeLayer(meanTrajectoryLayer);
                    if (allTrajectoriesLayer && currentMap.hasLayer(allTrajectoriesLayer)) currentMap.removeLayer(allTrajectoriesLayer);

                    // Hide V2 panel, show V3 panel
                    var trajPanel = document.getElementById('v2TrajectoryPanel');
                    if (trajPanel) trajPanel.style.display = 'none';
                    var panel = document.getElementById('v3IntervalPanel');
                    if (panel) panel.style.display = 'block';
                }
            }

            // --------------------------------------------------
            // V3: Load current_vectors data once (cached)
            // --------------------------------------------------
            async function ensureCurrentVectorData() {
                if (currentVectorData) return currentVectorData;
                try {
                    var resp = await fetch('data/current_vectors_' + uniqueId + '.json?t=' + new Date().getTime());
                    if (resp.ok) {
                        currentVectorData = await resp.json();
                        console.log('[V3] Current vector data loaded, intervals:', currentVectorData.intervals.length);
                    } else {
                        console.warn('[V3] current_vectors file not found');
                        currentVectorData = null;
                    }
                } catch(e) {
                    console.warn('[V3] Could not load current_vectors:', e);
                    currentVectorData = null;
                }
                return currentVectorData;
            }

            // --------------------------------------------------
            // V3: Load a single interval GeoJSON + current-direction arrows
            // --------------------------------------------------
            async function loadV3Interval(idx, filename) {
                if (!currentMap) return;
                console.log('[V3 Interval] loadV3Interval called for idx=' + idx + ' file=' + filename);
                // Remove old layers if exists
                removeV3Interval(idx);

                // ── 1. Load interval GeoJSON (probability cells + bounding box) ──
                var filePath = filename.startsWith('data/') ? filename : 'data/' + filename;
                filePath += '?t=' + new Date().getTime();
                try {
                    var resp = await fetch(filePath);
                    if (!resp.ok) { console.warn('[V3] Could not load', filePath); return; }
                    var geojson = await resp.json();

                    var layer = L.geoJson(geojson, {
                        style: function(feature) {
                            if (feature.properties && feature.properties.type === 'bounding_box') {
                                return { color: '#1a6b9a', weight: 2.5, fillOpacity: 0, opacity: 0.9, dashArray: '6,4' };
                            }
                            var prob = feature.properties.normalized_probability || 0;
                            return {
                                color: 'none',
                                weight: 0,
                                fillColor: getV3ProbColor(prob),
                                fillOpacity: 0.75
                            };
                        },
                        onEachFeature: function(feature, lyr) {
                            if (feature.properties) {
                                var type = feature.properties.type || 'cell';
                                if (type === 'bounding_box') {
                                    lyr.bindPopup('Interval: ' + (feature.properties.interval || '') +
                                                  '<br>Max prob: ' + (feature.properties.max_probability || '') +
                                                  '<br>Points: ' + (feature.properties.points_included || ''));
                                } else {
                                    lyr.bindPopup('Probability: ' +
                                                  ((feature.properties.probability_percent || 0).toFixed(2)) + '%' +
                                                  '<br>Interval: ' + (feature.properties.interval || ''));
                                }
                            }
                        }
                    }).addTo(currentMap);

                    v3IntervalLayers[idx] = layer;

                } catch(e) { console.error('[V3] Error loading interval GeoJSON', idx, e); }

                // ── 2. Load current direction arrows ──
                try {
                    var cvData = await ensureCurrentVectorData();
                    if (cvData && cvData.intervals) {
                        var ivData = null;
                        for (var i = 0; i < cvData.intervals.length; i++) {
                            if (cvData.intervals[i].interval_idx === idx) {
                                ivData = cvData.intervals[i];
                                break;
                            }
                        }
                        if (ivData && ivData.valid && ivData.velocity_grib && ivData.velocity_grib.length >= 2) {
                            var arrowGroup = buildCurrentArrowLayer(ivData);
                            if (arrowGroup) {
                                arrowGroup.addTo(currentMap);
                                v3ArrowLayers[idx] = arrowGroup;
                            }
                        }
                    }
                } catch(e) { console.error('[V3] Error drawing current arrows for interval', idx, e); }
            }

            // --------------------------------------------------
            // V3: Build Leaflet LayerGroup of arrow markers for an interval
            // --------------------------------------------------
            function buildCurrentArrowLayer(ivData) {
                var uGrid = null, vGrid = null;
                for (var k = 0; k < ivData.velocity_grib.length; k++) {
                    var g = ivData.velocity_grib[k];
                    if (g.header.parameterNumber === 2) uGrid = g; // U east-west
                    if (g.header.parameterNumber === 3) vGrid = g; // V north-south
                }
                if (!uGrid || !vGrid) {
                    console.warn('[V3 Arrows] Missing U or V grid for interval', ivData.interval_idx);
                    return null;
                }

                var h = uGrid.header;
                var nx = h.nx, ny = h.ny;
                var lo1 = h.lo1, la1 = h.la1; // top-left corner
                var dx  = h.dx,  dy  = h.dy;  // grid spacing (positive)

                // Bounding box with a margin for arrows slightly outside the hull
                var bbox = ivData.bbox;
                var margin = Math.max(dy * 2, dx * 2, 0.25); // ~2 grid cells margin
                var bLon1 = bbox.min_lon - margin;
                var bLon2 = bbox.max_lon + margin;
                var bLat1 = bbox.min_lat - margin;
                var bLat2 = bbox.max_lat + margin;

                // Compute max speed for normalisation (skip zeros)
                var maxSpeed = 0;
                for (var i = 0; i < uGrid.data.length; i++) {
                    var sp = Math.sqrt(uGrid.data[i] * uGrid.data[i] + vGrid.data[i] * vGrid.data[i]);
                    if (sp > maxSpeed) maxSpeed = sp;
                }
                if (maxSpeed < 1e-6) maxSpeed = 1; // avoid division by zero

                var group = L.layerGroup();

                // Thinning: only render every Nth grid point to keep density sane
                // Target ~4-8 arrows per grid span; thin if grid is very fine
                var step = Math.max(1, Math.round(Math.min(nx, ny) / 8));

                for (var row = 0; row < ny; row += step) {
                    for (var col = 0; col < nx; col += step) {
                        var gridIdx = row * nx + col;
                        var u = uGrid.data[gridIdx];
                        var v = vGrid.data[gridIdx];
                        var speed = Math.sqrt(u * u + v * v);

                        // Skip zero-speed points
                        if (speed < 1e-4) continue;

                        // Reconstruct lat/lon: la1 is top (north), lat decreases downward
                        var lon = lo1 + col * dx;
                        var lat = la1 - row * dy;

                        // Only draw within bounding box + margin
                        if (lon < bLon1 || lon > bLon2 || lat < bLat1 || lat > bLat2) continue;

                        // Arrow angle: oceanographic convention
                        // u = east (positive = eastward), v = north (positive = northward)
                        // SVG angle: 0 = up, clockwise positive
                        // Math angle from north clockwise: atan2(u, v)
                        var angleDeg = Math.atan2(u, v) * 180 / Math.PI;

                        // Normalised speed [0..1] for visual scaling
                        var normSpeed = speed / maxSpeed;

                        var marker = makeArrowMarker(lat, lon, angleDeg, normSpeed, speed);
                        group.addLayer(marker);
                    }
                }

                return group;
            }

            // --------------------------------------------------
            // V3: Create a single arrow DivIcon marker
            // --------------------------------------------------
            function makeArrowMarker(lat, lon, angleDeg, normSpeed, speedMs) {
                // Arrow size: 24px base, slightly larger for fast currents
                var arrowLen = Math.round(22 + normSpeed * 10); // 22-32 px
                var half = Math.round(arrowLen / 2);

                // Colour: slow=cyan, medium=royalblue, fast=darkblue
                var arrowColor;
                if (normSpeed < 0.33)      arrowColor = '#00bcd4'; // cyan
                else if (normSpeed < 0.66) arrowColor = '#1565c0'; // royal blue
                else                       arrowColor = '#0d47a1'; // dark blue

                // SVG arrow pointing UP by default, rotated by angleDeg
                var svgSize = arrowLen + 10;
                var cx = svgSize / 2;
                var tipY = 2;
                var tailY = svgSize - 4;
                var hw = 5;  // half-width of arrowhead
                var sw = 2.5; // shaft width

                var svg =
                    '<svg xmlns="http://www.w3.org/2000/svg" width="' + svgSize + '" height="' + svgSize + '" ' +
                    'style="transform:rotate(' + angleDeg.toFixed(1) + 'deg);overflow:visible;">' +
                    // Shaft
                    '<line x1="' + cx + '" y1="' + tipY + '" x2="' + cx + '" y2="' + tailY + '" ' +
                    'stroke="' + arrowColor + '" stroke-width="' + sw + '" stroke-linecap="round"/>' +
                    // Arrowhead (filled triangle at tip)
                    '<polygon points="' +
                      cx + ',' + tipY + ' ' +
                      (cx - hw) + ',' + (tipY + hw * 2) + ' ' +
                      (cx + hw) + ',' + (tipY + hw * 2) + '" ' +
                    'fill="' + arrowColor + '"/>' +
                    '</svg>';

                var icon = L.divIcon({
                    className: 'v3-current-arrow',
                    html: svg,
                    iconSize:   [svgSize, svgSize],
                    iconAnchor: [cx, svgSize / 2]
                });

                var marker = L.marker([lat, lon], { icon: icon, interactive: false });
                return marker;
            }

            // --------------------------------------------------
            // V3: Probability → colour mapping
            // --------------------------------------------------
            function getV3ProbColor(normProb) {
                // Colour ramp: light blue → deep blue
                var p = Math.max(0, Math.min(1, normProb));
                if (p < 0.2)  return '#e0f3f8';
                if (p < 0.4)  return '#abd9e9';
                if (p < 0.6)  return '#74add1';
                if (p < 0.75) return '#4575b4';
                if (p < 0.9)  return '#313695';
                return '#0d1057';
            }

            // --------------------------------------------------
            // V3: Remove a single interval's layers
            // --------------------------------------------------
            function removeV3Interval(idx) {
                if (v3IntervalLayers[idx]) {
                    currentMap.removeLayer(v3IntervalLayers[idx]);
                    delete v3IntervalLayers[idx];
                }
                if (v3ArrowLayers[idx]) {
                    currentMap.removeLayer(v3ArrowLayers[idx]);
                    delete v3ArrowLayers[idx];
                }
            }

            // --------------------------------------------------
            // V3: Clear all interval layers
            // --------------------------------------------------
            function clearAllV3Layers() {
                Object.keys(v3IntervalLayers).forEach(function(idx) { removeV3Interval(parseInt(idx)); });
                Object.keys(v3ArrowLayers).forEach(function(idx) { removeV3Interval(parseInt(idx)); });
                // Uncheck all checkboxes
                document.querySelectorAll('.v3-interval-cb').forEach(function(cb) { cb.checked = false; });
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
          
                var pdfdownload = L.control({
                    position: 'topleft'
                });
                pdfdownload.onAdd = function (map) {
                    var div = L.DomUtil.create('div', 'info legend');
                    // ORIGINAL DYNAMIC PATH:
                    // div.innerHTML += '<h3 style="background-color:#ffffff;font-size:25px;font-style: bolder"><a style="font-color:red;" role="button" href="data/pdf/bulletein-<%=request.getParameter("request_id")%>.pdf" target="_blank">Click Here to Download</a></h3>';
                    // HARDCODED PATH FOR TESTING CASE 6687:
                    div.innerHTML += '<h3 style="background-color:#ffffff;font-size:25px;font-style: bolder"><a style="font-color:red;" role="button" href="data/pdf/bulletein-6687.pdf" target="_blank">Click Here to Download</a></h3>';
                    return div;
                };
                pdfdownload.addTo(map);
                
                //cDriftLegend1.addTo(map);//adding help message

                // Store map reference for heatmap controls
                currentMap = map;
                
                // Load probability regions and other data
                loadDataToMap(map);
                
                // Initialize V2/V3 visual mode control
                initVisualModeControl();

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

            /* ---- V2/V3 Visual Mode Control ---- */
            .visual-mode-control {
                background: white;
                border-radius: 6px;
                box-shadow: 0 1px 6px rgba(0,0,0,0.25);
                padding: 8px 12px;
                min-width: 148px;
                font-family: Arial, sans-serif;
                font-size: 13px;
            }
            .vmc-title {
                font-weight: bold;
                font-size: 12px;
                color: #005680;
                text-transform: uppercase;
                letter-spacing: 0.04em;
                margin-bottom: 5px;
            }
            .vmc-label {
                display: block;
                cursor: pointer;
                margin: 3px 0;
                color: #333;
                font-size: 12px;
                line-height: 1.6;
                white-space: nowrap;
            }
            .vmc-label input {
                margin-right: 5px;
                cursor: pointer;
            }
            #v3CheckboxList {
                max-height: 220px;
                overflow-y: auto;
                padding-right: 2px;
            }
            /* Speed label marker */
            .v3-speed-label {
                background: transparent;
                border: none;
                white-space: nowrap;
            }
            .v3-speed-label span {
                background: rgba(255,255,255,0.85);
                border: 1px solid #003580;
                border-radius: 3px;
                padding: 1px 5px;
                font-size: 10px;
                font-weight: bold;
                color: #003580;
            }
            /* Current direction arrow markers */
            .v3-current-arrow {
                background: transparent !important;
                border: none !important;
                pointer-events: none;
                /* filter gives the arrows a slight drop-shadow for contrast */
                filter: drop-shadow(0px 0px 1.5px rgba(255,255,255,0.8));
            }

        </style>
    </head>
    <body>
        <div id="background">
           <%@include file="Login_Header.jsp" %>
            <div class="contentpage">               
                <div id="contents">
                    <%
                        // LOCAL DEV BYPASS: Commented out the authentication redirect
                        // if ((session.getAttribute("userid") == null) || (session.getAttribute("userid") == "")) {
                    %>
                    <br/>
                    <%      // String message = "please login";
                            // response.sendRedirect("home.jsp?message=" + message);
                            // return;
                        // }
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
                        <!-- ORIGINAL DYNAMIC PATH: -->
                        <!-- <a style="color:red;font-style: bolder" role="button" href="data/pdf/bulletein-<%=request.getParameter("request_id")%>.pdf" target="_blank">Click Here to download Advisory</a> -->
                        <!-- HARDCODED PATH FOR TESTING CASE 6687: -->
                        <a style="color:red;font-style: bolder" role="button" href="data/pdf/bulletein-6687.pdf" target="_blank">Click Here to download Advisory</a>
<!--                        //<marquee> <a style="color:red;font-style: bolder" role="button" href="http://172.30.2.77/sarat/data/pdf/bulletein-<%=request.getParameter("request_id")%>.pdf" target="_blank">Click Here to download Advisory</a></marquee>-->
                    </div>
                    <div style="float:center;width:100%;padding-bottom: 20px">
                        <%
                            // System.out.println(request.getParameter("request_id"));
                            System.out.println("TESTING MODE: uniqueId forced to 6687");
                        %>
                        <!-- V3 mode replaces the old heatmap dropdown; interval panel is inside the Leaflet control -->
                        <div id="map" style="height:80%; width:100%;"></div>
                    </div>
                </div>
            </div>
            <center>©INCOIS search and Rescue. All Rights Reserved</center>
        </div>
    </body>
</html>
