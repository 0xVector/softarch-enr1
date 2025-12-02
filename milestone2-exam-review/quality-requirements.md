## Exam DB For Students (Availibility)
- what: Student Viewpoint tries to access ExamDB (normal operation) during peaks and this operation needs to succeed within 2 seconds.
- how: Student Viewpoint --- (unable to read ExamDB) ---> ExamDB --- (mask & reload, log) ---> 2s downtime
- solution: Student Viewpoint will check the heartbeat of the ExamDB.
- reasoning: Student often want to sign up for exams as soon as possible, free available space is also limited. Hence a high availibility is required.
Students need to be assured they have signed up successfully.

## Exam DB For Teacher (Availibility)
- what: Teacher Viewpoint tries to access ExamDB (normal operation) and this operation needs to succeed within an hour.
- how: Student Viewpoint --- (unable to read ExamDB) ---> ExamDB --- (mask & reload, log) ---> 1h downtime
- reasoning: Teachers are not pressured to create exams / change them / distribute marks, plus they're more understanding. 1h downtime should be fair.
- solution: Teacher Viewpoint will check the heartbeat of the ExamDB.

>>> Separation of DB Availibility of teacher / student viewpoint

## Exam perioid sign-up (Performance)
- what: Student wants to sign up for an exam and the system must be responsive enough even during high times.
- how: Student --- (signing up for an exam during exam period (high demand)) --> 

## DOS Attacks (Security)
- what: an attacker tries to block the exam