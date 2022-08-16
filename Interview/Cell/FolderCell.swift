//
//  FolderCell.swift
//  Interview
//
//  Created by donghyeon on 2022/07/21.
//

import UIKit

class FolderCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.contentView.layer.cornerRadius = 20.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.lightGray.cgColor
        self.contentView.layer.backgroundColor = CGColor.init(red: 178/255, green: 235/255, blue: 244/255, alpha: 1.0)
    }
}
