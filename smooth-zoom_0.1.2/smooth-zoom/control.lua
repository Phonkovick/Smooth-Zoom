local function get_state(player_index)
  storage.smooth_zoom = storage.smooth_zoom or {}
  storage.smooth_zoom[player_index] = storage.smooth_zoom[player_index] or {}
  return storage.smooth_zoom[player_index]
end

local function setup_player(player_index)
  local player = game.get_player(player_index)
  if not player then return end

  local state = get_state(player_index)
  state.target_zoom = player.zoom
  state.inertia_target = player.zoom
  state.phase = 0
  state.active = false
end

local function change_target(player_index, direction)
  local player = game.get_player(player_index)
  if not player or not player.valid then return end

  local state = get_state(player_index)
  local current_zoom = player.zoom
  local settings_for_player = settings.get_player_settings(player)
  local step = settings_for_player["smooth-zoom-step"].value / 100
  local inertia = settings_for_player["smooth-zoom-inertia"].value / 100

  -- Main zoom movement for this wheel tick.
  local main_target = current_zoom * (1 + direction * step)
  main_target = math.max(0.01, math.min(100.0, main_target))

  -- Optional small "slide" after the main movement.
  -- 0% = no extra movement, 100% = up to 25% of one wheel step extra.
  local extra_distance = math.abs(main_target - current_zoom) * inertia * 0.25
  local inertia_target = main_target + direction * extra_distance
  inertia_target = math.max(0.01, math.min(100.0, inertia_target))

  state.target_zoom = main_target
  state.inertia_target = inertia_target
  state.phase = inertia > 0 and 1 or 0
  state.active = true
end

script.on_init(function()
  storage.smooth_zoom = {}
  for _, player in pairs(game.players) do
    setup_player(player.index)
  end
end)

script.on_configuration_changed(function()
  storage.smooth_zoom = storage.smooth_zoom or {}
  for _, player in pairs(game.players) do
    if not storage.smooth_zoom[player.index] then
      setup_player(player.index)
    end
  end
end)

script.on_event(defines.events.on_player_created, function(event)
  setup_player(event.player_index)
end)

script.on_event("smooth-zoom-in", function(event)
  change_target(event.player_index, 1)
end)

script.on_event("smooth-zoom-out", function(event)
  change_target(event.player_index, -1)
end)

script.on_event(defines.events.on_tick, function()
  if not storage.smooth_zoom then return end

  for player_index, state in pairs(storage.smooth_zoom) do
    if state.active then
      local player = game.get_player(player_index)

      if player and player.valid then
        local current = player.zoom
        local target = state.target_zoom or current
        local player_settings = settings.get_player_settings(player)
        local smoothness = player_settings["smooth-zoom-smoothness"].value / 100

        -- Exponential easing: higher values reach the current target faster.
        local next_zoom = current + (target - current) * smoothness

        if math.abs(target - current) < 0.0005 then
          player.zoom = target

          if state.phase == 1 and state.inertia_target and math.abs(state.inertia_target - target) >= 0.0005 then
            -- Main movement finished: now let the camera "slide" a little further.
            state.target_zoom = state.inertia_target
            state.phase = 0
          else
            state.active = false
            state.phase = 0
          end
        else
          player.zoom = next_zoom

          -- If the engine clamps the zoom to its real limit, adopt the clamped value.
          local applied = player.zoom
          if math.abs(applied - next_zoom) > 0.0005 then
            state.target_zoom = applied
            state.inertia_target = applied
            state.phase = 0
          end
        end
      else
        state.active = false
      end
    end
  end
end)
