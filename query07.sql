/*
What are the _bottom five_ neighborhoods according to your accessibility metric?
*/

select
    hoods.listname::text as neighborhood_name,
    count(case stops.wheelchair_boarding when 1 then 1 end)::integer as num_bus_stops_accessible,
    count(case stops.wheelchair_boarding when 2 then 1 end)::integer as num_bus_stops_inaccessible,
    round((
        count(case stops.wheelchair_boarding when 1 then 1 end)::numeric
        / count(stops.stop_id)::numeric
    )
    * ((count(stops.stop_id) / hoods.shape_area) * 1000000)::numeric, 2) as accessibility_metric
from septa.bus_stops as stops
inner join azavea.neighborhoods as hoods
    on st_coveredby(stops.geog, hoods.geog)
group by neighborhood_name, hoods.shape_area
order by accessibility_metric
limit 5;
