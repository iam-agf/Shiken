package shikenrepository

import (
	"strings"
	"strconv"
	avl 			"gno.land/p/demo/avl"
	ufmt			"gno.land/p/demo/ufmt"
	shikenquestion 	"gno.land/p/dev/shikenquestion"
	shikenexam 		"gno.land/p/dev/shikenexam"
	std				"std"
)

// Error outputs
const ErrNoExistingId = "Id requested doesn't exist"
const ErrNotPossibleToDelete = "Id requested can't be deleted"
const ErrEmptyTitle = "Exam title can't be empty"
const ErrNoPendingExams = "You don't have pending exams!"
const ErrAddressNotAllowed = "Address not allowed!"

// Main structure that stores relevant information
var MainRepository Repository
var Applicants avl.Tree
var Creator std.Address

func init() {
	// Sets the creator of the Realm
	Creator = std.PrevRealm().Addr()
	Applicants = avl.Tree{}
	MainRepository = Repository{}
}

func Render(path string) string {
	words := strings.Split(path,"/")
	ufmt.Sprintf("%d", MainRepository.GetIdExam())
	ufmt.Sprintf("%d", MainRepository.GetIdQuestion())
	switch words[0]{
	case "exams":
			return ufmt.Sprintf("Exams %d\n\n%s", MainRepository.GetIdExam(), ReadExams())
	case "questions":
			return ufmt.Sprintf("Questions %d\n\n%s", MainRepository.GetIdQuestion(), ReadQuestions())	
	default:
			return ufmt.Sprintf(`
			%s
			[exams](/r/dev/shikenrepository:exams)
			[questions](/r/dev/shikenrepository:questions) <br><br>
			Created by %s
			`, words[0], GetCreator())
	}
}

// Add functions

// Add a Questions to the MainRepository Structure
func AddQuestion(statement string, kind uint, options string, categories string, answer string) {
	caller := std.GetOrigCaller()
	if caller != Creator {
		panic(ErrAddressNotAllowed)
	}
	MainRepository.AddQuestion(statement, kind, options, categories, answer)
}

// Add an Exam to the MainRepository Structure
func AddExam(title string, questions string, description string, applicantsString string) {
	caller := std.GetOrigCaller()
	if caller != Creator {
		panic(ErrAddressNotAllowed)
	}
	if len(title) == 0 {
		panic(ErrEmptyTitle)
	}
	applicantsArray := strings.Split(applicantsString,",")
	id := MainRepository.AddExam(title, questions, description, applicantsArray)
	for _, appl := range applicantsArray {
		SetApplicant(appl, id)
	}
}

// Read all the exams and returns it as a string if the caller is the creator.
// If the caller isn't the creator returns an empty string 
func ReadExams() string {
	// Blocker to avoid panic issue
	caller := std.GetOrigCaller()
	if caller != Creator {
		return ""
	}

	// In case the address is allowed
	var str = ""
	ids := MainRepository.GetIdExam()
	for id := 1; id <= ids; id++{
		content := ReadOneExam(strconv.Itoa(id))
		if content != ErrNoExistingId{
			str += content
		}
	}
	return str
}

// Reads the exam with the given id and returns it as a string if the caller is 
// the creator. If the caller isn't the creator returns an empty string
func ReadOneExam(id string) string {
	// Blocker for not allowed address
	caller := std.GetOrigCaller()
	if caller != Creator {
		return ""
	}

	var str string 
	e := MainRepository.GetExamById(id)
	str += "## " + e.GetTitle() + "\n"

	allQuestions := MainRepository.GetQuestions()
	qs := e.GetQuestions()
	for _, id := range qs{
		str += ReadOneQuestion(strconv.Itoa(id))
	}
	return str
}

// Read all the questions and returns it as a string if the caller is the 
// creator. If the caller isn't the creator returns an empty string
func ReadQuestions() string {
	var str string
	ids := MainRepository.GetIdQuestion()
	for id := 1; id <= ids; id++{
		str += ReadOneQuestion(strconv.Itoa(id))
	}
	return str
}

// Reads the question with the given id and returns it as a string if the 
// caller is the creator. If the caller isn't the creator returns an empty
// string.
func ReadOneQuestion(id string) string {
	var str string
	content := MainRepository.ReadQuestion(id)
	if content != ErrNoExistingId{
		str += content
	}
	return str
}

// Deletes the question with the given id if the caller is the creator and if 
// 1. the question hasn't been used in any exam (If you delete it first in the
// exam, you can remove it).
// 2. the question was not used in previous exams.
// If the caller isn't the creator, it panics.
func DeleteQuestion(id string) { 
	caller := std.GetOrigCaller()
	if caller != Creator {
		panic(ErrAddressNotAllowed)
	}
	if MainRepository.CanDeleteQuestion(id) {
		MainRepository.Questions.Remove(id)
	} else {
		panic(ErrNotPossibleToDelete)
	}

}

// Establishes the exams the applicant can access
func SetApplicant(addr string, idInt int) {
	// Forbids any address different from the creator to change the access
	// to exams
	caller := std.GetOrigCaller()
	if caller != Creator {
		panic(ErrAddressNotAllowed)
	}
	// Start of main set
	id := strconv.Itoa(idInt)
	if _, ok := Applicants.Get(addr); ok {
		applicantExamsInterface, _ := Applicants.Get(addr)
		applicantExams := applicantExamsInterface.(avl.Tree)
		applicantExams.Set(id,true)
	} else {
		applicantExams := avl.Tree{}
		applicantExams.Set(id, true)
		Applicants.Set(addr, applicantExams)
	}
}

// Returns the list of ids of the exams the applicant is going to do.
// It doesn't show the exams the user has already made
func GetMyPendingExams() string {
	var examsList string
	caller := std.GetOrigCaller().String()
	examsInterface, ok := Applicants.Get(caller)
	if !ok {
		panic(ErrNoPendingExams)
	} else {
		exams := examsInterface.(avl.Tree)
		exams.Iterate("","", func(key string, value interface{}) bool {
			examsList += key
		})
		return examsList
	}
}

// Returns the owner of the realm
func GetCreator() string {
	return Creator.String()
}