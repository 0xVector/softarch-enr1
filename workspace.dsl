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
            database = container "Database" {
                technology "PostgreSQL"
                tags "Database"
                description "Relational database with schemas for courses, students, enrollments, and surveys"
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
        student -> ss.webUI "Uses to search courses, enroll, view progress"
	teacher -> ss.webUI "Uses to manage courses and view enrollments"
	admin -> ss.webUI "Uses to administer system"

        # UI to API Gateway
        ss.webUI -> ss.apiGateway "Makes HTTPS API calls to" "JSON/REST"

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

	# Course Service relationships
	ss.courseService.courseRepository -> ss.database "Reads/writes course data" "SQL"
        ss.courseService.courseBusinessLogic -> ss.fileStorage "Retrieves course materials from"
        ss.courseService.courseBusinessLogic -> ss.messageQueue "Publishes course and search events to"

        # Enrollment Service relationships
        ss.enrollmentService.enrollmentRepository -> ss.enrollmentDB "Reads/writes enrollment data to its dedicated DB" "SQL"
        ss.enrollmentService.ticketRepository -> ss.enrollmentDB "Reads/updates ticker data to its dedicated DB" "SQL
        ss.enrollmentService.enrollmentBusinessLogic -> ss.messageQueue "Publishes enrollment and leave events to"
        ss.enrollmentService.enrollmentBusinessLogic -> ss.messageQueue "Consumes course and student events to update local data"

        # Student Service relationships
        ss.studentService.studentRepository -> ss.database "Reads/writes student data" "SQL"
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
	ss.surveyService.surveyRepository -> ss.database "Reads/writes survey data" "SQL"
        ss.surveyService.surveyBusinessLogic -> ss.messageQueue "Publishes survey events to"
        ss.surveyService.surveyBusinessLogic -> ss.studentService.studentBusinessLogic "Validates survey eligibility with"

        # Reporting Service relationships
        ss.reportingService -> ss.messageQueue "Consumes events for logging and analytics"
        ss.reportingService -> ss.database "Writes aggregated reports and logs to" "SQL"

        # Notification Service relationships
        ss.notificationService -> ss.messageQueue "Consumes events from"
        ss.notificationService -> ss.database "Logs notifications to"
        ss.notificationService -> student "Sends notifications to"
        ss.notificationService -> teacher "Sends notifications to"
        ss.notificationService -> admin "Sends notifications to"

        ss.messageQueue -> ss.notificationService "Triggers notifications in"

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

        component ss.courseService "CourseService-Components" {
            include *
            autolayout lr
            
            include ss.courseService.courseAPIController
            include ss.courseService.courseBusinessLogic
            include ss.courseService.courseRepository
            include ss.courseService.searchHandler
            
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

        dynamic ss "EnrollmentFlow" "Student enrollment flow" {
            student -> ss.webUI "Selects course to enroll"
            ss.webUI -> ss.apiGateway "POST /enrollments"
            ss.apiGateway -> ss.authService "Validates token"
            ss.apiGateway -> ss.enrollmentService "Forward enrollment request"
            ss.enrollmentService -> ss.enrollmentDB "Validates and creates enrollment"
            ss.enrollmentService -> ss.messageQueue "Publish enrollment event"
            ss.messageQueue -> ss.notificationService "Notify about enrollment"
            ss.notificationService -> student "Send confirmation email"
            autolayout lr
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
