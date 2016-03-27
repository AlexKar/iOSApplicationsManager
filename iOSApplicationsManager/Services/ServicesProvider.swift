//
//  ServicesProvider.swift
//  iOSApplicationsManager
//
//  Created by Aleksandr Karimov on 20.03.16.
//  Copyright © 2016 AlexKar. All rights reserved.
//

import Foundation

class ServicesProvider {
    static let sharedProvider = ServicesProvider()
    
    let mobileDeviceService = MobileDeviceService()
    private init() {}
}