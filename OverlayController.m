/* (c) 2009 eBay Inc. */

#import "OverlayController.h"
#if defined(RL_LOCALIZED)
#import "Localization.h"
#endif

@implementation OverlayController

- (void)barcodePickerController:(BarcodePickerController*)picker statusUpdated:(NSDictionary*)status
{
	// In the status dictionary:
	
	// "FoundBarcodes" key is a NSSet of all discovered barcodes this scan session
	// "NewFoundBarcodes" is a NSSet of barcodes discovered in the most recent pass.
		// When a barcode is found, it is added to both sets. The NewFoundBarcodes
		// set is cleaned out each pass.
	
	// "Guidance" can be used to help guide the user through the process of discovering
	// a long barcode in sections. Currently only works for Code 39.
	
	// "Valid" is TRUE once there are valid barcode results.
	// "InRange" is TRUE if there's currently a barcode detected the viewfinder. The barcode
	//		may not have been decoded yet.
	
	
	BOOL isValid = [(NSNumber*)[status objectForKey:@"Valid"] boolValue];
	BOOL inRange = [(NSNumber*)[status objectForKey:@"InRange"] boolValue];
	
	// Make the RedLaser stripe more vivid when Barcode is in Range.
	if (inRange)
	{
		_rectLayer.strokeColor = [[UIColor greenColor] CGColor];
	}
	else
	{
		_rectLayer.strokeColor = [[UIColor whiteColor] CGColor];
	}
	
	if (isValid)
	{
		[self beepOrVibrate];
		
		// Try to make sure we don't dismiss the modal controller before it's done
		// animating into view.
		if (viewHasAppeared)
			[self.parentPicker doneScanning];
	}
	
	int guidanceLevel = [[status objectForKey:@"Guidance"] intValue];
	if (guidanceLevel == 1)
	{
		textCue.text = @"Try moving the camera close to each part of the barcode";
	} else if (guidanceLevel == 2)
	{
		textCue.text = [status objectForKey:@"PartialBarcode"];
	} else 
	{
		textCue.text = @"";
	}
}

// Checks if the phone is in vibrate mode, in which case the scanner
// vibrates instead of beeps.

-(void)beepOrVibrate
{
	if (successSoundPlayed)
		return;
	successSoundPlayed = true;

	if (!_isSilent)
	{
		UInt32 routeSize = sizeof (CFStringRef);
		CFStringRef route = NULL;
		AudioSessionGetProperty (kAudioSessionProperty_AudioRoute, &routeSize, &route);
		
		if (CFStringGetLength(route) == 0) 
		{
			AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
		} else 
		{
			AudioServicesPlaySystemSound(_scanSuccessSound);
		}
	}
}

-(IBAction)cancelPressed
{
	if(self.parentPicker != nil)
	{
		// Tell the picker we're done
		[self.parentPicker doneScanning];
	}
}

-(IBAction)flashPressed 
{
	if ([flashButton style] == UIBarButtonItemStyleBordered) 
	{
		[flashButton setStyle:UIBarButtonItemStyleDone];
		[self.parentPicker turnFlash:YES];
	} 
	else 
	{
		[flashButton setStyle:UIBarButtonItemStyleBordered];
		[self.parentPicker turnFlash:NO];
	}
}

// Optionally, you can change the active scanning region.
// The region specified below is the default, and lines up
// with the default overlay.  It is recommended to keep the
// active region similar in size to the default region.
// Additionally, the iPhone 3GS may not focus as well if
// the region is too far away from center.
//
// In portrait mode only the top and bottom of this rectangle
// is used. The x-position and width specified are ignored.


- (void) setPortraitLayout
{
	// Set portrait
	self.parentPicker.orientation = UIImageOrientationUp;
	
	// Set the active scanning region for portrait mode
	[self.parentPicker setActiveRegion:CGRectMake(0, 100, 320, 250)];
	
	// Animate the UI changes
	CGAffineTransform transform = CGAffineTransformMakeRotation(0);
	//self.view.transform = transform;
	
	[UIView beginAnimations:@"rotateToPortrait" context:nil]; // Tell UIView we're ready to start animations.
	[UIView setAnimationDelegate:self];
	//[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[UIView setAnimationCurve: UIViewAnimationCurveLinear ];
	[UIView setAnimationDuration: 0.5];
	
	redlaserLogo.transform = transform;
	
	[self setActiveRegionRect];
	
	[UIView commitAnimations]; // Animate!
}

- (void) setLandscapeLayout
{
	// Set landscape
	self.parentPicker.orientation = UIImageOrientationRight;
	
	// Set the active scanning region for landscape mode
	[self.parentPicker setActiveRegion:CGRectMake(100, 0, 120, 436)];
	
	// Animate the UI changes
	CGAffineTransform transform = CGAffineTransformMakeRotation(3.14159/2);
	//self.view.transform = transform;
	
	//[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	
	[UIView beginAnimations:@"rotateToLandscape" context:nil]; // Tell UIView we're ready to start animations.
	[UIView setAnimationDelegate:self];
	//[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[UIView setAnimationCurve: UIViewAnimationCurveLinear ];
	[UIView setAnimationDuration: 0.5];
	
	redlaserLogo.transform = transform;
	
	[self setActiveRegionRect];
	
	[UIView commitAnimations]; // Animate!
}

- (IBAction) rotatePressed
{
	// Swap the orientation
	if (self.parentPicker.orientation == UIImageOrientationUp)
	{
		[self setLandscapeLayout];
	}
	else 
	{
		[self setPortraitLayout];
	}
}

- (CGMutablePathRef)newRectPathInRect:(CGRect)rect 
{
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathAddRect(path, NULL, rect);
	return path;
}

- (void) setActiveRegionRect
{
	[_rectLayer setFrame:CGRectMake(self.parentPicker.activeRegion.origin.x, 
									self.parentPicker.activeRegion.origin.y, 
									self.parentPicker.activeRegion.size.width, 
									self.parentPicker.activeRegion.size.height)];
	
	CGPathRef path = [self newRectPathInRect:_rectLayer.bounds];
	[_rectLayer setPath:path];
	CGPathRelease(path);
	[_rectLayer needsLayout];
}

- (void)viewDidLoad 
{
    [self.navigationController setNavigationBarHidden:YES];
    
    [super viewDidLoad];
	isGreen = FALSE;
	
	// Create active region rectangle
	_rectLayer = [[CAShapeLayer layer] retain];
	_rectLayer.fillColor = [[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.2] CGColor];
	_rectLayer.strokeColor = [[UIColor whiteColor] CGColor];
	_rectLayer.lineWidth = 3;
	_rectLayer.anchorPoint = CGPointZero;
	[self.view.layer addSublayer:_rectLayer];
	
	self->_isSilent = [[NSUserDefaults standardUserDefaults] boolForKey:@"silent_pref"];
		
	if(!_isSilent) // If silent, no need to do this.
	{
		NSURL* aFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"beep" ofType:@"wav"] isDirectory:NO]; 
		AudioServicesCreateSystemSoundID((CFURLRef)aFileURL, &_scanSuccessSound);
		
		UInt32 flag = 0;
		OSStatus error = AudioServicesSetProperty(kAudioServicesPropertyIsUISound,
												  sizeof(UInt32),
												  &_scanSuccessSound,
												  sizeof(UInt32),
												  &flag);
		
		float aBufferLength = 1.0; // In seconds
		error = AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, 
								sizeof(aBufferLength), &aBufferLength);
		
		/* Create and warm up an audio session */
		AudioSessionInitialize(NULL, NULL, NULL, NULL);
		AudioSessionSetActive(TRUE);
	}
}

- (void)viewDidUnload 
{
		
	AudioServicesDisposeSystemSoundID(_scanSuccessSound);
	if(!_isSilent) { AudioSessionSetActive(FALSE); }
}

- (void)viewWillAppear:(BOOL)animated
{
	if (self.parentPicker.orientation == UIImageOrientationUp)
	{
		[self setPortraitLayout];
	}
	else 
	{
		[self setLandscapeLayout];
	}
	
	if (![self.parentPicker hasFlash]) 
	{
		[flashButton setEnabled:NO];
		NSMutableArray * items = [[toolBar items] mutableCopy];
		[items removeObject:flashButton];
		[toolBar setItems:items animated:NO];
		[items release];
	}else
	{
		[flashButton setEnabled:YES];
		[flashButton setStyle:UIBarButtonItemStyleBordered];
	}

	textCue.text = @"";
	successSoundPlayed = false;
}

- (void) viewDidAppear:(BOOL)animated
{
	viewHasAppeared = YES;
}

- (void) viewDidDisappear:(BOOL)animated
{
	viewHasAppeared = NO;
}

- (void)dealloc 
{
    [super dealloc];
}

@end
