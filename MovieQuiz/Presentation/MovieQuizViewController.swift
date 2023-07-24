import UIKit

final class MovieQuizViewController: UIViewController {
    @IBOutlet weak private var questionLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    //количество всех правильных ответов
    private var  allcorrectAnswers = 0
    
    ///класс, которы показывает alert-ы, взяв данные из alertModel
    private let alertPresenter = AlertPresenter()
        
    private var presenter: MovieQuizPresenter!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
      //  alertPresenter.delegate = self
        presenter = MovieQuizPresenter(viewController: self)
        showLoadingIndicator()
        let moviesLoading = MoviesLoader()
            imageView.layer.cornerRadius = 20
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked()
    }
   
    ///приватный метод вывода на экран вопроса,
    ///который принимает на вход вью модель вопроса и ничего не возвращает
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    /// приватный метод для показа результатов раунда квиза
    /// принимает вью модель QuizResultsViewModel и ничего не возвращает
    func show(quiz result: QuizResultsViewModel) {
        
        let message = presenter.makeResultsMassage()
        
        let alert = UIAlertController(
            title: result.title,
            message: message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            self.presenter.restartGame()
        }
        
        alert.addAction(action)
        
        self.present(alert,animated: true)
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func showNetworkError(message: String) {
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else {return}
            
            self.presenter.restartGame()
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
// MARK: - AlertShowDelegate
//extension MovieQuizViewController: AlertShowDelegate {
//    func show(alert: UIAlertController) {
//        present(alert, animated: true)
//    }
//}
