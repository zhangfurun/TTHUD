//
//  ViewController.swift
//  TTHUD
//
//  Created by 张福润 on 2021/5/28.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TTHUD.success()
    }
}

