require! fs

fs.writeFileSync do
  "#__dirname/../data/prejezdy-dec.tsv"
  fs.readFileSync '#__dirname/../data/seznam-prejezdu-szdc.tsv'
    .toString!
    .replace /\r/g ''
    .split "\n"
    .filter -> it.length
    .map (row, i) ->
      if i == 0
        return row
      fields = row.split '\t'
      lat = fields[7]
      lon = fields[8]
      if fields.length < 9
        console.log row
      # console.log fields
      [latDec, lonDec] = for coord in [lat, lon]
        if coord.match /([\.0-9]+)° ?([\.0-9]+)' ?([\.0-9]+)''/
          [deg, min, sec] = that.slice 1 .map parseFloat
          (deg + min / 60 + sec / 3600).toFixed 5
        else
          console.log "FAIL"
          console.log coord
      fields.push latDec, lonDec
      fields.join "\t"
    .join "\n"

