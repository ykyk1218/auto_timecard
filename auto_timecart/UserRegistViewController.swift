//
//  UserRegistViewController.swift
//  auto_timecart
//
//  Created by 小林芳樹 on 2016/01/06.
//  Copyright © 2016年 小林芳樹. All rights reserved.
//

import UIKit

class UserRegistViewController: UIViewController, UITextFieldDelegate {
    
    private let lblEmail = UILabel()
    private let txtEmail = UITextField()
    private let btnSubmit = UIButton()
    
    let defaults = NSUserDefaults.standardUserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let baseY: CGFloat = 200.0
        
        lblEmail.frame = CGRectMake(0,0,240,50)
        lblEmail.center = CGPointMake(self.view.bounds.width/2-30, baseY)
        lblEmail.text = "メールアドレス"
        lblEmail.textColor = UIColor.whiteColor()
        lblEmail.font = UIFont(name: "ヒラギノ角ゴ ProN W6",size: 25)
        
        txtEmail.frame = CGRectMake(0,0,240,50)
        txtEmail.center = CGPointMake(self.view.bounds.width/2-30, baseY+50)
        txtEmail.text = "kobayashi@basicinc.jp"
        txtEmail.borderStyle = UITextBorderStyle.Line
        txtEmail.backgroundColor = UIColor.whiteColor()
        let paddingView:UIView = UIView(frame: CGRectMake(0,0,10,10))
        txtEmail.leftView = paddingView
        txtEmail.textColor = UIColor.hex("333333", alpha: 1)
        txtEmail.leftViewMode = UITextFieldViewMode.Always
        txtEmail.delegate = self
        
        btnSubmit.frame = CGRectMake(20, baseY+105, self.view.bounds.width-30, 40)
        //btnSubmit.center = CGPointMake(15 , baseY+105)
        btnSubmit.backgroundColor = UIColor.hex("ADB367", alpha: 1)
        btnSubmit.setTitle(" 入力したないようで送信 ", forState: UIControlState.Normal)
        btnSubmit.setTitle(" 入力したないようで送信 ", forState: UIControlState.Highlighted)
        btnSubmit.showsTouchWhenHighlighted = true
        btnSubmit.addTarget(self, action: "regist", forControlEvents: .TouchUpInside)
        
        self.view.addSubview(lblEmail)
        self.view.addSubview(txtEmail)
        self.view.addSubview(btnSubmit)
        
        let aSelector = Selector("tapGesture:")
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: aSelector)
        self.view.addGestureRecognizer(tapGestureRecognizer)

        
    }

    func tapGesture(gestureRecognizer: UITapGestureRecognizer){
        self.txtEmail.resignFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //テキストフィールドからフォーカスを外して、キーボードを閉じる
        textField.resignFirstResponder()
        return true
    }
    
    func regist() {
        let email = txtEmail.text
        defaults.setObject(email, forKey: "email")
        defaults.synchronize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
