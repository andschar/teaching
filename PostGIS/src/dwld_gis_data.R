# Script to download sample data

# setup -------------------------------------------------------------------
require(RPostgreSQL)
require(andmisc)
datadir = 'PostGIS/data/geo'

# Sites -------------------------------------------------------------------
q = "SELECT * FROM tagli.wi6_sites;"
tagli_sites = andmisc::read_sf(q, dbname = 'monitoring',
                               cred_file = 'cred/credentials.sh')
st_write(tagli_sites, file.path(datadir, 'tagliamento_sites.gpkg'),
         append = FALSE)

# River -------------------------------------------------------------------
q = "SELECT fid, rex AS country, length, pente, strahler, (ST_Dump(ST_Force2D(geom))).geom geom
     FROM tagli.tagli_rw_euhydro;"
tagli_river = andmisc::read_sf(q, dbname = 'monitoring',
                               cred_file = 'cred/credentials.sh')
# write
st_write(tagli_river, file.path(datadir, 'tagliamento_river.gpkg'),
         append = FALSE)

# Basin -------------------------------------------------------------------
q = "SELECT fid, namebasin, (ST_Dump(ST_Force2D(geom))).geom geom
     FROM tagli.tagli_rw_euhydro_basin;"
tagli_basin = andmisc::read_sf(q, dbname = 'monitoring',
                               cred_file = 'cred/credentials.sh')
# write
st_write(tagli_basin, file.path(datadir, 'tagliamento_basin.gpkg'),
         append = FALSE)

# Palar River -------------------------------------------------------------
fid = c(1194653, 1194668, 1194670, 1194678, 1194708, 1194718, 1194730, 1194755, 1194764, 1194771, 1194717, 1194765, 1194782, 1194790, 1194824, 1194788, 1194813, 1194820)
q = paste0(
  "SELECT fid, length, pente, strahler, (ST_Dump(ST_Force2D(geom))).geom geom
   FROM tagli.tagli_rw_euhydro
   WHERE fid IN ('", paste0(fid, collapse = "', '"), "');"
)
palar_river = andmisc::read_sf(q, dbname = 'monitoring',
                                cred_file = 'cred/credentials.sh')
# write
st_write(palar_river, file.path(datadir, 'palar_river.gpkg'),
         append = FALSE)

# Palar CORINE ------------------------------------------------------------
q = "WITH tmp AS (
      SELECT code_18, ST_Intersection(ST_Buffer(ST_ENvelope(bas.geom), 10000), cor.geom) geom
      FROM
      	corine.corine18_vec cor,
      	(SELECT fid, geom
      	 FROM tagli.tagli_rw_euhydro
      	 WHERE fid = 1194678) bas
      WHERE ST_DWithin(ST_Envelope(bas.geom), cor.geom, 10000)
     )
     SELECT tmp.code_18, label1 AS label, geom
     FROM tmp
     INNER JOIN corine.corine18_meta met ON tmp.code_18 = met.code_18"

palar_corine = andmisc::read_sf(q, dbname = 'monitoring',
                                cred_file = 'cred/credentials.sh')
# write
st_write(palar_corine, file.path(datadir, 'palar_corine.gpkg'),
         append = FALSE)

