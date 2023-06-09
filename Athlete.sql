---1.	HOW MANY OLYMPIC GAMES HAVE BEEN PLAYED
  
	SELECT COUNT (DISTINCT _Games_) AS olympicsPlayed
	FROM [SQL_Projects].[dbo].[athlete_]

 
---2.	LIST ALL THE OLYMPIC GAMES HELD SO FAR
	
	SELECT DISTINCT _Games_
	FROM [SQL_Projects].[dbo].[athlete_]
	ORDER BY 1


---3.	HOW MANY TEAM PARTICIPATED IN EACH OLYMPIC GAME
 
	SELECT _Games_, COUNT (DISTINCT _Team_) AS ParticipatedTeams
	FROM [SQL_Projects].[dbo].[athlete_]
	GROUP BY _Games_
	ORDER BY 1


---4.	TOTAL NUMBER OF NATION THAT PARTICIPATED IN EACH OLYMPIC GAME
 
	SELECT _Games_, COUNT (DISTINCT _NOC_) AS TotalNations
	FROM [SQL_Projects].[dbo].[athlete_]
	GROUP BY _Games_
	ORDER BY 1

---5.	WHICH YEAR SAW THE HIGHEST AND LOWEST NUMBER OF COUNTRIES PARTICIPATING IN OLYMPICS?

	SELECT 
		MAX(CASE WHEN Row_Asc = 1 THEN _Games_ END) AS Year_with_lowest_countries,
		MIN(CASE WHEN Row_Desc = 1 THEN _Games_ END) AS Year_with_highest_countries,
		MIN(CASE WHEN Row_Asc = 1 THEN TotalNations END) AS Lowest_total_nations,
		MAX(CASE WHEN Row_Desc = 1 THEN TotalNations END) AS Highest_total_nations
	FROM
		(
			SELECT  _Games_, COUNT (DISTINCT _NOC_) AS TotalNations,
			ROW_NUMBER () OVER (ORDER BY COUNT(DISTINCT _NOC_)ASC) AS Row_Asc,
			ROW_NUMBER () OVER (ORDER BY COUNT(DISTINCT _NOC_)DESC) AS Row_Desc
			FROM [SQL_Projects].[dbo].[athlete_]
			GROUP BY _Games_) AS a
	WHERE Row_Asc = 1 OR Row_Desc = 1


---6.	WHICH NATION HAS PARTICIPATED IN ALL THE OLYMPIC GAMES?
	
	SELECT a._NOC_, b.region, COUNT(DISTINCT a._Games_) AS Game_count
	FROM [SQL_Projects].[dbo].[athlete_] as a
		JOIN [SQL_Projects].[dbo].[noc_regions] as b
		ON a._NOC_ = b.NOC
	GROUP BY _NOC_, region
	HAVING COUNT(DISTINCT _Games_) = (SELECT COUNT(DISTINCT _Games_)  FROM [SQL_Projects].[dbo].[athlete_]);


---7.	IDENTIFY THE SPORT WHICH WAS PLAYED IN ALL SUMMER OLYMPICS

	WITH Summer_olympics (_Games_, _Sport_) AS
	(
		SELECT _Games_, _Sport_
		FROM [SQL_Projects].[dbo].[athlete_]
		WHERE _Games_ LIKE '%Summer%'
		GROUP BY _Games_, _Sport_
		)

	SELECT  _Sport_, COUNT(DISTINCT _Games_) AS Game_count 
	FROM Summer_olympics
	GROUP BY  _Sport_
	HAVING COUNT(DISTINCT _Games_) = (SELECT COUNT(DISTINCT _Games_)  FROM Summer_olympics);


---8.	WHICH SPORTS WERE PLAYED ONLY ONCE IN THE OLYMPICS?

	SELECT _Sport_, COUNT(DISTINCT _Games_) AS Game_count
	FROM [SQL_Projects].[dbo].[athlete_]
	GROUP BY _Sport_
	HAVING COUNT(DISTINCT _Games_) = 1
	ORDER BY 1;
	
---9.	FETCH THE TOTAL NO. OF SPORTS PLAYED IN EACH OLYMPIC GAMES

	SELECT _Games_, COUNT(DISTINCT _Sport_) AS Total_sports
	FROM [SQL_Projects].[dbo].[athlete_]
	GROUP BY _Games_
	ORDER BY 1;

---10.	FETCH DETAILS OF THE OLDEST ATHLETE TO WIN A GOLD MEDAL

	SELECT TOP 1 *
	FROM [SQL_Projects].[dbo].[athlete_]
	WHERE _Age_ != 'NA'
		AND _Medal_ = 'Gold'
	ORDER BY 4 DESC;
	

---11.	FIND THE RATIO OF MALE AND FEMALE ATHLETES PARTICIPATED IN ALL OLYMPIC GAMES

	SELECT COUNT(CASE WHEN _Sex_ = 'M' THEN 1 END ) AS Male_count,
			COUNT(CASE WHEN _Sex_ = 'F' THEN 1 END ) AS Female_count,
			COUNT(*) AS Total_count,
			CAST(COUNT(CASE WHEN _Sex_ = 'M' THEN 1 END )AS FLOAT ) / CAST(COUNT(CASE WHEN _Sex_ = 'F' THEN 1 END ) AS FLOAT) AS Ratio
	FROM [SQL_Projects].[dbo].[athlete_]


---12.	FETCH THE TOP 5 ATHLETES WHO HAVE WON THE MOST GOLD MEDALS
	
	SELECT TOP 5 _Name_, _Medal_, COUNT(*) AS Medal_Count
	FROM [SQL_Projects].[dbo].[athlete_]
	WHERE _Medal_ = 'Gold'
	GROUP BY _Name_, _Medal_
	ORDER BY Medal_Count DESC

---13.	FETCH THE TOP 5 ATHLETES WHO HAVE WON THE MOST MEDALS (GOLD/SILVER/BRONZE)

	SELECT TOP 5 _Name_,  COUNT(_Medal_) AS Medal_count
	FROM [SQL_Projects].[dbo].[athlete_]
	WHERE _Medal_ != 'NA'
	GROUP BY _Name_
	HAVING COUNT(_Medal_) >1
	ORDER BY Medal_Count DESC

---14.	FETCH THE TOP 5 MOST SUCCESSFUL COUNTRIES IN OLYMPICS. SUCCESS IS DEFINED BY NUMBER OF MEDALS WON

	SELECT TOP 5 a._NOC_,  b.region, COUNT(_Medal_) AS Medal_count
	FROM [SQL_Projects].[dbo].[athlete_] AS a
		JOIN [SQL_Projects].[dbo].[noc_regions] AS b
		ON a._NOC_ = b.NOC
	WHERE _Medal_ != 'NA'
	GROUP BY _NOC_, region
	HAVING COUNT(_Medal_) >1
	ORDER BY Medal_Count DESC

---15.	 LIST DOWN TOTAL GOLD, SILVER AND BRONZE MEDALS WON BY EACH COUNTRY
	
	SELECT _NOC_, 
		COUNT(CASE WHEN _Medal_ = 'Gold' THEN 1 END) AS Total_Gold,
		COUNT(CASE WHEN _Medal_ = 'Silver' THEN 1 END) AS Total_silver,
		COUNT(CASE WHEN _Medal_ = 'Bronze' THEN 1 END) AS Total_bronze
	FROM [SQL_Projects].[dbo].[athlete_]
	GROUP BY _NOC_
	ORDER BY 1

	
	

---16.	LIST DOWN TOTAL GOLD, SILVER, AND BRONZE MEDALS WON BY EACH COUNTRY CORRESPONDING TO EACH OLYMPIC GAMES

	SELECT _NOC_, _Games_,
		COUNT(CASE WHEN _Medal_ = 'Gold' THEN 1 END) AS Total_Gold,
		COUNT(CASE WHEN _Medal_ = 'Silver' THEN 1 END) AS Total_silver,
		COUNT(CASE WHEN _Medal_ = 'Bronze' THEN 1 END) AS Total_bronze
	FROM [SQL_Projects].[dbo].[athlete_]
	WHERE _Medal_ != 'NA'
	GROUP BY _NOC_, _Games_
	
	

---17.	IDENTIFY WHICH COUNTRY WON THE MOST GOLD, SILVER AND MOST BRONZE MEDALS IN EACH OLYMPIC GAMES

	SELECT a._Games_, 
		MAX(CASE WHEN a._Medal_ = 'Gold' THEN b.region ELSE NULL END) AS Gold,
		MAX(CASE WHEN a._Medal_ = 'Silver' THEN b.region ELSE NULL END) AS Silver,
		MAX(CASE WHEN a._Medal_ = 'Bronze' THEN b.region ELSE NULL END) AS Bronze
	FROM [SQL_Projects].[dbo].[athlete_] AS a
		JOIN [SQL_Projects].[dbo].[noc_regions] AS b
		ON a._NOC_ = b.NOC
	WHERE _Year_ >= 1896 AND _Year_ <= 2016
	GROUP BY _Games_
	ORDER BY 1


---18.	WHICH COUNTRIES HAVE NEVER WON GOLD MEDAL BUT HAVE WON SILVER/BRONZE MEDALS?

	SELECT a._NOC_,a._Medal_, b.region
	FROM [SQL_Projects].[dbo].[athlete_] AS a
		JOIN [SQL_Projects].[dbo].[noc_regions] AS b
		ON a._NOC_ = b.NOC
	WHERE _Medal_ !='NA'
		AND _Medal_ !='Gold'
	GROUP BY _NOC_, _Medal_, region;

---20.	BREAK DOWN ALL OLYMPIC GAMES WHERE NIGERIA WON MEDAL FOR FOOTBALL AND HOW MANY MEDALS IN EACH OLYMPIC GAMES

	SELECT a._NOC_, b.region, a._Games_, a._Sport_, COUNT(_Medal_) AS Total_Medal
	FROM [SQL_Projects].[dbo].[athlete_] AS a
	JOIN [SQL_Projects].[dbo].[noc_regions] AS b
		ON a._NOC_ = b.NOC
	WHERE _NOC_ = 'NGR'
		AND _Sport_ = 'Football'
		AND _Medal_ != 'NA'
	GROUP BY _NOC_, _Games_, region, _Sport_;

---22.	YOUNGEST AND OLDEST NIGERIAN ATHLETES

	SELECT MIN(_Age_) AS Youngest, MAX(_Age_) AS Oldest
	FROM [SQL_Projects].[dbo].[athlete_]
	WHERE _NOC_ = 'NGR'
		AND _Age_ != 'NA'

---23.	WHICH NIGERIAN ATHLETE HAS WON GOLD MEDAL?

	SELECT a._Name_, b.region, a._Medal_
	FROM [SQL_Projects].[dbo].[athlete_] AS a
		JOIN [SQL_Projects].[dbo].[noc_regions] AS b
		ON a._NOC_ = b.NOC
	WHERE _NOC_ = 'NGR'
		AND _Medal_ = 'Gold'

---24.	WHICH ATHLETE HAS WON THE MOST MEDAL IN NIGERIA?
	
	SELECT TOP 1 _Name_, COUNT(_Medal_) AS Total_Medal
	FROM  [SQL_Projects].[dbo].[athlete_]
	WHERE _NOC_ = 'NGR'
		AND _Medal_ != 'NA'
	GROUP BY _Name_
	ORDER BY Total_Medal DESC

---25.	HOW MANY MEDALS HAS NIGERIA WON?
	
	SELECT b.region, COUNT(a._Medal_) AS Medal_count
	FROM [SQL_Projects].[dbo].[athlete_] AS a
		JOIN [SQL_Projects].[dbo].[noc_regions] AS b
		ON a._NOC_ = b.NOC
	WHERE _NOC_ = 'NGR'
		AND _Medal_ != 'NA'
	GROUP BY _NOC_, region;

---26.	BREAK DOWN THE MEDALS ACCORDING TO THE TOTAL NUMBER WON IN NIGERIA

	SELECT b.region, 
		COUNT(CASE WHEN a._Medal_ = 'Gold' THEN 1 END) AS Gold,
		COUNT(CASE WHEN a._Medal_ = 'Silver' THEN 1 END) AS Silver,
		COUNT(CASE WHEN a._Medal_ = 'Bronze' THEN 1 END) AS Bronze
	FROM [SQL_Projects].[dbo].[athlete_] AS a
		JOIN [SQL_Projects].[dbo].[noc_regions] AS b
		ON a._NOC_ = b.NOC
	WHERE _NOC_ = 'NGR'
	GROUP BY region;

---27.	HOW MANY GAMES DID NIGERIA TAKE PART IN?

	SELECT b.region, COUNT(a._Games_) AS Total_Games
	FROM [SQL_Projects].[dbo].[athlete_] AS a
		JOIN [SQL_Projects].[dbo].[noc_regions] AS b
		ON a._NOC_ = b.NOC
	WHERE _NOC_ = 'NGR'
	GROUP BY region

---28.	HOW MANY NIGERIAN ATHLETES WON A MEDAL?

	SELECT _Name_, _Medal_
	FROM [SQL_Projects].[dbo].[athlete_]
	WHERE _NOC_ = 'NGR'
		AND _Medal_ != 'NA'
	

	SELECT COUNT(_Medal_) 
	FROM [SQL_Projects].[dbo].[athlete_]
	WHERE _NOC_ = 'NGR'
		AND _Medal_ != 'NA'
		


	