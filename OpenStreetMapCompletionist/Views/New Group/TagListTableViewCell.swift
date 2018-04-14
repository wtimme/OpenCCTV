//
//  TagListTableViewCell.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/14/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import UIKit

import SDWebImage

class TagListTableViewCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet var thumbnailImageViewWidthConstraint: NSLayoutConstraint!
    
    private let preferredImageViewWidth: CGFloat = 88
    private let imageViewMarginRight: CGFloat = 6
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        descriptionTextView.textContainerInset = UIEdgeInsets.zero
        descriptionTextView.textContainer.lineFragmentPadding = 0
    }

    func update(tag: Tag) {
        titleLabel.text = tag.tag
        descriptionTextView.text = tag.description
        descriptionTextView.backgroundColor = UIColor.green
        
        thumbnailImageView.sd_setImage(with: tag.thumbnailImageURL(width: preferredImageViewWidth)) { (image, _, _, _) in
            self.updateWithDownloadedThumbnailImage(image)
        }
    }
    
    private func updateWithDownloadedThumbnailImage(_ image: UIImage?) {
        if image != nil {
            // Let the text of the text view "float" around the image.
            var convertedImageViewFrame = self.convert(thumbnailImageView.frame, to: descriptionTextView)
            convertedImageViewFrame.size.width += imageViewMarginRight
            let imagePath = UIBezierPath(rect: convertedImageViewFrame)
            descriptionTextView.textContainer.exclusionPaths = [imagePath]
            
            thumbnailImageViewWidthConstraint.constant = preferredImageViewWidth
        } else {
            descriptionTextView.textContainer.exclusionPaths = []
            
            var textViewFrame = descriptionTextView.frame
            textViewFrame.size.height = descriptionTextView.intrinsicContentSize.height
            descriptionTextView.frame = textViewFrame
            
            layoutIfNeeded()
            
            thumbnailImageViewWidthConstraint.constant = 0
        }
    }

}
