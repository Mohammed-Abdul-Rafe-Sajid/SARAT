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
                    "color": "#FD6A02",
                    "weight": 3,
                    "opacity": "0.9"
                };
            }

            function getPopUpForProbabilityRegion(feature, layer) {
                //console.log('getPopup');
                var popupContent = "";
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
                legend.push(feature.properties.confidence);
                let color = "#FFF";
                if (feature.properties.confidence == '0.05') {
                    color = "rgb(255,247,251)";
                }
                else if (feature.properties.confidence == '0.1') {
                    color = "rgb(247,236,246)";
                } 
                else if (feature.properties.confidence == '0.15') {
                    color = "rgb(239,228,241)";
                } 
                else if (feature.properties.confidence == '0.2') {
                    color = "rgb(229,221,237)";
                } 
                else if (feature.properties.confidence == '0.25') {
                    color = "rgb(217,214,233)";
                } 
                else if (feature.properties.confidence == '0.3') {
                    color = "rgb(204,206,228)";
                }
                else if (feature.properties.confidence == '0.35') {
                    color = "rgb(188,198,224)";
                } 
                else if (feature.properties.confidence == '0.4') {
                    color = "rgb(168,190,219)";
                }
                else if (feature.properties.confidence == '0.45') {                    
                    color = "rgb(143,182,214)";
                } 
                else if (feature.properties.confidence == '0.5') {                    
                    color = "rgb(116,173,208)";
                }
                else if (feature.properties.confidence == '0.55') {
                    color = "rgb(91,163,205)";
                } 
                else if (feature.properties.confidence == '0.6') {
                    color = "rgb(70,152,201)";
                }
                else if (feature.properties.confidence == '0.65') {                    
                    color = "rgb(51,142,190)";
                } 
                else if (feature.properties.confidence == '0.7') {                    
                    color = "rgb(31,136,169)";
                }
                else if (feature.properties.confidence == '0.75') {                    
                    color = "rgb(7,130,144)";
                } 
                else if (feature.properties.confidence == '0.8') {                    
                    color = "rgb(0,123,120)";
                }
                else if (feature.properties.confidence == '0.85') {                    
                    color = "rgb(0,114,100)";
                }
                else if (feature.properties.confidence == '0.9') {                    
                    color = "rgb(3,103,82)";
                }
                else if (feature.properties.confidence == '0.95') {                    
                    color = "rgb(5,88,67)";
                }
                else if (feature.properties.confidence >= '0.95') {                    
                    color = "rgb(1,70,54)";
                }
                return {
                    "color": "black",
                    "weight": 1,
                    "fillColor": color,
                    "fillOpacity": 0.9
                };
                //if (feature.properties.confidence == '0.05') {
                    //color = "rgb(1,70,54)";
                //}
                //else if (feature.properties.confidence == '0.1') {
                    //color = "rgb(5,88,67)";
                //} 
                //else if (feature.properties.confidence == '0.15') {
                    //color = "rgb(3,103,82)";
                //} 
                //else if (feature.properties.confidence == '0.2') {
                    //color = "rgb(0,114,100)";
                //} 
                //else if (feature.properties.confidence == '0.25') {
                    //color = "rgb(0,123,120)";
                //} 
                //else if (feature.properties.confidence == '0.3') {
                    //color = "rgb(7,130,144)";
                //}
                //else if (feature.properties.confidence == '0.35') {
                    //color = "rgb(31,136,169)";
                //} 
                //else if (feature.properties.confidence == '0.4') {
                    //color = "rgb(51,142,190)";
                //}
                //else if (feature.properties.confidence == '0.45') {
                    //color = "rgb(70,152,201)";
                //} 
                //else if (feature.properties.confidence == '0.5') {
                    //color = "rgb(91,163,205)";
                //}
                //else if (feature.properties.confidence == '0.55') {
                    //color = "rgb(116,173,208)";
                //} 
                //else if (feature.properties.confidence == '0.6') {
                    //color = "rgb(143,182,214)";
                //}
                //else if (feature.properties.confidence == '0.65') {
                    //color = "rgb(168,190,219)";
                //} 
                //else if (feature.properties.confidence == '0.7') {
                    //color = "rgb(188,198,224)";
                //}
                //else if (feature.properties.confidence == '0.75') {
                    //color = "rgb(204,206,228)";
                //} 
                //else if (feature.properties.confidence == '0.8') {
                    //color = "rgb(217,214,233)";
                //}
                //else if (feature.properties.confidence == '0.85') {
                    //color = "rgb(229,221,237)";
                //}
                //else if (feature.properties.confidence == '0.9') {
                    //color = "rgb(239,228,241)";
                //}
                //else if (feature.properties.confidence == '0.95') {
                    //color = "rgb(247,236,246)";
                //}
                //else if (feature.properties.confidence >= '0.95') {
                    //color = "rgb(255,247,251)";
                //}
                //return {
                    //"color": "black",
                    //"weight": 1,
                    //"fillColor": color,
                    //"fillOpacity": 0.9
                //};
            }

            //function onEachFeature(feature, layer) {
                //var popupContent = "";
                //if (feature.properties && feature.properties.confidence) {
                    //if (feature.properties.confidence == '0.1') {
                        //popupContent += "10% probability"; 
                    //} else if (feature.properties.confidence == '0.2') {
                        //popupContent += "20% probability"; 
                    //} else if (feature.properties.confidence == '0.3') {
                        //popupContent += "30% probability"; 
                    //} else if (feature.properties.confidence == '0.4') {
                        //popupContent += "40% probability"; 
                    //}
                    //else if (feature.properties.confidence == '0.5') {
                        //popupContent += "50% probability";
                    //}
                    //else if (feature.properties.confidence == '0.6') {
                        //popupContent += "60% probability"; 
                    //}
                    //else if (feature.properties.confidence == '0.7') {
                        //popupContent += "70% probability"; 
                    //}
                    //else if (feature.properties.confidence == '0.8') {
                        //popupContent += "80% probability"; 
                    //}
                    //else if (feature.properties.confidence == '0.9') {
                        //popupContent += "90% probability"; 
                    //}else if (feature.properties.confidence >= '0.9') {
                            //popupContent += "100% probability";
                        //}    
                //}
                //layer.bindPopup(popupContent);
                //layer.on('mouseover', function (e) {
                    //textContent = popupContent + '@';
                //});
                //layer.on('mouseout', function (e) {
                    //textContent = "";
                //});

                //layer.bindPopup(popupContent);
            //}

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
                //console.log(probabilityRegionsGeoJsonFile);

                fetch(probabilityRegionsGeoJsonFile)
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network error');
                    }
                    return response.json();
                }).then(data => {
                    //Do something with the data
                    console.log(data);
                    try {
                        const cdriftLayer = L.geoJson(data, {
                            style: getStyleForProbabilityRegion,
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
                        map.fitBounds(cdriftLayer.getBounds(), {maxZoom: 9});
                        cDriftLegend.addTo(map);
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
            /* .legend li.p01{
                background-color:#00008B;//Darkblue
            }
            .legend li.p02{
                background-color: #FF8C00;               
            }
            .legend li.p03{
                background-color: #6600FF;             
            }
            .legend li.p04{
                background-color: #EE82EE;             
            }
            .legend li.p05{
                background-color: #FF1493;
            }
            .legend li.p06{
                background-color: #006400;
            }
            .legend li.p07{
                background-color: #800080;
            }
            .legend li.p08{
                background-color: #FF0000;
            }
            .legend li.p09{
                background-color: #9933FF;
            }
            .legend li.p010{
                background-color: #40E0D0;
            } */
            /* .legend li.p5{
                background-color: rgb(1,70,54);
            }
            .legend li.p10{
                background-color: rgb(5,88,67);               
            }
            .legend li.p15{
                background-color: rgb(3,103,82);             
            }
            .legend li.p20{
                background-color: rgb(0,114,100);             
            }
            .legend li.p25{
                background-color: rgb(0,123,120);
            }
            .legend li.p30{
                background-color: rgb(7,130,144);
            }
            .legend li.p35{
                background-color: rgb(31,136,169);
            }
            .legend li.p40{
                background-color: rgb(51,142,190);
            }
            .legend li.p45{
                background-color: rgb(70,152,201);
            }
            .legend li.p50{
                background-color: rgb(91,163,205);
            }
            .legend li.p55{
                background-color: rgb(116,173,208);
            }
            .legend li.p60{
                background-color: rgb(143,182,214);
            }
            .legend li.p65{
                background-color: rgb(168,190,219);
            }
            .legend li.p70{
                background-color: rgb(188,198,224);
            }
            .legend li.p75{
                background-color: rgb(204,206,228);
            }
            .legend li.p80{
                background-color: rgb(217,214,233);
            }
            .legend li.p85{
                background-color: rgb(229,221,237);
            }
            .legend li.p90{
                background-color: rgb(239,228,241);
            }
            .legend li.p95{
                background-color: rgb(247,236,246);
            }
            .legend li.p100{
                background-color: rgb(255,247,251);
            } */
            .legend li.p5{
                background-color: rgb(255,247,251);                
            }
            .legend li.p10{
                background-color: rgb(247,236,246);                
            }
            .legend li.p15{                
                background-color: rgb(239,228,241);                
            }
            .legend li.p20{
                background-color: rgb(229,221,237);                
            }
            .legend li.p25{
                background-color: rgb(217,214,233);                
            }
            .legend li.p30{
                background-color: rgb(204,206,228);
            }
            .legend li.p35{
                background-color: rgb(188,198,224);
            }
            .legend li.p40{
                background-color: rgb(168,190,219);
            }
            .legend li.p45{
                background-color: rgb(143,182,214);
            }
            .legend li.p50{
                background-color: rgb(116,173,208);
            }
            .legend li.p55{
                background-color: rgb(91,163,205);                
            }
            .legend li.p60{
                background-color: rgb(70,152,201);                
            }
            .legend li.p65{
                background-color: rgb(51,142,190);                
            }
            .legend li.p70{
                background-color: rgb(31,136,169);                
            }
            .legend li.p75{
                background-color: rgb(7,130,144);                
            }
            .legend li.p80{
                background-color: rgb(0,123,120);
            }
            .legend li.p85{
                background-color: rgb(0,114,100);
            }
            .legend li.p90{
                background-color: rgb(3,103,82);
            }
            .legend li.p95{
                background-color: rgb(5,88,67);
            }
            .legend li.p100{
                background-color: rgb(1,70,54);
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
                      <marquee> <a style="color:red;font-style: bolder" role="button" href="data/pdf/bulletein-<%=request.getParameter("request_id")%>.pdf" target="_blank">Click Here to download Advisory</a></marquee>
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
