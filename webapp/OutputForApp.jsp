<%-- 
    Document   : OutputForApp
    Created on : Jun 14, 2016, 7:54:00 PM
    Author     : Administrator
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<html>
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
        <title>ESSO-SARAT Output</title>
        <link rel="stylesheet" href="Css/Menustyles.css">        
        <script src="Js/script.js"></script>
        <link rel="stylesheet" href="Css/style.css" type="text/css">
        <link rel="stylesheet" type="text/css" href="Js/vendors/leaflet-plugins/Leaflet.Coordinates-0.1.3.css">
        <link rel="stylesheet" href="Js/vendors/leaflet-plugins/Control.FullScreen.css" />
        <link rel="stylesheet" type="text/css" href="Css/TimeDimention_style.css">
        <script type="text/javascript" src="Js/vendors/jquery-2.0.0.min.js"></script>
        <script type='text/javascript' src="Js/vendors/leaflet-0.7.3/leaflet.js"></script>
        <script type="text/javascript" src="Js/vendors/leaflet-plugins/Control.FullScreen.js"></script>
        <link rel="stylesheet" type="text/css" href="Js/vendors/leaflet-0.7.3/leaflet.css">
        <script type='text/javascript' src="Js/vendors/leaflet-plugins/Leaflet.Coordinates-0.1.3.min.js"></script>
        <script type='text/javascript'>//<![CDATA[
            window.onload = function () {
                var textContent = "", popup = null;
                var southWest = L.latLng(-60, 30),
                        northEast = L.latLng(30, 120),
                        bounds = L.latLngBounds(southWest, northEast);
// create a map in the "map" div, set the view to a given place and zoom
                var legend = [];
                var map = L.map('map', {
                    fullscreenControl: true,
                    maxBounds: bounds,
                    center: [20, 77],
                    maxZoom: 12,
                    minZoom: 5,
                    zoom: 8
                });
                /* L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
                 maxZoom: 18,
                 }).addTo(map);*/

                /* L.tileLayer('https://api.tiles.mapbox.com/v4/streets/997/256/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoidmVua2F0NTA4IiwiYSI6ImNpcGZsenUzYTAwMDB0NWx2ZWQ2ZW5sNGMifQ.8du6DAzv9L499nZJacW8hQ', {
                 attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">Mapbox</a>',
                 maxZoom: 18
                 }).addTo(map);*/
                L.tileLayer('https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token={accessToken}', {
                    attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">Mapbox</a>',
                    maxZoom: 18,
                    id: 'venkat508.0dd9hkgl',
                    accessToken: 'pk.eyJ1IjoidmVua2F0NTA4IiwiYSI6ImNpcGZsenUzYTAwMDB0NWx2ZWQ2ZW5sNGMifQ.8du6DAzv9L499nZJacW8hQ'
                }).addTo(map);

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
                /*  var cDriftLegend1 = L.control({
                 position: 'topright'
                 });
                 cDriftLegend1.onAdd = function (map) {
                 var div = L.DomUtil.create('div', 'info legend');
                 div.innerHTML += '<h3 style="font-size:16px;color:red;">Click on a specific region on the colored area to see the probability</h3>';
                 return div;
                 };
                 cDriftLegend1.addTo(map);*/
                function onEachFeature(feature, layer) {
                    var popupContent = "";
                    if (feature.properties && feature.properties.confidence) {
                        if (feature.properties.confidence == '0.1') {
                            popupContent += "10% probability";
                        } else if (feature.properties.confidence == '0.2') {
                            popupContent += "20% probability";
                        } else if (feature.properties.confidence == '0.3') {
                            popupContent += "30% probability";
                        } else if (feature.properties.confidence == '0.4') {
                            popupContent += "40% probability";
                        }
                        else if (feature.properties.confidence == '0.5') {
                            popupContent += "50% probability";
                        }
                        else if (feature.properties.confidence == '0.6') {
                            popupContent += "60% probability";
                        }
                        else if (feature.properties.confidence == '0.7') {
                            popupContent += "70% probability";
                        }
                        else if (feature.properties.confidence == '0.8') {
                            popupContent += "80% probability";
                        }
                        else if (feature.properties.confidence == '0.9') {
                            popupContent += "90% probability";
                        } else if (feature.properties.confidence >= '0.9') {
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

                    layer.bindPopup(popupContent);
                }
                var cdriftLayer = null;
                 $.getJSON('data/' +<%= request.getParameter("request_id")%>+'.json', function (data) {
                //$.getJSON('data/228.json', function (data) {
                    cdriftLayer = L.geoJson(data, {
                        style: function (feature) {
                            legend.push(feature.properties.confidence);

                            var color = "#FFF";
                            if (feature.properties.confidence == '0.1') {
                                color = "#00008B";
                            } else if (feature.properties.confidence == '0.2') {
                                color = "#FF8C00";
                            } else if (feature.properties.confidence == '0.3') {
                                color = "#6600FF";
                            }
                            else if (feature.properties.confidence == '0.4') {
                                color = "#EE82EE";
                            }
                            else if (feature.properties.confidence == '0.5') {
                                color = "#FF1493";
                            }
                            else if (feature.properties.confidence == '0.6') {
                                color = "#006400";
                            }
                            else if (feature.properties.confidence == '0.7') {
                                color = "#800080";
                            }
                            else if (feature.properties.confidence == '0.8') {
                                color = "#FF0000";
                            }
                            else if (feature.properties.confidence == '0.9') {
                                color = "#9933FF";
                            }
                            else if (feature.properties.confidence >= '0.9') {
                                color = "#40E0D0";
                            }
                            return {
                                "color": color,
                                "weight": 10,
                                "fillColor": color,
                                "fillOpacity": 1
                            };
                        },
                        onEachFeature: onEachFeature
                    });
                    cdriftLayer.addTo(map);
                    cdriftLayer.bringToBack();
                    cDriftLegend.onAdd = function (map) {
                        legend.sort();
                        legend_prob = $.makeArray($(legend).filter(function (i, itm) {
                            return i == $(legend).index(itm);
                        }));
                        //legend_prob = jQuery.unique(legend).sort();
                        var div = L.DomUtil.create('div', 'info legend');
                        html = '<ul>\n'
                        for (i = 0; i < legend_prob.length; i++) {
                            html += '<li class=p0' + legend_prob[i] * 10 + '>' + legend_prob[i] * 100 + '% probability</li>';
                        }
                        html += '</ul>';
                        div.innerHTML += html;
                        return div;
                    };
                    map.fitBounds(cdriftLayer.getBounds(), {maxZoom: 9});
                    cDriftLegend.addTo(map);
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
                            text: textContent + "(" + e.latlng.lng.toFixed(4) + "," + e.latlng.lat.toFixed(4) + ")",
                            css: {fontSize: "16px", }
                        }).appendTo(popup);
                        popup.appendTo("#map");
                    }
                });

                //poly line
                var polylinePoints = [
                    new L.latLng(3.7589, 91.7956),
                    new L.LatLng(3.6532,91.9529),
                    new L.LatLng(3.5639, 92.0885),
                ];
                var polylineOptions = {
                    color: 'red',
                    weight: 6,
                    opacity: 5
                };
                var polyline = new L.Polyline(polylinePoints, polylineOptions);
                map.addLayer(polyline);
                map.fitBounds(polyline.getBounds());
                polyline.bringToFront();
               
                var points = [
                    [3.7589, 91.7956],
                    [3.6532,91.9529],
                    [3.5639, 92.0885]
                ];
                for (var i = 0; i < points.length; i++) {
                    marker = new L.marker([points[i][0], points[i][1]])
                            .addTo(map);
                }
                var marker1 = L.marker([3.7589, 91.7956]).bindPopup("23rd 13:05").addTo(map);
                var marker2 = L.marker([3.6532,91.9529]).bindPopup("24th 20:17").addTo(map);
                var marker3 = L.marker([3.5639, 92.0885]).bindPopup("25th 18:35").addTo(map);
             

            }//]]> 
        </script>
        <style>
            .legend ul{
                padding: 0; list-style: none;
            }
            .legend li{
                padding: 5px;   
                color:white;
                font-weight: bold;
            }
            .legend h3{
                background-color:white;
            }
            .legend li.p01{
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
            }
        </style>
    </head>
    <body>

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

        <div style="float:center;width:100%;padding: 0px">
            <div id="map" style="height:100%; width:100%;"></div>
        </div>            
    </body>
</html>