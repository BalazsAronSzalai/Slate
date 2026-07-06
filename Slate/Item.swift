//
//  Item.swift
//  Slate
//
//  Created by Szalai Balázs Áron on 2026. 07. 06..
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
