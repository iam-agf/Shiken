# Instructions

In order to work with this realm there will be a website (still under development) so the users can use a web2 framework to (en/de)crypt their information in the realm.

# Questions
The `shikenquestion` package is the minimal of the three engines of this realm. It will store the structure `Question`. 

In order to create a `Question` you need to provide 
- A `question` with more than 5 characters.
- The type (`kind`) of question:
    - Multiple options (0)
    - True-False (1)
    - Open ended (2)
    - If you provide a value different than 0,1 or 2, the realm will panic.
- The `options` 
    - If it's of `kind` 0, you will need to provide at least 4 options
    - If it's of `kind` 1 the realm will provide the options
    - If it's of `kind` 2 will panic
- The `answer`
    - If it's of `kind` 0 or 1 answer must be one of the 4 options, otherwise will panic.
    - If it's of `kind` 2 the realm will panic if you provide an answer different than ""

Once a `Question` is created, it will be given an id that will allow to identify that question.
All the properties of the question will be readable (but encrypted). Nonetheless, since all the content will be encrypted, **only the creator will be able to read the decrypted content after providing the password in the web2 interface**. 

Since there could be the chance someone wants to use this realm as a studying storage, the `Question` package gives you the option to make questions visible to everyone with the function `SetPublic`.

Most of the content will be easily readable (encrypted) via the website, but via CLI or other ways to reach the realm will be sort of complicate to fulfill the standards the questions must follow.

## Exams
The `shikenexam` package is the second level of the three engines of this realm. It will store the structure `Exam`. 

To create an `Exam`, you need to provide:
- A `title`.
- A `description`. 
- The list of ids of the `Question`s you'll add in your exam. This list can be empty and filled later.
- The list of addresses (as `String` types) that will be the applicants of your exam. This, as the list of questions, can be added later.

These parameters were going to be reviewed on length in the draft idea, but this is impossible onchain since all the content will be encrypted.

Like in the generation of a `Question`, an `Exam` will be associated to an id that will allow to identify the exam. Besides these parameters mentioned, an `Exam` will have three more relevant entries to be filled later to make this `Exam` functional:
- `startTime`: the time when the exam will be visible for applicants and the time when they can send their answers
- `endTime`: the time when the exam is closed and nothing can be edited anymore from it
- `answersApplicants`: A storage structure to save all the answers from the applicants.
Clearly the first two entries will be edited by the creator, but the third one will be only updated by the candidates during the window of time between `startTime` and `endTime`. Once the time surpass that time window, the applicants can't send any other answer (with `SendAnswers`) and the creator can't edit any entry of the exam. This way in case the exam requires a review with the rest of the candidates, this can be done via sharing the password for that exam to the applicants.

All the properties of the `Exam` can be edited **before an exam starts** or if the `startTime` and `endTime` haven't been defined.

## Repositories

Repositories will store Exams and Questions previously mentioned in this readme.
