include(ts/utils/common.ts)

$(MAKE_SIMPLE_FLIGHT_DEFAULT_PASSENGERS airp_dep_lat=AER airp_arv_lat=DME)

$(db_sql PAX COMMIT)
