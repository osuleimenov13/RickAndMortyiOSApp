//
//  RMLocationView.swift
//  RickAndMorty
//
//  Created by Olzhas Suleimenov on 17.04.2023.
//

import UIKit

protocol RMLocationViewDelegate: AnyObject {
    func rmLocationView(_ locationView: RMLocationView, didSelect location: RMLocation)
}

final class RMLocationView: UIView {
    
    public weak var delegate: RMLocationViewDelegate?
    
    private var viewModel: RMLocationViewViewModel? { // to hold view model in global scope of our view so we can access it
        didSet {
            spinner.stopAnimating() // also hides spinner
            tableView.isHidden = false
            tableView.reloadData()
            UIView.animate(withDuration: 0.3) {
                self.tableView.alpha = 1
            }
            
            // puttin here instead to init() to be sure viewModel gets created cause its nullable
            viewModel?.registerDidFinishPaginationBlock { [weak self] in
                DispatchQueue.main.async { // @escaping closure callback on background queue
                    // Loading indicator go bye bye
                    self?.tableView.tableFooterView = nil
                    self?.tableView.reloadData() // able to call this while maintaining the offset but going to promp table view to reload all data. Table view is efficient to comute only visible cells and reload those but you can also do batch updates tableView.insertRows (at: [IndexPath], with: UITableView.RowAnimation). reloadData() is more simplier though (done batch updating in collection views)
                }
            }
        }
    }
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.alpha = 0
        table.isHidden = true
        table.register(RMLocationTableViewCell.self,
                       forCellReuseIdentifier: RMLocationTableViewCell.identifier)
        return table
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews(tableView, spinner)
        spinner.startAnimating()
        addConstraints()
        configureTable()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            spinner.heightAnchor.constraint(equalToConstant: 100),
            spinner.widthAnchor.constraint(equalToConstant: 100),
            spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leftAnchor.constraint(equalTo: leftAnchor),
            tableView.rightAnchor.constraint(equalTo: rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    private func configureTable() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    public func configure(with viewModel: RMLocationViewViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - UITableViewDelegate

extension RMLocationView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let location = viewModel?.location(at: indexPath.row) else {
            return
        }
        delegate?.rmLocationView(self, didSelect: location)
    }
    
}

// MARK: - UITableViewDataSource

extension RMLocationView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.cellViewModels.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellViewModels = viewModel?.cellViewModels else {
            fatalError ()
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RMLocationTableViewCell.identifier, for: indexPath) as? RMLocationTableViewCell else {
            fatalError()
        }
        cell.configure(with: cellViewModels[indexPath.row])
        return cell
    }
}

// MARK: - UIScrolIViewDelegate

extension RMLocationView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let viewModel = viewModel, !viewModel.cellViewModels.isEmpty, viewModel.shouldShowLoadMoreIndicator, !viewModel.isLoadingMoreLocations else {
                return
            }
         
        // using timer to debounce the process of going down infinetly, not to accidentally kick off multiple pagination requests
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] t in
            let offset = scrollView.contentOffset.y
            let totalContentHeight = scrollView.contentSize.height
            let totalScroliViewFixedHeight = scrollView.frame.size.height
            
            if offset >= totalContentHeight - totalScroliViewFixedHeight - 120 {
                self?.showLoadingIndicator()
                self?.viewModel?.fetchAdditionalLocations()
            }
            
            t.invalidate()
        }
    }
    
    private func showLoadingIndicator() {
        let footer = RMTableLoadingFooterView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 100))
        tableView.tableFooterView = footer
        tableView.setContentOffset(CGPoint(x: 0, y: tableView.contentSize.height), animated: true) // to scroll all the way to the bottom when footer(spinner) appears
    }
}
