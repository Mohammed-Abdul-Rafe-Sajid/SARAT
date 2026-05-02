<%-- 
    Document   : output
    Created on : Oct 30, 2015, 12:44:02 PM
    Author     : Administrator
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<html>
    <head>
        <title>SARAT Main Page</title>
        <meta charset="UTF-8">
        <!--        <script src="Js/Registrionvalidation.js"></script>-->
        <link rel="stylesheet" href="Css/bootstrap.min.css">
        <link rel="stylesheet" href="Css/Menustyles.css">
        <link rel="stylesheet" href="Css/jquery-ui.css" />
        <script src="Js/jquery-1.10.2.js"></script>
        <script type="text/javascript" src="Js/leaflet.js"></script>
        <script src="Js/leaflet-google.js"></script>
        <script type="text/javascript" src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCn8bdFcjTW0M9y4wq14ejGdBk-I5S_qtc&sensor=false&region=IN"></script>
        <script src="Js/jquery-ui.js"></script>      
        <link rel="stylesheet" type="text/css" href="Css/jquery.datetimepicker.css"/>
        <link rel="stylesheet" type="text/css" href="Css/leaflet.css">
        <link rel="stylesheet" type="text/css" href="Css/style.css" >
        <script src="Js/validation.js"></script>
        <script src="Js/script.js"></script>
        <script type="text/javascript">
            /* required fields to DMS to DD convertion*/
            var latsign = 1;
            var lonsign = 1;
            var absdlat = 0;
            var absdlon = 0;
            var absmlat = 0;
            var absmlon = 0;
            var absslat = 0;
            var absslon = 0;
            
            /* function to convert DMS to DD*/
            function DD_cal() {
                input_form.latitude.value = Math.round(absdlat + (absmlat / 60) + (absslat / 3600)) * latsign / 1000000;
                input_form.longitude.value = Math.round(absdlon + (absmlon / 60) + (absslon / 3600)) * lonsign / 1000000;
                updateMap();
                latsign = 1;
                lonsign = 1;
            }
            
            $(function() {
                $("#From_date").tooltip({
                    position: {
                    my: "left left",
                            at: "right left",
                            collision: "none"
                    }
                });
            });
            
            $(function() {
                $("#object").selectmenu({
                    open: function(event, ui) {
                        $('#object-menu li.ui-menu-item').tooltip({
                            items:'li',
                            content:function(){
                                //console.log($(this).html());
                                var t = $(this).html();
                                return ($('#object option').filter(function () { return $(this).html() == t; }).attr('title'));
                            }
                        });
                    },
                    change: function(event, ui) {
                        $("#object").val(ui.item.value);
                    }
                }).selectmenu("menuWidget").addClass("overflow"); ;
            });

            function check(){
                input_form.slat.value = Math.abs(Math.round(input_form.slat.value * 1000000) / 1000000);
                absslat = Math.abs(Math.round(input_form.slat.value * 1000000)); // Note: kept as big integer for now, even if submitted as decimal
                if (absslat > (59.99999999 * 1000000)) {  alert(  "Minutes Latitude must be 0 or greater \n and less than 60."  ); input_form.slat.value = ''; }
            }
            function check1(){
                if (input_form.dlon.value < 0)  { lonsign = - 1; }
                absdlon = Math.abs(Math.round(input_form.dlon.value * 1000000));
                //Math.round is used to eliminate the small error caused by rounding in the computer:
                //e.g. 0.2 is not the same as 0.20000000000284
                //Error checks
                if (absdlon > (180 * 1000000)) { 
                    alert( ' Degrees Longitude must be in the range of - 180 to 180. ' );
                    input_form.dlon.value = ' ' ;
                    input_form.mlon.value = ' ' ;
                }                                                  
            }
            function check2(){
                input_form.mlon.value = Math.abs(Math.round(input_form.mlon.value * 1000000) / 1000000); 
                absmlon = Math.abs(Math.round(input_form.mlon.value * 1000000)); 
                //Error checks
                if (absmlon > (60 * 1000000))   {
                    alert( ' Minutes Longitude must be in the range of 0 to 59. ' );
                    input_form.mlon.value = ' ' ;
                    input_form.slon.value = ' ' ;
                }                                                         
            }
            function check3(){
                input_form.slon.value = Math.abs(Math.round(input_form.slon.value * 1000000) / 1000000);
                absslon = Math.abs(Math.round(input_form.slon.value * 1000000)); // Note: kept as big integer for now, even if submitted as decimal
                //Error checks
                if (absslon > (59.99999999 * 1000000)) {
                    alert( ' Minutes Latitude must be 0 or greater \n and less than 60. ' );
                    input_form.slon.value = ' ';
                }                                                          
            }
            function check4(){                
                if (input_form.dlat.value < 0)  { latsign = - 1; }
                absdlat = Math.abs(Math.round(input_form.dlat.value * 1000000));
                //Math.round is used to eliminate the small error caused by rounding in the computer:
                //e.g. 0.2 is not the same as 0.20000000000284

                //Error checks
                if (absdlat > (90 * 1000000)) {
                    alert( ' Degrees Latitude must be in the range of - 90 to 90. ' );
                    input_form.dlat.value = ' ' ;
                    input_form.dlat.value = ' ' ;
                    input_form.mlat.value = ' ' ;
                }                                                  
            }
            function check5(){
                input_form.mlat.value = Math.abs(Math.round(input_form.mlat.value * 1000000) / 1000000);
                absmlat = Math.abs(Math.round(input_form.mlat.value * 1000000)); 
                //Error checks
                if (absmlat >  (60 * 1000000)) {
                    alert( ' Minutes Latitude must be in the range of 0 to 59. ' );
                    input_form.mlat.value = ' ' ;
                    input_form.slat.value = ' ' ;
                }
            }
            function check6(){}
        </script>
        <script type="text/javascript">
            var marker = null, map = null;
            
            /* adding days to exitsed Date*/
            window.onload = function () {
                $("#atrb").tooltip({
                    content: function () {
                        return $(this).prop('title');
                    },
                    position: {my: "right", at: "left center"}
                });
                map = L.map('map', {crs: L.CRS.EPSG4326}).setView([20, 77], 4);
                map.setMaxBounds([
                    [ - 10, - 74.30],
                    [27, 120]
                ]);
                map.options.maxZoom = 18;
                map.options.minZoom = 4;
                map.scrollWheelZoom.disable();
                var googleLayer = new L.Google('ROADMAP');
                map.addLayer(googleLayer);
                function onMapClick(e) {
                    var lat = e.latlng.lat;
                    var lng = e.latlng.lng;
                    var icon = new L.Icon.Default();
                    icon.options.shadowSize = [0, 0]; //deleting shadow
                    if (marker != null) {
                        map.removeLayer(marker);
                    }
                    marker = L.marker([lat, lng], {icon: icon}).addTo(map);
                    map.addLayer(marker);
                    document.getElementById('latitude').value = lat.toFixed(5);
                    document.getElementById('longitude').value = lng.toFixed(5);
                    map.setView([lat, lng], 7);
                }
                map.on('click', onMapClick);
            }
            
            function updateMap() {
                var lat = document.getElementById('latitude').value;
                var lng = document.getElementById('longitude').value;
                var icon = new L.Icon.Default();
                icon.options.shadowSize = [0, 0];
                if (marker != null) {
                    map.removeLayer(marker);
                }
                map.setView([lat, lng], 7);
                marker = L.marker([lat, lng], {icon: icon}).addTo(map);
                map.addLayer(marker);
            }
            
            function map_mouse_Enable() {
                map.on('click', onMapClick);
            }
            
            function map_mouse_Disable() {
                if (marker != null) {
                    map.removeLayer(marker);
                }
                map.off('click');
            }
        </script>
        <script type="text/javascript" src="Js/Latlong.js"></script>  
        <style type="text/css">
            object.decorated option:hover {
                box-shadow: 0 0 10px 100px #1882A8 inset;
            }
            .custom-date-style {
                background-color: red !important;
            }
            .input-wide{
                width: 500px;
            }
            .leaflet-map-pane {
                z-index: 2 !important;
            }
            .leaflet-google-layer {
                z-index: 1 !important;
            }
            td{
                padding-right:7px;
            }
        </style>
    </head>
    <body>
        <div id="background">
            <%@include file="Login_Header.jsp" %>
            <div class="contentpage">
                <div style="margin: 10px;padding: 10px"> 
                    <div id="contents" style="width:100%;align:center">
                        <!-- div for contact page elements -->
                        <div style="width:50%;float:left"> 
                            <br>

                            <center>
                                <div class="panel panel-primary" style="margin-right:20px">
                                    <div class="panel-heading" style="padding-top:5px">
                                        <h3 class="panel-title">
                                            <font style="font-weight:bold;color:white;font-size: 16px;"><fmt:message key="main.panel.object" /></font>
                                        </h3>
                                    </div>
                                </div>
                            </center>

                            <%
                                if ((session.getAttribute("userid") == null) || (session.getAttribute("userid") == "")) {
                            %>
                            <br/>

                            <%         String message = "please login";
                                    response.sendRedirect("login.jsp?message=" + message);
                                    return;
                                }
                            %>
                            <form class="form-horizontal" name="input_form" action="Store" method="post" onsubmit="return checkForm(event)">
                                <fieldset>
                                    <!-- missing object selection -->
                                    <div class="form-group">
                                        <label class="col-md-4 control-label" for="object"><fmt:message key="main.label.object" />:</label>
                                        <div class="col-md-2">
                                            <select id="object" name="object" class="form-control">
                                                <option title="Person-in-water,Unknown state" value="1">Person In Water(PIW-1)</option>
                                                <option title="Person-in-Water.Horisontal,Survival suit" value="4">Person,horisontal,survival suit(PIW-4)</option>
                                                <option title="Person-in-Water.Horisontal,Deceased" value="6">Person ,horisontal,deceased(PIW-6)</option>
                                                <option title="Life-raft,no ballast(NB) system,genral" value="7">LIFE-RAFT-NB1</option>
                                                <option title="Life-raft,no ballast system,no canopy,no drogue" value="8">LIFE-RAFT-NB2</option>
                                                <option title="Life-raft,no ballast system,no canopy,with drogue" value="9">LIFE-RAFT-NB3</option>
                                                <option title="Life-raft,no ballast system,with canopy,no drogue" value="10">LIFE-RAFT-NB4</option>
                                                <option title="Life-raft,no ballast system,with canopy,with drogue" value="11">LIFE-RAFT-NB5</option>
                                                <option title="Life-raft,shallow ballast(SB)system and canopy,general" value="12">LIFE-RAFT-SB6</option>
                                                <option title="Life-raft,shallow ballast(SB)system and canopy,no drogue" value="13">LIFE-RAFT-SB7</option>
                                                <option title="Life-raft,shallow ballast(SB)system and canopy,with drogue" value="14">LIFE-RAFT-SB8</option>
                                                <option title="Life-raft,shallow ballast(SB)system and canopy,Capsized"  value="15">LIFE-RAFT-SB9</option>
                                                <option title="Life-raft,Deep ballast(DB)system,general,unknown capacity and loading" value="16">LIFE-RAFT-DB10</option>
                                                <option title="4-6 person capacity,Deep ballast(DB)system,general" value="17">LIFE-RAFT-DB11</option>
                                                <option title="4-6 person capacity,Deep ballast(DB)system,no drogue" value="18">LIFE-RAFT-DB12</option>
                                                <option title="4-6 person capacity,Deep ballast(DB)system,no drogue,light loading" value="19">LIFE-RAFT-DB13</option>
                                                <option title="4-6 person capacity,Deep ballast(DB)system,no drogue,heavy loading" value="20">LIFE-RAFT-DB14</option>
                                                <option title="4-6 person capacity,Deep ballast(DB)system,with drogue" value="21">LIFE-RAFT-DB15</option>
                                                <option title="4-6 person capacity,Deep ballast(DB)system,with drogue,light loading" value="22">LIFE-RAFT-DB16</option>
                                                <option title="4-6 person capacity,Deep ballast(DB)system,with drogue,Heavy loading" value="23">LIFE-RAFT-DB17</option>
                                                <option title="15-25 person capacity,Deep ballast(DB)system,general" value="24">LIFE-RAFT-DB18</option>
                                                <option title="15-25 person capacity,Deep ballast(DB)system,general,no drogue,light loading" value="25">LIFE-RAFT-DB19</option>
                                                <option title="15-25 person capacity,Deep ballast(DB)system,general,with drogue,heavy loading" value="26">LIFE-RAFT-DB20</option>
                                                <option title="Deep ballest system,general,capsized" value="27">LIFE-RAFT-DB21</option>
                                                <option title="Deep ballest system,general,swamoed" value="28">LIFE-RAFT-DB22</option>
                                                <option title="Life Capsule" value="29">LIFE-CAPSULE</option>
                                                <option title="USCG Sea Rescue Kit" value="30">USCG-RESCUE</option>
                                                <option title="Life-raft,4-6 person capacity,no ballast,with canopy,no drgue" value="31">AVIATION-1</option>
                                                <option title="Evacuation slide with life-raft,46 person capacity" value="32">AVIATION-2</option>
                                                <option title="Sea Kayak with person on aft deck" value="33">SEA-KAYAK</option>
                                                <option title="Surf board with person" value="34">SURF-BOARD</option>
                                                <option title="Windsurfer with mast and sail in water" value="35">WINDSURFER</option>
                                                <option title="Mono-hull,full keel,deep draft" value="36">SAIL-BOAT-1</option>
                                                <option title="Mono-hull,full keel,shoal draft" value="37">SAIL-BOAT-2</option>
                                                <option title="skiff,flat bottom" value="38">SKIFF-1</option>
                                                <option title="skiff,V-hull" value="39">SKIFF-2</option>
                                                <option title="skiff,V-hull,swamped" value="40">SKIFF-3</option>
                                                <option title="sport boat,no canvas(*1),modified v-hull" value="41">SPORT-BOAT</option>
                                                <option title="sport fisher,center console(*2),open cockpit" value="42">SPORT-FISHER</option>
                                                <option title="Fishing vessel,general" value="43">FISHING-VESSEL-1</option>
                                                <option title="Fishing vessel,Hawaiian sampan(*3)" value="44">FISHING-VESSEL-2</option>
                                                <option title="Fishing vessel,Japanee side-stern trawler" value="45">FISHING-VESSEL-3</option>
                                                <option title="Fishing vessel,japanee Longliner(*3)" value="46">FISHING-VESSEL-4</option>
                                                <option title="Fishing vessel,Korean fishing vessel(*4)" value="47">FISHING-VESSEL-5</option>
                                                <option title="Fishing vessel,Gill-netter with real reel(*3)" value="48">FISHING-VESSEL-6</option> 
                                                <option title="Coastel freighter" value="49">COASTEL-FREIGHTER</option>
                                                <option title="Fishing vessel debris" value="50">FV-DEBRIS</option>
                                                <option title="Bait/wharf box,holds a cubic metre of ice" value="51">BAIT-BOX-1</option>
                                                <option title="Bait/wharf box,holds a cubic metre of ice,lightly loaded" value="52">BAIT-BOX_2</option>
                                                <option title="Bait/wharf box,holds a cubic metre of ice,full loaded" value="53">BAIT-BOX_3</option>
                                                <option title="Immigration vessel,Cuban refugee-raft,no sail" value="54">REFUGEE-RAFT-1</option>
                                                <option title="Immigration vessel,Cuban refugee-raft,with sail" value="55">REFUGEE-RAFT-2</option>
                                                <option title="swage floatables,tampon applicator" value="56">SEWAGE</option>
                                                <option title="medical waste" value="57">MED-WASTE-1</option>
                                                <option title="medical waste,vials" value="58">MED-WASTE-2</option>
                                                <option title="medical waste,vials,large" value="59">MED-WASTE-3</option>
                                                <option title="medical waste,vials,small" value="60">MED-WASTE-4</option> 
                                                <option title="medical waste,Syringes" value="61">MED-WASTE-5</option> 
                                                <option title="medical waste,Syringes,large" value="62">MED-WASTE-6</option> 
                                                <option title="medical waste,Syringes,small" value="63">MED-WASTE-7</option> 
                                            </select>
                                        </div>
                                    </div>
                                    <center>
                                        <div class="panel panel-primary" style="margin-right:20px">
                                            <div class="panel-heading" style="padding-top:5px">
                                                <h3 class="panel-title">
                                                    <font style="font-weight:bold;color:white;font-size: 16px;"><fmt:message key="main.panel.time" /></font>
                                                </h3>
                                            </div>
                                        </div>
                                    </center>
                                    <!--<b style="font-size:18px;color:gray;padding-bottom:25px"> Last Known Position:</b><br> -->
                                    <!-- From-Date Field-->
                                    <div class="form-group">
                                        <label class="col-md-4 control-label" for="From_date"><fmt:message key="main.label.lasttime" /> :<font color="red">*</font></label>  
                                        <div class="col-md-2">
                                            <input id="From_date" name="From_date" type="text" placeholder="" class="form-control input-md" required="" title="Date format:YYYY-MM-DD HH:mm:ss" readonly>

                                        </div>
                                    </div>

                                    <!-- To date Field-->
                                    <div class="form-group">
                                        <label class="col-md-4 control-label" for="To_date"><fmt:message key="main.label.searchtime" /> :<font color="red">*</font></label>  
                                        <div class="col-md-2">
                                            <input id="To_date" name="To_date" type="text" placeholder="" class="form-control input-md" required="" title="Date format:YYYY-MM-DD HH:mm:ss" readonly>

                                        </div>
                                    </div>
                                    <center>
                                        <div class="panel panel-primary" style="margin-right:20px">
                                            <div class="panel-heading" style="padding-top:5px">
                                                <h3 class="panel-title">
                                                    <font style="font-weight:bold;color:white;font-size: 16px;"><fmt:message key="main.panel.positon" /></font>
                                                </h3>
                                            </div>
                                        </div>
                                    </center>
                                    <!-- Radio button to check weather knows lat long or not   -->
                                    <div class="form-group">
                                        <label class="col-md-4 control-label" for="place_know"><fmt:message key="main.lablel.latlonknows" />:</label>
                                        <div class="col-md-4"> 
                                            <label class="radio-inline" for="place_know-0">
                                                <input type="radio" name="latlong_know" id="place_know-0" value="latlong_yes" checked="checked">
                                                <fmt:message key="main.radio.yes" />
                                            </label> 
                                            <label class="radio-inline" for="place_know-1">
                                                <input type="radio" name="latlong_know" id="place_know-1" value="latlong_no">
                                                <fmt:message key="main.radio.no" />
                                            </label>
                                        </div>
                                    </div>
                                    <div id="latlong_no">
                                        <!-- state selection -->
                                        <div class="form-group">
                                            <label class="col-md-4 control-label" for="state"><fmt:message key="main.label.state"/><font color="red">*</font></label>
                                            <div class="col-md-2">
                                                <select id="state" name="state" class="form-control">
                                                    <option value="Andhra Pradesh">Andhra Pradesh</option>
                                                    <option value="Goa">Goa</option>
                                                    <option value="Gujarat">Gujarat</option>
                                                    <option value="Karnataka">Karnataka</option>
                                                    <option value="Kerala">Kerala</option>
                                                    <option value="Odissa">odissa</option>
                                                    <option value="Maharashtra">Maharashtra</option>
                                                    <option value="Tamil Nadu">Tamil Nadu</option>
                                                    <option value="West Bengal">West Bengal</option>
                                                    <option value="Andaman Nicobar">Andaman Nicobar</option>
                                                    <option value="Lakshadweep">Lakshadweep</option>
                                                </select>
                                            </div>
                                        </div>
                                        <!-- Landing Center-->
                                        <div class="form-group">
                                            <label class="col-md-4 control-label" for="landingcenter"><fmt:message key="main.label.landingcenter"/><font color="red">*</font></label>
                                            <div class="col-md-2">
                                                <select id="landingcenter" name="landingcenter" class="form-control">
                                                    <option value="Pulinjerikuppam">Pulinjerikuppam</option>
                                                    <option value="Durgarajupatnam">Durgarajupatnam</option>
                                                    <option value="Kondur">Kondur</option>
                                                    <option value="Arkatapalem">Arkatapalem</option>
                                                    <option value="Kottapatnam">Kottapatnam</option>
                                                    <option value="Tammenapatnam">Tammenapatnam</option>
                                                    <option value="Krishnapatnam(Upputeru)">Krishnapatnam(Upputeru)</option>
                                                    <option value="Krishnapatnam">Krishnapatnam</option>
                                                    <option value="Pathapalem">Pathapalem</option>
                                                    <option value="Maipadu">Maipadu</option>
                                                    <option value="Utukuru">Utukuru</option>
                                                    <option value="Pattapupalem">Pattapupalem</option>
                                                    <option value="Isakapalle">Isakapalle</option>
                                                    <option value="Zuvvaladinne">Zuvvaladinne</option>
                                                    <option value="Vatturupallepalem">Vatturupallepalem</option>
                                                    <option value="Ramayapatnam">Ramayapatnam</option>
                                                    <option value="Chakicherla">Chakicherla</option>
                                                    <option value="Itamukkala">Itamukkala</option>
                                                    <option value="Allurukottapatnam">Allurukottapatnam</option>
                                                    <option value="Adavipallipalem">Adavipallipalem</option>
                                                    <option value="Vetapalem">Vetapalem</option>
                                                    <option value="Vadarevu">Vadarevu</option>
                                                    <option value="Bestapalam_Bapatla">Bestapalam_Bapatla</option>
                                                    <option value="Suryalanka">Suryalanka</option>
                                                    <option value="Nizampatnam">Nizampatnam</option>
                                                    <option value="Nachugunta">Nachugunta</option>
                                                    <option value="Etimoga">Etimoga</option>
                                                    <option value="Sorlagondi">Sorlagondi</option>
                                                    <option value="Palakayatippa">Palakayatippa</option>
                                                    <option value="Machilipatnam">Machilipatnam</option>
                                                    <option value="Giripuram">Giripuram</option>
                                                    <option value="Pedda_Gollapalem">Pedda_Gollapalem</option>
                                                    <option value="Narasapur_Pt">Narasapur_Pt</option>
                                                    <option value="Bandamurlanka">Bandamurlanka</option>
                                                    <option value="Karakutippa">Karakutippa</option>
                                                    <option value="Bhairavapalem">Bhairavapalem</option>
                                                    <option value="Kakinada">Kakinada</option>
                                                    <option value="Vakalapudi">Vakalapudi</option>
                                                    <option value="Uppada">Uppada</option>
                                                    <option value="Konapapeta">Konapapeta</option>
                                                    <option value="Perumallanuram">Perumallanuram</option>
                                                    <option value="Danavaipeta">Danavaipeta</option>
                                                    <option value="Pentakota">Pentakota</option>
                                                    <option value="Revu_Polavaram">Revu_Polavaram</option>
                                                    <option value="Rambilli">Rambilli</option>
                                                    <option value="Pudimadaka">Pudimadaka</option>
                                                    <option value="Palmanpeta">Palmanpeta</option>
                                                    <option value="Visakhapatnam">Visakhapatnam</option>
                                                    <option value="Bhimunipatnam">Bhimunipatnam</option>
                                                    <option value="Mukkam">Mukkam</option>
                                                    <option value="Konada">Konada</option>
                                                    <option value="Chintapalli">Chintapalli</option>
                                                    <option value="Ramachandrapuram">Ramachandrapuram</option>
                                                    <option value="Allivalasa">Allivalasa</option>
                                                    <option value="Kuppili">Kuppili</option>
                                                    <option value="Srikurmam">Srikurmam</option>
                                                    <option value="Kalingapatnam">Kalingapatnam</option>
                                                    <option value="Gupparapeta">Gupparapeta</option>
                                                    <option value="Jagannadhapuram">Jagannadhapuram</option>
                                                    <option value="Maruvada">Maruvada</option>
                                                    <option value="Kotta_Naupada">Kotta_Naupada</option>
                                                    <option value="Bavanapadu">Bavanapadu</option>
                                                    <option value="Nuvvalarevu">Nuvvalarevu</option>
                                                    <option value="Metturu">Metturu</option>
                                                    <option value="Ganguvada">Ganguvada</option>
                                                    <option value="Baruva">Baruva</option>
                                                    <option value="Iduvanipalem">Iduvanipalem</option>
                                                    <option value="Kaviti">Kaviti</option>
                                                    <option value="Sonnapurampeta">Sonnapurampeta</option>

                                                </select>
                                            </div>
                                        </div>
                                        <!-- Traveled Distance -->
                                        <div class="form-group">
                                            <label class="col-md-4 control-label" for="traveled_distance"><fmt:message key="main.label.distance" />:<font color="red">*</font></label>  
                                            <div class="col-md-2">
                                                <input id="traveled_distance" name="traveled_distance" type="text" placeholder="" class="form-control input-md"> 
                                            </div>
                                        </div>
                                        <!-- Bearing angle-->
                                        <div class="form-group">
                                            <label class="col-md-4 control-label" for="angle"><fmt:message key="main.label.angle" />:<font color="red">*</font></label>  
                                            <div class="col-md-2">
                                                <input id="angle" name="angle" type="text" placeholder="" class="form-control input-md">

                                            </div>
                                        </div>
                                    </div>
                                    <div id="dddms_radio">
                                        <!-- Radio know weather lat longs are in DMS or DD -->
                                        <div class="form-group">
                                            <label class="col-md-4 control-label" for="latlong"><fmt:message key="main.lable.latlonin" />:</label>
                                            <div class="col-md-6">
                                                <div class="radio">
                                                    <label for="latlong-0">
                                                        <input type="radio" name="latlong" id="latlong-0" value="dd" checked="checked">
                                                        <fmt:message key="main.radio.dd" />
                                                    </label>
                                                </div>
                                                <div class="radio">
                                                    <label for="latlong-1">
                                                        <input type="radio" name="latlong" id="latlong-1" value="dms">
                                                        <fmt:message key="main.radio.dms" />
                                                    </label>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div id="ddtodms">                                        
                                        <!-- Degrees Minutes Seconds for latitude -->
                                        <div class="form-group">
                                            <label class="col-md-4 control-label" for="DMSlat"><fmt:message key="main.label.dmslat" />:<font color="red">*</font></label>  
                                            <div class="col-md-2">
                                                <table>
                                                    <tr>
                                                        <td>
                                                            <input class="form-control input-md" name="dlat" type="INT" size="4" value="" maxlength="4" id="DMSlat" placeholder="Deg" style="font-size: 12pt" tabindex="1" onblur="check4();"></td>
                                                        <td><input class="form-control input-md" name="mlat" type="INT" size="4" value="" maxlength="2" placeholder="Min" id="DMSlat" style="font-size: 12pt" tabindex="2" onblur="check5();"></td><td><input class="form-control input-md"  name="slat" type="INT" size="6" value="" placeholder="Sec" maxlength="6" id="DMSlat" style="font-size: 12pt" tabindex="3" onblur="check();">
                                                        </td></tr></table>
                                            </div>
                                        </div>

                                        <!-- Degrees Minutes Seconds for longitude -->
                                        <div class="form-group">
                                            <label class="col-md-4 control-label" for="DMSlat"><fmt:message key="main.label.dmslon" />:<font color="red">*</font></label>  
                                            <div class="col-md-2">
                                                <table>
                                                    <tr>
                                                        <td>
                                                            <input class="form-control input-md" name="dlon" type="INT" size="4" value="" maxlength="4" id="DMSlon" placeholder="Deg"style="font-size: 12pt" tabindex="4" onblur="check1();"></td>
                                                            <td><input class="form-control input-md" name="mlon" type="INT" size="4" value="" maxlength="2" id="DMSlon" placeholder="Min" style="font-size: 12pt" tabindex="5" onblur="check2();"></td>
                                                            <td><input class="form-control input-md" name="slon" type="INT" size="6" value="" maxlength="6" id="DMSlon" placeholder="Sec" style="font-size: 12pt" tabindex="6" onblur="check3();">
                                                        </td></tr></table>
                                            </div>
                                        </div>
                                        
                                        <!-- DMS-DD converter -->
                                        <div class="form-group">
                                            <label class="col-md-4 control-label" for="ddconverter"></label>
                                            <div class="col-md-2">
                                                <button type="button" id="ddconverter" name="ddconverter" class="btn btn-primary" onclick="DD_cal()"><fmt:message key="main.button.caldd" /></button>
                                            </div>
                                        </div>
                                    </div>
                                    <div id="latlong_final">                                        
                                        <!-- Latitude Text field-->
                                        <div class="form-group">
                                            <label class="col-md-4 control-label" for="latitude"><fmt:message key="main.label.latitude" /> :<font color="red">*</font></label>  
                                            <div class="col-md-2">
                                                <input id="latitude" name="latitude" type="text" placeholder="" class="form-control input-md" required="" onchange="updateMap()">
                                            </div>
                                        </div>

                                        <!-- Longitude Text Field-->
                                        <div class="form-group">
                                            <label class="col-md-4 control-label" for="longitude"><fmt:message key="main.label.longitude" /> :<font color="red">*</font></label>  
                                            <div class="col-md-2">
                                                <input id="longitude" name="longitude" type="text" placeholder="" class="form-control input-md" required="" onchange="updateMap()">  
                                            </div>
                                        </div>

                                    </div>
                                    <!-- submitButton -->
                                    <div class="form-group">
                                        <label class="col-md-4 control-label" for="submit"></label>
                                        <div class="col-md-2">
                                            <!-- <button id="submit" name="submit" class="btn btn-success" onclick="return checkForm()"><fmt:message key="main.button.submit" /></button> -->
                                            <button id="submit" name="submit" class="btn btn-success"><fmt:message key="main.button.submit" /></button>
                                        </div>
                                    </div>
                                </fieldset>
                            </form>    </div>
                        <div style="width:50%;float:left;height:600px" id="map"></div>  
                    </div>
                </div>
            </div>
            <script type="text/javascript" src="Js/jquery.datetimepicker.min.js"></script>
            <script type="text/javascript" src="Js/jquery.datetimepicker.full.min.js"></script>
            <script>
                var currentDate = new Date();
                var mindate = new Date();
                var maxdate = new Date();
                maxdate.setDate(maxdate.getDate() + 6)
                //mindate.setDate(mindate.getDate() - 4);
                mindate.setDate(mindate.getDate() - 30);
                
                //let mindatePlus6 = new Date(mindate);
                //mindatePlus6.setDate(mindatePlus6.getDate() + 6);
                var td = currentDate.getDate();
                $('#From_date').datetimepicker({
                    format: 'Y-m-d H:i:00',
                    lang: 'en',
                    step:5,
                    minDate:mindate,
                    maxDate:maxdate,
                    defaultTime: '05:30',
                    //allowTimes: ['05:30', '11:30', '17:30', '23:30'],
                });
                $('#From_date').datetimepicker({value: currentDate.getDate});
                $('#To_date').datetimepicker({
                    format: 'Y-m-d H:i:00',
                    lang: 'en',
                    step:5,
                    maxDate: maxdate,
                    //minDate:new Date(),
                    minDate:mindate ,
                    defaultTime: '05:30',
                    //allowTimes: ['05:30', '11:30', '17:30', '23:30'],
                });
                $('#To_date').datetimepicker({value: currentDate.getDate});

            </script>
            <center>©INCOIS search and Rescue. All Rights Reserved</center>
        </div>

    </body> 
</html>
