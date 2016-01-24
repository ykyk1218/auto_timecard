//
//  UserRegistViewController.swift
//  auto_timecart
//
//  Created by 小林芳樹 on 2016/01/06.
//  Copyright © 2016年 小林芳樹. All rights reserved.
//

import UIKit
import QuartzCore


class UserRegistViewController: UIViewController, UITextFieldDelegate {
    
    private let lblEmail = UILabel()
    private let txtEmail = UITextField()
    private let btnSubmit = UIButton()
    
    let defaults = NSUserDefaults.standardUserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let baseY: CGFloat = 200.0
        //self.view.backgroundColor = UIColor.hex("00FFFF", alpha: 0.8)
        
        /*
        ぼかし画像を全画面で表示
        let filter = CIFilter(name: "CIGaussianBlur")!
        filter.setValue(CIImage(image: UIImage(named: "new_kakushin.png")!), forKey: kCIInputImageKey)
        let ciContext:CIContext = CIContext(options: nil)
        let cgimg:CGImageRef = ciContext.createCGImage(filter.outputImage!, fromRect:filter.outputImage!.extent)
        UIGraphicsBeginImageContext(self.view.frame.size);
        let backImg: UIImage = UIImage(CGImage: cgimg, scale: 2.0, orientation:UIImageOrientation.Up)
        backImg.drawInRect(self.view.bounds)
        let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.view.backgroundColor = UIColor(patternImage: backgroundImage)
        */
        
        lblEmail.frame = CGRectMake(0,0,240,50)
        lblEmail.center = CGPointMake(self.view.bounds.width/2-30, baseY)
        lblEmail.text = "メールアドレス"
        lblEmail.textColor = UIColor.whiteColor()
        lblEmail.font = UIFont(name: "ヒラギノ角ゴ ProN W6",size: 25)
        
        txtEmail.frame = CGRectMake(0,0,self.view.bounds.width-30,50)
        txtEmail.center = CGPointMake(self.view.bounds.width/2, baseY+50)
        txtEmail.text = ""
        txtEmail.borderStyle = UITextBorderStyle.Line
        txtEmail.backgroundColor = UIColor.whiteColor()
        txtEmail.layer.borderWidth = 1.0
        txtEmail.layer.cornerRadius = 10.0
        txtEmail.layer.borderColor = UIColor.hex("efefef", alpha: 1).CGColor
        
        let paddingView:UIView = UIView(frame: CGRectMake(0,0,10,10))
        txtEmail.leftView = paddingView
        txtEmail.textColor = UIColor.hex("333333", alpha: 1)
        txtEmail.leftViewMode = UITextFieldViewMode.Always
        txtEmail.placeholder = "メールアドレスを入力してください"
        txtEmail.delegate = self
        
        btnSubmit.frame = CGRectMake(0, 0, self.view.bounds.width-30, 40)
        btnSubmit.center = CGPointMake(self.view.bounds.width/2, baseY+105)
        btnSubmit.backgroundColor = UIColor.hex("b3d3ac", alpha: 1)
        btnSubmit.setTitle(" 入力したないようで送信 ", forState: UIControlState.Normal)
        btnSubmit.setTitle(" 入力したないようで送信 ", forState: UIControlState.Highlighted)
        btnSubmit.showsTouchWhenHighlighted = true
        btnSubmit.addTarget(self, action: "regist", forControlEvents: .TouchUpInside)
        
        /*
        self.view.addSubview(lblEmail)
        self.view.addSubview(txtEmail)
        self.view.addSubview(btnSubmit)
        */
        
        let aSelector = Selector("tapGesture:")
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: aSelector)
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        let imageView = UIImageView(image: UIImage(named: "new_kakushin.png"))
        imageView.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
        blurView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        blurView.contentView.frame = blurView.frame
        
        self.view.addSubview(imageView)
        blurView.contentView.addSubview(lblEmail)
        blurView.contentView.addSubview(txtEmail)
        blurView.contentView.addSubview(btnSubmit)
        self.view.addSubview(blurView)

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
        if(email == nil || email!.isEmpty){
            SweetAlert().showAlert("入力エラー", subTitle: "メールアドレスが空です", style: AlertStyle.Warning)
            
        }else{
            
            //メールアドレス存在チェック
            let timecardModel = TimecardModel()
            timecardModel.checkUser(["email": email!]) {(check: Bool)->() in
                if(check) {
                    self.defaults.setObject(email, forKey: "email")
                    self.defaults.synchronize()
                    let nav = CustomNavigationController(rootViewController: ViewController())
                    self.presentViewController(nav, animated: true, completion: nil)
                }else{
                    SweetAlert().showAlert("入力エラー", subTitle: "入力したメールアドレスは登録されていません", style: AlertStyle.Error)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
