import UIKit
final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var correctAnswers = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticService?
    private var alertPresenter: AlertPresenter?
    private var presenter = MovieQuizPresenter()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServiceImplementation()
        alertPresenter = AlertPresenter(controller: self)
        presenter.viewController = self
        
        imageView.layer.backgroundColor = UIColor.clear.cgColor
        activityIndicator.hidesWhenStopped = true
        questionFactory?.loadData()
        showLoadingIndicator()
        self.switchOfButtons()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        self.switchOfButtons()
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        self.switchOfButtons()
        presenter.currentQuestion = currentQuestion
        presenter.noButtonClicked()
    }
    
    // MARK: - Private functions
    
    private func show(quiz step: QuizStepViewModel) {
        hideLoadingIndicator()
        imageView.layer.borderWidth = 0
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        switchOfButtons()
    }
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            showFinalResult()
        } else {
            presenter.switchToNextQuestion()
            showLoadingIndicator()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showFinalResult() {
        statisticService?.store(correct: correctAnswers, total: presenter.questionsAmount)
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: makeResultMessage(),
            buttonText: "Сыграть еще раз",
            completion: { [weak self] in
                guard let self = self else { return }
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                self.showLoadingIndicator()
                self.questionFactory?.requestNextQuestion()
            }
        )
        alertPresenter?.show(result: alertModel)
    }
    
    private func switchOfButtons() {
        yesButton.isEnabled.toggle()
        noButton.isEnabled.toggle()
    }
    
    private func makeResultMessage() -> String {
        guard let statisticService = statisticService else {
            assertionFailure("error message")
            return ""
        }
        let message = """
        Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
        Количество сыгранных квизов: \(statisticService.gamesCount)
        Рекорд: \(statisticService.bestGame.correct)/10 (\(statisticService.bestGame.date.dateTimeString))
        Cредняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        """
        return message
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз",
            completion: { [weak self] in
                guard let self = self else { return }
                self.questionFactory?.loadData()
                self.showLoadingIndicator()
                self.presenter.resetQuestionIndex()
            }
        )
        alertPresenter?.show(result: alertModel)
    }
    
    private func showImageError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Загрузить другой вопрос",
            completion: { [weak self] in
                guard let self = self else { return }
                self.questionFactory?.requestNextQuestion()
                self.showLoadingIndicator()
            }
        )
        alertPresenter?.show(result: alertModel)
    }
    
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    
    // MARK: - Internal functions
    
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with errorMessage: String) {
        showNetworkError(message: errorMessage)
    }
    
    func didFailToLoadImage() {
        showImageError(message: "Failed to load image")
    }
    
}




