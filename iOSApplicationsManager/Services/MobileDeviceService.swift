//
//  MobileDeviceService.swift
//  iOSApplicationsManager
//
//  Created by Aleksandr Karimov on 20.03.16.
//  Copyright © 2016 AlexKar. All rights reserved.
//

import Foundation

protocol MobileDeviceServiceDelegate : class {
    func mobileDeviceService(service: MobileDeviceService, didAddDeviceWithId identifier: String) -> Void
    func mobileDeviceService(service: MobileDeviceService, didRemoveDeviceWithId identifier: String) -> Void
}

class MobileDeviceService : MobileDeviceAccessListener, AMInstallationProxyDelegate {
    typealias CompletionBlock = () -> Void
    private var connectedDevices = [String : AMDevice]()
    private var delegates = NSHashTable.weakObjectsHashTable()
    private var installationProxiesCallbacks = [String : [CompletionBlock]]()

    var connectedDevicesIds : [String] {
        return Array(connectedDevices.keys)
    }

    //# MARK: - Init
    init() {
        MobileDeviceAccess.singleton().setListener(self)
    }
    
    deinit {
        MobileDeviceAccess.singleton().setListener(nil)
    }

    //# MARK: - Public
    func addDelegate(delegate: MobileDeviceServiceDelegate) -> Void {
        delegates.addObject(delegate)
    }
    
    func removeDelegate(delegate: MobileDeviceServiceDelegate) -> Void {
        delegates.removeObject(delegate)
    }
    
    func deviceWithId(identifier : String) -> AMDevice? {
        return connectedDevices[identifier]
    }

    func disconnectDeviceWithId(identifier : String) -> Void {
        let device = deviceWithId(identifier)
        if (device != nil) {
            MobileDeviceAccess.singleton().detachDevice(device)
        }
    }
    
    func applicationIdsForDeviceWithId(identifier : String) -> [String]? {
        let device = deviceWithId(identifier)
        var applications = [String]()
        for application in (device?.installedApplications())! {
            let bundleId = (application as? AMApplication)?.bundleid()
            if (bundleId != nil) {
                applications.append(bundleId!)
            }
        }
        return applications
    }
    
    func applicationsForDeviceWithId(identifier : String) -> [AMApplication]? {
        let device = deviceWithId(identifier)
        var applications = [AMApplication]()
        for application in (device?.installedApplications())! {
            applications.append(application as! AMApplication)
        }
        return applications
    }
    
    func applicationForDeviceWithId(identifier: String, bundleId: String) -> AMApplication? {
        let device = deviceWithId(identifier)
        return device?.installedApplicationWithId(bundleId)
    }
    
    func archiveApplicationForDeviceWithId(identifier: String, bundleId: String, completion: CompletionBlock?) -> Void {
        let device = deviceWithId(identifier)
        if (device == nil) {
            if (completion != nil) {
                completion!()
            }
            return
        }
        let identifier = "Archive_\(bundleId)"
        var completions = installationProxiesCallbacks[identifier]
        if (completions == nil) {
            completions = [CompletionBlock]()
            let installationProxy = device!.newAMInstallationProxyWithDelegate(self)
            if (completion != nil) {
                completions?.append(completion!)
            }
            installationProxiesCallbacks[identifier] = completions
            installationProxy.archive(bundleId, container: true, payload: true, uninstall: true)
        }
        else {
            if (completion != nil) {
                completions?.append(completion!)
                installationProxiesCallbacks[identifier] = completions
            }
        }
    }
    
    func restoreApplicationForDeviceWithId(identifier: String, bundleId: String, completion: CompletionBlock?) -> Void {
        let device = deviceWithId(identifier)
        if (device == nil) {
            if (completion != nil) {
                completion!()
            }
            return
        }
        let identifier = "Restore_\(bundleId)"
        var completions = installationProxiesCallbacks[identifier]
        if (completions == nil) {
            completions = [CompletionBlock]()
            let installationProxy = device!.newAMInstallationProxyWithDelegate(self)
            if (completion != nil) {
                completions?.append(completion!)
            }
            installationProxiesCallbacks[identifier] = completions
            installationProxy.restore(bundleId)
        }
        else {
            if (completion != nil) {
                completions?.append(completion!)
                installationProxiesCallbacks[identifier] = completions
            }
        }
    }

    //# MARK: - MobileDeviceAccessListener
    @objc func deviceConnected(device: AMDevice!) {
        connectedDevices[device.udid] = device
        enumerateDelegatesWithBlock { (delegate) -> Void in
            delegate.mobileDeviceService(self, didAddDeviceWithId: device.udid)
        }
    }

    @objc func deviceDisconnected(device: AMDevice!) {
        connectedDevices.removeValueForKey(device.udid)
        enumerateDelegatesWithBlock { (delegate) -> Void in
            delegate.mobileDeviceService(self, didRemoveDeviceWithId: device.udid)
        }
    }
    
    //# MARK: - AMInstallationProxyDelegate
    @objc func operationCompleted(info: [NSObject : AnyObject]!) {
        let operation = info["Command"]
        let bundleId = info["ApplicationIdentifier"]
        if (operation == nil || bundleId == nil) {
            return
        }
        let identifier = "\(operation!)_\(bundleId!)"
        let completions = installationProxiesCallbacks[identifier]
        if (completions != nil) {
            installationProxiesCallbacks.removeValueForKey(identifier)
            for completion in completions! {
                completion()
            }
        }
    }
    
    //# MARK: - Private
    private func enumerateDelegatesWithBlock(block: (delegate: MobileDeviceServiceDelegate) -> Void) -> Void {
        for delegate in delegates.allObjects {
            block(delegate: delegate as! MobileDeviceServiceDelegate)
        }
    }
}