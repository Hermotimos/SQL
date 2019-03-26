/*
Source of exercises: https://lagunita.stanford.edu/courses/DB/SQL/SelfPaced/courseware/ch-sql/seq-exercise-sql_social_query_extra/?child=first
*/

/*
Students at your hometown high school have decided to organize their social network using databases. So far, they have collected information about sixteen students in four grades, 9-12. Here's the schema:

Highschooler ( ID, name, grade )
English: There is a high school student with unique ID and a given first name in a certain grade.

Friend ( ID1, ID2 )
English: The student with ID1 is friends with the student with ID2. Friendship is mutual, so if (123, 456) is in the Friend table, so is (456, 123).

Likes ( ID1, ID2 )
English: The student with ID1 likes the student with ID2. Liking someone is not necessarily mutual, so if (123, 456) is in the Likes table, there is no guarantee that (456, 123) is also present.

Your queries will run over a small data set conforming to the schema. View the database. (You can also download the schema and data.)
For your convenience, here is a graph showing the various connections between the students in our database. 9th graders are blue, 10th graders are green, 11th graders are yellow, and 12th graders are purple. Undirected black edges indicate friendships, and directed red edges indicate that one student likes another student.
Social graph

Instructions: Each problem asks you to write a query in SQL. When you click "Check Answer" our back-end runs your query against the sample database using SQLite. It displays the result and compares your answer against the correct one. When you're satisfied with your solution for a given problem, click the "Save Answers" button to save your progress. Click "Submit Answers" to submit the entire exercise set. 
*/


/* 1 
For every situation where student A likes student B, but student B likes a different student C, return the names and grades of A, B, and C. 
*/
SELECT H1.name, H1.grade, H2.name, H2.grade, H3.name, H3.grade
FROM Likes L1
JOIN Likes L2
    ON L1.ID2 = L2.ID1
JOIN Highschooler H1
    ON L1.ID1 = H1.ID
JOIN Highschooler H2
    ON L1.ID2 = H2.ID
JOIN Highschooler H3
    ON L2.ID2 = H3.ID
WHERE H1.ID <> H3.ID;


/* 2
Find those students for whom all of their friends are in different grades from themselves. Return the students' names and grades. 
*/
SELECT H.name, H.grade
FROM Highschooler H
WHERE H.grade NOT IN
                (SELECT H2.grade
                FROM Friend F
                JOIN Highschooler H1
                    ON F.ID1 = H1.ID
                JOIN Highschooler H2
                    ON F.ID2 = H2.ID
                WHERE H.ID = F.ID1);


/* 3 
What is the average number of friends per student? (Your result should be just one number.) 
*/
SELECT AVG(Cnt)
FROM 
    (SELECT COUNT(ID2) AS Cnt
    FROM Friend
    GROUP BY ID1);


/* 4 
Find the number of students who are either friends with Cassandra or are friends of friends of Cassandra. Do not count Cassandra, even though technically she is a friend of a friend. 
*/
SELECT
(SELECT COUNT(ID2)
FROM Friend F
JOIN Highschooler H
    ON F.ID1 = H.ID
WHERE H.name = 'Cassandra')
+
(SELECT COUNT(F2.ID2)
FROM Friend F1
JOIN Friend F2
    ON F1.ID2 = F2.ID1
    AND F1.ID1 <> F2.ID2
JOIN Highschooler H
    ON F1.ID1 = H.ID
WHERE H.name = 'Cassandra');


/* 5 
Find the name and grade of the student(s) with the greatest number of friends.
*/
SELECT H.name, H.grade
FROM Friend F
JOIN Highschooler H
    ON H.ID = F.ID1
GROUP BY F.ID1
HAVING COUNT(F.ID2) = 
                    (SELECT MAX(Cnt)
                    FROM
                        (SELECT COUNT(ID2) AS Cnt
                        FROM Friend 
                        GROUP BY ID1));
