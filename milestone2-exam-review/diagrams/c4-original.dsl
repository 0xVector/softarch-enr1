workspace "Name" "Description" {

    !identifiers hierarchical

    model {
        teacher = person "Teacher"
        student = person "Student"
        manager = person "Manager"
        emailService = softwareSystem "Email Service"
        
        sis = softwareSystem "SIS" {
            description "Rest of the study information system"
            
            dbInterface = container "SIS Database Interface" {
                description "SIS interface for communication with SIS inner databases"
            }
            
        }
        

        ss = softwareSystem "Exams Module" {
            description "Handles scheduling exams, registring for exams and awarding and viewing grades"
            
            examDb = container "Exam Database" {
                tags "Database"
            }
            
            
            studentViewpoint = container "Student Viewpoint" {
                description "Student-facing application combining dashboard (student part), exam sign-up and grade viewing."

                

                signUpController = component "Sign-up Controller" {
                    description "Handles student UI events for exam sign-up and grade viewing (merged Dashboard Controller + original Sign-up Controller)."
                }

                signUpManager = component "Sign-up Manager" {
                    description "Manages main business logic for exam sign-up: coordinates services, translations and workflow."
                }

                examTermService = component "Exam Term Service" {
                    description "Forms queries, interacts with exam term data in the database and returns available terms."
                }

                roomFilter = component "Room Filter" {
                    description "Filters exam terms by capacity, room constraints and other conditions."
                }

                studentService = component "Student Service" {
                    description "Fetches and updates student-related data used during exam sign-up."
                }

                gradeReader = component "Grade Reader" {
                    description "Enables viewing and filtering of grades (merged Read-only API, Data Getter and Rules)."
                }

                validator = component "Validator" {
                    description "Checks if the student is qualified for an exam and validates integrity of data returned from databases (merged validators)."
                }
            }
            
            
            teacherViewpoint = container "Teacher Viewpoint" {
                description "Controls creating, editing and deleting of the exam terms"

                group "Exam Term Handler" {
                    subjectFilter = component "Subject Filter" {
                        description "Filters subjects for the given teacher"
                    }

                    roomFilter = component "Room Filter" {
                        description "Filters free rooms with given parameters from the database for the given term"
                    }

                    examsEditorAPI = component "Exams Editor API" {
                        description "Communicates with the dashboard to present the exam editor to the teacher"
                    }

                    examsEditor = component "Exam Term Editor" {
                        description "Creates exam term with parameters given by the teacher, restricted by data read from the databases"
                    }

                    sisDataGetter = component "SIS Data Getter" {
                        description "Handles request for SIS database interface"
                    }
                }

                group "Awarding Grades Handler" {
                    examsFilter = component "Exams Filter" {
                        description "Filters data from the exam database"
                    }

                    gradesEditorAPI = component "Grades Editor API" {
                        description "Communicates with the dashboard to present the grades editor to the teacher"
                    }

                    gradesEditor = component "Grade Editor" {
                        description "Allows creating, editing and deleting grades"
                    }

                    dbDataLoader = component "Database Data Loader" {
                        description "Loads data from databases"
                    }

                    examRepository = component "Exam repository"{
                        description "Abstraction over exams database"
                    }
                }
            }
        
        
            studentDashboard = container "Student Dashboard" {
                description "Handles UI to students and teachers"
                
                vComponents = component "View Components" {
                    description "Renders the UI and updates when data changes"
                }
                
                dsbController = component "Dashboard Controller" {
                    description "Handles UI events"
                }
                
                pgRouter = component "Page Router" {
                    description "Controls navigation between pages"
                }
                
                APIService = component "API Service" {
                    description "Handles communication with backend"
                }
                ntfUIHandler = component "Notification UI Handler" {
                    description "Handles real-time notification updates"
                }
                
                authHandler = component "Authentication Handler" {
                    description "Handles login state"
                }
            }
            
            
            teacherDashboard = container "Teacher Dashboard" {
                description "Handles UI to students and teachers"
                
                vComponents = component "View Components" {
                    description "Renders the UI and updates when data changes"
                }
                
                dsbController = component "Dashboard Controller" {
                    description "Handles UI events"
                }
                
                pgRouter = component "Page Router" {
                    description "Controls navigation between pages"
                }
                
                APIService = component "API Service" {
                    description "Handles communication with backend"
                }
                ntfUIHandler = component "Notification UI Handler" {
                    description "Handles real-time notification updates"
                }
                
                authHandler = component "Authentication Handler" {
                    description "Handles login state"
                }
            }
            
            
            ntfHandler = container "Notification Handler"{
                description "Handles messeges about success/failure of user operations"

                ntfMaker = component "Notification Maker"{
                    description "Creates proper notifications based on handler events"
                }
                
                usrValidator = component "User Validator"{
                    description "Validates the existence of users"
                }
                
                emailer = component "Emailer"{
                    description "Formats and sends emails"
                }
            }
        
        }
        
        #
        # L1
        #
        student -> ss "Registers for exams, views results"
        teacher -> ss "Schedules exams, awards grades"
        manager -> ss "Monitors exam schedules"
        sis -> ss "Autenticates users, sends data from shared SIS databases..."
        ss -> sis "Sends requests"
        
        #
        # L3
        #

        # L3 - student dashboard 
        student -> ss.studentDashboard.authHandler "Validates as a student"
        ss.studentDashboard.authHandler -> ss.studentDashboard.dsbController "User interacts with UI"
        ss.studentDashboard.dsbController -> ss.studentDashboard.vComponents "Updates UI"
        ss.studentDashboard.APIService -> ss.studentDashboard.dsbController "Updates results based on data and responds to requests"
        ss.studentDashboard.pgRouter -> ss.studentDashboard.dsbController "Show correct page and accept page requests"
        ss.ntfHandler -> ss.studentDashboard.ntfUIHandler "Sends notification data in real-time"
        ss.studentDashboard.ntfUIHandler -> ss.studentDashboard.dsbController "For giving notifications"
        ss.studentDashboard.APIService -> ss.studentViewpoint "Requests and receiveViewpoint
        
        # L3 - teacher dashboard 
        teacher -> ss.teacherDashboard.authHandler "Validates as a teacher"
        ss.teacherDashboard.authHandler -> ss.teacherDashboard.dsbController "User interacts with UI"
        ss.teacherDashboard.dsbController -> ss.teacherDashboard.vComponents "Updates UI"
        ss.teacherDashboard.APIService -> ss.teacherDashboard.dsbController "Updates results based on data and responds to requests"
        ss.teacherDashboard.pgRouter -> ss.teacherDashboard.dsbController "Show correct page and accept page requests"
        ss.ntfHandler -> ss.teacherDashboard.ntfUIHandler "Sends notification data in real-time"
        ss.teacherDashboard.ntfUIHandler -> ss.teacherDashboard.dsbController "For giving notifications"
        ss.teacherDashboard.APIService -> ss.teacherViewpoint "Requests and receiveViewpoint
        
        # L3 - ntfHandler
        ss.teacherViewpoint -> ss.ntfHandler.ntfMaker "Calls for sending notifications to users"
        ss.studentViewpoint -> ss.ntfHandler.ntfMaker "Calls for sending notifications to users"
        ss.ntfHandler.ntfMaker -> ss.ntfHandler.usrValidator "Validates the people exist"
        ss.ntfHandler.ntfMaker -> ss.studentDashboard "Sends real-time notification events to the student"
        ss.ntfHandler.ntfMaker -> ss.teacherDashboard "Sends real-time notification events to the teacher"
        ss.ntfHandler.usrValidator -> ss.ntfHandler.emailer "Formats emails"
        ss.ntfHandler.emailer -> emailService "Sends notifications by mail"  
        
        #L3 - student viewpoint
        ss.studentDashboard -> ss.studentViewpoint.signUpController ""
        ss.studentViewpoint.signUpController -> ss.studentViewpoint.signUpManager "Sends student's sign-up or exam-term request"
        ss.studentViewpoint.signUpManager -> ss.studentViewpoint.examTermService "Requests exam terms"
        ss.studentViewpoint.signUpManager -> ss.studentViewpoint.studentService "Requests student profile / sign-up info"
        ss.studentViewpoint.signUpManager -> ss.studentViewpoint.validator "Requests eligibility validation"
        ss.studentViewpoint.examTermService -> ss.studentViewpoint.roomFilter "Filters exam terms by rules"
        ss.studentViewpoint.examTermService -> ss.examDb "Reads and updates exam term data"
        ss.studentViewpoint.studentService -> sis.dbInterface "Reads and updates student sign-up records"
        ss.studentViewpoint.examTermService -> ss.studentViewpoint.validator "Validity check for exam term data"
        ss.studentViewpoint.signUpController -> ss.studentViewpoint.gradeReader "Requests grades for the authenticated student"
        ss.studentViewpoint.gradeReader -> sis.dbInterface "Reads grades of the student"
        ss.studentViewpoint.gradeReader -> ss.studentViewpoint.validator "Requests validation of database data"
        ss.studentDashboard -> ss.studentViewpoint.signUpManager "Request viewpoint."
        ss.studentViewpoint.signUpManager -> ss.ntfHandler "Send to ntfHandler about change"
    
        # L3 - teacher viewpoint
        # Exam term creation
        ss.teacherViewpoint.sisDataGetter -> sis.dbInterface "Requests data"
        ss.teacherViewpoint.sisDataGetter -> ss.teacherViewpoint.subjectFilter "Sends subject data"
        ss.teacherViewpoint.sisDataGetter -> ss.teacherViewpoint.roomFilter "Sends room data"
        ss.teacherViewpoint.roomFilter -> ss.teacherViewpoint.examsEditor "Gives list of available rooms"
        ss.teacherViewpoint.subjectFilter -> ss.teacherViewpoint.examsEditor "Gives list of subjects of the teacher"
        ss.teacherViewpoint.examsEditor -> ss.examDb "Saves changes"
        ss.teacherViewpoint.examsEditor -> ss.ntfHandler "Alerts about changes"
        ss.teacherDashboard -> ss.teacherViewpoint.examsEditorAPI "Uses exams editor API"
        ss.teacherViewpoint.examsEditor -> ss.teacherViewpoint.examsEditorAPI "Sets values to show"
        ss.teacherViewpoint.examsEditorAPI -> ss.teacherViewpoint.examsEditor "Gives actual values from user"

        #Awarding grade
        ss.teacherDashboard -> ss.teacherViewpoint.gradesEditorAPI "Uses grades editor API"
        ss.teacherViewpoint.gradesEditorApi -> sis.dbInterface "Requests the data from sis database."
        ss.teacherViewpoint.gradesEditorAPI -> ss.teacherViewpoint.gradesEditor "Requests writing grade."
        ss.teacherViewpoint.gradesEditorAPI -> ss.teacherViewpoint.examsFilter "Adds additional filtering constraints."
        ss.teacherViewpoint.examsFilter -> ss.teacherViewpoint.dbDataLoader "Requests the data from databases."
        ss.teacherViewpoint.dbDataLoader -> sis.dbInterface "Gets data from SIS databases."
        ss.teacherViewpoint.dbDataLoader -> ss.teacherViewpoint.examRepository "Requests data from internal db."
        ss.teacherViewpoint.examRepository -> ss.examDb "Gets data from db."
        ss.teacherViewpoint.gradesEditor -> sis.dbInterface "Stores grades to the database"
        ss.teacherViewpoint.gradesEditor -> ss.ntfHandler "Alerts about changes"
    }

    views {
        systemContext ss {
            include *
            autolayout tb
            title "C1 – System Context: Exams Software System"
        }
        
        container ss {
            include student
            include teacher
            include *
            autolayout lr
            title "C2 – SIS Exams Containers"
        }
        
        component ss.studentDashboard {
            include *
            include student
            autolayout lr
            title "C3 – Student Dashboard Components"
            
        }
        
        component ss.teacherDashboard {
            include *
            include teacher
            autolayout lr
            title "C3 – Teacher Dashboard Components"
            
        }
        
        component ss.ntfHandler {
            include *
            include emailService
            autolayout lr
            title "C3 – Notification Handler Components"
            
        }
        
        component ss.studentViewpoint {
            include *
            autolayout lr
            title "C3 – Student Viewpoint Components"
        }
        
        component ss.teacherViewpoint {
            include *
            include teacher
            autolayout lr
            title "C3 – Teacher Viewpoint Components"
        }

        styles {
            element "Person" {
                shape Person
                background #08427B
                color #ffffff
            }
            
            element "Software System" {
                shape RoundedBox
                background #1168BD
                color #ffffff
            }

            element "Database" {
                shape Cylinder
            }
        }

        theme default
    }

}


