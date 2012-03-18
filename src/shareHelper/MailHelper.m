//
//  MailHelper.m
//  testOauth2
//
//  Created by radio on 12-3-18.
//  Copyright (c) 2012年 pawdigits. All rights reserved.
//

#import "MailHelper.h"
#import "AppDelegate.h"

@implementation MailHelper

- (void) sendmail:(NSString*) title body:(NSString*) bodyText imageName:(NSString*) name{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil){
		if ([mailClass canSendMail]){
			MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            picker.mailComposeDelegate = self;
            [picker setSubject:title];
//            NSArray *toRecipients = [NSArray arrayWithObject:@"first@example.com"]; 
//            NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil]; 
//            NSArray *bccRecipients = [NSArray arrayWithObject:@"fourth@example.com"]; 
//            [picker setToRecipients:toRecipients];
//            [picker setCcRecipients:ccRecipients];	
//            [picker setBccRecipients:bccRecipients];
            UIImage *image = [UIImage imageNamed:name];
            [picker addAttachmentData:UIImagePNGRepresentation(image) mimeType:@"image/png" fileName:@"photo"];
            [picker setMessageBody:bodyText isHTML:NO];

            AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            [delegate.viewController presentModalViewController:picker animated:YES];
            [picker release];
		}else{
			[self launchMailAppOnDevice];
		}
	}else{
		[self launchMailAppOnDevice];
	}
}

-(void)launchMailAppOnDevice{
    //    NSLog(@"launchMailAppOnDevice");
    UIAlertView *error = [[UIAlertView alloc]initWithTitle:nil
                                                   message:@"邮件服务器连接失败，请确认您的邮箱帐号设置是否正确。"
                                                  delegate:nil
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil];
    [error show];
    [error release];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    NSString *message = @"";
    switch (result)
	{
		case MFMailComposeResultCancelled:
			message = @"Result: canceled";
			break;
		case MFMailComposeResultSaved:
			message = @"Result: saved";
			break;
		case MFMailComposeResultSent:
			message = @"Result: sent";
			break;
		case MFMailComposeResultFailed:
			message = @"Result: failed";
			break;
		default:
			message = @"Result: not sent";
			break;
	}
    NSLog(@"message=%@",message);
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [delegate.viewController dismissModalViewControllerAnimated:YES];
}

@end
