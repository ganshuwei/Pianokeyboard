//
//  SettingView.swift
//  Example
//
//  Created by Shuwei Gan on 2021/8/7.
//  Copyright © 2021 Shuwei Gan. All rights reserved.
//

import UIKit

class SettingView: UIView, NibLoadable {

    
    // MARK: - 自定义点击事件
    public var cancelDidClick: (() -> Void)?
    public var keyNumberDidClick: ((Int) -> Void)?
    public var octaveStepperDidClick: ((Int) -> Void)?
    public var showNotesDidClick: (() -> Void)?
    public var scoreDidClick: (() -> Void)?
    public var practiceDidClick: ((Bool) -> Void)?
    
    // MARK: - 控件
    @IBOutlet private var keyNumberStepper: UIStepper!
    @IBOutlet private var octaveStepper: UIStepper!
    @IBOutlet private var keyNumberLabel: UILabel!
    @IBOutlet private var octaveLabel: UILabel!
    @IBOutlet private var showNotesSwitch: UISwitch!
    @IBOutlet private var parcticeSwitch: UISwitch!
    @IBOutlet private var scoreButton: UIButton!
    private var demo: Demo?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 8
        
        keyNumberLabel.text = String(Int(keyNumberStepper.value))
        keyNumberLabel.accessibilityIdentifier = "keyNumberLabel"
        keyNumberStepper.layer.cornerRadius = 8.0
        keyNumberStepper.layer.masksToBounds = true
        keyNumberStepper.accessibilityIdentifier = "keyNumberStepper"
        keyNumberStepper.isAccessibilityElement = true
        keyNumberStepper.value = Double(22)

        octaveLabel.text = String(Int(octaveStepper.value))
        octaveLabel.accessibilityIdentifier = "octaveLabel"
        octaveStepper.layer.cornerRadius = 8.0
        octaveStepper.layer.masksToBounds = true
        octaveStepper.accessibilityIdentifier = "octaveStepper"
        octaveStepper.isAccessibilityElement = true
        
        showNotesSwitch.subviews[0].subviews[0].backgroundColor = .gray
        showNotesSwitch.accessibilityIdentifier = "showNotesSwitch"
        showNotesSwitch.isAccessibilityElement = true
    }
    
    // MARK: - 点击事件的回调 - 到主视图去刷新和更新页面数据
    @IBAction func keyNumberStepperTapped(_ sender: UIStepper) {
        print(sender.value)
        keyNumberLabel.text = String(Int(sender.value))
        keyNumberDidClick?(Int(sender.value))
    }

    @IBAction func octaveStepperTapped(_ sender: UIStepper) {
        octaveLabel.text = String(Int(sender.value))
        octaveStepperDidClick?(Int(sender.value))
    }
    
    @IBAction func showNotesTapped(_: Any) {
        showNotesDidClick?()
    }
    
    // MARK: - 取消按钮点击
    @IBAction func cancelButtonClick(_ sender: Any) {
        cancelDidClick?()
    }
    
    @IBAction func scoreButtonClick(_ sender: Any) {
        scoreDidClick?()
    }
    
    // MARK: - Practice
    @IBAction func practiceClick(_ sender: UISwitch) {
        practiceDidClick?(sender.isOn)
    }
}
