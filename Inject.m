// TODO: prevent volume change altogether
// TODO: use KVO AVAudioSession.outputVolume rather than private notification
// TODO: hide HUD pre-emptively rather than on first press

@import MediaPlayer;
@import AVFAudio.AVAudioSession;
@import Darwin.POSIX.dlfcn;

@interface Inject:NSObject
@end

void (*turnPage)(BOOL forward);
float prevVolume;
dispatch_once_t addSliderOnce;

@implementation Inject

+(void)load
{
	prevVolume=AVAudioSession.sharedInstance.outputVolume;
	
	turnPage=dlsym(RTLD_DEFAULT,"_BKAccessibilityTurnPage");
	
	// https://stackoverflow.com/a/59720724
	[NSNotificationCenter.defaultCenter addObserverForName:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil queue:nil usingBlock:^(NSNotification* notification)
	{
		dispatch_once(&addSliderOnce,^()
		{
			MPVolumeView* view=MPVolumeView.alloc.init;
			
			// hidden or alpha 0 make the HUD reappear
			view.frame=CGRectMake(-1000,-1000,0,0);
			
			[UIApplication.sharedApplication.windows[0] addSubview:view];
			view.release;
		});
		
		float volume=((NSNumber*)notification.userInfo[@"AVSystemController_AudioVolumeNotificationParameter"]).floatValue;
		
		BOOL up;
		if(volume==prevVolume)
		{
			up=prevVolume!=0;
		}
		else
		{
			up=volume>prevVolume;
		}
		
		prevVolume=volume;
		
		turnPage(!up);
	}];
}

@end