/*
Source: https://lagunita.stanford.edu/courses/DB/Indexes/SelfPaced/courseware/ch-indexes/seq-quiz-transactions/?activate_block_id=i4x%3A%2F%2FDB%2FIndexes%2Fsequential%2Fseq-quiz-transactions
*/

/*
Each multiple-choice quiz problem is based on a "root question,"
from which the system generates different correct and incorrect choices each time you take the quiz.
Thus, you can test yourself on the same material multiple times.
We strongly urge you to continue testing on each topic until you complete the quiz with a perfect score at least once.
Simply click the "Reset" button at the bottom of the page for a new variant of the quiz.

After submitting your selections, the system will score your quiz,
and for incorrect answers will provide an "explanation" (sometimes for correct ones too).
These explanations should help you get the right answer the next time around. To prevent rapid-fire guessing,
the system enforces a minimum of 10 minutes between each submission of solutions.
*/




/* 1
Consider tables R(A) and S(B) and the following transaction T1:
*/
set transaction isolation level repeatable read;
    select * from R;
    select * from R;
    select * from S;
    commit;
/*
Suppose table R initially has one tuple with value A=3 and table S initially has one tuple with value B=6.
Consider the following possible transactions T2, executed around the same time as T1.
Which one of them can cause the two transactions to exhibit nonserializable behavior?

T2: set transaction isolation level serializable; delete from S; insert into S values (6); commit;
T2: set transaction isolation level serializable; update S set B=7; commit;
T2: set transaction isolation level serializable; update S set B=5; delete from R; commit; correct
T2: set transaction isolation level serializable; delete from R where A=3; commit;

Solution:
I thought I understand it, but it seems I don't...
*/




/* 2
Consider a relation R(x) containing integers. Suppose Alice runs a transaction that is a query:
*/
   select sum(x) from R;
   commit;
/*
Betty's transaction is a sequence of inserts:
*/
   insert into R values (10);
   insert into R values (20);
   insert into R values (30);
   commit;
/*
Carol's transaction is a sequence of deletes:
*/
   delete from R where x=30;
   delete from R where x=20;
   commit;
/*
Before any of these transactions execute, the sum of the integers in R is 1000, and none of the integers are 10, 20, or 30.
If Alice's, Betty's, and Carol's transactions run at about the same time, and each runs under isolation level READ COMMITTED,
which of the following sums could be produced by Alice's transaction?

950
1010 correct
970
1020
Solution: All transactions have to take place in some order: T1,T2,T3 or T1,T3,T2 or T2,T1,T3 or T2,T3,T1 etc.
If the order is T2, T3, T1, then the result of T1 is 1010 (1000 + 60 - 50).
*/




/* 3
Consider a relation R(x) containing integers. Suppose Alice runs a transaction that is a query:
*/
   select sum(x) from R;
   commit;
/*
Betty's transaction is a sequence of inserts:
*/
   insert into R values (10);
   insert into R values (20);
   insert into R values (30);
   commit;
/*
Carol's transaction is a sequence of deletes:
*/
   delete from R where x=30;
   delete from R where x=20;
   commit;
/*
Before any of these transactions execute, the sum of the integers in R is 1000, and none of these integers are 10, 20, or 30.
Alice's, Betty's, and Carol's transactions run at about the same time.
Which of the following sums could be returned by Alice's transaction
if all three transactions run under isolation level READ UNCOMMITTED,
but not if all three run under isolation level SERIALIZABLE?

1020
1000
1030 correct => If T1 is performed after second insert in T2.
1060
*/