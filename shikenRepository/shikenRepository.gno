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
	QuestionsUsed avl.Tree 		// qId -> avl.Tree{examID -> true} using the question with id 'qId'
	Pubkey string				// Public key to encrypt all content of this Repository
	privkey string				// Private Key (previously encrypted by user password via off-chain)
	idQuestion int				// Id of the next Question
	idExam int					// Id of next Exam
}

// Errors

const ErrQuestionUnderUsage = "Question under usage"
const ErrExamUnderUsage = "Exam under usage"
const ErrQuestionNotUsed = "Question isn't used"

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
		if exams, ok := r.QuestionsUsed.Get(qId); !ok {
			avlTreeQuestion := avl.Tree{}
			avlTreeQuestion.Set(idExamString, true)
			r.QuestionsUsed.Set(qId, avlTreeQuestion)
			// else just register the exam
			} else {
				examsStruct := exams.(avl.Tree)
				examsStruct.Set(idExamString,true)
				r.QuestionsUsed.Set(qId, examsStruct)
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
func (r *Repository) DeleteExam(idInt int) {
	eId := strconv.Itoa(idInt)
	if r.CanDeleteExam(eId) {
		r.QuestionsUsed.Iterate("","", func(qId string, value interface{}) bool {
			r.RemoveExamUsingQuestionId(qId,eId)
		})
		r.Exams.Remove(eId)
	} else {
		panic(ErrExamUnderUsage)
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
// Converts an array of strings into an array of ints
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
	examsInterface, dontExist := r.QuestionsUsed.Get(id)
	if !dontExist{
		return true
	}
	exams := examsInterface.(avl.Tree)
	if exams.Size() == 0 {
		return true
	} else {
		return false
	}
}

// Checks if an exam hasn't started yet, doesn't have questions or doesn't
// have applicants to answer if can be deleted or not
func (r *Repository) CanDeleteExam(id string) bool {
	examInterface, dontExist := r.Exams.Get(id)
	if !dontExist {
		return true 
	} else {
		exam := examInterface.(*shikenexam.Exam)

		appls := exam.GetApplicantsTree()
		qs := exam.GetQuestions()
		start := exam.GetStartTime()
		end := exam.GetEndTime()

		// Conditions
		noApplicants := appls.Size() == 0
		noQuestions := len(qs) == 0
		noTime := start == end

		// filters
		if noApplicants {
			return true
		}
		if noQuestions {
			return true
		}
		if noTime {
			return true
		}
		return false
	}
}

/* // Detatch a Question from an Exam
func (r *Repository) DetachQuestionFromExam(qId string eId string) {
	return
}
 */
// ## Update Functions

// Increases by 1 the Id for the next question
func (r *Repository) IncreaseIdQuestion(){
	r.idQuestion++
}

// Increases by 1 the Id for the next exam
func (r *Repository) IncreaseIdExam(){
	r.idExam++
}

// Remove the Exam using this Question
func (r *Repository) RemoveExamUsingQuestionId(qId string, qExam string) {
	avlTreeInterface, dontExist := r.QuestionsUsed.Get(qId) // Gets the 
	if !dontExist {
		panic(ErrQuestionNotUsed)
	}
	questionsTree := avlTreeInterface.(avl.Tree)
	questionsTree.Remove(qExam)
	if questionsTree.Size() == 0{
		r.QuestionsUsed.Remove(qId)
	} else {
		r.QuestionsUsed.Set(qId, questionsTree)
	}
}

// Adds an Exam using this Question
func (r *Repository) AppendExamUsingQuestionId(qId string, qExam string) {
	avlTreeInterface, dontExist := r.QuestionsUsed.Get(qId) // Gets the 
	if !dontExist {
		panic(ErrQuestionNotUsed)
	}
	questionsTree := avlTreeInterface.(avl.Tree)
	questionsTree.Set(qExam, true)
	r.QuestionsUsed.Set(qId, questionsTree)
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

// Gets the last Id used to register a Question
func (r *Repository) GetIdQuestion() int {
	return r.idQuestion
}

// Gets the last Id used to register an Exam
func (r *Repository) GetIdExam() int {
	return r.idExam
}


// Get the Exams that use the Question with the given Id
func (r *Repository) GetExamsUsingThisQuestions(id string) avl.Tree {
	examsInterface, ok := r.QuestionsUsed.Get(id)
	if !ok{
		panic(ErrQuestionNotUsed)
	}
	exams := examsInterface.(avl.Tree)
	return exams
}

// Get the Exams that use the Question with the given Id
func (r *Repository) GetArrayExamsUsingThisQuestion(id string) []string {
	var eArr []string
	examsInterface, ok := r.QuestionsUsed.Get(id)
	if !ok{
		panic(ErrQuestionNotUsed)
	}
	exams := examsInterface.(avl.Tree)
	exams.Iterate("","", func(key string, value interface{}) bool {
		eArr = append(eArr, key)
	})
	return eArr
}