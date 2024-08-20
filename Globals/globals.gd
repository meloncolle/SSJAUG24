# Try to use this sparingly...

extends Node

# testing config stuff...
const SKIP_TITLE: bool = true 
const ENABLE_COLLISION_DEBUG_IN_EXPORT: bool = true

# for setting star gravity in editor
const MAX_GRAVITY: float = 4096
const MIN_GRAVITY: float = MAX_GRAVITY * -1

var sceneController: Node = null
