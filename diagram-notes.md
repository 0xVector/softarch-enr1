# Architectural Decisions and Rationale

This document summarizes the key architectural decisions made during the design of the SIS Enrollment System. Each decision includes the context, the choice that was made, and a discussion of its pros and cons.

---

### 1. Separation of Concerns: Controller, Logic, and Repository Layers

*   **Decision**: Each service (e.g., `Course Service`, `Enrollment Service`) was decomposed into three distinct internal layers:
    1.  **API Controller**: Handles incoming API requests, validation, and routing.
    2.  **Business Logic**: Contains the core domain logic, orchestrates operations, and makes decisions.
    3.  **Repository**: Manages all data persistence and retrieval logic, interacting directly with the database.

*   **Rationale**: The initial model mixed business logic with data access. This separation aligns with the principles of **High Cohesion and Low Coupling**. It creates a clean, layered architecture within each service, making the system easier to understand, maintain, and test.

*   **Pros**:
    *   **Improved Maintainability**: Changes to the database schema only affect the Repository layer, shielding the business logic and controllers.
    *   **Enhanced Testability**: Each layer can be tested in isolation. We can mock the repository to test business logic without needing a database.
    *   **Clear Responsibilities**: Developers know exactly where to find and implement specific types of logic.

*   **Cons**:
    *   **Increased Boilerplate**: This pattern introduces more files and classes for each service, which can feel like overhead for very simple operations.

---

### 2. Decoupling Databases: Database-per-Service Pattern

*   **Decision**: The single, monolithic `Database` was split into multiple, domain-specific databases: `Course DB`, `Student DB`, `Survey DB`, and `Log DB`. Each core service now owns and interacts with its own database.

*   **Rationale**: A single database creates a tight coupling between services. If the `Survey Service` puts a heavy load on the database, it could slow down critical operations in the `Course Service` or `Student Service`. Decoupling the databases provides fault isolation and independent scalability.

*   **Pros**:
    *   **Scalability & Performance**: Each service's database can be scaled independently based on its specific workload.
    *   **Fault Isolation**: An issue with one database (e.g., high load, downtime) will not directly impact other services.
    *   **Data Autonomy**: Each service team can manage and evolve its database schema without coordinating with other teams.

*   **Cons**:
    *   **Increased Complexity**: Managing multiple databases (backups, security, monitoring) is more complex than managing one.
    *   **No Native Joins**: We can no longer perform native SQL joins across different service domains. Data must be replicated or fetched via API calls.

---

### 3. Data Replication in Enrollment Service via Event-Driven Architecture

*   **Decision**: The `Enrollment Service` maintains its own `Enrollment DB` which contains replicated data from the `Course DB` and `Student DB`. This data is kept in sync asynchronously via a `Message Queue`. When a course is updated, the `Course Service` publishes an event, which the `Enrollment Service` consumes to update its local copy.

*   **Rationale**: The enrollment process requires fast, reliable access to course and student data for validation. Making synchronous API calls to the `Course Service` and `Student Service` during every enrollment check would create a performance bottleneck and a single point of failure. Replicating the data makes the `Enrollment Service` resilient and highly scalable.

*   **Pros**:
    *   **High Availability & Resilience**: The enrollment process can function even if the `Course Service` or `Student Service` is temporarily unavailable.
    *   **Performance**: Validations are performed against a local database, which is significantly faster than cross-service network calls.
    *   **Scalability**: The `Enrollment Service` can be scaled out horizontally, with each instance being self-sufficient.

*   **Cons**:
    *   **Eventual Consistency**: There is a small delay between a change in the "golden source" (e.g., `Course DB`) and the update in the `Enrollment DB`. This is a standard trade-off in distributed systems.
    *   **Data Duplication**: Storing replicated data increases storage requirements.

---

### 4. Handling Enrollment Race Conditions with a Central Arbiter

*   **Decision**: To solve the race condition where two students try to claim the last spot, the `Course Service` was designated as the central arbiter. The `Enrollment Service` publishes an `EnrollmentRequested` event. The `Course Service` consumes these events serially, makes the final capacity check against its "golden source" `Course DB`, and publishes the final outcome (`EnrollmentConfirmed`, `EnrollmentFailed`, or `EnrollmentWaitlisted`).

*   **Rationale**: Relying on the local, eventually consistent data in the `Enrollment Service` is unsafe for critical state changes like claiming a course spot. A single source of truth is required to make the final decision. This pattern ensures fairness and data integrity.

*   **Pros**:
    *   **Guaranteed Consistency**: Prevents overselling course capacity by ensuring all enrollment decisions are serialized and made against the authoritative data source.
    *   **Robust and Fair**: The message queue naturally orders requests, ensuring a "first-come, first-served" process.
    *   **Clear Separation of Authority**: The `Enrollment Service` handles initial checks, while the `Course Service` handles the final, critical state change.

*   **Cons**:
    *   **Asynchronous User Experience**: The student does not get immediate confirmation. The UI must handle a "Pending" state while waiting for the final event, which adds complexity to the front end.

---

### 5. Centralized Waitlist Management

*   **Decision**: If an enrollment fails due to capacity, the `Course Service`'s new `Waitlist Manager` component automatically adds the student to a waitlist. This waitlist is stored in the `Course DB`, making it the "golden source" for waitlist data.

*   **Rationale**: This is a logical extension of the central arbiter pattern. The service that owns course capacity should also own the waitlist for that capacity. This keeps related logic cohesive and prevents data synchronization issues.

*   **Pros**:
    *   **Single Source of Truth**: The waitlist and its order are managed authoritatively in one place, preventing inconsistencies.
    *   **Simplified Logic**: The `Enrollment Service` does not need to be aware of waitlist mechanics; it only needs to react to the final `EnrollmentWaitlisted` event.

*   **Cons**:
    *   **Increased Responsibility for Course Service**: The `Course Service` is now responsible for more than just course metadata; it actively participates in the enrollment lifecycle.

---

### 6. Decomposing the Front-End SPA

*   **Decision**: The monolithic "Web Application" container was decomposed into several logical UI components (e.g., `Course Search View`, `Student Dashboard View`).

*   **Rationale**: Modeling the front end as a single block is inaccurate for a modern SPA like React. This decomposition provides a clearer view of the application's structure and maps user interactions to specific parts of the UI.

*   **Pros**:
    *   **More Accurate Model**: Better reflects the component-based nature of the front-end architecture.
    *   **Clearer User Journeys**: The diagrams now show which part of the UI a user interacts with to perform a specific action.

*   **Cons**:
    *   **Risk of Over-Granularity**: Care must be taken not to make the UI model too detailed, which could clutter the diagrams. The current split is based on high-level domain views.

---

### 7. Dedicated Logging Database

*   **Decision**: A dedicated `Log DB` was created for the `Reporting Service` and `Notification Service`, separating it from the transactional `Student DB`.

*   **Rationale**: Logging is a high-volume, write-heavy operation. Combining it with transactional data can cause performance bottlenecks, where a spike in log events could slow down critical user-facing operations.

*   **Pros**:
    *   **Workload Isolation**: Prevents logging activity from impacting the performance of the core application databases.
    *   **Independent Scalability**: The logging infrastructure can be scaled independently.
    *   **Optimized Storage**: Allows for choosing a database technology specifically optimized for log storage and analysis if needed in the future (e.g., Elasticsearch).

*   **Cons**:
    *   **Increased Operational Overhead**: Requires managing an additional database.
    *   **No Direct Joins**: It's no longer possible to run a simple SQL query to join logs directly with student data.

---

### 8. Shift to Asynchronous, Event-Driven Communication

*   **Decision**: Many previously synchronous, cross-service interactions were refactored into an asynchronous model using a central `Message Queue`. Instead of making direct API calls for non-critical operations, services now publish events, and other interested services subscribe to and consume them independently.

*   **Rationale**: Direct, synchronous calls create tight coupling and reduce resilience. If the `Student Service` is down, a synchronous call from the `Enrollment Service` to update credits would fail, potentially blocking the entire enrollment process. An event-driven approach decouples services, allowing them to operate independently and handle updates when they are ready.

*   **Key Asynchronous Flows and Events**:

    1.  **Enrollment Arbitration and Outcome**:
        *   `EnrollmentRequested`: Published by the `Enrollment Service` to ask for a spot in a course. Consumed by the `Course Service`.
        *   `EnrollmentConfirmed`: Published by the `Course Service` after successfully reserving a spot. Consumed by the `Enrollment Service`, `Notification Service`, and `Reporting Service`.
        *   `EnrollmentFailed`: Published by the `Course Service` if enrollment is denied (e.g., prerequisites not met on final check). Consumed by the `Enrollment Service`, `Notification Service`, and `Reporting Service`.
        *   `EnrollmentWaitlisted`: Published by the `Course Service` when a course is full. Consumed by the `Enrollment Service`, `Notification Service`, and `Reporting Service`.

    2.  **Data Synchronization for Replicas**:
        *   `CourseUpdated` (and other variants like `CourseCapacityUpdated`): Published by the `Course Service` whenever its "golden source" data changes. Consumed by the `Enrollment Service` to keep its local `Enrollment DB` replica up-to-date.
        *   `StudentProgressUpdated`: Published by the `Student Service` when a student's academic record changes. Consumed by the `Enrollment Service` to update its replica.

    3.  **General Notifications**:
        *   The `Notification Service` is a generic consumer for a wide range of business events (e.g., `EnrollmentConfirmed`, `SurveySubmitted`, `CourseDeleted`). It listens for these events and translates them into user-facing notifications (email, in-app, etc.).

    4.  **Auditing and Reporting**:
        *   The `Reporting Service` subscribes to nearly all significant business events (`EnrollmentRequested`, `CourseCreated`, `StudentLeftCourse`, etc.). It consumes these events to build a comprehensive audit log and generate analytics in the `Log DB` without impacting the performance of the primary services.

*   **Pros**:
    *   **Loose Coupling**: Services do not need to have direct knowledge of each other. They only need to agree on the event format.
    *   **Increased Resilience and Availability**: The failure of a single consumer service (like the `Reporting Service`) does not stop the producer service (like `Enrollment Service`) from functioning.
    *   **Improved Scalability**: The message queue acts as a buffer, absorbing spikes in load and allowing consumer services to process events at their own pace.

*   **Cons**:
    *   **Eventual Consistency**: As mentioned in Decision #3, this introduces a delay. The system state is not updated instantaneously across all services.
    *   **Increased Complexity**: Requires managing a message broker. Debugging a distributed flow across multiple services can be more complex than debugging a single synchronous call stack.
    *   **Asynchronous User Experience**: The UI must be designed to handle pending states and asynchronous feedback, which can be more challenging than a simple request/response model.