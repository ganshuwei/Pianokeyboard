//
//  ViewController.swift
//  Example
//
//  Created by Shuwei Gan on 2021/8/1.
//  Copyright © 2021 Shuwei Gan. All rights reserved.

import UIKit
import AVFoundation

class ViewController: UIViewController, PianoKeyboardDelegate {
    
    // MARK: - 自定义控件和数据
    @IBOutlet private var fascia: FasciaView!
    @IBOutlet private var keyboard: PianoKeyboard!
    @IBOutlet private var latchSwitch: UISwitch!
    @IBOutlet private var parHistoryView: UITextView!
    @IBOutlet private var parcticButton: UIButton!
    private var parHistoryArray: [UInt8] = []
    private var showHistoryArray: [Int] = []
    @IBOutlet private var nextTapButton: UIButton!
    @IBOutlet private var loopButton: UIButton!
    @IBOutlet private var loopLabel: UILabel!
    
    @IBOutlet private var saveButton: UIButton!
    @IBOutlet private var delButton: UIButton!
    @IBOutlet private var cancelButton: UIButton!
    @IBOutlet private var delaySlider: UISlider!
    
    @IBOutlet private var songmenu: UIButton!
    
    @IBOutlet private var Latch: UILabel!
    
    @IBOutlet private var delete: UIButton!
    
    public let noteArray:[String]=["C","#C","D","#D","E","F","#F","G","#G","A","#A","B"]
    private let audioEngine = AudioEngine()
    private var demo: Demo?
    public var index_of_array:Int=0
    public var model_index:Int=0
    var timer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
        
        audioEngine.start()
        
        setSettingView()
    }
    
    // MARK: - 初始化UI
    fileprivate func setUpUI() {
        
        demo = Demo(keyboard: keyboard)
        
        keyboard.delegate = self
        parHistoryView.isHidden = true
        nextTapButton.isHidden = true
        cancelButton.isHidden = true
        songmenu.isHidden=true
        parcticButton.isHidden = true
        loopButton.isHidden = true
        delaySlider.isHidden = true
        parHistoryView.text = ""
        loopLabel.isHidden = true
        saveButton.isHidden = true
        delButton.isHidden = true
        songmenu.isHidden=true
        delete.isHidden=true
        
        
        nextTapButton.layer.cornerRadius = 4
        nextTapButton.layer.masksToBounds = true
        cancelButton.layer.cornerRadius = 4
        cancelButton.layer.masksToBounds = true
        parHistoryView.layer.cornerRadius = 4
        parHistoryView.layer.masksToBounds = true
        saveButton.layer.cornerRadius = 4
        saveButton.layer.masksToBounds = true
        delButton.layer.cornerRadius = 4
        delButton.layer.masksToBounds = true
        delete.layer.cornerRadius=4
        delete.layer.masksToBounds=true
        
        loopLabel.text = "loop interval 1s"
        delaySlider.addTarget(self, action: #selector(rateChange), for: .valueChanged)

        latchSwitch.subviews[0].subviews[0].backgroundColor = .gray
        latchSwitch.accessibilityIdentifier = "latchSwitch"
        latchSwitch.isAccessibilityElement = true
        
        localView.x = view.width
    }
    
    lazy var localView: LocalDataView = {
        let localView = LocalDataView(frame: view.bounds)
        view.addSubview(localView)
        view.bringSubviewToFront(localView)
        localView.localDissDidClick = { [weak self] in
            UIView.animate(withDuration: 0.25) {
                self!.localView.x = self!.view.width
            }
        }
        localView.cellDidClick = { [weak self] content in
            print(content)
            self?.showHistoryArray.removeAll()
            self?.parHistoryArray.removeAll()
            
            UIView.animate(withDuration: 0.25) {
                self!.localView.x = self!.view.width
            }
            //self?.parHistoryView.text = content
//            self?.loopForClick(1) // 自动的话打开此代码
            
            let newContent = content.replacingOccurrences(of: "Key: ", with: "")
            print(newContent)
            let newContentArray = newContent.components(separatedBy: "、")
            print(newContentArray)
            for item in newContentArray {
                print(item)
                if item.count > 0 {
                    let index = Int(item)!
                    let octave = self!.keyboard.octave
                    
                    self?.parHistoryArray.append(UInt8(index))
                    self?.showHistoryArray.append(index - octave)
                    
                    
                }
            }
        }
        return localView
    }()
    
    
    lazy var setView: SettingView = {
        let setView = SettingView.loadFromNib()
        setView.isHidden = true
        
        setView.cancelDidClick = { [weak self] in
            setView.isHidden = true
        }
        
        setView.octaveStepperDidClick = { [weak self] value in
            self?.keyboard.octave = value
        }
        
        setView.keyNumberDidClick = { [weak self] value in
            self?.keyboard.numberOfKeys = value
        }
        
        setView.showNotesDidClick = { [weak self] in
            self?.keyboard.toggleShowNotes()
        }
        
        setView.scoreDidClick = { [weak self] in
            setView.isHidden = true
            self?.setUpAlterView()
        }
        
        setView.practiceDidClick = { [weak self] on in
            self?.parHistoryView.text = ""
            self?.parcticeFunction(open: on)
            if on==true{
                self?.model_index=1
            }
        }
        
        setView.InputDidClick = { [weak self] on in
            if self?.parHistoryArray.count != 0 && self?.index_of_array != 0 {
                self?.keyboard.highlightKey(noteNumber: Int((self?.parHistoryArray[self!.index_of_array-1])!), color: UIColor.white)
            }
            self?.parHistoryView.text = ""
            self?.InputFunction(open:on)
            if on==true {
                self?.model_index=2
            }
            
        }
        
        view.addSubview(setView)
        view.bringSubviewToFront(setView)
        setView.size = CGSize(width: view.width * 0.5, height: view.height * 0.6)
        setView.center = view.center
        return setView
    }()
    
    // MARK: - 设置SettingView
    func setSettingView() {
        setView.isHidden = true
    }
    
    @IBAction func showSettingVcClick(_ sender: Any) {
        setView.isHidden = false
    }
    
    @IBAction func showMoreVcClick(_ sender: Any) {
        UIView.animate(withDuration: 0.25) {
            self.localView.x = 0
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        demo?.notes()
    }

    // MARK: - Settings
    func setUpAlterView() {
        let alertView = ZYInputAlertView.singleton()
        alertView?.inputTextView.keyboardType = .numbersAndPunctuation
        alertView!.confirmBgColor = .black
        alertView!.placeholder = "Please enter the sheet music format as follows 12、13、14 In the range0~\((keyboard.numberOfKeys) - 2)"
        alertView!.confirmBtnClick { [self] content in
            let array = content!.components(separatedBy: "、")
            if array.count == 0 {
                return
            }
            self.parHistoryView.text = ""
            self.showHistoryArray.removeAll()
            self.parHistoryArray.removeAll()
            
            for item in array {
                if Int(item) ?? 0 > Int(keyboard.numberOfKeys) - 2 {
                    continue
                }
                
                self.parHistoryArray.append(UInt8(keyboard.octave + Int(item)!))
                self.showHistoryArray.append(Int(item)!)
                
                
            }
            for item in self.parHistoryArray {
                let a = item/12-1
                self.parHistoryView.text = parHistoryView.text + noteArray[Int(item) % 12]+"\(a)"+"\t"
            }
            self.loopForClick(1)
        }
        alertView!.show()
    }

    @IBAction func deleteButtonClick(_ sender: Any) {
        if parHistoryArray.count != 0{
            parHistoryArray.removeLast()}
        self.parHistoryView.text=""
        for item in self.parHistoryArray {
            let a = item/12-1
            self.parHistoryView.text = parHistoryView.text + noteArray[Int(item) % 12]+"\(a)"+"\t"
        }
    }
    
    
    @IBAction func delButtonClick(_ sender: Any) {
        parHistoryView.text = ""
        parHistoryArray.removeAll()
        showHistoryArray.removeAll()
    }
    
    @IBAction func saveButtonClick(_ sender: Any) {
        if parHistoryView.text.count == 0 {
            return
        }
        var text=""
        for item in parHistoryArray{
            text=text+"Key: \(item)、"
        }
        let titleAlter = UIAlertController(title: "Please enter the name of the storage file", message: "", preferredStyle: .alert)
        titleAlter.addTextField { field in
            field.placeholder = "file name"
        }
        let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel) { _ in
        }
        
        let saveBtn = UIAlertAction(title: "Save", style: .default) { [self] _ in
            var fileName = titleAlter.textFields?.first?.text!
            fileName = fileName! + "&" + text
            
            let fileArray = UserDefaults().object(forKey: "file")
            guard let fileNameArray = fileArray else {
                var files = [String]()
                files.append(fileName!)
                UserDefaults().set(files, forKey: "file")
                localView.loadData()
                return
            }
            var files = [String]()
            files = fileNameArray as! [String]
            files.append(fileName!)
            UserDefaults().set(files, forKey: "file")
            print(fileName!)
            localView.loadData()
        }
        titleAlter.addAction(cancelBtn)
        titleAlter.addAction(saveBtn)
        present(titleAlter, animated: true, completion: nil)
    }
    
    @IBAction func latchTapped(_ sender: Any) {
        keyboard.toggleLatch()
    }

    @IBAction func nextClick(_ sender: Any) {
        againPlay(showAgain: true)
    }
    
    @IBAction func loopForClick(_ sender: Any) {
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(delaySlider.value) * 2, target: self, selector: #selector(againPlay), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
        cancelButton.isHidden = false
    }
    
    @IBAction func cancelButtonClick(_ sender: Any) {
        timer.invalidate()
        cancelButton.isHidden = true
    }
    
    @objc func rateChange(slider: UISlider) {
        let s = String(format:"%.2f",slider.value * 2)
        loopLabel.text = "loop interval \(s)s"
    }
    
    @objc func againPlay(showAgain: Bool) {
        if parHistoryArray.count==0{
            return
        }
        if index_of_array == parHistoryArray.count{
            timer.invalidate()
            cancelButton.isHidden = true
            keyboard.highlightKey(noteNumber: Int(parHistoryArray[index_of_array-1]), color: UIColor.white)
            index_of_array=0
            parHistoryView.text=""
            if showAgain {
                nextTapButton.isHidden = true
                parcticButton.isEnabled = true
            }
            return
        }
        print(index_of_array)
        audioEngine.sampler.startNote(parHistoryArray[index_of_array], withVelocity: 64, onChannel: 0)
        if showHistoryArray[index_of_array] < keyboard.keysArray.count {
            keyboard.keysArray[Int(showHistoryArray[index_of_array])]?.setImage(keyNum: Int(parHistoryArray[index_of_array]), isDown: true)
            keyboard.highlightKey(noteNumber: Int(parHistoryArray[index_of_array]), color: UIColor.red)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [self] in
            audioEngine.sampler.stopNote(parHistoryArray[index_of_array], onChannel: 0)
            if showHistoryArray[index_of_array] < keyboard.keysArray.count-1 {
                keyboard.keysArray[Int(showHistoryArray[index_of_array])]?.setImage(keyNum: Int(parHistoryArray[index_of_array]), isDown: false)
                
            }
            index_of_array = index_of_array + 1
            if index_of_array  == parHistoryArray.count+1{
                timer.invalidate()
                keyboard.highlightKey(noteNumber: Int(parHistoryArray[index_of_array-1]), color: UIColor.white)
                cancelButton.isHidden = true
                nextTapButton.isHidden = true
                parcticButton.isEnabled = true
                return
            } else {
                if showAgain {
                    self.nextTapButton.isHidden = false
                    self.parcticButton.isEnabled = false
                }
            }
            let a = parHistoryArray[index_of_array-1]/12-1
            parHistoryView.text =  noteArray[Int(parHistoryArray[index_of_array-1]) % 12]+"\(a)"+"\t"
            
        }
        
    }
    
    
    // MARK: - Practice and Input
    @IBAction func startPracticeClick(_ sender: Any) {
        againPlay(showAgain: true)
        index_of_array=0
    }
    
    func parcticeFunction(open: Bool) {
        if open {
            parHistoryView.isHidden = false
            parcticButton.isHidden = false
            parcticButton.isEnabled = true
            loopButton.isHidden = false
            delaySlider.isHidden = false
            delaySlider.value = 0.5
            loopLabel.text = "loop interval 1s"
            loopLabel.isHidden = false
            saveButton.isHidden = true
            delButton.isHidden = true
            songmenu.isHidden=false
            delete.isHidden=true
            
        } else {
            parHistoryView.isHidden = true
            parcticButton.isHidden = true
            loopButton.isHidden = true
            delaySlider.isHidden = true
            parHistoryView.text = ""
            loopLabel.isHidden = true
            saveButton.isHidden = true
            delButton.isHidden = true
            songmenu.isHidden=true
            delete.isHidden=true
        }
        parHistoryArray.removeAll()
        showHistoryArray.removeAll()
    }
    
    func InputFunction(open: Bool) {
        if open {
            parHistoryView.isHidden = false
            parcticButton.isHidden = true
            parcticButton.isEnabled = false
            loopButton.isHidden = true
            delaySlider.isHidden = true
            loopLabel.isHidden = true
            saveButton.isHidden = false
            delButton.isHidden = false
            songmenu.isHidden=true
            delete.isHidden=false
            nextTapButton.isHidden=true
        } else {
            parHistoryView.isHidden = true
            parcticButton.isHidden = true
            loopButton.isHidden = true
            delaySlider.isHidden = true
            parHistoryView.text = ""
            loopLabel.isHidden = true
            saveButton.isHidden = true
            delButton.isHidden = true
            songmenu.isHidden=true
            delete.isHidden=true
        }
        parHistoryArray.removeAll()
        showHistoryArray.removeAll()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}



// MARK: - PianoKeyboardDelegate
extension ViewController {
    func pianoKeyDown(_ keyNumber: Int) {
        print("\(milliStamp) pianoKeyDown + \(keyNumber)")
        audioEngine.sampler.startNote(UInt8(keyboard.octave + keyNumber), withVelocity: 64, onChannel: 0)
        if model_index != 1{
            parHistoryView.text = ""
        }
        if self.model_index==2{
            parHistoryArray.append(UInt8(keyboard.octave + keyNumber))
            showHistoryArray.append(keyNumber)
            for item in parHistoryArray {
                let a = item/12 - 1
                self.parHistoryView.text = parHistoryView.text + noteArray[Int(item) % 12]+"\(a)"+"\t"
            }
        }
        
        
    }

    func pianoKeyUp(_ keyNumber: Int) {
        print("\(milliStamp) pianoKeyUp + \(keyNumber)")
        audioEngine.sampler.stopNote(UInt8(keyboard.octave + keyNumber), onChannel: 0)
    }
    
    /// 获取当前 毫秒级 时间戳 - 13位
    var milliStamp : String {
       let timeInterval: TimeInterval = Date().timeIntervalSince1970
       let millisecond = CLongLong(round(timeInterval*1000))
       return "\(millisecond)"
    }
    
}
