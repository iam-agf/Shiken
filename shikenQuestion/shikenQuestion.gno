package shikenquestion

import (
	"std"

	ufmt "gno.land/p/demo/ufmt"

	avl "gno.land/p/demo/avl"
)

// Given the encryption state of the question once it reaches the
// blockchain, there is no possibility to read the content without
// the information. Because of this, there are several restrictions
// that will be removed
type Question struct {
	answer   string   // Answer. It points the index of the option.
	id       int      // identifier of this question. Not editable
	kind     string   // type of questions as in multiple choice, true/false or open (0,1,2). Not editable.
	options  []string // The encrypted answer(s), if question is multiple choice this will contain multiple options.
	question string   // The statement of the question.
	hashAES  string   // The statement of the question.
}

// This realm is intended to work purely with the website.
// Otherwise expect errors and mistakes in the way it works.

// Panics for generic cases
const (
	ErrKindOutOfRange   = "kind type must be 1,2 or 3"
	ErrShortOptionsList = "options length must be greater or equal to 4"
)

// Panics for options
const (
	ErrEmptyOption                 = "option entry is empty"
	ErrRepeatedOption              = "option entry repeated"
	ErrAnswerNotInOption           = "answer not in options"
	ErrQuestionTypeForbiddenAction = "this question can't change its options"
	ErrCantDeleteMoreOptions       = "can't delete more options. Minimum is 4"
	ErrNotExistingOption           = "Given Option doesn't exist"
	ErrAnswerNotRemovable          = "answer can't be removed"
)

// Panics for Open ended Questions
const (
	ErrOpenQuestionOptions = "open question don't require options"
	ErrOpenQuestionAnswer  = "open question don't require answer"
)

// Creates a new question. Since basically no content can be verified, this
// must only check if the kind matches with the given options
func NewQuestion(question string, kind string, id int, options []string, answer string, hashAES string) *Question {
	switch kind {
	case "0":
		verifyMultipleOptionQuestion(options, answer)
	case "1":
		options = []string{"True", "False", "Can't be determined", "No answer"}
	case "2":
		options = []string{}
		answer = ""
		verifyOpenEndedQuestion(options, answer)
	default:
		panic(ErrKindOutOfRange)
	}

	return &Question{
		id:       id,
		kind:     kind,
		answer:   answer,
		question: question,
		options:  options,
		hashAES:  hashAES,
	}
}

// Verifies if the options in a multiple option Question
// are valid and if the answer is contained in the array
// of options ("0")
func verifyMultipleOptionQuestion(options []string, answer string) {
	if len(options) < 4 {
		panic(ErrShortOptionsList)
	}
	seen := avl.Tree{}
	for _, opt := range options {
		// the option isn't repeated
		_, ok := seen.Get(opt)
		if ok {
			panic(ErrRepeatedOption)
		}
		seen.Set(opt, true)
	}
}

// Verifies the options and answer of an open
// ended Question ("2")
func verifyOpenEndedQuestion(options []string, answer string) {
	// must have
	if len(options) != 0 {
		text := ufmt.Sprintf("%s", options[0])
		panic(text)
	}
	if len(answer) != 0 {
		panic(ErrOpenQuestionAnswer)
	}
}

// Set functions

// Set the question again. Doesn't require any filtering since
// it's made by the website, and the hash has a size of more than
// 64 chars
func (s *Question) SetQuestion(question string) {
	s.question = question
}

// Updates set of options if allowed. Otherwise panics.
// In case you want to update the options from a question
// that isn't allowed to edit the options, will panic too
func (s *Question) SetOptions(options []string) {
	if s.GetKind() != "0" {
		panic(ErrQuestionTypeForbiddenAction)
	}
	if len(options) >= 4 {
		s.options = options
	} else {
		panic(ErrAnswerNotInOption)
	}
}

// Get functions

// Get options of question
func (s *Question) GetOptions() []string {
	return s.options
}

// Get answer of question
func (s *Question) GetAnswer() string {
	return s.answer
}

// Get statement of question
func (s *Question) GetQuestions() string {
	return s.question
}

// Get kind of question
func (s *Question) GetKind() string {
	return s.kind
}

// Get kind of question
func (s *Question) GetHashAES() string {
	return s.hashAES
}
