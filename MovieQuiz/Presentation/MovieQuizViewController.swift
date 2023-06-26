import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertShowDelegate {
    @IBOutlet weak private var questionLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    
    ///переменная с индексом текущего вопроса, начальное значение 0
    ///(по этому индексу будем искать вопрос в массиве, где индекс первого элемента = 0
    private var currentQuestionIndex = 0
    
    ///переменная со счетчиком правильных ответов, начальное значение закономерно =0
    private var correctAnswers = 0
    
    ///общее количество вопросов для квиза
    private let questionsAmount = 10
    
    ///фабрика вопросов, которую мы создали. Наш контроллер будет обращаться за вопросами именно к ней.
    private var questionFactory : QuestionFactoryProtocol?

    ///текущий вопрос, который видит пользователь.
    private var currentQuestion: QuizQuestion?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()
        imageView.layer.cornerRadius = 20
        
        
        var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "top250MoviesIMDB.json"
        documentsURL.appendPathComponent(fileName)
        print(documentsURL)
        if let jsonString = try? String(contentsOf: documentsURL) {
            let top = getTop(from: jsonString)
            dump(top)
        }
       
   }
    
    func getTop(from jsonString: String) -> Top? {
        guard let data = jsonString.data(using: .utf8) else { //переводим json в двоичный код
            return nil //если json пустой, возвращаем НИЛ так как функция должна что-то возвращать
        }
        do {
            let top = try JSONDecoder().decode(Top.self, from: data)
            return top
        } catch {
            print("Failed to parse: \(error.localizedDescription)")
            
            return nil
        }
    }
    
    
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewMdel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewMdel)
        }
        show(quiz: viewMdel)
    }
    
    // MARK: - AlertShowDelegate
    func show(alert: UIAlertController) {
        present(alert, animated: true)
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        //достаём текущий вопрос:
        guard let currentQuestion = currentQuestion else { return }
        //булевая переменная которая содержит ТРУ если ответ сошелся
        let isCorrectAnswer = currentQuestion.correctAnswer == false
        showAnswerResult(isCorrect: isCorrectAnswer)
        noButton.isUserInteractionEnabled = false
        yesButton.isUserInteractionEnabled = false
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        //достаём текущий вопрос
        guard let currentQuestion = currentQuestion else { return }
        let isCorrectAnswer = currentQuestion.correctAnswer == true
        showAnswerResult(isCorrect: isCorrectAnswer)
        yesButton.isUserInteractionEnabled = false
        noButton.isUserInteractionEnabled = false
    }
    
    /// метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image1 = UIImage(named: model.image) ??  UIImage()
        
        let questionNumber1 = "\(currentQuestionIndex + 1)/\(questionsAmount)"
        let viewModel = QuizStepViewModel(image: image1,
                                          question: model.text,
                                          questionNumber: questionNumber1)
        return viewModel
    }
    
    ///приватный метод вывода на экран вопроса,
    ///который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    /// метод красит рамку, в зависимости от ответа ДА/НЕТ
    /// isCorrect это параметр который указывает верный ответ или нет.  Если true, ответ ВЕРНЫЙ, если false - неверный
    ///
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        //красим рамку в зависимости от того, правильный ответ или нет
        imageView.layer.borderColor = isCorrect == true ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        if isCorrect == true {
            correctAnswers += 1
        }
        //запускаем задачу через 1 секунду с помощью диспетчера задач:
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {return}
            // который мы хотим вызвать через 1 секунду
            self.showNextQuestionOrResult()
            self.noButton.isUserInteractionEnabled = true
            self.yesButton.isUserInteractionEnabled = true
        }
    }
    
    ///приватный метод, который содержит логику перехода в один из сценариев
    ///метод ничего не принимает и ничего не возвращает
    private func showNextQuestionOrResult() {
        imageView.layer.borderColor = UIColor.clear.cgColor
        if currentQuestionIndex == questionsAmount - 1 {
            //идём в состояние результат Квиза
            let text = correctAnswers == questionsAmount ?
            "Поздравляем, Вы ответили на 10 из 10!" :
            "Вы ответили на \(correctAnswers) из 10, попробуйте еще раз!"
            let viewModel = QuizResultsViewModel(title: "Этот раунд окончен!",
                                                 text: text,
                                                 buttonText: "Сыграть еще раз")
            show(quiz: viewModel)
        } else {
            //Переходим к следующему вопросу
            currentQuestionIndex += 1
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    private func showAlert() {
        //создаём объекты всплывающего окна
        let alert = UIAlertController(title: "Этот раунд окончен!", message: "This is an alert", preferredStyle: .alert)
        //создаём для алерта кнопку с действием
        //в замыкании пишем, что должно происходить при нажатии на кнопку
        let action = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let self = self else {return}
            //выводим на экран все вопросы занаво, начиная с первого:
            self.currentQuestionIndex = 0
            //обнуляем счетчик с результатами квиза:
            self.correctAnswers = 0
            
            self.questionFactory?.requestNextQuestion()
        }
        alert.addAction (action)
        
        //показываем всплывающее окно
        self.present(alert, animated: true)
    }
    
    /// приватный метод для показа результатов раунда квиза
    /// принимает вью модель QuizResultsViewModel и ничего не возвращает
    private func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText) {
            self.correctAnswers = 0
            self.currentQuestionIndex = 0

            self.questionFactory?.requestNextQuestion()
        }
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
        alertPresenter.getAlert(alertModel: alertModel)
        
    }
    
}

/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */

