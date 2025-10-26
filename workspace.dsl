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

                searchHandler = component "Search Handler"
                courseManager = component "Course Manager"
                courseValidator = component "Course Validator"
            }

            enrollmentService = container "Enrollment Service" {
                technology "Java/Spring Boot"
                description "Handles student enrollments, unenrollments, and waitlist management"

                enrollmentHandler = component "Enrollment Handler"
                ticketValidator = component "Ticket Validator"
                prereqChecker = component "Prerequisite Checker"
                capacityManager = component "Capacity Manager"
                waitlistManager = component "Waitlist Manager"
            }

            studentService = container "Student Service" {
                technology "Java/Spring Boot"
                description "Manages student profiles, study progress tracking, and academic planning"

                progressTracker = component "Progress Tracker"
                planManager = component "Plan Manager"
                requirementCalculator = component "Requirement Calculator"
            }

            surveyService = container "Survey Service" {
                technology "Java/Spring Boot"
                description "Handles course surveys, comments, ratings, and content moderation"

                surveyHandler = component "Survey Handler"
                commentManager = component "Comment Manager"
                moderationService = component "Moderation Service"
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

	    cacheLayer = container "Cache Layer" {
                technology "Redis"
                description "Distributed cache for courses, student data, and session management"
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
	ss.apiGateway -> ss.courseService "Routes course requests to"
	ss.apiGateway -> ss.enrollmentService "Routes enrollment requests to"
	ss.apiGateway -> ss.studentService "Routes student requests to"
	ss.apiGateway -> ss.surveyService "Routes survey requests to"
	ss.apiGateway -> ss.authService "Validates tokens with"

	# Course Service relationships
	ss.courseService -> ss.database "Reads/writes course data" "SQL"
        ss.courseService -> ss.cacheLayer "Caches course catalog"
        ss.courseService -> ss.fileStorage "Retrieves course materials from"
        ss.courseService -> ss.messageQueue "Publishes course events to"

        # Enrollment Service relationships
        ss.enrollmentService -> ss.database "Reads/writes enrollment data" "SQL"
        ss.enrollmentService -> ss.cacheLayer "Caches enrollment status"
        ss.enrollmentService -> ss.messageQueue "Publishes enrollment events to"
        ss.enrollmentService -> ss.courseService "Validates course availability with"
        ss.enrollmentService -> ss.studentService "Validates prerequisites with"

        # Student Service relationships
        ss.studentService -> ss.database "Reads/writes student data" "SQL"
        ss.studentService -> ss.cacheLayer "Caches student profiles"
        ss.studentService -> ss.messageQueue "Publishes student events to"
        ss.studentService -> ss.courseService "Fetches course requirements from"

        # Survey Service relationships
	ss.surveyService -> ss.database "Reads/writes survey data" "SQL"
        ss.surveyService -> ss.cacheLayer "Caches popular surveys"
        ss.surveyService -> ss.messageQueue "Publishes survey events to"
        ss.surveyService -> ss.studentService "Validates survey eligibility with"

        # Notification Service relationships
        ss.notificationService -> ss.messageQueue "Consumes events from"
        ss.notificationService -> ss.database "Logs notifications to"
        ss.notificationService -> student "Sends notifications to"
        ss.notificationService -> teacher "Sends notifications to"
        ss.notificationService -> admin "Sends notifications to"

        ss.messageQueue -> ss.notificationService "Triggers notifications in"

        # Common infrastructure relationships
        ss.apiGateway -> ss.cacheLayer "Caches API responses in"

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
            description "Course Service internal components"
        }

        component ss.enrollmentService "EnrollmentService-Components" {
            include *
            autolayout tb
            description "Enrollment Service internal components"
        }

        component ss.studentService "StudentService-Components" {
            include *
            autolayout lr
            description "Student Service internal components"
        }

        component ss.surveyService "SurveyService-Components" {
            include *
            autolayout lr
            description "Survey Service internal components"
        }

        dynamic ss "EnrollmentFlow" "Student enrollment flow" {
            student -> ss.webUI "Selects course to enroll"
            ss.webUI -> ss.apiGateway "POST /enrollments"
            ss.apiGateway -> ss.authService "Validates token"
            ss.apiGateway -> ss.enrollmentService "Forward enrollment request"
            ss.enrollmentService -> ss.studentService "Check prerequisites"
            ss.enrollmentService -> ss.courseService "Check capacity"
            ss.enrollmentService -> ss.database "Create enrollment"
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
