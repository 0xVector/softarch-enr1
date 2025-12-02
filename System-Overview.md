# System Overview: SIS Enrollment System

**Team**: Tue ENR1

## 1. System Description

**SIS Enrollment System** is a service-oriented system designed to manage student course enrollments at a university. It allows students to discover courses, manage their study plans, enroll in courses, and provide feedback through surveys. It also provides administrative features for teachers and staff.

The architecture is designed to be scalable, resilient, and maintainable, relying on event-driven communication between decoupled services.

---

## 2. Features Overview

The system provides the following core features:

- **1. Course Discovery**

  - **User Story**: As a user, I want to be able to search, filter, and browse available courses to find what I'm interested in.
  - **Team Member**: Matúš Jurčák

- **2. View a Course**

  - **User Story**: As a user, I want to view detailed information about a specific course, including its description, prerequisites, and comments from other students.
  - **Team Member**: Matúš Jurčák, Lukáš Hellesch

- **3. Enroll in Course**

  - **User Story**: As a student, I want to enroll in a course I am eligible for, or be placed on a waiting list if it's full.
  - **Team Member**: Jakub Maťa

- **4. Leave Course**

  - **User Story**: As a student, I want to leave a course I am currently enrolled in.
  - **Team Member**: Matúš Jurčák

- **5. Course Surveys**

  - **User Story**: As a student, I want to read feedback from past students and leave my own comments and ratings for a course. As a teacher/admin, I want to view and moderate this feedback.
  - **Team Member**: Jakub Maťa

- **6. View Remaining Mandatory Courses**
  - **User Story**: As a student, I want to see a clear overview of the mandatory courses I still need to complete for my degree, and plan my future schedule accordingly.
  - **Team Member**: Jakub Maťa, Lukáš Hellesch

## See details [here](Features-and-Responsibilities.md)

## 3. Responsibilities Overview

The features above give rise to several logical groups of responsibilities that the system must handle:

- **User Interface & Interaction**: Responsibilities for rendering views, handling user input, and providing feedback. This includes displaying course lists, detail pages, forms, and notifications.
- **Authentication & Authorization**: Ensuring that users are who they say they are and have the correct permissions to perform actions (e.g., only students can enroll, only admins can create courses).
- **Course & Catalog Management**: Managing the lifecycle of courses, including their creation, metadata, and searchability.
- **Enrollment & Eligibility Logic**: Handling the complex business rules for course enrollment, such as checking prerequisites, credit limits, and course capacity. This also includes managing waitlists.
- **Student Profile & Progress Management**: Tracking a student's academic progress, completed courses, earned credits, and study plans.
- **Data Persistence & Retrieval**: Storing and retrieving all system data reliably from databases.
- **Asynchronous Communication & Event Handling**: Managing event-driven communication between services to ensure loose coupling and resilience.
- **Notifications**: Sending communications to users (e.g., email, in-app messages) about important events like enrollment confirmation.
- **Auditing & Reporting**: Logging all significant system events for security, compliance, and statistical analysis.

---

## 4. C4 Architecture Model

### Level 1: System Context

The System Context diagram shows how our **SIS Enrollment System** fits into its operating environment.

- **Actors**:
  - **Student**: Interacts with the system to search for courses, enroll, manage their study plan, and leave feedback.
  - **Teacher**: Manages course participants.
  - **Admin**: Performs administrative tasks like creating courses and managing users.
- **External Systems**:
  - **External Auth System**: The university's SSO system, used for authenticating users.
  - **Email System**: Used by the Notification Service to send emails.

### Level 2: Containers

The Container diagram shows the high-level architectural building blocks of the system. We've chosen a **service-oriented architecture** where responsibilities are split across multiple collaborating containers.

- **Core Containers**:
  - **Web Application (React)**: A single-page application that provides the user interface for all actors.
  - **API Gateway**: The single entry point for the Web App. It handles routing, authentication, and rate limiting.
  - **Course Service**: Manages the course catalog, search functionality, and is the final arbiter for enrollment decisions. Owns the `Course DB`.
  - **Enrollment Service**: Handles the enrollment workflow, including prerequisite checks and ticket validation. It uses a replicated, local database for speed and resilience.
  - **Student Service**: Manages student profiles, academic progress, and study plans. Owns the `Student DB`.
  - **Survey Service**: Manages course surveys, comments, and ratings. Owns the `Survey DB`.
  - **Reporting Service**: Asynchronously consumes events to generate audit logs and statistics.
  - **Notification Service**: Sends notifications to users based on system events.
  - **Auth Service**: Handles user authentication and authorization.
- **Infrastructure Containers**:
  - **Message Queue**: An event broker for asynchronous communication between services, which decouples the services and improves resilience.
  - **Databases**: Each core service has its own dedicated database (`Course DB`, `Enrollment DB`, `Student DB`, `Survey DB`, `Log DB`) to ensure data isolation and independent scalability.
  - **File Storage**: Object storage for course materials and attachments.

### Level 3: Components

#### Interesting Container 1: Enrollment Service

The `Enrollment Service` is interesting because it is designed for high performance and resilience.
The decision to create a separate service was driven by the need for scalability during the enrollment
season.

It uses a local, replicated database composed from _CourseDB_ and _StudentDB_ to perform fast eligibility checks without making slow, synchronous calls to other services. To avoid races during enrollment, a final
arbiter (_Course Service_) is called upon each enrollment (see [details](diagram-notes.md#)).

- **Key Components**:
  - **Enrollment API Controller**: The entry point for all enrollment-related API requests.
  - **Enrollment Business Logic**: Orchestrates the enrollment process. It uses other components to perform its tasks.
  - **Prerequisite Checker & Ticket Validator**: Perform fast checks against the local `Enrollment DB`.
  - **Course Enroller**: Initiates the final enrollment by publishing an `EnrollmentRequested` event to the `Message Queue`.
  - **Leave Course Handler**: Manages the logic for a student leaving a course.
  - **Enrollment Repository**: Manages all data access to the `Enrollment DB`.

#### Interesting Container 2: Student Service

The `Student Service` is responsible for managing all aspects of a student's academic journey.

- **Key Components**:
  - **Student API Controller**: Handles API requests related to student data.
  - **Student Business Logic**: Orchestrates the logic for fetching student profiles and calculating study progress.
  - **Progress Tracker**: Determines a student's completed courses and credits.
  - **Requirement Calculator**: Calculates the remaining mandatory courses and credit requirements for a student's degree.
  - **Plan Manager**: Manages a student's saved study plans.
  - **Student Repository**: Manages data access to the `Student DB`.

### Dynamic Diagram: Student Enrollment Flow

This diagram shows the sequence of interactions when a student enrolls in a course. It highlights our event-driven approach.

1.  The **Student** clicks "Enroll" in the **Web UI**.
2.  The system check for eligibility.
3.  The UI fetches available tickets from the **Enrollment Service**.
4.  The student selects a ticket, and the UI sends a final enrollment request.
5.  The **Enrollment Service** validates the request and publishes an `EnrollmentRequested` event to the **Message Queue**.
6.  The **Course Service** (the central arbiter) consumes the event, checks for capacity in the authoritative `Course DB`, and makes the final decision.
7.  It then publishes an `EnrollmentConfirmed` (or `Failed`/`Waitlisted`) event.
8.  The **Notification Service** consumes this final event and sends a confirmation email to the student.

- **Team Member**: Jakub Maťa

### Deployment Diagram: Production Environment

This diagram shows how our containers are deployed in a production environment.

- Each service runs in its own **Deployment Node** (e.g., a Docker container or Kubernetes pod), allowing for independent scaling.
- The databases are hosted in a managed **Database Cluster**.
- An **API Gateway** acts as the entry point, routing traffic to the appropriate services.
- Static assets for the **Web Application** are served from a web server node.

- **Team Member**: Matúš Jurčák

### Deployment Diagram: Development Environment

This diagram shows how our containers are deployed in a development environment.

- All services are grouped into a single **Service Container** for simplicity.
- The databases are hosted in a managed **Database Cluster**.
- An **API Gateway** acts as the entry point, routing traffic to the appropriate services.
- Static assets for the **Web Application** are served from a web server node.

- **Team Member**: Matúš Jurčák

---

## 5. Mapping Responsibilities to Architecture

Here is how the high-level responsibilities are mapped to our C4 containers:

| Responsibility                     | Primary Container(s)                                   |
| ---------------------------------- | ------------------------------------------------------ |
| **User Interface & Interaction**   | Web Application                                        |
| **Authentication & Authorization** | Auth Service, API Gateway                              |
| **Course & Catalog Management**    | Course Service                                         |
| **Enrollment & Eligibility Logic** | Enrollment Service, Course Service (final arbitration) |
| **Student Profile & Progress**     | Student Service                                        |
| **Surveys and Feedback**           | Survey Service                                         |
| **Data Persistence**               | All Services with a DB (Course, Student, Survey, etc.) |
| **Asynchronous Communication**     | Message Queue                                          |
| **Notifications**                  | Notification Service                                   |
| **Auditing & Reporting**           | Reporting Service, Log DB                              |
