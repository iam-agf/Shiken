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

// Error outputs
const ErrNoExistingId = "Id requested doesn't exist"

// The Question structure must be not editable except for the kind entry.
// This is in order to protect the candidates that answer this question.
// Because this way the examinator can't edit the question after
// has been used in an exam.

type Repository struct {
	Exams avl.Tree			// List of Exams
	Questions avl.Tree		// List of Questions
	AppliedExams avl.Tree	// Exams already expired (useful to delete questions)
	Pubkey string			// Public key to encrypt all content of this Repository
	privkey string			// Private Key (previously encrypted by user password via off-chain)
	idQuestion int			// Id of the next Question
	idExam int				// Id of next Exam
}

func (r *Repository) AddQuestion(statement string, kind uint, options string, categories string, answer string) {
	categoriesArray := separateContent(categories)
	optionsArray := separateContent(options)
	r.IncreaseIdQuestion()
	q := shikenquestion.NewQuestion(statement, kind, r.GetIdQuestion(), optionsArray, answer, categoriesArray)
	r.Questions.Set(strconv.Itoa(r.GetIdQuestion()), q)
}

func (r *Repository) AddExam(title string, questions string, description string) {
	r.IncreaseIdExam()
	idExam := r.GetIdExam()
	e := shikenexam.NewExam(title, description, questions, idExam)
	r.Exams.Set(strconv.Itoa(idExam),e)
}

func separateContent(words string) []string {
	if len(words) == 0 {
		return []string{}
	}
	separatedWords := strings.Split(words, ",")
	return separatedWords
}


// Functions for Ids (Questions & Exams)
func (r *Repository) IncreaseIdQuestion(){
	r.idQuestion++
}

func (r *Repository) IncreaseIdExam(){
	r.idExam++
}

func (r *Repository) GetIdQuestion() int {
	return r.idQuestion
}

func (r *Repository) GetIdExam() int {
	return r.idExam
}


func (r *Repository) ReadQuestion(id string) string {
	qt, ok := r.Questions.Get(id)
	if !ok {
		panic(ErrNoExistingId)
	} else{
		q := qt.(*shikenquestion.Question)
		var output string
		if q.GetKind() != uint(2) {
			o := q.GetOptions()
			output = ufmt.Sprintf(`## %s
	1) %s
	2) %s
	3) %s
	4) %s
	`, q.GetQuestion(), o[0], o[1], o[2], o[3])
		} else {
			output = "## "+ q.GetQuestion() + "\n (open ended) \n"
		}
		return output + "\n"
	}
	return ""
}

func (r *Repository) ReadExam(id string) string {
	ex, ok := r.Exams.Get(id)
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