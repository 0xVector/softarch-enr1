workspace "SIS" "Enrollment" {

    !identifiers hierarchical

    model {
        student = person "Student" "University student enrolling in courses"
        teacher = person "Teacher" "Course instructor"
        admin = person "Admin" "System administrator"

        ss = softwareSystem "SIS Enrollment System" {
            # Presentation Layer
            webUI = container "Web Application" {
                technology "React/TypeScript"
                description "Single-page application providing UI for students, teachers, and admins"

                courseSearchView = component "Course Search View" {
                    description "Provides UI for searching, filtering, and displaying lists of courses."
                }
                courseDetailView = component "Course Detail View" {
                    description "Displays detailed information for a single course and initiates enrollment."
                }
                studentDashboardView = component "Student Dashboard View" {
                    description "Allows students to view their enrolled courses, study plans, and leave courses."
                }
                surveyView = component "Survey View" {
                    description "Provides the UI for viewing and submitting course surveys and comments."
                }
                adminDashboardView = component "Admin Dashboard View" {
                    description "Provides UI for administrative tasks like course and user management."
                }
            }

            # API Layer
            apiGateway = container "API Gateway" {
                technology "Node.js/Express"
                description "API gateway handling routing, authentication, rate limiting, and request validation"
            }

            # Business Logic Layer - Domain Services
            courseService = container "Course Service" {
                technology "Java/Spring Boot"
                description "Manages course catalog, search, viewing, and course metadata"
                
                courseAPIController = component "Course API Controller" {
                    description "Handles incoming HTTP requests for course-related operations."
                }
                courseBusinessLogic = component "Course Business Logic" {
                    description "Orchestrates business rules for course management."
                }
                courseRepository = component "Course Repository" {
                    description "Manages persistence operations for course data."
                }
                searchHandler = component "Search Handler" {
                    description "Handles course search and filtering logic."
                }
                waitlistManager = component "Waitlist Manager" {
                    description "Manages the authoritative waitlist for courses in the Course DB."
                }
            }

            enrollmentService = container "Enrollment Service" {
                technology "Java/Spring Boot"
                description "Handles student enrollments, unenrollments, and waitlist management"
                
                enrollmentAPIController = component "Enrollment API Controller" {
                    description "Handles incoming HTTP requests for enrollment-related operations."
                }
                enrollmentBusinessLogic = component "Enrollment Business Logic" {
                    description "Orchestrates business rules for enrollment management."
                }
                enrollmentRepository = component "Enrollment Repository" {
                    description "Manages persistence operations for enrollment data."
                }
                ticketRepository = component "Ticker Repository" {
                    description "Manages persistence operations for ticket data."
                }
                ticketSearchHandler = component "Ticket Search Handler" {
                    description "Fetches tickets of a course."
                }
                ticketValidator = component "Ticket Validator" {
                    description "Validates enrollment tickets."
                }
                prereqChecker = component "Prerequisite Checker" {
                    description "Checks course prerequisites."
                }
                capacityManager = component "Capacity Manager" {
                    description "Manages course capacity and availability."
                }
                waitlistManager = component "Waitlist Manager" {
                    description "Manages student waitlists for courses."
                }
                courseEnroller = component "Course Enroller" {
                    description "Enrolls students in courses by updating the DB."
                }
                leaveCourseHandler = component "Leave Course Handler" {
                    description "Handles the logic for a student leaving a course."
                }
            }

            studentService = container "Student Service" {
                technology "Java/Spring Boot"
                description "Manages student profiles, study progress tracking, and academic planning"
                
                studentAPIController = component "Student API Controller" {
                    description "Handles incoming HTTP requests for student-related operations."
                }
                studentBusinessLogic = component "Student Business Logic" {
                    description "Orchestrates business rules for student management."
                }
                studentRepository = component "Student Repository" {
                    description "Manages persistence operations for student data."
                }
                dbPrepopulator = component "DB Prepopulator" {
                    description "Prepopulates the student database with initial data on startup."
                }
                progressTracker = component "Progress Tracker" {
                    description "Tracks student academic progress, including past and current courses."
                }
                planManager = component "Plan Manager" {
                    description "Manages student academic plans."
                }
                requirementCalculator = component "Requirement Calculator" {
                    description "Calculates student academic requirements."
                }
            }

            surveyService = container "Survey Service" {
                technology "Java/Spring Boot"
                description "Handles course surveys, comments, ratings, and content moderation"
                
                surveyAPIController = component "Survey API Controller" {
                    description "Handles incoming HTTP requests for survey-related operations."
                }
                surveyBusinessLogic = component "Survey Business Logic" {
                    description "Orchestrates business rules for survey management."
                }
                surveyRepository = component "Survey Repository" {
                    description "Manages persistence operations for survey data."
                }
                surveyHandler = component "Survey Handler" {
                    description "Handles survey creation and retrieval."
                }
                surveyValidator = component "Survey Validator" {
                    description "Validates a newly created survey (if all information is provided)"
                }
                commentManager = component "Comment Manager" {
                    description "Manages comments and ratings."
                }
                moderationService = component "Moderation Service" {
                    description "Handles content moderation for surveys and comments."
                }
            }

            reportingService = container "Reporting Service" {
                technology "Python/FastAPI"
                description "Asynchronously consumes events to generate reports, statistics, and audit logs."
            }

            # Infrastructure Services
            notificationService = container "Notification Service" {
                technology "Node.js"
                description "Sends email, SMS, push notifications, and in-app messages"
            }

            authService = container "Auth Service" {
                technology "Keycloak/OAuth2"
                description "Centralized authentication and role-based authorization"
            }

            messageQueue = container "Message Queue" {
                technology "RabbitMQ"
                description "Async message broker for event-driven communication between services"
            }

            # Data Layer
            courseDB = container "Course DB" {
                technology "PostgreSQL"
                tags "Database"
                description "Relational database with schemas for courses and tickets."
            }

            studentDB = container "Student DB" {
                technology "PostgreSQL"
                tags "Database"
                description "Relational database for student profiles, progress, and operational logs."
            }

            surveyDB = container "Survey DB" {
                technology "PostgreSQL"
                tags "Database"
                description "Relational database for surveys and comments."
            }

            logDB = container "Log DB" {
                technology "PostgreSQL"
                tags "Database"
                description "Centralized database for storing audit logs, events, and operational metrics."
            }

            enrollmentDB = container "Enrollment DB" {
                technology "PostgreSQL"
                tags "Database"
                description "Dedicated database for the enrollment service to manage enrollments, tickets, and replicated course/student data for validation."
            }

            fileStorage = container "File Storage" {
                technology "S3/MinIO"
                tags "Storage"
                description "Object storage for course materials, syllabi, and attachments"
            }

        }


        authSystem = softwareSystem "External Auth System" {
            description "University SSO/LDAP system"
        }

        emailSystem = softwareSystem "Email System" {
            description "University email server"
        }

        # External system relationships
        ss.authService -> authSystem "Validates credentials with"
        ss.notificationService -> emailSystem "Sends emails via"

        # User to UI relationships
        student -> ss.webUI.courseSearchView "Searches and filters courses"
        student -> ss.webUI.courseDetailView "Views course details and enrolls"
        student -> ss.webUI.studentDashboardView "Manages study progress and leaves courses"
        student -> ss.webUI.surveyView "Views and writes course surveys"

        teacher -> ss.webUI.courseSearchView "Views course catalog"
        teacher -> ss.webUI.adminDashboardView "Manages course participants"

        admin -> ss.webUI.adminDashboardView "Administers system, creates courses, and manages users"

        # UI to API Gateway
        ss.webUI.courseSearchView -> ss.apiGateway "Makes API calls to search courses" "JSON/REST"
        ss.webUI.courseDetailView -> ss.apiGateway "Makes API calls to get course details and enroll" "JSON/REST"
        ss.webUI.studentDashboardView -> ss.apiGateway "Makes API calls to manage student data" "JSON/REST"
        ss.webUI.surveyView -> ss.apiGateway "Makes API calls to manage surveys" "JSON/REST"
        ss.webUI.adminDashboardView -> ss.apiGateway "Makes API calls for administrative tasks" "JSON/REST"

        # API Gateway to Services
        ss.apiGateway -> ss.courseService.courseAPIController "Routes course requests to"
        ss.apiGateway -> ss.enrollmentService.enrollmentAPIController "Routes enrollment requests to"
        ss.apiGateway -> ss.studentService.studentAPIController "Routes student requests to"
        ss.apiGateway -> ss.surveyService.surveyAPIController "Routes survey requests to"
        ss.apiGateway -> ss.authService "Validates tokens with"

        # Component-level relationships within Course Service
        ss.courseService.courseAPIController -> ss.courseService.courseBusinessLogic "Uses"
        ss.courseService.courseBusinessLogic -> ss.courseService.courseRepository "Uses to persist data"
        ss.courseService.searchHandler -> ss.courseService.courseRepository "Fetches courses"
        ss.courseService.courseBusinessLogic -> ss.courseService.searchHandler "Uses"
        ss.courseService.courseBusinessLogic -> ss.courseService.waitlistManager "Uses to manage waitlists on capacity failure"
        ss.courseService.waitlistManager -> ss.courseService.courseRepository "Reads/writes waitlist data"

        # Component-level relationships within Enrollment Service
        ss.enrollmentService.enrollmentAPIController -> ss.enrollmentService.enrollmentBusinessLogic "Uses"
        ss.enrollmentService.enrollmentBusinessLogic -> ss.enrollmentService.ticketValidator "Uses"
        ss.enrollmentService.enrollmentBusinessLogic -> ss.enrollmentService.prereqChecker "Uses"
        ss.enrollmentService.enrollmentBusinessLogic -> ss.enrollmentService.capacityManager "Uses"
        ss.enrollmentService.enrollmentBusinessLogic -> ss.enrollmentService.waitlistManager "Uses"
        ss.enrollmentService.enrollmentBusinessLogic -> ss.enrollmentService.ticketSearchHandler "Uses"
        ss.enrollmentService.enrollmentBusinessLogic -> ss.enrollmentService.courseEnroller "Uses"
        ss.enrollmentService.enrollmentBusinessLogic -> ss.enrollmentService.leaveCourseHandler "Uses"
        ss.enrollmentService.leaveCourseHandler -> ss.enrollmentService.enrollmentRepository "Removes enrollment data"
        ss.enrollmentService.ticketSearchHandler -> ss.enrollmentService.ticketRepository "Fetches tickets of a course"
        ss.enrollmentService.prereqChecker -> ss.enrollmentService.enrollmentRepository "Fetches course prerequisites"
        ss.enrollmentService.capacityManager -> ss.enrollmentService.enrollmentRepository "Fetches course capacity"
        ss.enrollmentService.ticketValidator -> ss.enrollmentService.ticketRepository "Fetches ticket information"
        ss.enrollmentService.courseEnroller -> ss.enrollmentService.enrollmentRepository "Updates enrollment data"
        ss.enrollmentService.waitlistManager -> ss.enrollmentService.enrollmentRepository "Updates waitlist data"

        # Component-level relationships within Student Service
        ss.studentService.studentAPIController -> ss.studentService.studentBusinessLogic "Uses"
        ss.studentService.studentBusinessLogic -> ss.studentService.studentRepository "Uses to persist data"
        ss.studentService.studentBusinessLogic -> ss.studentService.progressTracker "Uses to check enrollment eligibility"
        ss.studentService.studentBusinessLogic -> ss.studentService.planManager "Uses to fetch / store study plans"
        ss.studentService.studentBusinessLogic -> ss.studentService.requirementCalculator "Uses to calculate requirements"
        ss.studentService.planManager -> ss.studentService.studentRepository "Fetches student plans"
        ss.studentService.requirementCalculator -> ss.studentService.studentRepository "Fetches student's specialization"
        ss.studentService.progressTracker -> ss.studentService.studentRepository "Fetches student's study history"
        ss.studentService.dbPrepopulator -> ss.studentService.studentRepository "Uses to write initial data"

        # Course Service relationships
        ss.courseService.courseRepository -> ss.courseDB "Reads/writes course data" "SQL"
        ss.courseService.courseBusinessLogic -> ss.fileStorage "Retrieves course materials from"
        ss.courseService.courseBusinessLogic -> ss.messageQueue "Publishes course and search events to"

        # Enrollment Service relationships
        ss.enrollmentService.enrollmentRepository -> ss.enrollmentDB "Reads/writes enrollment data to its dedicated DB" "SQL"
        ss.enrollmentService.ticketRepository -> ss.enrollmentDB "Reads/updates ticker data to its dedicated DB" "SQL"
        ss.enrollmentService.enrollmentBusinessLogic -> ss.messageQueue "Publishes EnrollmentRequested and leave events"
        ss.courseService.courseBusinessLogic -> ss.messageQueue "Publishes EnrollmentConfirmed/Failed/Waitlisted events"
        ss.enrollmentService.enrollmentBusinessLogic -> ss.messageQueue "Consumes course and student events to update local data"

        # Student Service relationships
        ss.studentService.studentRepository -> ss.studentDB "Reads/writes student data" "SQL"
        ss.studentService.studentBusinessLogic -> ss.messageQueue "Publishes student events to"
        ss.studentService.progressTracker -> ss.courseService.courseBusinessLogic "Fetches course requirements from"
        ss.studentService.requirementCalculator -> ss.courseService.courseBusinessLogic "Fetches mandatory courses"


        # Component-level relationships within Survey Service
        ss.surveyService.surveyAPIController -> ss.surveyService.surveyBusinessLogic "Uses"
        ss.surveyService.surveyHandler -> ss.surveyService.surveyRepository "Read / Write / Delete Surveys"
        ss.surveyService.surveyBusinessLogic -> ss.surveyService.surveyHandler "Uses"
        ss.surveyService.surveyBusinessLogic -> ss.surveyService.commentManager "Uses"
        ss.surveyService.commentManager -> ss.surveyService.surveyRepository "Read / Write Comments"
        ss.surveyService.commentManager -> ss.surveyService.moderationService "Checks comments for moderation"
        ss.surveyService.surveyHandler -> ss.surveyService.moderationService "Checks surveys for moderation"
        ss.surveyService.surveyHandler -> ss.surveyService.surveyValidator "Validates survey forms"


        # Survey Service relationships
        ss.surveyService.surveyRepository -> ss.surveyDB "Reads/writes survey data" "SQL"
        ss.surveyService.surveyBusinessLogic -> ss.messageQueue "Publishes survey events to"
        ss.surveyService.surveyBusinessLogic -> ss.studentService.studentBusinessLogic "Validates survey eligibility with"

        # Reporting Service relationships
        ss.reportingService -> ss.messageQueue "Consumes events for logging and analytics"
        ss.reportingService -> ss.logDB "Writes aggregated reports and logs to" "SQL"

        # Notification Service relationships
        ss.notificationService -> ss.messageQueue "Consumes events from"
        ss.notificationService -> ss.logDB "Logs notifications to"
        ss.notificationService -> student "Sends notifications to"
        ss.notificationService -> teacher "Sends notifications to"
        ss.notificationService -> admin "Sends notifications to"

        ss.messageQueue -> ss.notificationService "Triggers notifications in"

        deploymentEnvironment "Production" {
            deploymentNode "Web application" "Single-page application providing UI for students, teachers, and admins" "React/TypeScript" {
                webUIInstance = containerInstance ss.webUI
            }

            deploymentNode "API Gateway Server" "Handles all HTTP requests" "Node.js/Express" {
                apiGatewayInstance = containerInstance ss.apiGateway
            }

            deploymentNode "Course Service Node" "Manages courses" "Java/Spring Boot" {
                courseServiceInstance = containerInstance ss.courseService
            }

            deploymentNode "Enrollment Service Node" "Handles enrollments" "Java/Spring Boot" {
                enrollmentServiceInstance = containerInstance ss.enrollmentService
            }

            deploymentNode "Student Service Node" "Manages student data" "Java/Spring Boot" {
                studentServiceInstance = containerInstance ss.studentService
            }

            deploymentNode "Survey Service Node" "Manages surveys" "Java/Spring Boot" {
                surveyServiceInstance = containerInstance ss.surveyService
            }

            deploymentNode "Reporting Service Node" "Generates reports" "Python/FastAPI" {
                reportingServiceInstance = containerInstance ss.reportingService
            }

            deploymentNode "Notification Service Node" "Sends notifications" "Node.js" {
                notificationServiceInstance = containerInstance ss.notificationService
            }

            deploymentNode "Auth Service Node" "Handles auth" "Keycloak/OAuth2" {
                authServiceInstance = containerInstance ss.authService
            }

            deploymentNode "Message Queue Node" "Event broker" "RabbitMQ" {
                messageQueueInstance = containerInstance ss.messageQueue
            }

            deploymentNode "Database Server" "" "" {
                deploymentNode "Database Cluster" "Primary DB cluster" "PostgreSQL"{
                    courseDBInstance = containerInstance ss.courseDB
                    enrollmentDBInstance = containerInstance ss.enrollmentDB
                    studentDBInstance = containerInstance ss.studentDB
                    surveyDBInstance = containerInstance ss.surveyDB
                }

                deploymentNode "Log storage" "Database for logs and reports" "PostgreSQL" {
                    logDBInstance = containerInstance ss.logDB
                }
            }

        }

        deploymentEnvironment "Development" {
            deploymentNode "Web application" "Single-page application providing UI for students, teachers, and admins" "React/TypeScript" {
                webUIInstance = containerInstance ss.webUI
            }

            deploymentNode "API Gateway Server" "Handles all HTTP requests" "Node.js/Express" {
                apiGatewayInstance = containerInstance ss.apiGateway
            }

            deploymentNode "Service container" "Service container" "Java/Spring Boot" {
                courseServiceInstance = containerInstance ss.courseService
                enrollmentServiceInstance = containerInstance ss.enrollmentService
                studentServiceInstance = containerInstance ss.studentService
                surveyServiceInstance = containerInstance ss.surveyService
                reportingServiceInstance = containerInstance ss.reportingService
                notificationServiceInstance = containerInstance ss.notificationService
                authServiceInstance = containerInstance ss.authService
            }

            deploymentNode "Message Queue Node" "Event broker" "RabbitMQ" {
                messageQueueInstance = containerInstance ss.messageQueue
            }

            deploymentNode "File Storage Node" "Object storage for course materials" {
                fileStorageInstance = containerInstance ss.fileStorage
            }

            deploymentNode "Database Server" "" "" {
                deploymentNode "Database Cluster" "Primary DB cluster" "PostgreSQL"{
                    courseDBInstance = containerInstance ss.courseDB
                    enrollmentDBInstance = containerInstance ss.enrollmentDB
                    studentDBInstance = containerInstance ss.studentDB
                    surveyDBInstance = containerInstance ss.surveyDB
                }

                deploymentNode "Log storage" "Database for logs and reports" "PostgreSQL" {
                    logDBInstance = containerInstance ss.logDB
                }
            }
        }
    }

    views {
        systemContext ss "SystemContext" {
            include *
            autolayout lr
            description "System context diagram showing SIS Enrollment System and external systems"
        }

        container ss "Containers" {
            include *
            autolayout tb
            description "Container diagram showing major architectural components"
        }

        component ss.webUI "WebApp-Components" {
            include *
            autolayout tb

            include ss.webUI.courseSearchView
            include ss.webUI.courseDetailView
            include ss.webUI.studentDashboardView
            include ss.webUI.surveyView
            include ss.webUI.adminDashboardView

            description "High-level component structure of the Single-Page Application."
        }


        component ss.courseService "CourseService-Components" {
            include *
            autolayout lr
            
            include ss.courseService.courseAPIController
            include ss.courseService.courseBusinessLogic
            include ss.courseService.courseRepository
            include ss.courseService.searchHandler
            include ss.courseService.waitlistManager
            
            autolayout tb
            description "Course Service internal components"
        }

        component ss.enrollmentService "EnrollmentService-Components" {
            include *
            autolayout tb
            
            include ss.enrollmentService.enrollmentAPIController
            include ss.enrollmentService.enrollmentBusinessLogic
            include ss.enrollmentService.enrollmentRepository
            include ss.enrollmentService.ticketValidator
            include ss.enrollmentService.prereqChecker
            include ss.enrollmentService.capacityManager
            include ss.enrollmentService.waitlistManager
            include ss.enrollmentService.courseEnroller
            include ss.enrollmentService.leaveCourseHandler

            description "Enrollment Service internal components"
        }

        component ss.studentService "StudentService-Components" {
            include *
            autolayout lr
            
            include ss.studentService.studentAPIController
            include ss.studentService.studentBusinessLogic
            include ss.studentService.studentRepository
            include ss.studentService.dbPrepopulator
            include ss.studentService.progressTracker
            include ss.studentService.planManager
            include ss.studentService.requirementCalculator

            autolayout tb
            description "Student Service internal components"
        }

        component ss.surveyService "SurveyService-Components" {
            include *
            autolayout lr
            
            include ss.surveyService.surveyAPIController
            include ss.surveyService.surveyBusinessLogic
            include ss.surveyService.surveyRepository
            include ss.surveyService.surveyHandler
            include ss.surveyService.commentManager
            include ss.surveyService.moderationService

            autolayout tb
            description "Survey Service internal components"
        }

        dynamic ss "CourseDiscoveryFlow" "Course discovery flow" {
            student -> ss.webUI "Opens the Course Dashboard™ and fills in the search module with filters"
            ss.webUI -> ss.apiGateway "GET /courses?filters=... (fetches courses with applied filters)"
            ss.apiGateway -> ss.courseService "Forwards GET request for courses"
            ss.courseService -> ss.courseDB "Queries courses based on filters"
            ss.courseDB -> ss.courseService "Returns matching courses"
            ss.courseService -> ss.apiGateway "Returns filtered course list"
            ss.apiGateway -> ss.webUI "Displays filtered courses to user"
            student -> ss.webUI "Views filtered courses"

            autolayout tb
        }

        dynamic ss "EnrollmentFlow" "Student enrollment flow" {
            student -> ss.webUI "Clicks 'Enroll' on a course"
            ss.webUI -> ss.apiGateway "GET /enrollments/tickets (fetches available tickets)"
            ss.apiGateway -> ss.enrollmentService "Validates prerequisites against local DB"
            student -> ss.webUI "Selects a ticket and confirms"
            ss.webUI -> ss.apiGateway "POST /enrollments (with selected ticket)"
            ss.apiGateway -> ss.enrollmentService "Forwards final enrollment request"
            ss.enrollmentService -> ss.messageQueue "Publishes EnrollmentRequested event"
            ss.messageQueue -> ss.courseService "Arbitrates final enrollment and capacity"
            ss.courseService -> ss.messageQueue "Publishes EnrollmentConfirmed/Failed/Waitlisted"
            ss.messageQueue -> ss.notificationService "Notifies student of final outcome"
            autolayout lr
        }
        dynamic ss.enrollmentService "EnrollmentService-InternalFlow" "Component interactions inside the Enrollment Service during an enrollment" {
            ss.apiGateway -> ss.enrollmentService.enrollmentAPIController "Forwards GET request for tickets"
            ss.enrollmentService.enrollmentAPIController -> ss.enrollmentService.enrollmentBusinessLogic "Uses to validate and fetch tickets"
            ss.enrollmentService.enrollmentBusinessLogic -> ss.enrollmentService.prereqChecker "Checks prerequisites"
            ss.enrollmentService.prereqChecker -> ss.enrollmentService.enrollmentRepository "Fetches student/course data from replica"
            ss.enrollmentService.enrollmentBusinessLogic -> ss.enrollmentService.ticketSearchHandler "Fetches available tickets"
            ss.enrollmentService.ticketSearchHandler -> ss.enrollmentService.ticketRepository "Reads ticket data from replica"

            ss.apiGateway -> ss.enrollmentService.enrollmentAPIController "Forwards POST request to enroll"
            ss.enrollmentService.enrollmentAPIController -> ss.enrollmentService.enrollmentBusinessLogic "Uses to process final enrollment"
            ss.enrollmentService.enrollmentBusinessLogic -> ss.enrollmentService.ticketValidator "Validates selected ticket"
            ss.enrollmentService.ticketValidator -> ss.enrollmentService.ticketRepository "Fetches ticket details from replica"
            ss.enrollmentService.enrollmentBusinessLogic -> ss.messageQueue "Publishes EnrollmentRequested event for arbitration"
            autolayout tb
        }
        dynamic ss.surveyService "surveyService-InternalFlow-Comment" "Component interactions inside the Survey Service when writing a comment" {
            ss.apiGateway -> ss.surveyService.surveyAPIController "Forwards comment submission request"
            ss.surveyService.surveyAPIController -> ss.surveyService.surveyBusinessLogic "Uses to check and send/store comments"
            ss.surveyService.surveyBusinessLogic -> ss.surveyService.commentManager "Uses to process comments"
            ss.surveyService.commentManager -> ss.surveyService.moderationService "Checks comments for moderation"
            ss.surveyService.commentManager -> ss.surveyService.surveyRepository "If moderate writes/stores comments"
            autolayout tb
        }

        dynamic ss.surveyService "surveyService-InternalFlow-Survey" "Component interactions inside the Survey Service when submitting a survey" {
            ss.apiGateway -> ss.surveyService.surveyAPIController "Forwards survey submission request"
            ss.surveyService.surveyAPIController -> ss.surveyService.surveyBusinessLogic "Uses to check and send/store comments"
            ss.surveyService.surveyBusinessLogic -> ss.surveyService.surveyHandler "Uses to process surveys"
            ss.surveyService.surveyHandler -> ss.surveyService.moderationService "Checks surveys for moderation"
            ss.surveyService.surveyHandler -> ss.surveyService.surveyValidator "Validates submitted forms"
            ss.surveyService.surveyHandler -> ss.surveyService.surveyRepository "If moderate and complete writes/stores surveys"
            autolayout tb
        }
        dynamic ss.studentService "StudentService-InternalFlow-ViewDuties" "Component interactions inside the Student Service when viewing duties" {
            ss.apiGateway -> ss.studentService.studentAPIController "Forwards GET request for duties"
            ss.studentService.studentAPIController -> ss.studentService.studentBusinessLogic "Uses to orchestrate fetching duties"     
            ss.studentService.studentBusinessLogic -> ss.studentService.studentRepository "Fetches student profile (major, specialization)"
            ss.studentService.studentRepository -> ss.studentDB "Reads student data"
            ss.studentService.studentBusinessLogic -> ss.studentService.progressTracker "Uses to get completed courses/credits"
            ss.studentService.progressTracker -> ss.studentService.studentRepository "Fetches student's study history"
            ss.studentService.studentBusinessLogic -> ss.studentService.requirementCalculator "Uses to calculate remaining requirements"
            ss.studentService.requirementCalculator -> ss.courseService "Fetches mandatory courses and credit reqs"        
            autolayout tb
        }

        dynamic ss.studentService "StudentService-InternalFlow-SavePlan" "Component interactions inside the Student Service when saving a plan" {
            ss.apiGateway -> ss.studentService.studentAPIController "Forwards POST request to save plan"
            ss.studentService.studentAPIController -> ss.studentService.studentBusinessLogic "Uses to orchestrate saving the plan"      
            ss.studentService.studentBusinessLogic -> ss.studentService.planManager "Uses to validate and store plan"
            ss.studentService.planManager -> ss.studentService.studentRepository "Writes/overwrites student plan"
            ss.studentService.studentRepository -> ss.studentDB "Saves plan to database"      
            autolayout tb
        }

        dynamic ss "LeaveCourseFlow" "Student leaves a course" {
            student -> ss.webUI "Clicks 'Leave Course' on a selected course"
            ss.webUI -> ss.apiGateway "POST /enrollments/leave (leave selected course)"
            ss.apiGateway -> ss.enrollmentService "Processes the leave course request"
            ss.enrollmentService -> ss.enrollmentDB "Removes student from course in DB"
            ss.enrollmentService -> ss.messageQueue "Publishes CourseLeft event"
            ss.messageQueue -> ss.notificationService "Notifies student upon successful leaving/error"

            autolayout lr
        }

        dynamic ss "CourseViewFlow" "Student views course details and checks enrollment eligibility" {
            student -> ss.webUI "Navigates to course detail page"
            ss.webUI -> ss.apiGateway "GET /courses/{courseId} (fetch course details)"
            ss.apiGateway -> ss.courseService "Forwards request for course data"
            ss.courseService -> ss.courseDB "Queries course information"
            ss.courseDB -> ss.courseService "Returns course details (title, description, metadata)"
            ss.courseService -> ss.apiGateway "Returns course data"
            ss.apiGateway -> ss.webUI "Displays course information to user"
            student -> ss.webUI "Clicks 'Can I enroll?' button"
            ss.webUI -> ss.apiGateway "GET /enrollments/eligibility?courseId={id} (check eligibility)"
            ss.apiGateway -> ss.enrollmentService "Validates enrollment eligibility"
            ss.enrollmentService -> ss.enrollmentDB "Checks prerequisites, capacity, and credit limits"
            ss.enrollmentDB -> ss.enrollmentService "Returns eligibility result"
            ss.enrollmentService -> ss.apiGateway "Returns eligibility status (TRUE/FALSE)"
            ss.apiGateway -> ss.webUI "Displays eligibility notification"
            student -> ss.webUI "Clicks 'comments' to view course surveys"
            ss.webUI -> ss.apiGateway "GET /surveys/course/{courseId} (fetch comments)"
            ss.apiGateway -> ss.surveyService "Forwards request for course surveys"
            ss.surveyService -> ss.surveyDB "Queries comments and ratings"
            ss.surveyDB -> ss.surveyService "Returns comments (author, date, ratings)"
            ss.surveyService -> ss.apiGateway "Returns survey data"
            ss.apiGateway -> ss.webUI "Displays comments section to user"

            autolayout tb
        }

        deployment ss "Production" {
            include *
        
            autoLayout tb
            
            description "Deployment diagram showing production environment setup"
        }

        deployment ss "Development" {
            include *
        
            autoLayout tb
            
            description "Deployment diagram showing development environment setup"
        }

        styles {
            element "Element" {
                color #ffffff
                background #1168bd
                fontSize 24
                shape roundedbox
            }
            element "Person" {
                background #08427b
                shape person
            }
            element "Software System" {
                background #1168bd
            }
            element "Container" {
                background #438dd5
            }
            element "Component" {
                background #85bbf0
                color #000000
            }
            element "Database" {
                shape cylinder
                background #438dd5
            }
            element "Storage" {
                shape folder
                background #438dd5
            }
            element "WebApp" {
                shape webbrowser
            }
            element "Gateway" {
                shape hexagon
            }
            element "Infrastructure" {
                background #999999
            }
            relationship "Relationship" {
                thickness 2
                color #707070
                fontSize 24
            }
        }

        theme default
    }

    configuration {
        scope softwaresystem
    }

}
