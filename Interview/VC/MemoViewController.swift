//
//  MemoViewController.swift
//  Interview
//
//  Created by donghyeon on 2022/07/22.
//

import UIKit

class MemoViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var memoList = [Memo]() {
        didSet {
            self.saveMemoList()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionView()
        self.loadMemoList()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(editMemoNotification(_ :)),
            name: NSNotification.Name("editMemo"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(starMemoNotification(_ :)),
            name: NSNotification.Name("starMemo"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deleteMemoNotification(_ :)),
            name: Notification.Name("deleteMemo"),
            object: nil
        )
    }
    
    private func configureCollectionView() {
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        self.collectionView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    @objc func editMemoNotification(_ notification: Notification) {
        guard let memo = notification.object as? Memo else { return }
        guard let index = self.memoList.firstIndex(where: { $0.uuidString == memo.uuidString }) else { return }
        self.memoList[index] = memo
        self.collectionView.reloadData()
    }
    
    @objc func starMemoNotification(_ notification: Notification) {
        guard let starMemo = notification.object as? [String: Any] else { return }
        guard let isStar = starMemo["isStar"] as? Bool else { return }
        guard let uuidString = starMemo["uuidString"] as? String else { return }
        guard let index = self.memoList.firstIndex(where: { $0.uuidString == uuidString }) else { return }
        self.memoList[index].isStar = isStar
    }
    
    @objc func deleteMemoNotification(_ notification: Notification) {
        guard let uuidString = notification.object as? String else { return }
        guard let index = self.memoList.firstIndex(where: { $0.uuidString == uuidString }) else { return }
        self.memoList.remove(at: index)
        self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let writeMemoViewController = segue.destination as? WriteMemoViewController {
            writeMemoViewController.delegate = self
        }
    }
    
    private func saveMemoList() {
        let data = self.memoList.map {
            [
                "uuidString": $0.uuidString,
                "question": $0.question,
                "answer": $0.answer,
                "isStar": $0.isStar
            ]
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: "memoList")
    }
    
    private func loadMemoList() {
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
        }
    }
}

extension MemoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.memoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemoCell", for: indexPath) as? MemoCell else { return UICollectionViewCell() }
        let memo = self.memoList[indexPath.row]
        cell.titleLabel.text = memo.question
        return cell
    }
}

extension MemoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width) - 10, height: 60)
    }
}

extension MemoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MemoDetailViewController") as? MemoDetailViewController else { return }
        let memo = self.memoList[indexPath.row]
        viewController.memo = memo
        viewController.indexPath = indexPath
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension MemoViewController: WriteMemoViewDelegate {
    func didSelectRegister(memo: Memo) {
        self.memoList.append(memo)
        self.collectionView.reloadData()
    }
}
