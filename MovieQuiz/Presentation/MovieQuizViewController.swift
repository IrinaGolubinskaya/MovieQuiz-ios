import UIKit

final class MovieQuizViewController: UIViewController {
    @IBOutlet weak private var questionLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    
    ///переменная со счетчиком правильных ответов, начальное значение закономерно =0
    private var correctAnswers = 0
    
    //количество всех правильных ответов
    private var  allcorrectAnswers = 0
    
    ///фабрика вопросов, которую мы создали. Наш контроллер будет обращаться за вопросами именно к ней.
    private var questionFactory : QuestionFactoryProtocol?
    
    ///класс, которы показывает alert-ы, взяв данные из alertModel
    private let alertPresenter = AlertPresenter()
    
    private var currentQuestion: QuizQuestion?
    
    private var statisticService : StatisticService = StatisticServiceImplementation()
    
    private let presenter = MovieQuizPresenter()

    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter.delegate = self
        presenter.viewController = self
        showLoadingIndicator()
        let moviesLoading = MoviesLoader()
        questionFactory = QuestionFactory(moviesLoader: moviesLoading, delegate: self)
        questionFactory?.loadData()
        imageView.layer.cornerRadius = 20
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
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
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
    func showAnswerResult(isCorrect: Bool) {
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
        if presenter.isLastQuestion() {
            statisticService.store(newCorrect: correctAnswers, newTotal: presenter.questionsAmount)
            let strTotalAccuracy = String(format: "%.2f", statisticService.totalAccuracy)
            //идём в состояние результат Квиза
            let text = """
Ваш результат: \(correctAnswers)/10
Количество сыгранных квизов: \(statisticService.gamesCount)
Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
Средняя точность: \(strTotalAccuracy)%
"""
            let viewModel = QuizResultsViewModel(title: "Этот раунд окончен!",
                                                 text: text,
                                                 buttonText: "Сыграть еще раз")
            show(quiz: viewModel)
        } else {
            //Переходим к следующему вопросу
            presenter.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    /// приватный метод для показа результатов раунда квиза
    /// принимает вью модель QuizResultsViewModel и ничего не возвращает
    private func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText) { [weak self] in
            guard let self = self else { return }
            self.correctAnswers = 0
            self.presenter.resetQuestionIndex()
            self.questionFactory?.requestNextQuestion()
        }
        alertPresenter.getAlert(alertModel: alertModel)
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func showNetworkError(message: String) {
        let model = AlertModel(title: "Ошибка", message: message, buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else {return}
            
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        alertPresenter.getAlert(alertModel: model)
    }
    
    func sendFirstRequest() {
        // создаём адрес
        guard let url = URL(string: "https://imdb-api.com/en/API/Top250Movies/k_zcuw1ytf") else { return }
        // создаём запрос
        let request = URLRequest(url: url)
        // Создаём задачу на отправление запроса в сеть
        let task: URLSessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if let _ = error {
                self.showNetworkError(message: "")
            }
        }
        // Отправляем запрос
        task.resume()
    }
}

// MARK: - QuestionFactoryDelegate
extension MovieQuizViewController : QuestionFactoryDelegate {
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
}

// MARK: - AlertShowDelegate
extension MovieQuizViewController: AlertShowDelegate {
    func show(alert: UIAlertController) {
        present(alert, animated: true)
    }
}
