/* (c) 2009 eBay Inc. */

#import "RLSampleViewController.h"
#import "OverlayController.h"
#import "RedLaserSDK.h"


@implementation RLSampleViewController

- (void) barcodePickerController:(BarcodePickerController*)picker returnResults:(NSSet *)results
{	
	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	
	// Restore main screen (and restore title bar for 3.0)
	if (!modalViewIsAppearing)
		[self dismissModalViewControllerAnimated:TRUE];
	modalViewIsAppearing = NO;
	
	// Note that it is possible to get multiple results discovered at the same time.
	// Even if you return as soon as you see result barcodes, there could be more than one.
	BarcodeResult *foundCode = [results anyObject];
	if (foundCode)
	{
		barcodeTextLabel.text = foundCode.barcodeString;

		int btype = foundCode.barcodeType;
		if (btype == kBarcodeTypeEAN13) 
		{ 
			// Use first digit to differentiate between EAN13 and UPCA
			// An EAN13 barcode whose first digit is zero is exactly the same as a UPCA barcode.
			if ([foundCode.barcodeString characterAtIndex:0] == '0') 
			{
				barcodeTextLabel.text = [foundCode.barcodeString substringFromIndex:1];
				typeLabel.text = @"UPC-A";
			}
			else
			{
				typeLabel.text = @"EAN-13";
			}			
		}
		else if (btype == kBarcodeTypeEAN8) typeLabel.text = @"EAN-8";
		else if (btype == kBarcodeTypeUPCE) typeLabel.text = @"UPC-E";
		else if (btype == kBarcodeTypeQRCODE) typeLabel.text = @"QR Code";
		else if (btype == kBarcodeTypeCODE128) typeLabel.text = @"Code 128";
		else if (btype == kBarcodeTypeCODE39) typeLabel.text = @"Code 39";
		else if (btype == kBarcodeTypeDATAMATRIX) typeLabel.text = @"Data Matrix";
		else if (btype == kBarcodeTypeITF) typeLabel.text = @"ITF";
		else if (btype == kBarcodeTypeSTICKY) typeLabel.text = @"STICKYBITS";
		
	}
}

-(IBAction) scanPressed
{	
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
	if (pickerController == nil)
	{
		pickerController = [[BarcodePickerController alloc] init];
				
		[pickerController setOverlay:overlayController];
		[pickerController setDelegate:self];
		
		// Initialize with portrait mode as default
		pickerController.orientation = UIImageOrientationUp;

		// The active scanning region size is set in OverlayController.m
	}
	
	// Update barcode on/off settings
	[pickerController setScanUPCE:[enableUPCESwitch isOn]];
	[pickerController setScanEAN8:[enableEAN8Switch isOn]];
	[pickerController setScanEAN13:[enableEAN13Switch isOn]];
	[pickerController setScanSTICKY:[enableSTICKYSwitch isOn]];
	[pickerController setScanQRCODE:[enableQRCodeSwitch isOn]];
	[pickerController setScanCODE128:[enableCode128Switch isOn]];
	[pickerController setScanCODE39:[enableCode39Switch isOn]];
	[pickerController setScanITF:[enableITFSwitch isOn]];
	
	// Data matrix decoding does not work very well so it is disabled for now
	[pickerController setScanDATAMATRIX:NO];
	
	// hide the status bar
//	[[UIApplication sharedApplication] setStatusBarHidden:YES];

	// Show the scanner view. Prefer the new 5.0 method if available.
	if ([[UIDevice currentDevice].systemVersion floatValue] < 4.99)
	{
		[self presentModalViewController:pickerController animated:TRUE];
	} else
	{
		modalViewIsAppearing = YES;
		[self presentViewController:pickerController animated:YES completion:
				^{ 
					if (!modalViewIsAppearing)
						[self dismissModalViewControllerAnimated:TRUE];
 					modalViewIsAppearing = NO; 
				}];
		
	}
}


@end
