import std.stdio;
import rx;
static import ar = armos;

/++
+/
struct Line {
    size_t lines;
    string content;
}//struct Line

///
struct EditEvent{
};

/++
+/
struct Text {
    private alias This = typeof(this);

    public{
        ///
        this(in string str){
            lines = [];
            import std.algorithm:splitter;
            import std.range:array;
            foreach (size_t i, line; str.splitter('\n').array) {
                lines ~= Line();
                lines[$-1].lines = i;
                lines[$-1].content = line;
            }
        }

        ///
        string toString(){
            import std.algorithm:map;
            import std.array:join;
            return lines.map!(l => l.content).join("\n");
        };

        ///
        void put(in EditEvent e){
            // TODO
        }

        Line[] lines;
    }//public

    private{
    }//private
}//struct Text
unittest{
    {
        auto text = Text("foo\nbar");
        assert(text.lines[0].content == "foo");
        assert(text.lines[1].content == "bar");
    }

    {
        auto text = Text("foo\nbar\n");
        assert(text.lines[0].content == "foo");
        assert(text.lines[1].content == "bar");
    }

    {
        auto text = Text("\nfoo\nbar\n");
        assert(text.lines[0].content == "");
        assert(text.lines[1].content == "foo");
        assert(text.lines[2].content == "bar");
    }
}
unittest{
}

/++
+/
class Editor {
    private alias This = typeof(this);
    public{
        this(){
            _font = new ar.graphics.Font;
        }

        This setup(){
            string fontPath;
            version(OSX){
                fontPath = "/Library/Fonts/Futura.ttc";
            }
            version(Windows){
                fontPath = "C:\\Windows\\Fonts\\Arial\\arial.ttf";

            }
            version(linux){
                //TODO
            }
            _font = (new ar.graphics.Font).load(fontPath, 32, true);
            return this;
        }

        ///
        This draw(){
            return this;
        }

        ///
        This loadString(in string str){
            _text = Text(str);
            return this;
        }

        ///
        This cursorPosition(in ar.math.Vector2i p){
            import std.algorithm:clamp;
            auto upperLimitY = p.y.clamp(0, _text.lines.length-1);
            auto upperLimitX = p.x.clamp(0, _text.lines[upperLimitY].content.length-1);
            _cursorPosition = ar.math.Vector2i(p.x.clamp(0, upperLimitX),
                                               p.y.clamp(0, upperLimitY));
            return this;
        }

        ///
        ar.math.Vector2i cursorPosition()const{
            return _cursorPosition;
        }

        unittest{
            auto editor = new Editor;
            editor.loadString("foo\nbar")
                  .cursorPosition(ar.math.Vector2i(1, 0));
            assert(editor.cursorPosition == ar.math.Vector2i(1, 0));

            editor.cursorPosition(ar.math.Vector2i(3, 0));
            assert(editor.cursorPosition == ar.math.Vector2i(2, 0));

            editor.cursorPosition(ar.math.Vector2i(1, 3));
            assert(editor.cursorPosition == ar.math.Vector2i(1, 1));
        }

        ///
        This insert(in char c){
            //TODO
            _text.lines[_cursorPosition.y].content = _text.lines[_cursorPosition.y].content[0.._cursorPosition.x] ~ c ~ _text.lines[_cursorPosition.y].content[_cursorPosition.x .. $];
            return this;
        }
        unittest{
            auto editor = new Editor;
            editor.loadString("foo\nbar")
                .cursorPosition(ar.math.Vector2i(1, 0))
                .insert('x')
                ;
            assert(editor._text.toString == "fxoo\nbar");
        }
    }//public

    private{
        Text _text;
        ar.graphics.Font _font;
        ar.math.Vector2i _cursorPosition;
    }//private
}//class Editor

/++
+/
enum KeyEventType {
    Pressed, Released
}//enum KeyEventType

/++
+/
struct KeyEvent {
    public{
        ///
        this(in KeyEventType eventType, in ar.utils.KeyType k){
            _eventType = eventType;
            _key = k;
        };

        ///
        ar.utils.KeyType key()const{
            return _key;
        }

        ///
        KeyEventType eventType()const{
            return _eventType;
        }
    }//public

    private{
        KeyEventType _eventType;
        ar.utils.KeyType _key;
    }//private
}//struct KeyEvent

/++
+/
enum MouseEventType {
    Pressed, Released, Moved
}//enum MouseEvent

/++
+/
struct MouseEvent {
    public{
        ///
        this(in MouseEventType e, in ar.math.Vector2i Position){

        }

        ///
        MouseEventType eventType()const{
            return _eventType;
        }

        /// 
        ar.math.Vector2i position()const{
            return _position;
        }
    }//public

    private{
        MouseEventType _eventType;
        ar.math.Vector2i _position;
    }//private
}//struct MouseEvent

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
