//
//  ViewController.m
//  basicGame
//
//  Created by DML_Admin on 06/09/2014.
//  Copyright (c) 2014 DARREN LEITH. All rights reserved.
//

#import "ViewController.h"
#import "MyScene.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    SKScene * scene = [MyScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];

    /*
    //for playing background music in the game
    NSError *error;
    NSString *myString = [[NSBundle mainBundle]pathForResource:@"black" ofType:@"mp3"];
    NSURL *myURL = [NSURL fileURLWithPath:myString];
    self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:myURL error:&error];
    [self.backgroundMusicPlayer prepareToPlay];
    [self.backgroundMusicPlayer play];
    */
}

//simple line of code introduced to remove the status bar. Can also be achieved by editing the PLIST file, but below is probably the best method. 
-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
