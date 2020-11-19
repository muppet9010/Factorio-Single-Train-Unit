data:extend(
    {
        {
            name = "single_train_unit-wagon_capacity_percentage",
            type = "int-setting",
            default_value = 50,
            minimum_value = 0,
            setting_type = "startup",
            order = "1001"
        },
        {
            name = "single_train_unit-weight_percentage",
            type = "int-setting",
            default_value = 70,
            minimum_value = 1,
            setting_type = "startup",
            order = "1002"
        },
        {
            name = "single_train_unit-burner_effectivity_percentage",
            type = "int-setting",
            default_value = 50,
            minimum_value = 1,
            setting_type = "startup",
            order = "1003"
        },
        {
            name = "single_train_unit-burner_inventory_size",
            type = "int-setting",
            default_value = 1,
            minimum_value = 1,
            setting_type = "startup",
            order = "1004"
        },
        {
            name = "single_train_unit-disable_regular_rollingstock",
            type = "bool-setting",
            default_value = false,
            setting_type = "startup",
            order = "2001"
        },
        {
            name = "single_train_unit-disable_regular_rollingstock_whitelist",
            type = "string-setting",
            allow_blank = true,
            default_value = "",
            setting_type = "startup",
            order = "2002"
        },
        {
            name = "single_train_unit-use_wip_graphics",
            type = "bool-setting",
            default_value = false,
            setting_type = "startup",
            order = "9001"
        }
    }
)
