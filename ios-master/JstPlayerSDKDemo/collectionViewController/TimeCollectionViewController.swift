//
//  TimeCollectionViewController.swift
//  JstPlayerSDKDemo
//
//  Created by 開発部のMacBookPro on 2020/03/31.
//  Copyright © 2020 開発部のMacBookPro. All rights reserved.
//

import UIKit
class TimeCollectionViewController: UICollectionViewController {

    // cellの色の配列
    let colors: [UIColor] = [UIColor.black, UIColor.blue, UIColor.brown, UIColor.cyan, UIColor.darkGray, UIColor.darkText, UIColor.gray, UIColor.green, UIColor.lightGray, UIColor.orange, UIColor.red]
    // cellの色の名前の配列
    let colorNames: [String] = ["black", "blue", "brown", "cyan", "darkGray", "darkText", "gray", "green", "lightGray", "orange", "red"]

    // 画面遷移先に渡す色
    var giveColor: UIColor = UIColor.black
    // 画面遷移先に渡す色の名前
    var giveColorName: String = "black"

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // cellの数を返す関数
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }

    // cellに情報を入れていく関数
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Identifierが"CollectionViewCell"でCollectionViewCellというクラスのcellを取得
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell

        // cellのlabelに色付け
        cell.label.backgroundColor = colors[indexPath.item]
        // cellのnameに色の名前を入れる
        cell.name.text = colorNames[indexPath.item]

        return cell
    }

    // cell選択時に呼ばれる関数
    // 画面遷移先に渡すデータをここで格納する
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        giveColor = colors[indexPath.item]
        giveColorName = colorNames[indexPath.item]
        // Identifierが"Segue"のSegueを使って画面遷移する関数
        performSegue(withIdentifier: "Segue", sender: nil)
    }

    // 画面遷移先のViewControllerを取得し、データを渡す
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Segue" {
            let vc = segue.destination as! ViewController
            vc.receiveColor = giveColor
            vc.receiveColorName = giveColorName
        }
    }
}
