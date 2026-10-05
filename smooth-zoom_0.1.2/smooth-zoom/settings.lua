data:extend({
  {
    type = "int-setting",
    name = "smooth-zoom-step",
    setting_type = "runtime-per-user",
    default_value = 20,
    minimum_value = 1,
    maximum_value = 40,
    order = "a",
    localised_name = "setting-smooth-zoom-step",
    localised_description = "setting-smooth-zoom-step-desc"
  },
  {
    type = "int-setting",
    name = "smooth-zoom-smoothness",
    setting_type = "runtime-per-user",
    default_value = 20,
    minimum_value = 1,
    maximum_value = 100,
    order = "b",
    localised_name = "setting-smooth-zoom-smoothness",
    localised_description = "setting-smooth-zoom-smoothness-desc"
  },
  {
    type = "int-setting",
    name = "smooth-zoom-inertia",
    setting_type = "runtime-per-user",
    default_value = 20,
    minimum_value = 0,
    maximum_value = 100,
    order = "c",
    localised_name = "setting-smooth-zoom-inertia",
    localised_description = "setting-smooth-zoom-inertia-desc"
  }
})
