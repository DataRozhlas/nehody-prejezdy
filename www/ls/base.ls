data = d3.tsv.parse ig.data.prejezdy, (row) ->
  for field, value of row
    continue if field == "nazev"
    row[field] = parseFloat value
  row.latLng = L.latLng row.lat, row.lon
  row.radius = row.nehod
  row.ratio = (row.usmrceno)# / row.nehod
  row

data .= filter (.ratio)

container = d3.select ig.containers.base
mapElement = container.append \div
  ..attr \class \map

map = L.map do
  * mapElement.node!
  * minZoom: 7,
    maxZoom: 13,
    zoom: 8
    center: [49.78, 15.5]
    maxBounds: [[48.3,11.6], [51.3,19.1]]

baseLayer = L.tileLayer do
  * "https://samizdat.cz/tiles/ton_b1/{z}/{x}/{y}.png"
  * zIndex: 1
    opacity: 0.1
    attribution: 'mapová data &copy; přispěvatelé <a target="_blank" href="http://osm.org">OpenStreetMap</a>, obrazový podkres <a target="_blank" href="http://stamen.com">Stamen</a>, <a target="_blank" href="https://samizdat.cz">Samizdat</a>'

labelLayer = L.tileLayer do
  * "https://samizdat.cz/tiles/ton_l1/{z}/{x}/{y}.png"
  * zIndex: 3
    opacity: 0.5

radiusScale = d3.scale.sqrt!
  ..domain [0 5]
  ..range [24 40]

colorScale = d3.scale.threshold!
  ..domain [1 2 3 4]
  ..range ['rgb(252,146,114)','rgb(251,106,74)','rgb(239,59,44)','rgb(203,24,29)','rgb(165,15,21)','rgb(103,0,13)']


markers = for datum in data
  count = datum.ratio
  color = colorScale datum.ratio
  radius = Math.floor radiusScale count
  if datum.ratio == 0
    radius = 2
  latLng = datum.latLng
  zIndexOffset = (count) * 50
  icon = L.divIcon do
    html: "<div style='background-color: #color;line-height:#{radius}px'><span>#{ig.utils.formatNumber count}</span></div>"
    iconSize: [radius, radius]
  icon = L.divIcon do
    html: "<div style='background-color: #color;line-height:#{radius}px'><span>#{ig.utils.formatNumber count}</span></div>"
    iconSize: [radius, radius]

  marker = L.marker latLng, {icon, zIndexOffset}
    ..addTo map
    ..bindPopup "<b>#{datum.nazev}</b>
    <p>Celkem nehod: <b>#{datum.nehod}</b><br></p>
    <p>Při nich zraněno</p>
    <pre>Lehce: <b>#{datum.lehce}</b><br>
    Těžce: <b>#{datum.tezce}</b><br>
    Smrtelně: <b>#{datum.usmrceno}</b></pre>"


trate = topojson.feature do
  ig.data.trate
  ig.data.trate.objects.trate

trateLayer = L.geoJson do
  * trate
  * style: ->
    opacity: 1
    color: \black
    dashArray: "6,8"
    weight: 2
    clickable: no
trateLayer.addTo map
baseLayer.addTo map
labelLayer.addTo map

geocoder = new ig.Geocoder mapElement.node!
  ..on \latLng (latlng) ->
    map.setView latlng, 12
