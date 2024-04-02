# Project Shiken
(from "試験" [しけん, shiken], exam in Japanese)
Proof Of Expertise

## Grant type

Tinker

## Team members

| name                       | nickname | role |
|----------------------------|:-:|:-:|
| Antonio Gonzalez Fernandez | Jorin | Developer and Project manager |
| Victor P. H.               | BHIKTOR | Developer |

## Members links

| member    | github | email |
|-----------|:-:|:-:|
| Antonio   | [@iam-agf](https://github.com/iam-agf)   | agf0710@gmail.com   |


## Brief

After doing research about the different needs in GnoLand, Antonio had an idea to try to solve the [issue with hiring processes](https://github.com/gnolang/hackerspace/issues/13).
The solution is to create a tool to deploy exams in a realm that could produce a proof of expertise for someone on-chain.

The project contains a Web2 component that serves two purposes:
Given the public nature of blockchain technology we need to store the seed that decrypts the answers outside the realm.
And the other role of this component is to pre parse the answers that can be automatically qualified.
The component is a cloud hosted micro-service layered API that communicates with the realm via the front-end app.

## Description

An exam is composed of questions, this questions can be of the next following types:

- **True-False** - With only True or False answers
- **Multiple** - Select from a variety of pre defined answers
- **Open ended** - Let the person write their answer

The exam creator will be able to create, query and edit `questions`. These questions would be stored in a `repository` where the owner will be able to add, edit or delete questions, register/remove editors for a created exam, addresses that will be able do the same actions on questions except deleting the whole exam, or transfer ownership of.

Finally the editors (it's implicit the owner is included in this group) of the `repository` will be able to create `exams`. They would be able to edit the availability time/block heights to visualize the exam for the registered address(es), and other tools. Finally a last part would be a component in the realms to  for applicants.

## Goals

The idea is to create three packages: `Questions`, `Exams`, `Repositories`, and a website with several components to manipulate a realm that will hold a repository where the user will be able to:
* Query the questions & exams stored in this repository.
* Solve exams.
* Have a smoother control of all the functions related to the repository.

## Structure

Below I provide an attempt of the project model.

*The exposed functions and structures given here may not be the final ones. They could be edited during the production of the final version*


####`Questions`
This is the revised draft for the Question package.

```go
package Question

type Question struct {
	kind    uint     // type of questions as in multiple choice, true/false or free
	value   uint     // point value of the question
	cat     string   // category in the exam this question belongs
	content string   // the question text
	answer  string   // the correct answer
	options []string // the options for answers if needed
	tags    avl.Tree // tags to filter this question, for filtering mostly
}

func NewQuestion(kind uint, content string, answer string) *Question {
	return &Question{
		kind,
		1,
		"general",
		content,
		answer,
		[]string{},
		avl.NewTree(),
	}
}

// setters
func SetTag
func SetPoints
func SetAnswer
func AddOption
func RemoveOption
func IsCorrect
func SetCategory
func SetContent

// getters
func Options
func Answer // This will return an offchain encrypted answer the author would require to decrypt offchain too. That's the reason of the web2 component
func Category
func Content
func Points
func Tag

```

#### `Exams`

```go
type Exam struct {
	creator             std.Address         // owner
	title               string              // exam name
	description         string              // exam description or introduction
	categories          []string            // all the categories this exam has
	questions           []Question.Question // the questions that are in this exam
	category            string              // category for this exam
	ponderation         avl.Tree            // some questions could have more value than others.
	applicants          avl.Tree            // users who are participating in this exam
	tags                avl.Tree            // classification tags
	times               avl.Tree
	responsesApplicants avl.Tree
	record              []string
}

func GetTitle
func UpdateTitle

func GetDescription
func UpdateDescription

func NewQuestion
func GetQuestions
func RemoveQuestion
// In this case editQuestion is done at repository level, not exam

func NewApplicant
func RemoveApplicant
func GetApplicants
// EditApplicant is equivalent to delete an address and add a new one, so can be done in a safer way with removal and add.


func SendResponse // Will overwrite the previous answer of an applicant.
func GetResponses
func GetResponse

func AddTimes
func UpdateTimes

func getRecord // Will return all the edits from editors and owner since creation of exam
```

#### `Repositories`
(currently 1 struct, 17 functions)

```go
type Repository struct {
    owner std.Address
    questions []Question
    tags avl.Tree
    editors avl.Tree
    exams avl.Tree
    record []string
    CreatedAt time.Time
	UpdatedAt time.Time
}
```

```go
func NewRepository

func TransferOwnership

func NewQuestion // Add a question to this repository
func GetQuestion // Question by id
func GetQuestions // List of questions
func RemoveQuestion
func EditQuestion

func NewTag // Tags can exist without a question with it
func GetTags
func DeleteTag

func GetEditors
func RemoveEditor

func NewExam
func GetExam
func GetExamsByTag
func RemoveExam
func EditExamTitle

func GetRecord // Will return all the edits from editors and owner since creation of exam


```

It's necessary to state clear that the main reason of using a website instead of using a rendering of the realms is because would **allow to encrypt the answers of the questions via an owner password** through a external function in the website.

The process to encrypting would be the following:

1. Examinator enters the website tab to make a new exam.
2. This will generate a key pair `(pub, priv)`.
3. If the examinator sends an exam on chain, he will receive the key `priv` generated so will have to store/save it.
4. The `pub` key will be sent on the tx as part of the message.

In the case of the applicants they don't require to do anything more than answering the exam since the login would be

1. They enter the exam because they have an allowed address
2. When they call the exam:
2.1. The browser will receive the key `pub` stored along with the exam.
2.2. The browser will generate a symmetric key `sym`.
3. When they send their answer, it will be encrypted with the `sym` key and
4. The `pub` key generated will encrypt the symmetric key `sym`.
5. Both encrypted messages, `symmetricEncrypted(answer)` and `asymmetricEncrypted(sym)` will be sent as part of their tx.

Because of this, when the evaluator calls for the answer, the browser will first decrypt the symmetric key `sym`, and then will use it decrypt the answer. This way there is no way the applicants can copy each other. Another thing to mention is that the exam won't be seen identical by the applicants since the questions will be disordered so the answers and the encrypting will be almost impossible to be identical. For more information about the encrypting process [please check this dummy model created to briefly explain how it would work](https://github.com/iam-agf/encryptModel) and don't hesitate asking me any detail on the vision and work flow I have about this project.

## Contributions, issues and pull requests made to Gno and Game of Realms

None related to GNO. Only [one in ignite/cli](https://github.com/ignite/cli/pull/3564).

## Why are you best suited/what is your background?

As a developer I have 4 years of experience, I have been involved in crypto since last year, have knowledge in many languages like python, dart, javascript, go; I have participated in web3-based events like the [hackatom of 2022](https://github.com/EmpowerPlastic/Hackatom_2022) aand now I believe I can deliver valuable content to GNO starting with this idea.

## Milestones and overall time frame of your proposal

Splitting the parts of the project into smaller ones, These are my estimations for each part:

|Id | Activity | Expected | Worse scenario |
|:-:|----------|:-:|:-:|
| | **First repository** |
| 1 | Package `Questions` | 2 | 3 |
| 2 | Package `Repositories` | 2 | 3 |
| 3 | Package `Exams` | 3 | 5 |
| 4 | Realm for interacting repositories, questions and exams | 2 | 4 |
| 5 | Realm to render repositories data like questions and exams | 2 | 3 |
|  | **First Total** | **11** | **18** |
| | **Second repository** |
| 6 | Website view for repository visualising (questions & exams) | 2 | 3 |
| 8 | Website exam creation | 3 | 5 |
| 8 | Website exam application (only exams) | 3 | 4 |
| 9 | Documentation for all the previously mentioned components | 1 | 2 |
|  | **Second Total** | **9** | **14** |
|  | **Final Total** | **20** | **32** |

Meaning an approximate of 5 months, and in a (very) worst scenario 8 months.

The milestones can be understood as the deliver of each of the listed parts above. As a DAG, the graph for doing each section can be understood as this:

```
┌───────────────┐
│P Questions (1)│
└┬──────────────┘
┌▽───────────────┐
│P Repository (2)│
└┬───────────────┘
┌▽───────────────────────────────────────────────────────────────────────┐
│P Exam (3)                                                              │
└┬──────────────────────────────────────────────────────────────────────┬┘
┌▽────────────────────────────────────────────────────────────────────┐┌▽──────────────────┐
│Realm to Interact (4)                                                ││Realm to render (5)│
└┬───────────────────────────────────┬───────────────────────────────┬┘└───────────────────┘
┌▽─────────────────────────────────┐┌▽─────────────────────────────┐┌▽──────────────────────────────┐
│View exam application (8)         ││View repository manipulate (7)││View repository visualising (6)│
└┬─────────────────────────────────┘└┬─────────────────────────────┘└───────────────────────────────┘
┌▽───────────────────────────────────▽┐
│Documentation (9)                    │
└─────────────────────────────────────┘

```

Notes:

- Weeks are understood as working weeks, i.e. only from Monday to Friday.
- The packages `Questions`, `Repositories` and `Exams` would be built separately and will be joint all to become only one. Firstly each part would be independent to work easier. If it's better to have a package per structure, it can be done that way.
- The realms renders would only  show the questions and exams since currently it's not possible to encrypt the answers of the questions via a password on chain since it would expose the password.
- For the answers encryption would require an external tool in the website to encrypt the answers to send them to the chain for avoiding chances of copying. The method is explained in the goals. This is one of the heaviest and most relevant parts, so that's why I insist on it.

## Your idea for fair funding of the proposal

Based on the [salaries of a Go developer](https://www.google.com/search?client=safari&rls=en&q=junior+golang+salary&ie=UTF-8&oe=UTF-8), since my knowledge in Go is Junior~Mid, I consider it's approximate the upper range of a junior dev in that table (80,000 per year). This divided by [the amount of working hours in a year](https://www.google.com/search?client=safari&rls=en&q=working+hours+in+a+year&ie=UTF-8&oe=UTF-8) (2080), would be an average of 80,000/2080 ~38 USD per hour. So considering the previous table, I think the amount for the grant would be

(hour rate) x (working hours in a week) x (weeks the project will take) =

38 x 40 x 20 = 30,400 USD


## What do you and the submission bring to the Gno.land platform and community?

#### Me
As a developer I want to continue reaching new levels of Go knowledge and I think GNO is a good place where I can grow these skills. Also this can help me give meaningful contributions for the benefit of the chain knowing what is missing or required to make the code better for others.

#### The submission

The main goal of this project is to <u>**evaluate applicants to measure their skills**</u>.

But given the transparency of blockchain this tool can also
* <u>**Provide applicants with lists of questions to applicants to prepare and study before applying to exams**</u> if the evaluators make their questions visible when adding questions to their repository and
* <u>**Results will be transparent for both sides**</u>, making the exams honest, since the answers by candidates will be onchain for everyone and the private keys will require to be published onchain too after every exam.

As a collateral result, this project will
* Provide <u>**a simple infrastructure for sending private messages between addresses**</u>

which can be useful for others after refining this part project.

## Share any referrals or other projects you work with

[This is the only team with whom I have worked in
web3](https://github.com/empowerchain)

If it's required I can share my linkedin to the interested part.
