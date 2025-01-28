--1. SELECIONE DOS DADOS DAS TABELAS OLYMPICS_HISTORY E olympics_history_noc_regions --
select * from OLYMPICS_HISTORY;
SELECT *FROM olympics_history_noc_regions;

--2. Liste todos os jogos olímpicos realizados até agora--
SELECT  DISTINCT GAMES, CITY, YEAR FROM OLYMPICS_HISTORY
ORDER BY year ASC;

--3. Mencione o número total de nações que participaram de cada jogo olímpico?--
SELECT OLYMPICS_HISTORY.games, 
COUNT (DISTINCT olympics_history_noc_regions.region) as Total_Nations
FROM olympics_history_noc_regions
INNER JOIN OLYMPICS_HISTORY
ON  olympics_history_noc_regions.noc = OLYMPICS_HISTORY.noc
GROUP BY OLYMPICS_HISTORY.games
ORDER BY OLYMPICS_HISTORY.games ASC, Total_Nations;

--4. Em qual ano houve o maior e o menor número de países participando das Olimpíadas?--
SELECT year,
COUNT (DISTINCT noc) AS total_countries
FROM OLYMPICS_HISTORY
GROUP BY year
ORDER BY total_countries DESC;
SELECT year,
COUNT (DISTINCT noc) AS total_countries
FROM OLYMPICS_HISTORY
GROUP BY year
ORDER BY total_countries ASC;

--5. Qual nação participou de todos os jogos olímpicos?--

WITH TotalGames AS (
    SELECT COUNT(DISTINCT games) AS Total_Games
    FROM olympics_history
),
NationParticipation AS (
    SELECT 
        olympics_history_noc_regions.region AS Country, 
        COUNT(DISTINCT OLYMPICS_HISTORY.games) AS Participated_Games
    FROM olympics_history_noc_regions 
    INNER JOIN OLYMPICS_HISTORY
    ON olympics_history_noc_regions.noc = OLYMPICS_HISTORY.noc
    GROUP BY olympics_history_noc_regions.region
)
SELECT NationParticipation.Country, NationParticipation.Participated_Games
FROM NationParticipation
JOIN TotalGames 
ON NationParticipation.Participated_Games = TotalGames.Total_Games;


--6. Identifique o esporte que foi praticado em todas as Olimpíadas de verão.--
	
SELECT 
    distinct sport, 
    count (distinct games) as Total_Summer_games
FROM
   OLYMPICS_HISTORY
   WHERE season = 'Summer'
GROUP BY 
    sport, season
ORDER BY 
    Total_Summer_games DESC, 
    sport ASC;


--7. Quais esportes foram praticados apenas uma vez nas Olimpíadas?-

SELECT sport, MIN(games) AS games
FROM OLYMPICS_HISTORY
GROUP BY sport
HAVING COUNT(DISTINCT games) = 1
ORDER BY sport;

--8. Obtenha o número total de esportes praticados em cada jogo olímpico.-
SELECT games, COUNT(DISTINCT sport) AS Total_Sport
FROM OLYMPICS_HISTORY
GROUP BY games
ORDER BY games DESC;


--9. Obtenha detalhes dos atletas mais velhos que ganharam uma medalha de ouro.--
SELECT name, cast(case when age = 'NA' then '0' else age end as int), sex, team, games, city, sport, event, medal
FROM 
OLYMPICS_HISTORY
WHERE medal = 'Gold'
GROUP BY name, sex, city, team, games, sport, age, event, medal
ORDER BY age desc;


--10. Encontre a proporção de atletas masculinos e femininos que participaram de todos os jogos olímpicos.--
  with t1 as
        	(select sex, count(1) as cnt
        	from olympics_history
        	group by sex),
        t2 as
        	(select *, row_number() over(order by cnt) as rn
        	 from t1),
        min_cnt as
        	(select cnt from t2	where rn = 1),
        max_cnt as
        	(select cnt from t2	where rn = 2)
    select concat('1 : ', round(max_cnt.cnt::decimal/min_cnt.cnt, 2)) as ratio
    from min_cnt, max_cnt;


--11. Selecione os 5 melhores atletas que ganharam mais medalhas de ouro.--
SELECT name, COUNT(medal) AS Best_Players
FROM OLYMPICS_HISTORY
WHERE medal = 'Gold'
GROUP BY name, medal
ORDER BY Best_Players DESC
LIMIT 5;


--12. Selecione os 5 melhores atletas que ganharam mais medalhas (ouro/prata/bronze).--
SELECT name, COUNT (medal) as Best_Players
FROM OLYMPICS_HISTORY
WHERE medal IN ('Gold', 'Silver', 'Bronze')
GROUP BY name, medal
ORDER BY Best_players DESC
LIMIT 5;


-- 13. Busque os 5 países mais bem-sucedidos nas olimpíadas. O sucesso é definido pelo número de medalhas conquistadas.--
SELECT olympics_history_noc_regions.region AS Country, COUNT (OLYMPICS_HISTORY.medal) AS medal_count
FROM olympics_history_noc_regions
INNER JOIN OLYMPICS_HISTORY
ON olympics_history_noc_regions.noc = OLYMPICS_HISTORY.noc
WHERE OLYMPICS_HISTORY.medal IN ('Gold', 'Silver', 'Bronze')
GROUP BY  olympics_history_noc_regions.region
ORDER BY medal_count DESC
LIMIT 5;


--14. Liste o total de medalhas de ouro, prata e bronze conquistadas por cada país.--
SELECT 
    olympics_history_noc_regions.region AS Country,
    SUM(CASE WHEN OLYMPICS_HISTORY.medal = 'Gold' THEN 1 ELSE 0 END) AS Gold,
    SUM(CASE WHEN OLYMPICS_HISTORY.medal = 'Silver' THEN 1 ELSE 0 END) AS Silver,
    SUM(CASE WHEN OLYMPICS_HISTORY.medal = 'Bronze' THEN 1 ELSE 0 END) AS Bronze
FROM olympics_history_noc_regions
INNER JOIN OLYMPICS_HISTORY
ON olympics_history_noc_regions.noc = OLYMPICS_HISTORY.noc
GROUP BY olympics_history_noc_regions.region
ORDER BY Gold DESC, Silver DESC, Bronze DESC;



--15. Liste o total de medalhas de ouro, prata e bronze conquistadas por cada país, correspondentes a cada jogo olímpico.--
SELECT 
OLYMPICS_HISTORY.games, olympics_history_noc_regions.region AS Country, 
	SUM(CASE WHEN OLYMPICS_HISTORY.medal ='Gold' THEN 1 ELSE 0 END) AS Gold,
	SUM(CASE WHEN OLYMPICS_HISTORY.medal = 'Silver' THEN 1 ELSE 0 END) AS Silver,
    SUM(CASE WHEN OLYMPICS_HISTORY.medal = 'Bronze' THEN 1 ELSE 0 END) AS Bronze
	FROM olympics_history_noc_regions
	INNER JOIN OLYMPICS_HISTORY
	ON olympics_history_noc_regions.noc = OLYMPICS_HISTORY.noc
	GROUP BY olympics_history_noc_regions.region, OLYMPICS_HISTORY.games
	ORDER BY games ASC, Gold, Silver, Bronze;

--16. Identifique qual país ganhou mais medalhas de ouro, mais medalhas de prata e mais medalhas de bronze em cada jogo olímpico.--

WITH MedalCounts AS (
SELECT 
	olympics_history_noc_regions.region AS Country,
    OLYMPICS_HISTORY.games AS Games,
    SUM(CASE WHEN OLYMPICS_HISTORY.medal = 'Gold' THEN 1 ELSE 0 END) AS Gold,
    SUM(CASE WHEN OLYMPICS_HISTORY.medal = 'Silver' THEN 1 ELSE 0 END) AS Silver,
    SUM(CASE WHEN OLYMPICS_HISTORY.medal = 'Bronze' THEN 1 ELSE 0 END) AS Bronze
FROM 
	olympics_history_noc_regions 
INNER JOIN 
    olympics_history 
ON 
    olympics_history_noc_regions.noc = OLYMPICS_HISTORY.noc
GROUP BY 
    olympics_history_noc_regions.region, OLYMPICS_HISTORY.games
),

MaxGold AS (
SELECT Games, Country || ' - ' || Gold AS max_gold
FROM MedalCounts
    WHERE (Games, Gold) IN (
        SELECT Games, MAX(Gold) FROM MedalCounts GROUP BY Games
    )
),

MaxSilver AS (
SELECT Games, Country || ' - ' || Silver AS max_silver
FROM MedalCounts
    WHERE (Games, Silver) IN (
        SELECT Games, MAX(Silver) FROM MedalCounts GROUP BY Games
    )
),

MaxBronze AS (
SELECT Games, Country || ' - ' || Bronze AS max_bronze
FROM MedalCounts
    WHERE (Games, Bronze) IN (
        SELECT Games, MAX(Bronze) FROM MedalCounts GROUP BY Games
    )
)
SELECT 
    mg.Games, 
    mg.max_gold, 
    ms.max_silver, 
    mb.max_bronze
FROM 
    MaxGold mg
LEFT JOIN 
    MaxSilver ms ON mg.Games = ms.Games
LEFT JOIN 
    MaxBronze mb ON mg.Games = mb.Games
ORDER BY 
    mg.Games;



--17. Identifique qual país ganhou mais medalhas de ouro, mais medalhas de prata, mais medalhas de bronze e mais medalhas em cada jogo olímpico.--
WITH MedalCounts AS (
SELECT 
	olympics_history_noc_regions.region AS Country,
    OLYMPICS_HISTORY.games AS Games,
	COUNT (OLYMPICS_HISTORY.medal) AS Medals,
    SUM(CASE WHEN OLYMPICS_HISTORY.medal = 'Gold' THEN 1 ELSE 0 END) AS Gold,
    SUM(CASE WHEN OLYMPICS_HISTORY.medal = 'Silver' THEN 1 ELSE 0 END) AS Silver,
    SUM(CASE WHEN OLYMPICS_HISTORY.medal = 'Bronze' THEN 1 ELSE 0 END) AS Bronze
FROM 
	olympics_history_noc_regions 
INNER JOIN 
    olympics_history 
ON 
    olympics_history_noc_regions.noc = OLYMPICS_HISTORY.noc

GROUP BY 
    olympics_history_noc_regions.region, OLYMPICS_HISTORY.games
),
Max_Medals AS (
SELECT Games, Country || ' - ' || Medals AS Max_Medals
FROM MedalCounts
	WHERE (Games, Medals) IN (
		SELECT Games, MAX(Medals) FROM MedalCounts GROUP BY Games
)
),

MaxGold AS (
SELECT Games, Country || ' - ' || Gold AS max_gold
FROM MedalCounts
    WHERE (Games, Gold) IN (
        SELECT Games, MAX(Gold) FROM MedalCounts GROUP BY Games
    )
),

MaxSilver AS (
SELECT Games, Country || ' - ' || Silver AS max_silver
FROM MedalCounts
    WHERE (Games, Silver) IN (
        SELECT Games, MAX(Silver) FROM MedalCounts GROUP BY Games
    )
),

MaxBronze AS (
SELECT Games, Country || ' - ' || Bronze AS max_bronze
FROM MedalCounts
    WHERE (Games, Bronze) IN (
        SELECT Games, MAX(Bronze) FROM MedalCounts GROUP BY Games
    )
)
SELECT 
    mm.Games, 
	mm.Max_Medals,
    mg.max_gold, 
    ms.max_silver, 
    mb.max_bronze
FROM 
    Max_Medals mm
LEFT JOIN 
    MaxGold mg ON mm.Games = mg.Games
LEFT JOIN 
    MaxSilver ms ON mm.Games = ms.Games
LEFT JOIN 
    MaxBronze mb ON mm.Games = mb.Games
ORDER BY 
    mm.Games;




--18. Quais países nunca ganharam medalha de ouro, mas ganharam medalhas de prata/bronze?--
SELECT olympics_history_noc_regions.region AS Country,
	SUM(CASE WHEN OLYMPICS_HISTORY.medal = 'Gold' THEN 1 ELSE 0 END) AS Gold,
	SUM(CASE WHEN OLYMPICS_HISTORY.medal = 'Silver' THEN 1 ELSE 0 END) AS Silver, 
	SUM(CASE WHEN OLYMPICS_HISTORY.medal = 'Bronze' THEN 1 ELSE 0 END) AS Bronze
FROM olympics_history_noc_regions
	INNER JOIN OLYMPICS_HISTORY
	ON olympics_history_noc_regions.noc = OLYMPICS_HISTORY.noc
WHERE
    olympics_history.noc NOT IN (
SELECT
	noc
FROM
	OLYMPICS_HISTORY
        WHERE
	medal = 'Gold')
    
GROUP BY olympics_history_noc_regions.region, OLYMPICS_HISTORY.medal
ORDER BY Silver DESC, Bronze DESC;


--19. Em qual esporte/evento a Índia ganhou o maior número de medalhas.--
SELECT olympics_history_noc_regions.region AS Country, OLYMPICS_HISTORY.sport,
COUNT(OLYMPICS_HISTORY.sport) AS Total_Medals
FROM olympics_history_noc_regions
	INNER JOIN OLYMPICS_HISTORY
	ON olympics_history_noc_regions.noc = OLYMPICS_HISTORY.noc
	WHERE 
	olympics_history_noc_regions.region = 'India'
	GROUP BY OLYMPICS_HISTORY.sport,  olympics_history_noc_regions.region
	ORDER BY Total_Medals DESC
	LIMIT 1;

--20. Divida todos os jogos olímpicos em que a Índia ganhou medalhas de hóquei e quantas medalhas houve em cada jogo olímpico.--
SELECT olympics_history_noc_regions.region AS India, OLYMPICS_HISTORY.sport, COUNT (OLYMPICS_HISTORY.medal) as Total_Medals, OLYMPICS_HISTORY.games AS Games
FROM olympics_history_noc_regions
INNER JOIN OLYMPICS_HISTORY
	ON olympics_history_noc_regions.noc = OLYMPICS_HISTORY.noc
	WHERE 
	olympics_history_noc_regions.region = 'India' AND sport = 'Hockey'
GROUP BY OLYMPICS_HISTORY.sport, OLYMPICS_HISTORY.medal, OLYMPICS_HISTORY.games, India
ORDER BY Total_Medals DESC;
