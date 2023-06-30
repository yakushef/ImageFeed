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
//            viewController.image = image
            viewController.imageURL = imageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageService.fetchPhotosNextPage()
        
        self.navigationController?.isNavigationBarHidden = true
        
        NotificationCenter.default.addObserver(
            forName: ImagesListService.DidChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self = self else {
                    return
                }
                self.photos = imageService.photos
                tableView.reloadData()
            }
        
        tableView.register(UINib(nibName: "ImageListCell", bundle: nil), forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 12,
                                              left: 0,
                                              bottom: 12,
                                              right: 0)
    }
    
    //MARK: Methods
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        var index = indexPath.row
//        print(index)
//        print(imageService.photos[index])
        
        if photos.count - indexPath.row == 3 {
            imageService.fetchPhotosNextPage()
        }
        
        cell.dateLabel.text = dateFormatter.string(from: Date())
        cell.selectionStyle = .none
        
        let isLiked = indexPath.row % 2 == 0
        let likeImage = UIImage(named: isLiked ? "likeButtonActive" : "likeButtonInactive")
        cell.likeButton.setImage(likeImage, for: .normal)
        
        guard let imageURL = URL(string: imageService.photos[index].thumbImageURL)
        else { return }
        
        cell.cellImage.kf.setImage(with: imageURL, placeholder: UIImage(named: "PhotoLoaderFull")) { [weak self] _ in
            guard let self = self else { return }
            tableView.beginUpdates()
            tableView.endUpdates()
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
