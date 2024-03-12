extends WorldEnvironment

func _ready():
	if not GameSettings.setting_changed.is_connected(_on_setting_changed):
		GameSettings.setting_changed.connect(_on_setting_changed)
	set_graphics(GameSettings.graphics)

func _on_setting_changed(key: StringName, value: Variant):
	if key == &"graphics":
		set_graphics(value)

func set_graphics(graphics: GameSettings.Graphics):
	environment.ssr_enabled = graphics >= GameSettings.Graphics.PRETTY
	environment.ssil_enabled = graphics >= GameSettings.Graphics.PRETTY
	environment.sdfgi_enabled = graphics >= GameSettings.Graphics.BALANCED
	environment.volumetric_fog_enabled = graphics >= GameSettings.Graphics.BALANCED
	environment.fog_enabled = graphics < GameSettings.Graphics.BALANCED
