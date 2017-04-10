import std.stdio;
import rx;
import quickarmos;
static import ar = armos;

class QuickArmos: ar.app.BaseApp{
	this(){
        _keyEvents = new SubjectObject!KeyEvent;
        _mouseEvents = new SubjectObject!MouseEvent;
        _editor = new Editor;
    }
	
	override void setup(){}
	
	override void update(){}
	
	override void draw(){
        _editor.draw;
    }
	
	override void keyPressed(ar.utils.KeyType key){
        _keyEvents.put(KeyEvent(KeyEventType.Pressed, key));
    }
	
    override void keyReleased(ar.utils.KeyType key){
        _keyEvents.put(KeyEvent(KeyEventType.Released, key));
    }
	
	override void mouseMoved(ar.math.Vector2i position, int button){
        _mouseEvents.put(MouseEvent(MouseEventType.Moved, position));
    }
	
	override void mousePressed(ar.math.Vector2i position, int button){
        _mouseEvents.put(MouseEvent(MouseEventType.Pressed, position));
    }
	
	override void mouseReleased(ar.math.Vector2i position, int button){
        _mouseEvents.put(MouseEvent(MouseEventType.Released, position));
    }

    private{
        Subject!KeyEvent _keyEvents;
        Subject!MouseEvent _mouseEvents;
        Editor _editor;
    }
}

void main(){
    version(unittest){
    }else{
        ar.app.run(new QuickArmos);
    }
}
