//
//  ViewController.swift
//  Interview
//
//  Created by donghyeon on 2022/07/21.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var folderList = [Folder]() {
        didSet {
            self.saveFolderList()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionView()
        self.loadFolderList()
    }
    
    private func configureCollectionView() {
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        self.collectionView.contentInset = UIEdgeInsets(
            top: 12,
            left: 12,
            bottom: 12,
            right: 12
        )
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let writeFolderViewController = segue.destination as? WriteFolderViewController {
            writeFolderViewController.delegate = self
        }
    }
    
    private func saveFolderList() {
        let data = self.folderList.map {
            [
                "folderTitle": $0.folderTitle,
                "color": $0.color
            ]
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(
            data,
            forKey: "folderList"
        )
    }
    
    private func loadFolderList() {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "folderList") as? [[String: Any]] else { return }
        self.folderList = data.compactMap {
            guard let folderTitle = $0["folderTitle"] as? String else { return nil }
            guard let color = $0["color"] as? String else { return nil }
            return Folder(
                folderTitle: folderTitle,
                color: color
            )
        }
        self.folderList = self.folderList.sorted(by: {
            $0.folderTitle.compare($1.folderTitle) == .orderedAscending
        })
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.folderList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FolderCell", for: indexPath) as? FolderCell else { return UICollectionViewCell() }
        let folder = self.folderList[indexPath.row]
        cell.titleLabel.text = folder.folderTitle
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width / 2) - 24, height: (UIScreen.main.bounds.width / 2) - 24) //비슷한 크기로는 180
    }
}

extension ViewController: WriteFolderViewDelegate {
    func didSelectRegister(folder: Folder) {
        self.folderList.append(folder)
        self.folderList = self.folderList.sorted(by: {
            $0.folderTitle.compare($1.folderTitle) == .orderedAscending
        })
        self.collectionView.reloadData()
    }
}

