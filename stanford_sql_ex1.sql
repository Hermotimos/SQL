/*
Source of exercises: https://lagunita.stanford.edu/courses/DB/SQL/SelfPaced/courseware/ch-sql/seq-exercise-sql_movie_query_extra/?child=first
*/

/*
You've started a new movie-rating website, and you've been collecting data on reviewers' ratings of various movies. There's not much data yet, but you can still try out some interesting queries. Here's the schema:

Movie ( mID, title, year, director )
English: There is a movie with ID number mID, a title, a release year, and a director.

Reviewer ( rID, name )
English: The reviewer with ID number rID has a certain name.

Rating ( rID, mID, stars, ratingDate )
English: The reviewer rID gave the movie mID a number of stars rating (1-5) on a certain ratingDate.

Your queries will run over a small data set conforming to the schema. View the database. (You can also download the schema and data.)
Instructions: Each problem asks you to write a query in SQL. To run your query against our back-end sample database using SQLite, click the "Submit" button. You will see a display of your query result and the expected result. If the results match, your query will be marked "correct". You may run as many queries as you like for each question.

Important Notes:
    Your queries are executed using SQLite, so you must conform to the SQL constructs supported by SQLite.
    Unless a specific result ordering is asked for, you can return the result rows in any order.
    You are to translate the English into a SQL query that computes the desired result over all possible databases. All we actually check is that your query gets the right answer on the small sample database. Thus, even if your solution is marked as correct, it is possible that your query does not correctly reflect the problem at hand. (For example, if we ask for a complex condition that requires accessing all of the tables, but over our small data set in the end the condition is satisfied only by Star Wars, then the query "select title from Movie where title = 'Star Wars'" will be marked correct even though it doesn't reflect the actual question.) Circumventing the system in this fashion will get you a high score on the exercises, but it won't help you learn SQL. On the other hand, an incorrect attempt at a general solution is unlikely to produce the right answer, so you shouldn't be led astray by our checking system.

You may perform these exercises as many times as you like, so we strongly encourage you to keep working with them until you complete the exercises with full credit.
*/


/* 
Find the titles of all movies directed by Steven Spielberg. 
*/
SELECT title
FROM Movie
WHERE director = 'Steven Spielberg';
-- OR
SELECT title
FROM Movie
WHERE director LIKE '%Spielberg%';


/* 
Find all years that have a movie that received a rating of 4 or 5, and sort them in increasing order. 
*/
SELECT DISTINCT M.year
FROM Movie M
JOIN Rating R
    ON M.mID = R.mID
WHERE stars IN (4, 5)            
ORDER BY year;


/* 
Find the titles of all movies that have no ratings. 
*/
SELECT title
FROM Movie M
WHERE NOT EXISTS
    (SELECT R.mID
     FROM Rating R
     WHERE R.mID = M.mID);
-- OR
SELECT title
FROM Movie
WHERE mID NOT IN (
                SELECT mID
                FROM Rating
                );


/* 
Some reviewers didn't provide a date with their rating. Find the names of all reviewers who have ratings with a NULL value for the date.
*/
SELECT name
FROM Reviewer R1
JOIN Rating R2
    ON R1.rID = R2.rID
WHERE ratingDate IS NULL;
--OR
SELECT name
FROM Reviewer
WHERE rID in (
                SELECT rID
                FROM Rating
                WHERE ratingDate IS NULL
                );


/* 
Write a query to return the ratings data in a more readable format: reviewer name, movie title, stars, and ratingDate. Also, sort the data, first by reviewer name, then by movie title, and lastly by number of stars. 
*/

SELECT R2.name, M.title, R1.stars, R1.ratingDate
FROM Movie M
JOIN Rating R1
    ON M.mID = R1.mID
JOIN Reviewer R2
    ON R1.rID = R2.rID
ORDER BY R2.name, M.title, R1.stars;


/* 
For all cases where the same reviewer rated the same movie twice and gave it a higher rating the second time, return the reviewer's name and the title of the movie. 
*/
SELECT name, title
FROM
    (SELECT *
    FROM Rating R1
    JOIN Rating R2
        ON R1.rID = R2.rID
    WHERE R1.mID = R2.mID
    AND R1.rID = R2.rID
    AND R1.stars < R2.stars
    AND R1.ratingDate < R2.ratingDate) Z
JOIN Movie M
    ON Z.mID = M.mID
JOIN Reviewer R
    ON R.rID = Z.rID;
-- OR
SELECT R1.name, M.title
FROM Reviewer R1
JOIN Rating R2
    ON R1.rID = R2.rID
JOIN Rating R3
    ON R1.rID = R3.rID
JOIN Movie M
    ON R2.mID = M.mID
WHERE R2.mID = R3.mID
AND R2.ratingDate > R3.ratingDate
AND R2.stars > R3.stars;

/* 
For each movie that has at least one rating, find the highest number of stars that movie received. Return the movie title and number of stars. Sort by movie title. 
*/
SELECT M.title, MAX(R.stars)
FROM Movie M
JOIN Rating R
    ON M.mID = R.mID
GROUP BY M.title
ORDER BY M.title


/* 
For each movie, return the title and the 'rating spread', that is, the difference between highest and lowest ratings given to that movie. Sort by rating spread from highest to lowest, then by movie title. 
*/
SELECT title, MAX(stars) - MIN(stars) AS RatingSpread
FROM Movie M
JOIN Rating R1
    ON M.mID = R1.mID
GROUP BY title
ORDER BY RatingSpread DESC;
-- OR
SELECT M.title, (MAX(R.stars) - MIN(R.stars))
FROM Movie M
JOIN Rating R
    ON M.mID = R.mID
GROUP BY M.title
ORDER BY 2 DESC;

/* 
Find the difference between the average rating of movies released before 1980 and the average rating of movies released after 1980. (Make sure to calculate the average rating for each movie, then the average of those averages for movies before 1980 and movies after. Don't just calculate the overall average rating before and after 1980.) 
*/
SELECT
    (SELECT AVG(Avg1)
    FROM
        (SELECT title, year, AVG(stars) Avg1
        FROM Movie M
        JOIN Rating R1 ON M.mID = R1.mID
        GROUP BY title) DIFF1
    WHERE year <1980)
    -
    (SELECT AVG(Avg2)
    FROM
        (SELECT title, year, AVG(stars) Avg2
        FROM Movie M
        JOIN Rating R1 ON M.mID = R1.mID
        GROUP BY title) DIFF2
    WHERE year >1980);
-- OR
SELECT
    (SELECT AVG(AvgStars)
    FROM
        (SELECT AVG(R.stars) AvgStars
        FROM Rating R
        JOIN Movie M
            ON M.mID = R.mID
        WHERE M.year < 1980
        GROUP BY M.mID)
        DIFF1)
-
    (SELECT AVG(AvgStars)
    FROM
        (SELECT AVG(R.stars) AvgStars
        FROM Rating R
        JOIN Movie M
            ON M.mID = R.mID
        WHERE M.year > 1980
        GROUP BY M.mID)
        DIFF2);