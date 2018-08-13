//
//  Permission.swift
//  OSMSwift
//
//  Created by Wolfgang Timme on 6/26/18.
//

import Foundation

public enum Permission: String {
    public typealias RawValue = String
    
    case allow_read_prefs // Read user preferences
    case allow_write_prefs // Modify user preferences
    case allow_write_diary // Create diary entries, comments and make friends
    case allow_write_api // Modify the map
    case allow_read_gpx // Read private GPS traces
    case allow_write_gpx // Upload GPS traces
    case allow_write_notes // Modify notes
}
