/*
Source of exercises: https://lagunita.stanford.edu/courses/DB/SQL/SelfPaced/courseware/ch-sql/seq-exercise-sql_movie_query_extra/?child=first
*/

/*
You've started a new movie-rating website, and you've been collecting data on reviewers' ratings of various movies.
There's not much data yet, but you can still try out some interesting queries. Here's the schema:

Movie ( mID, title, year, director )
English: There is a movie with ID number mID, a title, a release year, and a director.

Reviewer ( rID, name )
English: The reviewer with ID number rID has a certain name.

Rating ( rID, mID, stars, ratingDate )
English: The reviewer rID gave the movie mID a number of stars rating (1-5) on a certain ratingDate.

Your queries will run over a small data set conforming to the schema. View the database. (You can also download the schema and data.)

Instructions: Each problem asks you to write a query in SQL.
To run your query against our back-end sample database using SQLite, click the "Submit" button.
You will see a display of your query result and the expected result. If the results match, your query will be marked "correct".
You may run as many queries as you like for each question.

Important Notes:

    Your queries are executed using SQLite, so you must conform to the SQL constructs supported by SQLite.
    Unless a specific result ordering is asked for, you can return the result rows in any order.
    You are to translate the English into a SQL query that computes the desired result over all possible databases.
        All we actually check is that your query gets the right answer on the small sample database.
        Thus, even if your solution is marked as correct, it is possible that your query does not correctly reflect the problem at hand.
        (For example, if we ask for a complex condition that requires accessing all of the tables,
        but over our small data set in the end the condition is satisfied only by Star Wars,
        then the query "select title from Movie where title = 'Star Wars'" will be marked correct even though it doesn't reflect the actual question.)
        Circumventing the system in this fashion will get you a high score on the exercises, but it won't help you learn SQL.
        On the other hand, an incorrect attempt at a general solution is unlikely to produce the right answer, so you shouldn't be led astray by our checking system.


You may perform these exercises as many times as you like, so we strongly encourage you to keep working with them until you complete the exercises with full credit.

*/


/*
Q1
Find the names of all reviewers who rated Gone with the Wind.
*/
SELECT DISTINCT R1.name
FROM Reviewer R1
JOIN Rating R2
    ON R1.rID = R2.rID
JOIN Movie M
    ON M.mID = R2.mID
WHERE M.title = 'Gone with the Wind';


/*
Q2
For any rating where the reviewer is the same as the director of the movie, return the reviewer name, movie title, and number of stars.
*/
SELECT R2.name, M.title, R1.stars
FROM Rating R1
JOIN Reviewer R2
    ON R1.rID = R2.rID
JOIN Movie M
    ON M.mID = R1.mID
WHERE M.director = R2.name;
--OR
SELECT R2.name, M.title, R1.stars
FROM Rating R1
JOIN Reviewer R2
    ON R1.rID = R2.rID
JOIN Movie M
    ON M.mID = R1.mID
    AND M.director = R2.name;


/* 
Q3
Return all reviewer names and movie names together in a single list, alphabetized.
(Sorting by the first name of the reviewer and first word in the title is fine; no need for special processing on last names or removing "The".)
*/
SELECT *
FROM (
    SELECT name
    FROM Reviewer
    UNION ALL
    SELECT title
    FROM Movie
    ) Z
ORDER BY 1;


/* 
Q4
Find the titles of all movies not reviewed by Chris Jackson.
*/
SELECT title
FROM Movie
WHERE mID NOT IN (
                SELECT R2.mID
                FROM Reviewer R1
                JOIN Rating R2
                    ON R1.rID = R2.rID
                WHERE R1.name = 'Chris Jackson'
                );


/* 
Q5
For all pairs of reviewers such that both reviewers gave a rating to the same movie, return the names of both reviewers.
Eliminate duplicates, don't pair reviewers with themselves, and include each pair only once.
For each pair, return the names in the pair in alphabetical order.
*/
SELECT DISTINCT R1.name, R2.name
FROM Reviewer R1
JOIN Reviewer R2
    ON R1.name < R2.name
JOIN Rating RR1
    ON RR1.rID = R1.rID
JOIN Rating RR2
    ON RR2.rID = R2.rID
WHERE RR1.mID = RR2.mID;


/* 
Q6
For each rating that is the lowest (fewest stars) currently in the database, return the reviewer name, movie title, and number of stars.
*/
SELECT R2.name, M.title, R1.stars
FROM Rating R1
JOIN Reviewer R2
    ON R1.rID = R2.rID
JOIN Movie M
    ON M.mID = R1.mID
WHERE R1.stars = (SELECT MIN(stars) FROM Rating)


/* 
Q7
List movie titles and average ratings, from highest-rated to lowest-rated.
If two or more movies have the same average rating, list them in alphabetical order.
*/
SELECT M.title, AVG(R.stars)
FROM Movie M
JOIN Rating R
    ON R.mID = M.mID
GROUP BY M.mID
ORDER BY 2 DESC, 1;


/* 
Q8
Find the names of all reviewers who have contributed three or more ratings.
(As an extra challenge, try writing the query without HAVING or without COUNT.)
*/
SELECT R1.name
FROM Reviewer R1
WHERE 3 <= (
            SELECT COUNT(R2.rID)
            FROM Rating R2
            WHERE R2.rID = R1.rID);

SELECT R1.name
FROM Reviewer R1
JOIN Rating R2
    ON R2.rID = R1.rID
GROUP BY R1.rID
HAVING COUNT(R1.rID) >= 3;

SELECT Z.name
FROM (
        SELECT RE.name, COUNT(RE.rID) AS Cnt
        FROM Reviewer RE
        JOIN Rating RA
            ON RA.rID = RE.rID
        GROUP BY RE.name
        ) Z
WHERE Z.Cnt >=3;


/* 
Q9
Some directors directed more than one movie. For all such directors, return the titles of all movies directed by them, along with the director name.
Sort by director name, then movie title. (As an extra challenge, try writing the query both with and without COUNT.)

*/
SELECT title, director
FROM Movie
WHERE director in (
                    SELECT director
                    FROM Movie
                    GROUP BY director
                    HAVING COUNT(director) > 1
                    )
ORDER BY director, title;

SELECT M1.title, M1.director
FROM Movie M1
JOIN Movie M2
    ON M1.director = M2.director
    AND M1.mID <> M2.mID
ORDER BY M1.director, M1.title;

SELECT M1.title, M1.director
FROM Movie M1, Movie M2
WHERE M1.director = M2.director
AND M1.mID <> M2.mID
ORDER BY M1.director, M1.title;


/*
Q10
Find the movie(s) with the highest average rating. Return the movie title(s) and average rating.
(Hint: This query is more difficult to write in SQLite than other systems;
you might think of it as finding the highest average rating and then choosing the movie(s) with that average rating.)
*/
SELECT M.title, AVG(R.stars)
FROM Movie M
JOIN Rating R
    ON M.mID = R.mID
GROUP BY M.mID
HAVING AVG(R.stars) = (
                        SELECT MAX(Avg)
                        FROM (
                            SELECT AVG(stars) Avg
                            FROM Rating
                            GROUP BY mID
                            )
                       );

/*
Q11
Find the movie(s) with the lowest average rating. Return the movie title(s) and average rating.
(Hint: This query may be more difficult to write in SQLite than other systems;
you might think of it as finding the lowest average rating and then choosing the movie(s) with that average rating.)
*/
SELECT M.title, AVG(R.stars)
FROM Movie M
JOIN Rating R
    ON M.mID = R.mID
GROUP BY M.mID
HAVING AVG(R.stars) = (
                        SELECT MIN(Avg)
                        FROM (
                            SELECT AVG(stars) Avg
                            FROM Rating
                            GROUP BY mID
                            )
                       );


/*
Q12
For each director, return the director's name together with the title(s) of the movie(s) they directed that received
the highest rating among all of their movies, and the value of that rating.
Ignore movies whose director is NULL.
*/
SELECT M.director, M.title, MAX(R.stars)
FROM Movie M
JOIN Rating R
    ON M.mID = R.mID
WHERE director IS NOT NULL
GROUP BY M.director;
