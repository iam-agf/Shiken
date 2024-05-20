package shikenrepository

import (
	std "std"
	"strconv"
	"strings"

	avl "gno.land/p/demo/avl"
	ufmt "gno.land/p/demo/ufmt"
	shikenexam "gno.land/p/dev/shikenexam"
	shikenquestion "gno.land/p/dev/shikenquestion"
)

// Error outputs
const (
	ErrNoExistingId      = "Id requested doesn't exist"
	ErrNoPendingExams    = "You don't have pending exams!"
	ErrEmptyTitle        = "Exam title can't be empty"
	ErrAddressNotAllowed = "Address not allowed!"
	ErrIdNotAnInteger    = "Id isn't an integer"
	ErrNoTopic           = "Topic doesn't exist"
)

// Main structure that stores relevant information
var (
	MainRepository Repository
	Applicants     avl.Tree // Applicant -> {avl.Tree {id -> true}}
	Creator        string
)

func init() {
	// Sets the creator of the Realm
	Creator = std.PrevRealm().Addr().String()
	Applicants = avl.Tree{}
}

func Render(path string) string {
	output := ufmt.Sprintf(`
		[exams (%d)](/r/dev/shikenrepository:exams)
		[questions (%d)](/r/dev/shikenrepository:questions) <br><br>
		Created by %s
		`, MainRepository.GetIdExam(), MainRepository.GetIdQuestion(), GetCreator(),
	)
	return output
}

// Add functions

// Add a Questions to the MainRepository Structure
func AddQuestion(topic, statement string, kind string, options string, answer string, hashAES string) {
	AddressAllowed()
	MainRepository.AddQuestion(topic, statement, kind, options, answer, hashAES)
}

// Add an Exam to the MainRepository Structure
func AddExam(title, description, questions, applicantsString, hashAES string) {
	AddressAllowed()
	applicantsArray := strings.Split(applicantsString, ",")
	id := MainRepository.GetIdExam()
	MainRepository.AddExam(title, questions, description, applicantsArray, hashAES)
	for _, appl := range applicantsArray {
		// Remember the ExamId will be increased in the AddExam part
		AddApplicant(appl, id+1)
	}
}

// Establishes the exams the applicant can access
func AddApplicant(addr string, idInt int) {
	AddressAllowed()
	// Start of main set
	id := strconv.Itoa(idInt)
	if applicantExamsInterface, ok := Applicants.Get(addr); ok {
		applicantExams := applicantExamsInterface.(avl.Tree)
		applicantExams.Set(id, true)
		Applicants.Set(addr, applicantExams)
	} else {
		applicantExams := avl.Tree{}
		applicantExams.Set(id, true)
		Applicants.Set(addr, applicantExams)
	}
}

// Read functions

// Reads the exam with the given id and returns all the content as a string.
// It won't matter if an external reads it because it will be hashed by
// web2 infrastructure.
func ReadExam(id string) string {
	var str string
	e := MainRepository.GetExamById(id)
	str += `"title":"` + e.GetTitle() + `",`
	str += `"description":"` + e.GetDescription() + `",`
	str += `"questions":"` + e.GetQuestions() + `",`
	appl := e.GetApplicants()
	applString := strings.Join(appl[:], `",`)
	str += `"applicantString":"` + applString + `",`
	str += `"hashAES":"` + e.GetHashAES() + `"`
	return `{` + str + `}`
}

// Read all the questions and returns it as a string. It won't matter if an
// external reads it because it will be hashed by web2 infrastructure.
func ReadTopic(topic string) []string {
	questionsArray := []string{}
	topicQuestionsInterface, ok := MainRepository.QuestionsByTopics.Get(topic)
	if !ok {
		panic(ErrNoTopic)
	}
	topicQuestions := topicQuestionsInterface.(avl.Tree)
	topicQuestions.Iterate("", "", func(key string, value interface{}) bool {
		question := value.(shikenquestion.Question)
		answer := question.GetAnswer()
		kind := question.GetKind()
		options := question.GetOptions()
		questions := question.GetQuestions()
		hashAES := question.GetHashAES()
		content := ufmt.Sprintf("{'answer':%s,'kind':%s,'options':%s,'question':%s,'hashAES':%s}", answer, kind, options, questions, hashAES)
		questionsArray = append(questionsArray, content)
		return true
	})
	return questionsArray
}

// Blocker to restrict to creator
func AddressAllowed() {
	caller := std.GetOrigCaller().String()
	if caller != Creator {
		panic(ErrAddressNotAllowed)
	}
}

// Get functions

// Returns the owner of the realm
func GetCreator() string {
	return Creator
}

// Gets all the topics from the user
func GetTopics() string {
	topics := ""
	MainRepository.QuestionsByTopics.Iterate("", "", func(key string, questions interface{}) bool {
		topics += key + ","
		return false
	})
	if len(topics) > 0 {
		topics = topics[:len(topics)-1]
	}
	topics = "[" + topics + "]"
	return topics
}

// Returns the list of ids of the exams the applicant is going to do.
// It doesn't show the exams the user has already made
func GetPendingExams(caller string) string {
	var examsList string
	examsInterface, ok := Applicants.Get(caller)
	if !ok {
		return "[]"
	} else {
		exams := examsInterface.(avl.Tree)
		exams.Iterate("", "", func(key string, value interface{}) bool {
			examsList += key + ","
			return false
		})
		examsList = examsList[:len(examsList)-1]
		return "[" + examsList + "]"
	}
}

// Returns the number of exams the applicant is going to do.
// It doesn't show the exams the user has already made
func GetNumberPendingExams(caller string) string {
	examsInterface, ok := Applicants.Get(caller)
	if !ok {
		return "0"
	} else {
		exams := examsInterface.(avl.Tree)
		return ufmt.Sprintf("%d", exams.Size())
	}
}

// Makes the caller drop the exam if is registered in it
func DropExam(id string) {
	caller := std.GetOrigCaller().String()
	// Removing the applicant from the applicants in the exam
	exam := MainRepository.GetExamById(id)
	applicantsInterface := exam.GetApplicantsTree()
	applicants := applicantsInterface.(avl.Tree)
	applicants.Remove(caller)
	exam.UpdateApplicants(applicants)
	// Removing the exam from the pending exams of the applicant
	applicantInterface, ok := Applicants.Get(caller)
	if !ok {
		panic(ufmt.Sprintf("Applicant %s not in Exam %s", caller, id))
	}
	applicant := applicantInterface.(avl.Tree)
	applicant.Remove(id)
	Applicants.Set(caller, applicant)
}

// answers parameter has to be a string because can't be sent decrypted
// Or could be read.
func SendAnswers(examId string, answers string) {
	caller := std.GetOrigCaller().String()
	exam := MainRepository.GetExamById(examId)
	valid := exam.VerifyApplicant(caller)
	if !valid {
		panic(ErrAddressNotAllowed)
	}
	answersInterface := exam.GetAnswerApplicantsTree()
	answersTree := answersInterface.(avl.Tree)
	answersTree.Set(caller, answers)
}

func DeleteExam(id string) {
	caller := std.GetOrigCaller().String()
	if caller != Creator {
		panic(ErrAddressNotAllowed)
	}

	// If the Id doesn't exist, will panic
	exam := MainRepository.GetExamById(id)

	if canDelete := MainRepository.CanDeleteExam(id); canDelete {
		applicants := exam.GetApplicants()
		// Removing exam from the applicants list of pending exams first
		for _, appl := range applicants {
			examsByApplInterface, ok := Applicants.Get(appl)
			if !ok {
				// This should never happen since each time there's an edit it's made in both sides
				// appl => exam and exam => appl
				panic(ErrUnexpectedError)
			}
			examsByAppl := examsByApplInterface.(avl.Tree)
			examsByAppl.Remove(id)
			Applicants.Set(appl, examsByAppl)
		}
	}
}
