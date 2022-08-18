//
//  LocalDataView.swift
//  Example
//
//  Created by Shuwei Gan on 2021/8/1.
//  Copyright © 2021 Shuwei Gan. All rights reserved.
//

import UIKit

class LocalDataView: UIView {
    
    // MARK: - 自定义点击事件
    public var localDissDidClick: (() -> Void)?
    public var cellDidClick: ((String) -> Void)?
    
    // MARK: - 控件
    var contentView = UIView()
    var tableView = UITableView()

    // MARK: - 数据
    var files = [String]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpBase()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 初始化
    func setUpBase() {
        backgroundColor = .clear
        contentView.backgroundColor = .white
        addSubview(contentView)
        
        tableView = UITableView(frame: CGRect.zero)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "myCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 70
        tableView.tableFooterView = UIView()
        contentView.addSubview(tableView)
        tableView.backgroundColor = .white
        
        loadData()
    }
    
    
    // MARK: - 加载数据
    func loadData() {
        let fileArray = UserDefaults().object(forKey: "file")
        guard let fileArray = fileArray else {
            return
        }
        files.removeAll()
        files = fileArray as! [String]
        print(fileArray)
        tableView.reloadData()
    }
    
    override func layoutSubviews() {
        superview?.layoutSubviews()
        contentView.x = self.width * 0.7
        contentView.y = 0
        contentView.width = self.width * 0.3
        contentView.height = self.height
        
        tableView.frame = contentView.bounds
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        localDissDidClick?()
    }

}

// MARK: - Table数据源和代理
extension LocalDataView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        files.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        let array = files[indexPath.row].components(separatedBy: "&")
        cell.textLabel?.text = array.first
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let array = files[indexPath.row].components(separatedBy: "&")
        if array.count == 2 {
            cellDidClick?(array.last!)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool{
        return true
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?{
        return "delete"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        
        if editingStyle == UITableViewCell.EditingStyle.delete {
            files.remove(at: indexPath.row)
            UserDefaults().set(files, forKey: "file")
            loadData()
        }
    }
    
    
}
