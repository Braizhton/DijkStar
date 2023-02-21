function transition_cost(start::Char,dest::Char)
    inf = typemax(Int64)

    if dest == '@' || dest == 'O' || dest == 'T'    # Out of bounds or trees
        return inf
    end

    if start == '.' || start == 'G'                 # GROUND
        if dest == start                            # Staying on the same soil
            return 1
        elseif dest == 'W'                          # Ground to Water
            return inf
        elseif dest == 'S'                          # Ground to Swamp
            return 3
        end

    elseif start == 'S'                             # SWAMP
        if dest == start                            # Staying on the same soil
            return 5
        elseif dest == 'W'                          # Swamp to Water
            return inf
        elseif dest == 'G' || dest == '.'           # Swamp to Ground
            return 3
        end

    elseif start == 'W'                             # WATER
        if dest == start                            # Staying on water
            return 1
        elseif dest == 'G' || dest == '.' || dest == 'S' # Leaving water
            return inf
        end
    end
end
