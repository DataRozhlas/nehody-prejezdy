require! fs
prejezdyAssoc = {}
fs.readFileSync '#__dirname/../data/nehody-prejezdy-filtered.tsv'
  .toString!
  .replace /\r/g ''
  .split "\n"
  .forEach (row, i) ->
    return unless i
    [obeti_usmr, obeti_lehc, obeti_tezc, prejezd_id] = row.split "\t"
    prejezdyAssoc[prejezd_id] ?= {usmr:0, lehc:0, tezc:0, nehody:0}
    prejezdyAssoc[prejezd_id].nehody++
    prejezdyAssoc[prejezd_id].usmr += parseInt obeti_usmr,10
    prejezdyAssoc[prejezd_id].lehc += parseInt obeti_lehc,10
    prejezdyAssoc[prejezd_id].tezc += parseInt obeti_tezc,10

# console.log prejezdyAssoc


prejezdy = fs.readFileSync '#__dirname/../data/prejezdy-dec.tsv'
  .toString!
  .replace /\r/g ''
  .split "\n"
  .map (row, i) ->
    if i == 0
      return "id\tnazev\tlat\tlon\tnehod\tlehce\ttezce\tusmrceno"
    fields = row.split '\t'
    [id, nazev_usek, km, trolej, kom_trida, kom_cislo, nazev_mistni, _, _, lat, lon] = fields
    return null if prejezdyAssoc[id] is void
    [id, nazev_mistni || nazev_usek, lat, lon, prejezdyAssoc[id].nehody, prejezdyAssoc[id].lehc, prejezdyAssoc[id].tezc, prejezdyAssoc[id].usmr].join "\t"
  .filter -> it isnt null
  .join "\n"

fs.writeFileSync do
  "#__dirname/../data/prejezdy-out.tsv"
  prejezdy
