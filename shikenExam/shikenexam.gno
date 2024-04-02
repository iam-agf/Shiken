package shikenexam

import (
	question "gno.land/p/dev/shikenquestion"
	"std"
)

type Exam struct {
	creator           std.Address         // Creator of Exam
	title             string              // Name of Exam
	description       string              // Description for Exam
	categories        []string            // Categories where this Exam is involved.
	questions         []uint 			  // Set of ids of the questions to be asked in the Exam
	ponderation       avl.Tree            // Scoring for the questions.
	applicants        avl.Tree            // List of users that can apply to this Exam
	answersApplicants avl.Tree            // Answers from the Applicants
	record            []string            // Scoring for the exam
}

func NewExam(title string, description string, questions []uint) Exam {
	return Exam{
		title: title,
		description: description,
		questions: questions,
	}
}