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

        ///
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
            auto upperLimitX = p.x.clamp(0, _text.lines[upperLimitY].content.length);
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
            assert(editor.cursorPosition == ar.math.Vector2i(3, 0));

            editor.cursorPosition(ar.math.Vector2i(1, 3));
            assert(editor.cursorPosition == ar.math.Vector2i(1, 1));
        }

        ///
        This insert(in char c){
            immutable head = _text.lines[_cursorPosition.y].content[0.._cursorPosition.x];
            immutable tail = _text.lines[_cursorPosition.y].content[_cursorPosition.x..$];
            switch (c) {
                case '\n':
                    auto newLine =  Line();
                    newLine.lines = _cursorPosition.y+1;
                    newLine.content = tail;
                    _text.lines[_cursorPosition.y].content =  head;
                    import std.array:insertInPlace;
                    _text.lines.insertInPlace(_cursorPosition.y+1, newLine);
                    cursorPosition = ar.math.Vector2i(0, cursorPosition.y+1);
                    break;
                default:
                    _text.lines[_cursorPosition.y].content =  head ~ c ~ tail;
                    cursorPosition = ar.math.Vector2i(cursorPosition.x+1, cursorPosition.y);
            }
            return this;
        }

        unittest{
            auto editor = new Editor;

            editor.loadString("foo\nbar")
                  .cursorPosition(ar.math.Vector2i(1, 0))
                  .insert('x');
            assert(editor._text.toString == "fxoo\nbar");
            assert(editor.cursorPosition == ar.math.Vector2i(2, 0));

            editor.cursorPosition(ar.math.Vector2i(3, 1))
                  .insert('x');
            assert(editor._text.toString == "fxoo\nbarx");

            editor.cursorPosition(ar.math.Vector2i(2, 0))
                  .insert('\n');
            assert(editor._text.toString == "fx\noo\nbarx");
            assert(editor._text.lines.length == 3);
            assert(editor.cursorPosition == ar.math.Vector2i(0, 1));

            editor.cursorPosition(ar.math.Vector2i(4, 2))
                  .insert('\n');
            assert(editor._text.toString == "fx\noo\nbarx\n");
            assert(editor._text.lines.length == 4);
            assert(editor.cursorPosition == ar.math.Vector2i(0, 3));
        }

        ///
        This remove(){
            if (_cursorPosition.x == 0) {
                if (_cursorPosition.y == 0) {
                    // none
                }else{
                    immutable preLineLength =  _text.lines[_cursorPosition.y-1].content.length;

                    auto newLine = Line();
                    newLine.lines = _cursorPosition.y-1;
                    newLine.content = _text.lines[_cursorPosition.y-1].content ~ _text.lines[_cursorPosition.y].content;
                    _text.lines[_cursorPosition.y-1] = newLine;
                    import std.algorithm:remove;
                    _text.lines = _text.lines.remove(_cursorPosition.y);
                    import std.conv:to;
                    cursorPosition = ar.math.Vector2i(preLineLength.to!int, cursorPosition.y-1);
                }
            }else{
                immutable head = _text.lines[_cursorPosition.y].content[0.._cursorPosition.x-1];
                immutable tail = _text.lines[_cursorPosition.y].content[_cursorPosition.x..$];
                _text.lines[_cursorPosition.y].content =  head ~ tail;
                cursorPosition = ar.math.Vector2i(cursorPosition.x-1, cursorPosition.y);
            }
            return this;
        }

        unittest{
            auto editor = new Editor;

            editor.loadString("hoge\nmoge")
                  .cursorPosition(ar.math.Vector2i(1, 0))
                  .remove;
            assert(editor._text.toString == "oge\nmoge");

            editor.cursorPosition(ar.math.Vector2i(3, 0))
                  .remove;
            assert(editor._text.toString == "og\nmoge");

            editor.cursorPosition(ar.math.Vector2i(0, 1))
                  .remove;
            assert(editor._text.toString == "ogmoge");
            assert(editor.cursorPosition == ar.math.Vector2i(2, 0));
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
