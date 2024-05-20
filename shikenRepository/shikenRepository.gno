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

const (
	ErrNoExistingExam  = "No exam with given Id"
	ErrUnexpectedError = "Something that should never happen, happened"
)

// To avoid the chance of applicants to know the Topics with Gnoscan,
// The topics will be also encrypted. It's recommended to use the same
// password, since it would be really annoying to decrypt them one by one
type Repository struct {
	Exams             avl.Tree // ExamId -> Exam
	ExamQuestions     avl.Tree // ExamId -> avl.Tree {QuestionId -> Question} [This way can be encrypted for the applicants]
	QuestionsByTopics avl.Tree // Topic(any string) -> avl.Tree {QuestionId -> Question}
	idQuestion        int      // Id of the next Question
	idExam            int      // Id of next Exam
}

// Errors

const (
	ErrQuestionUnderUsage = "Question under usage"
	ErrExamUnderUsage     = "Exam under usage"
	ErrQuestionNotUsed    = "Question isn't used"
)

// Add functions

// Adds your Question to the Repository in the topic you register.
// If topic is empty, it will be sent to general
func (r *Repository) AddQuestion(topic string, statement string, kind string, optionsArray string, answer string, hashAES string) {
	if topic == "" {
		topic = "general"
	}
	// This is to avoid several topics with typos (It's tough to assume the user knows how to write)
	topic = strings.ToLower(topic)
	options := strings.Split(optionsArray, ",")
	r.IncreaseIdQuestion()
	qId := r.GetIdQuestion()
	q := shikenquestion.NewQuestion(statement, kind, qId, options, answer, hashAES)
	qIdString := strconv.Itoa(qId)
	topicQuestionsInterface, ok := r.QuestionsByTopics.Get(topic)
	var topicQuestions avl.Tree
	if !ok {
		topicQuestions := avl.Tree{}
		topicQuestions.Set(qIdString, q)
	} else {
		topicQuestions := topicQuestionsInterface.(avl.Tree)
		topicQuestions.Set(qIdString, q)
	}
	r.QuestionsByTopics.Set(topic, topicQuestions)
}

// Add Exam to the Repository
func (r *Repository) AddExam(title string, questions string, description string, applicants []string, hashAES string) {
	r.IncreaseIdExam()
	idExam := r.GetIdExam()
	idExamString := strconv.Itoa(idExam)
	// There is no chance to review any content in the exam, so everything enters as how is received
	// The only non encrypted data is the applicants entry
	e := shikenexam.NewExam(title, description, questions, applicants, idExam, hashAES)
	r.Exams.Set(idExamString, e)
	// Registers in each question the exam that will use it
}

func (r *Repository) DeleteExam(examId string) {
	// Ask if it's deletable
	if canDeleteExam := r.CanDeleteExam(examId); canDeleteExam {
		// Removes the exam from the list of exams
		_, ok := r.Exams.Remove(examId)
		if ok {
			// Removes the exam questions from the list of exam questions
			_, okk := r.ExamQuestions.Remove(examId)
			if !okk {
				panic(ErrNoExistingExam)
			}
		} else {
			panic(ErrNoExistingExam)
		}
	}
}

// ## Supporting functions

// Converts an array of strings into an array of ints
func stringsToInts(questionStrings []string) []int {
	var questionIds []int
	for _, q := range questionStrings {
		qId, err := strconv.Atoi(q)
		if err != nil {
			panic(err)
		}
		questionIds = append(questionIds, qId)
	}
	return questionIds
}

// Checks if an exam hasn't started yet, doesn't have questions or doesn't
// have applicants to answer if can be deleted or not
func (r *Repository) CanDeleteExam(id string) bool {
	examInterface, dontExist := r.Exams.Get(id)
	if !dontExist {
		return true
	}
	exam := examInterface.(*shikenexam.Exam)

	appls := exam.GetApplicantsTree()
	start := exam.GetStartTime()
	end := exam.GetEndTime()

	// conditions
	if appls.Size() == 0 {
		return true
	}
	if start == end {
		return true
	}
	_, noQuestions := r.ExamQuestions.Get(id)
	if !noQuestions {
		return true
	}
	return false
}

// ## Update Functions

// Increases by 1 the Id for the next question
func (r *Repository) IncreaseIdQuestion() {
	r.idQuestion++
}

// Increases by 1 the Id for the next exam
func (r *Repository) IncreaseIdExam() {
	r.idExam++
}

// ## Read Functions

// Gets the information from an Exam and returns
// a string containing the information related to it
// to print it wherever is needed
func (r *Repository) ReadExam(id string) string {
	ex, ok := r.Exams.Get(id)
	if !ok {
		return ""
	} else {
		e := ex.(*shikenexam.Exam)
		output := ufmt.Sprintf("## %s \n %s \n", e.GetTitle(), e.GetDescription())
		return output
	}
	return ""
}

// ## Get functions

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
