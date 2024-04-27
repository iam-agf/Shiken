package shikenexam

import (
	"std"
	"strings"
	"strconv"
	"time"
	avl		"gno.land/p/demo/avl"
)

type Exam struct {
	title             string              // Name of Exam
	description       string              // Description for Exam
	id 				  int   		      // Id of the exam
	categories        []string            // Categories where this Exam is involved.
	questions         []int 			  // Set of ids of the questions to be asked in the Exam
	ponderation       avl.Tree            // Scoring for the questions.
	applicants        avl.Tree            // List of users that can apply to this Exam
	answersApplicants avl.Tree            // Answers from the Applicants
	startTime		  time.Time           // Time the exam should start
	endTime		  	  time.Time           // Time the exam should end
}

func NewExam(title string, description string, questions []int, applicants []string, id int) *Exam {
	var applicantsTree avl.Tree

	for _, appl := range applicants{
		applicantsTree.Set(appl, true)
	}

	return &Exam{
		id: id,
		title: title,
		description: description,
		questions: questions,
		applicants: applicantsTree,
	}
}

// Updates the exam's title with the given one
func (e *Exam) EditTitle(newTitle string){
	e.title = newTitle
}

// Updates the exam's description with the given one
func (e *Exam) EditDescription(newDescription string){
	e.description = newDescription
}

// Updates the list of categories
func (e *Exam) EditCategories(categories []string){
	e.categories = categories
}


/* // Adds the given address to the allowed applicants
// to the exam
func (e *Exam) AddApplicant(applicant std.Address) bool {
	if e.endTime == nil || e.endTime < 
	return e.applicants.Set(applicant.String(),true)
}
*/

// Returns if the given address is allowed to apply to 
// this exam
func (e *Exam) VerifyApplicant(applicant std.Address) bool {
	return e.applicants.Has(applicant.String())
}

/* func (e *Exam) SetStartTime(){
	
}
 */

// Get the exam's title
func (e *Exam) GetTitle() string {
	return e.title
}

// Get the exam's questions
func (e *Exam) GetQuestions() []int {
	return e.questions
}

// Get the exam's description
func (e *Exam) GetDescription() string {
	return e.description
}

// Returns the scores of the applicants in the exam
func (e *Exam) GetRecord() avl.Tree {
	return e.answersApplicants
}

// Returns the list of addresses allowed to apply to this Exam
func (e *Exam) GetApplicants() []string {
	var applicants []string
	e.applicants.Iterate("","", func(key string, value interface{}) bool {
		applicants = append(applicants, key)
	})
	return applicants
}

// Returns the avl.Tree of addresses allowed to apply to this Exam
func (e *Exam) GetApplicantsTree() avl.Tree {
	return e.applicants
}

// Returns the startTime of the exam
func (e *Exam) GetStartTime() time.Time {
	return e.startTime
}

// Returns the endTime of the exam
func (e *Exam) GetEndTime() time.Time {
	return e.endTime
}