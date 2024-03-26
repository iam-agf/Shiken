package shikenquestion

import (
	"testing"
)

// Tests the cases where the NewQuestion function
// works as expected
func TestQuestionCorrect(t *testing.T) {
	originalId := id
	defer func() {
		id = originalId
	}()
	tt := []struct {
		testcase        string
		kind            uint
		question        string
		options         []string
		expectedOptions []string
		categories      []string
		answer          string
		expectedAnswer  string
	}{
		{
			testcase:        "Multiple Option Question correct",
			kind:            uint(0),
			question:        "Testing",
			options:         []string{"one", "two", "three", "four"},
			expectedOptions: []string{"one", "two", "three", "four"},
			categories:      []string{"cat"},
			answer:          "three",
			expectedAnswer:  "three",
		},
		{
			testcase:        "True-False Question correct",
			kind:            uint(1),
			question:        "Testing",
			options:         []string{"one", "two", "three", "four"},
			expectedOptions: []string{"True", "False", "None", "No answer"},
			categories:      []string{"categories"},
			answer:          "True",
			expectedAnswer:  "True",
		},
		{
			testcase:        "Open ended Question correct",
			kind:            uint(2),
			question:        "Testing",
			options:         []string{},
			expectedOptions: []string{},
			categories:      []string{"categories"},
			answer:          "",
			expectedAnswer:  "",
		},
	}
	for _, unit := range tt {
		t.Run(unit.testcase, func(t *testing.T) {
			id = 0
			result := NewQuestion(unit.kind, unit.question, unit.options, unit.answer, unit.categories)
			if result != nil {
				if result.author != "author" {
					t.Errorf("Error with author entry")
				}
				if result.id != uint(1) {
					t.Errorf("Error with id entry")
				}
				if result.kind != unit.kind {
					t.Errorf("Error with kind entry")
				}
				if result.answer != unit.expectedAnswer {
					t.Errorf("Error with answer entry")
				}
				if result.question != unit.question {
					t.Errorf("Error with question entry")
				}
				// Categories
				if len(result.categories) != len(unit.categories) {
					t.Errorf("Error with categories size entry")
				}
				for idx, v := range unit.categories {
					expV := result.categories[idx]
					if v != expV {
						t.Errorf("Error with categories entry")
					}
				}
				// Options
				if len(result.options) != len(unit.options) {
					t.Errorf("Error with options size entry")
				}
				for idx, v := range unit.expectedOptions {
					expV := result.options[idx]
					if v != expV {
						t.Errorf("Error with options entries %s, %s", v, expV)
					}
				}
			}
		})
	}

}

// Tests the cases where the NewQuestion function
// panics as expected
func TestQuestionPanics(t *testing.T) {
	originalId := id
	defer func() {
		id = originalId
	}()
	tt := []struct {
		testcase   string
		kind       uint
		question   string
		options    []string
		categories []string
		answer     string
	}{
		{
			testcase: "Question size is less than 5",
			kind:     uint(0),
			question: "1234",
			options:  []string{"one", "two", "three"},
			answer:   "three",
		},
		{
			testcase: "Multiple Options Question has less than 4 options",
			kind:     uint(0),
			question: "12345",
			options:  []string{"one", "two", "three"},
			answer:   "three",
		},
		{
			testcase: "Multiple Option Question with empty option",
			kind:     uint(0),
			question: "12345",
			options:  []string{"one", "two", "three", ""},
			answer:   "three",
		},
		{
			testcase: "Multiple Option Question with empty option",
			kind:     uint(0),
			question: "12345",
			options:  []string{"one", "two", "three", "four", "four"},
			answer:   "one",
		},
		{
			testcase: "Multiple Option Question with empty option",
			kind:     uint(0),
			question: "12345",
			options:  []string{"one", "two", "three", "four"},
			answer:   "five",
		},
		{
			testcase: "True-False Option Question without answer",
			kind:     uint(1),
			question: "12345",
			options:  []string{"one", "two", "three", "four"},
			answer:   "five",
		},
		{
			testcase: "Open Ended Question not empty options",
			kind:     uint(2),
			question: "12345",
			options:  []string{"one", "two", "three", "four"},
			answer:   "",
		},
		{
			testcase: "Open Ended Question not empty answer",
			kind:     uint(2),
			question: "12345",
			options:  []string{},
			answer:   "lol",
		},
		{
			testcase: "kind of Question out of range",
			kind:     uint(4),
			question: "12345",
			options:  []string{"one", "two", "three", "four"},
			answer:   "four",
		},
	}
	for _, unit := range tt {
		t.Run(unit.testcase, func(t *testing.T) {
			assertPanicNewQuestion(t, NewQuestion, unit.kind, unit.question, unit.options, unit.answer, unit.categories, unit.testcase)
		})
	}
}

var DummyQuestionKind0 = Question{
	answer:     "four",
	author:     "author",
	categories: []string{"one", "cat", "per", "word"},
	id:         uint(0),
	kind:       0,
	options:    []string{"one", "two", "three", "four"},
	question:   "Kind 0 question",
}
var DummyQuestionKind1 = Question{
	answer:     "True",
	author:     "author",
	categories: []string{"two"},
	id:         uint(1),
	kind:       1,
	options:    []string{"one", "two", "three", "four"},
	question:   "Kind 1 question",
}
var DummyQuestionKind2 = Question{
	answer:     "",
	author:     "author",
	categories: []string{"two"},
	id:         uint(2),
	kind:       2,
	options:    []string{},
	question:   "Kind 2 question",
}

func TestGetKind(t *testing.T) {
	if DummyQuestionKind0.GetKind() != uint(0) {
		t.Errorf("Error in DummyQuestionKind0")
	}
	if DummyQuestionKind1.GetKind() != uint(1) {
		t.Errorf("Error in DummyQuestionKind1")
	}
	if DummyQuestionKind2.GetKind() != uint(2) {
		t.Errorf("Error in DummyQuestionKind2")
	}
}

func TestGetQuestion(t *testing.T) {
	if DummyQuestionKind0.GetQuestion() != "Kind 0 question" {
		t.Errorf("Error in TestGetQuestion")
	}
}
func TestGetAnswer(t *testing.T) {
	if DummyQuestionKind0.GetAnswer() != "four" {
		t.Errorf("GetAnswer wrong for Kind 0 Question")
	}
	if DummyQuestionKind1.GetAnswer() != "True" {
		t.Errorf("GetAnswer wrong for Kind 1 Question")
	}
	if DummyQuestionKind2.GetAnswer() != "" {
		t.Errorf("GetAnswer wrong for Kind 2 Question")
	}
}
func TestIsCorrect(t *testing.T) {
	if true != DummyQuestionKind0.IsCorrect("four") {
		t.Errorf("Kind0 error IsCorrect")
	}
	if false != DummyQuestionKind0.IsCorrect("five") {
		t.Errorf("Kind0 error IsCorrect")
	}
	if true != DummyQuestionKind1.IsCorrect("True") {
		t.Errorf("Kind1 error IsCorrect")
	}
	if false != DummyQuestionKind1.IsCorrect("False") {
		t.Errorf("Kind1 error IsCorrect")
	}
	if true != DummyQuestionKind2.IsCorrect("") {
		t.Errorf("Kind2 error IsCorrect")
	}
	if false != DummyQuestionKind2.IsCorrect("???") {
		t.Errorf("Kind2 error IsCorrect")
	}
}
func TestSetQuestion(t *testing.T) {
	originalQuestion := DummyQuestionKind1
	defer func() {
		DummyQuestionKind1 = originalQuestion
	}()
	updatedQuestion := "Updated question"
	DummyQuestionKind1.SetQuestion(updatedQuestion)
	if updatedQuestion != DummyQuestionKind1.GetQuestion() {
		t.Errorf("Error updating question")
	}
	defer func() {
		if r := recover(); r == nil {
			t.Errorf("The code did not panic")
		}
	}()
	DummyQuestionKind2.SetQuestion("sq")
}
func TestGetOptions(t *testing.T) {
	expectedOptions := []string{"one", "two", "three", "four"}
	options := DummyQuestionKind0.GetOptions()
	if len(options) != len(expectedOptions) {
		t.Errorf("Size of Category with expected Categories not equal")
	}
	for idx, v := range options {
		if expectedOptions[idx] != v {
			t.Errorf("Entries %s, %s are different ", expectedOptions[idx], v)
		}
	}
}
func TestSetOptions(t *testing.T) {
	expectedOptions := []string{"one", "two", "three", "four", "new"}
	originalQuestion := DummyQuestionKind0
	defer func() {
		DummyQuestionKind0 = originalQuestion
	}()
	DummyQuestionKind0.SetOptions(expectedOptions)
	options := DummyQuestionKind0.GetOptions()
	if len(options) != len(expectedOptions) {
		t.Errorf("Size of Options with expected Categories not equal")
	}
	for idx, v := range options {
		if expectedOptions[idx] != v {
			t.Errorf("Entries %s, %s are different ", expectedOptions[idx], v)
		}
	}
}
func TestGetCategories(t *testing.T) {
	expectedCategories := []string{"one", "cat", "per", "word"}
	categories := DummyQuestionKind0.GetCategories()
	if len(categories) != len(expectedCategories) {
		t.Errorf("Size of Category with expected Categories not equal")
	}
	for idx, v := range categories {
		if expectedCategories[idx] != v {
			t.Errorf("Entries %s, %s are different ", expectedCategories[idx], v)
		}
	}
}
func TestSetCategories(t *testing.T) {
	expectedCategories := []string{"one", "cat", "per", "word", "new"}
	originalQuestion := DummyQuestionKind0
	defer func() {
		DummyQuestionKind0 = originalQuestion
	}()
	DummyQuestionKind0.SetCategories(expectedCategories)
	categories := DummyQuestionKind0.GetCategories()
	if len(categories) != len(expectedCategories) {
		t.Errorf("Size of Category with expected Categories not equal")
	}
	for idx, v := range categories {
		if expectedCategories[idx] != v {
			t.Errorf("Entries %s, %s are different ", expectedCategories[idx], v)
		}
	}
}

func TestRemoveOption(t *testing.T) {
	originalQuestionKind0 := DummyQuestionKind0
	defer func() {
		DummyQuestionKind0 = originalQuestionKind0
	}()
	options := []string{"one", "two", "three", "four", "five"}
	expectedOptions := []string{"one", "three", "four", "five"}
	DummyQuestionKind0.SetOptions(options)
	DummyQuestionKind0.RemoveOption("two")
	updatedOptions := DummyQuestionKind0.GetOptions()
	if len(expectedOptions) != len(updatedOptions) {
		t.Errorf("RemoveOptions size of array isn't expected")
	}
	for idx, expOpt := range expectedOptions {
		opt := options[idx]
		if opt != expOpt {
			t.Errorf("RemoveOptions entries error on '%s' and '%s'", opt, expOpt)
		}
	}
}

func TestPanicRemoveOption(t *testing.T) {
	originalQuestionKind0 := DummyQuestionKind0
	originalQuestionKind2 := DummyQuestionKind2
	defer func() {
		DummyQuestionKind0 = originalQuestionKind0
		DummyQuestionKind2 = originalQuestionKind2
	}()
	assertPanicRemoveOption(t, &DummyQuestionKind2, "Options size can't reduce to less than 4", "one")

	tt := []struct {
		testcase string
		options  []string
		option   string
	}{
		{
			testcase: "Option out of list",
			options:  []string{"one", "two", "three"},
			option:   "zero",
		},
		{
			testcase: "Option out of list",
			options:  []string{"one", "two", "three", "four"},
			option:   "zero",
		},
	}
	for _, unit := range tt {
		t.Run(unit.testcase, func(t *testing.T) {
			DummyQuestionKind0.SetOptions(unit.options)
			assertPanicRemoveOption(t, &DummyQuestionKind0, unit.testcase, unit.option)
		})
	}
}

// Supporting function to verify NewQuestion
// panics
func assertPanicNewQuestion(t *testing.T, f func(kind uint, question string, options []string, answer string, categories []string) *Question, kind uint, question string, options []string, answer string, categories []string, testcase string) {
	defer func() {
		if r := recover(); r == nil {
			t.Errorf("The case %s did not panic", testcase)
		}
	}()
	f(kind, question, options, answer, categories)
}

// Supporting function to verify something
// panics
func assertPanicRemoveOption(t *testing.T, q *Question, testcase string, option string) {
	defer func() {
		if r := recover(); r == nil {
			t.Errorf("The case %s did not panic", testcase)
		}
	}()
	q.RemoveOption(option)
}
