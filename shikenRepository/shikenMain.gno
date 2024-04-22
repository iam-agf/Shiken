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

// Main structure that stores relevant information
var mainRepository Repository

func Render(path string) string {
	words := strings.Split(path,"/")
	ufmt.Sprintf("%d", mainRepository.GetIdExam())
	ufmt.Sprintf("%d", mainRepository.GetIdQuestion())
	switch words[0]{
	case "exams":
			return ufmt.Sprintf(`Exams %d`, mainRepository.GetIdExam())
	case "questions":
			return ufmt.Sprintf(`Questions %d

	%s`, mainRepository.GetIdQuestion(), ReadQuestions())	
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

func AddExam(title string, questions string, description string) {
	mainRepository.AddExam(title, questions, description)
}

func ReadQuestions() string {
	var str = ``
	ids := mainRepository.GetIdQuestion()
	for id := 1; id <= ids; id++{
		str += mainRepository.ReadQuestion(strconv.Itoa(id)) + ``
	}
/* 	mainRepository.Questions.Iterate("", "", func(name string, value interface{}) bool {
		content += " * " + name + ".- " + value.(*shikenquestion.Question).GetQuestion() + "\n"
		str += " * " + name + ".- " + value.(*shikenquestion.Question).GetQuestion() + "\n"
		return false
	}) */
	return str
}