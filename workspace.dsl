workspace "SIS" "Enrollment" {

    !identifiers hierarchical

    model {
        student = person "Student"
	teacher = person "Teacher"
	admin = person "Admin"

        ss = softwareSystem "Software System" {
	    webUI = container "Website View"
            teacherUI = container "Teacher View"
            adminUI = container "Admin View"
	    notify = container "Notifcation UI"
	    proxy = container "ReverseProxy"
            courseMngr = container "One Course Manager" {
		enrollCapt = component "EnrollmentCapturer"
		courseValid = component "Course Validation"
            }
            courseDash = container "Course Dashboard"
            progressMngr = container "Study Progress Manager"
            surveyMngr = container "Survey Manager"
            studyProgress = container "StudyProgressManager"
            authWallet = container "Authenticator"

	    logger = container "Logger"

	    surveyRepo = container "Survey Repository"
            studRepo = container "Student Repository"
            survCache = container "Survey Cache"
	    studCache = container "Students Cache"
	    courseCache = container "Course Cache"
            courseRepo = container "Course Repository" 

            studentDB = container "Students DB" { 
				tags "Database" 
			}	
	    surveyDB = container "Surveys / deleted surveys DB" { 
				tags "Database" 
			}
            courseDB = container "Course DB" { 
				tags "Database" 
			}
            logDB = container "Logging Storage" { 
				tags "Database" 
			}
            
        }	

	auth = softwareSystem "Authentication System"

        ss -> auth "Fetches user's identity"

        student -> ss.webUI "Uses"
	teacher -> ss.teacherUI "Uses"
	admin -> ss.adminUI "Administers"

	ss.notify -> student "Notifies"
	ss.notify -> teacher "Notifies"
        ss.notify -> admin "Notifies"

        ss.webUI -> ss.proxy "Makes API calls to"
	ss.teacherUI -> ss.proxy "Makes API calls to"
        ss.adminUI -> ss.proxy "Makes API calls to"
        
	ss.proxy -> ss.courseMngr "Forwards to"
	ss.proxy -> ss.courseDash "Forwards to"
	ss.proxy -> ss.surveyMngr "Forwards to"

	ss.courseMngr -> ss.courseRepo "Reads from / Writes to"
        ss.courseMngr -> ss.courseCache "Reads from / Writes to"
	ss.courseMngr -> ss.authWallet "Authorizes"
        ss.courseMngr -> ss.notify "Send notifications"
        ss.courseMngr -> ss.Logger "Logs an action"

	ss.surveyMngr -> ss.surveyRepo "Reads from / writes to"
        ss.surveyMngr -> ss.survCache "Reads from / writes to"
	ss.surveyMngr -> ss.authWallet "Authorizes"
        ss.surveyMngr -> ss.notify "Send notifications"
        ss.surveyMngr -> ss.Logger "Logs an action"

	ss.courseDash -> ss.courseRepo "Reads"
        ss.courseDash -> ss.courseCache "Reads"
	ss.courseDash -> ss.authWallet "Authorizes"
        ss.courseDash -> ss.notify "Send notifications"
        ss.courseDash -> ss.Logger "Logs an action"

        ss.courseRepo -> ss.courseDB "reads from"
        ss.studRepo -> ss.studentDB "reads from / stores to"
        ss.surveyRepo -> ss.surveyDB "reads from / stores to"
	ss.logger -> ss.logDB "stores to"
        
    }

    views {
        systemContext ss "Level1" {
            include *
            autolayout lr
        }

        container ss "SISEnrollment-Level2" {
            include *
            autolayout lr
        }

        component ss.courseMngr "CourseManager-Level3" {
            include *
            autolayout lr
        }

        styles {
            element "Element" {
                color #f88728
                stroke #f88728
                strokeWidth 7
                shape roundedbox
            }
            element "Person" {
                shape person
            }
            element "Database" {
                shape cylinder
            }
            element "Boundary" {
                strokeWidth 5
            }
            relationship "Relationship" {
                thickness 4
            }
        }
    }

    configuration {
        scope softwaresystem
    }

}
