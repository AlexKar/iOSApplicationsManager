//
//  ViewController.swift
//  iOSApplicationsManager
//
//  Created by Aleksandr Karimov on 19.03.16.
//  Copyright © 2016 AlexKar. All rights reserved.
//

import Cocoa

class DevicesViewController: NSViewController, DevicesViewModelDelegate, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var devicesTableView : NSTableView?
    @IBOutlet weak var scrollView : NSScrollView?
    @IBOutlet weak var progressIndicator : NSProgressIndicator?
    
    private var viewModel: DevicesViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = DevicesViewModel()
        viewModel?.delegate = self;
        
        devicesTableView?.setDelegate(self)
        devicesTableView?.setDataSource(self)
        
        if (viewModel?.deviceItems.count == 0) {
            scrollView?.hidden = true
            progressIndicator?.startAnimation(self)
            progressIndicator?.hidden = false
        }
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    // #MARK: - DevicesViewModelDelegate
    func didChangeDeviceItems(viewModel: DevicesViewModel) {
        if (viewModel.deviceItems.count > 0) {
            scrollView?.hidden = false
            progressIndicator?.stopAnimation(self)
            progressIndicator?.hidden = true
        }
        devicesTableView?.reloadData()
    }
    
    // #MARK: - NSTableViewDelegate
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let identifier = tableColumn?.identifier == "DeviceName" ? "DeviceNameCell" : "DeviceUDIDCell"
        let cell = tableView.makeViewWithIdentifier(identifier, owner: self) as? NSTableCellView
        let deviceItem = viewModel?.deviceItems[row]
        if (tableColumn?.identifier == "DeviceName") {
            cell?.textField?.stringValue = (deviceItem?.name)!
        }
        else {
            cell?.textField?.stringValue = (deviceItem?.udid)!
        }
        return cell;
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        let selectedRow = devicesTableView?.selectedRow
        if (selectedRow != nil) {
            let storyboard = NSStoryboard(name: "Main", bundle: nil)
            let item = self.viewModel?.deviceItems[selectedRow!]
            if (item != nil) {
                let viewController = storyboard.instantiateControllerWithIdentifier("ApplicationsViewController") as? ApplicationsViewController
                let viewModel = ApplicationsViewModel(deviceItem: item!)
                viewController?.viewModel = viewModel
                view.window?.contentViewController = viewController
            }
        }
    }
    
    // #MARK: - NSTableViewDataSource
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return (viewModel?.deviceItems.count)!
    }
}

