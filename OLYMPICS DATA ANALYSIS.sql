USE [Olympics]
SELECT * 
FROM [dbo].[athlete_events$]

SELECT * 
FROM [dbo].[noc_regions$]

--1. Total Olympics games held--
SELECT COUNT(DISTINCT [Games]) AS TotalGamesHeld
FROM [dbo].[athlete_events$]

SELECT [Games],COUNT([Games])AS GameFrequency
FROM [dbo].[athlete_events$]
GROUP BY [Games]
ORDER BY GameFrequency DESC

--2. All Olympics games held so far--
SELECT DISTINCT [Games]
FROM [dbo].[athlete_events$]
ORDER BY [Games] ASC

--3. Total no of nations who participated in each olympics game--
SELECT [Games], COUNT (DISTINCT [Team]) AS Nations
FROM [dbo].[athlete_events$]
GROUP BY [Games]
ORDER BY Nations DESC

--This query also execute the above case study--
SELECT a.[Games],  COUNT (DISTINCT b.[region]) AS Nations
FROM [dbo].[athlete_events$] a
JOIN [dbo].[noc_regions$] b
ON a.[NOC] =b.[NOC]
GROUP BY [Games]
ORDER BY Nations DESC

--4. Year with highest and lowest no. of countries participating in olympics--
WITH CountryCount AS (
	SELECT [Year], COUNT(DISTINCT[Team]) AS Country_Count
	FROM [dbo].[athlete_events$]
	GROUP BY [Year]
	)
SELECT [Year], Country_Count,
CASE 
WHEN Country_Count =(SELECT MAX(Country_Count) FROM CountryCount)
THEN 'Highest'
WHEN Country_Count =(SELECT MIN(Country_Count) FROM CountryCount)
THEN 'Lowest'
END AS CATEGORY
FROM CountryCount
WHERE Country_Count =(SELECT MAX(Country_Count) FROM CountryCount) 
OR 
Country_Count =(SELECT MIN(Country_Count) FROM CountryCount)

--5. Which nation has participated in all of the olympic games--
SELECT [Team]
FROM [dbo].[athlete_events$]
GROUP BY [Team]
HAVING COUNT (DISTINCT [Games]) =
	(SELECT  COUNT (DISTINCT [Games]) FROM [dbo].[athlete_events$])

--IF NO NATION PARTICIPATED--
IF EXISTS (
SELECT [Team]
FROM [dbo].[athlete_events$]
GROUP BY [Team]
HAVING COUNT (DISTINCT [Games]) =
	(SELECT  COUNT (DISTINCT [Games]) FROM [dbo].[athlete_events$])
	)
BEGIN
	SELECT [Team]
	FROM [dbo].[athlete_events$]
	GROUP BY [Team]
	HAVING COUNT(DISTINCT [Games])=(SELECT COUNT(DISTINCT [Games]) FROM [dbo].[athlete_events$])
END
ELSE
BEGIN
	SELECT 'NO NATION PARTICIPATED IN ALL GAMES' AS Result
END
	
--6.  The sport which was played in all summer olympics--
SELECT distinct([Sport])
FROM [dbo].[athlete_events$]
WHERE [Season] = 'Summer'
GROUP BY [Sport]
HAVING COUNT(DISTINCT Games) = (SELECT COUNT(DISTINCT Games)
								FROM [dbo].[athlete_events$])

--IF NO SPORT WAS PLAYED IN ALL SUMMER OLYMPICS--
IF EXISTS (
SELECT DISTINCT ([Sport])
FROM [dbo].[athlete_events$]
WHERE [Season] = 'Summer'
GROUP BY [Sport]
HAVING COUNT(DISTINCT Games) = (SELECT COUNT(DISTINCT Games)
								FROM [dbo].[athlete_events$]))
BEGIN
	SELECT [Sport]
	FROM [dbo].[athlete_events$]
	GROUP BY [Sport]
	HAVING COUNT(DISTINCT [Games])=(SELECT COUNT(DISTINCT [Games]) FROM [dbo].[athlete_events$])
END
ELSE
BEGIN
	SELECT 'NO SPORT WAS PLAYED IN ALL SUMMER OLYMPICS' AS Result
END

--7. Sports played only once in the olympics--
SELECT [Sport]
FROM [dbo].[athlete_events$]
GROUP BY [Sport]
HAVING COUNT(DISTINCT[Year])=1

--8.Total no of sports played in each olympic games--
SELECT DISTINCT [Games],  COUNT(DISTINCT[Sport]) AS TotalSportPlayed
FROM [dbo].[athlete_events$]
GROUP BY [Games]
ORDER BY TotalSportPlayed DESC

--9. Details of the oldest athletes to win a gold medal--
SELECT *
FROM [dbo].[athlete_events$]
WHERE [Age] = (SELECT MAX([Age]) FROM [dbo].[athlete_events$] where  [Medal]= 'Gold')
--or--
SELECT TOP 1 *
FROM [dbo].[athlete_events$]
WHERE [Medal]= 'Gold'
ORDER BY [Age] DESC

--10. Ratio of male and female athletes participated in all olympic games--
SELECT [Sex], count([Sex]) as Gender_Ratio
FROM [dbo].[athlete_events$]
GROUP BY [Sex]

--11. Top 5 athletes who have won the most gold medals--
SELECT TOP 5 [Name],COUNT([Medal]) AS MedalWon
FROM [dbo].[athlete_events$]
WHERE [Medal] ='Gold'
GROUP  BY [Name]
ORDER BY MedalWon DESC

--12. Top 5 athletes who have won the most medals (gold/silver/bronze)--
SELECT TOP 5 [Name],[Medal],COUNT([Medal]) AS medalWon
FROM [dbo].[athlete_events$]
WHERE [Medal] IN ('Gold', 'Silver', 'Bronze')
GROUP  BY [Name],[Medal]
ORDER BY medalWon DESC

--13.Top 5 most successful countries in olympics. Success is defined by no of medals won.--
SELECT TOP 5 [Team], [Medal], COUNT([Medal]) AS MedalCount
FROM [dbo].[athlete_events$]
WHERE [Medal] <> 'NA'
GROUP BY [Team],[Medal]
ORDER BY MedalCount DESC

--14.  Total gold, silver and bronze medals won by each country--
SELECT [Team],
SUM(CASE WHEN [Medal]='Gold'
THEN 1 ELSE 0 END) AS GOLD,
SUM(CASE WHEN [Medal]='Silver'
THEN 1 ELSE 0 END) AS SILVER,
SUM(CASE WHEN [Medal]='Bronze'
THEN 1 ELSE 0 END) AS BRONZE
FROM [dbo].[athlete_events$]
GROUP BY [Team]
ORDER BY [Team]ASC, GOLD DESC, SILVER DESC, BRONZE DESC

--15.	Total gold, silver and bronze medals won by each country corresponding to each olympic games
SELECT DISTINCT([Games]),[Team] AS Country,
SUM(CASE WHEN [Medal]='Gold'
THEN 1 ELSE 0 END) AS GOLD,
SUM(CASE WHEN [Medal]='Silver'
THEN 1 ELSE 0 END) AS SILVER,
SUM(CASE WHEN [Medal]='Bronze'
THEN 1 ELSE 0 END) AS BRONZE
FROM [dbo].[athlete_events$]
GROUP BY [Team],[Games]
ORDER BY Country ASC, GOLD DESC, SILVER DESC, BRONZE DESC


--18.	Countries that has never won gold medal but have won silver/bronze medals?-- 
SELECT [Team] AS Country
FROM [dbo].[athlete_events$]
GROUP BY [Team]
HAVING 
SUM(CASE WHEN [Medal] = 'Gold' 
THEN 1 ELSE 0 END) =0
AND SUM(CASE WHEN [Medal] = 'Silver' 
THEN 1 ELSE 0 END) >0
AND SUM(CASE WHEN [Medal] = 'Bronze' 
THEN 1 ELSE 0 END) >0

