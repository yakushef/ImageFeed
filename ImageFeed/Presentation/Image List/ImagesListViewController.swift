//
//  ViewController.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 28.04.2023.
//

import UIKit
import Kingfisher

protocol ImageListViewControllerProtocol: AnyObject {
    var presenter: ImageListViewPresenterProtocol? { get set }
    
    func addCells(newCellsCount: Int)
    func showAlert(with message: String)
    func updateRow(at indexPath: IndexPath)
    func goToFullScreenView(senderIndexPath: IndexPath)
}

final class ImagesListViewController: UIViewController & ImageListViewControllerProtocol {
    
    @IBOutlet private weak var tableView: UITableView!
    
    var presenter: ImageListViewPresenterProtocol?
    
    private let ShowSingleImageSegueIdentifier = "ShowSingleImage"
    private var alertPresenter: AlertPresenterProtocol!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowSingleImageSegueIdentifier {
            guard let viewController = segue.destination as? SingleImageViewController,
                  let indexPath = sender as? IndexPath,
                  let urlString = presenter?.getFullSizeUrl(forIndex: indexPath.row),
                  let imageURL = URL(string: urlString)
            else { return }
            viewController.imageURL = imageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertPresenter = AlertPresenter(delegate: self)
        
        self.navigationController?.isNavigationBarHidden = true
        
        tableView.register(UINib(nibName: "ImageListCell", bundle: nil), forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        presenter?.connectTable(tableView)

        tableView.contentInset = UIEdgeInsets(top: 12,
                                              left: 0,
                                              bottom: 12,
                                              right: 0)
        
        presenter?.fetchNextPageIfShould(fromIndex: nil)
    }
    
    //MARK: - Presenter config
    
    func configure(_ presenter: ImageListViewPresenterProtocol) {
        self.presenter = presenter
        presenter.imageListVC = self
    }
    
    //MARK: - Table View interaction
    
    func goToFullScreenView(senderIndexPath: IndexPath) {
        performSegue(withIdentifier: ShowSingleImageSegueIdentifier, sender: senderIndexPath)
    }
    
    func updateRow(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func addCells(newCellsCount: Int) {
        let currentRowNumber = tableView.numberOfRows(inSection: 0) - 1
        
        let newCellPaths = (currentRowNumber + 1...currentRowNumber + newCellsCount).map {
            IndexPath(row: $0, section: 0)
        }

        self.tableView.performBatchUpdates() {
        self.tableView.insertRows(at: newCellPaths, with: .automatic)
        }
    }

    // MARK: - Prepare Alert
    
    func showAlert(with message: String) {
        alertPresenter.presentAlert(title: "Что-то пошло не так(",
                                    message: message,
                                    buttonText: "OK",
                                    completion: { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true)
        })
    }
}

extension ImagesListViewController: AlertPresenterDelegate {
    
    func show(alert: UIAlertController) {
        present(alert, animated: true)
    }
}
