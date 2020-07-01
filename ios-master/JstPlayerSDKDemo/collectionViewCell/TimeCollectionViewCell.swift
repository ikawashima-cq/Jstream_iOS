//
//  TimeCollectionViewCell.swift
//  JstPlayerSDKDemo
//
//  Created by 開発部のMacBookPro on 2020/03/31.
//  Copyright © 2020 開発部のMacBookPro. All rights reserved.
//

import UIKit

class TimeCollectionViewCell: UICollectionViewCell{
    @IBOutlet weak var label: UILabel!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        // cellの枠の太さ
        self.layer.borderWidth = 1.0
        // cellの枠の色
        self.layer.borderColor = UIColor.black.cgColor
        // cellを丸くする
        self.layer.cornerRadius = 8.0
    }
}
