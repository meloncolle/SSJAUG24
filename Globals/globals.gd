extends Node

# -----STUFF FOR TESTING CONFIG----- #
# Go straight to first level
const ENABLE_SKIP_TITLE_SCREEN: bool = true
# Show debug collision shapes in build 
const ENABLE_COLLISION_DEBUG_IN_EXPORT: bool = true
# Don't drain fuel when we hit ball
const ENABLE_INFINITE_FUEL: bool = false
# Can press space to select next ball
const ENABLE_SWITCHING_BALLS: bool = true
# true: Player scores points on contact w/ collectible
# false: Collectibles 'carried' by ball, and points granted when reaching black hole
const ENABLE_SIMPLE_COLLECTIBLES: bool = false


# for setting star gravity in editor
const MAX_GRAVITY: float = 4096
const MIN_GRAVITY: float = MAX_GRAVITY * -1

# gravity boost stuff
const GRAVITY_BOOST_LIMIT: float = 4096
const GRAVITY_BOOST_SPEED: float = 50

# fuel cost for 100% power swing
const MAX_FUEL_PER_SWING: float = 20

var sceneController: Node = null
