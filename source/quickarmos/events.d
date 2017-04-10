module quickarmos.events;

import armos.utils.keytype:KeyType;
import armos.math.vector:Vector2i;

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
        this(in KeyEventType eventType, in KeyType k){
            _eventType = eventType;
            _key = k;
        };

        ///
        KeyType key()const{
            return _key;
        }

        ///
        KeyEventType eventType()const{
            return _eventType;
        }
    }//public

    private{
        KeyEventType _eventType;
        KeyType _key;
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
        this(in MouseEventType e, in Vector2i Position){

        }

        ///
        MouseEventType eventType()const{
            return _eventType;
        }

        /// 
        Vector2i position()const{
            return _position;
        }
    }//public

    private{
        MouseEventType _eventType;
        Vector2i _position;
    }//private
}//struct MouseEvent
