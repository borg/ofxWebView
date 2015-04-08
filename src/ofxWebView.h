/*
 *  ofxWebView.h
 *  WebView

 *
 *  Created by Andreas Borg on 06/04/2015
 *  Copyright 2015 __MyCompanyName__. All rights reserved.
 *  
 *
 *   Proof od concept
 *   http://forum.openframeworks.cc/t/using-cef-with-of/18094/15
 
 *  Font rendering not so crips in texture grab...room for improvement.
 *  Also not tested with passing javascript
 
 */

#ifndef _ofxWebView
#define _ofxWebView

#include "ofMain.h"

#include "ofAppGLFWWindow.h"
#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>




class WebViewEvent : public ofEventArgs {
    
public:
    
    WebViewEvent(){};
    string URL;
   
};





class ofxWebView : ofRectangle {
	
  public:
	
	ofxWebView();
    ~ofxWebView();

    
    void loadURL(string url);
    void loadFile(string file);//local html
    void setHTML(string htm,string base="");
    
    void toTexture(ofTexture *tex);
    
    void setSize(int w, int h);
    ofRectangle getSize();
    void setPosition(int x, int y);
    
    void setDrawsBackground(bool b);
    bool getDrawBackground();
    
    ofEvent <WebViewEvent> LOAD_URL;
    
    bool getAllowPageLoad();
    void setAllowPageLoad(bool s);
    
protected:
    void setWebViewFrame(ofRectangle frame);
    
    bool _allowPageLoad;
    bool _drawBg;
    
    //WebListener *webListener;
    WebView * webView;
    NSWindow * window;
    

};







@interface WebListener: NSObject<WebPolicyDecisionListener>{
    ofxWebView * _ofView;
}

- (void) webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request  frame:(WebFrame *)frame decisionListener:(id )listener;

- (void) webView:(WebView *)webView decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame  decisionListener:(id )listener;


-(void) setOfView: (ofxWebView *) _ofView;

@end;




#endif
