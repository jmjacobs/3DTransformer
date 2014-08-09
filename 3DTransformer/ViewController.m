//
//  ViewController.m
//  3DTransformer
//
//  Created by Joshua Jacobs on 25/07/2014.
//  Copyright (c) 2014 Joshua Jacobs. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UISlider *xRotate;
@property (weak, nonatomic) IBOutlet UISlider *yRotate;
@property (weak, nonatomic) IBOutlet UISlider *zRotate;

@property (weak, nonatomic) IBOutlet UISlider *xScale;
@property (weak, nonatomic) IBOutlet UISlider *yScale;
@property (weak, nonatomic) IBOutlet UISlider *zScale;

@property (weak, nonatomic) IBOutlet UISlider *xTranslation;
@property (weak, nonatomic) IBOutlet UISlider *yTranslation;
@property (weak, nonatomic) IBOutlet UISlider *zTranslation;

@property (weak, nonatomic) IBOutlet UILabel *xRotateLabel;
@property (weak, nonatomic) IBOutlet UILabel *yRotateLabel;
@property (weak, nonatomic) IBOutlet UILabel *zRotateLabel;
@property (weak, nonatomic) IBOutlet UILabel *xScaleLabel;
@property (weak, nonatomic) IBOutlet UILabel *yScaleLabel;
@property (weak, nonatomic) IBOutlet UILabel *zScaleLabel;
@property (weak, nonatomic) IBOutlet UILabel *xTranslationLabel;
@property (weak, nonatomic) IBOutlet UILabel *yTranslationLabel;
@property (weak, nonatomic) IBOutlet UILabel *zTranslationLabel;
@property (weak, nonatomic) IBOutlet UILabel *perspectiveLabel;
@property (weak, nonatomic) IBOutlet UILabel *animationLengthLabel;
@property (weak, nonatomic) IBOutlet UILabel *opacityLabel;

@property (weak, nonatomic) IBOutlet UISlider *opacitySlider;
@property (weak, nonatomic) IBOutlet UISlider *animationLength;
@property (weak, nonatomic) IBOutlet UIView *AView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UISlider *perspectiveSlider;
@property (weak, nonatomic) IBOutlet UISegmentedControl *keyframeSegments;

@property NSMutableArray *transformKeyframeArray;
@property NSMutableArray *opacityKeyframeArray;
@property NSMutableArray *sliderValuesArray;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // INITIALISE KEYFRAME ARRAYS AND UPDATE VIEW LABELS
    self.transformKeyframeArray = [[NSMutableArray alloc] init];
    self.opacityKeyframeArray = [[NSMutableArray alloc] init];
    self.sliderValuesArray = [[NSMutableArray alloc] init];
    [self updateLabelValues];
    self.backgroundView.layer.cornerRadius = 10.0;
    [self.keyframeSegments removeAllSegments];
    self.keyframeSegments.hidden = YES;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [self setAnchorPoint:CGPointMake(0.5, 0.5) forView:self.AView];
}

- (IBAction)transformView:(id)sender {

    // CREATE A TRANSFORM OF ALL THE SLIDER VALUES AND APPLY THIS TO THE VIEW
    CATransform3D transform;
    CATransform3D transformIdentity = CATransform3DIdentity;
    
    CATransform3D transformX =	CATransform3DRotate(transformIdentity, self.xRotate.value * (float)M_PI / 180.0f, 1, 0, 0);
    CATransform3D transformY =	CATransform3DRotate(transformIdentity, self.yRotate.value * (float)M_PI / 180.0f, 0, 1, 0);
    CATransform3D transformZ =	CATransform3DRotate(transformIdentity, self.zRotate.value * (float)M_PI / 180.0f, 0, 0, 1);
    CATransform3D scale = CATransform3DScale(transformIdentity, self.xScale.value, self.yScale.value, self.zScale.value);
    CATransform3D translate = CATransform3DTranslate(transformIdentity, self.xTranslation.value, self.yTranslation.value, self.zTranslation.value);
    
    transform = CATransform3DConcat(transformX, transformY);
    transform = CATransform3DConcat(transform, transformZ);
    transform = CATransform3DConcat(transform, scale);
    transform = CATransform3DConcat(transform, translate);
    
    self.AView.layer.opacity = self.opacitySlider.value;
    self.AView.layer.transform = transform;
    
    [self updateLabelValues];
    
}

- (IBAction)perspectiveSwitched:(id)sender {
    
    // ADD A PERSPECTIVE TO ALL SUBLAYERS ON THE VIEWCONTROLLERS VIEW
    CATransform3D perspective = CATransform3DIdentity;
    perspective.m34 = (self.perspectiveSlider.value / 100.f);
    self.view.layer.sublayerTransform = perspective;
    
    [self updateLabelValues];

}

- (IBAction)addKeyframe:(id)sender {
    
    // ADD TRANSFORM AND OPACITY VALUES TO THEIR RESPECTIVE ARRAYS
    [self.transformKeyframeArray addObject:[NSValue valueWithCATransform3D:self.AView.layer.transform]];
    [self.opacityKeyframeArray addObject:[NSNumber numberWithFloat:self.opacitySlider.value]];
    
    // ADD AN ARRAY OF ALL THE SLIDER VALUES FOR EACH KEYFRAME
    [self.sliderValuesArray addObject:@[[NSNumber numberWithFloat:self.xRotate.value],[NSNumber numberWithFloat:self.yRotate.value],[NSNumber numberWithFloat:self.zRotate.value],[NSNumber numberWithFloat:self.xScale.value],[NSNumber numberWithFloat:self.yScale.value],[NSNumber numberWithFloat:self.zScale.value],[NSNumber numberWithFloat:self.xTranslation.value],[NSNumber numberWithFloat:self.yTranslation.value],[NSNumber numberWithFloat:self.zTranslation.value],[NSNumber numberWithFloat:self.opacitySlider.value],[NSNumber numberWithFloat:self.perspectiveSlider.value]]];
    
    // AMEND THE SEGMENTED CONTROL TO MATCH THE KEYFRAMES
    NSUInteger numberOfFrames = self.sliderValuesArray.count;
    [self.keyframeSegments insertSegmentWithTitle:[NSString stringWithFormat:@"%lu",(unsigned long)numberOfFrames] atIndex:numberOfFrames animated:YES];
    self.keyframeSegments.selectedSegmentIndex = numberOfFrames - 1;
    self.keyframeSegments.hidden = NO;
}

- (IBAction)beginAnimation:(id)sender {
    
    // TRANSFORM ANIMATION
    CAKeyframeAnimation * transformAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    transformAnimation.duration = self.animationLength.value;
    transformAnimation.values = self.transformKeyframeArray;
    
    self.AView.layer.transform = [[transformAnimation.values lastObject] CATransform3DValue];
    [self.AView.layer addAnimation:transformAnimation forKey:kCATransition];
    
    // OPACITY ANIMATION
    CAKeyframeAnimation * opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    
    opacityAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    opacityAnimation.duration = self.animationLength.value;
    opacityAnimation.values = self.opacityKeyframeArray;
    
    self.AView.layer.opacity = [[opacityAnimation.values lastObject] floatValue];
    [self.AView.layer addAnimation:opacityAnimation forKey:@"opacityAnimation"];
    
}

- (IBAction)resetView:(id)sender {
    
    // RESET ALL THE SLIDER VALUES BACK TO THE DEFAULTS AND CLEAR THE ARRAYS
    self.AView.layer.transform = CATransform3DIdentity;
    self.xTranslation.value = self.yTranslation.value = self.zTranslation.value = 0.0;
    self.xRotate.value = self.yRotate.value = self.zRotate.value = 0.0;
    self.xScale.value = self.yScale.value = self.zScale.value = 1.0;
    self.perspectiveSlider.value = 0.0;
    self.animationLength.value = 1.0;
    
    [self updateLabelValues];
    [self.transformKeyframeArray removeAllObjects];
    [self.opacityKeyframeArray removeAllObjects];
    [self.sliderValuesArray removeAllObjects];
    
    
    // HIDE SEGMENTED CONTROL AND RESET IT BACK ITS DEFAULT
    self.keyframeSegments.hidden = YES;
    [self.keyframeSegments removeAllSegments];
    
    
}

- (IBAction)updateLabelValues
{
    // UPDATE ALL THE LABELS NEXT TO THE SLIDERS TO REPRESENT THE CURRENT VALUES
    self.xRotateLabel.text = [NSString stringWithFormat:@"%.0fº", self.xRotate.value];
    self.yRotateLabel.text = [NSString stringWithFormat:@"%.0fº", self.yRotate.value];
    self.zRotateLabel.text = [NSString stringWithFormat:@"%.0fº", self.zRotate.value];
    
    self.xScaleLabel.text = [NSString stringWithFormat:@"%.1f", self.xScale.value];
    self.yScaleLabel.text = [NSString stringWithFormat:@"%.1f", self.yScale.value];
    self.zScaleLabel.text = [NSString stringWithFormat:@"%.1f", self.zScale.value];
    
    self.xTranslationLabel.text = [NSString stringWithFormat:@"%.0f", self.xTranslation.value];
    self.yTranslationLabel.text = [NSString stringWithFormat:@"%.0f", self.yTranslation.value];
    self.zTranslationLabel.text = [NSString stringWithFormat:@"%.0f", self.zTranslation.value];
    
    self.animationLengthLabel.text = [NSString stringWithFormat:@"%.1f", self.animationLength.value];
    self.perspectiveLabel.text = [NSString stringWithFormat:@"%.1f", self.perspectiveSlider.value];
    self.opacityLabel.text = [NSString stringWithFormat:@"%.2f", self.opacitySlider.value];
}

- (IBAction)segmentChanged:(id)sender {
    
    NSArray *sliderValues = self.sliderValuesArray[self.keyframeSegments.selectedSegmentIndex];
    
    self.xRotate.value = [sliderValues[0] floatValue];
    self.yRotate.value = [sliderValues[1] floatValue];
    self.zRotate.value = [sliderValues[2] floatValue];
    self.xScale.value = [sliderValues[3] floatValue];
    self.yScale.value = [sliderValues[4] floatValue];
    self.zScale.value = [sliderValues[5] floatValue];
    self.xTranslation.value = [sliderValues[6] floatValue];
    self.yTranslation.value = [sliderValues[7] floatValue];
    self.zTranslation.value = [sliderValues[8] floatValue];
    self.opacitySlider.value = [sliderValues[9] floatValue];
    
    [self updateLabelValues];
    [self transformView:nil];

}

// METHOD TO MOVE THE LAYERS ANCHOR POINT WITHOUT EFFECTING ITS POSITION

-(void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view
{
    CGPoint newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x,
                                   view.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x,
                                   view.bounds.size.height * view.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);
    
    CGPoint position = view.layer.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    view.layer.position = position;
    view.layer.anchorPoint = anchorPoint;
}

@end
