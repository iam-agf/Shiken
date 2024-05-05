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
)

// Main structure that stores relevant information
var (
	MainRepository Repository
	Applicants     avl.Tree
	Creator        string
)

func init() {
	// Sets the creator of the Realm
	Creator = std.PrevRealm().Addr().String()
	Applicants = avl.Tree{}
}

func Render(path string) string {
	words := strings.Split(path, "/")
	ufmt.Sprintf("%d", MainRepository.GetIdExam())
	ufmt.Sprintf("%d", MainRepository.GetIdQuestion())
	switch words[0] {
	case "exams":
		return ufmt.Sprintf("Exams %d\n\n%s", MainRepository.GetIdExam(), ReadExams())
	case "questions":
		return ufmt.Sprintf("Questions %d\n\n%s", MainRepository.GetIdQuestion(), ReadQuestions())
	default:
		return ufmt.Sprintf(`
			%s
			[exams (%d)](/r/dev/shikenrepository:exams)
			[questions (%d)](/r/dev/shikenrepository:questions) <br><br>
			Created by %s 
			`, words[0], MainRepository.GetIdExam(), MainRepository.GetIdQuestion(), GetCreator())
	}
}

// Add functions

// Add a Questions to the MainRepository Structure
func AddQuestion(statement string, kind string, options string, answer string) {
	AddressAllowed()
	MainRepository.AddQuestion(statement, kind, options, answer)
}

// Add an Exam to the MainRepository Structure
func AddExam(title string, questions string, description string, applicantsString string) {
	AddressAllowed()
	if len(title) == 0 {
		panic(ErrEmptyTitle)
	}
	applicantsArray := strings.Split(applicantsString, ",")
	id := MainRepository.GetIdExam()
	MainRepository.AddExam(title, questions, description, applicantsArray)
	for _, appl := range applicantsArray {
		SetApplicant(appl, id)
	}
}

// Duplicates an exam based on a previous one
func DuplicateExam(oId string) {
	AddressAllowed()
	oldExam := MainRepository.GetExamById(oId)
	title := oldExam.GetTitle()
	description := oldExam.GetDescription()

	// Creating duplicate
	MainRepository.AddExam(title, "", description, []string{})
	newExamId := MainRepository.GetIdExam()
	newExam := MainRepository.GetExamById(strconv.Itoa(newExamId))

	// Optional parameters added
	questions := oldExam.GetQuestions()
	if len(questions) > 0 {
		newExam.UpdateQuestions(questions)
		for _, q := range questions {
			MainRepository.AppendExamUsingQuestionId(strconv.Itoa(q), strconv.Itoa(newExamId))
		}
	}
	applicants := oldExam.GetApplicantsTree()
	if applicants.Size() > 0 {
		newExam.UpdateApplicants(applicants)
	}
}

// Read all the exams and returns it as a string. It won't matter if an external
// reads it because it will be hashed by web2 infrastructure.
func ReadExams() string {
	AddressAllowed()
	// In case the address is allowed
	str := ""
	ids := MainRepository.GetIdExam()
	for id := 1; id <= ids; id++ {
		content := ReadOneExam(strconv.Itoa(id))
		if content != ErrNoExistingId {
			str += content
		}
	}
	return str
}

// Reads the exam with the given id and returns it as a string.
// It won't matter if an external reads it because it will be hashed by
// web2 infrastructure.
func ReadOneExam(id string) string {
	AddressAllowed()
	var str string
	e := MainRepository.GetExamById(id)
	str += "## " + e.GetTitle() + "\n"

	allQuestions := MainRepository.GetQuestions()
	qs := e.GetQuestions()
	for _, id := range qs {
		str += ReadOneQuestion(strconv.Itoa(id))
	}
	return str
}

// Read all the questions and returns it as a string. It won't matter if an
// external reads it because it will be hashed by web2 infrastructure.
func ReadQuestions() string {
	var str string
	ids := MainRepository.GetIdQuestion()
	for id := 1; id <= ids; id++ {
		str += ReadOneQuestion(strconv.Itoa(id))
	}
	return str
}

// Reads the question with the given id and returns it as a string if the
// caller is the creator. If the caller isn't the creator returns an empty
// string.
func ReadOneQuestion(id string) string {
	AddressAllowed()
	var str string
	content := MainRepository.ReadQuestion(id)
	if content != ErrNoExistingId {
		str += content
	}
	return str
}

// Deletes the question with the given id if the caller is the creator and if:
// 1. the question hasn't been used in any exam (If you delete it first in the
// exam, you can remove it).
// 2. the question was not used in previous exams.
// If the caller isn't the creator, it panics.
func DeleteQuestion(id string) {
	AddressAllowed()
	idInt, err := strconv.Atoi(id)
	if err != nil {
		panic(ErrIdNotAnInteger)
	}
	MainRepository.DeleteQuestion(idInt)
}

// Deletes the question with the given id if the caller is the creator and if:
// 1. The exam hasn't started yet
// 2. The exam doesn't have applicants
// 3. The exam doesn't have questions
func DeleteExam(id string) {
	AddressAllowed()
	idInt, err := strconv.Atoi(id)
	if err != nil {
		panic(ErrIdNotAnInteger)
	}
	MainRepository.DeleteExam(idInt)
}

// Establishes the exams the applicant can access
func SetApplicant(addr string, idInt int) {
	AddressAllowed()
	// Start of main set
	id := strconv.Itoa(idInt)
	if _, ok := Applicants.Get(addr); ok {
		applicantExamsInterface, _ := Applicants.Get(addr)
		applicantExams := applicantExamsInterface.(avl.Tree)
		applicantExams.Set(id, true)
	} else {
		applicantExams := avl.Tree{}
		applicantExams.Set(id, true)
		Applicants.Set(addr, applicantExams)
	}
}

func GetExamsArrayGivenQuestion(id string) []string {
	AddressAllowed()
	return MainRepository.GetArrayExamsUsingThisQuestion(id)
}

// Blocker to restrict to creator
func AddressAllowed() {
	caller := std.GetOrigCaller().String()
	if caller != Creator {
		panic(ErrAddressNotAllowed)
	}
}

// Returns the owner of the realm
func GetCreator() string {
	return Creator
}

// All public Functions

// Returns the list of ids of the exams the applicant is going to do.
// It doesn't show the exams the user has already made
func GetMyPendingExams(caller string) string {
	var examsList string
	examsInterface, ok := Applicants.Get(caller)
	if !ok {
		panic(ErrNoPendingExams)
	} else {
		exams := examsInterface.(avl.Tree)
		exams.Iterate("", "", func(key string, value interface{}) bool {
			examsList += key
		})
		return examsList
	}
}

// Makes the caller drop the exam if is registered in it
func DropExam(id string) {
	caller := std.GetOrigCaller().String()
	exam := MainRepository.GetExamById(id)
	applicantsInterface := exam.GetApplicantsTree()
	applicants := applicantsInterface.(avl.Tree)
	applicants.Remove(caller)
	exam.UpdateApplicants(applicants)
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
