//
//  StarViewController.swift
//  Interview
//
//  Created by donghyeon on 2022/07/21.
//

import UIKit

class StarViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var memoList = [Memo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionView()
        self.loadStarMemoList()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(editMemoNotification(_:)),
            name: NSNotification.Name("editMemo"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(starMemoNotification(_:)),
            name: NSNotification.Name("starMemo"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deleteMemoNotification(_:)),
            name: NSNotification.Name("deleteMemo"),
            object: nil
        )
    }
    
    private func configureCollectionView() {
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        self.collectionView.contentInset = UIEdgeInsets(
            top: 10,
            left: 10,
            bottom: 10,
            right: 10
        )
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    private func loadStarMemoList() {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "memoList") as? [[String: Any]] else { return }
        self.memoList = data.compactMap {
            guard let uuidString = $0["uuidString"] as? String else { return nil }
            guard let question = $0["question"] as? String else { return nil }
            guard let answer = $0["answer"] as? String else { return nil }
            guard let isStar = $0["isStar"] as? Bool else { return nil }
            return Memo(
                uuidString: uuidString,
                question: question,
                answer: answer,
                isStar: isStar
            )
        }.filter({
            $0.isStar == true
        })
    }
    
    @objc func editMemoNotification(_ notification: Notification) {
        guard let memo = notification.object as? Memo else { return }
        guard let index = self.memoList.firstIndex(where: { $0.uuidString == memo.uuidString }) else { return }
        self.memoList[index] = memo
        self.collectionView.reloadData()
    }
    
    @objc func starMemoNotification(_ notification: Notification) {
        guard let starMemo = notification.object as? [String: Any] else { return }
        guard let memo = starMemo["memo"] as? Memo else { return }
        guard let isStar = starMemo["isStar"] as? Bool else { return }
        guard let uuidString = starMemo["uuidString"] as? String else { return }
        if isStar {
            self.memoList.append(memo)
            self.collectionView.reloadData()
        } else {
            guard let index = self.memoList.firstIndex(where: { $0.uuidString == uuidString }) else { return }
            self.memoList.remove(at: index)
            self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
        }
    }
    
    @objc func deleteMemoNotification(_ notification: Notification) {
        guard let uuidString = notification.object as? String else { return }
        guard let index = self.memoList.firstIndex(where: { $0.uuidString == uuidString }) else { return }
        self.memoList.remove(at: index)
        self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
    }
}

extension StarViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.memoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StarCell", for: indexPath) as? StarCell else { return UICollectionViewCell() }
        let memo = self.memoList[indexPath.row]
        cell.folderLabel.text = memo.question
        cell.memoLabel.text = memo.answer
        return cell
    }
}

extension StarViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width - 20, height: 80)
    }
}

extension StarViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewController = self.storyboard?.instantiateViewController(identifier: "MemoDetailViewController") as? MemoDetailViewController else { return }
        let memo = self.memoList[indexPath.row]
        viewController.memo = memo
        viewController.indexPath = indexPath
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
