/*
https://lagunita.stanford.edu/courses/DB/Views/SelfPaced/courseware/ch-views/seq-quiz-views/?activate_block_id=i4x%3A%2F%2FDB%2FViews%2Fsequential%2Fseq-quiz-views
*/

/*
Each multiple-choice quiz problem is based on a "root question,"
from which the system generates different correct and incorrect choices each time you take the quiz.
Thus, you can test yourself on the same material multiple times.
We strongly urge you to continue testing on each topic until you complete the quiz with a perfect score at least once.
Simply click the "Reset" button at the bottom of the page for a new variant of the quiz.

After submitting your selections, the system will score your quiz,
and for incorrect answers will provide an "explanation" (sometimes for correct ones too).
These explanations should help you get the right answer the next time around.
To prevent rapid-fire guessing, the system enforces a minimum of 10 minutes between each submission of solutions.
*/


/* 1
Consider the following base tables. Capitalized attributes are primary keys.
All non-key attributes are permitted to be NULL.

   MovieStar(NAME, address, gender, birthdate)
   MovieExecutive(LICENSE#, name, address, netWorth)
   Studio(NAME, address, presidentLicense#)

Each of the choices describes, in English, a view that could be created with a query on these tables.
Which one can be written as a SQL view that is updatable according to the SQL standard?

1) A view "StudioPresInfo" containing the studio name, executive name, and license number for all executives who are studio presidents.
2) A view "NewYorkWealth" containing the average net worth of movie executives whose address contains "New York".
3) A view "GenderBalance" containing the number of male and number of female movie stars.
4) A view "NewYorkStudios" containing the names and addresses of all studios with addresses containing "New York". correct

SOLUTION:
1) The View could be written so that one of the attributes ommited in the view is non-nullable (LICENSE).
Whi is not allowed: Attributes not in view must be allowed to be NULL or have DEFAULT value.
*/
CREATE VIEW StudioPresInfo AS
    SELECT S.NAME, ME.name, S.presidentLicense
    FROM Studio S, MovieExecutive ME
    WHERE S.presidentLicense = ME.LICENSE
/*
2) Updatable views cannot contain aggregate functions (AVG)
3) Updatable views cannot contain aggregate functions (COUNT)
4) OK
*/




/* 2
Consider the following schema:

  Book(ISBN, title, year) // ISBN and title cannot be NULL
  Author(ISBN, name) // ISBN and name cannot be NULL

and the following view definition over this schema:
*/
  Create View V as
    Select Book.ISBN, count(*)
    From Book, Author
    Where Book.ISBN = Author.ISBN
    And Author.name Like 'A%'
    And Book.year > 2000
    Group By Book.ISBN
/*
This view is not updatable according to the SQL standard, for a number of reasons.
Which of the following is a valid reason for the view being non-updatable according to the standard?

The condition Author.name Like 'A%'
The condition Book.year > 2000
Book.year is omitted from the view
Use of aggregate function COUNT correct
*/




/* 3
Suppose a table T(A,B,C) has the following tuples: (1,1,3), (1,2,3), (2,1,4), (2,3,5), (2,4,1), (3,2,4), and (3,3,6). Consider the following view definition:
*/
Create View V as
    Select A+B as D, C
    From T
/*
Consider the following query over view V:
*/
    Select D, sum(C)
    From V
    Group By D
    Having Count(*) <> 1
/*
Which of the following tuples is in the query result?
(2,3)
(3,5)
(5,9) correct
(3,12)


SOLUTION
T
a   b   c
---------
1   1   3
1   2   3
2   1   4
2   3   5
2   4   1
3   2   4
3   3   6

V
d   c
-----
2   3
3   3
3   4
5   5
6   1
5   4
6   6

query result:
D   sum(c)
----------
3   7
5   9
6   7
*/




