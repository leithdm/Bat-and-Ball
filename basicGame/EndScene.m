//
//  EndScene.m
//  basicGame
//
//  Created by DML_Admin on 08/09/2014.
//  Copyright (c) 2014 DARREN LEITH. All rights reserved.
//

#import "EndScene.h"

@implementation EndScene

-(instancetype)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        MyScene *gameOverSoundProperty = [[MyScene alloc] init];
        gameOverSoundProperty.playSFXGameOver = [SKAction playSoundFileNamed:@"gameover.caf" waitForCompletion:NO];
        [self runAction:gameOverSoundProperty.playSFXGameOver];

        
        self.backgroundColor = [SKColor blackColor];
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Futura Medium"];
        label.text = @"GAME OVER. YOU SUCK!";
        label.fontColor = [SKColor whiteColor];
        label.fontSize = 20;
        label.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        
        [self addChild:label];
        
        //new label for restarting the game all over again
        SKLabelNode *startGameAgain = [SKLabelNode labelNodeWithFontNamed:@"Futura Medium"];
        startGameAgain.text = @"Tap to Play again";
        startGameAgain.fontColor = [UIColor whiteColor];
        startGameAgain.fontSize = 24;
        startGameAgain.position = CGPointMake(size.width/2, -50);
        
        
        SKAction *moveLabel = [SKAction moveToY:(size.height/2 - 60) duration:0.5];
        [startGameAgain runAction:moveLabel];
        
        [self addChild:startGameAgain];
        
    }
    return  self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    MyScene *playAgain = [MyScene sceneWithSize:self.size];
    
    //present the scene
    [self.view presentScene:playAgain transition: [SKTransition doorsOpenHorizontalWithDuration:2.0] ];
    
}
@end
