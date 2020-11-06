local DisableRegularRollingStock = {}

DisableRegularRollingStock.OnStartup = function()
    if not settings.startup["single_train_unit-disable_regular_rollingstock"].value then
        return
    end

    DisableRegularRollingStock.DisableRecipesForEntityType("locomotive")
    DisableRegularRollingStock.DisableRecipesForEntityType("cargo-wagon")
    DisableRegularRollingStock.DisableRecipesForEntityType("fluid-wagon")
end

DisableRegularRollingStock.DisableRecipesForEntityType = function(entityType)
    local entityPrototypes = game.get_filtered_entity_prototypes({{filter = "type", type = entityType}})
    for _, entityPrototype in pairs(entityPrototypes) do
        if string.find(entityPrototype.name, "single_train_unit") == nil then
            local recipes = game.get_filtered_recipe_prototypes({{filter = "has-product-item", elem_filters = {{filter = "place-result", elem_filters = {{filter = "name", name = entityPrototype.name}}}}}})
            for _, recipe in pairs(recipes) do
                for _, force in pairs(game.forces) do
                    force.recipes[recipe.name].enabled = false
                end
            end
        end
    end
end

return DisableRegularRollingStock
