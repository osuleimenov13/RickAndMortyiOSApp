//
//  RMSearchInputView.swift
//  RickAndMorty
//
//  Created by Olzhas Suleimenov on 19.04.2023.
//

import UIKit

protocol RMSearchInputViewDelegate: AnyObject {
    func rmSearchInputView(_ searchInputView: RMSearchInputView, didSelectOption option: RMSearchInputViewViewModel.DynamicOption)
}

final class RMSearchInputView: UIView {
    
    public weak var delegate: RMSearchInputViewDelegate?
    
    private var viewModel: RMSearchInputViewViewModel? {
        didSet {
            guard let viewModel = viewModel, viewModel.hasDynamicOptions else {
                return
            }
            
            let options = viewModel.options
            createOptionSelectionViews(options: options)
        }
    }

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews(searchBar)
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: topAnchor),
            searchBar.leftAnchor.constraint(equalTo: leftAnchor),
            searchBar.rightAnchor.constraint(equalTo: rightAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    private func createOptionSelectionViews(options: [RMSearchInputViewViewModel.DynamicOption]) {
        let stackView = createOptionStackView()
        
        for i in 0..<options.count {
            let option = options[i]
            let button = createButton(with: option, tag: i)
            stackView.addArrangedSubview(button)
        }
    }
    
    private func createButton(with option: RMSearchInputViewViewModel.DynamicOption, tag: Int) -> UIButton {
        let button = UIButton()
        button.backgroundColor = .secondarySystemBackground
        
        button.setAttributedTitle(
            NSAttributedString(string: option.rawValue,
                               attributes: [
                                .font : UIFont.systemFont(ofSize: 18, weight: .medium),
                                .foregroundColor: UIColor.label
                               ]),
            for: .normal)
        
        button.layer.cornerRadius = 6
        button.tag = tag
        button.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        
        return button
    }
    
    private func createOptionStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 6
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            stackView.leftAnchor.constraint (equalTo: leftAnchor),
            stackView.rightAnchor.constraint (equalTo: rightAnchor),
            stackView.bottomAnchor.constraint (equalTo: bottomAnchor),
        ])
        
        return stackView
    }
    
    @objc private func didTapButton (_ sender: UIButton) {
        guard let options = viewModel?.options else {
            return
        }
        let tag = sender.tag
        let selected = options[tag]
        delegate?.rmSearchInputView(self, didSelectOption: selected)
    }
    
    // MARK: - Public
    
    public func configure(with viewModel: RMSearchInputViewViewModel) {
        // TODO: Fix height of input view for episode with no options
        searchBar.placeholder = viewModel.searchPlaceholderText
        self.viewModel = viewModel
    }
    
    public func presentKeyboard() {
        searchBar.becomeFirstResponder()
    }
    
    
}
