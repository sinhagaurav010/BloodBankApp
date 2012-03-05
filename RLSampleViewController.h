/* (c) 2009 eBay Inc. */


#import <UIKit/UIKit.h>
#import "RedLaserSDK.h"
#import "OverlayController.h"

@interface RLSampleViewController : UIViewController <BarcodePickerControllerDelegate> {

	IBOutlet UILabel * barcodeTextLabel;
	IBOutlet UILabel * typeLabel;
	
	IBOutlet UISwitch * enableEAN8Switch;
	IBOutlet UISwitch * enableUPCESwitch;
	IBOutlet UISwitch * enableSTICKYSwitch;
	IBOutlet UISwitch * enableEAN13Switch;
	IBOutlet UISwitch * enableQRCodeSwitch;
	IBOutlet UISwitch * enableCode128Switch;
	IBOutlet UISwitch * enableCode39Switch;
	IBOutlet UISwitch * enableDataMatrixSwitch;
	IBOutlet UISwitch * enableITFSwitch;

	
	IBOutlet OverlayController 	* overlayController;
	BarcodePickerController		* pickerController;
	
	bool 						modalViewIsAppearing;
	
}

-(IBAction) scanPressed;

@end

