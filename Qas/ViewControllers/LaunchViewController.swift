//
//  LaunchViewController.swift
//  Qas
//
//  Created by temma on 2017/09/04.
//  Copyright © 2017年 eifaniori. All rights reserved.
//
import UIKit
import LTMorphingLabel

class LaunchViewController: UIViewController, LTMorphingLabelDelegate {
    
    fileprivate var label: LTMorphingLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
        label = LTMorphingLabel(frame: CGRect(x: 100, y: 400, width: 200, height: 40))
        label.text = "Quick Access Browser"
        label.morphingEffect = .pixelate
        view.addSubview(label)
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] _ in
        //            guard let `self` = self else { return }
        //            self.label.text = "Qas"
        //        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func morphingDidStart(_ label: LTMorphingLabel) {
    }
    
    func morphingOnProgress(_ label: LTMorphingLabel, progress: Float) {
    }
    
    func morphingDidComplete(_ label: LTMorphingLabel) {
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
