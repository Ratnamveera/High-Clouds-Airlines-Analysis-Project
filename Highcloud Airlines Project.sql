USE airline_maindata;
SELECT *FROM maindata;

# Creating Date Fields
SELECT Year,`Month (#)` AS Monthno,MONTHNAME(STR_TO_DATE(CONCAT(Year, '-', `Month (#)`, '-', Day), '%Y-%m-%d')) AS Monthfullname,Day,
CONCAT(Year, '-', LEFT(MONTHNAME(STR_TO_DATE(CONCAT(Year, '-', `Month (#)`, '-', Day), '%Y-%m-%d')), 3)) AS YearMonth,
CASE WHEN `Month (#)` BETWEEN 1 AND 3 THEN 'Q1'
	 WHEN `Month (#)` BETWEEN 4 AND 6 THEN 'Q2'
	 WHEN `Month (#)` BETWEEN 7 AND 9 THEN 'Q3'
	 ELSE 'Q4' END AS Quarter,
STR_TO_DATE(CONCAT(Year, '-', `Month (#)`, '-', Day), '%Y-%m-%d') AS FullDate,
WEEKDAY(STR_TO_DATE(CONCAT(Year, '-', `Month (#)`, '-', Day), '%Y-%m-%d')) + 1 AS Weekdayno,
DAYNAME(STR_TO_DATE(CONCAT(Year, '-', `Month (#)`, '-', Day), '%Y-%m-%d')) AS Weekdayname,
CASE WHEN `Month (#)` >= 4 THEN `Month (#)` - 3 ELSE `Month (#)` + 9 END AS FinancialMonth,
CASE WHEN `Month (#)` BETWEEN 4 AND 6 THEN 'FQ1'
     WHEN `Month (#)` BETWEEN 7 AND 9 THEN 'FQ2'
	 WHEN `Month (#)` BETWEEN 10 AND 12 THEN 'FQ3'
	 ELSE 'FQ4' END AS FinancialQuarter
FROM Maindata;

# Load Factor Calculation (Yearly, Quarterly, Monthly)
SELECT Year,`Month (#)`,
CONCAT(Year, '-Q', QUARTER(STR_TO_DATE(CONCAT(Year, '-', `Month (#)`, '-', Day), '%Y-%m-%d'))) AS YearQuarter,
CONCAT(Year, '-', LEFT(MONTHNAME(STR_TO_DATE(CONCAT(Year, '-', `Month (#)`, '-', Day), '%Y-%m-%d')), 3)) AS YearMonth,
ROUND(SUM(`# Transported Passengers`) * 1.0 / NULLIF(SUM(`# Available Seats`), 0), 2) AS LoadFactor,
CONCAT(ROUND((SUM(`# Transported Passengers`) * 100.0 / (SELECT SUM(`# Transported Passengers`) FROM Maindata)), 2),'%') AS PercentageOfGrandTotal
FROM Maindata GROUP BY Year, `Month (#)`, Day;

#Load Factor by Carrier Name
SELECT `Carrier Name`, ROUND(SUM(`# Transported Passengers`) * 1.0 / NULLIF(SUM(`# Available Seats`), 0), 2) AS LoadFactor, 
CONCAT(ROUND((SUM(`# Transported Passengers`) * 100.0 / (SELECT SUM(`# Transported Passengers`) FROM Maindata)), 2),'%') AS PercentageOfGrandTotal 
FROM Maindata GROUP BY `Carrier Name` ORDER BY LoadFactor DESC;

#Top 10 Carrier Names by Passenger Count
SELECT `Carrier Name`, CONCAT(ROUND(SUM(`# Transported Passengers`)/1000000,2),'M') AS TotalPassengers FROM Maindata
GROUP BY `Carrier Name` ORDER BY TotalPassengers DESC LIMIT 10;

#Top Routes by Number of Flights
SELECT `From - To City` AS Route, COUNT(`# Departures Performed`) AS FlightCount
FROM Maindata GROUP BY `From - To City` ORDER BY FlightCount DESC LIMIT 10;

#Load Factor on Weekends vs. Weekdays
SELECT CASE WHEN DAYOFWEEK(STR_TO_DATE(CONCAT(Year, '-', `Month (#)`, '-', Day), '%Y-%m-%d')) IN (1, 7) THEN 'Weekend' ELSE 'Weekday' END AS DayType,
ROUND((SUM(`# Transported Passengers`) * 1.0 / NULLIF(SUM(`# Available Seats`), 0)), 2) AS LoadFactor, 
CONCAT(ROUND((SUM(`# Transported Passengers`) * 100.0 / (SELECT SUM(`# Transported Passengers`) FROM Maindata)), 2),'%') AS PercentageOfGrandTotal
FROM Maindata GROUP BY DayType;

#Number of Flights by Distance Group
SELECT `%Distance Group ID`AS Distancegroup, COUNT(`# Departures Performed`) AS Flights FROM Maindata
GROUP BY `%Distance Group ID` ORDER BY Flights DESC;



