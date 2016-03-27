//
//  DevicesViewModel.swift
//  iOSApplicationsManager
//
//  Created by Aleksandr Karimov on 20.03.16.
//  Copyright © 2016 AlexKar. All rights reserved.
//

import Foundation

struct DeviceItem {
    let name: String?
    let udid: String!
}

protocol DevicesViewModelDelegate : class {
    func didChangeDeviceItems(viewModel: DevicesViewModel) -> Void;
}

class DevicesViewModel : MobileDeviceServiceDelegate {

    private let mobileDeviceService: MobileDeviceService?
    private var items = [DeviceItem]()
    
    weak var delegate: DevicesViewModelDelegate?
    
    var deviceItems : [DeviceItem] {
        return items
    }
    
    init() {
        mobileDeviceService = ServicesProvider.sharedProvider.mobileDeviceService
        mobileDeviceService?.addDelegate(self)
    }
    
    deinit {
        mobileDeviceService?.removeDelegate(self)
    }
    
    // #MARK - MobileDeviceServiceDelegate
    
    func mobileDeviceService(service: MobileDeviceService, didAddDeviceWithId identifier: String) -> Void {
        let device = service.deviceWithId(identifier)
        if (device != nil) {
            let deviceItem = DeviceItem(name: device!.deviceName, udid: device!.udid)
            items.append(deviceItem)
            delegate?.didChangeDeviceItems(self)
        }
    }
    
    func mobileDeviceService(service: MobileDeviceService, didRemoveDeviceWithId identifier: String) -> Void {
        let device = service.deviceWithId(identifier)
        if (device != nil) {
            let index = items.indexOf({ (item) -> Bool in
                item.udid == identifier
            })
            if (index != nil) {
                items.removeAtIndex(index!)
                delegate?.didChangeDeviceItems(self)
            }
        }
    }
}