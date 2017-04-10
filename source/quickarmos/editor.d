module quickarmos.editor;

import quickarmos.text;
import armos.graphics.font:Font;
import armos.math.vector:Vector2i;

/++
+/
class Editor {
    private alias This = typeof(this);
    public{
        this(){
            _font = new Font;
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
            _font = (new Font).load(fontPath, 32, true);
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
        This cursorPosition(in Vector2i p){
            import std.algorithm:clamp;
            auto upperLimitY = p.y.clamp(0, _text.lines.length-1);
            auto upperLimitX = p.x.clamp(0, _text.lines[upperLimitY].content.length);
            _cursorPosition = Vector2i(p.x.clamp(0, upperLimitX),
                                       p.y.clamp(0, upperLimitY));
            return this;
        }

        ///
        Vector2i cursorPosition()const{
            return _cursorPosition;
        }

        unittest{
            auto editor = new Editor;
            editor.loadString("foo\nbar")
                  .cursorPosition(Vector2i(1, 0));
            assert(editor.cursorPosition == Vector2i(1, 0));

            editor.cursorPosition(Vector2i(3, 0));
            assert(editor.cursorPosition == Vector2i(3, 0));

            editor.cursorPosition(Vector2i(1, 3));
            assert(editor.cursorPosition == Vector2i(1, 1));
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
                    cursorPosition = Vector2i(0, cursorPosition.y+1);
                    break;
                default:
                    _text.lines[_cursorPosition.y].content =  head ~ c ~ tail;
                    cursorPosition = Vector2i(cursorPosition.x+1, cursorPosition.y);
            }
            return this;
        }

        unittest{
            auto editor = new Editor;

            editor.loadString("foo\nbar")
                  .cursorPosition(Vector2i(1, 0))
                  .insert('x');
            assert(editor._text.toString == "fxoo\nbar");
            assert(editor.cursorPosition == Vector2i(2, 0));

            editor.cursorPosition(Vector2i(3, 1))
                  .insert('x');
            assert(editor._text.toString == "fxoo\nbarx");

            editor.cursorPosition(Vector2i(2, 0))
                  .insert('\n');
            assert(editor._text.toString == "fx\noo\nbarx");
            assert(editor._text.lines.length == 3);
            assert(editor.cursorPosition == Vector2i(0, 1));

            editor.cursorPosition(Vector2i(4, 2))
                  .insert('\n');
            assert(editor._text.toString == "fx\noo\nbarx\n");
            assert(editor._text.lines.length == 4);
            assert(editor.cursorPosition == Vector2i(0, 3));
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
                    cursorPosition = Vector2i(preLineLength.to!int, cursorPosition.y-1);
                }
            }else{
                immutable head = _text.lines[_cursorPosition.y].content[0.._cursorPosition.x-1];
                immutable tail = _text.lines[_cursorPosition.y].content[_cursorPosition.x..$];
                _text.lines[_cursorPosition.y].content =  head ~ tail;
                cursorPosition = Vector2i(cursorPosition.x-1, cursorPosition.y);
            }
            return this;
        }

        unittest{
            auto editor = new Editor;

            editor.loadString("hoge\nmoge")
                  .cursorPosition(Vector2i(1, 0))
                  .remove;
            assert(editor._text.toString == "oge\nmoge");

            editor.cursorPosition(Vector2i(3, 0))
                  .remove;
            assert(editor._text.toString == "og\nmoge");

            editor.cursorPosition(Vector2i(0, 1))
                  .remove;
            assert(editor._text.toString == "ogmoge");
            assert(editor.cursorPosition == Vector2i(2, 0));
        }

    }//public

    private{
        Text _text;
        Font _font;
        Vector2i _cursorPosition;
    }//private
}//class Editor
