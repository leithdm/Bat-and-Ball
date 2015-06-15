//
//  MyScene.m
//  basicGame
//
//  Created by DML_Admin on 06/09/2014.
//  Copyright (c) 2014 DARREN LEITH. All rights reserved.
//

#import "MyScene.h"

@interface MyScene ()

@property (nonatomic) SKSpriteNode *paddle;

@end


//DEFINE THE CATEGORIES:
static const uint32_t ballCategory = 1;     //00000000000000000000000000000001
static const uint32_t brickCategory = 2;    //00000000000000000000000000000010
static const uint32_t paddleCategory = 4;   //00000000000000000000000000000100
static const uint32_t edgeCategory = 8;     //00000000000000000000000000001000
static const uint32_t bottomEdgeCategory = 16;
/*
//alternate way of assigning these bitwise categories using BITWISE OPERATORS
//BITWISE OPERATORS are better for 10, 15, 20+ categories. Same code as above shown below in BITWISE OPERATORS format:

static const uint32_t ballCategory = 0x1
static const uint32_t brickCategory = 0x1 <<1; //i.e. shift it over one bit.
static const uint32_t paddleCategory = 0x1 <<2; //i.e. shift it over two bits.
static const uint32_t edgeCategory = 0x1 <<3; //i.e. shift it over three bits.
*/

@implementation MyScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        
        
        
        //set up the sound effects
        self.playSFXPaddle = [SKAction playSoundFileNamed:@"paddle.m4a" waitForCompletion:NO];
        self.playSFXBrick = [SKAction playSoundFileNamed:@"brickhit.caf" waitForCompletion:NO];
//        self.playSFXGameOver = [SKAction playSoundFileNamed:@"gameover.caf" waitForCompletion:NO];
        
        /* Setup your scene here */
        self.backgroundColor = [UIColor blackColor];

        
        //add myParticle
        SKEmitterNode *fire = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle]pathForResource:@"MyParticle" ofType:@"sks"]];
        fire.position = CGPointMake(size.width/2, size.height/2);
        [fire advanceSimulationTime:10]; 
    
        
        //add a PHYSICS BODY to the scene. This creates a physical boundary around the frame of the screen in order to contain the nodes e.g. in this case to prevent the ball from falling through the screen.
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        //assign category to physicsBody. Assigning categories is basically how we can account for contacts between the various objects, and collissions.
        self.physicsBody.categoryBitMask = edgeCategory;
        
        //change the gravity settings
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        //contact delegate
        self.physicsWorld.contactDelegate = self;
        
        [self createBall:size];
        [self addPlayer:size];
        [self addBricks:size];
        [self addBottomEdge:size];
        [self addChild:fire];
    }
    return self;
}

-(void)didBeginContact:(SKPhysicsContact *)contact
{
    //code below will work perfectly fine, but because there are 2 objects, ball+brick, ball+paddle and the fact that object A/B can be a combination of either of them it is better to use the code FURTHER DOWN below it...
    /*if (contact.bodyA.categoryBitMask == brickCategory) {
        NSLog(@"body A is a brick");
        [contact.bodyA.node removeFromParent];
    }
    else NSLog(@"Body B is a paddle!");
     */
    
    //create a placeholder reference for the non-ball object. Basically we are trying to find which object is the ball, and from that can assign the contactA and contactB body to NOTTHEBALL physicsBody object.
    SKPhysicsBody *notTheBall;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        notTheBall = contact.bodyB;
    }
    else {
        notTheBall = contact.bodyA;
    }
    
    if (notTheBall.categoryBitMask == brickCategory) {
        [self runAction:self.playSFXBrick];
        [notTheBall.node removeFromParent];
    }
    if (notTheBall.categoryBitMask == paddleCategory){
        [self runAction:self.playSFXPaddle];
    }
    if (notTheBall.categoryBitMask == bottomEdgeCategory) {
        
        //create a new instance of the EndScene class. Note: this is flappy bird logic i.e. you only have one life, not three... SCENEWITHSIZE is a convenience method used below instead of alloc/init. Could use alloc/init but SCENEWITHSIZE does both...hence the term convenience method dumbass.
        EndScene *end = [EndScene sceneWithSize:self.size];
        
        //present the scene
        UIColor *myColor = [UIColor blueColor];
        [self.view presentScene:end transition:[SKTransition fadeWithColor: myColor duration:3]];
    }
    
}

-(void)addBottomEdge: (CGSize)size{
    //basically this "invisible node" will act as a CONTAINER
    SKNode *bottomEdge = [SKNode node];
    bottomEdge.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(0, 1) toPoint:CGPointMake(size.width, 1)];
    bottomEdge.physicsBody.categoryBitMask = bottomEdgeCategory;
    [self addChild:bottomEdge];
    
}

- (void)createBall:(CGSize)size {
    
    //create a new sprite from an image
    SKSpriteNode *ball = [SKSpriteNode spriteNodeWithImageNamed:@"orb0000"];
    //create a CGPoint for position
    ball.position = CGPointMake(size.width/2, size.height/2);
    ball.scale = 0.7;
    
    //use of texture atlas
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"orb"];
    //get all image filenames
    NSArray *orbImageNames = [atlas textureNames];
    
    //sort the filename
    NSArray *sortedNames =  [orbImageNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    //create an array to hold the textured objects
    NSMutableArray *orbTextures =  [NSMutableArray array];
    
    for (NSString *fileName in sortedNames) {
        SKTexture *texture = [atlas textureNamed:fileName];
        [orbTextures addObject:texture];
    }
    
    SKAction *glow = [SKAction animateWithTextures:orbTextures timePerFrame:0.2];
    SKAction *keepGlowing = [SKAction repeatActionForever:glow];
    SKAction *reverseGlow = [glow reversedAction];
    SKAction *sequence = [SKAction sequence:@[glow, reverseGlow, keepGlowing]];
    [ball runAction:sequence];
    
    
    //after settings its position, add the sprite node to the scene
    [self addChild:ball];
    
    //add a physicsBody to the ball sprite
    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ball.frame.size.width/2];
    ball.physicsBody.linearDamping = 0.0;
    ball.physicsBody.restitution = 1.0;
    ball.physicsBody.friction = 0.0;
    //add the category to the physics body
    ball.physicsBody.categoryBitMask = ballCategory;
    //contactTest i.e which bitmasks I am interested in touching
    ball.physicsBody.contactTestBitMask = brickCategory | paddleCategory | bottomEdgeCategory;
    
    //create the vector
    //again, this is a C struct, not an object, so dont need a pointer to the variable name
    CGVector myVector = CGVectorMake(20, 20);
    
    //apply the created vector to the physics body
    [ball.physicsBody applyImpulse:myVector];
}

-(void) addPlayer: (CGSize)size {
    
    //create paddle sprite
    self.paddle = [SKSpriteNode spriteNodeWithImageNamed:@"paddle"];
    
    //create a CGPoint for position
    self.paddle.position = CGPointMake(size.width/2, 75);
    
    //add a physicsBody to the paddle sprite
    self.paddle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.paddle.frame.size];
    self.paddle.physicsBody.dynamic = NO;
    //add category to physicsBody
    self.paddle.physicsBody.categoryBitMask = paddleCategory;
    
    //add the paddle to the scene
    [self addChild:self.paddle];
    
}

//adding a touch event for the movement of the paddle
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        CGPoint newPosition = CGPointMake(location.x, location.y);
        //stop paddle from going to far
        if (newPosition.x <self.paddle.size.width/2) {
            newPosition.x = self.paddle.size.width/2;
        }
        if (newPosition.x >self.size.width - (self.paddle.size.width/2)) {
            newPosition.x = self.size.width - (self.paddle.size.width/2);
        }
        self.paddle.position = newPosition;
    }
}

//adding a layer of bricks
-(void) addBricks: (CGSize)size {
    
    //create brick sprite from image. Want 4 bricks in a row
    for (int i=0; i<4; i++) {
        
        //instantiate a new sprite brick object
        SKSpriteNode * brick = [[SKSpriteNode alloc] initWithImageNamed:@"brick"];

        //add physics body
        brick.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: brick.frame.size];
        brick.physicsBody.dynamic = NO;
        //assign category to physics body
        brick.physicsBody.categoryBitMask = brickCategory;
        
        
        int xPos = size.width/5 * (i+1);
        int yPos = size.height - 50;
        brick.position = CGPointMake(xPos, yPos);
        
        //after setting its position, lets add it to the scene
        [self addChild:brick];
    }
    
    for (int i=0; i<4; i++) {
        
        //instantiate a new sprite brick object
        SKSpriteNode * brick = [[SKSpriteNode alloc] initWithImageNamed:@"brick"];
        
        //add physics body
        brick.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: brick.frame.size];
        brick.physicsBody.dynamic = NO;
        //assign category to physics body
        brick.physicsBody.categoryBitMask = brickCategory;
        
        
        int xPos = size.width/5 * (i+1);
        int yPos = size.height - 85;
        brick.position = CGPointMake(xPos-25, yPos);
        
        //after setting its position, lets add it to the scene
        [self addChild:brick];
    
    }
    
    for (int i=0; i<4; i++) {
        
        //instantiate a new sprite brick object
        SKSpriteNode * brick = [[SKSpriteNode alloc] initWithImageNamed:@"brick"];
        
        //add physics body
        brick.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: brick.frame.size];
        brick.physicsBody.dynamic = NO;
        //assign category to physics body
        brick.physicsBody.categoryBitMask = brickCategory;
        
        
        int xPos = size.width/5 * (i+1);
        int yPos = size.height - 125;
        brick.position = CGPointMake(xPos +25, yPos);
        
        //after setting its position, lets add it to the scene
        [self addChild:brick];
        
    }
}



-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
