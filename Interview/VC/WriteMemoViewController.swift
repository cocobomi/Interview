//
//  WriteMemoViewController.swift
//  Interview
//
//  Created by donghyeon on 2022/07/22.
//

import UIKit

enum MemoEditorMode {
    case new
    case edit(IndexPath, Memo)
}

protocol WriteMemoViewDelegate: AnyObject {
    func didSelectRegister(memo: Memo)
}

class WriteMemoViewController: UIViewController {
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var answerTextView: UITextView!
    @IBOutlet weak var confirmButton: UIBarButtonItem!
    
    weak var delegate: WriteMemoViewDelegate?
    var memoEditorMode: MemoEditorMode = .new
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureContentsTextView()
        self.configureInputField()
        self.configureEditMode()
        self.confirmButton.isEnabled = false
    }
    
    private func configureEditMode() {
        switch self.memoEditorMode {
        case let .edit(_, memo):
            self.questionTextView.text = memo.question
            self.answerTextView.text = memo.answer
            self.confirmButton.title = "수정"
            
        default:
            break
        }
    }
    
    //Text Field 테투리 표현
    private func configureContentsTextView() {
        let borderColor = UIColor(
            red: 220/255,
            green: 220/255,
            blue: 220/255,
            alpha: 1.0
        )
        self.questionTextView.layer.borderColor = borderColor.cgColor
        self.questionTextView.layer.borderWidth = 0.5
        self.questionTextView.layer.cornerRadius = 5.0
        
        self.answerTextView.layer.borderColor = borderColor.cgColor
        self.answerTextView.layer.borderWidth = 0.5
        self.answerTextView.layer.cornerRadius = 5.0
    }
    
    private func configureInputField() {
        self.questionTextView.delegate = self
        self.answerTextView.delegate = self
        self.answerTextView.refreshControl?.addTarget(self, action: #selector(answerTextViewDidChange(_:)), for: .editingChanged)
        self.questionTextView.refreshControl?.addTarget(self, action: #selector(questionTextViewDidChange(_:)), for: .editingChanged)
    }
    
    @IBAction func tabConfirmButton(_ sender: UIBarButtonItem) {
        guard let question = self.questionTextView.text else { return }
        guard let answer = self.answerTextView.text else { return }
        
        switch self.memoEditorMode {
        case .new:
            let memo = Memo(
                uuidString: UUID().uuidString,
                question: question,
                answer: answer,
                isStar: false
            )
            self.delegate?.didSelectRegister(memo: memo)
        case let .edit(indexPath, memo):
            let memo = Memo(
                uuidString: memo.uuidString,
                question: question,
                answer: answer,
                isStar: memo.isStar
            )
            NotificationCenter.default.post(
                name: NSNotification.Name("editMemo"),
                object: memo,
                userInfo: nil
            )
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func questionTextViewDidChange(_ textView: UITextView) {
        self.validateInputField()
    }
    
    @objc private func answerTextViewDidChange(_ textView: UITextView) {
        self.validateInputField()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func validateInputField() {
        self.confirmButton.isEnabled = !(self.questionTextView.text?.isEmpty ?? true) && !(self.answerTextView.text?.isEmpty ?? true)
    }
}

extension WriteMemoViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.validateInputField()
    }
}
