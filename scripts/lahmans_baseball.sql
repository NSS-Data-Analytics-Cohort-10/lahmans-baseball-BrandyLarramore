-- 1. What range of years for baseball games played does the provided database cover? 


SELECT MIN(yearid) AS min_year, MAX(yearid) AS max_year
FROM collegeplaying
UNION
SELECT MIN(year) AS min_year, MAX(year) AS max_year
FROM homegames
UNION
SELECT MIN(yearid) AS min_year, MAX(yearid) AS max_year
FROM managers
UNION
SELECT MIN(yearid) AS min_year, MAX(yearid) AS max_year
FROM teams
UNION
SELECT MIN(yearid) AS min_year, MAX(yearid) AS max_year
FROM teamshalf
UNION
SELECT MIN(yearid) AS min_year, MAX(yearid) AS max_year
FROM salaries
UNION
SELECT MIN(yearid) AS min_year, MAX(yearid) AS max_year
FROM allstarfull
UNION
SELECT MIN(yearid) AS min_year, MAX(yearid) AS max_year
FROM managershalf
UNION
SELECT MIN(yearid) AS min_year, MAX(yearid) AS max_year
FROM teams
UNION
SELECT MIN(yearid) AS min_year, MAX(yearid) AS max_year
FROM appearances
UNION
SELECT MIN(yearid) AS min_year, MAX(yearid) AS max_year
FROM fieldingofsplit
UNION
SELECT MIN(yearid) AS min_year, MAX(yearid) AS max_year
FROM fielding
UNION
SELECT MIN(yearid) AS min_year, MAX(yearid) AS max_year
FROM pitching
UNION
SELECT MIN(yearid) AS min_year, MAX(yearid) AS max_year
FROM batting
UNION
SELECT MIN(yearid) AS min_year, MAX(yearid) AS max_year
FROM halloffame
UNION
SELECT MIN(yearid) AS min_year, MAX(yearid) AS max_year
FROM awardsshareplayers
UNION
SELECT MIN(yearid) AS min_year, MAX(yearid) AS max_year
FROM awardsplayers
UNION
SELECT MIN(yearid) AS min_year, MAX(yearid) AS max_year
FROM awardsmanagers
UNION
SELECT MIN(yearid) AS min_year, MAX(yearid) AS max_year
FROM awardssharemanagers

--Okay, that's pulling up a lot of different rows. Going to try to consolodate it with a subquery. 
--Also went through and made sure all tables with years were added.
--Also took out college playing year because that wasn't a game table. It's the years they went to college.


SELECT MIN(min_year) AS smallest_year, MAX(max_year) AS largest_year
FROM (
    SELECT MIN(year) AS min_year, MAX(year) AS max_year FROM homegames
    UNION SELECT MIN(yearid) AS min_year, MAX(yearid) AS max_year FROM managers
    UNION SELECT MIN(yearid) AS min_year, MAX(yearid) AS max_year FROM teams
    UNION SELECT MIN(yearid) AS min_year, MAX(yearid) AS max_year FROM teamshalf
    UNION SELECT MIN(yearid) AS min_year, MAX(yearid) AS max_year FROM salaries
    UNION SELECT MIN(yearid) AS min_year, MAX(yearid) AS max_year FROM allstarfull
    UNION SELECT MIN(yearid) AS min_year, MAX(yearid) AS max_year FROM managershalf
    UNION SELECT MIN(yearid) AS min_year, MAX(yearid) AS max_year FROM teams
    UNION SELECT MIN(yearid) AS min_year, MAX(yearid) AS max_year FROM appearances
    UNION SELECT MIN(yearid) AS min_year, MAX(yearid) AS max_year FROM fieldingofsplit
    UNION SELECT MIN(yearid) AS min_year, MAX(yearid) AS max_year FROM fielding
	UNION SELECT MIN(yearid) AS min_year, MAX(yearid) AS max_year FROM fieldingof
    UNION SELECT MIN(yearid) AS min_year, MAX(yearid) AS max_year FROM pitching
    UNION SELECT MIN(yearid) AS min_year, MAX(yearid) AS max_year FROM batting
    UNION SELECT MIN(yearid) AS min_year, MAX(yearid) AS max_year FROM halloffame
    UNION SELECT MIN(yearid) AS min_year, MAX(yearid) AS max_year FROM awardsshareplayers
    UNION SELECT MIN(yearid) AS min_year, MAX(yearid) AS max_year FROM awardsplayers
    UNION SELECT MIN(yearid) AS min_year, MAX(yearid) AS max_year FROM awardsmanagers
    UNION SELECT MIN(yearid) AS min_year, MAX(yearid) AS max_year FROM awardssharemanagers
) as subquery;


--1871 - 2017



-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?


SELECT height, playerid, namefirst, namelast, teamid, g_batting, g_defense
FROM people
FULL JOIN appearances
USING (playerid)
WHERE height IS NOT NULL
ORDER BY height
LIMIT 1;

--Eddie Gaedel. Played one game for the Saint Lewis Cardinals.


-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

SELECT schoolname, schoolid
FROM schools
WHERE LOWER(schoolname) = 'vanderbilt university'

--school id: vandy


SELECT
    c.schoolid,
    c.playerid,
    SUM(s.salary) AS salary,
    p.namefirst,
    p.namelast
FROM
    schools
INNER JOIN
    collegeplaying AS c
ON schools.schoolid = c.schoolid
INNER JOIN
    salaries AS s
ON c.playerid = s.playerid
INNER JOIN
    people AS p
ON s.playerid = p.playerid
WHERE c.schoolid = 'vandy'
GROUP BY c.schoolid, c.playerid, p.namefirst, p.namelast
ORDER BY SUM(s.salary) DESC;

--David Price had the highest salary.
	
	

-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

SELECT 
    CASE 
        WHEN pos = 'OF' THEN 'Outfield'
        WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
        WHEN pos IN ('P', 'C') THEN 'Battery'
        ELSE 'Other'
    END AS position,
    SUM(po) AS total_putouts
FROM fielding
WHERE yearid = 2016
GROUP BY position;

--Battery: 41424, Infield: 58934, Outfield 29560


-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

SELECT 
	FLOOR((yearid / 10) * 10) AS decade,
    ROUND(AVG(so / g), 2) AS avg_strikeouts_per_game,
    ROUND(AVG(hr / g), 2) AS avg_home_runs_per_game
FROM teams
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade;

  
--not sure if that is the correct table to pull from



-- 6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.



SELECT
    playerid
FROM (
    SELECT
        playerid,
        SUM(sb) AS successful_attempts,
        SUM(cs) AS caught_stealing,
        SUM(sb) + SUM(cs) AS total_attempts
    FROM batting
    WHERE yearid = 2016
    GROUP BY playerid
    HAVING SUM(sb) + SUM(cs) >= 20
) AS StolenBaseStats
ORDER BY (successful_attempts * 1.0 / total_attempts) DESC;


--Need to add more info of the player

WITH StolenBaseStats AS (
    SELECT
        b.playerid,
        SUM(b.sb) AS successful_attempts,
        SUM(b.cs) AS caught_stealing,
        SUM(b.sb) + SUM(b.cs) AS total_attempts
    FROM batting AS b
    WHERE b.yearid = 2016
    GROUP BY b.playerid
    HAVING SUM(b.sb) + SUM(b.cs) >= 20
)
SELECT p.namefirst, p.namelast
FROM StolenBaseStats AS s
JOIN people AS p ON s.playerid = p.playerid
ORDER BY (s.successful_attempts * 1.0 / s.total_attempts) DESC;


--Need to add percentage somehow

WITH StolenBaseStats AS (
    SELECT
        b.playerid,
        SUM(b.sb) AS successful_attempts,
        SUM(b.cs) AS caught_stealing,
        SUM(b.sb) + SUM(b.cs) AS total_attempts
    FROM batting AS b
    WHERE b.yearid = 2016
    GROUP BY b.playerid
    HAVING SUM(b.sb) + SUM(b.cs) >= 20
)
SELECT
    p.namefirst,
    p.namelast,
    ROUND((s.successful_attempts * 100.0 / s.total_attempts),2) AS success_percentage
FROM StolenBaseStats AS s
JOIN people AS p ON s.playerid = p.playerid
ORDER BY success_percentage DESC
LIMIT 1;

--Chris Owings 91%


-- 7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. 

SELECT w, l, wswin, teamid, yearid
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
	AND wswin = 'N'
ORDER BY w DESC;

SELECT w, l, wswin, teamid, yearid
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
	AND wswin = 'Y'
ORDER BY w;

--Take out 1981

SELECT w, l, wswin, teamid, yearid
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
	AND wswin = 'N'
ORDER BY w DESC;

SELECT w, l, wswin, teamid, yearid
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
	AND wswin = 'Y'
	AND yearid != 1981
ORDER BY w;


--How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?


WITH cte AS (SELECT yearid, (MAX(w))AS maxw
FROM teams
WHERE yearid BETWEEN 1970 AND 2016 AND yearid NOT IN (1981)
GROUP BY yearid
ORDER BY yearid DESC),

cte2 AS (SELECT teamid, yearid, w, wswin
		FROM teams
		WHERE yearid BETWEEN 1978 AND 2016 AND yearid NOT IN (1981)
		ORDER BY w DESC)
SELECT
SUM(CASE WHEN wswin='Y'
	THEN 1 
	ELSE 0 
	END) AS total_wins,
COUNT(DISTINCT cte.yearid),
ROUND(SUM(CASE WHEN wswin = 'Y' 
	THEN 1 
	ELSE 0 
	END)/COUNT(DISTINCT cte.yearid)::numeric, 2)*100
FROM cte2
LEFT JOIN cte
ON cte.yearid=cte2.yearid AND cte2.w=cte.maxw
WHERE cte.maxw IS NOT NULL;


-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

SELECT park_name, team, year,
SUM(attendance)/SUM(games) AS average_attendance
FROM homegames
INNER JOIN parks
USING(park)
WHERE year = '2016' AND games >= 10
GROUP BY team, year, park_name
ORDER BY average_attendance DESC
LIMIT 5;

SELECT park_name, team, year,
SUM(attendance) / SUM(games) AS average_attendance
FROM homegames
INNER JOIN parks
USING(park)
WHERE year = '2016' AND games >= 10
GROUP BY team, year, park_name
ORDER BY average_attendance ASC
LIMIT 5;



-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

SELECT DISTINCT(p.namefirst), p.namelast, teamid
FROM awardsmanagers AS am1
INNER JOIN awardsmanagers AS am2
USING (playerid)
INNER JOIN people AS p
USING (playerid)
INNER JOIN managers AS m
USING (playerid)
WHERE am1.awardid = 'TSN Manager of the Year'
AND am2.awardid = 'TSN Manager of the Year'
AND ((am1.lgid = 'AL' AND am2.lgid = 'NL') 
OR (am1.lgid = 'NL' AND am2.lgid = 'AL'))
AND (m.yearid = am1.yearid);


-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.



-- **Open-ended questions**

-- 11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

-- 12. In this question, you will explore the connection between number of wins and attendance.
--     <ol type="a">
--       <li>Does there appear to be any correlation between attendance at home games and number of wins? </li>
--       <li>Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.</li>
--     </ol>


-- 13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?
