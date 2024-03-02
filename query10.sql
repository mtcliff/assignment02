/*10. You're tasked with giving more contextual information to rail stops to fill the `stop_desc` 
field in a GTFS feed. Using any of the data sets above, PostGIS functions (e.g., `ST_Distance`, `ST_Azimuth`, etc.), 
and PostgreSQL string functions, build a description (alias as `stop_desc`) for each stop. 
Feel free to supplement with other datasets (must provide link to data used so it's reproducible), 
and other methods of describing the relationships. SQL's `CASE` statements may be helpful for some operations.

    **Structure:**
    ```sql
    (
        stop_id integer,
        stop_name text,
        stop_desc text,
        stop_lon double precision,
        stop_lat double precision
    )
    ```

   As an example, your `stop_desc` for a station stop may be something like "37 meters NE of 1234 Market St" 
   (that's only an example, feel free to be creative, silly, descriptive, etc.)

   >**Tip when experimenting:** Use subqueries to limit your query to just a few rows to keep query times faster. 
   Once your query is giving you answers you want, scale it up. E.g., instead of `FROM tablename`, 
   use `FROM (SELECT * FROM tablename limit 10) as t`.

    I found this csv of Wawa locations from user kamine93_rowanuniversity on ArcGIS Online, dated December 18, 2023.
    https://www.arcgis.com/home/item.html?id=3c7936f5e9744882a76e02867f25e9e7
    Direct download link: https://www.arcgis.com/sharing/rest/content/items/3c7936f5e9744882a76e02867f25e9e7/data
    Note: I believe these locations are a little out of date (based on my personal knowledge
    of Wawa locations in Center City.)
*/

select
    rail.stop_id::integer,
    rail.stop_name,
    concat(round(st_distance(wawa.geog, rail.geog))::text, 
        ' meters ',
        CASE
            WHEN az >= 0 AND az < 22.5 THEN 'N'
            WHEN az >= 22.5 AND az < 67.5 THEN 'NE'
            WHEN az >= 67.5 AND az < 112.5 THEN 'E'
            WHEN az >= 112.5 AND az < 157.5 THEN 'SE'
            WHEN az >= 157.5 AND az < 202.5 THEN 'S'
            WHEN az >= 202.5 AND az < 247.5 THEN 'SW'
            WHEN az >= 247.5 AND az < 292.5 THEN 'W'
            WHEN az >= 292.5 AND az < 337.5 THEN 'NW'
            ELSE 'N'
        END,
        ' from the nearest Wawa.') as stop_desc,
    rail.stop_lon,
    rail.stop_lat
from septa.rail_stops as rail
cross join lateral (
    select 
        wawa.geog, 
        wawa.geog <-> rail.geog as distance, 
        degrees(st_azimuth(wawa.geog, rail.geog)) as az
    from wawa.locations as wawa
    order by distance
    limit 1
) wawa
order by distance