package shikenrepository

import "shikenQuestion"

// The Question structure must be not editable except for the kind entry.
// This is in order to protect the candidates that answer this question.
// Because this way the examinator can't edit the question after
// has been used in an exam.

type Repository struct {
	author    string
	questions []shikenQuestion.Question
	exams     []shikenExam.Exam
}
