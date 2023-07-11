//
//  ImageListViewPresenter.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 11.07.2023.
//

import Foundation

protocol ImageListViewPresenterProtocol {
    var imageListVC: ImageListViewControllerProtocol? { get set }
    
    func fetchNextPage()
    func processLike()
    func convertDate()
}

final class ImageListViewPresenter {
    var imageListVC: ImageListViewControllerProtocol?
    
}
