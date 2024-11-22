// File: EndlessScroller.hx

function create() {
    // Example initialization of object positions
    treesNormal2.x = 0;
    treesNormal22.x = treesNormal2.width; // Clone starts right after the main object

    mtn.x = 0;
    mtn2.x = mtn.width; // Clone starts right after the main object
}

function update(elapsed:Float) {
    // Move and reset objects endlessly based on their specific limits
    moveEndlessly(grass, grass2, 1, "Left", -1090, 1900);
    moveEndlessly(treesNormal2, treesNormal22, 2, "Left", -800, 1900);
    // moveEndlessly(mtn, mtn2, 6, "Left", -100, 1900);
    moveObject(mtn, 20, "Left");
    moveEndlessly(sky, sky2, 8, "Left", -800, 1900);
    // trace(mtn.x + mtn.width);
}

/**
 * Moves two objects endlessly with custom limits for seamless looping.
 * 
 * @param Obj Main object to move.
 * @param Clone Clone object to move and reset.
 * @param Depth Speed factor for movement.
 * @param Direction Direction of movement ("Left" or "Right").
 * @param Limit Custom off-screen position where the object resets.
 * @param ResetPos Position to reset the object to (usually the end of the clone).
 */
function moveEndlessly(Obj, Clone, Depth:Float, Direction:String, Limit:Float, ResetPos:Float) {
    // Move both objects
    moveObject(Obj, Depth, Direction);
    moveObject(Clone, Depth, Direction);

    // Reset positions when objects go out of bounds
    if (Direction == "Left") {
        if (Obj.x + Obj.width <= Limit) {
            Obj.x = Clone.x + Clone.width; // Place Obj right after Clone
        }
        if (Clone.x + Clone.width <= Limit) {
            Clone.x = Obj.x + Obj.width; // Place Clone right after Obj
        }
    } else if (Direction == "Right") {
        if (Obj.x >= Limit) {
            Obj.x = Clone.x - Obj.width; // Place Obj right before Clone
        }
        if (Clone.x >= Limit) {
            Clone.x = Obj.x - Clone.width; // Place Clone right before Obj
        }
    }
}

/**
 * Moves an object in the specified direction.
 * 
 * @param Obj The object to move.
 * @param Depth Speed factor for movement.
 * @param Direction Direction of movement ("Left" or "Right").
 */
function moveObject(Obj, Depth:Float, Direction:String) {
    var Speed = 10; // Base speed
    if (Direction == "Left") {
        Obj.x -= Speed / Depth; // Move left
    } else if (Direction == "Right") {
        Obj.x += Speed / Depth; // Move right
    }
}
