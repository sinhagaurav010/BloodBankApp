/* (c) 2009 eBay Inc. */

#import <UIKit/UIKit.h>
#import "RedLaserSDK.h"
#import "AudioToolbox/AudioServices.h"
#import <QuartzCore/QuartzCore.h>

@interface OverlayController : CameraOverlayViewController
{
	
	IBOutlet UILabel * textCue;
	
	IBOutlet UIImageView * redlaserLogo;
	
	BOOL isGreen;
	BOOL viewHasAppeared;
	BOOL successSoundPlayed;
	
	SystemSoundID _scanSuccessSound;
	BOOL _isSilent;
	
	IBOutlet UILabel * latestResultLabel;

	IBOutlet UIBarButtonItem *flashButton;
	IBOutlet UIToolbar *toolBar;
	IBOutlet UIBarButtonItem *cancelButton;
	
	// Rectangle
	CAShapeLayer *_rectLayer;
}

-(IBAction) cancelPressed;
-(IBAction) flashPressed;
-(IBAction) rotatePressed;
-(void) setLandscapeLayout;
-(void) setPortraitLayout;
-(void) beepOrVibrate;
- (CGMutablePathRef)newRectPathInRect:(CGRect)rect;
- (void) setActiveRegionRect;

@end
