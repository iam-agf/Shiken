package shikenexam

import (
	"std"
	avl		"gno.land/p/demo/avl"
)

type Exam struct {
	creator           std.Address         // Creator of Exam
	title             string              // Name of Exam
	description       string              // Description for Exam
	id 				  uint   		      // Id of the exam
	categories        []string            // Categories where this Exam is involved.
	questions         []uint 			  // Set of ids of the questions to be asked in the Exam
	ponderation       avl.Tree            // Scoring for the questions.
	applicants        avl.Tree            // List of users that can apply to this Exam
	answersApplicants avl.Tree            // Answers from the Applicants
	record            []string            // Scoring for the exam
}

var exams avl.Tree
var id uint

func NewExam(title string, description string, questions []uint) Exam {
	incrementId()
	return Exam{
		id: id,
		title: title,
		description: description,
		questions: []uint{},
	}
}

func incrementId() {
	id++
}