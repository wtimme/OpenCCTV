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

        image = UIImage(bgIcon: .mapicons(.squarePin),
                        bgTextColor: .annotationBackgroundColor,
                        bgBackgroundColor: .annotationBackgroundColor,
                        topIcon: .mapicons(.bicycling),
                        topTextColor: .annotationForegroundColor,
                        bgLarge: true,
                        size: CGSize(width: NodeAnnotationView.annotationDimension, height: NodeAnnotationView.annotationDimension))
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
