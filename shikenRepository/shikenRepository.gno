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

const ErrNoExistingExam = "No exam with given Id"


type Repository struct {
	Exams avl.Tree				// List of Exams
	Questions avl.Tree			// List of Questions
	QuestionsUsedBy avl.Tree	// key -> avl.Tree{examID -> true} using the question with id 'key'
	Pubkey string				// Public key to encrypt all content of this Repository
	privkey string				// Private Key (previously encrypted by user password via off-chain)
	idQuestion int				// Id of the next Question
	idExam int					// Id of next Exam
}

// Errors

const ErrQuestionUnderUsage = "Question under usage"

// Add functions

// Add Question to the Repository
func (r *Repository) AddQuestion(statement string, kind uint, options string, categories string, answer string) {
	categoriesArray := separateContent(categories)
	optionsArray := separateContent(options)
	r.IncreaseIdQuestion()
	q := shikenquestion.NewQuestion(statement, kind, r.GetIdQuestion(), optionsArray, answer, categoriesArray)
	r.Questions.Set(strconv.Itoa(r.GetIdQuestion()), q)
}

// Add Exam to the Repository
func (r *Repository) AddExam(title string, questions string, description string, applicants []string) {
	r.IncreaseIdExam()
	idExam := r.GetIdExam()
	idExamString := strconv.Itoa(idExam)
	questionStrings := strings.Split(questions, ",")
	questionInts := stringsToInts(questionStrings)
	e := shikenexam.NewExam(title, description, questionInts, applicants, idExam)
	r.Exams.Set(idExamString,e)
	// Registers in each question the exam that will use it
	for _, qId := range questionStrings {
		// if the question isn't registered generate the avl.Tree and set the values
		if exams, ok := r.QuestionsUsedBy.Get(qId); !ok {
			avlTreeQuestion := avl.Tree{}
			avlTreeQuestion.Set(idExamString, true)
			r.QuestionsUsedBy.Set(qId, avlTreeQuestion)
			// else just register the exam
			} else {
				examsStruct := exams.(avl.Tree)
				examsStruct.Set(idExamString,true)
				r.QuestionsUsedBy.Set(qId, examsStruct)
		}
	}
}

// ## Remove functions

func (r *Repository) DeleteQuestion(idInt int) {
	id := strconv.Itoa(idInt)
	if r.CanDeleteQuestion(id) {
		r.Questions.Remove(id)
	} else {
		panic(ErrQuestionUnderUsage)
	}
}

// ## Supporting functions

// Splits the content of a string of words separated by a comma.
func separateContent(words string) []string {
	if len(words) == 0 {
		return []string{}
	}
	separatedWords := strings.Split(words, ",")
	return separatedWords
}

func stringsToInts(questionStrings []string) []int {
	var questionIds []int
	for _, q := range questionStrings{
		qId, err := strconv.Atoi(q)
		if err != nil {
			panic(err)
		}
		questionIds = append(questionIds, qId)
	}
	return questionIds
}

// Checks if a question has been used in an exam
// so it can be deleted or not
func (r *Repository) CanDeleteQuestion(id string) bool {
	exams := r.GetExamsUsingQuestionsByQuestionId()
	used, dontExist := exams.Get(id)
	if !dontExist {
		return true 
	} else {
		return false
	}
	return true
}

// ## Increase Functions

// Increases by 1 the Id for the next question
func (r *Repository) IncreaseIdQuestion(){
	r.idQuestion++
}

// Increases by 1 the Id for the next exam
func (r *Repository) IncreaseIdExam(){
	r.idExam++
}

// ## Read Functions

// Gets the information from a Question and returns
// a string containing the information related to it
// to print it wherever is needed
func (r *Repository) ReadQuestion(id string) string {
	qt, ok := r.Questions.Get(id)
	if !ok {
		""
	} else {
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
			output = "## "+ q.GetQuestion() + "\n (open question) \n"
		}
		return output + "\n"
	}
	return ""
}

// Gets the information from an Exam and returns
// a string containing the information related to it
// to print it wherever is needed
func (r *Repository) ReadExam(id string) string {
	ex, ok := r.Exams.Get(id)
	if !ok {
		return ""
	} else{
		e := ex.(*shikenexam.Exam)
		output := ufmt.Sprintf("## %s \n %s \n ",e.GetTitle(), e.GetDescription())
		return output
	}
	return ""
}

// ## Get functions

func (r *Repository) GetQuestions() avl.Tree {
	return r.Questions
}

func (r *Repository) GetExamById(id string) *shikenexam.Exam {
	e, ok := r.Exams.Get(id)
	if !ok {
		panic(ErrNoExistingExam)
	}
	return e.(*shikenexam.Exam)
}

// Gets the last Id used to register a question
func (r *Repository) GetIdQuestion() int {
	return r.idQuestion
}

// Gets the last Id used to register an exam
func (r *Repository) GetIdExam() int {
	return r.idExam
}

// Get the Questions that are used by an exam
func (r *Repository) GetExamsUsingQuestionsByQuestionId() avl.Tree {
	return r.QuestionsUsedBy
}