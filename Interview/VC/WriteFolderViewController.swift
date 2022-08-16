//
//  WriteFolderViewController.swift
//  Interview
//
//  Created by donghyeon on 2022/07/22.
//

import UIKit

protocol WriteFolderViewDelegate: AnyObject {
    func didSelectRegister(folder: Folder)
}

class WriteFolderViewController: UIViewController {
    @IBOutlet weak var folderTitleTextField: UITextField!
    @IBOutlet weak var colorTextField: UITextField!
    @IBOutlet weak var confirmButton: UIBarButtonItem!
    
    weak var delegate: WriteFolderViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureInputField()
        self.confirmButton.isEnabled = false
    }
    
    private func configureInputField() {
        self.colorTextField.delegate = self
        self.folderTitleTextField.addTarget(
            self,
            action: #selector(categoryTitleTextFieldDidChange(_:)),
            for: .editingChanged
        )
        self.colorTextField.addTarget(
            self,
            action: #selector(colorTextFieldDidChange(_:)),
            for: .editingChanged
        )
    }
    
    @IBAction func tabConfirmButton(_ sender: UIBarButtonItem) {
        guard let folderTitle = self.folderTitleTextField.text else { return }
        guard let color = self.colorTextField.text else { return }
        let folder = Folder(
            folderTitle: folderTitle,
            color: color
        )
        self.delegate?.didSelectRegister(folder: folder)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func categoryTitleTextFieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
    
    @objc private func colorTextFieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
    
    //빈화면 터치시 키보드 숨김
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //등록 버튼 활성화 조건 메소드
    private func validateInputField() {
        self.confirmButton.isEnabled = !(self.folderTitleTextField.text?.isEmpty ?? true) && !(self.colorTextField.text?.isEmpty ?? true)
    }
}

extension WriteFolderViewController: UITextFieldDelegate {
    //TextField의 text가 입력될 때 마다 validateInputField 메소드를 호출함
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.validateInputField()
    }
}
