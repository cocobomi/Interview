//
//  MemoDetailViewController.swift
//  Interview
//
//  Created by donghyeon on 2022/07/22.
//

import UIKit

class MemoDetailViewController: UIViewController {
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var answerTextView: UITextView!
    var starButton: UIBarButtonItem?
    
    var memo: Memo?
    var indexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(starMemoNotification(_:)),
            name: NSNotification.Name("starMemo"),
            object: nil
        )
    }
    
    private func configureView() {
        guard let memo = self.memo else { return }
        self.questionTextView.text = memo.question
        self.answerTextView.text = memo.answer
        self.starButton = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(tapStarButton))
        self.starButton?.image = memo.isStar ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        self.starButton?.tintColor = .orange
        self.navigationItem.rightBarButtonItem = self.starButton
    }
    
    @objc func editMemoNotification(_ notification: Notification) {
        guard let memo = notification.object as? Memo else { return }
        self.memo = memo
        self.configureView()
    }
    
    @objc func starMemoNotification(_ notification: Notification) {
        guard let starMemo = notification.object as? [String: Any] else { return }
        guard let isStar = starMemo["isStar"] as? Bool else { return }
        guard let uuidString = starMemo["uuidString"] as? String else { return }
        guard let memo = self.memo else { return }
        if memo.uuidString == uuidString {
            self.memo?.isStar = isStar
            self.configureView()
        }
    }
    
    @IBAction func tabEditButton(_ sender: UIButton) {
        guard let viewController = self.storyboard?.instantiateViewController(identifier: "WriteMemoViewController") as? WriteMemoViewController else { return }
        guard let indexPath = self.indexPath else { return }
        guard let memo = self.memo else { return }
        viewController.memoEditorMode = .edit(indexPath, memo)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(editMemoNotification(_ :)),
            name: NSNotification.Name("editMemo"),
            object: nil
        )
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func tabDeleteButton(_ sender: UIButton) {
        guard let uuidString = self.memo?.uuidString else { return }
        
        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
            NotificationCenter.default.post(
                name: NSNotification.Name("deleteMemo"),
                object: uuidString,
                userInfo: nil
            )
            self.navigationController?.popViewController(animated: true)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let alertController = UIAlertController(title: nil, message: "해당 메모를 삭제하시겠습니까?", preferredStyle: .alert)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func tapStarButton() {
        guard let isStar = self.memo?.isStar else { return }
        
        if isStar {
            self.starButton?.image = UIImage(systemName: "star")
        }   else {
            self.starButton?.image = UIImage(systemName: "star.fill")
        }
        self.memo?.isStar = !isStar
        NotificationCenter.default.post(
            name: NSNotification.Name("starMemo"),
            object: [
                "memo": self.memo as Any,
                "isStar": self.memo?.isStar ?? false,
                "uuidString": memo?.uuidString as Any
            ],
            userInfo: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
