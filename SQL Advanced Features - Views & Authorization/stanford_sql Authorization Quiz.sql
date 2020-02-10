/*
https://lagunita.stanford.edu/courses/DB/Views/SelfPaced/courseware/ch-views/seq-quiz-authorization/?activate_block_id=i4x%3A%2F%2FDB%2FViews%2Fsequential%2Fseq-quiz-authorization
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
The following SQL statement over tables R(a,b), S(b,c), and T(a,c) requires certain privileges to execute:
*/
   UPDATE R
   SET a = 10
   WHERE b IN (SELECT c FROM S)
   AND NOT EXISTS (SELECT a FROM T WHERE T.a = R.a)
/*
Which of the following privileges is not useful for execution of this SQL statement?
UPDATE ON R(a)
SELECT ON T(b) correct
UPDATE ON R
SELECT ON S
*/




/* 2
 Consider a set of users A, B, C, D, E. Suppose user A creates a table T and thus is the owner of T. Now suppose the following set of statements is executed in order:

  1. User A: grant update on T to B,C with grant option
  2. User B: grant update on T to D with grant option
  3. User C: grant update on T to D with grant option
  4. User D: grant update on T to E
  5. User A: revoke update on T from C cascade

After execution of statement 5, which of the following is true?
A no longer has privilege UPDATE ON T
C has privilege UPDATE ON T
D no longer has privilege UPDATE ON T
B has privilege UPDATE ON T correct
*/




/* 3
The following SQL statement over tables R(c,d), S(f,g), and T(a,b) requires certain privileges to execute:
*/
   UPDATE T
   SET a=1, b=2
   WHERE a <= ALL (SELECT d FROM R)
   OR EXISTS (SELECT f FROM S WHERE f > T.a)
/*
Which of the following privileges is not useful for execution of this SQL statement?
INSERT ON T(b) correct
SELECT ON S
SELECT ON T
UPDATE ON T(a)
*/




/* 4
 Consider a set of users U, V, W, X, and Y. Suppose user U creates a table T and thus is the owner of T. Now suppose the following set of statements is executed in order:

  1. User U: grant select on T to V,W with grant option
  2. User V: grant select on T to W
  3. User W: grant select on T to X,Y
  4. User U: grant select on T to Y
  5. User U: revoke select on T from V restrict
  6. User U: revoke select on T from W cascade

Which of the following statements is true?

Y has privilege SELECT ON T after statement 6 correct
V has privilege SELECT ON T after statement 5
W does not have privilege SELECT ON T after statement 5
X does not have SELECT ON T privilege after statement 5
*/




