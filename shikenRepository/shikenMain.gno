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

// Main structure that stores relevant information
var mainRepository Repository

func Render(path string) string {
	words := strings.Split(path,"/")
	ufmt.Sprintf("%d", mainRepository.GetIdExam())
	ufmt.Sprintf("%d", mainRepository.GetIdQuestion())
	switch words[0]{
	case "exams":
			return ufmt.Sprintf("Exams %d\n\n%s", mainRepository.GetIdExam(), ReadExams())
	case "questions":
			return ufmt.Sprintf("Questions %d\n\n%s", mainRepository.GetIdQuestion(), ReadQuestions())	
	default:
			return ufmt.Sprintf(`
			%s
			[exams](/r/dev/shikenrepository:exams)
			[questions](/r/dev/shikenrepository:questions)
			`, words[0])
	}
}

func AddQuestion(statement string, kind uint, options string, categories string, answer string) {
	mainRepository.AddQuestion(statement, kind, options, categories, answer)
}

func AddExam(title string, questions string, description string, applicantsString string) {
	if len(title) == 0 {
		panic(ErrEmptyTitle)
	}
	applicantsArray := strings.Split(applicantsString,",")
	mainRepository.AddExam(title, questions, description, applicantsArray)
}

func ReadExams() string {
	var str = ""
	ids := mainRepository.GetIdExam()
	for id := 1; id <= ids; id++{
		content := ReadOneExam(strconv.Itoa(id))
		if content != ErrNoExistingId{
			str += content
		}
	}
	return str
}

func ReadOneExam(id string) string {
	var str string 
	
	e := mainRepository.GetExamById(id)
	str += "## " + e.GetTitle() + "\n"
	//str += e.GetDescription() + "\n"
	//str += "### Questions" + '\n'

	allQuestions := mainRepository.GetQuestions()
	qs := e.GetQuestions()
	for _, id := range qs{
		str += ReadOneQuestion(strconv.Itoa(id))
	}
	return str
}

func ReadQuestions() string {
	var str string
	ids := mainRepository.GetIdQuestion()
	for id := 1; id <= ids; id++{
		str += ReadOneQuestion(strconv.Itoa(id))
	}
	return str
}

// Reads one question 
func ReadOneQuestion(id string) string {
	var str string
	content := mainRepository.ReadQuestion(id)
	if content != ErrNoExistingId{
		str += content
	}
	return str
}

// Deletes a question in case it hasn't been used
func DeleteQuestion(id string) { 
	if mainRepository.CanDeleteQuestion(id) {
		mainRepository.Questions.Remove(id)
	} else {
		panic(ErrNotPossibleToDelete)
	}

}
