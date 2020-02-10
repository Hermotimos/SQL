/*
Source of exercises: https://lagunita.stanford.edu/courses/DB/SQL/SelfPaced/courseware/ch-sql/seq-exercise-sql_social_mod/?child=first
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

Your modifications will run over a small data set conforming to the schema. View the database.
(You can also download the schema and data.)

For your convenience, here is a graph showing the various connections between the people in our database.
9th graders are blue, 10th graders are green, 11th graders are yellow, and 12th graders are purple.
Undirected black edges indicate friendships, and directed red edges indicate that one person likes another person.
[social.png]]

Instructions:
You are to write each of the following data modification commands using SQL.
Our back-end runs each modification using SQLite on the original state of the sample database.
It then performs a query over the modified database to check whether your command made the correct modification,
and restores the database to its original state.

You may perform these exercises as many times as you like, so we strongly encourage you to keep working with them until you complete the exercises with full credit.
*/


/* 1 
It's time for the seniors to graduate. Remove all 12th graders from Highschooler.
*/
DELETE
FROM Highschooler
WHERE grade = 12;


/* 2
If two students A and B are friends, and A likes B but not vice-versa, remove the Likes tuple.
*/
-- The main problem with this example is that SQLite or at least the version used in exercises does not accept aliases
-- with DELETE command; so target table has to be called by its full name in linked subqueries
DELETE
FROM Likes
WHERE EXISTS (
                SELECT *
                FROM Friend F
                WHERE Likes.ID1 = F.ID1 AND Likes.ID2 = F.ID2
                )
AND NOT EXISTS (
                SELECT *
                FROM Likes LL
                WHERE LL.ID1 = Likes.ID2 AND LL.ID2 = Likes.ID1
                );


-- OLDER SOLUTIONS WHICH ARE FAR TOO LONG AND UNNECESSARILY COMPLICATED AND STILL USE LINKED SUBQUERIES:
DELETE
FROM Likes
WHERE ID1 IN
    (SELECT L.ID1
    FROM Likes L
    JOIN Friend F
        ON L.ID1 = F.ID1
        AND L.ID2 = F.ID2
    WHERE NOT EXISTS
                    (SELECT LL.ID1, LL.ID2
                    FROM Likes LL
                    WHERE LL.ID1 = L.ID2 AND LL.ID2 = L.ID1))
AND ID2 IN
    (SELECT L.ID2
    FROM Likes L, Friend F
    WHERE L.ID1 = F.ID1 AND L.ID2 = F.ID2
    AND NOT EXISTS
                    (SELECT LL.ID1, LL.ID2
                    FROM Likes LL
                    WHERE LL.ID1 = L.ID2 AND LL.ID2 = L.ID1));

DELETE
FROM Likes
WHERE ID1 IN
    (SELECT Likes.ID1
    FROM Friend F
    WHERE Likes.ID1 = F.ID1 AND Likes.ID2 = F.ID2
    AND NOT EXISTS
                    (SELECT LL.ID1, LL.ID2
                    FROM Likes LL
                    WHERE LL.ID1 = Likes.ID2 AND LL.ID2 = Likes.ID1))
AND ID2 IN
    (SELECT Likes.ID2
    FROM Friend F
    WHERE Likes.ID1 = F.ID1 AND Likes.ID2 = F.ID2
    AND NOT EXISTS
                    (SELECT LL.ID1, LL.ID2
                    FROM Likes LL
                    WHERE LL.ID1 = Likes.ID2 AND LL.ID2 = Likes.ID1));



/* 3 
For all cases where A is friends with B, and B is friends with C, add a new friendship for the pair A and C.
Do not add duplicate friendships, friendships that already exist, or friendships with oneself.
(This one is a bit challenging; congratulations if you get it right.)
*/
INSERT INTO Friend
SELECT DISTINCT F1.ID1, F2.ID2
FROM Friend F1
JOIN Friend F2
    ON F1.ID2 = F2.ID1
    AND F1.ID1 <> F2.ID2
EXCEPT
SELECT *
FROM Friend;

