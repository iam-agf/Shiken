package shikenexam

import (
	"time"

	avl "gno.land/p/demo/avl"
	ufmt "gno.land/p/demo/ufmt"
)

type Exam struct {
	title             string    // Name of Exam (encrypted)
	description       string    // Description for Exam (encrypted)
	id                int       // Id of the exam
	questions         string    // Set of ids of the questions to be asked in the Exam (encrypted)
	applicants        avl.Tree  // List of users that can apply to this Exam
	answersApplicants avl.Tree  // Answers from the Applicants
	startTime         time.Time // Time the exam should start
	endTime           time.Time // Time the exam should end
	hashAES           string    // Encryption key for this exam
}

const (
	ErrAddressNotAllowed = "Address not allowed!"
	ErrNoCandidateRecord = "No candidate answers registered!"
)

func NewExam(title string, description string, questions string, applicants []string, id int, hashAES string) *Exam {
	var applicantsTree avl.Tree

	for _, appl := range applicants {
		applicantsTree.Set(appl, true)
	}

	return &Exam{
		id:          id,
		title:       title,
		description: description,
		questions:   questions,
		applicants:  applicantsTree,
		hashAES:     hashAES,
	}
}

// Adds the given address to the allowed applicants
// to the exam. There is no need to put any restriction to add
// an applicant since the applicant will only be able to send
// his answers if the exam is still in the application window
func (e *Exam) AddApplicant(applicant string) bool {
	e.applicants.Set(applicant, true)
	// The line below is just to check if the applicant was successfully added
	return e.VerifyApplicant(applicant)
}

// Returns if the given address is registered as an allowed one
// to apply this exam
func (e *Exam) VerifyApplicant(applicant string) bool {
	_, ok := e.applicants.Get(applicant)
	if !ok {
		return false
	}
	return true
}

func (e *Exam) EditExam(title, questions, description string, applicants []string) {
	e.UpdateTitle(title)
	e.UpdateDescription(description)
	e.UpdateQuestions(questions)
	newApplicants := avl.Tree{}
	for _, appl := range applicants {
		newApplicants.Set(appl, true)
	}
	e.UpdateApplicants(newApplicants)
}

// Returns the list of addresses allowed to apply to this Exam
func (e *Exam) GetApplicants() []string {
	var applicants []string
	e.applicants.Iterate("", "", func(key string, value interface{}) bool {
		applicants = append(applicants, key)
		return false
	})
	return applicants
}

// Basic Get functions

func (e *Exam) GetTitle() string {
	return e.title
}

func (e *Exam) GetDescription() string {
	return e.description
}

func (e *Exam) GetId() int {
	return e.id
}

func (e *Exam) GetQuestions() string {
	return e.questions
}

func (e *Exam) GetApplicantsTree() avl.Tree {
	return e.applicants
}

func (e *Exam) GetAnswerApplicantsTree() avl.Tree {
	return e.answersApplicants
}

func (e *Exam) GetStartTime() time.Time {
	return e.startTime
}

func (e *Exam) GetEndTime() time.Time {
	return e.endTime
}

func (e *Exam) GetHashAES() string {
	return e.hashAES
}

// Update functions

func (e *Exam) UpdateTitle(c string) {
	e.title = c
}

func (e *Exam) UpdateDescription(c string) {
	e.description = c
}

func (e *Exam) UpdateQuestions(c string) {
	e.questions = c
}

func (e *Exam) UpdateApplicants(c avl.Tree) {
	e.applicants = c
}

func (e *Exam) UpdateStartTime(c time.Time) {
	e.startTime = c
}

func (e *Exam) UpdateEndTime(c time.Time) {
	e.endTime = c
}

// Applicants functions

func (e *Exam) SendAnswers(applicant string, answers avl.Tree) {
	e.answersApplicants.Set(applicant, answers)
}

// Creator relevant functions

func (e *Exam) CheckAllAnswers() string {
	output := ""
	e.answersApplicants.Iterate("", "", func(key string, value interface{}) bool {
		answers := value.(string)
		output += ufmt.Sprintf(`"%s":"%s",`, key, answers)
		return false
	})
	output = "{" + output[:len(output)-1] + "}"
	return output
}

func (e *Exam) CheckCandidateAnswers(applicant string) string {
	output := ""
	answersInterface, ok := e.answersApplicants.Get(applicant)
	if !ok {
		panic(ErrNoCandidateRecord)
	}
	answers := answersInterface.(string)
	output = ufmt.Sprintf(`{"%s":%s}`, applicant, answers)
	return output
}
