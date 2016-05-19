/*
 *  ofxWebView.mm
 *  WebView
 *
 *  Created by Andreas Borg on 06/04/2015
 *  Copyright 2015 LocalProjects. All rights reserved.
 *
 */

#include "ofxWebView.h"


//TODO: Explore alternative aproaches for conversion that better handle alpha/antialias
//eg. https://gist.github.com/shpakovski/7696268

//Check if fuzziness is related to rounding error float/int, on set size / image resize

//--------------------------------------------------------------
bool NSBitmapToOFTexture(NSBitmapImageRep *uiImage, ofTexture *outTexture, int targetWidth, int targetHeight) {
    if(!uiImage) return false;
    
    CGContextRef spriteContext;
    CGImageRef	cgImage = uiImage.CGImage;
    
    int bytesPerPixel	= CGImageGetBitsPerPixel(cgImage)/8;
    if(bytesPerPixel == 3) bytesPerPixel = 4;
    
    int width			= targetWidth > 0 ? targetWidth : CGImageGetWidth(cgImage);
    int height			= targetHeight > 0 ? targetHeight : CGImageGetHeight(cgImage);
    
    // Allocated memory needed for the bitmap context
    GLubyte *pixels		= (GLubyte *) malloc(width * height * bytesPerPixel);
    
    // Uses the bitmap creation function provided by the Core Graphics framework.
    spriteContext = CGBitmapContextCreate(pixels, width, height, CGImageGetBitsPerComponent(cgImage), width * bytesPerPixel, CGImageGetColorSpace(cgImage), bytesPerPixel == 4 ? kCGImageAlphaPremultipliedLast : kCGImageAlphaNone);
    
    if(spriteContext == NULL) {
        ofLogError("ofxiOSExtras") << "ofxiOSUIImageToOFImage(): CGBitmapContextCreate returned NULL";
        free(pixels);
        return false;
    }
    
    // After you create the context, you can draw the sprite image to the context.
    ofLogVerbose("ofxiOSExtras") << "ofxiOSUIImageToOFImage(): about to CGContextDrawImage";
    CGContextDrawImage(spriteContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), cgImage);
    
    // You don't need the context at this point, so you need to release it to avoid memory leaks.
    ofLogVerbose("ofxiOSExtras") << "ofxiOSUIImageToOFImage(): about to CGContextRelease";
    CGContextRelease(spriteContext);
    
    int glMode;
    
    switch(bytesPerPixel) {
        case 1:
            glMode = GL_LUMINANCE;
            break;
        case 3:
            glMode = GL_RGB;
            break;
        case 4:
        default:
            glMode = GL_RGBA; break;
    }
    
    outTexture->allocate(width, height, glMode);
    outTexture->loadData(pixels, width, height, glMode);
    
    free(pixels);
    
    return true;
}





@implementation WebListener

-(void) setOfView: (ofxWebView *) _of{
    _ofView = _of;

};
//@synthesize _ofView;

- (void) webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request  frame:(WebFrame *)frame decisionListener:(id )listener{
    
    
    WebViewEvent e;
    e.URL = (string)[[request.URL absoluteString] UTF8String];
    ofNotifyEvent(_ofView->LOAD_URL,e);
    
    //this allows for blocking in event response
    if(_ofView->getAllowPageLoad()){
        [listener use];
    }else{
        [listener ignore];
    }

}


- (void) webView:(WebView *)webView decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame  decisionListener:(id )listener{
    
    NSLog(@"decidePolicyForNewWindowAction URL %@ ", request.URL);
    
    //to stop load
    //[listener ignore];
    
    //or
    [listener use];
    
}



@end;





//------------------------------------------------------------------
ofxWebView::ofxWebView() {
    window = (NSWindow *)(ofAppGLFWWindow *)ofGetWindowPtr()->getCocoaWindow();
    
    NSRect bounds = {0,0,static_cast<CGFloat>(ofGetWidth()),static_cast<CGFloat>(ofGetHeight())};//[window.contentView bounds]
    setPosition(0,0);
    setSize(ofGetWidth(),ofGetHeight());
    
    _drawBg = false;
    
    webView = [[WebView alloc] initWithFrame:bounds
                                   frameName:@"OF-frame"
                                   groupName:nil];
    
    [webView setWantsLayer:YES];
    [webView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable]; // stick to the window's size
    [webView setDrawsBackground:NO]; // if you want OF to show up behind the web view
    [webView setCanDrawConcurrently:YES]; // may speed up rendering, worth profiling
    
    [webView setHostWindow:window];
    [window.contentView addSubview:webView];
    
    [window.contentView setBackgroundColor:[NSColor clearColor]];
     
    _allowPageLoad = true;
    
    WebListener *webListener = [[WebListener alloc] init];
    
    [webListener  setOfView: this];
    
    //more delegate options here https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/DisplayWebContent/Concepts/WebKitDesign.html#//apple_ref/doc/uid/20002024-128170
   // [webView setPolicyDelegate:webListener];
    //[webView setFrameLoadDelegate:webListener];
    //[webView setResourceLoadDelegate:webListener];
    

    
    
}
ofxWebView::~ofxWebView(){
    
   // [window.contentView removeView:webView];
    //webView = 0;
};



bool ofxWebView::getAllowPageLoad(){
    return _allowPageLoad;

};


void ofxWebView::setAllowPageLoad(bool s){
    _allowPageLoad = s;
};


void ofxWebView::loadURL(string _url){
    NSString *str = [NSString stringWithUTF8String:_url.c_str()];
    NSURL * url = [NSURL URLWithString:str];
    NSURLRequest * req = [NSURLRequest requestWithURL:url];
    [[webView mainFrame] loadRequest:req];
    



};


void ofxWebView::loadFile(string file, bool relativeToData){
    
    if(!ofFile::doesFileExist(file,relativeToData)){
        ofLogError()<<"File "<<file<<" not found"<<endl;
        return;
    }
    
    NSString *str;
    
    if(relativeToData){
        ofFile f;
        f.open(file);
        str = [NSString stringWithUTF8String:f.getAbsolutePath().c_str()];
    }else{
        str = [NSString stringWithUTF8String:file.c_str()];
    }
    NSURL * url = [NSURL fileURLWithPath:str];
    NSURLRequest * req = [NSURLRequest requestWithURL:url];
    [[webView mainFrame] loadRequest:req];
}



void ofxWebView::setHTML(string htm,string base){
    NSString *str = [NSString stringWithUTF8String:htm.c_str()];
    NSString *bStr = [NSString stringWithUTF8String:base.c_str()];
    NSURL * bUrl = [NSURL fileURLWithPath:bStr];
    [[webView mainFrame] loadHTMLString:str baseURL:bUrl];

};

void ofxWebView::setDrawsBackground(bool b){
    
    _drawBg = b;

    
    [webView setDrawsBackground:_drawBg];

};


bool ofxWebView::getDrawBackground(){
    return _drawBg;
};

void ofxWebView::toTexture(ofTexture *tex){
    
    //NSSize imgSize = webView.bounds.size;
    //NSBitmapImageRep * bir = [webView bitmapImageRepForCachingDisplayInRect:[webView bounds]];
    //[bir setSize:imgSize];
    //[webView cacheDisplayInRect:[webView bounds] toBitmapImageRep:bir];
    //NSBitmapToOFTexture(bir, tex,imgSize.width,imgSize.height);
    
    
    
    //NSRect f = (NSRect){getX(), -getY(), getWidth(), getHeight()};

    
    NSRect f = (NSRect){0,0, getWidth(), getHeight()};
    NSBitmapImageRep * bir = [webView bitmapImageRepForCachingDisplayInRect:f];
    [webView cacheDisplayInRect:f toBitmapImageRep:bir];
    NSBitmapToOFTexture(bir, tex,getWidth(),getHeight());

};

void ofxWebView::setPosition(int x, int y){
    ofRectangle::setX(x);
    ofRectangle::setY(y);
    setWebViewFrame((ofRectangle)*this);
};


void ofxWebView::setSize(int w, int h){
    ofRectangle::setWidth(w);
    ofRectangle::setHeight(h);
    setWebViewFrame((ofRectangle)*this);
};


ofRectangle ofxWebView::getSize(){
    return ofRectangle((ofRectangle)*this);
};


void ofxWebView::setWebViewFrame(ofRectangle frame) {
    NSRect f;
    if(frame.isEmpty()) {
        f = NSMakeRect([window.contentView bounds].origin.x, [window.contentView bounds].origin.y, [window.contentView bounds].size.width, [window.contentView bounds].size.height);
    } else {
        //y upside down?
        f = (NSRect){frame.x, -frame.y, frame.width, frame.height};
    }
    [webView setFrame:f];
    
}
