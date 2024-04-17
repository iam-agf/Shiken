package shikenrepository

import (
	"strings"
	"strconv"
	avl 			"gno.land/p/demo/avl"
	ufmt			"gno.land/p/demo/ufmt"
	shikenquestion 	"gno.land/p/dev/shikenquestion"
	shikenexam 			"gno.land/p/dev/shikenexam"
	std				"std"
)

// The Question structure must be not editable except for the kind entry.
// This is in order to protect the candidates that answer this question.
// Because this way the examinator can't edit the question after
// has been used in an exam.

type Repository struct {
	author    string
	questions avl.Tree // id -> *Question
	exams     avl.Tree // id -> *Exam
}

// Basic variables
var exams avl.Tree		// Map of exams
var questions avl.Tree	// Map of questions
var idQuestion int		// Id of the next Question
var idExam int			// Id of next Exam

// Error outputs
const ErrNoExistingId = "Id requested doesn't exist"

func Render(path string) string {
	words := strings.Split(path,"/")
	switch words[0]{
	case "exams":
			return ufmt.Sprintf("exams %d",idExam)
	case "questions":
			return ufmt.Sprintf("questions %d",idQuestion)	
	default:
			return ufmt.Sprintf(`
			%s
			[exams](/r/dev/shikenrepository:exams)
			[questions](/r/dev/shikenrepository:questions)
			`, words[0])
	}
}

func AddQuestion(statement string, kind uint, options string, categories string, answer string) {
	categoriesArray := separateContent(categories)
	optionsArray := separateContent(options)
	increaseIdQuestion()
	q := shikenquestion.NewQuestion(statement, kind, idQuestion, optionsArray, answer, categoriesArray)
	questions.Set(strconv.Itoa(idQuestion), q)
}

func AddExam(title string, questions string, description string) {
	increaseIdExam()
	e := shikenexam.NewExam(title, description, questions, idExam)
	exams.Set(strconv.Itoa(idExam),e)
}

func separateContent(words string) []string {
	if len(words) == 0 {
		return []string{}
	}
	separatedWords := strings.Split(words, ",")
	return separatedWords
}

func increaseIdQuestion(){
	idQuestion++
}

func increaseIdExam(){
	idExam++
}

func counterQuestions() int {
	return idQuestion
}

func counterExams() int {
	return idExam
}

func ReadQuestion(id string) string {
	qt, ok := questions.Get(id)
	if !ok {
		panic(ErrNoExistingId)
	} else{
		q := qt.(*shikenquestion.Question)
		var output string
		if q.GetKind() != uint(2) {
			o := q.GetOptions()
			output = ufmt.Sprintf(`%s
	1) %s
	2) %s
	3) %s
	4) %s`, q.GetQuestion(), o[0], o[1], o[2], o[3])
		} else {
			output = q.GetQuestion()
		}
		return output
	}
	return ""
}

func ReadExam(id string) string {
	ex, ok := exams.Get(id)
	if !ok {
		panic(ErrNoExistingId)
	} else{
		e := ex.(*shikenexam.Exam)
		var output string
		output = ufmt.Sprintf(`%s
		%s`,e.GetTitle(), e.GetDescription())
		return output
	}
	return ""
}