--[[
    "margin" and "padded" are 4 pixels. Margin offsets on the top and left of the outside of the element. Padded keeps inside things away from the bottom and right of the elements. Unlimited things with margin should be stackable inside the padded thing. Margin and Padded combines both for elements that are inside others and have their own contents.

    These styles expect to be called by gui-util which will handle the version number in the style name.

    This file is now version controlled to avoid conflicts with different versions used by different mods.

    Require the file and call GeneratePrototypes in data.lua:
        require("utility/style-data").GeneratePrototypes()
]]
local styleData = {}

styleData.styleVersion = "_1_0_0"

styleData.GeneratePrototypes = function()
    local Colors = require("utility/colors")
    local defaultStyle = data.raw["gui-style"]["default"]

    local frameShadowRisenColor = {0, 0, 0, 0.35}
    local frameShadowSunkenColor = {0, 0, 0, 1}
    local frameShadowRisen = function()
        return {
            position = {183, 128},
            corner_size = 8,
            tint = frameShadowRisenColor,
            scale = 0.5,
            draw_type = "inner"
        }
    end
    local frameShadowSunken = function()
        return {
            position = {200, 128},
            corner_size = 8,
            tint = frameShadowSunkenColor,
            scale = 0.5,
            draw_type = "outer"
        }
    end

    --FLOW
    for _, direction in pairs({{"_horizontal", "horizontal"}, {"_vertical", "vertical"}}) do
        for _, margin in pairs({{"", 0, 0, 0, 0}, {"_marginTL", 4, 4, 0, 0}}) do
            for _, padding in pairs({{"", 0, 0, 0, 0}, {"_paddingBR", 0, 0, 4, 4}}) do
                for _, spacing in pairs({{"", 0}, {"_spaced", 4}}) do
                    defaultStyle["muppet_flow" .. direction[1] .. margin[1] .. padding[1] .. spacing[1] .. styleData.styleVersion] = {
                        type = direction[2] .. "_flow_style",
                        left_margin = margin[2],
                        top_margin = margin[3],
                        right_margin = margin[4],
                        bottom_margin = margin[5],
                        left_padding = padding[2],
                        top_padding = padding[3],
                        right_padding = padding[4],
                        bottom_padding = padding[5],
                        [direction[2] .. "_spacing"] = spacing[2]
                    }
                end
            end
        end
    end

    --FRAME - the shadow types include padding/margins to handle the graphics. take this in to account if overwriting the values.
    for _, graphic in pairs(
        {
            {"_main", {base = {position = {0, 0}, corner_size = 8}}, 0, 0},
            {"_main_shadowSunken", {base = {position = {0, 0}, corner_size = 8}, shadow = frameShadowSunken()}, 2, 0},
            {"_main_shadowRisen", {base = {position = {0, 0}, corner_size = 8}, shadow = frameShadowRisen()}, 0, 2},
            {"_content", {base = {position = {68, 0}, corner_size = 8}}, 0, 0},
            {"_content_shadowSunken", {base = {position = {68, 0}, corner_size = 8}, shadow = frameShadowSunken()}, 2, 0},
            {"_content_shadowRisen", {base = {position = {68, 0}, corner_size = 8}, shadow = frameShadowRisen()}, 0, 2},
            {"_contentInnerDark", {base = {position = {34, 0}, corner_size = 8}}, 0, 0},
            {"_contentInnerDark_shadowSunken", {base = {position = {34, 0}, corner_size = 8}, shadow = frameShadowSunken()}, 2, 0},
            {"_contentInnerDark_shadowRisen", {base = {position = {34, 0}, corner_size = 8}, shadow = frameShadowRisen()}, 0, 2},
            {"_contentInnerLight", {base = {position = {0, 17}, corner_size = 8}}, 0, 0},
            {"_contentInnerLight_shadowSunken", {base = {position = {0, 17}, corner_size = 8}, shadow = frameShadowSunken()}, 2, 0},
            {"_contentInnerLight_shadowRisen", {base = {position = {0, 17}, corner_size = 8}, shadow = frameShadowRisen()}, 0, 2}
        }
    ) do
        for _, margin in pairs({{"", 0, 0, 0, 0}, {"_marginTL", 4, 4, 0, 0}}) do
            for _, padding in pairs({{"", 0, 0, 0, 0}, {"_paddingBR", 0, 0, 4, 4}}) do
                defaultStyle["muppet_frame" .. graphic[1] .. margin[1] .. padding[1] .. styleData.styleVersion] = {
                    type = "frame_style",
                    left_margin = margin[2] + graphic[3],
                    top_margin = margin[3] + graphic[3],
                    right_margin = margin[4] + graphic[3],
                    bottom_margin = margin[5] + graphic[3],
                    left_padding = padding[2] + graphic[4],
                    top_padding = padding[3] + graphic[4],
                    right_padding = padding[4] + graphic[4],
                    bottom_padding = padding[5] + graphic[4],
                    graphical_set = graphic[2]
                }
            end
        end
    end

    --SCROLL
    for _, margin in pairs({{"", 0, 0, 0, 0}, {"_marginTL", 4, 4, 0, 0}}) do
        for _, padding in pairs({{"", 0, 0, 0, 0}, {"_paddingBR", 0, 0, 4, 4}}) do
            defaultStyle["muppet_scroll" .. margin[1] .. padding[1] .. styleData.styleVersion] = {
                type = "scroll_pane_style",
                left_margin = 2 + margin[2],
                top_margin = 2 + margin[3],
                right_margin = 2 + margin[4],
                bottom_margin = 2 + margin[5],
                left_padding = padding[2],
                top_padding = padding[3],
                right_padding = padding[4],
                bottom_padding = padding[5],
                extra_left_padding_when_activated = 0,
                extra_top_padding_when_activated = 0,
                extra_right_padding_when_activated = 0,
                extra_bottom_padding_when_activated = 0
            }
        end
    end

    --TABLE
    for _, tableMargin in pairs({{"", 0, 0, 0, 0}, {"_marginTL", 4, 4, 0, 0}}) do
        for _, tablePadding in pairs({{"", 0, 0, 0, 0}, {"_paddingBR", 0, 0, 4, 4}}) do
            for _, cellPadding in pairs({{"", 0, 0, 0, 0}, {"_cellPadded", 4, 4, 4, 4}}) do
                for _, verticalSpaced in pairs({{"", 0}, {"_verticalSpaced", 4}}) do
                    for _, horizontalSpaced in pairs({{"", 0}, {"_horizontalSpaced", 4}}) do
                        defaultStyle["muppet_table" .. tableMargin[1] .. tablePadding[1] .. cellPadding[1] .. verticalSpaced[1] .. horizontalSpaced[1] .. styleData.styleVersion] = {
                            type = "table_style",
                            left_margin = tableMargin[2],
                            top_margin = tableMargin[3],
                            right_margin = tableMargin[4],
                            bottom_margin = tableMargin[5],
                            left_padding = tablePadding[2],
                            top_padding = tablePadding[3],
                            right_padding = tablePadding[4],
                            bottom_padding = tablePadding[5],
                            left_cell_padding = cellPadding[2],
                            top_cell_padding = cellPadding[3],
                            right_cell_padding = cellPadding[4],
                            bottom_cell_padding = cellPadding[5],
                            vertical_spacing = verticalSpaced[2],
                            horizontal_spacing = horizontalSpaced[2]
                        }
                    end
                end
            end
        end
    end

    --SPRITE
    for _, size in pairs({{"_32", 32}, {"_48", 48}, {"_64", 64}}) do
        defaultStyle["muppet_sprite" .. size[1] .. styleData.styleVersion] = {
            type = "image_style",
            width = size[2],
            height = size[2],
            margin = 0,
            padding = 0,
            scalable = true,
            stretch_image_to_widget_size = true
        }
    end

    --SPRITE BUTTON
    for _, attributes in pairs(
        {
            {"", {}},
            {"_frame", {default_graphical_set = {base = {position = {0, 0}, corner_size = 8}, shadow = {position = {440, 24}, corner_size = 8, draw_type = "outer"}}}},
            {"_noBorder", {default_graphical_set = {}, hovered_graphical_set = {}, clicked_graphical_set = {}}},
            {"_frameCloseButtonClickable", {default_graphical_set = {base = {position = {0, 0}, corner_size = 8}, shadow = {position = {440, 24}, corner_size = 8, draw_type = "outer"}}, padding = -6, width = 16, height = 16}}
        }
    ) do
        for _, size in pairs({{"", nil}, {"_mod", 36}, {"_smallText", 28}, {"_clickable", 16}, {"_32", 32}, {"_48", 48}, {"_64", 64}}) do
            local name = "muppet_sprite_button" .. attributes[1] .. size[1] .. styleData.styleVersion
            defaultStyle[name] = {
                type = "button_style",
                width = size[2],
                height = size[2],
                margin = 0,
                padding = 0,
                scalable = true,
                minimal_width = 0,
                minimal_height = 0
            }
            for k, v in pairs(attributes[2]) do
                if type(k) == "number" then
                    defaultStyle[name][k] = (defaultStyle[name][k] or 0) + v
                else
                    defaultStyle[name][k] = v
                end
            end
        end
    end

    --BUTTON
    for _, purpose in pairs({{"_text", Colors.black}, {"_heading", Colors.guiheadingcolor}}) do
        for _, textSize in pairs({{"_small", "_small"}, {"_medium", "_medium"}, {"_large", "_large"}}) do
            for _, boldness in pairs({{"", ""}, {"_semibold", "_semibold"}, {"_bold", "_bold"}}) do
                for _, attributes in pairs(
                    {
                        {"", {}},
                        {"_frame", {default_graphical_set = {base = {position = {0, 0}, corner_size = 8}, shadow = {position = {440, 24}, corner_size = 8, draw_type = "outer"}}, default_font_color = Colors.white, hovered_font_color = Colors.white, clicked_font_color = Colors.white}},
                        {"_noBorder", {default_graphical_set = {}, hovered_graphical_set = {}, clicked_graphical_set = {}}}
                    }
                ) do
                    for _, padding in pairs({{"", 0, -2, 0, -2}, {"_paddingSides", 4, 0, 4, 0}, {"_paddingNone", -2, -6, -2, -6}, {"_paddingTight", 0, -4, 0, -4}}) do
                        local name = "muppet_button" .. purpose[1] .. textSize[1] .. boldness[1] .. attributes[1] .. padding[1] .. styleData.styleVersion
                        defaultStyle[name] = {
                            type = "button_style",
                            font = "muppet" .. textSize[2] .. boldness[2] .. styleData.styleVersion,
                            font_color = purpose[2],
                            single_line = false,
                            margin = 0,
                            left_padding = padding[2],
                            top_padding = padding[3],
                            right_padding = padding[4],
                            bottom_padding = padding[5],
                            minimal_width = 0,
                            minimal_height = 0
                        }
                        for k, v in pairs(attributes[2]) do
                            if type(k) == "number" then
                                defaultStyle[name][k] = (defaultStyle[name][k] or 0) + v
                            else
                                defaultStyle[name][k] = v
                            end
                        end
                    end
                end
            end
        end
    end

    --LABEL
    for _, purpose in pairs({{"_text", Colors.white}, {"_heading", Colors.guiheadingcolor}}) do
        for _, textSize in pairs({{"_small", "_small"}, {"_medium", "_medium"}, {"_large", "_large"}}) do
            for _, boldness in pairs({{"", ""}, {"_semibold", "_semibold"}, {"_bold", "_bold"}}) do
                for _, margin in pairs({{"", 0, 0, 0, 0}, {"_marginTL", 4, 4, 0, 0}}) do
                    for _, padding in pairs({{"", 0, 0, 0, 0}, {"_paddingBR", 0, 0, 4, 4}, {"_paddingSides", 4, 0, 4, 0}}) do
                        defaultStyle["muppet_label" .. purpose[1] .. textSize[1] .. boldness[1] .. margin[1] .. padding[1] .. styleData.styleVersion] = {
                            type = "label_style",
                            font = "muppet" .. textSize[2] .. boldness[2] .. styleData.styleVersion,
                            font_color = purpose[2],
                            single_line = false,
                            left_margin = margin[2],
                            top_margin = margin[3],
                            right_margin = margin[4],
                            bottom_margin = margin[5],
                            left_padding = padding[2],
                            top_padding = padding[3],
                            right_padding = padding[4],
                            bottom_padding = padding[5]
                        }
                    end
                end
            end
        end
    end

    --TEXT BOX - set width & height setting when using as base game has values that can't be nil'd
    for _, margin in pairs({{"", 0, 0, 0, 0}, {"_marginTL", 4, 4, 0, 0}}) do
        for _, padding in pairs({{"", 0, 0, 0, 0}, {"_paddingBR", 0, 0, 4, 4}}) do
            defaultStyle["muppet_textbox" .. margin[1] .. padding[1] .. styleData.styleVersion] = {
                type = "textbox_style",
                left_margin = margin[2],
                top_margin = margin[3],
                right_margin = margin[4],
                bottom_margin = margin[5],
                left_padding = padding[2],
                top_padding = padding[3],
                right_padding = padding[4],
                bottom_padding = padding[5]
            }
        end
    end

    data:extend(
        {
            {
                type = "font",
                name = "muppet_small" .. styleData.styleVersion,
                from = "default",
                size = 12
            },
            {
                type = "font",
                name = "muppet_small_semibold" .. styleData.styleVersion,
                from = "default-semibold",
                size = 12
            },
            {
                type = "font",
                name = "muppet_small_bold" .. styleData.styleVersion,
                from = "default-bold",
                size = 12
            },
            {
                type = "font",
                name = "muppet_medium" .. styleData.styleVersion,
                from = "default",
                size = 16
            },
            {
                type = "font",
                name = "muppet_medium_semibold" .. styleData.styleVersion,
                from = "default-semibold",
                size = 16
            },
            {
                type = "font",
                name = "muppet_medium_bold" .. styleData.styleVersion,
                from = "default-bold",
                size = 16
            },
            {
                type = "font",
                name = "muppet_large" .. styleData.styleVersion,
                from = "default",
                size = 18
            },
            {
                type = "font",
                name = "muppet_large_semibold" .. styleData.styleVersion,
                from = "default-semibold",
                size = 18
            },
            {
                type = "font",
                name = "muppet_large_bold" .. styleData.styleVersion,
                from = "default-bold",
                size = 18
            }
        }
    )
end

return styleData
