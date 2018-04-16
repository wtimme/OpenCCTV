//
//  NodeAnnotationView.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/8/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import MapKit

import SwiftIcons

class NodeAnnotationView: MKAnnotationView {
    static let reuseIdentifier = "NodeAnnotationView"
    static let annotationDimension: CGFloat = 30

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        image = UIImage(icon: .mapicons(MapiconsType.bicycling),
                        size: CGSize(width: NodeAnnotationView.annotationDimension, height: NodeAnnotationView.annotationDimension))
        
        backgroundColor = UIColor(red: 57/255, green: 42/255, blue: 89/255, alpha: 0.1)
        layer.cornerRadius = 4.0
        layer.borderColor = UIColor(white: 0.1, alpha: 0.8).cgColor
        layer.borderWidth = 0.5
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
