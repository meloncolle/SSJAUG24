class_name Enums

enum GameState {ON_START, IN_GAME, PAUSED}

# FOR SANDBOX MODE (CURRENT) ONLY USING FIRST 3 STAGES
enum LevelState {
	INIT,		# Initial state for loading stuff
	READY,		# Ready to select ball and swing
	IN_SWING,	# Started swing, waiting for player to release
	GRAVITY,	# Swing happened, can manip gravity now
	DEAD		# Fail state? idk if/how to use this
	}
enum BallState {READY, IN_SWING, WAITING}
