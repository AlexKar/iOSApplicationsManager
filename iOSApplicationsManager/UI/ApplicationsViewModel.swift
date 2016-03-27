//
//  ApplicationsViewModel.swift
//  iOSApplicationsManager
//
//  Created by Aleksandr Karimov on 20.03.16.
//  Copyright © 2016 AlexKar. All rights reserved.
//

import Foundation

struct ApplicationItem {
    let name: String
    let bundleId: String
}

protocol ApplicationsViewModelDelegate : class {
    func didChangeApplicationItems(viewModel: ApplicationsViewModel) -> Void
    func shouldShowProgress(viewModel: ApplicationsViewModel) -> Void
    func shouldHideProgress(viewModel: ApplicationsViewModel) -> Void
}

class ApplicationsViewModel {
    let deviceItem: DeviceItem
    weak var delegate: ApplicationsViewModelDelegate?
    
    private let mobileDeviceService: MobileDeviceService?
    private var items = [ApplicationItem]()
    private var operationIsInProgress: Bool = false
    
    var applicationItems : [ApplicationItem] {
        return items
    }
    
    init(deviceItem: DeviceItem) {
        self.deviceItem = deviceItem
        mobileDeviceService = ServicesProvider.sharedProvider.mobileDeviceService
        refresh(shouldNotify: false)
    }
    
    func refresh() -> Void {
        refresh(shouldNotify: true)
    }
    
    func archiveApplicationItems(items: [ApplicationItem]) -> Void {
        if (items.count == 0 || operationIsInProgress) {
            return;
        }
        delegate?.shouldShowProgress(self)
        operationIsInProgress = true
        internalOperationWithApplicationItems(items) { (item, completion) -> Void in
            self.mobileDeviceService?.archiveApplicationForDeviceWithId(self.deviceItem.udid, bundleId:item.bundleId, completion:completion)
        }
    }
    
    func restoreApplicationItems(items: [ApplicationItem]) -> Void {
        if (items.count == 0 || operationIsInProgress) {
            return;
        }
        delegate?.shouldShowProgress(self)
        operationIsInProgress = true
        internalOperationWithApplicationItems(items) { (item, completion) -> Void in
            self.mobileDeviceService?.restoreApplicationForDeviceWithId(self.deviceItem.udid, bundleId:item.bundleId, completion:completion)
        }
    }
    
    // #MARK - private
    private func internalOperationWithApplicationItems(items: [ApplicationItem], operation: (item: ApplicationItem, completion: () -> Void) -> Void) -> Void {
        let item = items.first
        if (item != nil) {
            operation(item: item!) { () -> Void in
                var modifiedItems = items
                modifiedItems.removeFirst()
                self.internalOperationWithApplicationItems(modifiedItems, operation: operation)
            }
        }
        else {
            operationIsInProgress = false
            delegate?.shouldHideProgress(self)
        }
    }
    
    private func refresh(shouldNotify notify: Bool) -> Void {
        let applications = mobileDeviceService?.applicationsForDeviceWithId(deviceItem.udid)
        if (applications == nil) {
            return;
        }
        var items = [ApplicationItem]()
        for application in applications! {
            let applicationItem = ApplicationItem(name: application.appname(), bundleId: application.bundleid())
            items.append(applicationItem)
        }
        self.items = items
        if (notify) {
            delegate?.didChangeApplicationItems(self)
        }
    }
    
}