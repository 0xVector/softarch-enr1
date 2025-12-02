## Exam DB For Students (Runtime, Availibility)
- what: Student Viewpoint tries to access ExamDB (normal operation) during peaks and this operation needs to succeed within 2 seconds.
- how: Student Viewpoint --- (unable to read ExamDB) ---> ExamDB --- (mask & reload, log) ---> 2s downtime
- solution: Student Viewpoint will check the heartbeat of the ExamDB.
- reasoning: Student often want to sign up for exams as soon as possible, free available space is also limited. Hence a high availibility is required.
Students need to be assured they have signed up successfully.

## Exam DB For Teacher (Runtime, Availibility)
- what: Teacher Viewpoint tries to access ExamDB (normal operation) and this operation needs to succeed within an hour.
- how: Student Viewpoint --- (unable to read ExamDB) ---> ExamDB --- (mask & reload, log) ---> 1h downtime
- reasoning: Teachers are not pressured to create exams / change them / distribute marks, plus they're more understanding. 1h downtime should be fair.
- solution: Teacher Viewpoint will check the heartbeat of the ExamDB.

>>> Separation of DB Availibility of teacher / student viewpoint

## Exam perioid sign-up (Runtime, Performance)
- what: Student wants to sign up for an exam and the system must be responsive enough even during high times.
- how: Student --- (signing up for an exam during exam period (high demand)) --> 

## DOS Attacks (Runtime, Security)
- what: an attacker tries to block the exam

## DB access (Runtime, Security)
- what: attempt to access the DB outside of the Student and Teacher Viewpoints
- how: direct DB access attempt ---> DB --- (block & log) ---> deny access
- solution: DB will only accept connections from Student and Teacher Viewpoints.

## Student can only view own data (Runtime, Security)
- what: a student tries to access another student's or teacher's data
- how: Student A ---> (attempt to access Student B's data) ---> Student Viewpoint ---> (block & log) ---> deny access  
OR  
Student ---> (attempt to access Teacher's data) ---> Student Viewpoint ---> (block & log) ---> deny access

## System correctly scales up and down with demand (Runtime, Elasticity)
- what: the system must be able to handle high loads during exam sign-up periods and scale down during off-peak times.
- how: during high demand periods ---> system scales up resources, during low demand periods ---> system scales down resources

## Interoperability with the rest of the SIS (Design, Interoperability)
- what: the exam system must be able to communicate with the rest of the system
- how: Exam System ---> (data exchange) ---> SIS

**TODO:** iterate on the C4 model to add qualitative requirements

Q: How to formulate security requirements?
A: From PoV from the problematic behaviour (eg. student tries to access another student's data - maybe not via UI but via API call) -> expected system behaviour.  
Also e.g.: angry teacher writes fail grade to all students, or angry student colludes with another students to write bad reviews about a teacher.