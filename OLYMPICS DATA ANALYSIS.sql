USE [Olympics]
SELECT * 
FROM [dbo].[athlete_events$]

SELECT * 
FROM [dbo].[noc_regions$]

--1. Total Olympics games held--
SELECT COUNT(DISTINCT [Games]) AS TotalGamesHeld
FROM [dbo].[athlete_events$]

select [Games],count([Games])AS GameFrequency
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
UNION ALL
SELECT 'No Nation Participated in all games'
WHERE NOT EXISTS (
   SELECT 1
   FROM [dbo].[athlete_events$]
   GROUP BY [Team]
   having count(distinct Games) = (select count(distinct Games)
								from [dbo].[athlete_events$])


--6.  The sport which was played in all summer olympics--
SELECT distinct([Sport])
FROM [dbo].[athlete_events$]
where [Season] = 'Summer'
GROUP BY [Sport]
having count(distinct Games) = (select count(distinct Games)
								from [dbo].[athlete_events$])

--7.	Which Sports were just played only once in the olympics--
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
select [Sex], count([Sex]) as Gender_Ratio
from [dbo].[athlete_events$]
group by [Sex]

--11. Top 5 athletes who have won the most gold medals--
SELECT TOP 5 [Name],COUNT([Medal]) AS medalWon
FROM [dbo].[athlete_events$]
WHERE [Medal] ='Gold'
GROUP  BY [Name]
order by medalWon DESC

--12. Top 5 athletes who have won the most medals (gold/silver/bronze)--
SELECT TOP 5 [Name],[Medal],COUNT([Medal]) AS medalWon
FROM [dbo].[athlete_events$]
WHERE [Medal] IN ('Gold', 'Silver', 'Bronze')
GROUP  BY [Name],[Medal]
order by medalWon DESC

--13.Top 5 most successful countries in olympics. Success is defined by no of medals won.--
SELECT TOP 5 [Team], [Medal], COUNT([Medal]) AS MedalCount
FROM [dbo].[athlete_events$]
WHERE [Medal] <> 'NA'
GROUP BY [Team],[Medal]
ORDER BY MedalCount DESC

--14.  Total gold, silver and bronze medals won by each country--
SELECT DISTINCT[Team],[Medal], COUNT([Medal]) AS TotalMedal
FROM [dbo].[athlete_events$]
WHERE [Medal] <> 'NA'
GROUP BY [Medal],[Team]
ORDER BY TotalMedal DESC

--THE NEXT QUERY EXECUTES IT BETTER--
SELECT [Team],
SUM(CASE WHEN [Medal]='Gold'
THEN 1 ELSE 0 END) AS GOLD,
SUM(CASE WHEN [Medal]='Silver'
THEN 1 ELSE 0 END) AS SILVER,
SUM(CASE WHEN [Medal]='Bronze'
THEN 1 ELSE 0 END) AS BRONZE,
COUNT(CASE WHEN [Medal] <> 'NA' THEN 1 ELSE 0 END) AS MedalCount
FROM [dbo].[athlete_events$]
GROUP BY [Team]
ORDER BY GOLD DESC, SILVER DESC, BRONZE DESC

--15.	Total gold, silver and broze medals won by each country corresponding to each olympic games
SELECT DISTINCT([Games]),[Team] AS Country,
SUM(CASE WHEN [Medal]='Gold'
THEN 1 ELSE 0 END) AS GOLD,
SUM(CASE WHEN [Medal]='Silver'
THEN 1 ELSE 0 END) AS SILVER,
SUM(CASE WHEN [Medal]='Bronze'
THEN 1 ELSE 0 END) AS BRONZE,
COUNT(CASE WHEN [Medal] <> 'NA' THEN 1 ELSE 0 END) AS MedalCount
FROM [dbo].[athlete_events$]
GROUP BY [Team],[Games]
ORDER BY GOLD DESC, SILVER DESC, BRONZE DESC

 --16. Country With the most gold, most silver and most bronze medals--
 SELECT [Team],[Medal], COUNT([Medal]) AS MedalCount
 from [dbo].[athlete_events$]
 WHERE [Medal]<> 'NA'
group by [Team],[Medal]
order by MedalCount DESC


--17.	Which countries have never won gold medal but have won silver/bronze medals?-- 
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

