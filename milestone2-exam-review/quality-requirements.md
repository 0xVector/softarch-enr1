# RUNTIME

## Exam DB For Students (Runtime, Availibility)
- what: Student Viewpoint tries to access ExamDB (normal operation) during peaks and this operation needs to succeed within 2 seconds.
- how: Student Viewpoint --- (unable to read ExamDB) ---> ExamDB --- (mask & reload, log) ---> 5s downtime
- solution: Student Viewpoint will check the heartbeat of the ExamDB.
- reasoning: Students often want to sign up for exams as soon as possible, free available space is also limited. Hence high availibility is required.
Students need to be assured they have signed up successfully.

## Exam DB For Teacher (Runtime, Availibility)
- what: Teacher Viewpoint tries to access ExamDB (normal operation) and this operation needs to succeed within an hour.
- how: Student Viewpoint --- (unable to read ExamDB) ---> ExamDB --- (mask & reload, log) ---> 1h downtime
- reasoning: Teachers are not pressured to create exams / change them / distribute marks, plus they're more understanding. 1h downtime should be fair.
- solution: Teacher Viewpoint will check the heartbeat of the ExamDB.

> Note: Separation of DB Availibility of teacher / student viewpoint

## Exam perioid sign-up (Runtime, Performance)
- what: Student wants to sign up for an exam and the system must be responsive enough even during high times.
- how: Student --- (signing up for an exam during exam period (high demand)) --> System --> response within 5s
- solution: Refactor in Rust. JK probably just profile the hotpaths and improve performance. *No architectural change needed*.

## DOS Attacks (Runtime, Security)
- what: an attacker tries to overload the system using Denial Of Service. The system has to be resilient enough to counter this.
- how: Attacker --- (many reqs from one device) --- System --- (ignore / block incoming requests)
- solution: Use a reverse proxy (Nginx) and put it in front the server. Configure it using the "leaky bucket" technique, purposefully slowing down
excessive requests or even discarding them completely without informing the client.

## DB access (Runtime, Security)
- what: Client / attacker attempts to access the DB outside the Student / Teacher Viewpoints.
- how: direct DB access attempt ---> DB --- (block & log) ---> deny access
- solution: DB will only accept connections from Student and Teacher Viewpoints. This also requires creating credential for the DB and storing them safely. *No architectural change needed*.

## Student can only view own data (Runtime, Security)
- what: Student tries to access another student's or teacher's data, either willingly or unwillingly.
- how: Student A ---> (attempt to access Student B's data) ---> Student Viewpoint ---> (block & log) ---> deny access  
OR  
Student ---> (attempt to access Teacher's data) ---> Student Viewpoint ---> (block & log) ---> deny access
- solution: Ensure proper authorization is met before requesting senstive information. The current architecture supports authentication on the client-side. However, addition authentication on the server-side is a good
idea. Let's move this responsibility to the *Reverse Proxy*.

## System correctly scales up and down with demand (Runtime, Elasticity)
- what: the system must be able to handle high loads during exam sign-up periods and scale down during off-peak times.
- how: during high demand periods ---> system scales up resources, during low demand periods ---> system scales down resources
- solution: The current model separates Teacher and Student handling, allowing for horizontal scaling. These handlers themselves can be scaled
vertically if needed. For this scaling, *an extra container (e.g. Kubernetes) is required*.

## Notifications queue (Runtime, Performance)
- what: When a student or teacher performs an action that triggers a notification, the system must deliver UI notifications quickly without blocking other operations, even during high-load periods.
- how: User ---> (action triggers notification) ---> Notification Handler ---> (enqueue) ---> Notification Queue ---> (async delivery) ---> Dashboard --> notification visible within 1s
- solution: Separate notification creation (ntfMaker) from notification delivery by introducing a notification queue. This removes blocking the nftMaker and increases throughput.

# DESIGN

## New ways of notifying (Design, Modifiability)
- what: the system must be designed to easily accommodate new notification methods (e.g., SMS, push notifications) in the future.
- how: Notification Maker ---> (new notification method added) ---> Notification Handler ---> (new delivery method integrated) ---> 1 week development time
- solution: Implement a notification delivery router that can direct notifications from the ntfMaker to all the supported notification methods. New methods can be added by implementing a new delivery module and registering it with the router.

## Interoperability with the rest of the SIS (Design, Interoperability)
- what: the exam system must be able to communicate with the rest of the system. Other parts of the system must be able to easily access the 
functionality this system.
- how: Exam System <---> (data exchange) <---> SIS 
- solution: Create an *extra container as an interface for the Exam System*.

**TODO:** iterate on the C4 model to add qualitative requirements

Q: How to formulate security requirements?
A: From PoV from the problematic behaviour (eg. student tries to access another student's data - maybe not via UI but via API call) -> expected system behaviour.  
Also e.g.: angry teacher writes fail grade to all students, or angry student colludes with another students to write bad reviews about a teacher.
