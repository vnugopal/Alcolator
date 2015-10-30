//
//  ViewController.h
//  Alcolator
//
//  Created by Venugopal Narayanabhatla on 10/29/15.
//  Copyright © 2015 Venugopal Narayanabhatla. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController


@property (weak, nonatomic) IBOutlet UITextField *BeerPercentTextField;
@property (weak, nonatomic) IBOutlet UISlider *beerCountSlider;

@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
- (void)buttonPressed:(UIButton *)sender;

@end

