//
//  TLYCollectionViewController.m
//  TLYShyNavBarDemo
//
//  Created by Mazyad Alabduljaleel on 10/20/15.
//  Copyright © 2015 Telly, Inc. All rights reserved.
//

#import "TLYCollectionViewController.h"

@interface TLYCollectionViewController ()

@property (nonatomic, strong) NSArray *data;

@end

@implementation TLYCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.data = @[@"No Game No Life",
                  @"Ookami Kodomo no Ame to Yuki",
                  @"Owari no Seraph",
                  @"Prince of Tennis",
                  @"Psycho-Pass",
                  @"Psycho-Pass 2",
                  @"School Rumble",
                  @"Sen to Chihiro no Kamikakushi",
                  @"Shijou Saikyou no Deshi Kenichi",
                  @"Shingeki no Kyojin",
                  @"Soul Eater",
                  @"Steins;Gate",
                  @"Summer Wars",
                  @"Sword Art Online",
                  @"Sword Art Online II",
                  @"Tenkuu no Shiro Laputa",
                  @"Toki wo Kakeru Shoujo",
                  @"Tokyo Ghoul",
                  @"Tonari no Totoro",
                  @"Uchuu Kyoudai",
                  @"Yakitate!! Japan",
                  @"Zankyou ",
                  ];
    
    UIView *view = view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 40.f)];
    view.backgroundColor = [UIColor redColor];
    
    
    /* Library code */
    self.shyNavBarManager.scrollView = self.collectionView;
    /* Can then be remove by setting the ExtensionView to nil */
    [self.shyNavBarManager setExtensionView:view];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    UILabel *label = (id)[cell viewWithTag:777];
    label.text = self.data[indexPath.item];
    
    return cell;
}

@end
