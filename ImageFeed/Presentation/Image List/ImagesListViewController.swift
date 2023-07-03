//
//  ViewController.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 28.04.2023.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    
    private let ShowSingleImageSegueIdentifier = "ShowSingleImage"
    private let imageService = ImagesListService.shared
    private var photos: [Photo] = []
    
    private var alertPresenter: AlertPresenterProtocol!
    
    private let photosName: [String] = Array(0...20).map { "\($0)" }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    
    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowSingleImageSegueIdentifier {
            guard let viewController = segue.destination as? SingleImageViewController,
                  let indexPath = sender as? IndexPath,
                  let urlString = photos[indexPath.row].largeImageURL,
                  let imageURL = URL(string: urlString)
            else { return }
            viewController.imageURL = imageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertPresenter = AlertPresenter(delegate: self)
        
        self.navigationController?.isNavigationBarHidden = true
        
        NotificationCenter.default.addObserver(
            forName: ImagesListService.ErrorNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self = self else { return }
                
                self.showAlert(with: "Ошибка загрузки изображений")
            }
        
        NotificationCenter.default.addObserver(
            forName: ImagesListService.DidChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self = self else { return }
                let newCellsCount = imageService.photos.count - self.photos.count
                
                let currentRowNumber = tableView.numberOfRows(inSection: 0) - 1
                
                let newCellPaths = (currentRowNumber + 1...currentRowNumber + newCellsCount).map {
                    IndexPath(row: $0, section: 0)
                }
                
                self.photos = imageService.photos
                
                self.tableView.performBatchUpdates() {
                    self.tableView.insertRows(at: newCellPaths, with: .automatic)
                }
            }
        
        tableView.register(UINib(nibName: "ImageListCell", bundle: nil), forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 12,
                                              left: 0,
                                              bottom: 12,
                                              right: 0)
        
        imageService.fetchPhotosNextPage()
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
    
    //MARK: Cell Congiguration
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let index = indexPath.row
        let photo = imageService.photos[index]
        
        cell.delegate = self
        
        if photos.count - indexPath.row == 3 {
            imageService.fetchPhotosNextPage()
        }
        
        if let date = photo.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: date)
        } else {
            cell.dateLabel.text = ""
        }
        cell.selectionStyle = .none
        
        let isLiked = photos[indexPath.row].isLiked
        cell.likeButton.isSelected = isLiked
        cell.likeButton.setImage(UIImage(named: "likeButtonActive"), for: .selected)
        cell.likeButton.setImage(UIImage(named: "likeButtonInactive"), for: .normal)
        
        guard let imageURL = URL(string: photo.thumbImageURL)
        else { return }
        
        cell.cellImage.kf.setImage(with: imageURL, placeholder: UIImage(named: "PhotoLoaderFull")) { [weak self] didLoad in
            guard let self = self else { return }
            switch didLoad {
            case .success(_):
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            case .failure(_):
                return
            }
        }
    }
}

// MARK: - UITableView

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: ShowSingleImageSegueIdentifier, sender: indexPath)
    }
    

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier,
                                                 for: indexPath)

        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }

        configCell(for: imageListCell, with: indexPath)

        return imageListCell
    }
}

// MARK: - Cell Delegate

extension ImagesListViewController: ImageListCellDelegate {
    func processLike(photoIndex: Int) {
        UIBlockingProgressHUD.show()
        let photo = photos[photoIndex]
        imageService.changeLike(photoId: photo.id,
                                isLike: !photo.isLiked) {[weak self] (result: Result<Void, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success():
                self.photos = imageService.photos
                guard let cell = self.tableView.cellForRow(at: IndexPath(row: photoIndex, section: 0)) as? ImagesListCell else { return }
                cell.likeButton.isSelected = self.photos[photoIndex].isLiked
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                showAlert(with: "Не получилось изменить лайк \(error.localizedDescription)")
            }
        }
    }
}

extension ImagesListViewController: AlertPresenterDelegate {
    
    func show(alert: UIAlertController) {
        present(alert, animated: true)
    }
    
}
