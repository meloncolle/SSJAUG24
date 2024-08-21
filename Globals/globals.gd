# Try to use this sparingly...

extends Node

# testing config stuff...
const ENABLE_SKIP_TITLE_SCREEN: bool = true 
const ENABLE_COLLISION_DEBUG_IN_EXPORT: bool = true
const ENABLE_INFINITE_FUEL: bool = true
const ENABLE_SWITCHING_BALLS: bool = true

# for setting star gravity in editor
const MAX_GRAVITY: float = 4096
const MIN_GRAVITY: float = MAX_GRAVITY * -1

# gravity boost stuff
const GRAVITY_BOOST_LIMIT: float = 4096
const GRAVITY_BOOST_SPEED: float = 50

var sceneController: Node = null
