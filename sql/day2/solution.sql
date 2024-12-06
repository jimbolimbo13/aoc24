\set ON_ERROR_STOP 1

CREATE TEMP TABLE indexed_test AS
SELECT row_number() OVER () AS report, string_to_array(values, ' ') as values
FROM day2;

CREATE TEMP TABLE indexed AS
SELECT report, array(select CAST(unnest(values) AS INTEGER) ) as values
FROM indexed_test;


CREATE OR REPLACE FUNCTION day2_is_safe(a integer, b integer, incr boolean, decr boolean) RETURNS boolean AS $$
BEGIN
IF b IS NULL THEN
   RETURN TRUE;
ELSE
   RETURN (ABS(a - b) BETWEEN 1 AND 3) AND ( (a - b) < 0) = incr AND ( (a - b) > 0 ) = decr;
END IF;
END;
$$ LANGUAGE plpgsql;

-- a little on-the-fly testing
do $$
BEGIN
  ASSERT day2_is_safe(1, 3, TRUE, FALSE); 
  ASSERT NOT day2_is_safe(1, 3, FALSE, TRUE);

  ASSERT day2_is_safe(2, 3, TRUE, FALSE); 
  ASSERT NOT day2_is_safe(1, 1, TRUE, FALSE);
  ASSERT NOT day2_is_safe(1, 5, TRUE, FALSE) ;
  ASSERT day2_is_safe(3, 1, FALSE, TRUE) ;
  ASSERT day2_is_safe(4, 3, FALSE, TRUE) ;

  ASSERT day2_is_safe(4, NULL, TRUE, FALSE) ;
  ASSERT day2_is_safe(4, NULL, FALSE, TRUE) ;
 END$$;


CREATE TEMP TABLE checked_reports AS
WITH RECURSIVE rep(repID, safe, incr, decr, ix) as (
     SELECT root.report,
     	    day2_is_safe( root.values[1], root.values[2]),
     	    (root.values[1] - root.values[2]) < 0,
	    (root.values[1] - root.values[2]) > 0,
	    1 as ix
     FROM indexed as root UNION ALL
     SELECT rep.repID,
     	    day2_is_safe( indexed.values[rep.ix + 1], indexed.values[rep.ix + 2], rep.incr, rep.decr),
     	    (indexed.values[rep.ix + 1] - indexed.values[rep.ix + 2]) < 0,
	    (indexed.values[rep.ix + 1] - indexed.values[rep.ix + 2]) > 0,
     	    rep.ix + 1
     FROM indexed JOIN
     	  rep ON indexed.report = rep.repID
	  WHERE indexed.values[rep.ix + 1] IS NOT NULL
)
SELECT *
FROM rep;

CREATE TEMP TABLE unsafe_reports AS 
  SELECT DISTINCT repid
  FROM checked_reports
  WHERE safe = FALSE;

SELECT COUNT( DISTINCT cr.repid) as part1_solution
FROM checked_reports AS cr
LEFT OUTER JOIN unsafe_reports AS ur
ON cr.repid = ur.repid
WHERE ur.repid IS NULL;

--- PART 2 ---


CREATE OR REPLACE FUNCTION day2_mostly_safe(a integer, b integer, c integer, incr boolean, decr boolean) RETURNS boolean AS $$
BEGIN

IF day2_is_safe(a, b, incr, decr) THEN
   RETURN TRUE;
ELSE
   RETURN day2_is_safe(a, c, ((a - c) < 0), ((a - c) > 0));
END IF;

END;
$$ LANGUAGE plpgsql;


do $$
BEGIN

ASSERT day2_mostly_safe(1, 2, 3, TRUE, FALSE);
ASSERT day2_mostly_safe(1, 1, 3, FALSE, FALSE);
ASSERT day2_mostly_safe(1, 5, 3, TRUE, FALSE);
ASSERT day2_mostly_safe(2, 1, 3, FALSE, TRUE);

ASSERT day2_mostly_safe(5, 1, 3, FALSE, TRUE);
ASSERT day2_mostly_safe(3, 1, 3, FALSE, TRUE);
ASSERT NOT day2_mostly_safe(3, 3, 3, FALSE, FALSE);

ASSERT NOT day2_mostly_safe(7, 3, 3, FALSE, TRUE);
ASSERT NOT day2_mostly_safe(3, 3, 3, FALSE, FALSE);
ASSERT NOT day2_mostly_safe(3, 3, 3, FALSE, FALSE);

END$$;


CREATE TEMP TABLE mostly_checked_reports AS
WITH RECURSIVE rep(repID, safe, incr, decr, ix) as (
     SELECT root.report,
     	    day2_mostly_safe(
		root.values[1],
		root.values[2],
		root.values[3],
		((root.values[1] - root.values[2]) < 0),
		((root.values[1] - root.values[2]) > 0)
		),
	CASE
	    WHEN (NOT day2_is_safe( root.values[1], root.values[2])) AND
     	    day2_mostly_safe(root.values[1],root.values[2],root.values[3],((root.values[1] - root.values[2]) < 0),((root.values[1] - root.values[2]) > 0))
	    THEN (root.values[1] - root.values[3]) < 0
	ELSE
     	    (root.values[1] - root.values[2]) < 0
	END,
	CASE
	    WHEN (NOT day2_is_safe( root.values[1], root.values[2])) AND
     	    day2_mostly_safe(root.values[1],root.values[2],root.values[3],((root.values[1] - root.values[2]) < 0),((root.values[1] - root.values[2]) > 0))
	    THEN (root.values[1] - root.values[3]) > 0
	ELSE
	    (root.values[1] - root.values[2]) > 0
	END,
	CASE
	    WHEN (NOT day2_is_safe( root.values[1], root.values[2])) AND
     	    day2_mostly_safe(root.values[1],root.values[2],root.values[3],((root.values[1] - root.values[2]) < 0),((root.values[1] - root.values[2]) > 0))
	    THEN 2
	ELSE
	    1
	END
     FROM indexed as root UNION ALL
     SELECT rep.repID,

     	    day2_mostly_safe( indexed.values[rep.ix + 1], indexed.values[rep.ix + 2], indexed.values[rep.ix + 3], rep.incr, rep.decr),

	CASE
	    WHEN day2_is_safe( indexed.values[rep.ix + 1], indexed.values[rep.ix + 2], rep.incr, rep.decr) THEN (indexed.values[rep.ix + 1] - indexed.values[rep.ix + 2]) < 0
	    WHEN day2_mostly_safe( indexed.values[rep.ix + 1], indexed.values[rep.ix + 2], indexed.values[rep.ix + 3], rep.incr, rep.decr) THEN (indexed.values[rep.ix + 1] - indexed.values[rep.ix + 3]) < 0
	ELSE
	    (indexed.values[rep.ix + 1] - indexed.values[rep.ix + 2]) < 0
	END,

	CASE
	    WHEN day2_is_safe( indexed.values[rep.ix + 1], indexed.values[rep.ix + 2], rep.incr, rep.decr) THEN (indexed.values[rep.ix + 1] - indexed.values[rep.ix + 2]) > 0
	    WHEN day2_mostly_safe( indexed.values[rep.ix + 1], indexed.values[rep.ix + 2], indexed.values[rep.ix + 3], rep.incr, rep.decr) THEN (indexed.values[rep.ix + 1] - indexed.values[rep.ix + 3]) > 0
	ELSE
	    (indexed.values[rep.ix + 1] - indexed.values[rep.ix + 2]) > 0
	END,

	CASE
	    WHEN day2_is_safe( indexed.values[rep.ix + 1], indexed.values[rep.ix + 2], rep.incr, rep.decr) THEN rep.ix + 1
	    WHEN day2_mostly_safe( indexed.values[rep.ix + 1], indexed.values[rep.ix + 2], indexed.values[rep.ix + 3], rep.incr, rep.decr) THEN rep.ix + 2
	ELSE
	    rep.ix + 1
	END

     FROM indexed JOIN
     	  rep ON indexed.report = rep.repID
	  WHERE indexed.values[rep.ix + 1] IS NOT NULL
)
SELECT *
FROM rep;

-- SELECT * FROM mostly_checked_reports
-- WHERE ix = 1
-- AND safe = FALSE
-- ORDER BY repid, ix;

CREATE TEMP TABLE very_unsafe_reports AS 
  SELECT DISTINCT repid
  FROM mostly_checked_reports
  WHERE safe = FALSE;

SELECT count(*) as very_unsafe_reports_count FROM very_unsafe_reports;

select count(ur.repid) as mostly_safe_reports
FROM unsafe_reports as ur
left outer join very_unsafe_reports vur
on ur.repid = vur.repid
where vur.repid is null;


SELECT COUNT( DISTINCT cr.repid) as part2_solution
FROM mostly_checked_reports AS cr
LEFT OUTER JOIN very_unsafe_reports AS ur
ON cr.repid = ur.repid
WHERE ur.repid IS NULL;

