//
//  TLViewController.h
//  CalendarWidget
//
//  Created by Tony Li on 4/12/12.
//  Copyright (c) 2012 Tony Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBWeeAppController-Protocol.h"

@interface TLViewController : UIViewController {
    id<BBWeeAppController> _weeAppController;
}

@end
