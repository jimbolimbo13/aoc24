SELECT 'Hello World';

CREATE TEMP TABLE left_side AS
select split_part(values, ' ', 1) as point from day1
order by point;

CREATE TEMP TABLE right_side AS
select split_part(values, ' ', 4) as point from day1
order by point;

SELECT SUM( ABS(rpoint::int - lpoint::int) ) as distance
FROM (
  SELECT row_number() OVER (), point AS lpoint
  from left_side
) AS ls
INNER JOIN(
  SELECT row_number() OVER (), point as rpoint
  FROM right_side
) as rs
  USING (row_number);
