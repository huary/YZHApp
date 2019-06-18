//
//  GLPaintingView.m
//  UIPaintingViewDemo
//
//  Created by yuan on 2018/1/31.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "GLPaintingView.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import <GLKit/GLKit.h>

#import "shaderUtil.h"
#import "fileUtil.h"
#import "debug.h"

#import "YZHKitType.h"

#define NEED_DEPTH_RENDER_BUFFER    (0)
#define FIRST_VERTEX_CNT            (64)
#define BRUSH_PIXEL_STEP            (3) //(20)

#if FIRST_VERTEX_CNT <= 0
#error "FIRST_VERTEX_CNT must be greater than 0"
#endif

#if BRUSH_PIXEL_STEP <= 0
#error "FIRST_VERTEX_CNT must be greater than 0"
#endif

//如果用previousLocationInView就有点和上层逻辑不太符合，用本次存储的就符合
#define USE_LOCAL_PREV_TOUCH_POINT  (0)

// Shaders
enum {
    PROGRAM_POINT,
    NUM_PROGRAMS
};

enum {
    UNIFORM_MVP,
    UNIFORM_POINT_SIZE,
    UNIFORM_VERTEX_COLOR,
    UNIFORM_TEXTURE,
    NUM_UNIFORMS
};

enum {
    ATTRIB_VERTEX,
    NUM_ATTRIBS
};

typedef struct {
    char *vert, *frag;
    GLint uniform[NUM_UNIFORMS];
    GLuint program;
} programInfo_t;

programInfo_t program[NUM_PROGRAMS] = {
    { "point.vsh",   "point.fsh" },     // PROGRAM_POINT
};

// Texture
typedef struct {
    GLuint texId;
    GLsizei width, height;
} textureInfo_t;


@interface GLPaintingView ()
{
    // The pixel dimensions of the backbuffer
    GLint backingWidth;
    GLint backingHeight;
    
    EAGLContext *context;
    
    // OpenGL names for the renderbuffer and framebuffers used to render to this view
    GLuint viewRenderbuffer, viewFramebuffer;
    
    // OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist)
#if NEED_DEPTH_RENDER_BUFFER
    GLuint depthRenderbuffer;
#endif
    
    textureInfo_t brushTexture;     // brush texture
    //    GLfloat brushColor[4];          // brush color
    
    Boolean needsErase;
    
    // Shader objects
    //    GLuint vertexShader;
    //    GLuint fragmentShader;
    //    GLuint shaderProgram;
    
    // Buffer Objects
    GLuint vboId;
    
    BOOL initialized;
    
    GLfloat *vertexBuffer;
    NSUInteger vertexMax;
    
    NSUInteger vertexCntS;
#if USE_LOCAL_PREV_TOUCH_POINT
    CGPoint prevPoint;
#endif
}

@property (nonatomic, assign) CGSize renderSize;

/* <#name#> */
@property (nonatomic, assign) BOOL isInClear;

@end


@implementation GLPaintingView

// Implement this to override the default layer class (which is [CALayer class]).
// We do this so that our view will be backed by a layer that is capable of OpenGL ES rendering.
+(Class)layerClass
{
    return [CAEAGLLayer class];
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        if (![self _setupDefaultValue]) {
            return nil;
        };
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (![self _setupDefaultValue]) {
            return nil;
        }
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        if (![self _setupDefaultValue]) {
            return nil;
        };
    }
    return self;
}

-(BOOL)_setupDefaultValue
{
    CAEAGLLayer *eaglLayer = (CAEAGLLayer*)self.layer;
    eaglLayer.opaque = YES;
    
    // In this application, we want to retain the EAGLDrawable contents after a call to presentRenderbuffer.
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],kEAGLDrawablePropertyRetainedBacking,kEAGLColorFormatRGBA8,kEAGLDrawablePropertyColorFormat,nil];
    
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!context || ![EAGLContext setCurrentContext:context]) {
        return NO;
    }
    
    // Set the view's scale factor as you wish
    self.contentScaleFactor = [UIScreen mainScreen].scale;
    
    // Make sure to start with a cleared buffer
    needsErase = YES;
    
    self.backgroundColor = WHITE_COLOR;
    self.brushWidth = 1.0;
    self.brushColor = BLACK_COLOR;
    self.touchPaintEnabled = YES;
    vertexBuffer = NULL;
    vertexMax = FIRST_VERTEX_CNT;
    vertexCntS = 0;
    //    self.layer.shouldRasterize = YES;
    return YES;
}

-(EAGLContext*)getGLContext
{
    return context;
}

-(void)_getColorComponentsForColor:(UIColor*)color outComponents:(GLfloat*)colorComponents
{
    if (colorComponents == NULL) {
        return;
    }
    
    CGFloat red = 0, green = 0, blue = 0, alpha = 0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    colorComponents[0] = (GLfloat)red;
    colorComponents[1] = (GLfloat)green;
    colorComponents[2] = (GLfloat)blue;
    colorComponents[3] = (GLfloat)alpha;
}

// If our view is resized, we'll be asked to layout subviews.
// This is the perfect opportunity to also update the framebuffer so that it is
// the same size as our display area.
-(void)layoutSubviews
{
    [super layoutSubviews];
    [EAGLContext setCurrentContext:context];
    
    if (!initialized) {
        initialized = [self _initGL];
    }
    else {
        CGSize size = self.bounds.size;
        GLint width = size.width * self.contentScaleFactor;
        GLint height = size.height * self.contentScaleFactor;
        if (width != backingWidth || height != backingHeight) {
            [self _resizeFromLayer:(CAEAGLLayer*)self.layer];
        }
    }
    
    if (needsErase) {
        [self erase];
        needsErase = NO;
    }
    self.renderSize = self.bounds.size;
}

-(BOOL)_initGL
{
    // Generate IDs for a framebuffer object and a color renderbuffer
    glGenFramebuffers(1, &viewFramebuffer);
    glGenRenderbuffers(1, &viewRenderbuffer);
    
    glBindFramebuffer(GL_FRAMEBUFFER, viewFramebuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
    
    // This call associates the storage for the current render buffer with the EAGLDrawable (our CAEAGLLayer)
    // allowing us to draw into a buffer that will later be rendered to screen wherever the layer is (which corresponds with our view).
    
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(id<EAGLDrawable>)self.layer];
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, viewRenderbuffer);
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    
    // For this sample, we do not need a depth buffer. If you do, this is how you can create one and attach it to the framebuffer:
#if NEED_DEPTH_RENDER_BUFFER
    glGenRenderbuffers(1, &depthRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, backingWidth, backingHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
#endif
    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) !=GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    }
    
    // Setup the view port in Pixels
    glViewport(0, 0, backingWidth, backingHeight);
    
    // Create a Vertex Buffer Object to hold our data
    glGenBuffers(1, &vboId);
    
    // Load the brush texture
    brushTexture = [self _textureFromName:@"Particle.png"];
    
    // Load shaders
    [self _setupShaders];
    
    // Enable blending and set a blending function appropriate for premultiplied alpha pixel data
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
    return YES;
}


// Create a texture from an image
-(textureInfo_t)_textureFromName:(NSString *)name
{
    CGImageRef brushImage = NULL;
    CGContextRef brushContext = NULL;
    GLubyte *brushData = NULL;
    size_t width, height;
    GLuint texId;
    textureInfo_t texture;
    
    // First create a UIImage object from the data in a image file, and then extract the Core Graphics image
    brushImage = [UIImage imageNamed:name].CGImage;
    
    // Get the width and height of the image
    width = CGImageGetWidth(brushImage);
    height = CGImageGetHeight(brushImage);
    
    // Make sure the image exists
    if (brushImage != NULL) {
        // Allocate  memory needed for the bitmap context
        brushData = (GLubyte*)calloc(width * height * 4, sizeof(GLubyte));
        // Use  the bitmatp creation function provided by the Core Graphics framework.
        brushContext = CGBitmapContextCreate(brushData, width, height, 8, width * 4, CGImageGetColorSpace(brushImage), kCGImageAlphaPremultipliedLast);
        // After you create the context, you can draw the  image to the context.
        CGContextDrawImage(brushContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), brushImage);
        // You don't need the context at this point, so you need to release it to avoid memory leaks.
        CGContextRelease(brushContext);
        // Use OpenGL ES to generate a name for the texture.
        glGenTextures(1, &texId);
        // Bind the texture name.
        glBindTexture(GL_TEXTURE_2D, texId);
        // Set the texture parameters to use a minifying filter and a linear filer (weighted average)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        // Specify a 2D texture image, providing the a pointer to the image data in memory
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)width, (int)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, brushData);
        // Release  the image data; it's no longer needed
        free(brushData);
        
        texture.texId = texId;
        texture.width = (int)width;
        texture.height = (int)height;
    }
    else {
        texture.texId = -1;
        texture.width = -1;
        texture.height = -1;
    }
    return texture;
}

-(void)_setupShaders
{
    for (int i = 0; i < NUM_PROGRAMS; ++i) {
        char *vsrc = readFile(pathForResource(program[i].vert));
        char *fsrc = readFile(pathForResource(program[i].frag));
        
        GLsizei attribCnt = 0;
        GLchar *attribUsed[NUM_ATTRIBS] = {NULL,};
        GLint attrib[NUM_ATTRIBS] = {0};
        GLchar *attribName[NUM_ATTRIBS] = {"inVertex",};
        const GLchar *uniformName[NUM_UNIFORMS] = {"MVP", "pointSize", "vertexColor", "texture",};
        
        // auto-assign known attribs
        for (int j = 0; j < NUM_ATTRIBS; ++j) {
            if (strstr(vsrc, attribName[j])) {
                attrib[attribCnt] = j;
                attribUsed[attribCnt] = attribName[j];
                ++attribCnt;
            }
        }
        
        glueCreateProgram(vsrc, fsrc, attribCnt, (const GLchar**)&attribUsed[0], attrib, NUM_UNIFORMS, &uniformName[0], program[i].uniform, &program[i].program);
        
        free(vsrc);
        free(fsrc);
        
        // Set constant/initalize uniforms
        if (i == PROGRAM_POINT) {
            glUseProgram(program[i].program);
            
            // the brush texture will be bound to texture unit 0
            glUniform1i(program[i].uniform[UNIFORM_TEXTURE], 0);
            
            // viewing matrices
            GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, backingWidth, 0, backingHeight, -1, 1);
            // this sample uses a constant identity modelView matrix
            GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
            GLKMatrix4 MVPMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
            
            glUniformMatrix4fv(program[i].uniform[UNIFORM_MVP], 1, GL_FALSE, MVPMatrix.m);
            
            // point size
            glUniform1f(program[i].uniform[UNIFORM_POINT_SIZE], self.brushWidth * self.contentScaleFactor);
            
            // initialize brush color
            GLfloat brushColor[4] = {0};
            [self _getColorComponentsForColor:self.brushColor outComponents:brushColor];
            glUniform4fv(program[i].uniform[UNIFORM_VERTEX_COLOR], 1, brushColor);
        }
    }
    glError();
}


- (BOOL)_resizeFromLayer:(CAEAGLLayer *)layer
{
    // Allocate color buffer backing based on the current layer size
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
    //这一句为啥会导致前面渲染的清空???
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    // For this sample, we do not need a depth buffer. If you do, this is how you can allocate depth buffer backing:
#if NEED_DEPTH_RENDER_BUFFER
    glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, backingWidth, backingHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
#endif
    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Failed to make complete framebuffer objectz %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }

    // Update projection matrix
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, backingWidth, 0, backingHeight, -1, 1);
    // this sample uses a constant identity modelView matrix
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    GLKMatrix4 MVPMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    
    glUseProgram(program[PROGRAM_POINT].program);
    glUniformMatrix4fv(program[PROGRAM_POINT].uniform[UNIFORM_MVP], 1, GL_FALSE, MVPMatrix.m);
    
    // Update viewport
    glViewport(0, 0, backingWidth, backingHeight);
    return YES;
}

-(void)_renderVertexBuffer:(GLfloat*)vertexBuffer vertexCnt:(NSInteger)vertexCnt lineWidth:(CGFloat)lineWidth lineColor:(UIColor*)lineColor
{
    if (vertexBuffer == NULL || vertexCnt <= 0) {
        return;
    }
    // Load data to the Vertex Buffer Object
    glBindBuffer(GL_ARRAY_BUFFER, vboId);
    glBufferData(GL_ARRAY_BUFFER, 2 * vertexCnt *  sizeof(GLfloat), vertexBuffer, GL_DYNAMIC_DRAW);
    
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, GL_FALSE, 0, 0);
    
    // Draw
    glUseProgram(program[PROGRAM_POINT].program);
    if (lineWidth > 0.0f) {
        glUniform1f(program[PROGRAM_POINT].uniform[UNIFORM_POINT_SIZE], lineWidth * self.contentScaleFactor);
    }
    if (lineColor) {
        GLfloat brushColor[4] = {0};
        [self _getColorComponentsForColor:lineColor outComponents:brushColor];
        glUniform4fv(program[PROGRAM_POINT].uniform[UNIFORM_VERTEX_COLOR], 1, brushColor);
    }
    glDrawArrays(GL_POINTS, 0, (int)vertexCnt);
}

// Drawings a line onscreen based on where the user touches
-(void)_renderLineFromPoint:(GLLinePoint*)fromPt toPoint:(GLLinePoint*)toPt lineColor:(UIColor*)lineColor
{
    if (fromPt == nil || toPt == nil) {
        return;
    }
//    static GLfloat *vertexBuffer = NULL;
//    static NSUInteger vertexMax = FIRST_VERTEX_CNT;
    NSUInteger vertexCnt, count, i;
    vertexCnt = count = i = 0;
    
    [EAGLContext setCurrentContext:context];
    glBindFramebuffer(GL_FRAMEBUFFER, viewFramebuffer);
    
    CGPoint from = fromPt.point;
    CGPoint to = toPt.point;
    // Convert locations from Points to Pixels
    CGFloat scale = self.contentScaleFactor;
    from.x *= scale;
    from.y *= scale;
    
    to.x *= scale;
    to.y *= scale;
    

    // Add points to the buffer so there are drawing points every X pixels
    CGFloat dis = sqrtf((to.x - from.x) * (to.x - from.x) + (to.y - from.y) * (to.y - from.y));
    count = MAX(ceilf(dis*BRUSH_PIXEL_STEP),1);
    
    CGFloat lineWidthDiff = fabs(fromPt.lineWidth - toPt.lineWidth);
    if (count > 1 && /*fromPt.lineWidth > 0.0f && toPt.lineWidth > 0.0f &&*/ lineWidthDiff > 0.001f) {
        GLfloat vertexBuffer[2] = {0.0};
        CGFloat lineWidth = 0;
        for (i = 0; i < count; ++i) {
            vertexBuffer[0] = from.x + (to.x - from.x) * ((GLfloat)i/(GLfloat)count);
            vertexBuffer[1] = from.y + (to.y - from.y) * ((GLfloat)i/(GLfloat)count);
            
            lineWidth = fromPt.lineWidth + (toPt.lineWidth -fromPt.lineWidth) * ((GLfloat)i/(GLfloat)count);
            
            [self _renderVertexBuffer:vertexBuffer vertexCnt:1 lineWidth:lineWidth lineColor:lineColor];
            vertexCntS += 1;
        }
    }
    else {
        // Allocate vertex array buffer
        if (vertexBuffer == NULL) {
            NSInteger len = 2 * vertexMax * sizeof(GLfloat);
            vertexBuffer = malloc(len);
            memset(vertexBuffer, 0, len);
        }
        
        for (i = 0; i < count; ++i) {
            if (vertexCnt == vertexMax) {
                vertexMax = 2 * vertexMax;
                vertexBuffer = realloc(vertexBuffer, 2 * vertexMax * sizeof(GLfloat));
            }
            vertexBuffer[2 * vertexCnt + 0] = from.x + (to.x - from.x) * ((GLfloat)i/(GLfloat)count);
            vertexBuffer[2 * vertexCnt + 1] = from.y + (to.y - from.y) * ((GLfloat)i/(GLfloat)count);
            
            vertexCnt += 1;
        }
        
        [self _renderVertexBuffer:vertexBuffer vertexCnt:vertexCnt lineWidth:fromPt.lineWidth lineColor:lineColor];
        
        vertexCntS += vertexCnt;
    }
}

-(void)_renderLineAndPresentFromPoint:(GLLinePoint*)from toPoint:(GLLinePoint*)to lineColor:(UIColor*)lineColor
{
    [self _renderLineFromPoint:from toPoint:to lineColor:lineColor];
    [self presentRenderbuffer];
}



//接口==============
-(void)setBrushWidth:(CGFloat)brushWidth
{
    _brushWidth = brushWidth;
    if (initialized) {
        EAGLContext *prevContext = [EAGLContext currentContext];
        [EAGLContext setCurrentContext:context];
        
        glUseProgram(program[PROGRAM_POINT].program);
        glUniform1f(program[PROGRAM_POINT].uniform[UNIFORM_POINT_SIZE], brushWidth * self.contentScaleFactor);
        
        [EAGLContext setCurrentContext:prevContext];
    }
}

-(void)setBrushColor:(UIColor *)brushColor
{
    _brushColor = brushColor;
    if (initialized) {
        EAGLContext *prevContext = [EAGLContext currentContext];
        [EAGLContext setCurrentContext:context];

        glUseProgram(program[PROGRAM_POINT].program);
        GLfloat brushColorC[4] = {0};
        [self _getColorComponentsForColor:brushColor outComponents:brushColorC];
        glUniform4fv(program[PROGRAM_POINT].uniform[UNIFORM_VERTEX_COLOR], 1, brushColorC);
        
        [EAGLContext setCurrentContext:prevContext];
    }
}

-(void)_doClearFrameBufferAction
{
    [EAGLContext setCurrentContext:context];
    
    // Clear the buffer
    glBindFramebuffer(GL_FRAMEBUFFER, viewFramebuffer);
    
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
    [self.backgroundColor getRed:&red green:&green blue:&blue alpha:&alpha];
    glClearColor(red, green, blue, alpha);
}

-(void)clearFrameBuffer
{
    [self _doClearFrameBufferAction];
    glClear(GL_COLOR_BUFFER_BIT);
}

-(void)clearFrameBufferInFrame:(CGRect)frame
{
    [self _doClearFrameBufferAction];
    
    CGRect glRect = [self _convertRectToGLRect:frame];
    
    glScissor(glRect.origin.x,glRect.origin.y, glRect.size.width, glRect.size.height);
    glEnable(GL_SCISSOR_TEST);
    glClear(GL_COLOR_BUFFER_BIT);
    glDisable(GL_SCISSOR_TEST);
}

-(void)presentRenderbuffer
{
    // Display the buffer
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER];
}

-(CGRect)_convertRectToGLRect:(CGRect)rect
{
    CGFloat scale = self.contentScaleFactor;
    CGFloat x = rect.origin.x * scale;
    CGFloat w = rect.size.width * scale;
    CGFloat h = rect.size.height * scale;
    CGFloat y = (self.renderSize.height - CGRectGetMaxY(rect)) * scale;//(self.renderSize.height - rect.origin.y);
    return CGRectMake(x, y, w, h);
}

-(GLLinePoint*)_convertToGLPoint:(GLLinePoint*)point
{
    CGPoint pt = point.point;
    pt.y = self.renderSize.height - pt.y;
    return [[GLLinePoint alloc] initWithPoint:pt lineWidth:point.lineWidth];
}

-(void)renderLineFromPoint:(GLLinePoint*)from toPoint:(GLLinePoint*)to present:(BOOL)present
{
//    NSLog(@"from:%@->to:%@",NSStringFromCGPoint(from.point),NSStringFromCGPoint(to.point));
    GLLinePoint *newFrom = [self _convertToGLPoint:from];
    GLLinePoint *newTo = [self _convertToGLPoint:to];
    
    if (present) {
        [self _renderLineAndPresentFromPoint:newFrom toPoint:newTo lineColor:nil];
    }
    else {
        [self _renderLineFromPoint:newFrom toPoint:newTo lineColor:nil];
    }
}

-(void)renderLineFromPoint:(GLLinePoint*)from toPoint:(GLLinePoint*)to lineColor:(UIColor*)lineColor present:(BOOL)present
{
    GLLinePoint *newFrom = [self _convertToGLPoint:from];
    GLLinePoint *newTo = [self _convertToGLPoint:to];
    
//    NSLog(@"from:%@->to:%@",NSStringFromCGPoint(from.point),NSStringFromCGPoint(to.point));
    if (present) {
        [self _renderLineAndPresentFromPoint:newFrom toPoint:newTo lineColor:lineColor];
    }
    else {
        [self _renderLineFromPoint:newFrom toPoint:newTo lineColor:lineColor];
    }
}

-(void)erase
{
    EAGLContext *prevContext = [EAGLContext currentContext];
    [self clearFrameBuffer];
    
    [self presentRenderbuffer];
    
    [EAGLContext setCurrentContext:prevContext];
}

-(void)eraseInFrame:(CGRect)frame
{
    EAGLContext *prevContext = [EAGLContext currentContext];
    [self clearFrameBufferInFrame:frame];
    
    [self presentRenderbuffer];
    [EAGLContext setCurrentContext:prevContext];
}

-(void)setGLBlendModel:(BOOL)clear
{
    EAGLContext *prevContext = [EAGLContext currentContext];
    [EAGLContext setCurrentContext:context];
    glEnable(GL_BLEND);
    if (clear) {
        brushTexture = [self _textureFromName:@"erase.png"];
        self.isInClear = YES;
        self.brushColor = [self.brushColor colorWithAlphaComponent:1.0];
        
//        glBlendFunc(GL_ONE, GL_ZERO);
//        glBlendFunc(GL_ZERO, GL_ZERO);
        glBlendFunc(GL_ZERO, GL_ONE_MINUS_SRC_ALPHA);
    }
    else {
        brushTexture = [self _textureFromName:@"Particle.png"];
        self.isInClear = NO;
        
        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    }
    [EAGLContext setCurrentContext:prevContext];
}

-(BOOL)isInClearModel
{
    return self.isInClear;
}

- (UIImage*)snapshot
{
    if (SYSTEMVERSION_NUMBER >= 7.0) {
        return [self _snapshotOnIOS7AndLater];
    }
    return [self _snapshotOnIOS6AndBefore];
}

-(UIImage*)_snapshotOnIOS7AndLater
{
    if (CGSizeEqualToSize(self.bounds.size, CGSizeZero)) {
        return nil;
    }
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    // Render our snapshot into the image context
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    
    // Grab the image from the context
    UIImage *complexViewImage = UIGraphicsGetImageFromCurrentImageContext();
    // Finish using the context
    UIGraphicsEndImageContext();
    
    return complexViewImage;
}

-(UIImage*)_snapshotOnIOS6AndBefore
{
    EAGLContext *prevContext = [EAGLContext currentContext];
    [EAGLContext setCurrentContext:context];
    
    GLint backingWidth, backingHeight;
    
    // Bind the color renderbuffer used to render the OpenGL ES view
    // If your application only creates a single color renderbuffer which is already bound at this point,
    // this call is redundant, but it is needed if you're dealing with multiple renderbuffers.
    // Note, replace "viewRenderbuffer" with the actual name of the renderbuffer object defined in your class.
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
    
    // Get the size of the backing CAEAGLLayer
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    
    NSInteger x = 0, y = 0, width = backingWidth, height = backingHeight;
    NSInteger dataLength = width * height * 4;
    GLubyte *data = (GLubyte*)malloc(dataLength * sizeof(GLubyte));
    
    // Read pixel data from the framebuffer
    glPixelStorei(GL_PACK_ALIGNMENT, 4);
    glReadPixels((int)x, (int)y, (int)width, (int)height, GL_RGBA, GL_UNSIGNED_BYTE, data);
    
    // Create a CGImage with the pixel data
    // If your OpenGL ES content is opaque, use kCGImageAlphaNoneSkipLast to ignore the alpha channel
    // otherwise, use kCGImageAlphaPremultipliedLast
    CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGImageRef iref = CGImageCreate(width, height, 8, 32, width * 4, colorspace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast,
                                    ref, NULL, true, kCGRenderingIntentDefault);
    
    [EAGLContext setCurrentContext:prevContext];
    
    // OpenGL ES measures data in PIXELS
    // Create a graphics context with the target size measured in POINTS
    if (NULL != UIGraphicsBeginImageContextWithOptions) {
        // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
        // Set the scale parameter to your OpenGL ES view's contentScaleFactor
        // so that you get a high-resolution snapshot when its value is greater than 1.0
        CGFloat scale = self.contentScaleFactor;
        width = width / scale;
        height = height / scale;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, scale);
    }
    else {
        // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
        UIGraphicsBeginImageContext(CGSizeMake(width, height));
    }
    
    
    CGContextRef cgcontext = UIGraphicsGetCurrentContext();
    // UIKit coordinate system is upside down to GL/Quartz coordinate system
    // Flip the CGImage by rendering it to the flipped bitmap context
    // The size of the destination area is measured in POINTS
    CGContextSetBlendMode(cgcontext, kCGBlendModeCopy);
    CGContextDrawImage(cgcontext, CGRectMake(0.0, 0.0, width, height), iref);
    
    // Retrieve the UIImage from the current context
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Clean up
    free(data);
    CFRelease(ref);
    CFRelease(colorspace);
    CGImageRelease(iref);
    
    return image;
}

-(void)_renderLineFromPoint:(CGPoint)from toPoint:(CGPoint)to lineWidth:(CGFloat)lineWidth lineColor:(UIColor*)lineColor
{
    GLLinePoint *fromPt = [[GLLinePoint alloc] initWithPoint:from lineWidth:lineWidth];
    GLLinePoint *toPt = [[GLLinePoint alloc] initWithPoint:to lineWidth:lineWidth];
    [self renderLineFromPoint:fromPt toPoint:toPt present:YES];
}

// Handles the end of a touch event when the touch is a tap.
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.touchPaintEnabled == NO) {
        return;
    }
    
    UITouch *touch = [[event touchesForView:self] anyObject];
    if ([self.delegate respondsToSelector:@selector(paintingView:touchBegan:withEvent:)]) {
        BOOL can = [self.delegate paintingView:self touchBegan:touch withEvent:event];
        if (!can) {
            return;
        }
    }
    
    self.brushWidth = _brushWidth;
    self.brushColor = _brushColor;
    
    CGPoint loc = [touch locationInView:self];
#if USE_LOCAL_PREV_TOUCH_POINT
    prevPoint = loc;
#endif

    [self _renderLineFromPoint:loc toPoint:loc lineWidth:-1 lineColor:nil];
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.touchPaintEnabled == NO) {
        return;
    }
    UITouch *touch = [[event touchesForView:self] anyObject];

    if ([self.delegate respondsToSelector:@selector(paintingView:touchMoved:withEvent:)]) {
        BOOL can = [self.delegate paintingView:self touchMoved:touch withEvent:event];
        if (!can) {
            return;
        }
    }
    CGPoint currLoc = [touch locationInView:self];
    
#if USE_LOCAL_PREV_TOUCH_POINT
    CGPoint prevLoc = prevPoint;
    prevPoint = currLoc;
#else
    CGPoint prevLoc = [touch previousLocationInView:self];
#endif
    
    [self _renderLineFromPoint:prevLoc toPoint:currLoc lineWidth:-1 lineColor:nil];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.touchPaintEnabled == NO) {
        return;
    }
    UITouch *touch = [[event touchesForView:self] anyObject];
    
    if ([self.delegate respondsToSelector:@selector(paintingView:touchEnded:withEvent:)]) {
        BOOL can = [self.delegate paintingView:self touchEnded:touch withEvent:event];
        if (!can) {
            return;
        }
    }
    CGPoint currLoc = [touch locationInView:self];

#if USE_LOCAL_PREV_TOUCH_POINT
    CGPoint prevLoc = prevPoint;
#else
    CGPoint prevLoc = [touch previousLocationInView:self];
#endif
    
    [self _renderLineFromPoint:prevLoc toPoint:currLoc lineWidth:-1 lineColor:nil];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

// Releases resources when they are not longer needed.
-(void)dealloc
{
    // Destroy framebuffers and renderbuffers
    if (viewFramebuffer) {
        glDeleteFramebuffers(1, &viewFramebuffer);
        viewFramebuffer = 0;
    }
    if (viewRenderbuffer) {
        glDeleteRenderbuffers(1, &viewRenderbuffer);
        viewRenderbuffer = 0;
    }
#if NEED_DEPTH_RENDER_BUFFER
    if (depthRenderbuffer)
    {
        glDeleteRenderbuffers(1, &depthRenderbuffer);
        depthRenderbuffer = 0;
    }
#endif

    // texture
    if (brushTexture.texId) {
        glDeleteTextures(1, &brushTexture.texId);
        brushTexture.texId = 0;
    }
    // vbo
    if (vboId) {
        glDeleteBuffers(1, &vboId);
        vboId = 0;
    }
    // tear down context
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
    context = nil;
    
    if (vertexBuffer) {
        free(vertexBuffer);
        vertexBuffer = nil;
        vertexMax = 0;
    }
}

@end
