/*
Source of exercises: https://lagunita.stanford.edu/courses/DB/SQL/SelfPaced/courseware/ch-sql/seq-exercise-sql_social_query_core/?activate_block_id=i4x%3A%2F%2FDB%2FSQL%2Fsequential%2Fseq-exercise-sql_social_query_core
*/

/*
Students at your hometown high school have decided to organize their social network using databases.
So far, they have collected information about sixteen students in four grades, 9-12. Here's the schema:

Highschooler ( ID, name, grade )
English: There is a high school student with unique ID and a given first name in a certain grade.

Friend ( ID1, ID2 )
English: The student with ID1 is friends with the student with ID2. Friendship is mutual, so if (123, 456) is in the Friend table, so is (456, 123).

Likes ( ID1, ID2 )
English: The student with ID1 likes the student with ID2.
Liking someone is not necessarily mutual, so if (123, 456) is in the Likes table, there is no guarantee that (456, 123) is also present.

Your queries will run over a small data set conforming to the schema. View the database. (You can also download the schema and data.)

For your convenience, here is a graph showing the various connections between the students in our database.
9th graders are blue, 10th graders are green, 11th graders are yellow, and 12th graders are purple.
Undirected black edges indicate friendships, and directed red edges indicate that one student likes another student.
Social graph
[social.png]

Instructions: Each problem asks you to write a query in SQL. To run your query against our back-end sample database using SQLite, click the "Submit" button.
You will see a display of your query result and the expected result. If the results match, your query will be marked "correct". You may run as many queries as you like for each question.

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


/* 1 
Find the names of all students who are friends with someone named Gabriel. 
*/
SELECT H.name
FROM Highschooler H
JOIN Friend F
    ON H.ID = F.ID1
WHERE F.ID2 IN (
            SELECT ID
            FROM Highschooler
            WHERE name = 'Gabriel'
            );

SELECT name
FROM Highschooler
WHERE ID IN (
            SELECT F.ID2
            FROM Highschooler H
            JOIN Friend F
                ON H.ID = F.ID1
            WHERE H.name = 'Gabriel'
            );

SELECT H1.name
FROM Highschooler H1
JOIN Highschooler H2
    ON H1.ID <> H2.ID
JOIN Friend F
    ON H1.ID = F.ID1
AND H2.ID = F.ID2
WHERE H2.name = 'Gabriel';



/* 2
For every student who likes someone 2 or more grades younger than themselves, return that student's name and grade, and the name and grade of the student they like. 
*/
SELECT H1.name, H1.grade, H2.name, H2.grade
FROM Likes L
JOIN Highschooler H1
    ON L.ID1 = H1.ID
JOIN Highschooler H2
    ON L.ID2 = H2.ID
WHERE H1.grade >= H2.grade+2;

SELECT H1.name, H1.grade, H2.name, H2.grade
FROM Highschooler H1, Highschooler H2
JOIN Likes F
    ON F.ID1 = H1.ID AND F.ID2 = H2.ID
WHERE H1.grade >= H2.grade + 2;

SELECT H1.name, H1.grade, H2.name, H2.grade
FROM Highschooler H1
JOIN Highschooler H2
    ON H1.grade >= H2.grade + 2
JOIN Likes L
    ON H1.ID = L.ID1 AND H2.ID = L.ID2;



/* 3 
For every pair of students who both like each other, return the name and grade of both students. Include each pair only once, with the two names in alphabetical order. 
*/
SELECT H1.name, H1.grade, H2.name, H2.grade
FROM Likes L2
JOIN Highschooler H1
	ON L2.ID1 = H1.ID
JOIN Highschooler H2
	ON L2.ID2 = H2.ID
WHERE H1.name < H2.name
AND EXISTS (
            SELECT *
            FROM Likes L1
            WHERE L1.ID1 = L2.ID2 AND L1.ID2 = L2.ID1
            );


SELECT H1.name, H1.grade, H2.name, H2.grade
FROM Highschooler H1, Highschooler H2
JOIN Likes L
    ON L.ID1 = H1.ID AND L.ID2 = H2.ID
WHERE H1.name < H2.name
AND EXISTS (
             SELECT *
             FROM Likes LL
             WHERE LL.ID1 = H2.ID AND LL.ID2 = H1.ID
             );


SELECT H1.name, H1.grade, H2.name, H2.grade
FROM Likes L1
JOIN Likes L2
    ON L1.ID1 = L2.ID2 AND L1.ID2 = L2.ID1
JOIN Highschooler H1
    ON L1.ID1 = H1.ID
JOIN Highschooler H2
    ON L1.ID2 = H2.ID
WHERE H1.name < H2.name;




/* 4 
Find all students who do not appear in the Likes table (as a student who likes or is liked) and return their names and grades. Sort by grade, then by name within each grade. 
*/
SELECT name, grade
FROM Highschooler
WHERE ID NOT IN (
                SELECT ID1
                FROM Likes
                UNION           -- OR UNION ALL
                SELECT ID2
                FROM Likes
                )
ORDER BY grade, name;




/* 5 
For every situation where student A likes student B, but we have no information about whom B likes (that is, B does not appear as an ID1 in the Likes table), return A and B's names and grades. 
*/
SELECT H1.name, H1.grade, H2.name, H2.grade
FROM Likes L
JOIN Highschooler H1
    ON L.ID1 = H1.ID
JOIN Highschooler H2
    ON L.ID2 = H2.ID
WHERE L.ID2 NOT IN (
                SELECT ID1
                FROM Likes
                );




/* 6 
Find names and grades of students who only have friends in the same grade. Return the result sorted by grade, then by name within each grade.
*/
SELECT H1.name, H1.grade
FROM Highschooler H1, Highschooler H2
JOIN Friend F
    ON F.ID1 = H1.ID AND F.ID2 = H2.ID
WHERE H1.grade = H2.grade
EXCEPT
SELECT H1.name, H1.grade
FROM Highschooler H1, Highschooler H2
JOIN Friend F
    ON F.ID1 = H1.ID AND F.ID2 = H2.ID
WHERE H1.grade <> H2.grade
ORDER BY H1.grade, H1.name;


SELECT HH.name, HH.grade
FROM Highschooler HH
WHERE NOT EXISTS (
                    SELECT *
                    FROM Friend F
                    JOIN Highschooler H1
                        ON F.ID1 = H1.ID
                    JOIN Highschooler H2
                        ON F.ID2 = H2.ID
                    WHERE H1.grade <> H2.grade
                    AND H1.ID = HH.ID
                    )
ORDER BY HH.grade, HH.name;


/* 7 
For each student A who likes a student B where the two are not friends, find if they have a friend C in common (who can introduce them!). For all such trios, return the name and grade of A, B, and C. 
*/
-- New solution:
SELECT DISTINCT H1.name, H1.grade, H2.name, H2.grade, H3.name, H3.grade
FROM Highschooler H1, Highschooler H2, Highschooler H3
-- Select only those H1 and H2 that H1 likes H2 (A likes B)
JOIN Likes L
    ON H1.ID = L.ID1 AND H2.ID = L.ID2
-- Select only thise H3 who are common friends of H1 and H2
WHERE H3.ID IN (
                -- Find common friends of A and B (H1.ID = A, H2.ID = B)
                SELECT F.ID2
                FROM Friend F
                WHERE F.ID1 = H1.ID
                INTERSECT
                SELECT F.ID2
                FROM Friend F
                WHERE F.ID1 = H2.ID
                )
AND NOT EXISTS (
                -- Ensure A and B are not friends (H1.ID = A, H2.ID = B)
                SELECT *
                FROM Friend FF
                WHERE H1.ID = FF.ID1 AND H2.ID = FF.ID2
                );

-- The older solution, which I no more understand:
SELECT H1.name, H1.grade, H2.name, H2.grade, H3.name, H3.grade
FROM Likes L
JOIN Highschooler H1             
    ON H1.ID = L.ID1            
JOIN Highschooler H2            
    ON H2.ID = L.ID2
JOIN Friend F1
    ON L.ID1 = F1.ID1
JOIN Friend F2
    ON L.ID2 = F2.ID1
JOIN Highschooler H3
    ON H3.ID = F2.ID2
WHERE L.ID1 NOT IN    
                    (SELECT FF.ID1
                    FROM Friend FF
                    WHERE L.ID1 = FF.ID1 AND L.ID2 = FF.ID2)
AND F1.ID2 = F2.ID2;




/* 8 
Find the difference between the number of students in the school and the number of different first names. 
*/
SELECT COUNT(ID) - COUNT(DISTINCT Name)
FROM Highschooler;




/* 9 
Find the name and grade of all students who are liked by more than one other student. 
*/
SELECT name, grade
FROM (SELECT ID2, COUNT(ID2)
            FROM Likes
            GROUP BY ID2
            HAVING COUNT(ID2) >1) S
JOIN Highschooler H
   ON H.ID = S.ID2;


SELECT name, grade
FROM Highschooler
WHERE ID IN (
                SELECT ID2
                FROM Likes
                GROUP BY ID2
                HAVING COUNT(*) > 1
                );


SELECT H.name, H.grade
FROM Highschooler H
JOIN Likes L
    ON H.ID = L.ID2
GROUP BY L.ID2
HAVING COUNT(L.ID2) > 1;

