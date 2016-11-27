//
//  PickerViewController.swift
//  PromTest
//
//  Created by Dmitriy Shulzhenko on 11/24/16.
//  Copyright © 2016 dmitriy.shulzhenko. All rights reserved.
//

import UIKit

class PickerView: UIView {
    weak var responder: ViewResponderProtocol?
    
    @IBOutlet var rightButton: UIBarButtonItem!
    @IBOutlet var leftButton: UIBarButtonItem!
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var titleItem: UIBarButtonItem!
    
    private var myView: UIView?
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNib()
    }
    
    func loadNib() {
        self.myView = (Bundle.main.loadNibNamed("PickerView", owner: self, options: nil)?.first as! UIView)
        self.addSubview(myView!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        myView!.frame = CGRect.init(origin: CGPoint.zero, size: self.frame.size)
    }
   
    @IBAction func buttonPressed(_ sender: UIBarButtonItem) {
        responder?.didTouchedUpInside(sender)
    }
}
