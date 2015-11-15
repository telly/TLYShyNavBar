//
//  TableViewController.swift
//  TLYShyNavBarSwiftDemo
//
//  Created by Tony Nuzzi on 2/22/15.
//  Copyright (c) 2015 Telly, Inc. All rights reserved.
//

import UIKit

class TableViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let view = UIView(frame: CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 40))
        view.backgroundColor = UIColor.redColor()
        
        
        /* Library code */
        self.shyNavBarManager.scrollView = self.tableView;
        self.shyNavBarManager.extensionView = view
    }
}

extension TableViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = "Content"
        
        return cell
    }
}
