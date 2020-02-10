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

Your triggers will run over a small data set conforming to the schema. View the database. (You can also download the schema and data.)

For your convenience, here is a graph showing the various connections between the people in our database.
9th graders are blue, 10th graders are green, 11th graders are yellow, and 12th graders are purple.
Undirected black edges indicate friendships, and directed red edges indicate that one person likes another person.
Social graph



Instructions:
You are to solve each of the following problems by writing one or more triggers.
Our back-end creates triggers using SQLite on the original state of the sample database.
It then performs a data modification statement that activate the trigger(s),
runs a query to check that the final database state is correct, and restores the database to its original state.
When you're satisfied with your solution for a given problem, click the "Submit" button to check your answer.

Important Notes:
    Our backend system is SQLite, so you must conform to the trigger constructs supported by SQLite.
        A guide to SQLite triggers is here, although you may find it easier to start from the triggers used in the video demonstrations.
    In the workbench and the grading program, triggers are executed with recursive triggering disabled ("recursive_triggers=off").
    You are to translate the English into one or more triggers that perform the desired actions for all possible databases and modifications.
        All we actually check is that the verification query gets the right answer on the small sample database.
        Thus, even if your solution is marked as correct, it is possible that your solution does not correctly reflect the problem at hand.
        Circumventing the system in this fashion will get you a high score on the exercises, but it won't help you learn about triggers.
        On the other hand, an incorrect attempt at a general solution is unlikely to behave correctly, so you shouldn't be led astray by our checking system.


You may perform these exercises as many times as you like, so we strongly encourage you to keep working with them until you complete the exercises with full credit.
*/




/* 1
Write a trigger that makes new students named 'Friendly' automatically like everyone else in their grade.
That is, after the trigger runs, we should have ('Friendly', A) in the Likes table for every other Highschooler A in the same grade as 'Friendly'.
    Your triggers are created in SQLite, so you must conform to the trigger constructs supported by SQLite.
*/
CREATE TRIGGER trFriendly
AFTER INSERT ON Highschooler
FOR EACH ROW
WHEN (new.name = 'Friendly')
BEGIN
    INSERT INTO Likes
    SELECT new.ID, ID
    FROM Highschooler
    WHERE grade = new.grade AND ID <> new.ID;
END;


CREATE TRIGGER trFriendly
AFTER INSERT ON Highschooler
FOR EACH ROW
BEGIN
    INSERT INTO Likes
    SELECT new.ID, H.ID
    FROM Highschooler H
    WHERE new.name = 'Friendly' AND H.grade = new.grade AND H.ID <> new.ID;
END;


CREATE TRIGGER trFriendly
AFTER INSERT ON Highschooler
FOR EACH ROW
BEGIN
    INSERT INTO Likes
    SELECT H1.ID, H2.ID
    FROM Highschooler H1,Highschooler H2
    WHERE H1.ID = new.ID AND H1.name = "Friendly"
    AND  H2.grade = H1.grade AND H1.ID <> H2.ID;
END;




/* 2
Write one or more triggers to manage the grade attribute of new Highschoolers.
If the inserted tuple has a value less than 9 or greater than 12, change the value to NULL.
On the other hand, if the inserted tuple has a null value for grade, change it to 9.
    Your triggers are created in SQLite, so you must conform to the trigger constructs supported by SQLite.
    To create more than one trigger, separate the triggers with a vertical bar (|).
*/
CREATE TRIGGER trGrades1
AFTER INSERT ON Highschooler
FOR EACH ROW
BEGIN
    UPDATE Highschooler
    SET grade = NULL
    WHERE new.ID = ID AND (new.grade < 9 OR new.grade > 12);
    UPDATE Highschooler
    SET grade = 9
    WHERE new.ID = ID AND new.grade IS NULL;
END;


CREATE TRIGGER trGrade1
AFTER INSERT ON Highschooler
FOR EACH ROW
WHEN (new.grade NOT BETWEEN 9 AND 12)
BEGIN
    UPDATE Highschooler
    SET grade = NULL
    WHERE ID = new.ID;
END;
|
CREATE TRIGGER trGrade2
AFTER INSERT ON Highschooler
FOR EACH ROW
WHEN (new.grade IS NULL)
BEGIN
    UPDATE Highschooler
    SET grade = 9
    WHERE ID = new.ID;
END;




/* 3
Write one or more triggers to maintain symmetry in friend relationships.
Specifically, if (A,B) is deleted from Friend, then (B,A) should be deleted too.
If (A,B) is inserted into Friend then (B,A) should be inserted too. Don't worry about updates to the Friend table.
    Your triggers are created in SQLite, so you must conform to the trigger constructs supported by SQLite.
    To create more than one trigger, separate the triggers with a vertical bar (|).
*/
CREATE TRIGGER trFr1
AFTER INSERT ON Friend
FOR EACH ROW
WHEN NOT EXISTS (SELECT * FROM Friend WHERE ID1 = new.ID2 AND ID2 = new.ID1)
BEGIN
    INSERT INTO Friend
    VALUES (new.ID2, new.ID1);
END;
|
CREATE TRIGGER trFr2
AFTER DELETE ON Friend
FOR EACH ROW
BEGIN
    DELETE
    FROM Friend
    WHERE ID1 = old.ID2 AND ID2 = old.ID1;
END;


CREATE TRIGGER trInsFriend
AFTER INSERT ON Friend
FOR EACH ROW
BEGIN
    INSERT INTO Friend
    SELECT new.ID2, new.ID1
    EXCEPT
    SELECT ID1, ID2
    FROM Friend;
END;
|
CREATE TRIGGER trDelFriend
AFTER DELETE ON Friend
FOR EACH ROW
BEGIN
    DELETE FROM Friend
    WHERE ID1 = old.ID2 AND ID2 = old.ID1;
END;



/* 4
Write a trigger that automatically deletes students when they graduate, i.e., when their grade is updated to exceed 12.
    Your triggers are created in SQLite, so you must conform to the trigger constructs supported by SQLite.
*/
CREATE TRIGGER trGraduation
AFTER UPDATE ON Highschooler
FOR EACH ROW
WHEN new.grade > 12
BEGIN
    DELETE FROM Highschooler
    WHERE ID = new.ID;
END;


CREATE TRIGGER trDel
AFTER UPDATE OF grade ON Highschooler
FOR EACH ROW
WHEN new.grade > 12
BEGIN
    DELETE FROM Highschooler
    WHERE ID = new.ID;
END;


CREATE TRIGGER trGraduate
AFTER UPDATE ON Highschooler
FOR EACH ROW
BEGIN
    DELETE FROM Highschooler
    WHERE grade > 12;
END;


/* 5
Write a trigger that automatically deletes students when they graduate, i.e., when their grade is updated to exceed 12 (same as Question 4).
In addition, write a trigger so when a student is moved ahead one grade, then so are all of his or her friends.
    Your triggers are created in SQLite, so you must conform to the trigger constructs supported by SQLite.
    To create more than one trigger, separate the triggers with a vertical bar (|).
*/
CREATE TRIGGER trGraduation
AFTER UPDATE ON Highschooler
FOR EACH ROW
WHEN (new.grade > 12)
BEGIN
    DELETE FROM Highschooler
    WHERE ID = new.ID;
END;
|
CREATE TRIGGER trAhead
AFTER UPDATE of grade ON Highschooler
FOR EACH ROW
WHEN new.grade > old.grade
BEGIN
    UPDATE Highschooler
    SET grade = grade + 1
    WHERE ID IN (SELECT ID2 FROM Friend WHERE ID1 = new.ID);
END;


CREATE TRIGGER trGrades
AFTER UPDATE OF grade ON Highschooler
FOR EACH ROW
WHEN new.grade > old.grade
BEGIN
    UPDATE Highschooler
    SET grade = grade + 1
    WHERE ID IN
                (SELECT ID2
                FROM Friend
                WHERE ID1 = new.ID);
    DELETE FROM Highschooler
    WHERE grade > 12;
END;




/* 6
Write a trigger to enforce the following behavior: If A liked B but is updated to A liking C instead, and B and C were friends, make B and C no longer friends.
Don't forget to delete the friendship in both directions, and make sure the trigger only runs when the "liked" (ID2) person is changed but the "liking" (ID1) person is not changed.
    Your triggers are created in SQLite, so you must conform to the trigger constructs supported by SQLite.
*/
CREATE TRIGGER trFriends
AFTER UPDATE ON Likes
WHEN (old.ID1 = new.ID1 AND old.ID2 <> new.ID2)
BEGIN
    DELETE
    FROM Friend
    WHERE (ID1 = old.ID2 AND ID2 = new.ID2)
    OR (ID1 = new.ID2 AND ID2 = old.ID2);
END;


