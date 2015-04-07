#include "ofApp.h"

/*
 Very important.
 Make sure to set the Type of this file to Objective-C++ Source in the Xcode
 Identity and Type inspector  over here ---------------------------------------------------------->
 Also rename cpp to mm and add WebKit framework
 */


//--------------------------------------------------------------
void ofApp::setup(){
    
    ofSetFrameRate(60);
    //loading a web URL:
    int margin = 10;
    webView.setSize(ofGetWidth()/2-margin*2,ofGetHeight()-margin*2);
    webView.setPosition(margin,margin);
    
    ofAddListener(webView.LOAD_URL,this,&ofApp::onPageLoad);
    
    
    //doesn't seem to support WebGL
    //webView.loadURL("http://threejs.org/examples/#webgl_buffergeometry_rawshader");
    webView.loadURL("http://localprojects.net");
    
    bg = 0;
    
}

void ofApp::onPageLoad(WebViewEvent &e){
    cout<<"This stuff is being loaded now "<<e.URL<<endl;
    
    
    //if you want to block it..maybe to extract javascript variables
    //webView.setAllowPageLoad(false);

};

//--------------------------------------------------------------
void ofApp::update(){
}




//--------------------------------------------------------------
void ofApp::draw(){
    
     ofSetColor(255);
    if(bg){
        bg->draw(ofGetWidth()/2,0,ofGetWidth()/2,ofGetHeight());
    }else{
        ofDrawBitmapString("Press space to capture browser view as texture", ofGetWidth()/2+10,10);
    }
}

//--------------------------------------------------------------
void ofApp::keyPressed(int key){
    if(key ==' '){
        if(bg){
            delete bg;
        }
        bg = new ofTexture();
        bg->allocate(ofGetWidth()/2,ofGetHeight(),GL_RGB);
        
        webView.toTexture(bg);
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
    startPos.set(x,y);
}

//--------------------------------------------------------------
void ofApp::mouseReleased(int x, int y, int button){
    
    ofRectangle r(startPos.x,startPos.y,x,y);
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

