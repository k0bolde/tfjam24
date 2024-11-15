extends Node
# put signals here that can be called from anywhere with Events.the_signal.emit()
# warnings are ignored because we don't use them in this class but globally

@warning_ignore("unused_signal")
signal battle_start(monsters:Array, can_run:bool)
@warning_ignore("unused_signal")
signal battle_end

@warning_ignore("unused_signal")
signal dialogue_start(clyde_file)
@warning_ignore("unused_signal")
signal dialogue_ended
