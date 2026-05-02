(function($) {

  $.fn.menumaker = function(options) {
      
      var cssmenu = $(this), settings = $.extend({
        title: "Menu",
        format: "dropdown",
        sticky: false
      }, options);

      return this.each(function() {
        cssmenu.prepend('<div id="menu-button">' + settings.title + '</div>');
        $(this).find("#menu-button").on('click', function(){
          $(this).toggleClass('menu-opened');
          var mainmenu = $(this).next('ul');
          if (mainmenu.hasClass('open')) { 
            mainmenu.hide().removeClass('open');
          }
          else {
            mainmenu.show().addClass('open');
            if (settings.format === "dropdown") {
              mainmenu.find('ul').show();
            }
          }
        });

        cssmenu.find('li ul').parent().addClass('has-sub');

        multiTg = function() {
          cssmenu.find(".has-sub").prepend('<span class="submenu-button"></span>');
          cssmenu.find('.submenu-button').on('click', function() {
            $(this).toggleClass('submenu-opened');
            if ($(this).siblings('ul').hasClass('open')) {
              $(this).siblings('ul').removeClass('open').hide();
            }
            else {
              $(this).siblings('ul').addClass('open').show();
            }
          });
        };

        if (settings.format === 'multitoggle') multiTg();
        else cssmenu.addClass('dropdown');

        if (settings.sticky === true) cssmenu.css('position', 'fixed');

        resizeFix = function() {
          if ($( window ).width() > 768) {
            cssmenu.find('ul').show();
          }

          if ($(window).width() <= 768) {
            cssmenu.find('ul').hide().removeClass('open');
          }
        };
        resizeFix();
        return $(window).on('resize', resizeFix);

      });
  };
})(jQuery);

(function($){
$(document).ready(function(){

$("#cssmenu").menumaker({
   title: "Menu",
   format: "multitoggle"
});


});
})(jQuery);

// ============================================
// HEATMAP RENDERING FUNCTIONS
// ============================================

let heatmapGeoLayer = null;

// Color scale for probability heatmap (0-100%)
function getHeatmapColor(probability) {
    const prob = parseFloat(probability) || 0;
    return prob > 70 ? '#800026' :
           prob > 50 ? '#BD0026' :
           prob > 30 ? '#E31A1C' :
           prob > 20 ? '#FC4E2A' :
           prob > 10 ? '#FD8D3C' :
           prob > 5  ? '#FEB24C' :
           prob > 1  ? '#FED976' :
                       '#FFEDA0';
}

// Style function for heatmap grid cells
function getHeatmapStyle(feature) {
    return {
        fillColor: getHeatmapColor(feature.properties.probability || 0),
        weight: 1,
        color: 'white',
        fillOpacity: 0.7
    };
}

// Hover tooltip for grid cells
function onHeatmapEachFeature(feature, layer) {
    if (feature.properties && feature.properties.probability !== undefined) {
        const prob = parseFloat(feature.properties.probability).toFixed(2);
        layer.bindTooltip(
            `Probability: ${prob}%`,
            { sticky: true }
        );
    }
}

// Render heatmap GeoJSON grid
function renderHeatmapGeoJSON(data, map) {
    if (heatmapGeoLayer) {
        map.removeLayer(heatmapGeoLayer);
    }

    heatmapGeoLayer = L.geoJSON(data, {
        style: getHeatmapStyle,
        onEachFeature: onHeatmapEachFeature
    }).addTo(map);
    
    // Fit bounds to heatmap
    try {
        const bounds = heatmapGeoLayer.getBounds();
        if (bounds.isValid()) {
            map.fitBounds(bounds, { maxZoom: 9 });
        }
    } catch (e) {
        console.log("Could not fit bounds to heatmap:", e);
    }
}

// Load heatmap from interval GeoJSON file
function loadHeatmapInterval(filepath, map) {
    fetch(filepath)
        .then(response => {
            if (!response.ok) {
                throw new Error('Failed to load heatmap GeoJSON: ' + filepath);
            }
            return response.json();
        })
        .then(data => {
            renderHeatmapGeoJSON(data, map);
        })
        .catch(error => {
            console.error('Error loading heatmap:', error);
            alert('Failed to load heatmap data: ' + error.message);
        });
}

// Add heatmap legend
function addHeatmapLegend(map) {
    const legend = L.control({ position: 'bottomright' });
    
    legend.onAdd = function() {
        const div = L.DomUtil.create('div', 'info legend');
        const grades = [0, 1, 5, 10, 20, 30, 50, 70];
        
        div.innerHTML = '<div style="background-color: white; padding: 10px; border-radius: 5px;"><strong>Probability %</strong><br>';
        
        for (let i = 0; i < grades.length; i++) {
            const color = getHeatmapColor(grades[i]);
            div.innerHTML += `<i style="background:${color}; width: 18px; height: 18px; display: inline-block; margin-right: 5px; border: 1px solid #999;"></i> ${grades[i]}+<br>`;
        }
        
        div.innerHTML += '</div>';
        return div;
    };
    
    legend.addTo(map);
}
