//
//  MediaCell.h
//  ASMediaFocusExemple
//
//  Created by Philippe Converset on 31/03/2015.
//  Copyright (c) 2015 AutreSphere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FLAnimatedImage/FLAnimatedImageView.h>

@interface MediaCell : UITableViewCell

@property (strong, nonatomic) IBOutlet FLAnimatedImageView *thumbnailView;
@property (strong, nonatomic) IBOutlet UIImageView *playView;

+ (MediaCell *)mediaCell;

@end
