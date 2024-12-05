SELECT 'Hello World';

CREATE TEMP TABLE left_side AS
select split_part(values, ' ', 1) as point from day1
order by point;

CREATE TEMP TABLE right_side AS
select split_part(values, ' ', 4) as point from day1
order by point;

CREATE TEMP TABLE similarities AS
SELECT ls.point::int as left_val, COUNT(rs.point)  as right_count
FROM left_side AS ls
LEFT JOIN right_side AS rs
ON ls.point = rs.point
GROUP BY ls.point;

SELECT SUM( ABS(rpoint::int - lpoint::int) ) as part1_solution
FROM (
  SELECT row_number() OVER (), point AS lpoint
  from left_side
) AS ls
INNER JOIN(
  SELECT row_number() OVER (), point as rpoint
  FROM right_side
) as rs
  USING (row_number);

SELECT SUM(left_val * right_count) as part2_solution
FROM similarities;
