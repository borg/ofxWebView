#include "ofApp.h"

/*
 Very important.
 Make sure to set the Type of this file to Cobjective-C++ Source in the Xcode
 Identity and Type inspector  over here ---------------------------------------------------------->
 Also rename cpp to mm and add WebKit framework
 */


//--------------------------------------------------------------
void ofApp::setup(){
    
    ofSetFrameRate(60);
    
    
    ofEnableSmoothing();
    ofEnableAlphaBlending();
    
    
    
    //loading a web URL:
    int margin =  0;
    webView.setSize(ofGetWidth()/2-margin*2,ofGetHeight()-margin*2);
    webView.setPosition(margin,margin);
    
    ofAddListener(webView.LOAD_URL,this,&ofApp::onPageLoad);
    
    //doesn't seem to support WebGL
    //webView.loadURL("http://threejs.org/examples/#webgl_buffergeometry_rawshader");
    //webView.loadURL("http://localprojects.net");
    webView.loadURL("http://crea.tion.to/");
    
    bg = 0;
    bg = new ofTexture();
    bg->allocate(webView.getWidth(),webView.getHeight(),GL_RGBA);
    bg->clear();
    
    
    autoRefresh = 0;
    
}

void ofApp::onPageLoad(WebViewEvent &e){
    cout<<"This stuff is being loaded now "<<e.URL<<endl;
    
    
    //if you want to block it..maybe to extract javascript variables
    //webView.setAllowPageLoad(false);
    
};

//--------------------------------------------------------------
void ofApp::update(){
    if(autoRefresh){
        webView.toTexture(bg);
    }
}




//--------------------------------------------------------------
void ofApp::draw(){
    
    ofBackground(50);
    ofSetColor(255);
    if(bg){
        ofEnableAlphaBlending();
        bg->draw(ofGetWidth()/2,webView.getY(),webView.getWidth(),webView.getHeight());
    }else{
        ofDrawBitmapString("Press space to capture browser view as texture", ofGetWidth()/2+10,10);
    }
    
    ofSetWindowTitle(ofToString((int)ofGetFrameRate()));
}

//--------------------------------------------------------------
void ofApp::keyPressed(int key){
    if(key ==' '){
        if(bg){
            bg->clear();
        }
        webView.toTexture(bg);
    }
    
    if(key=='l'){
        string htm = "<html><body><font color='#fa6b7d' face='Verdana' size='20'>Lorem ipsum yada yada</font></body></html>";
        webView.setHTML(htm);
    }
    
    if(key == 'f'){
        ofToggleFullscreen();
    }
    
    if(key =='b'){
        webView.setDrawsBackground( !webView.getDrawBackground());
    }
    
    if(key  == 'r'){
        webView.loadURL("http://localprojects.net");
    }
    
    if(key =='a'){
        autoRefresh = !autoRefresh;
    }
}

//--------------------------------------------------------------
void ofApp::keyReleased(int key){
    
}

//--------------------------------------------------------------
void ofApp::mouseMoved(int x, int y ){
    
}

//--------------------------------------------------------------
void ofApp::mouseDragged(int x, int y, int button){
    
}

//--------------------------------------------------------------
void ofApp::mousePressed(int x, int y, int button){
    //startPos.set(x,y);
}

//--------------------------------------------------------------
void ofApp::mouseReleased(int x, int y, int button){
    
    //ofRectangle r(startPos.x,startPos.y,x,y);
    //setWebViewFrame(r);
}

//--------------------------------------------------------------
void ofApp::windowResized(int w, int h){
    
}

//--------------------------------------------------------------
void ofApp::gotMessage(ofMessage msg){
    cout<<"ofApp::gotMessage "<<msg.message<<endl;
}

//--------------------------------------------------------------
void ofApp::dragEvent(ofDragInfo dragInfo){
    
}

