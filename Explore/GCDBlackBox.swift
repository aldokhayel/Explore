//
//  GCDBlackBox.swift
//  FlickrFinder
//
//  Created by Abdulrahman on 09/12/2018.
//  Copyright © 2018 Abdulrahman. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
