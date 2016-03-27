//
//  ApplicationsViewController.swift
//  iOSApplicationsManager
//
//  Created by Aleksandr Karimov on 20.03.16.
//  Copyright © 2016 AlexKar. All rights reserved.
//

import Cocoa

class ApplicationsViewController: NSViewController, ApplicationsViewModelDelegate, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var applicationsTableView : NSTableView?
    @IBOutlet weak var scrollView : NSScrollView?
    @IBOutlet weak var progressIndicator : NSProgressIndicator?
    
    private var model: ApplicationsViewModel?
    
    var viewModel: ApplicationsViewModel? {
        set(viewModel) {
            model?.delegate = nil
            model = viewModel
            model?.delegate = self
            applicationsTableView?.reloadData()
        }
        get {
            return model
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applicationsTableView?.setDelegate(self)
        applicationsTableView?.setDataSource(self)
    }
    
    @IBAction func archiveDidPressed(sender: AnyObject) -> Void {
        let selectedRow = applicationsTableView?.selectedRow
        if (selectedRow != nil) {
            let applicationItem = model?.applicationItems[selectedRow!]
            if (applicationItem != nil) {
                model?.archiveApplicationItems([applicationItem!])
            }
        }
    }
    
    @IBAction func restoreDidPressed(sender: AnyObject) -> Void {
        let selectedRow = applicationsTableView?.selectedRow
        if (selectedRow != nil) {
            let applicationItem = model?.applicationItems[selectedRow!]
            if (applicationItem != nil) {
                model?.restoreApplicationItems([applicationItem!])
            }
        }
    }
    
    // #MARK: - ApplicationsViewModelDelegate
    func didChangeApplicationItems(viewModel: ApplicationsViewModel) {
        applicationsTableView?.reloadData()
    }
    
    func shouldShowProgress(viewModel: ApplicationsViewModel) {
        progressIndicator?.startAnimation(self)
        progressIndicator?.hidden = false;
    }
    
    func shouldHideProgress(viewModel: ApplicationsViewModel) {
        progressIndicator?.hidden = true
        progressIndicator?.stopAnimation(self)
    }
    
    // #MARK: - NSTableViewDelegate
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let identifier = tableColumn?.identifier == "ApplicationName" ? "ApplicationNameCell" : "BundleIDCell"
        let cell = tableView.makeViewWithIdentifier(identifier, owner: self) as? NSTableCellView
        let applicationItem = viewModel?.applicationItems[row]
        if (tableColumn?.identifier == "ApplicationName") {
            cell?.textField?.stringValue = (applicationItem?.name)!
        }
        else {
            cell?.textField?.stringValue = (applicationItem?.bundleId)!
        }
        return cell;
    }
    
    // #MARK: - NSTableViewDataSource
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if (viewModel == nil) {
            return 0
        }
        return (viewModel?.applicationItems.count)!
    }
}
