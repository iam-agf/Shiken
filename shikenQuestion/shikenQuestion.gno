package shikenquestion

import "std"

// The Question structure must be not editable except if hasn't been used.
// This is in order to protect the candidates that answer this question.
// This way the examinator can't edit the question after has been used in an exam.

type Question struct {
	answer		string   	 	// Answer. It must be contained in the options.
	author		std.Address  	// address which created the Question. Not editable.
	categories 	[]string 		// category in the exam this question belongs
	id       	int				// identifier of this question. Not editable
	kind		uint     		// type of questions as in multiple choice, true/false or open (0,1,2). Not editable.
	options		[]string 		// The encrypted answer(s), if question is multiple choice this will contain multiple options.
	question	string   		// The statement of the question.
	public		bool 			// The question is public or not.
	hash		string			// To make the question encrypted.
	canRead		bool			// Allows the exam container to read the full information.
}

// Panics for generic cases
const ErrQuestionTooShort = "question too short"
const ErrKindOutOfRange = "kind type must be 1,2 or 3"
const ErrShortOptionsList = "options length must be greater or equal to 4"

// Panics for options
const ErrEmptyOption = "option entry is empty"
const ErrRepeatedOption = "option entry repeated"
const ErrAnswerNotInOption = "answer not in options"

// Panics for Open ended Questions
const ErrOpenQuestionOptions = "open question don't require options"
const ErrOpenQuestionAnswer = "open question don't require answer"

// Creates a new question
func NewQuestion(question string, kind uint, id int, options []string, answer string, categories []string) *Question {
	// If the question is True-False the options are set to these options
	if len(question) < 5 {
		panic(ErrQuestionTooShort)
	}
	switch kind {
	case uint(0):
		verifyMultipleOptionQuestion(options, answer)
	case uint(1):
		options = []string{"True", "False", "None", "No answer"}
		verifyTrueFalseQuestion(options, answer)
	case uint(2):
		verifyOpenEndedQuestion(options, answer)
	default:
		panic(ErrKindOutOfRange)
	}

	return &Question{
		author:     std.GetOrigCaller(),
		id:         id,
		kind:       kind,
		answer:     answer,
		categories: categories,
		question:   question,
		options:    options,
	}
}

// Verifies if the options in a multiple option Question
// are valid and if the answer is contained in the array
// of options
func verifyMultipleOptionQuestion(options []string, answer string) {
	if len(options) < 4 {
		panic(ErrShortOptionsList)
	}
	seen := make(map[string]bool)
	containsAnswer := false
	for _, opt := range options {
		// the option isn't empty
		if len(opt) == 0 {
			panic(ErrEmptyOption)
		}
		// the option isn't repeated
		if seen[opt] {
			panic(ErrRepeatedOption)
		}
		// the answer is in the options
		if opt == answer {
			containsAnswer = true
		}
		seen[opt] = true
	}
	if !containsAnswer {
		panic(ErrAnswerNotInOption)
	}
}

// Verifies if the answer is True or False, so
// the array of options contain the answer
func verifyTrueFalseQuestion(options []string, answer string) {
	containsAnswer := false
	for _, v := range options {
		if v == answer {
			containsAnswer = true
		}
	}
	if !containsAnswer {
		panic(ErrAnswerNotInOption)
	}
}

// Verifies the options and answer of an open
// ended Question
func verifyOpenEndedQuestion(options []string, answer string) {
	// must have
	if len(options) != 0 {
		panic(ErrOpenQuestionOptions)
	}
	if len(answer) != 0 {
		panic(ErrOpenQuestionAnswer)
	}
}

func (s *Question) RemoveOption(option string) {
	if s.GetKind() == 0 {
		if len(s.GetOptions()) == 4 {
			panic("can't delete options")
		}
		indexToDelete := -1
		for i, v := range s.options {
			if v == option {
				indexToDelete = i
			}
		}
		if indexToDelete == -1 {
			panic("Option not listed in question options")
		}
		s.options = append(s.options[:indexToDelete], s.options[indexToDelete+1:]...)
	} else {
		panic("Only Multiple option Questions can remove options")
	}
}

func (s *Question) IsCorrect(answer string) bool {
	return answer == s.GetAnswer()
}

func (s *Question) SetQuestion(question string) {
	if len(question) < 5 {
		panic("the length of the question is very short")
	} else {
		s.question = question
	}
}

func (s *Question) SetCategories(categories []string) {
	s.categories = categories
}

func (s *Question) GetOptions() []string {
	return s.options
}

func (s *Question) SetOptions(options []string) {
	s.options = options
}

func (s *Question) GetAnswer() string {
	return s.answer
}

func (s *Question) GetCategories() []string {
	return s.categories
}

func (s *Question) GetQuestion() string {
	return s.question
}
func (s *Question) GetKind() uint {
	return s.kind
}
