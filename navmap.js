
var lat = 30.00;
var lon =  2.50;

var projused = new ol.proj.Projection({
   code: 'EPSG:3857',
   extent: [-20026376.39, -20048966.10, 20026376.39, 20048966.10]
});

//------------------------------------------------------------
//                  Background layers       
//------------------------------------------------------------
var osm   = new ol.layer.Tile({source: new ol.source.OSM()});
var toner = new ol.layer.Tile({source: new ol.source.Stamen({layer: 'toner'})});
var water = new ol.layer.Tile({source: new ol.source.Stamen({layer: 'watercolor'})});

//------------------------------------------------------------
//                     Edwin lagen
//------------------------------------------------------------
var wikinl  = new ol.layer.Vector({
  source: new ol.source.Vector({
    url: 'http://wiki.wisze.net/lib/exe/fetch.php/nl/sitemap.kml',
    dataProjection: 'EPSG:4326',
    format: new ol.format.KML(),
    visible: true
  })
});
wikinl.set('name', 'Wiki NL');
wikinl.set('baselayer', false);

var wikien  = new ol.layer.Vector({
  source: new ol.source.Vector({
    url: 'http://wiki.wisze.net/lib/exe/fetch.php/en/sitemap.kml',
    dataProjection: 'EPSG:4326',
    format: new ol.format.KML(),
    visible: true
  })
});
wikien.set('name', 'Wiki EN');
wikien.set('baselayer', false);

//------------------------------------------------------------
//                     Satnav lagen
//------------------------------------------------------------
var waypoints  = new ol.layer.Image({
  source: new ol.source.ImageWMS({
    url: 'http://wold.xs4all.nl/cgi-bin/mapserv?map=/var/www/html/edwin/edwin.map&service=wms&',
    params: {
      'LAYERS': 'Waypoints',
      'FORMAT': 'image/png'
    },
    projection: projused,
    serverType: /** @type {ol.source.WMSServerType} */ ('mapserver')
  })
});
waypoints.set('name', 'Waypoints');
waypoints.set('baselayer', false);

var tracks  = new ol.layer.Image({
  source: new ol.source.ImageWMS({
    url: 'http://wold.xs4all.nl/cgi-bin/mapserv?map=/var/www/html/edwin/edwin.map&service=wms&',
    params: {
      'LAYERS': 'Tracks',
      'FORMAT': 'image/png'
    },
    projection: projused,
    serverType: /** @type {ol.source.WMSServerType} */ ('mapserver')
  })
});
waypoints.set('name', 'Tracks');
waypoints.set('baselayer', false);

var trackpoints  = new ol.layer.Image({
  source: new ol.source.ImageWMS({
    url: 'http://wold.xs4all.nl/cgi-bin/mapserv?map=/var/www/html/edwin/edwin.map&service=wms&',
    params: {
      'LAYERS': 'Trackpoints',
      'FORMAT': 'image/png'
    },
    projection: projused,
    serverType: /** @type {ol.source.WMSServerType} */ ('mapserver')
  })
});
trackpoints.set('name', 'Trackpoints');
trackpoints.set('baselayer', false);

var activity  = new ol.layer.Image({
  source: new ol.source.ImageWMS({
    url: 'http://wold.xs4all.nl/cgi-bin/mapserv?map=/var/www/html/edwin/edwin.map&service=wms&',
    params: {
      'LAYERS': 'Activity',
      'FORMAT': 'image/png'
    },
    projection: projused,
    serverType: /** @type {ol.source.WMSServerType} */ ('mapserver')
  })
});
activity.set('name', 'Activity');
activity.set('baselayer', false);

var elevation  = new ol.layer.Image({
  source: new ol.source.ImageWMS({
    url: 'http://wold.xs4all.nl/cgi-bin/mapserv?map=/var/www/html/edwin/edwin.map&service=wms&',
    params: {
      'LAYERS': 'Elevation',
      'FORMAT': 'image/png'
    },
    projection: projused,
    serverType: /** @type {ol.source.WMSServerType} */ ('mapserver')
  })
});
elevation.set('name', 'Elevation');
elevation.set('baselayer', false);

var beidou_used  = new ol.layer.Image({
  source: new ol.source.ImageWMS({
    url: 'http://wold.xs4all.nl/cgi-bin/mapserv?map=/var/www/html/edwin/beidou.map&service=wms&',
    params: {
      'LAYERS': 'Used',
      'FORMAT': 'image/png'
    },
    projection: projused,
    serverType: /** @type {ol.source.WMSServerType} */ ('mapserver')
  })
});
beidou_used.set('name', 'Used');
beidou_used.set('baselayer', false);

var beidou_points  = new ol.layer.Image({
  source: new ol.source.ImageWMS({
    url: 'http://wold.xs4all.nl/cgi-bin/mapserv?map=/var/www/html/edwin/beidou.map&service=wms&',
    params: {
      'LAYERS': 'BeidouPoints',
      'FORMAT': 'image/png'
    },
    projection: projused,
    serverType: /** @type {ol.source.WMSServerType} */ ('mapserver')
  })
});
beidou_points.set('name', 'BeidouPoints');
beidou_points.set('baselayer', false);
//------------------------------------------------------------
//                       The map
//------------------------------------------------------------
// var layerlist = [ osm, trackpoints, waypoints ];
// var navmaplayers = [ osm, activity, trackpoints, waypoints ];
var edwinlayers  = [ water, wikinl, wikien ];
var navmaplayers = [ toner, activity, tracks, trackpoints, waypoints ];
var beidoulayers = [ osm, beidou_used, beidou_points ];
var heightlayers = [ osm, elevation, tracks, trackpoints, waypoints ];

var overview = new ol.View({ projection: projused,
                 center: [0, 0], zoom: 2 })

var map = new ol.Map({
   target: 'map',
   layers: navmaplayers,
   controls: ol.control.defaults().extend([ new ol.control.ScaleLine() ]),
   view: overview
});

//------------------------------------------------------------
//              Page functionality
//------------------------------------------------------------
map.onclick = layers;
function layers(e,topic) {

  // if (e.style.color == 'red') {
  //   e.style.color = 'black';
  //   if (topic == 'overview')  { map.removeLayer(trackpoints); }
  //   if (topic == 'beidou')    { map.removeLayer(beidou);}
  //   if (topic == 'elevation') { map.removeLayer(elevation); }
  //   map.removeLayer(waypoints);
  //   map.addLayer(waypoints);
  //   map.render();
  // } else {
  //   e.style.color = 'red';
  if (topic == 'edwin')     {map.setLayerGroup(new ol.layer.Group({layers: edwinlayers}));}
  if (topic == 'overview')  {map.setLayerGroup(new ol.layer.Group({layers: navmaplayers}));}
  if (topic == 'beidou')    {map.setLayerGroup(new ol.layer.Group({layers: beidoulayers}));}
  if (topic == 'elevation') {map.setLayerGroup(new ol.layer.Group({layers: heightlayers}));}
  map.render();
  // }
}
