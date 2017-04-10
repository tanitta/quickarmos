module quickarmos.text;

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
