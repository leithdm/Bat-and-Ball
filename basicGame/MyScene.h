//
//  MyScene.h
//  basicGame
//

//  Copyright (c) 2014 DARREN LEITH. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "EndScene.h"

@interface MyScene : SKScene <SKPhysicsContactDelegate>

@property (nonatomic, strong) SKAction *playSFXPaddle;
@property (nonatomic, strong) SKAction *playSFXBrick;
@property (nonatomic, strong) SKAction *playSFXGameOver;

@end
