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

// Returns the list of addresses allowed to apply to this Exam
func (e *Exam) GetApplicants() []string {
	var applicants []string
	e.applicants.Iterate("","", func(key string, value interface{}) bool {
		applicants = append(applicants, key)
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
func (e *Exam) GetCategories() []string {
	return e.categories
}
func (e *Exam) GetQuestions() []int {
	return e.questions
}
func (e *Exam) GetPonderation() avl.Tree {
	return e.ponderation
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

// Update functions

func (e *Exam) UpdateTitle(c string) {
	e.title = c
}
func (e *Exam) UpdateDescription(c string) {
	e.description = c
}
func (e *Exam) UpdateCategories(c []string) {
	e.categories = c
}
func (e *Exam) UpdateQuestions(c []int) {
	e.questions = c
}
func (e *Exam) UpdatePonderation(c avl.Tree) {
	e.ponderation = c
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