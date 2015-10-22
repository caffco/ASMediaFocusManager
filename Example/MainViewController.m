//
//  MainViewController.m
//  ASMediaFocusExample
//
//  Created by Philippe Converset on 21/12/12.
//  Copyright (c) 2012 AutreSphere. All rights reserved.
//

#import "MainViewController.h"
#import "MediaCell.h"
#import <QuartzCore/QuartzCore.h>
#import <FLAnimatedImage/FLAnimatedImage.h>

static CGFloat const kMaxAngle = 0.1;
static CGFloat const kMaxOffset = 20;

@interface MainViewController ()
@property (nonatomic, assign) BOOL statusBarHidden;
@property (nonatomic, strong) NSArray *mediaNames;
@end

@implementation MainViewController

+ (float)randomFloatBetween:(float)smallNumber andMax:(float)bigNumber
{
    float diff = bigNumber - smallNumber;
    
    return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
}

- (void)addSomeRandomTransformOnThumbnailViews
{
    for(UIView *view in self.imageViews)
    {
        CGFloat angle;
        NSInteger offsetX;
        NSInteger offsetY;
        
        angle = [MainViewController randomFloatBetween:-kMaxAngle andMax:kMaxAngle];
        offsetX = (NSInteger)[MainViewController randomFloatBetween:-kMaxOffset andMax:kMaxOffset];
        offsetY = (NSInteger)[MainViewController randomFloatBetween:-kMaxOffset andMax:kMaxOffset];
        view.transform = CGAffineTransformMakeRotation(angle);
        view.center = CGPointMake(view.center.x + offsetX, view.center.y + offsetY);
        
        // This is going to avoid crispy edges.
        view.layer.shouldRasterize = YES;
        view.layer.rasterizationScale = [UIScreen mainScreen].scale;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.mediaNames = @[@"1f.jpg", @"2f.jpg", @"3f.mp4", @"4f.jpg"];
    self.mediaFocusManager = [[ASMediaFocusManager alloc] init];
    self.mediaFocusManager.delegate = self;
    self.mediaFocusManager.elasticAnimation = YES;
    self.mediaFocusManager.focusOnPinch = YES;

    // Tells which views need to be focusable. You can put your image views in an array and give it to the focus manager.
    [self.mediaFocusManager installOnViews:self.imageViews];
    
    [self addSomeRandomTransformOnThumbnailViews];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    //return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
     return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)prefersStatusBarHidden
{
    return self.statusBarHidden;
}

#pragma mark - ASMediaFocusDelegate
- (UIViewController *)parentViewControllerForMediaFocusManager:(ASMediaFocusManager *)mediaFocusManager
{
    return self;
}

- (NSURL *)mediaFocusManager:(ASMediaFocusManager *)mediaFocusManager mediaURLForView:(UIView *)view
{
    NSString *name;
    NSInteger index;
    NSURL *url;
    
    if(self.tableView == nil)
    {
        index = ([self.imageViews indexOfObject:view]);
    }
    else
    {
        index = view.tag - 1;
    }
    
    name = self.mediaNames[index];
    url = [[NSBundle mainBundle] URLForResource:[name stringByDeletingPathExtension] withExtension:name.pathExtension];
    
    if ( index == 0 ) {
        url = [NSURL URLWithString:@"https://33.media.tumblr.com/07b00df16a910359a331e158b79dfa72/tumblr_nvuw1mFBzL1qharjqo1_500.gif"];
    }
    
    return url;
}

- (NSString *)mediaFocusManager:(ASMediaFocusManager *)mediaFocusManager titleForView:(UIView *)view;
{
    BOOL isVideo;
    NSURL *url;
    NSString *extension;
    
    url = [self mediaFocusManager:mediaFocusManager mediaURLForView:view];
    extension = url.pathExtension.lowercaseString;
    isVideo = [extension isEqualToString:@"mp4"] || [extension isEqualToString:@"mov"];
    
    return (isVideo?@"Videos are also supported.":@"Of course, you can zoom in and out on the image.");
}

- (void)mediaFocusManagerWillAppear:(ASMediaFocusManager *)mediaFocusManager
{
    self.statusBarHidden = YES;
    if([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)mediaFocusManagerWillDisappear:(ASMediaFocusManager *)mediaFocusManager
{
    self.statusBarHidden = NO;
    if([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"MediaCell";
    MediaCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSString *path;
    UIImage *image;
    BOOL isVideo;
    NSString *name;
    NSString *extension;
    
    if(cell == nil)
    {
        cell = [MediaCell mediaCell];
        cell.thumbnailView.tag = indexPath.row + 1;
        [self.mediaFocusManager installOnView:cell.thumbnailView];
    }
    
    name = self.mediaNames[indexPath.row];
    extension = name.pathExtension.lowercaseString;
    isVideo = ([extension isEqualToString:@"mp4"] || [extension isEqualToString:@"mov"]);
    cell.playView.hidden = !isVideo;
    path = [NSString stringWithFormat:@"%ld.jpg", (unsigned long)indexPath.row + 1];
    image = [UIImage imageNamed:path];
    if ( indexPath.row == 0 ) {
        [cell.thumbnailView setAnimatedImage:[FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://33.media.tumblr.com/07b00df16a910359a331e158b79dfa72/tumblr_nvuw1mFBzL1qharjqo1_500.gif"]]]];
    } else {
        cell.thumbnailView.image = image;
    }
    cell.thumbnailView.tag = indexPath.row + 1;
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mediaNames.count;
}
@end
