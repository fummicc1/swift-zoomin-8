import UIKit
import Combine

@MainActor
final class UserViewController: UIViewController {
    private let viewState: UserViewState
    private let iconImageView: UIImageView = .init()
    private let nameLabel: UILabel = .init()
    private var cancellables: Set<AnyCancellable> = []

    init(id: User.ID) {
        self.viewState = UserViewState(id: id)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // レイアウト
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.layer.cornerRadius = 40
        iconImageView.layer.borderWidth = 4
        iconImageView.layer.borderColor = UIColor.systemGray3.cgColor
        iconImageView.clipsToBounds = true
        view.addSubview(iconImageView)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 80),
            iconImageView.heightAnchor.constraint(equalToConstant: 80),
            iconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            nameLabel.centerXAnchor.constraint(equalTo: iconImageView.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 16),
        ])

        // View Binding
        let task = Task { [weak self] in
            guard let viewState = self?.viewState else {
                return
            }
            for await _ in viewState.objectWillChange.values {
                guard let self = self else {
                    return
                }
                self.nameLabel.text = viewState.user?.name
                self.iconImageView.image = viewState.iconImage
            }
        }
        cancellables.insert(
            AnyCancellable({ task.cancel() })
        )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task {
            await viewState.loadUser()
        }
    }
}
