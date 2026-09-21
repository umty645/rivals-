--!nocheck
--!optimize 2

local a, b, c = (getfenv and getfenv(1)) or _ENV or _G, (table and table.unpack) or unpack, select

local function pack(...)
    return {
        n = c('#', ...),
        ...,
    }
end

local d = {}

d.set_wallbang_part = function(e, f)
    local g

    g = f

    if (not a._G.RIVALS_WALLBANG) then
    else
        a._G.RIVALS_WALLBANG.AimAtPart = g
    end

    return
end
d.set_wallbang_radius = function(e, f)
    local g

    g = f

    if (not a._G.RIVALS_WALLBANG) then
    else
        a._G.RIVALS_WALLBANG.SearchRadius = g
    end

    return
end
d.set_wallbang_interval = function(e, f)
    local g

    g = f

    if (not a._G.RIVALS_WALLBANG) then
    else
        a._G.RIVALS_WALLBANG.ShotInterval = g
    end

    return
end
d.set_wallbang_mouse_hold = function(e, f)
    local g, h, i, j

    g = f

    if (not a._G.RIVALS_WALLBANG) then
    else
        h = a._G.RIVALS_WALLBANG
        i = 'RequireMouseHeld'
        j = g

        if (not g) then
        else
            j = true
        end
        if (j) then
        else
            j = false
        end

        h[i] = j
    end

    return
end
d.set_wallbang_enabled = function(e, f)
    local g, h, i, j

    g = f

    if (not a._G.RIVALS_WALLBANG) then
    else
        h = a._G.RIVALS_WALLBANG
        i = 'Enabled'
        j = g

        if (not g) then
        else
            j = true
        end
        if (j) then
        else
            j = false
        end

        h[i] = j
    end

    return
end
d.build_wallbang_ui = function(e)
    local f = e[1][1].Combat:Section('wallbang', 2)

    f:Toggle('enabled', false, function(...)
        return d.set_wallbang_enabled({}, ...)
    end)
    f:Toggle('require mouse hold', false, function(...)
        return d.set_wallbang_mouse_hold({}, ...)
    end)
    f:Slider('shot interval', 0.01, 0.3, 0.05, 2, function(...)
        return d.set_wallbang_interval({}, ...)
    end)
    f:Slider('search radius', 1, 15, 9.5, 1, function(...)
        return d.set_wallbang_radius({}, ...)
    end)

    local g = {}

    g[1] = 'Head'
    g[2] = 'HumanoidRootPart'
    g[3] = 'UpperTorso'

    f:Dropdown('aim part', g, 'Head', function(...)
        return d.set_wallbang_part({}, ...)
    end)
    f:Label'hold LMB/RMB to fire through walls'

    return
end
d.wallbang_tick = function(e)
    local f = a._G.RIVALS_WALLBANG

    if not (f and f.Enabled) then
        return
    end
    if not (e[1][1].EnemyControllerHooked or e[1][1].FighterControllerHooked) then
        e[2][1]()
    end

    local g = a.table.pack(a.pcall(e[3][1]))

    if not g[1] then
        a.warn('[Wallbang] tick error: ' .. a.tostring(g[2]))

        return
    end

    local h, i = g[2], g[3]

    if h then
        e[4][1](i or 'FIRED')
    elseif i then
        e[5][1](i)
    end
end
d.p428 = function(e, f)
    local g

    g = f

    if (not (g.UserInputType == a.Enum.UserInputType.MouseButton1)) then
        if (not (g.UserInputType == a.Enum.UserInputType.MouseButton2)) then
        else
            e[1][1].RightMouseHeld = false
        end
    else
        e[1][1].LeftMouseHeld = false
    end

    return
end
d.p427 = function(e, f, g)
    local h, i

    h = f
    i = g

    if (not i) then
        if (not (h.UserInputType == a.Enum.UserInputType.MouseButton1)) then
            if (not (h.UserInputType == a.Enum.UserInputType.MouseButton2)) then
            else
                e[1][1].RightMouseHeld = true
            end
        else
            e[1][1].LeftMouseHeld = true
        end

        return
    else
        return
    end
end
d.wallbang_fire_worker = function(e)
    local f, g = a.tick(), e[1][1]

    if g.RequireMouseHeld and not e[2][1]() then
        return false
    end
    if f - g.LastShotAt < g.ShotInterval then
        return false
    end

    local h = e[3][1]()

    if not h then
        return false, 'no LocalFighter'
    end

    local i = h.EquippedItem

    if not i then
        return false, 'no equipped item'
    end

    local j = e[4][1](i)

    if not j then
        local k = e[5][1](i, 'Ammo')

        if a.type(k) == 'number' and k <= 0 then
            return false, 'out of ammo'
        end
    end
    if a.type(i._shoot_cooldown) == 'number' and f < i._shoot_cooldown then
        return false
    end

    local k, l = e[6][1]()

    if not k then
        return false, l
    end
    if j then
        local m = e[7][1].Character
        local n = m and m:FindFirstChild'HumanoidRootPart'

        if n and (n.Position - k.Position).Magnitude > g.MeleeAttackMaxStuds then
            return false
        end
    end

    local m = e[8][1].CurrentCamera

    if not m then
        return false, 'no camera'
    end

    local n = e[9][1](k, k.Position, m.CFrame.Position)

    if not n then
        return false, 'no clear LoS from any sampled origin'
    end

    local o = e[5][1](i, 'ObjectID')

    if not o then
        return false, 'no ObjectID on item'
    end

    local p = e[10][1]()

    if p == nil then
        return false, 'StartShooting enum not ready'
    end

    local q = e[11][1]()

    if not q then
        return false, 'UseItem remote not found'
    end

    local r = e[12][1](n, k, k.Position)

    q:FireServer(o, p, r, nil)

    g.LastShotAt = f

    local s = k:FindFirstAncestorOfClass'Model'

    return true, a.string.format('FIRED -> %s (%.1f studs)', s and s.Name or '?', (m.CFrame.Position - k.Position).Magnitude)
end
d.mouse_fire_active = function(e)
    local f

    if (not e[1][1].LeftMouseHeld) then
        f = e[1][1].AcceptRightMouse

        if (not e[1][1].AcceptRightMouse) then
        else
            f = e[1][1].RightMouseHeld
        end
        if (not f) then
            return false
        else
            return true
        end
    else
        return true
    end
end
d.encode_cframe_runtime = function(e, f, g, h)
    local i = a.CFrame.lookAt(f, h)
    local j, k, l = i:ToOrientation()
    local m, n = {}, a.utf8.char(0)

    m[n] = f.X

    local o = a.utf8.char(1)

    m[o] = f.Y

    local p = a.utf8.char(2)

    m[p] = f.Z

    local q = a.utf8.char(3)

    m[q] = j

    local r = a.utf8.char(4)

    m[r] = k

    local s = a.utf8.char(5)

    m[s] = l

    local t = g.CFrame:ToObjectSpace(a.CFrame.new(h))
    local u, v, w = t:ToOrientation()
    local x, y, z, A = {}, a.utf8.char(1), {}, a.utf8.char(0)

    z[A] = m

    local B = a.utf8.char(1)

    z[B] = m

    local C = a.utf8.char(2)

    z[C] = g

    local D, E, F = a.utf8.char(3), {}, a.utf8.char(0)

    E[F] = t.X

    local G = a.utf8.char(1)

    E[G] = t.Y

    local H = a.utf8.char(2)

    E[H] = t.Z

    local I = a.utf8.char(3)

    E[I] = u

    local J = a.utf8.char(4)

    E[J] = v

    local K = a.utf8.char(5)

    E[K] = w
    z[D] = E
    x[y] = z

    return x
end
d.find_nearby_target = function(e, f, g, h)
    local i = f:FindFirstAncestorOfClass'Model'
    local j = e[1][1](i)

    if e[2][1](h, g, j) then
        return h
    end

    for k, l in ipairs(e[3][1])do
        local m = h + l * e[4][1].SearchRadius

        if e[2][1](m, g, j) then
            return m
        end
    end

    return nil
end
d.wallcheck = function(e, f, g, h)
    local i, j, k, l

    i = f
    j = g
    k = h
    l = (j - i)

    if (not ((j - i).Magnitude <= 0)) then
        local m = e[1][1]:Raycast(i, l, k)

        return (m == nil)
    else
        return false
    end
end
d.make_raycast_params = function(e, f)
    local g = a.RaycastParams.new()

    g.FilterType = a.Enum.RaycastFilterType.Exclude
    g.IgnoreWater = true

    local h = {}

    h[1] = e[1][1].Character
    h[2] = f
    g.FilterDescendantsInstances = h

    return g
end
d.select_aim_target = function(e)
    local f = e[1][1]
    local g = f.Character
    local h = g and g:FindFirstChild'HumanoidRootPart'

    if not h then
        return nil, 'no local HumanoidRootPart'
    end

    local i, j, k = e[2][1], (a.math.huge)

    for l, m in pairs(i.TrackedFighters)do
        local n = m.Character
        local o = n and n:FindFirstChild(i.AimAtPart)

        if o then
            local p = (h.Position - o.Position).Magnitude

            if p < j then
                k = o
                j = p
            end
        end
    end
    for l, m in pairs(i.TrackedEnemies)do
        local n = m.aimPart

        if not n or not n.Parent then
            n = e[3][1](m.model)
            m.aimPart = n
        end
        if n and m.model.Parent then
            local o = (h.Position - n.Position).Magnitude

            if o < j then
                k = n
                j = o
            end
        end
    end

    if not k then
        return nil, 'no target'
    end

    return k
end
d.p419 = function(e)
    local f = e[1][1]

    if not f.FighterControllerHooked then
        local g = e[2][1]()

        if g then
            for h, i in ipairs(g.Objects or {})do
                e[3][1](i)
            end

            if g.ObjectAdded and type(g.ObjectAdded.Connect) == 'function' then
                f.FighterAddedConnection = g.ObjectAdded:Connect(e[3][1])
            end
            if g.ObjectRemoved and type(g.ObjectRemoved.Connect) == 'function' then
                f.FighterRemovedConnection = g.ObjectRemoved:Connect(e[4][1])
            end

            f.FighterControllerHooked = true
        end
    end
    if not f.EnemyControllerHooked then
        local g = e[5][1]()

        if g then
            for h, i in ipairs(g.Objects or {})do
                e[6][1](i)
            end

            if g.ObjectAdded and type(g.ObjectAdded.Connect) == 'function' then
                f.EnemyAddedConnection = g.ObjectAdded:Connect(e[6][1])
            end
            if g.ObjectRemoved and type(g.ObjectRemoved.Connect) == 'function' then
                f.EnemyRemovedConnection = g.ObjectRemoved:Connect(e[7][1])
            end

            f.EnemyControllerHooked = true
        end
    end
end
d.p418 = function(e, f)
    e[1][1].TrackedEnemies[f] = nil

    return
end
d.p417 = function(e, f)
    local g, h, i

    g = f
    h = g

    if (not g) then
    else
        h = g.Model
    end

    i = (not h)

    if ((not h)) then
    else
        i = (not e[1][1][h.Name])
    end
    if (not i) then
        local j = {}

        j.model = h

        local k = e[3][1](h)

        j.aimPart = k
        e[2][1].TrackedEnemies[g] = j

        return
    else
        return
    end
end
d.p416 = function(e, f)
    local g, h

    g = f
    h = g

    if (not g) then
    else
        h = g.Player
    end
    if (not (not h)) then
        if (not (e[1][1].TrackedFighters[h] == g)) then
        else
            e[1][1].TrackedFighters[h] = nil
        end

        return
    else
        return
    end
end
d.p415 = function(e, f)
    local g, h, i

    g = f
    h = g

    if (not g) then
    else
        h = g.Player
    end

    i = (not h)

    if ((not h)) then
    else
        i = (h == e[1][1])
    end
    if (not i) then
        e[2][1].TrackedFighters[h] = g

        return
    else
        return
    end
end
d.p414 = function(e, f)
    if not f then
        return nil
    end

    local g = f:FindFirstChild'Head'

    if g and g:IsA'BasePart' then
        return g
    end
    if f.PrimaryPart then
        return f.PrimaryPart
    end

    for h, i in ipairs(f:GetChildren())do
        if i:IsA'BasePart' then
            return i
        end
    end

    return nil
end
d.p413 = function(e, f)
    local g, h, i

    g = f
    h = g

    if (not g) then
    else
        h = g.Info
    end
    if (not (not h)) then
        i = (h.Class == 'Melee')

        if ((h.Class == 'Melee')) then
        else
            i = (h.Type == 'Melee')
        end

        return i
    else
        return false
    end
end
d.p412 = function(e, f, g)
    local h, i, j, k

    h = f
    i = g

    if (not (not h)) then
        local l = a.type(h.Get)

        if (not (l == 'function')) then
        else
            local m, n = a.pcall(h.Get, h, i)

            j = n
            k = m

            if (not m) then
            else
                k = (j ~= nil)
            end
            if (not k) then
                local o = a.type(h.Data)

                if (not (o == 'table')) then
                    return nil
                else
                    return h.Data[i]
                end
            else
                return j
            end
        end

        local m = a.type(h.Data)

        if (not (m == 'table')) then
            return nil
        else
            return h.Data[i]
        end
    else
        return nil
    end
end
d.p411 = function(e)
    local f, g, h, i, j, k = (e[1][1]())

    g = f

    if (not (not f)) then
        if (not g.LocalFighter) then
            local l = a.type(g.GetFighter)

            if (not (l == 'function')) then
            else
                local m, n = a.pcall(g.GetFighter, g, e[2][1])

                h = n
                i = m

                if (not m) then
                else
                    i = h
                end
                if (not i) then
                    if (not e[2][1].Character) then
                    else
                        local o, p = a.pcall(g.GetFighter, g, e[2][1].Character)

                        j = p
                        k = o

                        if (not o) then
                        else
                            k = j
                        end
                        if (not k) then
                            return nil
                        else
                            return j
                        end
                    end

                    return nil
                else
                    return h
                end
            end

            return nil
        else
            return g.LocalFighter
        end
    else
        return nil
    end
end
d.p410 = function(e)
    local f, g, h, i

    if (not (e[1][1] ~= nil)) then
        local j = e[2][1]()

        f = j
        g = (not j)

        if ((not j)) then
        else
            local k = a.type(f.ToEnum)

            g = (k ~= 'function')
        end
        if (not g) then
            local k, l = a.pcall(f.ToEnum, f, 'StartShooting')

            h = l
            i = k

            if (not k) then
            else
                i = (h ~= nil)
            end
            if (not i) then
            else
                e[1][1] = h
            end

            return e[1][1]
        else
            return nil
        end
    else
        return e[1][1]
    end
end
d.p409 = function(e)
    local f, g, h, i, j

    f = e[1][1]

    if (not e[1][1]) then
    else
        f = e[1][1].Parent
    end
    if (not f) then
        local k = e[2][1]:FindFirstChild'Remotes'

        f = k
        g = k

        if (not k) then
        else
            local l = f:FindFirstChild'Replication'

            g = l
        end

        h = g

        if (not g) then
        else
            local l = g:FindFirstChild'Fighter'

            h = l
        end

        i = h

        if (not h) then
        else
            local l = h:FindFirstChild'UseItem'

            i = l
        end

        j = i

        if (not i) then
        else
            local l = i:IsA'RemoteEvent'

            j = l
        end
        if (not j) then
        else
            e[1][1] = i
        end

        return e[1][1]
    else
        return e[1][1]
    end
end
d.p408 = function(e)
    local f, g, h, i

    if (not e[1][1]) then
        local j = e[2][1]:FindFirstChild'PlayerScripts'

        f = j
        g = j

        if (not j) then
        else
            local k = f:FindFirstChild'Controllers'

            g = k
        end

        h = g

        if (not g) then
        else
            local k = g:FindFirstChild'EnemyController'

            h = k
        end
        if (not (not h)) then
            local k, l = a.pcall(a.require, h)

            i = l

            if (not k) then
            else
                e[1][1] = i
            end

            return e[1][1]
        else
            return nil
        end
    else
        return e[1][1]
    end
end
d.p407 = function(e)
    local f, g, h, i

    if (not e[1][1]) then
        local j = e[2][1]:FindFirstChild'PlayerScripts'

        f = j
        g = j

        if (not j) then
        else
            local k = f:FindFirstChild'Controllers'

            g = k
        end

        h = g

        if (not g) then
        else
            local k = g:FindFirstChild'FighterController'

            h = k
        end
        if (not (not h)) then
            local k, l = a.pcall(a.require, h)

            i = l

            if (not k) then
            else
                e[1][1] = i
            end

            return e[1][1]
        else
            return nil
        end
    else
        return e[1][1]
    end
end
d.p406 = function(e)
    local f, g, h

    if (not e[1][1]) then
        local i = e[2][1]:FindFirstChild'Modules'

        f = i
        g = i

        if (not i) then
        else
            local j = f:FindFirstChild'EnumLibrary'

            g = j
        end
        if (not (not g)) then
            local j, k = a.pcall(a.require, g)

            h = k

            if (not j) then
            else
                e[1][1] = h
            end

            return e[1][1]
        else
            return nil
        end
    else
        return e[1][1]
    end
end
d.p405 = function(e, f)
    local g

    g = f

    if (not e[1][1].Verbose) then
    else
        a.print(('[Wallbang] ' .. g))
    end

    return
end
d.p404 = function(e, f)
    local g = e[1][1]

    if not g.Verbose then
        return
    end

    g.SkipCounter[f] = (g.SkipCounter[f] or 0) + 1

    if g.SkipCounter[f] % g.PrintEvery == 1 then
        a.print(a.string.format('[Wallbang] %s (x%d)', f, g.SkipCounter[f]))
    end
end
d.p403 = function(e)
    e[1][1]:Disconnect()

    return
end
d.combat_runtime = function(e)
    local f, g, h, i, j = a.game:GetService'Players', {
        a.game:GetService'ReplicatedStorage',
    }, {
        a.game:GetService'Workspace',
    }, a.game:GetService'RunService', a.game:GetService'UserInputService'
    local k, l = {
        f.LocalPlayer,
    }, a._G.RIVALS_WALLBANG

    if l and l.Loaded then
        for m, n in ipairs{
            'HeartbeatConnection',
            'InputBeganConnection',
            'InputEndedConnection',
            'EnemyAddedConnection',
            'EnemyRemovedConnection',
            'FighterAddedConnection',
            'FighterRemovedConnection',
        }do
            local o = l[n]

            if o then
                a.pcall(function()
                    o:Disconnect()
                end)
            end

            l[n] = nil
        end
    end

    local m = {
        Loaded = true,
        Enabled = false,
        Verbose = false,
        RequireMouseHeld = false,
        AcceptRightMouse = true,
        ShotInterval = 0.05,
        SearchRadius = 9.5,
        AimAtPart = 'Head',
        MeleeAttackMaxStuds = 15,
        LastShotAt = 0,
        PrintEvery = 60,
        SkipCounter = {},
        LeftMouseHeld = false,
        RightMouseHeld = false,
        TrackedFighters = {},
        TrackedEnemies = {},
        EnemyControllerHooked = false,
        FighterControllerHooked = false,
    }

    a._G.RIVALS_WALLBANG = m

    local n = {m}
    local o, p, q, r, s, t, u = {
        function(o)
            return d.p404({n}, o)
        end,
    }, {
        function(o)
            return d.p405({n}, o)
        end,
    }, {nil}, {nil}, {nil}, {nil}, {nil}
    local v, w, x, y = {
        function()
            return d.p406{q, g}
        end,
    }, {
        function()
            return d.p407{r, k}
        end,
    }, {
        function()
            return d.p408{s, k}
        end,
    }, {
        function()
            return d.p409{t, g}
        end,
    }
    local z, A, B, C, D, E, F, G = {
        function()
            return d.p410{u, v}
        end,
    }, {
        function()
            return d.p411{w, k}
        end,
    }, {
        function(...)
            return d.p412({}, ...)
        end,
    }, {
        function(...)
            return d.p413({}, ...)
        end,
    }, {
        {
            Dummy = true,
            ['DPS Dummy'] = true,
            Target = true,
        },
    }, {
        function(...)
            return d.p414({}, ...)
        end,
    }, {
        function(...)
            return d.p415({k, n}, ...)
        end,
    }, {
        function(...)
            return d.p416({n}, ...)
        end,
    }
    local H, I = {
        function(...)
            return d.p417({D, n, E}, ...)
        end,
    }, {
        function(...)
            return d.p418({n}, ...)
        end,
    }
    local J, K, L, M, N = {
        function(...)
            return d.p419({
                n,
                w,
                F,
                G,
                x,
                H,
                I,
            }, ...)
        end,
    }, {
        function(...)
            return d.select_aim_target({k, n, E}, ...)
        end,
    }, {
        {
            a.Vector3.new(1, 0, 0),
            a.Vector3.new(-1, 0, 0),
            a.Vector3.new(0, 1, 0),
            a.Vector3.new(0, -1, 0),
            a.Vector3.new(0, 0, 1),
            a.Vector3.new(0, 0, -1),
            a.Vector3.new(1, 1, 1).Unit,
            a.Vector3.new(1, 1, -1).Unit,
            a.Vector3.new(1, -1, 1).Unit,
            a.Vector3.new(1, -1, -1).Unit,
            a.Vector3.new(-1, 1, 1).Unit,
            a.Vector3.new(-1, 1, -1).Unit,
            a.Vector3.new(-1, -1, 1).Unit,
            a.Vector3.new(-1, -1, -1).Unit,
        },
    }, {
        function(...)
            return d.make_raycast_params({k}, ...)
        end,
    }, {
        function(...)
            return d.wallcheck({h}, ...)
        end,
    }
    local O, P = {
        function(...)
            return d.find_nearby_target({
                M,
                N,
                L,
                n,
            }, ...)
        end,
    }, {
        function(...)
            return d.mouse_fire_active({n}, ...)
        end,
    }
    local Q = {
        function(...)
            return d.wallbang_fire_worker({
                n,
                P,
                A,
                C,
                B,
                K,
                k,
                h,
                O,
                z,
                y,
                J,
            }, ...)
        end,
    }

    m.InputBeganConnection = j.InputBegan:Connect(function(...)
        return d.p427({n}, ...)
    end)
    m.InputEndedConnection = j.InputEnded:Connect(function(...)
        return d.p428({n}, ...)
    end)
    m.HeartbeatConnection = i.Heartbeat:Connect(function(...)
        return d.wallbang_tick({
            n,
            J,
            Q,
            p,
            o,
        }, ...)
    end)
end
d.p401 = function(e, ...)
    local f = a.game:GetService'CoreGui'
    local g = f:FindFirstChild'nexlib'

    if g then
        for h, i in a.ipairs(g:GetDescendants())do
            if i.Name == 'MainFrame' then
                i.Visible = true
            end
        end
    end

    local h = a.game:GetService'UserInputService'

    h.MouseBehavior = a.Enum.MouseBehavior.Default
    h.MouseIconEnabled = true
end
d.sync_menu_visibility = function(e)
    a.pcall(function(...)
        return d.p401({}, ...)
    end)

    return
end
d.refresh_shader = function(e)
    if (not (e[1][1] ~= e[2][1])) then
    else
        e[2][1] = e[1][1]

        if (not e[1][1]) then
            a.disable_shader()
        else
            a.enable_shader()
        end
    end

    return
end
d.p398 = function(e)
    e[1][1][e[2][1] ] = e[3][1]

    return
end
d.disable_shader = function(e)
    local f = e[1][1]

    if next(f) then
        for g, h in pairs(f)do
            local i, j = {g}, {h}

            a.pcall(function()
                return d.p398{
                    e[2],
                    i,
                    j,
                }
            end)
        end
    end

    e[3][1].Parent = nil
    e[4][1].Parent = nil
end
d.enable_shader = function(e)
    local f = {}

    f.Ambient = e[1][1].Ambient
    f.Brightness = e[1][1].Brightness
    f.OutdoorAmbient = e[1][1].OutdoorAmbient
    f.ShadowSoftness = e[1][1].ShadowSoftness
    f.TimeOfDay = e[1][1].TimeOfDay
    f.ColorShift_Top = e[1][1].ColorShift_Top
    f.ColorShift_Bottom = e[1][1].ColorShift_Bottom
    e[2][1] = f

    local g = a.Color3.fromRGB(94, 99, 188)

    e[1][1].Ambient = g
    e[1][1].Brightness = 3.5

    local h = a.Color3.fromRGB(0, 0, 0)

    e[1][1].OutdoorAmbient = h
    e[1][1].ShadowSoftness = 2.5
    e[1][1].TimeOfDay = '00:30:00'
    e[3][1].Parent = e[1][1]
    e[4][1].Parent = e[1][1]

    return
end
d.trigger_click = function(e)
    local f, g = (e[1][1](3))

    if (not (not f)) then
        if (not (not e[2][1])) then
            g = a.mouse1click

            if (not a.mouse1click) then
            else
                g = a.isrbxactive

                if (a.isrbxactive) then
                else
                    g = a.iswindowactive
                end
            end
            if (not g) then
            else
                g = a.isrbxactive

                if (not a.isrbxactive) then
                else
                    local h = a.isrbxactive()

                    g = h
                end
                if (g) then
                else
                    g = a.iswindowactive

                    if (not a.iswindowactive) then
                    else
                        local h = a.iswindowactive()

                        g = h
                    end
                end
            end
            if (not g) then
            else
                local h = e[4][1]()

                if (not h) then
                    if (not e[3][1]) then
                    else
                        a.pcall(a.mouse1release)

                        e[3][1] = false
                    end
                else
                    local i = a.tick()

                    if (not (e[5][1] < i)) then
                    else
                        if (not e[3][1]) then
                            a.pcall(a.mouse1press)
                        else
                            a.pcall(a.mouse1release)

                            local j = a.tick()

                            e[5][1] = (j + 0.07)
                        end

                        e[3][1] = (not e[3][1])
                    end
                end
            end

            return
        else
            if (not e[3][1]) then
            else
                a.pcall(a.mouse1release)

                e[3][1] = false
            end

            return
        end
    else
        return
    end
end
d.raycast_target = function(e)
    local f, g, h, i, j, k

    f = e[1][1].Character

    if (not (not e[1][1].Character)) then
        local l = {}

        l[1] = f
        l[2] = e[3][1]
        e[2][1].FilterDescendantsInstances = l

        local m = a.workspace:Raycast(e[3][1].CFrame.Position, (e[3][1].CFrame.LookVector * 400), e[2][1])

        g = m
        h = m

        if (not m) then
        else
            h = g.Instance
        end
        if (not h) then
        else
            local n = g.Instance:FindFirstAncestorOfClass'Model'

            h = n
            i = n

            if (not n) then
            else
                i = (h ~= f)
            end
            if (not i) then
            else
                local o = h:FindFirstChildOfClass'Humanoid'

                i = o
                j = o

                if (not o) then
                else
                    j = (i.Health > 0)
                end
                if (not j) then
                    return false
                else
                    local p = e[4][1]:GetPlayerFromCharacter(h)

                    j = p
                    k = p

                    if (not p) then
                    else
                        k = e[5][1]
                    end
                    if (not k) then
                    else
                        local q = e[5][1](j)

                        k = q
                    end
                    if (not k) then
                        return true
                    else
                        return false
                    end
                end
            end
        end

        return false
    else
        return false
    end
end
d.p393 = function(e)
    e[1][1].Visible = false
    e[2][1].Visible = false
    e[3][1].Visible = false
    e[4][1].Visible = false

    if (not e[5][1]) then
    else
        e[5][1].Visible = false
    end

    return
end
d.esp_update = function(e)
    local f = a.workspace.CurrentCamera or e[1][1]

    e[1][1] = f

    if not e[2][1](3) then
        return
    end

    local g = e[3][1].Character
    local h, i = g and g:FindFirstChild'HumanoidRootPart', a.espEnabled

    if not i then
        i = a._G.espEnabled
    end

    local function hide(j)
        j.Box.Visible = false
        j.Name.Visible = false
        j.HealthBg.Visible = false
        j.HealthBar.Visible = false

        if j.Weapon then
            j.Weapon.Visible = false
        end
    end

    for j, k in pairs(e[4][1])do
        local l = j.Character
        local m, n = l and l:FindFirstChild'HumanoidRootPart', l and l:FindFirstChildOfClass'Humanoid'
        local o = l and (l:FindFirstChild'Head' or l:FindFirstChild'HitboxHead') or m

        if not i or not m or not n or not o or n.Health <= 0 then
            hide(k)
        else
            local p, q = o.Position + a.Vector3.new(0, 0.6, 0), m.Position - a.Vector3.new(0, 3, 0)
            local r, s = f:WorldToViewportPoint(p)
            local t, u = f:WorldToViewportPoint(q)
            local v, w = f:WorldToViewportPoint(m.Position)

            if not (s or u or w) or v.Z <= 0 then
                hide(k)
            else
                local x = a.math.abs(r.Y - t.Y)

                if x < 8 then
                    x = 40
                end

                local y = x * 0.55
                local z, A, B = v.X - y / 2, r.Y, e[5][1] and e[5][1](j)

                if a.espBoxEnabled or a._G.espBoxEnabled then
                    k.Box.Size = a.UDim2.fromOffset(y, x)
                    k.Box.Position = a.UDim2.fromOffset(z, A)

                    if k.BoxStroke then
                        k.BoxStroke.Color = B and a.Color3.fromRGB(80, 160, 255) or a.Color3.fromRGB(255, 70, 70)
                    end

                    k.Box.Visible = true
                else
                    k.Box.Visible = false
                end
                if a.espNameEnabled or a._G.espNameEnabled then
                    local C = ''

                    if h then
                        C = ' [' .. a.math.floor((m.Position - h.Position).Magnitude) .. 'm]'
                    end

                    k.Name.Text = (j.DisplayName or j.Name) .. C
                    k.Name.Position = a.UDim2.fromOffset(v.X - 80, A - 16)
                    k.Name.TextColor3 = B and a.Color3.fromRGB(120, 180, 255) or a.Color3.fromRGB(255, 255, 255)
                    k.Name.Visible = true
                else
                    k.Name.Visible = false
                end
                if a.espHealthEnabled or a._G.espHealthEnabled then
                    local C = a.math.clamp(n.Health / a.math.max(n.MaxHealth, 1), 0, 1)

                    k.HealthBg.Size = a.UDim2.fromOffset(3, x)
                    k.HealthBg.Position = a.UDim2.fromOffset(z - 6, A)
                    k.HealthBg.Visible = true

                    local D = a.math.max(x * C, 1)

                    k.HealthBar.Size = a.UDim2.fromOffset(3, D)
                    k.HealthBar.Position = a.UDim2.fromOffset(z - 6, A + (x - D))
                    k.HealthBar.BackgroundColor3 = a.Color3.fromHSV(C * 0.33, 1, 1)
                    k.HealthBar.Visible = true
                else
                    k.HealthBg.Visible = false
                    k.HealthBar.Visible = false
                end
                if (a.espWeaponEnabled or a._G.espWeaponEnabled) and k.Weapon then
                    local C = e[6][1](j)

                    if C and C ~= '' then
                        k.Weapon.Text = C
                        k.Weapon.Position = a.UDim2.fromOffset(v.X - 90, A + x + 2)
                        k.Weapon.TextColor3 = B and a.Color3.fromRGB(140, 190, 255) or a.Color3.fromRGB(220, 220, 220)
                        k.Weapon.Visible = true
                    else
                        k.Weapon.Visible = false
                    end
                elseif k.Weapon then
                    k.Weapon.Visible = false
                end
            end
        end
    end
end
d.p391 = function(e, f)
    local g

    g = f

    if (not (g ~= e[1][1])) then
    else
        e[2][1](g)
    end

    return
end
d.p390 = function(e)
    e[1][1]:Destroy()

    return
end
d.p389 = function(e, f)
    local g = e[1][1][f]

    if not g then
        return
    end

    for h, i in pairs(g)do
        if a.typeof(i) == 'Instance' then
            a.pcall(function()
                i:Destroy()
            end)
        end
    end

    e[1][1][f] = nil
end
d.p388 = function(e, f)
    local g

    g = f

    if (not e[1][1][g]) then
        local h = a.Instance.new'Frame'

        h.Name = 'Box'
        h.BackgroundTransparency = 1
        h.BorderSizePixel = 0
        h.Visible = false
        h.Parent = e[2][1]

        local i = a.Instance.new'UIStroke'

        i.Thickness = 1

        local j = a.Color3.fromRGB(255, 70, 70)

        i.Color = j
        i.Parent = h

        local k = a.Instance.new'TextLabel'

        k.Name = 'Name'
        k.BackgroundTransparency = 1
        k.Font = a.Enum.Font.Code
        k.TextSize = 13

        local l = a.Color3.fromRGB(255, 255, 255)

        k.TextColor3 = l
        k.TextStrokeTransparency = 0

        local m = a.Color3.fromRGB(0, 0, 0)

        k.TextStrokeColor3 = m
        k.TextXAlignment = a.Enum.TextXAlignment.Center

        local n = a.UDim2.new(0, 160, 0, 16)

        k.Size = n
        k.Visible = false
        k.Parent = e[2][1]

        local o = a.Instance.new'Frame'

        o.Name = 'HealthBg'

        local p = a.Color3.fromRGB(0, 0, 0)

        o.BackgroundColor3 = p
        o.BackgroundTransparency = 0.35
        o.BorderSizePixel = 0
        o.Visible = false
        o.Parent = e[2][1]

        local q = a.Instance.new'Frame'

        q.Name = 'HealthBar'

        local r = a.Color3.fromRGB(0, 255, 0)

        q.BackgroundColor3 = r
        q.BorderSizePixel = 0
        q.Visible = false
        q.Parent = e[2][1]

        local s = a.Instance.new'TextLabel'

        s.Name = 'Weapon'
        s.BackgroundTransparency = 1
        s.Font = a.Enum.Font.Code
        s.TextSize = 12

        local t = a.Color3.fromRGB(220, 220, 220)

        s.TextColor3 = t
        s.TextStrokeTransparency = 0

        local u = a.Color3.fromRGB(0, 0, 0)

        s.TextStrokeColor3 = u
        s.TextXAlignment = a.Enum.TextXAlignment.Center

        local v = a.UDim2.new(0, 180, 0, 14)

        s.Size = v
        s.Visible = false
        s.Parent = e[2][1]

        local w = {}

        w.Box = h
        w.BoxStroke = i
        w.Name = k
        w.HealthBg = o
        w.HealthBar = q
        w.Weapon = s
        e[1][1][g] = w

        return
    else
        return
    end
end
d.p387 = function(e)
    local f, g = e[1][1], e[2][1]

    if f.Get then
        return f:Get(g)
    end

    return f[g]
end
d.p386 = function(e, f)
    local g, h

    g = f

    local i = {g}
    local j, k = a.pcall(function(...)
        return d.p387({
            e[1],
            i,
        }, ...)
    end)

    h = k

    if (not j) then
        return
    else
        return h
    end
end
d.p385 = function(e)
    local f, g = a.pcall(a.require, e[1][1].PlayerScripts.Controllers.FighterController)

    if not f or not g then
        return
    end

    local h, i = (e[2][1])

    if type(g.GetFighter) == 'function' then
        i = g:GetFighter(h)
    elseif h == e[1][1] then
        i = g.LocalFighter
    end
    if not i then
        return
    end

    local j = i.EquippedItem

    if not j then
        local k = h.Character
        local l = k and k:FindFirstChildOfClass'Tool'

        if l then
            e[3][1] = l.Name
        end

        return
    end

    local function get(k)
        return d.p386({
            {j},
        }, k)
    end

    local k, l, m, n = get'CurrentAmmo' or get'Ammo', get'ReserveAmmo' or get'StoredAmmo', get'Reloading' or get'IsReloading'

    if m == true then
        n = '*Reloading*'
    else
        n = a.tostring(j.Name or get'Name' or 'weapon')
    end

    e[3][1] = n

    if a.typeof(k) == 'number' and a.typeof(l) == 'number' then
        e[4][1] = a.string.format('%d/%d', a.math.floor(k + 0.5), a.math.floor(l + 0.5))
    elseif a.typeof(k) == 'number' then
        e[4][1] = a.tostring(a.math.floor(k + 0.5))
    end
end
d.p384 = function(e, f)
    local g, h, i, j

    g = f

    local k, l, m = {g}, {nil}, {nil}

    a.pcall(function(...)
        return d.p385({
            e[1],
            k,
            l,
            m,
        }, ...)
    end)

    h = l
    i = m

    if (not (not l[1])) then
        j = i[1]

        if (not i[1]) then
        else
            j = (i[1] ~= '')
        end
        if (not j) then
            return h[1]
        else
            return (h[1] .. (' | ' .. i[1]))
        end
    else
        return nil
    end
end
d.p383 = function(e)
    local f = a.game:GetService'CoreGui'

    e[1][1].Parent = f

    return
end
d.init_esp = function(e)
    local f = a.Instance.new'ScreenGui'

    f.Name = 'HalmuESP'
    f.ResetOnSpawn = false
    f.IgnoreGuiInset = true
    f.DisplayOrder = 40

    a.pcall(function()
        f.Parent = a.game:GetService'CoreGui'
    end)

    if not f.Parent then
        f.Parent = e[1][1]:WaitForChild'PlayerGui'
    end

    a._G.espEnabled = a._G.espEnabled or false

    if a._G.espBoxEnabled == nil then
        a._G.espBoxEnabled = true
    end
    if a._G.espNameEnabled == nil then
        a._G.espNameEnabled = true
    end
    if a._G.espHealthEnabled == nil then
        a._G.espHealthEnabled = true
    end
    if a._G.espWeaponEnabled == nil then
        a._G.espWeaponEnabled = true
    end

    a.espEnabled = a.espEnabled or false

    if a.espBoxEnabled == nil then
        a.espBoxEnabled = true
    end
    if a.espNameEnabled == nil then
        a.espNameEnabled = true
    end
    if a.espHealthEnabled == nil then
        a.espHealthEnabled = true
    end
    if a.espWeaponEnabled == nil then
        a.espWeaponEnabled = true
    end

    local g, h = {
        function(...)
            return d.p384({
                e[1],
            }, ...)
        end,
    }, {{}}
    local i = h
    local j, k = {
        function(...)
            return d.p388({
                i,
                {f},
            }, ...)
        end,
    }, function(...)
        return d.p389({i}, ...)
    end

    for l, m in ipairs(e[2][1]:GetPlayers())do
        if m ~= e[1][1] then
            j[1](m)
        end
    end

    e[2][1].PlayerAdded:Connect(function(l)
        if l ~= e[1][1] then
            j[1](l)
        end
    end)
    e[2][1].PlayerRemoving:Connect(k)
    e[3][1].RenderStepped:Connect(function(...)
        return d.esp_update({
            e[4],
            e[5],
            e[1],
            i,
            e[6],
            g,
        }, ...)
    end)

    local l, m, n = {false}, {0}, {
        a.RaycastParams.new(),
    }

    n[1].FilterType = a.Enum.RaycastFilterType.Exclude

    local o = {
        function(...)
            return d.raycast_target({
                e[1],
                n,
                e[4],
                e[2],
                e[6],
            }, ...)
        end,
    }

    e[3][1].RenderStepped:Connect(function(...)
        return d.trigger_click({
            e[5],
            e[7],
            l,
            o,
            m,
        }, ...)
    end)

    if not a.enable_shader then
        local p, q, r = {
            a.game:GetService'Lighting',
        }, {{}}, {
            a.Instance.new'BlurEffect',
        }

        r[1].Name = 'ShaderBlur'
        r[1].Size = 6

        local s = {
            a.Instance.new'ColorCorrectionEffect',
        }

        s[1].Name = 'ShaderColor'
        s[1].Saturation = -0.35
        a.enable_shader = function(...)
            return d.enable_shader({
                p,
                q,
                r,
                s,
            }, ...)
        end
        a.disable_shader = function(...)
            return d.disable_shader({
                q,
                p,
                r,
                s,
            }, ...)
        end
    end

    local p = {false}

    e[3][1].Heartbeat:Connect(function(...)
        return d.refresh_shader({
            e[8],
            p,
        }, ...)
    end)
    a.task.defer(function()
        return d.sync_menu_visibility{}
    end)
end
d.p381 = function(e, f)
    local g, h

    g = f
    h = g

    if (not g) then
    else
        h = true
    end
    if (h) then
    else
        h = false
    end

    e[1][1] = h

    if (not e[1][1]) then
    else
        a.task.spawn(e[2][1])
    end

    return
end
d.p380 = function(e, f)
    local g

    g = f

    if (not g) then
        if (not e[4][1]) then
        else
            e[4][1].Enabled = false
        end
    else
        e[1][1] = true

        e[2][1]()
        e[3][1]()
    end

    return
end
d.p379 = function(e, f)
    local g

    g = f
    e[1][1] = g

    if (not g) then
    else
        e[2][1]()
    end

    return
end
d.p378 = function(e)
    local f = a.UDim2.fromOffset(0, (e[2][1].AbsoluteContentSize.Y + 10))

    e[1][1].CanvasSize = f

    if (not e[3][1][1]) then
    else
        e[4][1](e[3][1][1])
    end

    return
end
d.p377 = function(e)
    for f, g in ipairs(e[1][1]:GetChildren())do
        if g:IsA'TextButton' then
            g.BackgroundColor3 = a.Color3.fromRGB(30, 30, 32)
            g.TextColor3 = a.Color3.fromRGB(210, 210, 210)
        end
    end

    e[2][1].BackgroundColor3 = a.Color3.fromRGB(36, 36, 42)
    e[2][1].TextColor3 = e[3][1].accentclr

    e[4][1](e[5][1])
end
d.p376 = function(e)
    e[1][1] = 'Wraps'

    e[2][1]()

    if (not e[3][1]) then
    else
        e[4][1](e[3][1])
    end

    return
end
d.p375 = function(e)
    e[1][1] = 'Skins'

    e[2][1]()

    if (not e[3][1]) then
    else
        e[4][1](e[3][1])
    end

    return
end
d.p374 = function(e)
    local f = a.UDim2.fromOffset(0, (e[2][1].AbsoluteContentSize.Y + 12))

    e[1][1].CanvasSize = f

    return
end
d.p373 = function(e)
    local f, g, h = (a.require(e[1][1].Modules.CosmeticLibrary))

    g = f
    h = (e[2][1] == 'Wraps')

    if (not (e[2][1] == 'Wraps')) then
    else
        h = (e[3][1] ~= 'None')
    end
    if (not h) then
        if (not (e[3][1] ~= 'Default')) then
        else
            g.Equip(e[4][1], 'Skin', e[3][1])
        end
    else
        g.Equip(e[4][1], 'Wrap', e[3][1])
    end

    return
end
d.p372 = function(e)
    a.writefile('VantaNex_skins.json', e[1][1]:JSONEncode(e[2][1]))

    return
end
d.p371 = function(e)
    if (not (e[1][1] == 'Wraps')) then
        e[2][1][e[3][1] ].Skin = e[4][1]
    else
        e[2][1][e[3][1] ].Wrap = e[4][1]
    end

    a.pcall(function(...)
        return d.p372({
            e[5],
            e[2],
        }, ...)
    end)
    a.pcall(function(...)
        return d.p373({
            e[6],
            e[1],
            e[4],
            e[3],
        }, ...)
    end)
    e[7][1](e[3][1])

    return
end
d.refresh_skin_changer = function(e, f)
    local g = {f}

    e[1][1]()

    e[2][1] = f

    if not f then
        return
    end

    local h = e[4][1]

    e[3][1].Text = 'skin changer  \u{b7}  ' .. a.string.lower(f) .. '  \u{b7}  ' .. a.string.lower(h)

    local i

    if h == 'Wraps' then
        i = e[5][1]
    else
        i = e[6][1][f] or {
            'Default',
        }
    end

    e[7][1][f] = e[7][1][f] or {
        Skin = 'Default',
        Wrap = 'None',
    }

    local j = e[7][1][f]

    for k, l in ipairs(i)do
        local m, n, o = {l}, (h == 'Wraps' and j.Wrap == l) or (h == 'Skins' and j.Skin == l), a.Instance.new'TextButton'

        o.BackgroundColor3 = n and a.Color3.fromRGB(36, 44, 40) or a.Color3.fromRGB(30, 30, 32)
        o.BorderSizePixel = 0
        o.Text = l
        o.Font = a.Enum.Font.Code
        o.TextSize = 12
        o.TextColor3 = n and e[8][1].accentclr or a.Color3.fromRGB(210, 210, 210)
        o.Parent = e[9][1]

        local p = a.Instance.new('UIStroke', o)

        p.Thickness = 1
        p.Color = n and e[8][1].accentclr or a.Color3.fromRGB(50, 50, 55)
        p.Transparency = n and 0.2 or 0.5

        o.MouseButton1Click:Connect(function(...)
            return d.p371({
                e[4],
                e[7],
                g,
                m,
                e[10],
                e[11],
                e[12],
            }, ...)
        end)
    end

    a.task.defer(function(...)
        return d.p374({
            e[9],
            e[13],
        }, ...)
    end)
end
d.p369 = function(e)
    for f, g in ipairs(e[1][1]:GetChildren())do
        if g:IsA'TextButton' then
            g:Destroy()
        end
    end
end
d.p368 = function(e)
    if (not (e[1][1] == 'Skins')) then
        e[4][1].TextColor3 = e[3][1].accentclr

        local f = a.Color3.fromRGB(160, 160, 160)

        e[2][1].TextColor3 = f
    else
        e[2][1].TextColor3 = e[3][1].accentclr

        local f = a.Color3.fromRGB(160, 160, 160)

        e[4][1].TextColor3 = f
    end

    return
end
d.p367 = function(e, f)
    local g, h

    g = f
    h = e[1][1]

    if (not e[1][1]) then
    else
        h = (g.UserInputType == a.Enum.UserInputType.MouseMovement)

        if ((g.UserInputType == a.Enum.UserInputType.MouseMovement)) then
        else
            h = (g.UserInputType == a.Enum.UserInputType.Touch)
        end
    end
    if (not h) then
    else
        local i = a.UDim2.new(e[4][1].X.Scale, (e[4][1].X.Offset + (g.Position - e[2][1]).X), e[4][1].Y.Scale, (e[4][1].Y.Offset + (g.Position - e[2][1]).Y))

        e[3][1].Position = i
    end

    return
end
d.p366 = function(e, f)
    local g, h

    g = f
    h = (g.UserInputType == a.Enum.UserInputType.MouseButton1)

    if ((g.UserInputType == a.Enum.UserInputType.MouseButton1)) then
    else
        h = (g.UserInputType == a.Enum.UserInputType.Touch)
    end
    if (not h) then
    else
        e[1][1] = false
    end

    return
end
d.p365 = function(e, f)
    local g, h

    g = f
    h = (g.UserInputType == a.Enum.UserInputType.MouseButton1)

    if ((g.UserInputType == a.Enum.UserInputType.MouseButton1)) then
    else
        h = (g.UserInputType == a.Enum.UserInputType.Touch)
    end
    if (not h) then
    else
        e[1][1] = true
        e[2][1] = g.Position
        e[4][1] = e[3][1].Position
    end

    return
end
d.p364 = function(e)
    e[1][1].Enabled = false

    return
end
d.p363 = function(e)
    if (not a.gethui) then
        local f = a.game:GetService'CoreGui'

        e[1][1].Parent = f
    else
        local f = a.gethui()

        e[1][1].Parent = f
    end

    return
end
d.p362 = function(e)
    e[1][1]:Destroy()

    return
end
d.build_skin_changer_ui = function(e)
    if e[1][1] then
        a.pcall(function()
            e[1][1]:Destroy()
        end)
    end

    local f, g = a.game:GetService'UserInputService', a.Instance.new'ScreenGui'

    g.Name = 'NexSkinChanger'
    g.ResetOnSpawn = false
    g.ZIndexBehavior = a.Enum.ZIndexBehavior.Sibling
    g.DisplayOrder = 99999
    g.IgnoreGuiInset = true

    a.pcall(function()
        g.Parent = a.gethui and a.gethui() or a.game:GetService'CoreGui'
    end)

    if not g.Parent then
        g.Parent = e[2][1]:WaitForChild'PlayerGui'
    end

    e[1][1] = g

    local h = a.Instance.new'Frame'

    h.Name = 'MainFrame'
    h.Size = a.UDim2.fromOffset(720, 460)
    h.Position = a.UDim2.new(0.5, -360, 0.5, -230)
    h.BackgroundColor3 = a.Color3.fromRGB(20, 20, 20)
    h.BackgroundTransparency = 0.06
    h.BorderSizePixel = 0
    h.ClipsDescendants = true
    h.Parent = g

    local i = a.Instance.new('UIStroke', h)

    i.Color = a.Color3.fromRGB(60, 60, 60)
    i.Thickness = 1

    local j = a.Instance.new'Frame'

    j.Size = a.UDim2.new(1, -6, 0, 30)
    j.Position = a.UDim2.fromOffset(3, 3)
    j.BackgroundColor3 = a.Color3.fromRGB(24, 24, 26)
    j.BorderSizePixel = 0
    j.Parent = h

    local k = a.Instance.new'TextLabel'

    k.BackgroundTransparency = 1
    k.Position = a.UDim2.fromOffset(10, 0)
    k.Size = a.UDim2.new(1, -48, 1, 0)
    k.Font = a.Enum.Font.Code
    k.TextSize = 14
    k.TextXAlignment = a.Enum.TextXAlignment.Left
    k.TextColor3 = a.Color3.fromRGB(230, 230, 230)
    k.Text = 'skin changer'
    k.Parent = j

    local l = a.Instance.new'TextButton'

    l.BackgroundTransparency = 1
    l.AnchorPoint = a.Vector2.new(1, 0)
    l.Position = a.UDim2.new(1, -4, 0, 0)
    l.Size = a.UDim2.fromOffset(32, 30)
    l.Font = a.Enum.Font.Code
    l.TextSize = 16
    l.Text = '\u{d7}'
    l.TextColor3 = a.Color3.fromRGB(180, 180, 180)
    l.Parent = j

    l.MouseButton1Click:Connect(function()
        g.Enabled = false
    end)

    local m, n, o = {
        'Skins',
    }, {nil}, a.Instance.new'TextButton'

    o.BackgroundTransparency = 1
    o.Position = a.UDim2.fromOffset(12, 38)
    o.Size = a.UDim2.fromOffset(70, 24)
    o.Font = a.Enum.Font.Code
    o.TextSize = 13
    o.Text = 'skins'
    o.TextColor3 = e[3][1].accentclr
    o.Parent = h

    local p = a.Instance.new'TextButton'

    p.BackgroundTransparency = 1
    p.Position = a.UDim2.fromOffset(88, 38)
    p.Size = a.UDim2.fromOffset(70, 24)
    p.Font = a.Enum.Font.Code
    p.TextSize = 13
    p.Text = 'wraps'
    p.TextColor3 = a.Color3.fromRGB(160, 160, 160)
    p.Parent = h

    local q = a.Instance.new'ScrollingFrame'

    q.Name = 'Weapons'
    q.Position = a.UDim2.fromOffset(10, 70)
    q.Size = a.UDim2.new(0, 205, 1, -80)
    q.BackgroundColor3 = a.Color3.fromRGB(24, 24, 26)
    q.BorderSizePixel = 0
    q.ScrollBarThickness = 3
    q.CanvasSize = a.UDim2.new()
    q.Parent = h

    local r = a.Instance.new('UIListLayout', q)

    r.Padding = a.UDim.new(0, 4)
    r.SortOrder = a.Enum.SortOrder.LayoutOrder

    local s = a.Instance.new'ScrollingFrame'

    s.Name = 'Items'
    s.Position = a.UDim2.fromOffset(225, 70)
    s.Size = a.UDim2.new(1, -235, 1, -80)
    s.BackgroundColor3 = a.Color3.fromRGB(24, 24, 26)
    s.BorderSizePixel = 0
    s.ScrollBarThickness = 3
    s.CanvasSize = a.UDim2.new()
    s.Parent = h

    local t = a.Instance.new('UIListLayout', s)

    t.Padding = a.UDim.new(0, 4)
    t.SortOrder = a.Enum.SortOrder.LayoutOrder

    local function clearItems()
        for u, v in ipairs(s:GetChildren())do
            if v:IsA'TextButton' then
                v:Destroy()
            end
        end
    end

    local u = {nil}

    u[1] = function(v)
        return d.refresh_skin_changer({
            {clearItems},
            n,
            {k},
            m,
            e[4],
            e[5],
            e[6],
            e[3],
            {s},
            e[7],
            e[8],
            u,
            {t},
        }, v)
    end

    local v = {}

    for w in pairs(e[5][1])do
        v[#v + 1] = w
    end

    a.table.sort(v)

    for w, x in ipairs(v)do
        local y, z = x, a.Instance.new'TextButton'

        z.Size = a.UDim2.new(1, -8, 0, 28)
        z.BackgroundColor3 = a.Color3.fromRGB(30, 30, 32)
        z.BorderSizePixel = 0
        z.Font = a.Enum.Font.Code
        z.TextSize = 12
        z.Text = y
        z.TextColor3 = a.Color3.fromRGB(210, 210, 210)
        z.Parent = q

        z.MouseButton1Click:Connect(function()
            for A, B in ipairs(q:GetChildren())do
                if B:IsA'TextButton' then
                    B.BackgroundColor3 = a.Color3.fromRGB(30, 30, 32)
                    B.TextColor3 = a.Color3.fromRGB(210, 210, 210)
                end
            end

            z.BackgroundColor3 = a.Color3.fromRGB(36, 36, 42)
            z.TextColor3 = e[3][1].accentclr

            u[1](y)
        end)
    end

    local function syncTabs()
        if m[1] == 'Skins' then
            o.TextColor3 = e[3][1].accentclr
            p.TextColor3 = a.Color3.fromRGB(160, 160, 160)
        else
            p.TextColor3 = e[3][1].accentclr
            o.TextColor3 = a.Color3.fromRGB(160, 160, 160)
        end
    end

    o.MouseButton1Click:Connect(function()
        m[1] = 'Skins'

        syncTabs()

        if n[1] then
            u[1](n[1])
        end
    end)
    p.MouseButton1Click:Connect(function()
        m[1] = 'Wraps'

        syncTabs()

        if n[1] then
            u[1](n[1])
        end
    end)
    r:GetPropertyChangedSignal'AbsoluteContentSize':Connect(function()
        q.CanvasSize = a.UDim2.fromOffset(0, r.AbsoluteContentSize.Y + 10)
    end)
    t:GetPropertyChangedSignal'AbsoluteContentSize':Connect(function()
        s.CanvasSize = a.UDim2.fromOffset(0, t.AbsoluteContentSize.Y + 12)
    end)

    local w, x, y = false

    j.InputBegan:Connect(function(z)
        if z.UserInputType == a.Enum.UserInputType.MouseButton1 or z.UserInputType == a.Enum.UserInputType.Touch then
            w = true
            x = z.Position
            y = h.Position
        end
    end)
    j.InputEnded:Connect(function(z)
        if z.UserInputType == a.Enum.UserInputType.MouseButton1 or z.UserInputType == a.Enum.UserInputType.Touch then
            w = false
        end
    end)
    f.InputChanged:Connect(function(z)
        if w and (z.UserInputType == a.Enum.UserInputType.MouseMovement or z.UserInputType == a.Enum.UserInputType.Touch) then
            local A = z.Position - x

            h.Position = a.UDim2.new(y.X.Scale, y.X.Offset + A.X, y.Y.Scale, y.Y.Offset + A.Y)
        end
    end)

    if v[1] then
        u[1](v[1])
    end

    g.Enabled = true

    return g
end
d.p360 = function(e)
    local f, g, h, i, j, k = (a.require(e[1][1].Modules.ReplicatedClass))
    local l = f:ToEnum'Data'

    g = f
    h = l
    i = e[2][1]
    j = l
    k = e[2][1][l]

    if (e[2][1][l]) then
    else
        local m = {}

        k = m
    end

    i[j] = k
    i = e[3][1][e[4][1] ]

    if (not e[3][1][e[4][1] ].Skin) then
    else
        local m = g:ToEnum'Skin'

        e[2][1][h][m] = i.Skin
    end
    if (not i.Wrap) then
    else
        local m = g:ToEnum'Wrap'

        e[2][1][h][m] = i.Wrap
    end
    if (not i.Charm) then
    else
        local m = g:ToEnum'Charm'

        e[2][1][h][m] = i.Charm
    end

    return
end
d.p359 = function(e, f, g)
    local h, i, j = {f}, g.ClientFighter and g.ClientFighter.Player, e[1][1] or g.Name
    local k = {j}

    if e[2][1] and i == e[3][1] and e[4][1][j] then
        a.pcall(function()
            d.p360{
                e[5],
                h,
                e[4],
                k,
            }
        end)
    end

    return e[6][1](h[1], g)
end
d.p358 = function(e)
    local f, g = (e[1][1].PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem:FindFirstChild'ClientViewModel')

    g = f

    if (not (not f)) then
        local h = a.require(g)
        local i = {
            h.new,
        }

        h.new = function(...)
            return d.p359({
                e[2],
                e[3],
                e[1],
                e[4],
                e[5],
                i,
            }, ...)
        end

        return
    else
        return
    end
end
d.p357 = function(e)
    local f, g = (e[1][1]:ToEnum'Data')

    g = f

    if (not e[2][1][f]) then
    else
        if (not e[3][1][e[4][1] ].Skin) then
        else
            local h = e[1][1]:ToEnum'Skin'

            e[2][1][g][h] = e[3][1][e[4][1] ].Skin

            local i = e[1][1]:ToEnum'Name'

            e[2][1][g][i] = e[3][1][e[4][1] ].Skin.Name
        end
        if (not e[3][1][e[4][1] ].Wrap) then
        else
            local h = e[1][1]:ToEnum'Wrap'

            e[2][1][g][h] = e[3][1][e[4][1] ].Wrap
        end
        if (not e[3][1][e[4][1] ].Charm) then
        else
            local h = e[1][1]:ToEnum'Charm'

            e[2][1][g][h] = e[3][1][e[4][1] ].Charm
        end
    end

    return
end
d.p356 = function(e, f, g)
    local h, i, j, k, l

    h = f
    i = g

    local m, n = {h}, {i}
    local o = {
        m[1].Name,
    }

    h = m
    i = n
    j = o
    k = m[1].ClientFighter

    if (not m[1].ClientFighter) then
    else
        k = h[1].ClientFighter.Player
    end

    l = (k == e[1][1])

    if (not (k == e[1][1])) then
    else
        l = j[1]
    end
    if (l) then
    else
        l = nil
    end

    e[2][1] = l
    l = e[3][1]

    if (not e[3][1]) then
    else
        l = (k == e[1][1])
    end
    if (not l) then
    else
        l = e[4][1][j[1] ]
    end
    if (not l) then
    else
        a.pcall(function(...)
            return d.p357({
                h,
                i,
                e[4],
                j,
            }, ...)
        end)
    end

    local p = e[5][1](h[1], i[1])

    e[2][1] = nil

    return p
end
d.p355 = function(e)
    return a.require(e[1][1].PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem)
end
d.p354 = function(e)
    e[1][1].CurrentData:Replicate'WeaponInventory'

    return
end
d.p353 = function(e)
    a.pcall(function(...)
        return d.p354({
            e[1],
        }, ...)
    end)

    return
end
d.p352 = function(e, f, ...)
    local g = a.getnamecallmethod()

    if g ~= 'FireServer' or f ~= e[1][1] or not e[3][1] then
        return e[2][1](f, ...)
    end

    local h = {...}
    local i, j, k, l = h[1], h[2], h[3], h[4] or {}

    e[4][1][i] = e[4][1][i] or {}

    if not k or k == 'None' or k == '' then
        e[4][1][i][j] = nil
    else
        local m = e[5][1](k, j, {
            inverted = l.IsInverted,
            favoritesOnly = l.OnlyUseFavorites,
        })

        if m then
            e[4][1][i][j] = m
        end
    end

    a.task.defer(function()
        return d.p353{
            e[6],
        }
    end)
    e[7][1]()
end
d.p351 = function(e, f, g)
    local h = e[1][1](f, g)

    if not h then
        return nil
    end

    local i = {}

    for j, k in pairs(h)do
        i[j] = k
    end

    i.Name = g

    local j = e[2][1][g]

    if j then
        for k, l in pairs(j)do
            i[k] = l
        end
    end

    return i
end
d.p350 = function(e, f, g)
    local h, i, j, k

    h = f
    i = g
    j = e[1][1].Cosmetics[i]
    k = e[1][1].Cosmetics[i]

    if (not e[1][1].Cosmetics[i]) then
    else
        k = e[2][1][j.Type]
    end
    if (not k) then
        k = e[3][1]

        if (not e[3][1]) then
        else
            k = e[3][1][i]
        end
        if (k) then
        else
            k = nil
        end

        return k
    else
        return true
    end
end
d.p349 = function(e, f, g)
    local h = e[1][1](f, g)

    if not e[2][1] then
        return h
    end
    if g == 'CosmeticInventory' then
        local i = {h}

        return a.setmetatable({}, {
            __index = function(...)
                return d.p350({
                    e[3],
                    e[4],
                    i,
                }, ...)
            end,
        })
    end

    return h
end
d.p348 = function(e, f, g, h, i)
    local j, k, l, m, n, o

    j = f
    k = g
    l = h
    m = i

    if (not (not e[1][1])) then
        n = e[2][1].Cosmetics[l]
        o = e[2][1].Cosmetics[l]

        if (not e[2][1].Cosmetics[l]) then
        else
            o = (n.Type == 'Skin')
        end

        return o
    else
        return false
    end
end
d.p347 = function(e, f, g, h, i)
    local j = e[2][1]

    if not e[1][1] or h:find('MISSING_', 1, true) or h == 'Bubble Gun' then
        return j(f, g, h, i)
    end

    local k = e[3][1].Cosmetics[h]

    if k and e[4][1][k.Type] then
        return true
    end

    return j(f, g, h, i)
end
d.p346 = function(e)
    a.writefile(e[1][1], e[2][1]:JSONEncode(e[3][1]))

    return
end
d.p345 = function(e)
    a.task.wait(0.8)

    local f = {
        equipped = {},
        favorites = e[1][1],
    }

    for g, h in pairs(e[2][1])do
        f.equipped[g] = {}

        for i, j in pairs(h)do
            if j and j.Name then
                f.equipped[g][i] = {
                    Name = j.Name,
                    Inverted = j.Inverted,
                    OnlyUseFavorites = j.OnlyUseFavorites,
                }
            end
        end
    end

    a.pcall(function()
        return d.p346{
            e[3],
            e[4],
            {f},
        }
    end)

    e[5][1] = false
end
d.p344 = function(e)
    local f

    f = (not a.writefile)

    if ((not a.writefile)) then
    else
        f = e[1][1]
    end
    if (not f) then
        e[1][1] = true

        a.task.spawn(function(...)
            return d.p345({
                e[2],
                e[3],
                e[4],
                e[5],
                e[1],
            }, ...)
        end)

        return
    else
        return
    end
end
d.p343 = function(e)
    local f, g = (a.isfile(e[1][1]))

    g = f

    if (not f) then
    else
        local h = a.readfile(e[1][1])

        g = h
    end

    return g
end
d.p342 = function(e)
    if not a.isfile or not a.readfile then
        return
    end

    local f, g = a.pcall(function()
        return d.p343{
            e[1],
        }
    end)

    if not f or not g or g == '' or g == false then
        return
    end

    local h, i = a.pcall(e[2][1].JSONDecode, e[2][1], g)

    if not h or not i then
        return
    end
    if i.favorites then
        e[3][1] = i.favorites
    end
    if i.equipped then
        for j, k in pairs(i.equipped)do
            e[4][1][j] = {}

            for l, m in pairs(k)do
                if m and m.Name and e[5][1].Cosmetics[m.Name] then
                    local n = e[6][1](m.Name, l, {
                        inverted = m.Inverted,
                        favoritesOnly = m.OnlyUseFavorites,
                    })

                    if n then
                        e[4][1][j][l] = n
                    end
                end
            end
        end
    end
end
d.p341 = function(e, f, g, h)
    local i = e[1][1].Cosmetics[f]

    if not i then
        return nil
    end

    local j = {}

    for k, l in pairs(i)do
        j[k] = l
    end

    j.Name = f
    j.Type = j.Type or g
    j.Seed = j.Seed or a.math.random(1, 1000000)

    if h then
        if h.inverted ~= nil then
            j.Inverted = h.inverted
        end
        if h.favoritesOnly ~= nil then
            j.OnlyUseFavorites = h.favoritesOnly
        end
    end

    return j
end
d.p340 = function(e)
    if (not e[1][1]) then
    else
        e[1][1]:WaitForEnumBuilder()
    end

    return
end
d.unlock_cosmetics_core = function(e)
    local f, g = {
        e[1][1],
    }, {
        e[2][1],
    }
    local h, i, j = g[1]:WaitForChild('PlayerScripts', 15):WaitForChild('Controllers', 15), f[1]:WaitForChild('Modules', 15), {
        e[3][1],
    }
    local k = {
        a.require(i:WaitForChild('EnumLibrary', 10)),
    }

    a.pcall(function()
        return d.p340{k}
    end)

    local l, m, n, o, p, q, r = {
        a.require(i:WaitForChild('CosmeticLibrary', 10)),
    }, {
        a.require(h:WaitForChild('PlayerDataController', 10)),
    }, {{}}, {{}}, {nil}, {
        'rivals_unlocker_config.json',
    }, {false}
    local s = {
        function(...)
            return d.p341({l}, ...)
        end,
    }
    local t, u = function(...)
        return d.p342({
            q,
            j,
            o,
            n,
            l,
            s,
        }, ...)
    end, {
        function(...)
            return d.p344({
                r,
                o,
                n,
                q,
                j,
            }, ...)
        end,
    }

    t()

    local v, w = {
        {
            Skin = true,
            Wrap = true,
            Charm = true,
            Dance = true,
            Emote = true,
        },
    }, {
        l[1].OwnsCosmetic,
    }

    l[1].OwnsCosmetic = function(...)
        return d.p347({
            e[4],
            w,
            l,
            v,
        }, ...)
    end

    for x, y in ipairs{
        'OwnsCosmeticNormally',
        'OwnsCosmeticUniversally',
        'OwnsCosmeticForWeapon',
    }do
        if l[1][y] then
            l[1][y] = function(...)
                return d.p348({
                    e[4],
                    l,
                }, ...)
            end
        end
    end

    local x = {
        m[1].Get,
    }

    m[1].Get = function(...)
        return d.p349({
            x,
            e[4],
            l,
            v,
        }, ...)
    end

    local y = {
        m[1].GetWeaponData,
    }

    if y[1] then
        m[1].GetWeaponData = function(...)
            return d.p351({y, n}, ...)
        end
    end
    if a.hookmetamethod then
        local z = f[1]:FindFirstChild'Remotes'
        local A = z and z:FindFirstChild'Data'
        local B, C = A and A:FindFirstChild'EquipCosmetic', {nil}

        if B then
            C[1] = a.hookmetamethod(a.game, '__namecall', function(...)
                return d.p352({
                    {B},
                    C,
                    e[4],
                    n,
                    s,
                    m,
                    u,
                }, ...)
            end)
        end
    end

    local z, A = a.pcall(function()
        return d.p355{g}
    end)

    if z and A then
        if A._CreateViewModel then
            local B = {
                A._CreateViewModel,
            }

            A._CreateViewModel = function(...)
                return d.p356({
                    g,
                    p,
                    e[4],
                    n,
                    B,
                }, ...)
            end
        end

        a.pcall(function()
            return d.p358{
                g,
                p,
                e[4],
                n,
                f,
            }
        end)
    end
end
d.p338 = function(e)
    if (not e[1][1]) then
        e[1][1] = true

        a.pcall(function(...)
            return d.unlock_cosmetics_core({
                e[2],
                e[3],
                e[4],
                e[5],
            }, ...)
        end)

        return
    else
        return
    end
end
d.p337 = function(e)
    local f = e[1][1]

    if not f then
        return nil
    end

    local g = e[2][1].ClientItem
    local h = g and g.Name
    local i = h and e[3][1][h]

    if i and i.Wrap and i.Wrap ~= 'None' then
        return e[4][1](i.Wrap, 'Wrap')
    end

    return nil
end
d.p336 = function(e, f)
    local g, h = a.pcall(function()
        return d.p337{
            e[1],
            {f},
            e[2],
            e[3],
        }
    end)

    if g and h then
        return h
    end

    return e[4][1](f)
end
d.p335 = function(e)
    local f, g, h, i, j, k, l, m, n

    f = (not e[1][1])

    if ((not e[1][1])) then
    else
        f = (not e[2][1])
    end
    if (not f) then
        g = e[3][1][e[2][1].Name]
        h = (not e[3][1][e[2][1].Name])

        if ((not e[3][1][e[2][1].Name])) then
        else
            h = (not g.Skin)
        end
        if (h) then
        else
            h = (g.Skin == 'Default')
        end
        if (not h) then
            local o = e[4][1](g.Skin, 'Skin')

            h = o

            if (not (not o)) then
                local p, q, r = e[5][1]:ToEnum'Data', e[5][1]:ToEnum'Skin', e[5][1]:ToEnum'Name'

                i = p
                j = q
                k = r
                l = e[6][1]
                m = p
                n = e[6][1][p]

                if (e[6][1][p]) then
                else
                    local s = {}

                    n = s
                end

                l[m] = n
                e[6][1][i][j] = h
                e[6][1][i][k] = g.Skin

                return
            else
                return
            end
        else
            return
        end
    else
        return
    end
end
d.p334 = function(e, f, g)
    local h, i = {f}, {g}

    a.pcall(function(...)
        return d.p335({
            e[1],
            i,
            e[2],
            e[3],
            e[4],
            h,
        }, ...)
    end)

    return e[5][1](h[1], i[1])
end
d.p333 = function(e, f, g)
    local h = e[1][1].Cosmetics and e[1][1].Cosmetics[f]

    if not h then
        return nil
    end

    local i = {}

    for j, k in pairs(h)do
        i[j] = k
    end

    i.Name = f
    i.Type = g or i.Type

    return i
end
d.install_skin_hooks = function(e)
    local f, g, h, i, j = (a.require(e[1][1].Modules.CosmeticLibrary))
    local k, l = {f}, e[2][1]:WaitForChild('PlayerScripts', 8)
    local m = a.require(l.Modules.ClientReplicatedClasses.ClientFighter.ClientItem.ClientViewModel)

    g = k
    h = m
    i = (not m)

    if ((not m)) then
    else
        i = h.__nexSkin
    end
    if (not i) then
        h.__nexSkin = true

        local n = a.require(e[1][1].Modules.ReplicatedClass)
        local o, p = {n}, {nil}

        p[1] = function(...)
            return d.p333({g}, ...)
        end

        local q = {
            h.new,
        }

        h.new = function(...)
            return d.p334({
                e[3],
                e[4],
                p,
                o,
                q,
            }, ...)
        end
        j = p

        if (not h.GetWrap) then
        else
            local r = {
                h.GetWrap,
            }

            h.GetWrap = function(...)
                return d.p336({
                    e[3],
                    e[4],
                    j,
                    r,
                }, ...)
            end
        end

        return
    else
        return
    end
end
d.p331 = function(e)
    a.pcall(function(...)
        return d.install_skin_hooks({
            e[1],
            e[2],
            e[3],
            e[4],
        }, ...)
    end)

    return
end
d.load_skin_config = function(e)
    if a.isfile and a.isfile'VantaNex_skins.json' then
        local f = e[1][1]:JSONDecode(a.readfile'VantaNex_skins.json')

        if a.type(f) == 'table' then
            for g, h in pairs(f)do
                e[2][1][g] = h
            end
        end
    end
end
d.build_skin_lists = function(e)
    local f, g, h = a.getgenv(), {}, {}

    h[1] = 'Default'
    h[2] = 'AK-47'
    h[3] = 'AUG'
    h[4] = 'Tommy Gun'
    h[5] = 'Boneclaw Rifle'
    h[6] = 'Gingerbread AUG'
    h[7] = 'AKEY-47'
    h[8] = '100K Visits'
    h[9] = '10 Billion Visits'
    h[10] = 'Phoenix Rifle'
    g['Assault Rifle'] = h

    local i = {}

    i[1] = 'Default'
    i[2] = 'Compound Bow'
    i[3] = 'Raven Bow'
    i[4] = 'Dream Bow'
    i[5] = 'Bat Bow'
    i[6] = 'Frostbite Bow'
    i[7] = 'Beloved Bow'
    i[8] = 'Balloon Bow'
    i[9] = 'Glorious Bow'
    i[10] = 'Key Bow'
    i[11] = 'Arch Bow'
    g.Bow = i

    local j = {}

    j[1] = 'Default'
    j[2] = 'Electro Burst'
    j[3] = 'Aqua Burst'
    j[4] = 'FAMAS'
    j[5] = 'Spectral Burst'
    j[6] = 'Pine Burst'
    g['Burst Rifle'] = j

    local k = {}

    k[1] = 'Default'
    k[2] = 'Pixel Crossbow'
    k[3] = 'Harpoon Crossbow'
    k[4] = 'Violin Crossbow'
    k[5] = 'Crossbone'
    k[6] = 'Frostbite Crossbow'
    k[7] = 'Arch Crossbow'
    k[8] = 'Glorious Crossbow'
    g.Crossbow = k

    local l = {}

    l[1] = 'Default'
    l[2] = 'Plasma Distortion'
    l[3] = 'Magma Distortion'
    l[4] = 'Cyber Distortion'
    l[5] = 'Expirement D15'
    l[6] = 'Sleighstortion'
    g.Distortion = l

    local m = {}

    m[1] = 'Default'
    m[2] = 'Hacker Rifle'
    m[3] = 'Hydro Rifle'
    m[4] = 'Void Rifle'
    m[5] = 'Soul Rifle'
    m[6] = 'New Years Energy Rifle'
    g['Energy Rifle'] = m

    local n = {}

    n[1] = 'Default'
    n[2] = 'Pixel Flamethrower'
    n[3] = 'Lamethrower'
    n[4] = 'Glitterthrower'
    n[5] = "Jack O' Thrower"
    n[6] = 'Snowblower'
    n[7] = 'Keythrower'
    n[8] = 'Rainbowthrower'
    g.Flamethrower = n

    local o = {}

    o[1] = 'Default'
    o[2] = 'Swashbuckler'
    o[3] = 'Uranium Launcher'
    o[4] = 'Gearnade Launcher'
    o[5] = 'Skull Grenade Launcher'
    o[6] = 'Snowball Launcher'
    g['Grenade Launcher'] = o

    local p = {}

    p[1] = 'Default'
    p[2] = 'Hyper Gunblade'
    p[3] = 'Crude Gunblade'
    p[4] = 'Gunsaw'
    p[5] = 'Boneblade'
    p[6] = "Elf's Gunblade"
    g.Gunblade = p

    local q = {}

    q[1] = 'Default'
    q[2] = 'Lasergun 3000'
    q[3] = 'Pixel Minigun'
    q[4] = 'Fighter Jet'
    q[5] = 'Pumpkin Minigun'
    q[6] = 'Wrapped Minigun'
    g.Minigun = q

    local r = {}

    r[1] = 'Default'
    r[2] = 'Slime Gun'
    r[3] = 'Boba Gun'
    r[4] = 'Ketchup Gun'
    r[5] = 'Brain Gun'
    r[6] = 'Snowball Gun'
    g['Paintball Gun'] = r

    local s = {}

    s[1] = 'Default'
    s[2] = 'Nuke Launcher'
    s[3] = 'Spaceship Launcher'
    s[4] = 'Squid Launcher'
    s[5] = 'Pumpkin Launcher'
    s[6] = 'Firework Launcher'
    g.RPG = s

    local t = {}

    t[1] = 'Default'
    t[2] = 'Balloon Shotgun'
    t[3] = 'Hyper Shotgun'
    t[4] = 'Cactus Shotgun'
    t[5] = 'Broomstick'
    t[6] = 'Wrapped Shotgun'
    g.Shotgun = t

    local u = {}

    u[1] = 'Default'
    u[2] = 'Pixel Sniper'
    u[3] = 'Hyper Sniper'
    u[4] = 'Event Horizon'
    u[5] = 'Eyething Sniper'
    u[6] = 'Gingerbread Sniper'
    u[7] = 'Keyper'
    u[8] = 'Glorious Sniper'
    g.Sniper = u

    local v = {}

    v[1] = 'Default'
    v[2] = 'Aces'
    v[3] = 'Paper Planes'
    v[4] = 'Shurikens'
    v[5] = 'Bat Daggers'
    v[6] = 'Cookies'
    v[7] = 'Crystal Daggers'
    v[8] = 'Keynais'
    g.Daggers = v

    local w = {}

    w[1] = 'Default'
    w[2] = 'Void Pistols'
    w[3] = 'Hydro Pistols'
    w[4] = 'Soul Pistols'
    w[5] = 'New Years Energy Pistols'
    g['Energy Pistols'] = w

    local x = {}

    x[1] = 'Default'
    x[2] = 'Singularity'
    x[3] = 'Raygun'
    x[4] = 'Repulsor'
    x[5] = 'Exogourd'
    x[6] = 'Midnight Festive Exogun'
    g.Exogun = x

    local y = {}

    y[1] = 'Default'
    y[2] = 'Firework Gun'
    y[3] = 'Dynamite Gun'
    y[4] = 'Banana Flare'
    y[5] = 'Vexed Flare Gun'
    y[6] = 'Wrapped Flare Gun'
    g['Flare Gun'] = y

    local z = {}

    z[1] = 'Default'
    z[2] = 'Blaster'
    z[3] = 'Hand Gun'
    z[4] = 'Gumball Handgun'
    z[5] = 'Pumpkin Handgun'
    z[6] = 'Gingerbread Handgun'
    g.Handgun = z

    local A = {}

    A[1] = 'Default'
    A[2] = 'Desert Eagle'
    A[3] = 'Sheriff'
    A[4] = 'Peppergun'
    A[5] = 'Boneclaw Revolver'
    A[6] = 'Peppermint Sheriff'
    g.Revolver = A

    local B = {}

    B[1] = 'Default'
    B[2] = 'Not So Shorty'
    B[3] = 'Lovely Shorty'
    B[4] = 'Balloon Shorty'
    B[5] = 'Demon Shorty'
    B[6] = 'Wrapped Shorty'
    g.Shorty = B

    local C = {}

    C[1] = 'Default'
    C[2] = 'Stick'
    C[3] = 'Goal Post'
    C[4] = 'Harp'
    C[5] = 'Boneshot'
    C[6] = 'Reindeer Slingshot'
    C[7] = 'Lucky Horseshoe'
    g.Slingshot = C

    local D = {}

    D[1] = 'Default'
    D[2] = 'Lovely Spray'
    D[3] = 'Nail Gun'
    D[4] = 'Bottle Spray'
    D[5] = 'Boneclaw Spray'
    D[6] = 'Pine Spray'
    D[7] = 'Key Spray'
    g.Spray = D

    local E = {}

    E[1] = 'Default'
    E[2] = 'Water Uzi'
    E[3] = 'Electro Uzi'
    E[4] = 'Money Gun'
    E[5] = 'Demon Uzi'
    E[6] = 'Pine Uzi'
    g.Uzi = E

    local F = {}

    F[1] = 'Default'
    F[2] = 'Glitter Warper'
    F[3] = 'Arcane Warper'
    F[4] = 'Hotel Bell'
    F[5] = 'Experiment W4'
    F[6] = 'Frost Warper'
    g.Warper = F

    local G = {}

    G[1] = 'Default'
    G[2] = 'The Shred'
    G[3] = 'Ban Axe'
    G[4] = 'Cerulean Axe'
    G[5] = 'Mimic Axe'
    G[6] = 'Nordic Axe'
    g['Battle Axe'] = G

    local H = {}

    H[1] = 'Default'
    H[2] = 'Blobsaw'
    H[3] = 'Handsaws'
    H[4] = 'Mega Drill'
    H[5] = 'Buzzsaw'
    H[6] = 'Festive Buzzsaw'
    g.Chainsaw = H

    local I = {}

    I[1] = 'Default'
    I[2] = 'Boxing Gloves'
    I[3] = 'Brass Knuckles'
    I[4] = 'Fists Of Hurt'
    I[5] = 'Pumpkin Claws'
    I[6] = 'Festive Fists'
    g.Fists = I

    local J = {}

    J[1] = 'Default'
    J[2] = 'Saber'
    J[3] = 'Lightning Bolt'
    J[4] = 'Stellar Katana'
    J[5] = 'Evil Trident'
    J[6] = 'New Years Katana'
    J[7] = 'Keytana'
    J[8] = 'Arch Katana'
    J[9] = 'Crystal Katana'
    J[10] = 'Pixel Katana'
    J[11] = 'Glorious Katana'
    g.Katana = J

    local K = {}

    K[1] = 'Default'
    K[2] = 'Chancla'
    K[3] = 'Karambit'
    K[4] = 'Balisong'
    K[5] = 'Machete'
    K[6] = 'Candy Cane'
    K[7] = 'Keylisong'
    K[8] = 'Keyrambit'
    K[9] = 'Caladbolg'
    g.Knife = K

    local L = {}

    L[1] = 'Default'
    L[2] = 'Door'
    L[3] = 'Energy Shield'
    L[4] = 'Masterpiece'
    L[5] = 'Tombstone Shield'
    L[6] = 'Sled'
    g['Riot Shield'] = L

    local M = {}

    M[1] = 'Default'
    M[2] = 'Scythe of Death'
    M[3] = 'Anchor'
    M[4] = 'Sakura Scythe'
    M[5] = 'Bat Scythe'
    M[6] = 'Cryo Scythe'
    M[7] = 'Crystal Scythe'
    M[8] = 'Keythe'
    M[9] = 'Bug Net'
    M[10] = 'Arch Scythe'
    g.Scythe = M

    local N = {}

    N[1] = 'Default'
    N[2] = 'Plastic Shovel'
    N[3] = 'Garden Shovel'
    N[4] = 'Paintbrush'
    N[5] = 'Pumpkin Carver'
    N[6] = 'Snow Shovel'
    g.Trowel = N

    local O = {}

    O[1] = 'Default'
    O[2] = 'Disco Ball'
    O[3] = 'Camera'
    O[4] = 'Lightbulb'
    O[5] = 'Skullbang'
    O[6] = 'Shining Star'
    g.Flashbang = O

    local P = {}

    P[1] = 'Default'
    P[2] = 'Temporal Ray'
    P[3] = 'Bubble Ray'
    P[4] = 'Gum Ray'
    P[5] = 'Spider Ray'
    P[6] = 'Wrapped Freeze Ray'
    g['Freeze Ray'] = P

    local Q = {}

    Q[1] = 'Default'
    Q[2] = 'Whoopee Cushion'
    Q[3] = 'Water Balloon'
    Q[4] = 'Dynamite'
    Q[5] = 'Soul Grenade'
    Q[6] = 'Jingle Grenade'
    g.Grenade = Q

    local R = {}

    R[1] = 'Default'
    R[2] = 'Trampoline'
    R[3] = 'Bounce House'
    R[4] = 'Shady Chicken Sandwich'
    R[5] = 'Spider Web'
    R[6] = 'Jolly Man'
    g['Jump Pad'] = R

    local S = {}

    S[1] = 'Default'
    S[2] = 'Sandwich'
    S[3] = 'Laptop'
    S[4] = 'Medkitty'
    S[5] = 'Bucket of Candy'
    S[6] = 'Milk & Cookies'
    S[7] = 'Box of Chocolates'
    S[8] = 'Briefcase'
    g.Medkit = S

    local T = {}

    T[1] = 'Default'
    T[2] = 'Coffee'
    T[3] = 'Torch'
    T[4] = 'Lava Lamp'
    T[5] = 'Vexed Candle'
    T[6] = 'Hot Coals'
    T[7] = 'Arch Molotov'
    g.Molotov = T

    local U = {}

    U[1] = 'Default'
    U[2] = 'Advanced Satchel'
    U[3] = 'Notebook Satchel'
    U[4] = "Bag O' Money"
    U[5] = 'Potion Satchel'
    U[6] = 'Suspicious Gift'
    g.Satchel = U

    local V = {}

    V[1] = 'Default'
    V[2] = 'Emoji Cloud'
    V[3] = 'Balance'
    V[4] = 'Hourglass'
    V[5] = 'Eyeball'
    V[6] = 'Snowglobe'
    g['Smoke Grenade'] = V

    local W = {}

    W[1] = 'Default'
    W[2] = "Don't Press"
    W[3] = 'Spring'
    W[4] = 'DIY Tripmine'
    W[5] = 'Trick or Treat'
    W[6] = 'Dev In the Box'
    W[7] = 'Pot O Keys'
    g['Subspace Tripmine'] = W

    local X = {}

    X[1] = 'Default'
    X[2] = 'Trumpet'
    X[3] = 'Megaphone'
    X[4] = 'Air Horn'
    X[5] = 'Boneclaw Horn'
    X[6] = 'Mammoth Horn'
    g['War Horn'] = X

    local Y = {}

    Y[1] = 'Default'
    Y[2] = 'Cyber Warpstone'
    Y[3] = 'Teleport Disc'
    Y[4] = 'Electropunk Warpstone'
    Y[5] = 'Warpbone'
    Y[6] = 'Warpstar'
    g.Warpstone = Y

    local Z = {}

    Z[1] = 'Default'
    Z[2] = 'Snowman Permafrost'
    Z[3] = 'Ice Permafrost'
    Z[4] = 'Glorious Permafrost'
    g.Permafrost = Z
    f._VantaSkinLists = g

    local _, aa = a.getgenv(), {}

    aa[1] = 'None'
    aa[2] = 'Gold'
    aa[3] = 'Diamond'
    aa[4] = 'Midas Touch'
    aa[5] = 'Community Wrap'
    aa[6] = 'Blush Wrapping'
    aa[7] = 'Brain'
    aa[8] = 'Crystalliz'
    aa[9] = 'Damascus'
    aa[10] = 'Black Damascus'
    aa[11] = '.exe wrap'
    aa[12] = 'Groove'
    aa[13] = 'Hollow Wrap'
    aa[14] = 'Hesper'
    aa[15] = 'Hyperdrive'
    aa[16] = 'Gingerbread'
    aa[17] = 'Neon Lights'
    aa[18] = 'Hologram Arena'
    aa[19] = 'Sunset'
    aa[20] = 'Pink Lemonade'
    aa[21] = 'Lovely Leopard'
    aa[22] = 'Dawn'
    aa[23] = 'Spectral'
    aa[24] = 'Danger'
    aa[25] = 'Termination'
    aa[26] = 'Moonstone'
    aa[27] = 'Starfall'
    aa[28] = 'Black Glass'
    aa[29] = 'Rift Wrap'
    aa[30] = 'Starblaze'
    aa[31] = 'Maganite'
    aa[32] = 'Watermelon'
    aa[33] = 'Reptile'
    aa[34] = 'Water'
    aa[35] = 'OranGG'
    aa[36] = 'A5'
    aa[37] = 'Cheese'
    aa[38] = 'Nova'
    aa[39] = 'Supernova'
    aa[40] = 'Glass'
    aa[41] = 'Mesh'
    aa[42] = 'Meat Wrap'
    aa[43] = 'Black Dark Wrap'
    aa[44] = 'Cardinal'
    aa[45] = 'Pixel Camo'
    aa[46] = 'Nauseite'
    aa[47] = 'Sensite'
    aa[48] = 'Urban Camo'
    aa[49] = 'Frosted'
    aa[50] = 'Slime Wrap'
    aa[51] = 'Carpet Wrap'
    aa[52] = 'Cross Wrap'
    aa[53] = 'Mainframe Wrap'
    aa[54] = 'Honeycomb Wrap'
    aa[55] = 'Black Opal Wrap'
    aa[56] = 'Patriot'
    aa[57] = 'PB&J Wrap'
    aa[58] = 'Digital Camo'
    aa[59] = 'Street Camo'
    aa[60] = 'Ocean Camo'
    aa[61] = 'Circuit'
    aa[62] = 'Clouds'
    aa[63] = 'Woven'
    aa[64] = 'Ladybug'
    _._VantaWrapList = aa

    return
end
d.p328 = function(aa)
    a.pcall(function(...)
        return d.build_skin_lists({}, ...)
    end)

    return
end
d.p327 = function(aa, e)
    aa[1][1][3] = e

    return
end
d.p326 = function(aa, e)
    aa[1][1][2] = e

    return
end
d.p325 = function(aa, e)
    aa[1][1][1] = e

    return
end
d.p324 = function(aa, e)
    aa[1][1] = e

    return
end
d.p323 = function(aa)
    if (not aa[1][1]) then
    else
        aa[1][1]:FireServer(aa[2][1])
    end

    return
end
d.p322 = function(aa)
    if (not aa[1][1]) then
    else
        aa[1][1]:FireServer(aa[2][1])
    end

    return
end
d.p321 = function(aa)
    return aa[1][1].Remotes.Replication.Fighter.PickWeapons, aa[1][1].Remotes.Duels.PickWeaponsAheadOfTime
end
d.auto_loadout_worker = function(aa)
    while true do
        a.task.wait(0.25)

        if aa[1][1] then
            local e, f, g = a.pcall(function()
                return d.p321{
                    aa[2],
                }
            end)

            if e then
                local h = {}

                for i, j in ipairs(aa[3][1])do
                    if j and j ~= '' then
                        h[i] = j
                    end
                end

                if next(h) then
                    a.pcall(function()
                        return d.p322{
                            {f},
                            {h},
                        }
                    end)
                    a.pcall(function()
                        return d.p323{
                            {g},
                            {h},
                        }
                    end)
                end
            end
        end
    end
end
d.p319 = function(aa, e)
    local f

    f = e
    aa[1][1] = f

    if (not aa[2][1]) then
    else
        a.pcall(aa[3][1])
    end

    return
end
d.p318 = function(aa)
    local e, f, g, h = (aa[1][1]:FindFirstChild'Remotes')

    f = e
    g = e

    if (not e) then
    else
        local i = f:FindFirstChild'Matchmaking'

        g = i
    end

    h = g

    if (not g) then
    else
        local i = g:FindFirstChild'LeaveQueue'

        h = i
    end
    if (not h) then
    else
        h:FireServer()
    end

    return
end
d.p317 = function(aa)
    while aa[1][1] do
        a.pcall(aa[2][1])
        a.task.wait(5)
    end

    aa[3][1] = false
end
d.leave_queue_worker = function(aa, e)
    local f, g

    f = e
    aa[1][1] = f
    g = f

    if (not f) then
    else
        g = (not aa[2][1])
    end
    if (not g) then
        if (not (not f)) then
        else
            a.pcall(function(...)
                return d.p318({
                    aa[4],
                }, ...)
            end)
        end
    else
        aa[2][1] = true

        a.task.spawn(function(...)
            return d.p317({
                aa[1],
                aa[3],
                aa[2],
            }, ...)
        end)
    end

    return
end
d.p315 = function(aa)
    return a.require(aa[1][1].PlayerScripts.Controllers.MatchmakingController)
end
d.join_auto_queue = function(aa)
    local e, f, g = aa[1][1][aa[2][1] ] or aa[2][1] or '1v1', a.pcall(function()
        return d.p315{
            aa[3],
        }
    end)

    if f and g and g.QueueInto then
        return g:QueueInto(e)
    end

    local h = aa[4][1]:FindFirstChild'Remotes'
    local i = h and h:FindFirstChild'Matchmaking'
    local j = i and i:FindFirstChild'JoinQueue'

    if j and j.InvokeServer then
        return j:InvokeServer(e)
    end
    if j and j.FireServer then
        return j:FireServer(e)
    end
end
d.p313 = function(aa)
    return a.require(aa[1][1].Modules.DuelLibrary)
end
d.scan_auto_queue = function(aa)
    local e = {}

    aa[1][1] = {}

    local f, g = a.pcall(function()
        return d.p313{
            aa[2],
        }
    end)

    if f and g then
        for h, i in pairs(g.MatchmakingQueueOrder or {})do
            local j = g.MatchmakingQueues and g.MatchmakingQueues[i]
            local k = j and j.DisplayName or i

            a.table.insert(e, k)

            aa[1][1][k] = i
        end
    end
    if #e == 0 then
        e = {
            '1v1',
            '2v2',
            '3v3',
            '4v4',
            '5v5',
            'Ranked 1v1',
            'Ranked 2v2',
            'Ranked 3v3',
            'Ranked 4v4',
            'Ranked 5v5',
        }

        for h, i in ipairs(e)do
            local j = i:gsub('Ranked ', 'ranked_'):gsub(' ', ''):lower()

            aa[1][1][i] = j

            if i == '1v1' then
                aa[1][1][i] = '1v1'
            elseif i == '2v2' then
                aa[1][1][i] = '2v2'
            end
        end

        aa[1][1]['1v1'] = '1v1'
        aa[1][1]['2v2'] = '2v2_beginner'
        aa[1][1]['Ranked 1v1'] = 'ranked_1v1'
        aa[1][1]['Ranked 2v2'] = 'ranked_2v2'
    end

    return e
end
d.p311 = function(aa, e)
    aa[1][1].spoofed_winstreak = e

    return
end
d.set_winstreak_spoof = function(aa, e)
    aa[1][1].winstreak_spoof = e

    return
end
d.p309 = function(aa, e)
    aa[1][1].spoofed_level = e

    return
end
d.set_level_spoof = function(aa, e)
    aa[1][1].level_spoof = e

    return
end
d.p307 = function(aa, e)
    aa[1][1].enemy_name = e

    return
end
d.p306 = function(aa, e)
    aa[1][1].your_name = e

    return
end
d.set_name_spoof = function(aa, e)
    aa[1][1].name_spoof = e

    return
end
d.spoof_worker = function(aa)
    while a.task.wait(2) do
        local e = aa[1][1]

        if e.name_spoof then
            for f, g in ipairs(aa[2][1]:GetPlayers())do
                aa[3][1](g)
            end
        end
        if e.level_spoof or e.winstreak_spoof then
            aa[4][1]()
        end
    end
end
d.p303 = function(aa)
    aa[1][1]:SetAttribute('WinStreak', aa[2][1].spoofed_winstreak)

    return
end
d.p302 = function(aa)
    aa[1][1].Value = aa[2][1].spoofed_winstreak

    return
end
d.p301 = function(aa)
    aa[1][1]:SetAttribute('Level', aa[2][1].spoofed_level)

    return
end
d.p300 = function(aa)
    aa[1][1].Value = aa[2][1].spoofed_level

    return
end
d.apply_level_streak_spoof = function(aa)
    local e, f = aa[1][1], aa[2][1]
    local g = e:FindFirstChild'CustomLeaderstats'

    if not g then
        return
    end
    if f.level_spoof then
        local h = g:FindFirstChild'Level'

        if h and h:IsA'IntValue' then
            a.pcall(function()
                h.Value = f.spoofed_level
            end)
        end

        a.pcall(function()
            e:SetAttribute('Level', f.spoofed_level)
        end)
    end
    if f.winstreak_spoof then
        for h, i in ipairs{
            'WinStreak',
            'Winstreak',
            'Streak',
            'Wins',
        }do
            local j = g:FindFirstChild(i)

            if not j then
                local k = g:FindFirstChild'WinStreak'

                j = k and k:FindFirstChild'Value'
            end
            if j and (j:IsA'IntValue' or j:IsA'NumberValue') then
                a.pcall(function()
                    j.Value = f.spoofed_winstreak
                end)
            end
        end

        a.pcall(function()
            e:SetAttribute('WinStreak', f.spoofed_winstreak)
        end)
    end
end
d.p298 = function(aa)
    if (not (aa[1][1] == aa[2][1])) then
        aa[1][1].DisplayName = aa[3][1].enemy_name
    else
        aa[1][1].DisplayName = aa[3][1].your_name
    end

    return
end
d.apply_name_spoof = function(aa, e)
    local f

    f = e

    local g = {f}

    f = g

    if (not (not aa[1][1].name_spoof)) then
        a.pcall(function(...)
            return d.p298({
                f,
                aa[2],
                aa[1],
            }, ...)
        end)

        return
    else
        return
    end
end
d.client_feature_bootstrap = function(aa)
    local e, f = {
        a.game:GetService'HttpService',
    }, {
        a.game:GetService'Players',
    }
    local g, h, i, j, k, l = {
        f[1].LocalPlayer,
    }, a.game:GetService'GuiService', a.game:GetService'VirtualInputManager', a.game:GetService'RunService', {
        a.game:GetService'ReplicatedStorage',
    }, {
        {
            name_spoof = false,
            your_name = 'Player',
            enemy_name = 'Enemy',
            level_spoof = false,
            spoofed_level = 999,
            winstreak_spoof = false,
            spoofed_winstreak = 50,
        },
    }
    local m, n = {
        function(...)
            return d.apply_name_spoof({l, g}, ...)
        end,
    }, {
        function(...)
            return d.apply_level_streak_spoof({g, l}, ...)
        end,
    }

    for o, p in ipairs(f[1]:GetPlayers())do
        m[1](p)
    end

    f[1].PlayerAdded:Connect(m[1])
    a.task.spawn(function()
        return d.spoof_worker{
            l,
            f,
            m,
            n,
        }
    end)

    local o = aa[1][1].Misc:Section('name spoofer', 1)

    o:Toggle('name spoof', false, function(...)
        return d.set_name_spoof({l}, ...)
    end)
    o:Input('your name', 'Player', 'name...', function(...)
        return d.p306({l}, ...)
    end)
    o:Input('enemy name', 'Enemy', 'name...', function(...)
        return d.p307({l}, ...)
    end)
    o:Toggle('level spoof', false, function(...)
        return d.set_level_spoof({l}, ...)
    end)
    o:Slider('spoofed level', 1, 9999, 999, 0, function(...)
        return d.p309({l}, ...)
    end)
    o:Toggle('winstreak spoof', false, function(...)
        return d.set_winstreak_spoof({l}, ...)
    end)
    o:Slider('spoofed streak', 0, 9999, 50, 0, function(...)
        return d.p311({l}, ...)
    end)

    local p, q, r, s = {false}, {
        '1v1',
    }, {{}}, {false}
    local t, u = function(...)
        return d.scan_auto_queue({r, k}, ...)
    end, {
        function(...)
            return d.join_auto_queue({
                r,
                q,
                g,
                k,
            }, ...)
        end,
    }
    local v, w = t(), aa[1][1].Misc:Section('auto queue', 2)

    w:Toggle('auto queue', false, function(...)
        return d.leave_queue_worker({
            p,
            s,
            u,
            k,
        }, ...)
    end)
    w:Dropdown('queue mode', v, v[1] or '1v1', function(...)
        return d.p319({q, p, u}, ...)
    end)

    local x, y = {false}, {
        {
            'Assault Rifle',
            'Handgun',
            'Knife',
        },
    }

    a.task.spawn(function()
        return d.auto_loadout_worker{x, k, y}
    end)

    local z = aa[1][1].Misc:Section('auto loadout', 1)

    z:Toggle('auto loadout', false, function(...)
        return d.p324({x}, ...)
    end)
    z:Input('primary', 'Assault Rifle', 'weapon...', function(...)
        return d.p325({y}, ...)
    end)
    z:Input('secondary', 'Handgun', 'weapon...', function(...)
        return d.p326({y}, ...)
    end)
    z:Input('melee', 'Knife', 'weapon...', function(...)
        return d.p327({y}, ...)
    end)
    a.pcall(function()
        return d.p328{}
    end)

    local A = a.getgenv()
    local B, C, D = {
        A._VantaSkinLists or {},
    }, {
        A._VantaWrapList or {
            'None',
        },
    }, {
        A._VantaSkinEq or {},
    }

    A._VantaSkinEq = D[1]

    for E in pairs(B[1])do
        D[1][E] = D[1][E] or {
            Skin = 'Default',
            Wrap = 'None',
        }
    end

    a.pcall(function()
        return d.load_skin_config{e, D}
    end)

    local E, F, G, H = {false}, {false}, {nil}, {nil}
    local I, J, K, L = {
        function(...)
            return d.p331({
                k,
                g,
                E,
                D,
            }, ...)
        end,
    }, {
        function(...)
            return d.p338({
                F,
                k,
                g,
                e,
                H,
            }, ...)
        end,
    }, {
        function(...)
            return d.build_skin_changer_ui({
                G,
                g,
                aa[2],
                C,
                B,
                D,
                e,
                k,
            }, ...)
        end,
    }, aa[1][1].Visuals:Section('skin changer', 2)

    L:Toggle('enable skins', false, function(...)
        return d.p379({E, I}, ...)
    end)
    L:Toggle('show skin ui', false, function(...)
        return d.p380({
            E,
            I,
            K,
            G,
        }, ...)
    end)
    L:Toggle('unlock all skins', false, function(...)
        return d.p381({F, J}, ...)
    end)
    L:Label'skins/wraps ui + unlock (no external links)'
end
d.p295 = function(aa, e)
    aa[1][1] = e

    return
end
d.p294 = function(aa, ...)
    local e = a.cloneref(a.game:GetService'Players')
    local f = a.require(e.LocalPlayer.PlayerScripts.Controllers.CameraController)
    local g = f.CameraState

    if aa[1][1] then
        g:_SetPOVState(g.States.ThirdPersonMirrored)

        return
    end

    local h = g.States.FirstPerson or g.States.FirstPersonMirrored or g.States.Default

    if h then
        g:_SetPOVState(h)
    end
end
d.p293 = function(aa, e)
    local f = {e}

    aa[1][1] = f[1]

    a.pcall(function(...)
        return d.p294({f}, ...)
    end)

    return
end
d.p292 = function(aa, e)
    aa[1][1] = e

    return
end
d.p291 = function(aa, e)
    aa[1][1] = e

    return
end
d.p290 = function(aa)
    aa[1][1].JumpPower = aa[2][1]
    aa[1][1].UseJumpPower = true

    return
end
d.p289 = function(aa)
    aa[1][1].WalkSpeed = aa[2][1]

    return
end
d.p288 = function(aa)
    local e, f = (aa[1][1](4))

    if (not (not e)) then
        f = aa[2][1].Character

        if (not aa[2][1].Character) then
        else
            local g = aa[2][1].Character:FindFirstChildOfClass'Humanoid'

            f = g
        end

        local g = {f}

        f = g

        if (not (not g[1])) then
            if (not aa[3][1]) then
            else
                a.pcall(function(...)
                    return d.p289({
                        f,
                        aa[4],
                    }, ...)
                end)
            end
            if (not aa[5][1]) then
            else
                a.pcall(function(...)
                    return d.p290({
                        f,
                        aa[6],
                    }, ...)
                end)
            end

            return
        else
            return
        end
    else
        return
    end
end
d.p287 = function(aa, e)
    aa[1][1] = e

    return
end
d.p286 = function(aa, e)
    aa[1][1] = e

    return
end
d.p285 = function(aa, e)
    aa[1][1] = e

    return
end
d.p284 = function(aa, e)
    aa[1][1] = e

    return
end
d.p283 = function(aa)
    aa[1][1]:AdjustSpeed(aa[2][1])

    return
end
d.p282 = function(aa, e)
    local f

    f = e

    local g = {f}

    aa[1][1] = g[1]
    f = g

    if (not aa[2][1]) then
    else
        a.pcall(function(...)
            return d.p283({
                aa[2],
                f,
            }, ...)
        end)
    end

    return
end
d.p281 = function(aa, e)
    local f, g

    f = e
    aa[1][1] = f

    local h = a.getgenv()

    h._VantaEmoteSelected = f
    g = aa[2][1]

    if (not aa[2][1]) then
    else
        g = aa[3][1].Character
    end
    if (not g) then
    else
        aa[4][1](aa[3][1].Character)
    end

    return
end
d.p280 = function(aa, e)
    local f, g

    f = e
    aa[1][1] = f
    g = f

    if (not f) then
    else
        g = aa[2][1].Character
    end
    if (not g) then
        aa[4][1]()
    else
        aa[3][1](aa[2][1].Character)
    end

    return
end
d.p279 = function(aa, e)
    aa[1][1] = e

    return
end
d.p278 = function(aa, e)
    aa[1][1] = e

    return
end
d.p277 = function(aa, e)
    aa[1][1] = e

    return
end
d.p276 = function(aa, e)
    aa[1][1] = e

    return
end
d.p275 = function(aa, e)
    aa[1][1] = e

    return
end
d.p274 = function(aa, e)
    aa[1][1] = e

    return
end
d.p273 = function(aa)
    local e

    e = aa[1][1][aa[2][1] ]

    if (aa[1][1][aa[2][1] ]) then
    else
        e = aa[1][1]['rust hs']
    end

    aa[3][1].SoundId = e
    aa[3][1].Pitch = aa[4][1]
    aa[3][1].Volume = 0

    local f = a.Instance.new'Sound'

    f.SoundId = e
    f.Pitch = aa[4][1]
    f.Volume = aa[5][1]

    local g = a.game:GetService'SoundService'

    f.Parent = g

    f:Play()

    local h = a.game:GetService'Debris'

    h:AddItem(f, 4)

    return
end
d.p272 = function(aa, e)
    local f, g

    f = e

    local h = {f}

    f = h

    if (not (not aa[1][1])) then
        local i = f[1]:IsA'Sound'

        g = i

        if (not i) then
        else
            g = (f[1].SoundId ~= 'rbxassetid://16537449730')
        end
        if (not g) then
        else
            a.pcall(function(...)
                return d.p273({
                    aa[2],
                    aa[3],
                    f,
                    aa[4],
                    aa[5],
                }, ...)
            end)
        end

        return
    else
        return
    end
end
d.p271 = function(aa)
    aa[1][1].PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem.ClientViewModel.ChildAdded:Connect(function(...)
        return d.p272({
            aa[2],
            aa[3],
            aa[4],
            aa[5],
            aa[6],
        }, ...)
    end)

    return
end
d.p270 = function(aa, e)
    local f = a.math.clamp((e / 10), 0.1, 2)

    aa[1][1] = f

    return
end
d.p269 = function(aa, e)
    aa[1][1] = e

    return
end
d.p268 = function(aa, e)
    aa[1][1] = e

    return
end
d.p267 = function(aa, e)
    aa[1][1] = e

    return
end
d.p266 = function(aa)
    local e

    e = aa[1][1]

    if (not aa[1][1]) then
    else
        e = aa[1][1].CurrentData
    end
    if (not e) then
    else
        aa[1][1].CurrentData:Replicate'CosmeticInventory'
        aa[1][1].CurrentData:Replicate'WeaponInventory'
    end

    return
end
d.p265 = function(aa, e)
    aa[1][1] = e

    a.pcall(function(...)
        return d.p266({
            aa[2],
        }, ...)
    end)

    return
end
d.p264 = function(aa)
    a.restore_gc_attribute'ShootRecoil'

    return
end
d.p263 = function(aa, e)
    local f

    f = e
    aa[1][1] = f

    if (not (not f)) then
    else
        a.pcall(function(...)
            return d.p264({}, ...)
        end)

        aa[2][1] = false
    end

    return
end
d.p262 = function(aa, e)
    aa[1][1] = e

    return
end
d.p261 = function(aa, e)
    aa[1][1] = e

    return
end
d.p260 = function(aa, e)
    a.espWeaponEnabled = e
    a._G.espWeaponEnabled = e

    return
end
d.p259 = function(aa, e)
    a.espHealthEnabled = e
    a._G.espHealthEnabled = e

    return
end
d.p258 = function(aa, e)
    a.espNameEnabled = e
    a._G.espNameEnabled = e

    return
end
d.p257 = function(aa, e)
    a.espBoxEnabled = e
    a._G.espBoxEnabled = e

    return
end
d.p256 = function(aa, e)
    a.espEnabled = e
    a._G.espEnabled = e

    return
end
d.p255 = function(aa, e)
    local f

    f = e
    aa[1][1] = f

    if (not aa[2][1]) then
    else
        aa[3][1](f)
    end

    return
end
d.p254 = function(aa, e)
    aa[1][1] = e

    aa[2][1](aa[3][1])

    return
end
d.p253 = function(aa, e)
    aa[1][1] = e

    return
end
d.p252 = function(aa, e)
    local f, g

    f = e
    aa[1][1] = f

    local h = a.game:GetService'Lighting'

    g = h

    if (not f) then
        g.Brightness = 1
        g.ClockTime = 12
        g.GlobalShadows = true
    else
        g.Brightness = 2
        g.ClockTime = 14
        g.FogEnd = 100000
        g.GlobalShadows = false
    end

    return
end
d.p251 = function(aa, e)
    aa[1][1] = e

    return
end
d.p250 = function(aa, e)
    aa[1][1] = e

    return
end
d.p249 = function(aa, e)
    aa[1][1] = e

    return
end
d.p248 = function(aa, e)
    aa[1][1] = e

    return
end
d.p247 = function(aa, e)
    local f

    f = e
    aa[1][1] = f

    if (not f) then
        a.pcall(a.restore_reload)
    else
        a.pcall(a.enable_instant_reload)
    end

    return
end
d.p246 = function(aa)
    a.restore_gc_attribute'ShootCooldown'

    return
end
d.p245 = function(aa, e)
    local f

    f = e
    aa[1][1] = f

    if (not (not f)) then
    else
        a.pcall(function(...)
            return d.p246({}, ...)
        end)

        aa[2][1] = false
    end

    return
end
d.p244 = function(aa, e)
    aa[1][1] = e

    return
end
d.p243 = function(aa, e)
    aa[1][1] = e

    return
end
d.p242 = function(aa, e)
    aa[1][1] = e

    return
end
d.p241 = function(aa)
    aa[1][1](aa[2][1])

    return
end
d.p240 = function(aa, e)
    local f = {e}

    aa[1][1] = f[1]
    aa[2][1] = f[1]

    a.pcall(function(...)
        return d.p241({
            aa[3],
            f,
        }, ...)
    end)

    return
end
d.p239 = function(aa, e)
    aa[1][1] = e

    return
end
d.p238 = function(aa, e)
    aa[1][1] = e

    return
end
d.p237 = function(aa, e)
    aa[1][1] = e

    return
end
d.p236 = function(aa, e)
    aa[1][1] = e

    return
end
d.p235 = function(aa, e)
    aa[1][1] = e

    return
end
d.p234 = function(aa, e)
    aa[1][1] = e

    return
end
d.p233 = function(aa, e)
    aa[1][1] = e
    aa[2][1] = e

    return
end
d.p232 = function(aa, e)
    aa[1][1] = e

    return
end
d.p231 = function(aa, e)
    aa[1][1] = e

    return
end
d.p230 = function(aa, e)
    aa[1][1] = e

    return
end
d.p229 = function(aa, e)
    local f

    f = e
    aa[1][1] = f

    if (not (not f)) then
    else
        aa[2][1] = true
    end

    return
end
d.p228 = function(aa, e)
    local f

    f = e
    aa[1][1] = f

    if (not f) then
    else
        aa[2][1] = 5003
    end

    return
end
d.p227 = function(aa)
    aa[1][1](aa[2][1])

    return
end
d.p226 = function(aa, e)
    local f = {e}

    aa[1][1] = f[1]

    a.pcall(function(...)
        return d.p227({
            aa[2],
            f,
        }, ...)
    end)

    return
end
d.p225 = function(aa, e)
    aa[1][1] = e

    return
end
d.p224 = function(aa, e)
    local f, g, h, i, j

    f = e

    local k = aa[1][1]:FindFirstChild('MainFrame', true)

    g = k

    if (not k) then
    else
        g.ClipsDescendants = true

        local l = g:FindFirstChild'ContainerHolderFrame'

        h = l

        if (not l) then
        else
            h.ClipsDescendants = true

            local m = a.UDim2.new(1, (-18), 1, (-42))

            h.Size = m
        end

        local m = a.game:GetService'TweenService'

        i = m
        j = f

        if (not f) then
        else
            local n = a.UDim2.new(0, 525, 0, 300)

            j = n
        end
        if (j) then
        else
            local n = a.UDim2.new(0, 525, 0, 631)

            j = n
        end

        local n, o = a.TweenInfo.new(0.2, a.Enum.EasingStyle.Quad, a.Enum.EasingDirection.Out), {}

        o.Size = j

        local p = i:Create(g, n, o)

        p:Play()
    end

    return
end
d.p223 = function(aa, e)
    aa[1][1] = e

    return
end
d.p222 = function(aa, e)
    aa[1][1] = e

    return
end
d.p221 = function(aa, e)
    a.fovSpinSpeed = e

    return
end
d.p220 = function(aa, e)
    a.fovSpinEnabled = e

    a.pcall(a.applyFovColors)

    return
end
d.p219 = function(aa, e)
    local f = a.math.clamp((e / 100), 0, 1)

    a.aimbotFovFillAlpha = f

    a.pcall(a.applyFovColors)

    return
end
d.p218 = function(aa, e)
    local f, g

    f = e
    g = a.FOV_COLOR_PRESETS

    if (not a.FOV_COLOR_PRESETS) then
    else
        g = a.FOV_COLOR_PRESETS[f]
    end
    if (g) then
    else
        local h = a.Color3.fromRGB(255, 255, 255)

        g = h
    end

    a.aimbotFovFill = g

    a.pcall(a.applyFovColors)

    return
end
d.p217 = function(aa, e)
    local f, g

    f = e
    g = a.FOV_COLOR_PRESETS

    if (not a.FOV_COLOR_PRESETS) then
    else
        g = a.FOV_COLOR_PRESETS[f]
    end
    if (g) then
    else
        local h = a.Color3.fromRGB(255, 255, 255)

        g = h
    end

    a.aimbotFovColor = g

    a.pcall(a.applyFovColors)

    return
end
d.p216 = function(aa, e)
    aa[1][1] = e

    return
end
d.p215 = function(aa, e)
    aa[1][1] = e

    return
end
d.p214 = function(aa, e)
    aa[1][1] = e

    return
end
d.p213 = function(aa, e)
    aa[1][1] = e

    return
end
d.p212 = function(aa, e)
    aa[1][1] = e

    return
end
d.p211 = function(aa, e)
    aa[1][1] = e

    return
end
d.p210 = function(aa, e)
    local f = a.math.clamp((e / 100), 0, 1)

    a.silentFovFillAlpha = f

    a.pcall(a.applyFovColors)

    return
end
d.p209 = function(aa, e)
    local f, g

    f = e
    g = a.FOV_COLOR_PRESETS

    if (not a.FOV_COLOR_PRESETS) then
    else
        g = a.FOV_COLOR_PRESETS[f]
    end
    if (g) then
    else
        local h = a.Color3.fromRGB(255, 80, 80)

        g = h
    end

    a.silentFovFill = g

    a.pcall(a.applyFovColors)

    return
end
d.p208 = function(aa, e)
    local f, g

    f = e
    g = a.FOV_COLOR_PRESETS

    if (not a.FOV_COLOR_PRESETS) then
    else
        g = a.FOV_COLOR_PRESETS[f]
    end
    if (g) then
    else
        local h = a.Color3.fromRGB(255, 80, 80)

        g = h
    end

    a.silentFovColor = g

    a.pcall(a.applyFovColors)

    return
end
d.p207 = function(aa, e)
    aa[1][1] = e

    return
end
d.p206 = function(aa, e)
    aa[1][1] = e

    return
end
d.p205 = function(aa, e)
    aa[1][1] = e

    return
end
d.p204 = function(aa, e)
    aa[1][1] = e

    return
end
d.build_main_ui = function(aa)
    local e, f = aa[1][1].Combat:Section('silent aim', 2), aa[1][1].Combat:Section('aimbot', 1)

    e:Toggle('enabled', false, function(...)
        return d.p204({
            aa[2],
        }, ...)
    end)

    local g = {}

    g[1] = 'head'
    g[2] = 'humanoidrootpart'
    g[3] = 'torso'

    e:Dropdown('hitbox', g, 'head', function(...)
        return d.p205({
            aa[3],
        }, ...)
    end)
    e:Slider('fov radius', 10, 500, 300, 0, function(...)
        return d.p206({
            aa[4],
        }, ...)
    end)
    e:Toggle('draw fov', false, function(...)
        return d.p207({
            aa[5],
        }, ...)
    end)

    local h = {}

    h[1] = 'White'
    h[2] = 'Red'
    h[3] = 'Green'
    h[4] = 'Blue'
    h[5] = 'Cyan'
    h[6] = 'Purple'
    h[7] = 'Orange'
    h[8] = 'Yellow'
    h[9] = 'Pink'

    e:Dropdown('silent ring color', h, 'Red', function(...)
        return d.p208({}, ...)
    end)

    local i = {}

    i[1] = 'White'
    i[2] = 'Red'
    i[3] = 'Green'
    i[4] = 'Blue'
    i[5] = 'Cyan'
    i[6] = 'Purple'
    i[7] = 'Orange'
    i[8] = 'Yellow'
    i[9] = 'Pink'

    e:Dropdown('silent fill color', i, 'Red', function(...)
        return d.p209({}, ...)
    end)
    e:Slider('silent fill alpha', 0, 100, 85, 0, function(...)
        return d.p210({}, ...)
    end)
    e:Toggle('wallcheck', false, function(...)
        return d.p211({
            aa[6],
        }, ...)
    end)
    f:Toggle('aimbot enabled', false, function(...)
        return d.p212({
            aa[7],
        }, ...)
    end)

    local j = {}

    j[1] = 'head'
    j[2] = 'humanoidrootpart'
    j[3] = 'torso'

    f:Dropdown('hitbox', j, 'head', function(...)
        return d.p213({
            aa[8],
        }, ...)
    end)
    f:Slider('smoothness', 1, 20, 5, 1, function(...)
        return d.p214({
            aa[9],
        }, ...)
    end)
    f:Slider('fov radius', 10, 500, 100, 0, function(...)
        return d.p215({
            aa[10],
        }, ...)
    end)
    f:Toggle('draw fov', false, function(...)
        return d.p216({
            aa[11],
        }, ...)
    end)

    local k = {}

    k[1] = 'White'
    k[2] = 'Red'
    k[3] = 'Green'
    k[4] = 'Blue'
    k[5] = 'Cyan'
    k[6] = 'Purple'
    k[7] = 'Orange'
    k[8] = 'Yellow'
    k[9] = 'Pink'

    f:Dropdown('aimbot ring color', k, 'White', function(...)
        return d.p217({}, ...)
    end)

    local l = {}

    l[1] = 'White'
    l[2] = 'Red'
    l[3] = 'Green'
    l[4] = 'Blue'
    l[5] = 'Cyan'
    l[6] = 'Purple'
    l[7] = 'Orange'
    l[8] = 'Yellow'
    l[9] = 'Pink'

    f:Dropdown('aimbot fill color', l, 'White', function(...)
        return d.p218({}, ...)
    end)
    f:Slider('aimbot fill alpha', 0, 100, 85, 0, function(...)
        return d.p219({}, ...)
    end)
    f:Toggle('fov spin', false, function(...)
        return d.p220({}, ...)
    end)
    f:Slider('spin speed', 10, 360, 90, 0, function(...)
        return d.p221({}, ...)
    end)
    f:Toggle('wallcheck', false, function(...)
        return d.p222({
            aa[12],
        }, ...)
    end)
    f:Toggle('scope look', false, function(...)
        return d.p223({
            aa[13],
        }, ...)
    end)

    local m = aa[1][1].Combat:Section('mobile setting', 1)

    m:Toggle('mobile on', false, function(...)
        return d.p224({
            aa[14],
        }, ...)
    end)

    local n = aa[1][1].Combat:Section('pull enabled', 1)

    n:Toggle('pull', false, function(...)
        return d.p225({
            aa[15],
        }, ...)
    end)

    local o = aa[1][1].Combat:Section('ragebot', 1)

    o:Toggle('enabled', false, function(...)
        return d.p226({
            aa[16],
            aa[17],
        }, ...)
    end)
    o:Toggle('orbit', false, function(...)
        return d.p228({
            aa[18],
            aa[19],
        }, ...)
    end)
    o:Toggle('voidspam', false, function(...)
        return d.p229({
            aa[20],
            aa[21],
        }, ...)
    end)
    o:Slider('hide', 0.01, 1, 0.25, 2, function(...)
        return d.p230({
            aa[22],
        }, ...)
    end)
    o:Slider('attack', 0.01, 1, 0.1, 2, function(...)
        return d.p231({
            aa[23],
        }, ...)
    end)
    o:Slider('offset X', (-50), 50, 0, 1, function(...)
        return d.p232({
            aa[24],
        }, ...)
    end)
    o:Slider('offset Y', (-50), 50, 3, 1, function(...)
        return d.p233({
            aa[25],
            aa[26],
        }, ...)
    end)
    o:Slider('offset Z', (-50), 50, 0, 1, function(...)
        return d.p234({
            aa[27],
        }, ...)
    end)
    o:Slider('max range', 50, 2000, 500, 0, function(...)
        return d.p235({
            aa[28],
        }, ...)
    end)
    o:Slider('predict', 0, 0.5, 0, 2, function(...)
        return d.p236({
            aa[29],
        }, ...)
    end)
    o:Toggle('head only', true, function(...)
        return d.p237({
            aa[30],
        }, ...)
    end)

    local p = {}

    p[1] = 'closest'
    p[2] = 'lowest_hp'

    o:Dropdown('priority', p, 'closest', function(...)
        return d.p238({
            aa[31],
        }, ...)
    end)

    local q = aa[1][1].Combat:Section('ffamods', 2)

    q:Toggle('team check', true, function(...)
        return d.p239({
            aa[32],
        }, ...)
    end)
    q:Toggle('baiting', false, function(...)
        return d.p240({
            aa[33],
            aa[34],
            aa[35],
        }, ...)
    end)

    local r = aa[1][1].Combat:Section('triggerbot', 2)

    r:Toggle('enabled', false, function(...)
        return d.p242({
            aa[36],
        }, ...)
    end)

    local s = aa[1][1].Combat:Section('weapons', 2)

    s:Toggle('no spread', false, function(...)
        return d.p243({
            aa[37],
        }, ...)
    end)
    s:Toggle('no muzzle flash', false, function(...)
        return d.p244({
            aa[38],
        }, ...)
    end)
    s:Toggle('attack cooldown', false, function(...)
        return d.p245({
            aa[39],
            aa[40],
        }, ...)
    end)
    s:Toggle('projectile cooldown', false, function(...)
        return d.p247({
            aa[41],
        }, ...)
    end)

    local t = aa[1][1].Combat:Section('orb,void', 2)

    t:Toggle('orbit', false, function(...)
        return d.p248({
            aa[18],
        }, ...)
    end)
    t:Slider('orbit studs', 5, 10000, 50000000, 0, function(...)
        return d.p249({
            aa[19],
        }, ...)
    end)
    t:Toggle('void spam', false, function(...)
        return d.p250({
            aa[34],
        }, ...)
    end)
    t:Slider('void spam studs', 50, 50000000, 50, 0, function(...)
        return d.p251({
            aa[42],
        }, ...)
    end)

    local u = aa[1][1].Visuals:Section('environment', 1)

    u:Toggle('Fullbright', false, function(...)
        return d.p252({
            aa[43],
        }, ...)
    end)
    u:Toggle('shader', false, function(...)
        return d.p253({
            aa[44],
        }, ...)
    end)

    local v = aa[1][1].Visuals:Section('skybox', 2)

    v:Toggle('skyboxs', false, function(...)
        return d.p254({
            aa[45],
            aa[46],
            aa[47],
        }, ...)
    end)

    local w = {}

    w[1] = 'Dark Sky'
    w[2] = 'Vaporwave'
    w[3] = 'Lake Sky'
    w[4] = 'Black Mesa'
    w[5] = 'Space'
    w[6] = 'Night'
    w[7] = 'Sunset'
    w[8] = 'Cloudy'

    v:Dropdown('Select Skybox', w, 'Dark Sky', function(...)
        return d.p255({
            aa[47],
            aa[45],
            aa[46],
        }, ...)
    end)

    local x = aa[1][1].Visuals:Section('visual esp', 1)

    x:Toggle('ESP Active', false, function(...)
        return d.p256({}, ...)
    end)
    x:Toggle('Box Display', true, function(...)
        return d.p257({}, ...)
    end)
    x:Toggle('Name Display', true, function(...)
        return d.p258({}, ...)
    end)
    x:Toggle('Health Display', true, function(...)
        return d.p259({}, ...)
    end)
    x:Toggle('weapon info', true, function(...)
        return d.p260({}, ...)
    end)

    local y = aa[1][1].Visuals:Section('indicators', 1)

    y:Toggle('ragebot', false, function(...)
        return d.p261({
            aa[48],
        }, ...)
    end)
    y:Toggle('ammo', false, function(...)
        return d.p262({
            aa[49],
        }, ...)
    end)

    local z = aa[1][1].Visuals:Section('viewmodel cosmetics', 1)

    z:Toggle('no recoil', false, function(...)
        return d.p263({
            aa[50],
            aa[51],
        }, ...)
    end)
    z:Toggle('unlock all', false, function(...)
        return d.p265({
            aa[52],
            aa[53],
        }, ...)
    end)

    local A, B, C, D, E = {false}, {
        'rust hs',
    }, {1}, {1}, {}

    E['rust hs'] = 'rbxassetid://4764109000'
    E.neverlose = 'rbxassetid://97643101798871'
    E.sparkle = 'rbxassetid://110241936966089'
    E['minecraft hit'] = 'rbxassetid://8766809464'
    E.bonk = 'rbxassetid://5766898159'
    E.osu = 'rbxassetid://7149255551'
    E['among us'] = 'rbxassetid://5700183626'
    E.bruh = 'rbxassetid://4578740568'
    E.vine = 'rbxassetid://5332680810'
    E.gamesense = 'rbxassetid://4817809188'
    E['\u{c7a5}\u{cda9}\u{b3d9} \u{c655}\u{c871}\u{bc1c} \u{bcf4}\u{c308}'] = 'rbxassetid://85775332966635'

    local F, G = {E}, {}

    G[1] = 'rust hs'
    G[2] = 'neverlose'
    G[3] = 'sparkle'
    G[4] = 'minecraft hit'
    G[5] = 'bonk'
    G[6] = 'osu'
    G[7] = 'among us'
    G[8] = 'bruh'
    G[9] = 'vine'
    G[10] = 'gamesense'
    G[11] = '\u{c7a5}\u{cda9}\u{b3d9} \u{c655}\u{c871}\u{bc1c} \u{bcf4}\u{c308}'

    local H = aa[1][1].Visuals:Section('hit sounds', 2)

    H:Toggle('enable hit sound', false, function(...)
        return d.p267({A}, ...)
    end)
    H:Dropdown('hit sound style', G, 'rust hs', function(...)
        return d.p268({B}, ...)
    end)
    H:Slider('volume', 0, 2, 1, 1, function(...)
        return d.p269({C}, ...)
    end)
    H:Slider('pitch (speed)', 1, 20, 10, 1, function(...)
        return d.p270({D}, ...)
    end)
    a.pcall(function(...)
        return d.p271({
            aa[54],
            A,
            F,
            B,
            D,
            C,
        }, ...)
    end)

    local I = aa[1][1].Misc:Section('movement', 1)

    I:Toggle('Mobile Fly', false, function(...)
        return d.p274({
            aa[55],
        }, ...)
    end)
    I:Slider('Mobile Fly Speed', 1, 3000, 50, 0, function(...)
        return d.p275({
            aa[56],
        }, ...)
    end)
    I:Toggle('PC Fly', false, function(...)
        return d.p276({
            aa[57],
        }, ...)
    end)
    I:Slider('PC Fly Speed', 1, 10000, 50, 0, function(...)
        return d.p277({
            aa[58],
        }, ...)
    end)
    I:Toggle('Noclip Active', false, function(...)
        return d.p278({
            aa[59],
        }, ...)
    end)

    local J = {}

    J[1] = 'all walls'
    J[2] = 'phong'

    I:Dropdown('Noclip Mode', J, 'all walls', function(...)
        return d.p279({
            aa[60],
        }, ...)
    end)

    local K = aa[1][1].Misc:Section('emote hop', 2)

    K:Toggle('Emote Hop', false, function(...)
        return d.p280({
            aa[61],
            aa[54],
            aa[62],
            aa[63],
        }, ...)
    end)

    local L = {}

    L[1] = 'Bodybuilder'
    L[2] = 'Crawling in a Circle'
    L[3] = 'Dolphin Dance'
    L[4] = 'Dance'
    L[5] = 'Dance Break'
    L[6] = 'French Confidence'
    L[7] = 'Floss'
    L[8] = 'Frosty Flair'
    L[9] = 'Full Wiggle'
    L[10] = 'Ghost Floating'
    L[11] = 'Gun'
    L[12] = 'Gangnam Style'
    L[13] = 'Hip Bounce'
    L[14] = 'Hype Dance'
    L[15] = 'Kicking Feet'
    L[16] = 'Line Dance'
    L[17] = 'Lay Floating'
    L[18] = "Let's Drive"
    L[19] = 'Long Legs'
    L[20] = 'Rock Out'
    L[21] = 'Samba'
    L[22] = 'Still Standing'
    L[23] = 'Spiral'
    L[24] = 'Solar System'
    L[25] = 'Twirl'
    L[26] = 'Take Me Under'
    L[27] = 'The Worm'
    L[28] = 'Take the L'
    L[29] = 'Zesty'

    K:Dropdown('emote', L, 'Dance', function(...)
        return d.p281({
            aa[64],
            aa[61],
            aa[54],
            aa[62],
        }, ...)
    end)
    K:Slider('Emote Speed', 1, 10000, 40, 0, function(...)
        return d.p282({
            aa[65],
            aa[66],
        }, ...)
    end)

    local M, N, O, P, Q = aa[1][1].Misc:Section('movement', 2), {false}, {false}, {16}, {50}

    M:Toggle('walkspeed', false, function(...)
        return d.p284({N}, ...)
    end)
    M:Slider('speed', 16, 200, 16, 0, function(...)
        return d.p285({P}, ...)
    end)
    M:Toggle('jumppower', false, function(...)
        return d.p286({O}, ...)
    end)
    M:Slider('jump', 50, 300, 50, 0, function(...)
        return d.p287({Q}, ...)
    end)
    aa[67][1].Heartbeat:Connect(function(...)
        return d.p288({
            aa[68],
            aa[54],
            N,
            P,
            O,
            Q,
        }, ...)
    end)

    local R = aa[1][1].Misc:Section('device spoofer', 2)

    R:Toggle('device spoofer', false, function(...)
        return d.p291({
            aa[69],
        }, ...)
    end)

    local S = {}

    S[1] = 'vr'
    S[2] = 'touch'
    S[3] = 'gamepad'
    S[4] = 'mousekeyboard'

    R:Dropdown('device selection', S, 'vr', function(...)
        return d.p292({
            aa[70],
        }, ...)
    end)

    local T = aa[1][1].Misc:Section('third person', 2)

    T:Toggle('enabled', false, function(...)
        return d.p293({
            aa[71],
        }, ...)
    end)

    local U = aa[1][1].Misc:Section('arcade servers', 2)

    U:Toggle('automatically grab drops', false, function(...)
        return d.p295({
            aa[72],
        }, ...)
    end)

    return
end
d.p202 = function(aa)
    local e, f, g = (a.tostring(aa[1][1].Name))
    local h = e:find'nexlib'

    f = e
    g = h

    if (h) then
    else
        local i = f:find'Vanta'

        g = i
    end
    if (g) then
    else
        local i = f:find'Halmu'

        g = i
    end
    if (g) then
    else
        local i = f:find'ExecutorToggle'

        g = i
    end
    if (g) then
    else
        local i = f:find'NexSkin'

        g = i
    end
    if (not g) then
    else
        aa[1][1]:Destroy()
    end

    return
end
d.p201 = function(aa)
    if (not a.gethui) then
    else
        local e = a.gethui()

        aa[1][1][(#aa[1][1] + 1)] = e
    end

    return
end
d.wallbang_cleanup = function(aa)
    local e = a.getgenv()

    e.VantaSC_Running = nil
    e.VantaSC_Window = nil

    if e.RIVALS_WALLBANG then
        e.RIVALS_WALLBANG.Enabled = false
    end

    local f = {
        a.game:GetService'CoreGui',
    }

    a.pcall(function()
        if a.gethui then
            f[#f + 1] = a.gethui()
        end
    end)

    for g, h in ipairs(f)do
        if h then
            for i, j in ipairs(h:GetChildren())do
                local k = {j}

                a.pcall(function()
                    return d.p202{k}
                end)
            end
        end
    end
end
d.unload_script = function(aa)
    a.pcall(function(...)
        return d.wallbang_cleanup({}, ...)
    end)

    return
end
d.p198 = function(aa)
    local e, f, g = (a.game:GetService'CoreGui')
    local h = e:FindFirstChild'nexlib'

    f = h
    g = h

    if (not h) then
    else
        local i = f:FindFirstChild'CustomCursorGui'

        g = i
    end
    if (not g) then
    else
        g.Enabled = aa[1][1]
    end

    return
end
d.toggle_custom_cursor = function(aa, e)
    local f = {e}

    a.pcall(function(...)
        return d.p198({f}, ...)
    end)

    return
end
d.p196 = function(aa, e, f)
    aa[1][1] = f

    return aa[2][1](e, f)
end
d.fetch_profile_page = function(aa)
    local e, f, g = (a.require(aa[1][1].PlayerScripts.Modules.Pages.ViewProfile))

    f = e
    g = e

    if (not e) then
    else
        g = f.Fetch
    end
    if (not g) then
    else
        local h = {
            f.Fetch,
        }

        f.Fetch = function(...)
            return d.p196({
                aa[2],
                h,
            }, ...)
        end
    end

    return
end
d.p194 = function(aa, e)
    local f = aa[1][1](e)

    for g, h in pairs(aa[2][1].Cosmetics)do
        if h then
            local i = g:lower()

            if h.Type == 'Dance' or h.Type == 'Emote' or i:find('dance', 1, true) or i:find('emote', 1, true) then
                if not f[g] then
                    f[g] = {
                        Name = g,
                        Type = h.Type,
                        ObjectID = h.ObjectID,
                        Enum = h.Enum,
                    }
                end
            end
        end
    end

    return f
end
d.get_emotes = function(aa)
    local e = a.require(aa[1][1]:WaitForChild('EmoteController', 10))

    aa[2][1] = e

    if e and e.GetEmotes then
        local f = {
            e.GetEmotes,
        }

        e.GetEmotes = function(...)
            return d.p194({
                f,
                aa[3],
            }, ...)
        end
    end
end
d.resolve_skin_image = function(aa, e, f, g)
    local h, i, j, k, l, m, n, o, p

    h = e
    i = f
    j = g

    if (not (not i)) then
        k = i.Name
        l = i.Skin

        if (not i.Skin) then
        else
            l = aa[1][1][k]
        end
        if (not l) then
        else
            l = (i.Skin == aa[1][1][k].Skin)
        end
        if (l) then
        else
            l = (aa[2][1] == aa[3][1])

            if (not (aa[2][1] == aa[3][1])) then
            else
                l = aa[1][1][k]
            end
            if (not l) then
            else
                l = aa[1][1][k].Skin
            end
        end

        m = l

        if (not l) then
        else
            m = aa[1][1][k]
        end
        if (not m) then
        else
            m = aa[1][1][k].Skin
        end
        if (not m) then
        else
            m = h.ViewModels[aa[1][1][k].Skin.Name]

            if (not h.ViewModels[aa[1][1][k].Skin.Name]) then
                return nil
            else
                o = m
                p = j

                if (not j) then
                else
                    p = 'ImageHighResolution'
                end
                if (p) then
                else
                    p = 'Image'
                end

                n = o[p]

                if (o[p]) then
                else
                    n = m.Image
                end

                return n
            end
        end

        return nil
    else
        return nil
    end
end
d.p191 = function(aa)
    if (not (not aa[1][1]._destroyed)) then
    else
        aa[1][1]:_UpdateWrap()
    end

    return
end
d.refresh_client_fighter_cosmetics = function(aa, e, f)
    local g, h, i, j, k, l, m, n, o

    g = e
    h = f
    i = h.ClientFighter

    if (not h.ClientFighter) then
    else
        i = h.ClientFighter.Player
    end

    j = aa[1][1]

    if (aa[1][1]) then
    else
        j = h.Name
    end

    k = (i == aa[2][1])

    if (not (i == aa[2][1])) then
    else
        k = aa[3][1][j]
    end
    if (not k) then
    else
        local p = a.require(aa[4][1].Modules.ReplicatedClass)
        local q = p:ToEnum'Data'

        k = p
        l = q
        m = g
        n = q
        o = g[q]

        if (g[q]) then
        else
            local r = {}

            o = r
        end

        m[n] = o
        m = aa[3][1][j]

        if (not aa[3][1][j].Skin) then
        else
            local r = k:ToEnum'Skin'

            g[l][r] = m.Skin
        end
        if (not m.Charm) then
        else
            local r = k:ToEnum'Charm'

            g[l][r] = m.Charm
        end
        if (not m.Wrap) then
        else
            local r = k:ToEnum'Wrap'

            g[l][r] = m.Wrap
        end
    end

    local p = aa[5][1](g, h)
    local q = {p}

    k = q
    l = (i == aa[2][1])

    if (not (i == aa[2][1])) then
    else
        l = aa[3][1][j]
    end
    if (not l) then
    else
        l = aa[3][1][j].Wrap
    end
    if (not l) then
    else
        l = k[1]._UpdateWrap
    end
    if (not l) then
    else
        k[1]:_UpdateWrap()
        a.task.delay(0.1, function(...)
            return d.p191({k}, ...)
        end)
    end

    return k[1]
end
d.apply_item_wrap = function(aa, e)
    local f = e.ClientItem
    local g, h = f and f.Name, f and f.ClientFighter and f.ClientFighter.Player

    if g and h == aa[1][1] then
        local i = aa[2][1][g]

        if i and i.Wrap then
            return i.Wrap
        end
    end

    return aa[3][1](e)
end
d.apply_item_charm = function(aa, e)
    local f = e.ClientItem
    local g, h = f and f.Name, f and f.ClientFighter and f.ClientFighter.Player

    if g and h == aa[1][1] then
        local i = aa[2][1][g]

        if i and i.Charm then
            return i.Charm
        end
    end

    return aa[3][1](e)
end
d.apply_item_skin = function(aa, e, f)
    local g, h, i, j, k, l, m, n

    g = e
    h = f
    i = g.Name
    j = g.ClientFighter

    if (not g.ClientFighter) then
    else
        j = g.ClientFighter.Player
    end

    k = (j == aa[1][1])

    if (not (j == aa[1][1])) then
    else
        k = i
    end
    if (k) then
    else
        k = nil
    end

    aa[2][1] = k
    k = (j == aa[1][1])

    if (not (j == aa[1][1])) then
    else
        k = aa[3][1][i]
    end
    if (not k) then
    else
        k = h
    end
    if (not k) then
    else
        local o = g:ToEnum'Data'

        l = h[o]

        if (h[o]) then
        else
            l = h.Data
        end
        if (not l) then
        else
            if (not aa[3][1][i].Skin) then
            else
                local p = g:ToEnum'Skin'

                m = l
                n = p

                if (p) then
                else
                    n = 'Skin'
                end

                m[n] = aa[3][1][i].Skin

                local q = g:ToEnum'Name'

                m = l
                n = q

                if (q) then
                else
                    n = 'Name'
                end

                m[n] = aa[3][1][i].Skin.Name
            end
            if (not aa[3][1][i].Charm) then
            else
                local p = g:ToEnum'Charm'

                m = l
                n = p

                if (p) then
                else
                    n = 'Charm'
                end

                m[n] = aa[3][1][i].Charm
            end
            if (not aa[3][1][i].Wrap) then
            else
                local p = g:ToEnum'Wrap'

                m = l
                n = p

                if (p) then
                else
                    n = 'Wrap'
                end

                m[n] = aa[3][1][i].Wrap
            end
        end
    end

    local o = aa[4][1](g, h)

    aa[2][1] = nil

    return o
end
d.load_client_item_classes = function(aa)
    local e = a.require(aa[1][1].PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem)

    aa[2][1] = e

    return
end
d.p185 = function(aa)
    aa[1][1].CurrentData:Replicate'FavoritedCosmetics'

    return
end
d.p184 = function(aa)
    a.pcall(function(...)
        return d.p185({
            aa[1],
        }, ...)
    end)

    return
end
d.p183 = function(aa)
    aa[1][1].CurrentData:Replicate'WeaponInventory'

    return
end
d.p182 = function(aa)
    a.pcall(function(...)
        return d.p183({
            aa[1],
        }, ...)
    end)
    a.task.wait(0.1)
    aa[2][1]()

    return
end
d.p181 = function(aa)
    aa[1][1].CurrentData:Replicate'CosmeticInventory'

    return
end
d.p180 = function(aa)
    a.pcall(function(...)
        return d.p181({
            aa[1],
        }, ...)
    end)
    a.task.wait(0.1)
    aa[2][1]()

    return
end
d.p179 = function(aa)
    local e = aa[1][1]
    local f = e:GetFighter(aa[2][1])

    if not f or not f.Items then
        return
    end

    for g, h in pairs(f.Items)do
        if h:Get'ObjectID' == aa[3][1] then
            aa[4][1] = h.Name

            break
        end
    end
end
d.cosmetic_namecall_hook = function(aa, e, ...)
    if a.getnamecallmethod() ~= 'FireServer' then
        return aa[1][1](e, ...)
    end

    local f = pack(...)

    if aa[2][1] and e == aa[2][1] then
        local g = {
            f[1],
        }

        if aa[3][1] then
            a.pcall(function()
                d.p179{
                    aa[3],
                    aa[4],
                    g,
                    aa[5],
                }
            end)
        end
    end
    if e == aa[6][1] then
        local g, h, i, j = f[1], f[2], f[3], f[4] or {}

        if i and i ~= 'None' and i ~= '' then
            local k = aa[7][1](aa[8][1], 'CosmeticInventory')

            if k and a.rawget(k, i) then
                return aa[1][1](e, ...)
            end
        end

        local k = i and i:lower() or ''
        local l = h == 'Dance' or h == 'Emote' or k:find('dance', 1, true) or k:find('emote', 1, true)

        if l then
            aa[9][1].Dances = aa[9][1].Dances or {}

            if not i or i == 'None' or i == '' then
                aa[9][1].Dances[h] = nil
            else
                local m = aa[10][1](i, h, {
                    inverted = j.IsInverted,
                    favoritesOnly = j.OnlyUseFavorites,
                })

                if m then
                    aa[9][1].Dances[h] = m
                end
            end

            a.task.defer(function()
                d.p180{
                    aa[8],
                    aa[11],
                }
            end)

            return
        end

        aa[9][1][g] = aa[9][1][g] or {}

        if not i or i == 'None' or i == '' then
            aa[9][1][g][h] = nil

            if not a.next(aa[9][1][g]) then
                aa[9][1][g] = nil
            end
        else
            local m = aa[10][1](i, h, {
                inverted = j.IsInverted,
                favoritesOnly = j.OnlyUseFavorites,
            })

            if m then
                aa[9][1][g][h] = m
            end
        end

        a.task.defer(function()
            d.p182{
                aa[8],
                aa[11],
            }
        end)

        return
    end
    if e == aa[12][1] then
        local g, h, i = f[1], f[2], f[3]

        if aa[13][1].Cosmetics[h] then
            aa[14][1][g] = aa[14][1][g] or {}
            aa[14][1][g][h] = i or nil

            aa[11][1]()
            a.task.spawn(function()
                d.p184{
                    aa[8],
                }
            end)
        end

        return
    end

    return aa[1][1](e, ...)
end
d.load_fighter_controller = function(aa)
    local e = a.require(aa[1][1]:WaitForChild('FighterController', 10))

    aa[2][1] = e

    return
end
d.index_cosmetics_by_name = function(aa, e, f)
    local g = aa[1][1](e, f)

    if not g then
        return nil
    end

    local h = {}

    for i, j in pairs(g)do
        h[i] = j
    end

    h.Name = f

    local i = aa[2][1][f]

    if i then
        for j, k in pairs(i)do
            h[j] = k
        end
    end

    return h
end
d.p175 = function(aa, e, f)
    local g, h

    g = e
    h = f

    if (not aa[1][1].Cosmetics[h]) then
        return nil
    else
        return true
    end
end
d.build_cosmetic_inventory = function(aa, e, f)
    local g = aa[1][1](e, f)

    if not aa[2][1] then
        return g
    end
    if f == 'CosmeticInventory' then
        local h = {}

        if g then
            for i, j in pairs(g)do
                if aa[3][1].Cosmetics[i] then
                    h[i] = j
                end
            end
        end

        return a.setmetatable(h, {
            _5087x733 = function(...)
                return d.p175({
                    aa[3],
                }, ...)
            end,
        })
    end
    if f == 'FavoritedCosmetics' then
        local h = g and a.table.clone(g) or {}

        for i, j in pairs(aa[4][1])do
            h[i] = h[i] or {}

            for k, l in pairs(j)do
                h[i][k] = l
            end
        end

        return h
    end

    return g
end
d.p173 = function(aa, e, f, g, h)
    local i, j, k, l, m, n

    i = e
    j = f
    k = g
    l = h

    if (not (not aa[1][1])) then
        m = aa[2][1].Cosmetics[k]
        n = aa[2][1].Cosmetics[k]

        if (not aa[2][1].Cosmetics[k]) then
        else
            n = (m.Type == 'Skin')
        end
        if (not n) then
            return false
        else
            return true
        end
    else
        return false
    end
end
d.p172 = function(aa, e, f, g, h)
    local i, j, k, l, m, n

    i = e
    j = f
    k = g
    l = h

    if (not (not aa[1][1])) then
        m = aa[2][1].Cosmetics[k]
        n = aa[2][1].Cosmetics[k]

        if (not aa[2][1].Cosmetics[k]) then
        else
            n = (m.Type == 'Skin')
        end
        if (not n) then
            return false
        else
            return true
        end
    else
        return false
    end
end
d.p171 = function(aa, e, f, g, h)
    local i, j, k, l, m, n

    i = e
    j = f
    k = g
    l = h

    if (not (not aa[1][1])) then
        m = aa[2][1].Cosmetics[k]
        n = aa[2][1].Cosmetics[k]

        if (not aa[2][1].Cosmetics[k]) then
        else
            n = (m.Type == 'Skin')
        end
        if (not n) then
            return false
        else
            return true
        end
    else
        return false
    end
end
d.normalize_cosmetic_type = function(aa, e, f, g, h)
    local i = aa[2][1]

    if not aa[1][1] or g:find'MISSING_' then
        return i(e, f, g, h)
    end

    local j = aa[3][1].Cosmetics[g]

    if j then
        local k, l = j.Type, g:lower()

        if k == 'Skin' or k == 'Charm' or k == 'Dance' or k == 'Emote' or k == 'Wrap' or k == 'Wrapping' or l:find('charm', 1, true) or l:find('dance', 1, true) or l:find('emote', 1, true) or l:find('wrap', 1, true) then
            return true
        end
    end

    return i(e, f, g, h)
end
d.p169 = function(aa)
    local e = aa[1][1]:JSONDecode(a.readfile(aa[2][1]))

    if e.equipped then
        for f, g in pairs(e.equipped)do
            aa[3][1][f] = {}

            for h, i in pairs(g)do
                local j = aa[4][1](i.name, h, {
                    inverted = i.inverted,
                })

                if j then
                    j.Seed = i.seed
                    aa[3][1][f][h] = j
                end
            end
        end
    end

    aa[5][1] = e.favorites or {}
end
d.load_cosmetic_state = function(aa)
    local e

    e = (not a.readfile)

    if ((not a.readfile)) then
    else
        e = (not a.isfile)
    end
    if (e) then
    else
        local f = a.isfile(aa[1][1])

        e = (not f)
    end
    if (not e) then
        a.pcall(function(...)
            return d.p169({
                aa[2],
                aa[1],
                aa[3],
                aa[4],
                aa[5],
            }, ...)
        end)

        return
    else
        return
    end
end
d.p167 = function(aa, ...)
    local e = {
        equipped = {},
        favorites = aa[1][1],
    }

    for f, g in a.pairs(aa[2][1])do
        local h = {}

        e.equipped[f] = h

        for i, j in a.pairs(g)do
            if j and j.Name then
                h[i] = {
                    name = j.Name,
                    seed = j.Seed,
                    inverted = j.Inverted,
                }
            end
        end
    end

    a.makefolder'unlockall'
    a.writefile(aa[3][1], aa[4][1]:JSONEncode(e))
end
d.save_cosmetic_state = function(aa)
    if (not (not a.writefile)) then
        a.pcall(function(...)
            return d.p167({
                aa[1],
                aa[2],
                aa[3],
                aa[4],
            }, ...)
        end)

        return
    else
        return
    end
end
d.build_cosmetic_state = function(aa, e, f, g)
    local h = aa[1][1].Cosmetics[e]

    if not h then
        return nil
    end

    local i = {}

    for j, k in pairs(h)do
        i[j] = k
    end

    i.Name = e
    i.Type = i.Type or f
    i.Seed = i.Seed or a.math.random(1, 1000000)

    local j = aa[2][1]

    if j then
        local k, l = a.pcall(j.ToEnum, j, e)

        if k and l then
            i.Enum = l
            i.ObjectID = i.ObjectID or l
        end
    end
    if g then
        if g.inverted ~= nil then
            i.Inverted = g.inverted
        end
        if g.favoritesOnly ~= nil then
            i.OnlyUseFavorites = g.favoritesOnly
        end
    end

    return i
end
d.p164 = function(aa, e)
    return
end
d.p163 = function(aa)
    aa[1][1]:FireServer(aa[2][1], aa[3][1], aa[4][1], nil)

    return
end
d.p162 = function(aa)
    if not aa[1][1] or not aa[2][1] then
        return
    end

    local e = aa[3][1]
    local f = e.Character
    local g = f and f:FindFirstChild'HumanoidRootPart'

    if not g then
        return
    end

    local h = aa[4][1]()

    if h then
        aa[5][1] = h
    else
        h = aa[5][1]
    end
    if not h then
        return
    end

    for i, j in ipairs(aa[6][1]:GetPlayers())do
        if j ~= e and not aa[7][1](j) and not aa[8][1](j) then
            local k = j.Character

            if k then
                local l, m = k:FindFirstChildWhichIsA'Humanoid', k:FindFirstChild'Head'

                if l and l.Health > 0 and m then
                    local n = m.Position - a.Vector3.new(0, 5, 0)
                    local o = aa[9][1](n, m)

                    a.pcall(function()
                        aa[10][1]:FireServer(h, aa[11][1], o, nil)
                    end)
                end
            end
        end
    end
end
d.p161 = function(aa, e, f)
    local g = a.CFrame.lookAt(e, f.Position)
    local h, i, j = g:ToOrientation()
    local k, l = {}, a.utf8.char(0)

    k[l] = e.X

    local m = a.utf8.char(1)

    k[m] = e.Y

    local n = a.utf8.char(2)

    k[n] = e.Z

    local o = a.utf8.char(3)

    k[o] = h

    local p = a.utf8.char(4)

    k[p] = i

    local q = a.utf8.char(5)

    k[q] = j

    local r = f.CFrame:ToObjectSpace(a.CFrame.new(f.Position))
    local s, t, u = r:ToOrientation()
    local v, w, x, y = {}, a.utf8.char(1), {}, a.utf8.char(0)

    x[y] = k

    local z = a.utf8.char(1)

    x[z] = k

    local A = a.utf8.char(2)

    x[A] = f

    local B, C, D = a.utf8.char(3), {}, a.utf8.char(0)

    C[D] = r.X

    local E = a.utf8.char(1)

    C[E] = r.Y

    local F = a.utf8.char(2)

    C[F] = r.Z

    local G = a.utf8.char(3)

    C[G] = s

    local H = a.utf8.char(4)

    C[H] = t

    local I = a.utf8.char(5)

    C[I] = u
    x[B] = C
    v[w] = x

    return v
end
d.p160 = function(aa)
    local e

    e = aa[1][1].Data

    if (not aa[1][1].Data) then
    else
        e = aa[1][1].Data.ObjectID
    end

    return e
end
d.p159 = function(aa)
    return aa[1][1]:Get'ObjectID'
end
d.p158 = function(aa)
    local e, f, g, h

    f = aa[1][1]

    if (not aa[1][1]) then
    else
        f = aa[2][1]
    end
    if (not (not f)) then
        e = aa[2][1].LocalFighter

        if (not (not aa[2][1].LocalFighter)) then
            local i = {
                e.EquippedItem,
            }

            f = i

            if (not (not i[1])) then
                local j, k = a.pcall(function(...)
                    return d.p159({f}, ...)
                end)

                g = k
                h = j

                if (not j) then
                else
                    h = g
                end
                if (not h) then
                    local l, m = a.pcall(function(...)
                        return d.p160({f}, ...)
                    end)

                    g = m
                    h = l

                    if (not l) then
                    else
                        h = g
                    end
                    if (h) then
                    else
                        h = nil
                    end

                    return h
                else
                    return g
                end
            else
                return nil
            end
        else
            return nil
        end
    else
        return nil
    end
end
d.p157 = function(aa)
    local e = aa[1][1]:ToEnum'StartShooting'

    aa[2][1] = e

    return
end
d.p156 = function(aa)
    local e, f = a.pcall(a.require, aa[1][1].PlayerScripts.Controllers.FighterController)
    local g, h, i, j = {e}, {f}, a.pcall(a.require, aa[2][1].Modules.EnumLibrary)
    local k, l, m = {j}, {
        aa[2][1].Remotes.Replication.Fighter.UseItem,
    }, {nil}

    a.pcall(function(...)
        return d.p157({k, m}, ...)
    end)

    local n = {nil}

    n[1] = function(...)
        return d.p158({g, h}, ...)
    end

    local o = {nil}

    o[1] = function(...)
        return d.p161({}, ...)
    end

    local p = {nil}
    local q = aa[3][1].Heartbeat:Connect(function(...)
        return d.p162({
            aa[4],
            aa[5],
            aa[1],
            n,
            p,
            aa[6],
            aa[7],
            aa[8],
            o,
            l,
            m,
        }, ...)
    end)

    aa[9][1] = q

    return
end
d.p155 = function(aa)
    a.xpcall(function(...)
        return d.p156({
            aa[1],
            aa[2],
            aa[3],
            aa[4],
            aa[5],
            aa[6],
            aa[7],
            aa[8],
            aa[9],
        }, ...)
    end, function(...)
        return d.p164({}, ...)
    end)

    return
end
d.rage_worker_bootstrap = function(aa, e)
    local f

    f = e

    if (not aa[1][1]) then
    else
        aa[1][1]:Disconnect()

        aa[1][1] = nil
    end
    if (not (not f)) then
        a.task.spawn(function(...)
            return d.p155({
                aa[2],
                aa[3],
                aa[4],
                aa[5],
                aa[6],
                aa[7],
                aa[8],
                aa[9],
                aa[1],
            }, ...)
        end)

        return
    else
        return
    end
end
d.nearest_player_helper = function(aa)
    while true do
        local e = (aa[1][1] and aa[2][1]) and 0.03 or 0.08

        a.task.wait(e)

        if aa[1][1] and aa[3][1] then
            local f = aa[4][1]
            local g = f.Character
            local h = g and g:FindFirstChild'HumanoidRootPart'
            local i, j, k = h and h.Position or a.Vector3.zero, (a.math.huge)

            for l, m in pairs(aa[5][1]:GetPlayers())do
                if m ~= f and m.Character and not aa[6][1](m) and (not aa[7][1](m) or not aa[8][1](m)) then
                    local n, o = m.Character:FindFirstChild'HumanoidRootPart', m.Character:FindFirstChild'Humanoid'

                    if n and o and o.Health > 0 then
                        local p, q = a.Vector3.new(i.X, 0, i.Z), a.Vector3.new(n.Position.X, 0, n.Position.Z)
                        local r = (p - q).Magnitude

                        if r < j then
                            j = r
                            k = m
                        end
                    end
                end
            end

            if k and k.Character then
                aa[10][1] = aa[9][1](k.Character)
            else
                aa[10][1] = nil
            end
        else
            aa[10][1] = nil
        end
    end
end
d.p152 = function(aa)
    local e = aa[1][1]
    local f = e.Character
    local g = f and f:FindFirstChild'HumanoidRootPart'

    if not g then
        return
    end
    if aa[2][1] then
        aa[3][1]()
    end

    local h = aa[4][1]

    if h then
        h = aa[5][1]
    end
    if h then
        h = aa[6][1]()
    end
    if h then
        local i = h:FindFirstAncestorOfClass'Model' or h.Parent
        local j = aa[8][1]:GetPlayerFromCharacter(i)

        if j and aa[9][1](j) then
            return
        end

        local k = (g.Position - h.Position).Magnitude

        if k > (aa[10][1] or 500) then
            return
        end

        aa[2][1] = g.CFrame
        aa[11][1] = g.AssemblyLinearVelocity

        local l, m = h.Position + a.Vector3.new(aa[12][1] or 0, (aa[13][1] or aa[14][1]) or 3, aa[15][1] or 0), aa[16][1] or 0

        if m > 0 and h.AssemblyLinearVelocity then
            l = l + h.AssemblyLinearVelocity * m
        end

        g.CFrame = a.CFrame.new(l, h.Position)

        return
    end
    if aa[17][1] then
        if not aa[18][1] then
            aa[18][1] = g.Position
        end

        aa[2][1] = g.CFrame
        aa[11][1] = g.AssemblyLinearVelocity

        local i = a.Vector3.new(a.math.random(-100, 100), a.math.random(-100, 100), a.math.random(-100, 100)).Unit
        local j, k = aa[18][1] + i * aa[19][1], aa[2][1] - aa[2][1].Position

        g.CFrame = a.CFrame.new(j) * k
    end
end
d.rage_desync_step = function(aa)
    local e, f, g = (aa[1][1](2))

    f = (not e)

    if (not (not e)) then
    else
        g = aa[2][1]

        if (not aa[2][1]) then
        else
            g = aa[3][1]
        end

        f = (not g)
    end
    if (not f) then
    else
        f = (not aa[4][1])
    end
    if (not f) then
        a.pcall(function(...)
            return d.p152({
                aa[5],
                aa[4],
                aa[6],
                aa[2],
                aa[7],
                aa[3],
                aa[8],
                aa[9],
                aa[10],
                aa[11],
                aa[12],
                aa[13],
                aa[14],
                aa[15],
                aa[16],
                aa[17],
                aa[18],
                aa[19],
                aa[20],
            }, ...)
        end)

        return
    else
        return
    end
end
d.bind_desync_restore = function(aa)
    aa[1][1]:BindToRenderStep('RestoreDesyncPerfect', 0, aa[2][1])

    return
end
d.unbind_desync_restore = function(aa)
    aa[1][1]:UnbindFromRenderStep'RestoreDesyncPerfect'

    return
end
d.capture_root_state = function(aa)
    local e, f

    e = aa[1][1].Character

    if (not aa[1][1].Character) then
    else
        local g = aa[1][1].Character:FindFirstChild'HumanoidRootPart'

        e = g
    end

    f = (not e)

    if ((not e)) then
    else
        f = (not aa[2][1])
    end
    if (not f) then
        e.CFrame = aa[2][1]

        if (not aa[3][1]) then
        else
            e.AssemblyLinearVelocity = aa[3][1]
        end

        aa[2][1] = nil
        aa[3][1] = nil

        return
    else
        return
    end
end
d.p147 = function(aa)
    local e, f = aa[1][1], aa[2][1]

    if e.Get then
        return e:Get(f)
    end

    local g = e[f]

    if g ~= nil then
        return g
    end
    if e.Data then
        g = e.Data[f]

        if g ~= nil then
            return g
        end
    end
    if e.Info then
        return e.Info[f]
    end

    return nil
end
d.p146 = function(aa, e)
    local f, g

    f = e

    local h = {f}
    local i, j = a.pcall(function(...)
        return d.p147({
            aa[1],
            h,
        }, ...)
    end)

    g = j

    if (not i) then
        return nil
    else
        return g
    end
end
d.ammo_state_helper = function(aa)
    local e, f, g, h, i, j, k, l = nil, nil, nil, nil, nil, nil, a.pcall(a.require, aa[1][1].PlayerScripts.Controllers.FighterController)

    e = l
    f = (not k)

    if ((not k)) then
    else
        f = (not e)
    end
    if (f) then
    else
        f = (not e.LocalFighter)
    end
    if (not f) then
        local m = {
            e.LocalFighter.EquippedItem,
        }

        f = m

        if (not (not m[1])) then
            local n = (function(...)
                return d.p146({f}, ...)
            end)'CurrentAmmo'

            g = function(...)
                return d.p146({f}, ...)
            end
            h = n

            if (n) then
            else
                local o = g'Ammo'

                h = o
            end
            if (h) then
            else
                local o = g'Bullets'

                h = o
            end
            if (h) then
            else
                local o = g'MagazineAmmo'

                h = o
            end

            local o = g'Reloading'

            i = o

            if (o) then
            else
                local p = g'IsReloading'

                i = p
            end

            j = f[1].Info

            if (not f[1].Info) then
            else
                local p = a.type(f[1].Info)

                j = (p == 'table')
            end
            if (not j) then
            else
                if (not (h == nil)) then
                else
                    j = f[1].Info.CurrentAmmo

                    if (f[1].Info.CurrentAmmo) then
                    else
                        j = f[1].Info.Ammo
                    end

                    h = j
                end

                j = (f[1].Info.Reloading == true)

                if ((f[1].Info.Reloading == true)) then
                else
                    j = (f[1].Info.IsReloading == true)
                end
                if (not j) then
                else
                    i = true
                end
            end
            if (not (i == true)) then
                local p = a.typeof(h)

                j = (p == 'number')

                if (not (p == 'number')) then
                else
                    j = (h <= 0)
                end
                if (not j) then
                    return
                else
                    aa[2][1] = false

                    return
                end
            else
                aa[2][1] = false

                return
            end
        else
            aa[2][1] = false

            return
        end
    else
        return
    end
end
d.p144 = function(aa)
    local e = {true}

    a.pcall(function(...)
        return d.ammo_state_helper({
            aa[1],
            e,
        }, ...)
    end)

    return e[1]
end
d.p143 = function(aa, e)
    return
end
d.p142 = function(aa)
    aa[1][1]:FireServer(aa[2][1], aa[3][1], aa[4][1], nil)

    return
end
d.p141 = function(aa)
    local e, f, g, h

    e = (not aa[1][1])

    if ((not aa[1][1])) then
    else
        e = (not aa[2][1])
    end
    if (not e) then
        e = (not aa[3][1])

        if ((not aa[3][1])) then
        else
            e = (not aa[3][1].Parent)
        end
        if (not e) then
            local i = aa[3][1]:FindFirstAncestorOfClass'Model'

            e = i

            if (i) then
            else
                e = aa[3][1].Parent
            end

            local j = aa[4][1]:GetPlayerFromCharacter(e)

            f = j
            g = (not j)

            if ((not j)) then
            else
                g = (f == aa[5][1])
            end
            if (not g) then
                local k = aa[6][1](f)

                if (not k) then
                    local l = aa[7][1](f)

                    if (not l) then
                        local m = aa[8][1](f)

                        if (not m) then
                            g = aa[5][1].Character

                            if (not aa[5][1].Character) then
                            else
                                local n = aa[5][1].Character:FindFirstChild'HumanoidRootPart'

                                g = n
                            end
                            if (not (not g)) then
                                local n = aa[9][1]()
                                local o = {n}

                                h = o

                                if (not o[1]) then
                                    h[1] = aa[10][1]
                                else
                                    aa[10][1] = h[1]
                                end
                                if (not (not h[1])) then
                                    local p = a.Vector3.new(0, 0.1, 0)
                                    local q = aa[11][1]((aa[3][1].Position + p), aa[3][1])
                                    local r = {q}

                                    a.pcall(function(...)
                                        return d.p142({
                                            aa[12],
                                            h,
                                            aa[13],
                                            r,
                                        }, ...)
                                    end)

                                    return
                                else
                                    return
                                end
                            else
                                return
                            end
                        else
                            return
                        end
                    else
                        return
                    end
                else
                    return
                end
            else
                return
            end
        else
            return
        end
    else
        return
    end
end
d.p140 = function(aa, e)
    local f

    f = e

    if (not aa[1][1]) then
    else
        aa[1][1]:Disconnect()

        aa[1][1] = nil
    end
    if (not (not f)) then
        local g = {nil}
        local h = aa[2][1].Heartbeat:Connect(function(...)
            return d.p141({
                aa[3],
                aa[4],
                aa[5],
                aa[6],
                aa[7],
                aa[8],
                aa[9],
                aa[10],
                aa[11],
                g,
                aa[12],
                aa[13],
                aa[14],
            }, ...)
        end)

        aa[1][1] = h

        return
    else
        return
    end
end
d.encode_cframe_helper = function(aa, e, f)
    local g = a.CFrame.lookAt(e, f.Position)
    local h, i, j = g:ToOrientation()
    local k, l = {}, a.utf8.char(0)

    k[l] = e.X

    local m = a.utf8.char(1)

    k[m] = e.Y

    local n = a.utf8.char(2)

    k[n] = e.Z

    local o = a.utf8.char(3)

    k[o] = h

    local p = a.utf8.char(4)

    k[p] = i

    local q = a.utf8.char(5)

    k[q] = j

    local r = f.CFrame:ToObjectSpace(a.CFrame.new(f.Position))
    local s, t, u = r:ToOrientation()
    local v, w, x, y = {}, a.utf8.char(1), {}, a.utf8.char(0)

    x[y] = k

    local z = a.utf8.char(1)

    x[z] = k

    local A = a.utf8.char(2)

    x[A] = f

    local B, C, D = a.utf8.char(3), {}, a.utf8.char(0)

    C[D] = r.X

    local E = a.utf8.char(1)

    C[E] = r.Y

    local F = a.utf8.char(2)

    C[F] = r.Z

    local G = a.utf8.char(3)

    C[G] = s

    local H = a.utf8.char(4)

    C[H] = t

    local I = a.utf8.char(5)

    C[I] = u
    x[B] = C
    v[w] = x

    return v
end
d.p138 = function(aa)
    local e

    e = aa[1][1].Data

    if (not aa[1][1].Data) then
    else
        e = aa[1][1].Data.ObjectID
    end

    return e
end
d.p137 = function(aa)
    return aa[1][1]:Get'ObjectID'
end
d.p136 = function(aa)
    local e, f, g, h

    f = aa[1][1]

    if (not aa[1][1]) then
    else
        f = aa[2][1]
    end
    if (not (not f)) then
        e = aa[2][1].LocalFighter

        if (not (not aa[2][1].LocalFighter)) then
            local i = {
                e.EquippedItem,
            }

            f = i

            if (not (not i[1])) then
                local j, k = a.pcall(function(...)
                    return d.p137({f}, ...)
                end)

                g = k
                h = j

                if (not j) then
                else
                    h = g
                end
                if (not h) then
                    local l, m = a.pcall(function(...)
                        return d.p138({f}, ...)
                    end)

                    g = m
                    h = l

                    if (not l) then
                    else
                        h = g
                    end
                    if (h) then
                    else
                        h = nil
                    end

                    return h
                else
                    return g
                end
            else
                return nil
            end
        else
            return nil
        end
    else
        return nil
    end
end
d.p135 = function(aa)
    local e = aa[1][1]:ToEnum'StartShooting'

    aa[2][1] = e

    return
end
d.p134 = function(aa)
    local e, f = a.pcall(a.require, aa[1][1].PlayerScripts.Controllers.FighterController)
    local g, h, i, j = {e}, {f}, a.pcall(a.require, aa[2][1].Modules.EnumLibrary)
    local k, l, m = {j}, {
        aa[2][1].Remotes.Replication.Fighter.UseItem,
    }, {nil}

    a.pcall(function(...)
        return d.p135({k, m}, ...)
    end)

    local n = {nil}

    n[1] = function(...)
        return d.p136({g, h}, ...)
    end

    local o = {nil}

    o[1] = function(...)
        return d.encode_cframe_helper({}, ...)
    end
    aa[12][1] = function(...)
        return d.p140({
            aa[3],
            aa[4],
            aa[5],
            aa[6],
            aa[7],
            aa[8],
            aa[1],
            aa[9],
            aa[10],
            aa[11],
            n,
            o,
            l,
            m,
        }, ...)
    end

    return
end
d.silent_aim_bootstrap = function(aa)
    a.xpcall(function(...)
        return d.p134({
            aa[1],
            aa[2],
            aa[3],
            aa[4],
            aa[5],
            aa[6],
            aa[7],
            aa[8],
            aa[9],
            aa[10],
            aa[11],
            aa[12],
        }, ...)
    end, function(...)
        return d.p143({}, ...)
    end)

    return
end
d.p132 = function(aa, e)
    return
end
d.find_hitbox_part = function(aa, e)
    local f, g

    f = e

    if (not (not f)) then
        local h = f:FindFirstChild'HitboxHead'

        g = h

        if (h) then
        else
            local i = f:FindFirstChild'HitboxHeadSmall'

            g = i
        end
        if (g) then
        else
            local i = f:FindFirstChild'Head'

            g = i
        end

        return g
    else
        return nil
    end
end
d.p130 = function(aa)
    while true do
        a.task.wait(1.5)

        if aa[1][1] then
            a.pcall(aa[2][1], aa[3][1])
        end
    end
end
d.p129 = function(aa)
    aa[1][1][aa[2][1] ] = aa[3][1]

    return
end
d.p128 = function(aa)
    aa[1][1].Parent = nil

    return
end
d.p127 = function(aa)
    aa[1][1]:Destroy()

    return
end
d.skybox_manager = function(aa, e)
    local f = a.game:GetService'Lighting'
    local g = {
        f:FindFirstChild'CustomSkybox',
    }

    if aa[1][1] and (not e or e == '') then
        e = aa[2][1]

        if not e or e == '' then
            e = 'Dark Sky'
            aa[2][1] = e
        end
    end
    if not aa[1][1] then
        if g[1] then
            a.pcall(function()
                return d.p127{g}
            end)
        end

        return
    end
    if not e or e == '' then
        return
    end

    local h = aa[3][1][e]

    if not h then
        return
    end

    for i, j in ipairs(f:GetChildren())do
        if j:IsA'Sky' and j.Name ~= 'CustomSkybox' then
            local k = {j}

            a.pcall(function()
                return d.p128{k}
            end)
        end
    end

    if not g[1] or not g[1].Parent then
        g[1] = a.Instance.new'Sky'
        g[1].Name = 'CustomSkybox'
        g[1].Parent = f
    end

    for i, j in pairs(h)do
        local k, l = {i}, {j}

        a.pcall(function()
            return d.p129{g, k, l}
        end)
    end

    g[1].Parent = f
end
d.p125 = function(aa, e)
    local f

    f = e

    a.task.wait(0.6)

    if (not aa[1][1]) then
    else
        aa[2][1](f)
    end

    return
end
d.p124 = function(aa)
    aa[1][1]:AdjustSpeed(aa[2][1])

    return
end
d.p123 = function(aa)
    return aa[1][1].IsPlaying
end
d.watch_emote_speed = function(aa)
    while true do
        a.task.wait(1)

        if aa[1][1] then
            local e = aa[2][1].Character

            if e then
                local f, g = aa[3][1], false

                if f then
                    g = a.pcall(function()
                        return d.p123{
                            aa[3],
                        }
                    end)
                end
                if not g or not aa[3][1] then
                    aa[4][1](e)
                else
                    a.pcall(function()
                        return d.p124{
                            aa[3],
                            aa[5],
                        }
                    end)
                end
            end
        end
    end
end
d.p121 = function(aa)
    aa[1][1]:AdjustSpeed(aa[2][1])

    return
end
d.p120 = function(aa)
    aa[1][1]:Play(0.1, 1, aa[2][1])

    return
end
d.p119 = function(aa)
    return aa[1][1]:LoadAnimation(aa[2][1])
end
d.play_emote = function(aa, e)
    local f, g, h, i, j, k

    f = e

    aa[1][1]()

    if (not (not f)) then
        local l = f:FindFirstChildOfClass'Humanoid'

        g = l

        if (not (not l)) then
            local m = g:FindFirstChildOfClass'Animator'
            local n = {m}

            h = n

            if (not (not n[1])) then
            else
                local o = a.Instance.new'Animator'

                h[1] = o
                h[1].Parent = g
            end

            i = aa[2][1][aa[3][1] ]

            if (aa[2][1][aa[3][1] ]) then
            else
                i = aa[2][1].Dance
            end

            local o = a.Instance.new'Animation'
            local p, q = {o}, a.tostring(i)

            p[1].AnimationId = ('rbxassetid://' .. q)
            aa[4][1] = p[1]

            local r, s = a.pcall(function(...)
                return d.p119({h, p}, ...)
            end)
            local t = {s}

            j = t
            k = r

            if (not r) then
            else
                k = j[1]
            end
            if (not k) then
            else
                aa[5][1] = j[1]
                j[1].Looped = true
                j[1].Priority = a.Enum.AnimationPriority.Action4

                a.pcall(function(...)
                    return d.p120({
                        j,
                        aa[6],
                    }, ...)
                end)
                a.pcall(function(...)
                    return d.p121({
                        j,
                        aa[6],
                    }, ...)
                end)
            end

            return
        else
            return
        end
    else
        return
    end
end
d.p117 = function(aa)
    aa[1][1]:Destroy()

    return
end
d.p116 = function(aa)
    aa[1][1]:Destroy()

    return
end
d.p115 = function(aa)
    aa[1][1]:Stop(0.1)

    return
end
d.p114 = function(aa)
    if (not aa[1][1]) then
    else
        a.pcall(function(...)
            return d.p115({
                aa[1],
            }, ...)
        end)
        a.pcall(function(...)
            return d.p116({
                aa[1],
            }, ...)
        end)

        aa[1][1] = nil
    end
    if (not aa[2][1]) then
    else
        a.pcall(function(...)
            return d.p117({
                aa[2],
            }, ...)
        end)

        aa[2][1] = nil
    end

    return
end
d.wait_numeric_state = function(aa)
    while true do
        if aa[1][1] and a.L555_61 then
            aa[2][1] = true

            local e = aa[3][1]

            if a.typeof(e) ~= 'number' or e < 0.01 then
                e = 0.01
            end

            a.task.wait(e)

            if aa[1][1] and a.L555_61 then
                aa[2][1] = false

                local f = aa[4][1]

                if a.typeof(f) ~= 'number' or f < 0.01 then
                    f = 0.01
                end

                a.task.wait(f)
            else
                aa[2][1] = true
            end
        else
            aa[2][1] = true

            a.task.wait(0.12)
        end
    end
end
d.p112 = function(aa)
    local e, f

    if (not aa[1][1].Animation) then
    else
        e = a.tostring
        f = aa[1][1].Animation.AnimationId

        if (aa[1][1].Animation.AnimationId) then
        else
            f = ''
        end

        local g = e(f)

        aa[2][1] = g
    end

    return
end
d.p111 = function(aa)
    return aa[1][1]:GetPlayingAnimationTracks()
end
d.anti_katana_check = function(aa, e)
    local f = e and e.Character

    if not f then
        return false
    end

    local g = f:FindFirstChildOfClass'Humanoid'

    for h, i in ipairs{
        'Reflecting',
        'IsReflecting',
        'BulletReflect',
        'Reflect',
        'Deflecting',
        'Parrying',
    }do
        local j = f:GetAttribute(i)

        if j == true or j == 1 or j == 'true' then
            return true
        end
        if g then
            local k = g:GetAttribute(i)

            if k == true or k == 1 then
                return true
            end
        end
    end

    local h, i = false, f:FindFirstChildOfClass'Tool'

    if i and a.string.find(a.string.lower(i.Name), 'katana', 1, true) then
        h = true
    end

    for j, k in ipairs(f:GetChildren())do
        local l = a.string.lower(k.Name)

        if a.string.find(l, 'katana', 1, true) then
            h = true
        end
        if a.string.find(l, 'reflect', 1, true) or a.string.find(l, 'deflect', 1, true) then
            return true
        end
    end

    if g then
        local j, k = a.pcall(function()
            return d.p111{
                {g},
            }
        end)

        if j and k then
            for l, m in ipairs(k)do
                local n, o, p = {m}, {
                    '',
                }, a.string.lower(a.tostring(m.Name or ''))

                a.pcall(function()
                    return d.p112{n, o}
                end)

                local q = p .. ' ' .. a.string.lower(o[1])
                local r = a.string.find(q, 'reflect', 1, true) or a.string.find(q, 'deflect', 1, true) or a.string.find(q, 'parry', 1, true) or a.string.find(q, 'block', 1, true)

                if r then
                    if h or a.string.find(q, 'katana', 1, true) then
                        return true
                    end
                    if a.string.find(q, 'reflect', 1, true) or a.string.find(q, 'deflect', 1, true) then
                        return true
                    end
                end
            end
        end
    end

    return false
end
d.is_invulnerable = function(aa, e)
    local f, g, h, i, j, k

    f = e

    local l = a.typeof(f)

    g = f
    h = (l == 'Instance')

    if (not (l == 'Instance')) then
    else
        local m = f:IsA'Player'

        h = m
    end
    if (not h) then
    else
        g = f.Character
    end
    if (not (not g)) then
        local m = g:FindFirstChildOfClass'ForceField'

        if (not m) then
            local n = g:FindFirstChild'HumanoidRootPart'

            h = n
            i = n

            if (not n) then
            else
                local o = h:FindFirstChild'Attachment'

                i = o
            end
            if (not i) then
                local o = g:GetAttribute'Immune'

                i = o

                if (o) then
                else
                    local p = g:GetAttribute'Invincible'

                    i = p
                end
                if (i) then
                else
                    local p = g:GetAttribute'IsImmune'

                    i = p
                end
                if (not (i == true)) then
                    local p = g:FindFirstChildOfClass'Humanoid'

                    j = p

                    if (not p) then
                    else
                        local q = j:GetAttribute'Immune'

                        k = q

                        if (q) then
                        else
                            local r = j:GetAttribute'Invincible'

                            k = r
                        end
                        if (not (k == true)) then
                            return false
                        else
                            return true
                        end
                    end

                    return false
                else
                    return true
                end
            else
                return true
            end
        else
            return true
        end
    else
        return true
    end
end
d.get_team_id = function(aa, e)
    local f, g, h, i

    f = e

    if (not (not aa[1][1])) then
        local j, k = aa[2][1]:GetAttribute'TeamID', f:GetAttribute'TeamID'

        g = j
        h = k
        i = (j == nil)

        if ((j == nil)) then
        else
            i = (h == nil)
        end
        if (not i) then
            return (h == g)
        else
            return false
        end
    else
        return false
    end
end
d.p107 = function(aa)
    aa[1][1]:Destroy()

    aa[2][1] = true

    aa[3][1]()

    return
end
d.animate_ui_blur = function(aa, ...)
    local e, f = {}, pack(...)

    for g = 1, 0 do
        e[g - 1] = f[g]
    end

    local g = 1

    while true do
        if g == 1 then
            e[0] = a.game
            e[2] = 'GetService'
            e[1] = e[0]
            e[0] = e[0][e[2] ]
            e[2] = 'TweenService'

            do
                local h = 2
                local i = pack(e[0](b(e, 1, 0 + h)))

                for j = 1, 1 do
                    e[0 + j - 1] = i[j]
                end
            end

            e[1] = a.game
            e[3] = 'GetService'
            e[2] = e[1]
            e[1] = e[1][e[3] ]
            e[3] = 'Lighting'

            do
                local h = 2
                local i = pack(e[1](b(e, 2, 1 + h)))

                for j = 1, 1 do
                    e[1 + j - 1] = i[j]
                end
            end

            e[3] = a.task
            e[4] = 'wait'
            e[2] = e[3][e[4] ]
            e[3] = 0.7

            do
                local h = 1

                e[2](b(e, 3, 2 + h))
            end

            e[2] = a.tick

            do
                local h = 0
                local i = pack(e[2](b(e, 3, 2 + h)))

                for j = 1, 1 do
                    e[2 + j - 1] = i[j]
                end
            end

            g = 2
        elseif g == 2 then
            e[5] = a.tick

            do
                local h = 0
                local i = pack(e[5](b(e, 6, 5 + h)))

                for j = 1, 1 do
                    e[5 + j - 1] = i[j]
                end
            end

            e[6] = e[2]
            e[4] = e[5] - e[6]
            e[5] = 3
            e[3] = e[4] < e[5]

            if (not not e[3]) == false then
                g = 4
            else
                g = 3
            end
        elseif g == 3 then
            e[4] = a.task
            e[5] = 'wait'
            e[3] = e[4][e[5] ]

            do
                local h = 0

                e[3](b(e, 4, 3 + h))
            end

            g = 2
        elseif g == 4 then
            e[3] = a.tick

            do
                local h = 0
                local i = pack(e[3](b(e, 4, 3 + h)))

                for j = 1, 1 do
                    e[3 + j - 1] = i[j]
                end
            end

            g = 5
        elseif g == 5 then
            e[6] = a.tick

            do
                local h = 0
                local i = pack(e[6](b(e, 7, 6 + h)))

                for j = 1, 1 do
                    e[6 + j - 1] = i[j]
                end
            end

            e[7] = e[3]
            e[5] = e[6] - e[7]
            e[6] = 2
            e[4] = e[5] < e[6]

            if (not not e[4]) == false then
                g = 10
            else
                g = 6
            end
        elseif g == 6 then
            e[4] = 0
            e[5] = 1
            e[6] = 500000
            e[7] = 1
            e[5] = e[5] - e[7]
            g = 8
        elseif g == 7 then
            e[10] = e[4]
            e[11] = e[8]
            e[9] = e[10] + e[11]
            e[4] = e[9]
            g = 8
        elseif g == 8 then
            e[5] = e[5] + e[7]

            local h = e[7]

            if (h > 0 and e[5] <= e[6]) or (h <= 0 and e[5] >= e[6]) then
                e[8] = e[5]
                g = 7
            else
                g = 9
            end
        elseif g == 9 then
            e[6] = a.task
            e[7] = 'wait'
            e[5] = e[6][e[7] ]

            do
                local h = 0

                e[5](b(e, 6, 5 + h))
            end

            g = 5
        elseif g == 10 then
            e[4] = e[1]
            e[6] = 'FindFirstChild'
            e[5] = e[4]
            e[4] = e[4][e[6] ]
            e[6] = 'ValkUIBlur'

            do
                local h = 2
                local i = pack(e[4](b(e, 5, 4 + h)))

                for j = 1, 1 do
                    e[4 + j - 1] = i[j]
                end
            end

            if (not not e[4]) == true then
                g = 12
            else
                g = 11
            end
        elseif g == 11 then
            e[5] = a.Instance
            e[6] = 'new'
            e[4] = e[5][e[6] ]
            e[5] = 'BlurEffect'

            do
                local h = 1
                local i = pack(e[4](b(e, 5, 4 + h)))

                for j = 1, 1 do
                    e[4 + j - 1] = i[j]
                end
            end

            g = 12
        elseif g == 12 then
            e[5] = e[4]
            e[6] = 'Name'
            e[7] = 'ValkUIBlur'
            e[5][e[6] ] = e[7]
            e[5] = e[4]
            e[6] = 'Size'
            e[7] = 0
            e[5][e[6] ] = e[7]
            e[5] = e[4]
            e[6] = 'Parent'
            e[7] = e[1]
            e[5][e[6] ] = e[7]
            e[6] = a.Instance
            e[7] = 'new'
            e[5] = e[6][e[7] ]
            e[6] = 'TextLabel'

            do
                local h = 1
                local i = pack(e[5](b(e, 6, 5 + h)))

                for j = 1, 1 do
                    e[5 + j - 1] = i[j]
                end
            end

            e[5] = {
                e[5],
            }
            e[6] = e[5][1]
            e[7] = 'Name'
            e[8] = 'IntroLEVK'
            e[6][e[7] ] = e[8]
            e[6] = e[5][1]
            e[7] = 'Parent'
            e[8] = aa[1][1]
            e[6][e[7] ] = e[8]
            e[6] = e[5][1]
            e[7] = 'AnchorPoint'
            e[9] = a.Vector2
            e[10] = 'new'
            e[8] = e[9][e[10] ]
            e[9] = 0.5
            e[10] = 0.5

            do
                local h = 2
                local i = pack(e[8](b(e, 9, 8 + h)))

                for j = 1, 1 do
                    e[8 + j - 1] = i[j]
                end
            end

            e[6][e[7] ] = e[8]
            e[6] = e[5][1]
            e[7] = 'Position'
            e[9] = a.UDim2
            e[10] = 'new'
            e[8] = e[9][e[10] ]
            e[9] = 0.5
            e[10] = 0
            e[11] = 0.5
            e[12] = 0

            do
                local h = 4
                local i = pack(e[8](b(e, 9, 8 + h)))

                for j = 1, 1 do
                    e[8 + j - 1] = i[j]
                end
            end

            e[6][e[7] ] = e[8]
            e[6] = e[5][1]
            e[7] = 'Size'
            e[9] = a.UDim2
            e[10] = 'new'
            e[8] = e[9][e[10] ]
            e[9] = 0
            e[10] = 400
            e[11] = 0
            e[12] = 100

            do
                local h = 4
                local i = pack(e[8](b(e, 9, 8 + h)))

                for j = 1, 1 do
                    e[8 + j - 1] = i[j]
                end
            end

            e[6][e[7] ] = e[8]
            e[6] = e[5][1]
            e[7] = 'BackgroundTransparency'
            e[8] = 1
            e[6][e[7] ] = e[8]
            e[6] = e[5][1]
            e[7] = 'Font'
            e[10] = a.Enum
            e[11] = 'Font'
            e[9] = e[10][e[11] ]
            e[10] = 'Code'
            e[8] = e[9][e[10] ]
            e[6][e[7] ] = e[8]
            e[6] = e[5][1]
            e[7] = 'Text'
            e[8] = 'LEVK'
            e[6][e[7] ] = e[8]
            e[6] = e[5][1]
            e[7] = 'TextColor3'
            e[9] = aa[2][1]
            e[10] = 'accentclr'
            e[8] = e[9][e[10] ]
            e[6][e[7] ] = e[8]
            e[6] = e[5][1]
            e[7] = 'TextSize'
            e[8] = 80
            e[6][e[7] ] = e[8]
            e[6] = e[5][1]
            e[7] = 'TextTransparency'
            e[8] = 1
            e[6][e[7] ] = e[8]
            e[7] = a.TweenInfo
            e[8] = 'new'
            e[6] = e[7][e[8] ]
            e[7] = 1
            e[10] = a.Enum
            e[11] = 'EasingStyle'
            e[9] = e[10][e[11] ]
            e[10] = 'Quad'
            e[8] = e[9][e[10] ]
            e[11] = a.Enum
            e[12] = 'EasingDirection'
            e[10] = e[11][e[12] ]
            e[11] = 'Out'
            e[9] = e[10][e[11] ]

            do
                local h = 3
                local i = pack(e[6](b(e, 7, 6 + h)))

                for j = 1, 1 do
                    e[6 + j - 1] = i[j]
                end
            end

            e[8] = a.TweenInfo
            e[9] = 'new'
            e[7] = e[8][e[9] ]
            e[8] = 0.8
            e[11] = a.Enum
            e[12] = 'EasingStyle'
            e[10] = e[11][e[12] ]
            e[11] = 'Quad'
            e[9] = e[10][e[11] ]
            e[12] = a.Enum
            e[13] = 'EasingDirection'
            e[11] = e[12][e[13] ]
            e[12] = 'In'
            e[10] = e[11][e[12] ]

            do
                local h = 3
                local i = pack(e[7](b(e, 8, 7 + h)))

                for j = 1, 1 do
                    e[7 + j - 1] = i[j]
                end
            end

            e[8] = e[0]
            e[10] = 'Create'
            e[9] = e[8]
            e[8] = e[8][e[10] ]
            e[10] = e[4]
            e[11] = e[6]
            e[12] = {}
            e[13] = 'Size'
            e[14] = 24
            e[12][e[13] ] = e[14]

            do
                local h = 4
                local i = pack(e[8](b(e, 9, 8 + h)))

                for j = 1, 1 do
                    e[8 + j - 1] = i[j]
                end
            end

            e[10] = 'Play'
            e[9] = e[8]
            e[8] = e[8][e[10] ]

            do
                local h = 1

                e[8](b(e, 9, 8 + h))
            end

            e[8] = e[0]
            e[10] = 'Create'
            e[9] = e[8]
            e[8] = e[8][e[10] ]
            e[10] = e[5][1]
            e[11] = e[6]
            e[12] = {}
            e[13] = 'TextTransparency'
            e[14] = 0
            e[12][e[13] ] = e[14]

            do
                local h = 4
                local i = pack(e[8](b(e, 9, 8 + h)))

                for j = 1, 1 do
                    e[8 + j - 1] = i[j]
                end
            end

            e[10] = 'Play'
            e[9] = e[8]
            e[8] = e[8][e[10] ]

            do
                local h = 1

                e[8](b(e, 9, 8 + h))
            end

            e[9] = a.task
            e[10] = 'wait'
            e[8] = e[9][e[10] ]
            e[9] = 2.2

            do
                local h = 1

                e[8](b(e, 9, 8 + h))
            end

            e[8] = e[0]
            e[10] = 'Create'
            e[9] = e[8]
            e[8] = e[8][e[10] ]
            e[10] = e[4]
            e[11] = e[7]
            e[12] = {}
            e[13] = 'Size'
            e[14] = 18
            e[12][e[13] ] = e[14]

            do
                local h = 4
                local i = pack(e[8](b(e, 9, 8 + h)))

                for j = 1, 1 do
                    e[8 + j - 1] = i[j]
                end
            end

            e[9] = e[0]
            e[11] = 'Create'
            e[10] = e[9]
            e[9] = e[9][e[11] ]
            e[11] = e[5][1]
            e[12] = e[7]
            e[13] = {}
            e[14] = 'TextTransparency'
            e[15] = 1
            e[13][e[14] ] = e[15]

            do
                local h = 4
                local i = pack(e[9](b(e, 10, 9 + h)))

                for j = 1, 1 do
                    e[9 + j - 1] = i[j]
                end
            end

            e[10] = e[8]
            e[12] = 'Play'
            e[11] = e[10]
            e[10] = e[10][e[12] ]

            do
                local h = 1

                e[10](b(e, 11, 10 + h))
            end

            e[10] = e[9]
            e[12] = 'Play'
            e[11] = e[10]
            e[10] = e[10][e[12] ]

            do
                local h = 1

                e[10](b(e, 11, 10 + h))
            end

            e[11] = e[8]
            e[12] = 'Completed'
            e[10] = e[11][e[12] ]
            e[12] = 'Connect'
            e[11] = e[10]
            e[10] = e[10][e[12] ]
            e[12] = function(...)
                return d.p107({
                    e[5],
                    aa[3],
                    aa[4],
                }, ...)
            end

            do
                local h = 2

                e[10](b(e, 11, 10 + h))
            end

            local h = 0

            return b(e, 0, 0 + h - 1)
        else
            return
        end
    end
end
d.destroy_ui_blur = function(aa, e)
    local f

    f = e

    local g = aa[1][1]:FindFirstChild'ValkUIBlur'

    if (not g) then
    else
        aa[1][1].ValkUIBlur:Destroy()
    end

    aa[2][1]:Destroy()

    return
end
d.p104 = function(aa, e, f)
    aa[1][1].Text = f

    return
end
d.create_multi_label = function(aa, e, f)
    local g, h = {}, a.Instance.new'TextLabel'
    local i = {h}

    i[1].Parent = aa[1][1]
    i[1].BackgroundTransparency = 1

    local j = a.UDim2.new(1, 0, 0, 18)

    i[1].Size = j
    i[1].Font = a.Enum.Font.Code
    i[1].Text = f

    local k = a.Color3.fromRGB(230, 230, 230)

    i[1].TextColor3 = k
    i[1].TextSize = 14
    i[1].TextXAlignment = a.Enum.TextXAlignment.Left

    aa[2][1]()

    g.Change = function(...)
        return d.p104({i}, ...)
    end

    return g
end
d.p102 = function(aa, ...)
    while a.task.wait() do
        aa[1][1].BackgroundColor3 = aa[2][1].accentclr
    end
end
d.p101 = function(aa, e)
    local f, g

    f = e
    g = aa[1][1]

    if (not aa[1][1]) then
    else
        g = (f.UserInputType == a.Enum.UserInputType.MouseMovement)

        if ((f.UserInputType == a.Enum.UserInputType.MouseMovement)) then
        else
            g = (f.UserInputType == a.Enum.UserInputType.Touch)
        end
    end
    if (not g) then
    else
        aa[2][1](f)
    end

    return
end
d.p100 = function(aa, e)
    local f, g

    f = e
    g = (f.UserInputType == a.Enum.UserInputType.MouseButton1)

    if ((f.UserInputType == a.Enum.UserInputType.MouseButton1)) then
    else
        g = (f.UserInputType == a.Enum.UserInputType.Touch)
    end
    if (not g) then
    else
        aa[1][1] = false
    end

    return
end
d.p099 = function(aa, e)
    local f, g

    f = e
    g = (f.UserInputType == a.Enum.UserInputType.MouseButton1)

    if ((f.UserInputType == a.Enum.UserInputType.MouseButton1)) then
    else
        g = (f.UserInputType == a.Enum.UserInputType.Touch)
    end
    if (not g) then
    else
        aa[1][1] = true

        aa[2][1](f)
    end

    return
end
d.p098 = function(aa, e)
    local f = a.math.clamp((e.Position.X - aa[1][1].AbsolutePosition.X) / aa[1][1].AbsoluteSize.X, 0, 1)
    local g = aa[2][1] + (aa[3][1] - aa[2][1]) * f

    if aa[4][1] == 0 then
        g = a.math.floor(g + 0.5)
    else
        g = a.tonumber(a.string.format('%.' .. aa[4][1] .. 'f', g))
    end

    aa[5][1].Size = a.UDim2.new(f, 0, 1, 0)
    aa[6][1].Text = a.tostring(g) .. 's'

    a.pcall(aa[7][1], g)
end
d.create_multi_slider = function(aa, e, f, g, h, i, j, k)
    local l, m, n, o, p = {g}, {h}, {j}, {k}, a.Instance.new'TextButton'
    local q = {p}

    q[1].Name = 'SliderBar'
    q[1].Parent = aa[1][1]

    local r = a.Color3.fromRGB(38, 38, 38)

    q[1].BackgroundColor3 = r
    q[1].BorderSizePixel = 0

    local s = a.UDim2.new(1, 0, 0, 16)

    q[1].Size = s
    q[1].Text = ''
    q[1].AutoButtonColor = false

    local t = a.Instance.new'ImageLabel'

    t.Parent = q[1]
    t.BackgroundTransparency = 1

    local u = a.UDim2.new(1, 0, 1, 0)

    t.Size = u
    t.Image = 'rbxassetid://2592362371'

    local v = a.Color3.fromRGB(60, 60, 60)

    t.ImageColor3 = v
    t.ScaleType = a.Enum.ScaleType.Slice

    local w = a.Rect.new(2, 2, 62, 62)

    t.SliceCenter = w

    local x = a.Instance.new'ImageLabel'

    x.Parent = q[1]
    x.BackgroundTransparency = 1

    local y = a.UDim2.new(0, 1, 0, 1)

    x.Position = y

    local z = a.UDim2.new(1, (-2), 1, (-2))

    x.Size = z
    x.Image = 'rbxassetid://2592362371'

    local A = a.Color3.fromRGB(0, 0, 0)

    x.ImageColor3 = A
    x.ScaleType = a.Enum.ScaleType.Slice

    local B = a.Rect.new(2, 2, 62, 62)

    x.SliceCenter = B

    local C = a.Instance.new'Frame'
    local D = {C}

    D[1].Parent = q[1]
    D[1].BackgroundColor3 = aa[2][1].accentclr
    D[1].BorderSizePixel = 0
    D[1].BackgroundTransparency = 0.55

    local E = a.UDim2.new(((i - l[1]) / (m[1] - l[1])), 0, 1, 0)

    D[1].Size = E

    local F = a.Instance.new'TextLabel'

    F.Parent = q[1]
    F.BackgroundTransparency = 1

    local G = a.UDim2.new(0, 6, 0, 0)

    F.Position = G

    local H = a.UDim2.new(0.7, 0, 1, 0)

    F.Size = H
    F.Font = a.Enum.Font.Code
    F.Text = f

    local I = a.Color3.fromRGB(190, 190, 190)

    F.TextColor3 = I
    F.TextSize = 13
    F.TextXAlignment = a.Enum.TextXAlignment.Left
    F.ZIndex = 2

    local J = a.Instance.new'TextLabel'
    local K = {J}

    K[1].Parent = q[1]
    K[1].BackgroundTransparency = 1

    local L = a.UDim2.new(1, (-75), 0, 0)

    K[1].Position = L

    local M = a.UDim2.new(0, 70, 1, 0)

    K[1].Size = M
    K[1].Font = a.Enum.Font.Code

    local N = a.tostring(i)

    K[1].Text = (N .. 's')

    local O = a.Color3.fromRGB(240, 240, 240)

    K[1].TextColor3 = O
    K[1].TextSize = 13
    K[1].TextXAlignment = a.Enum.TextXAlignment.Right
    K[1].ZIndex = 5

    local P, Q = {false}, {nil}

    Q[1] = function(...)
        return d.p098({
            q,
            l,
            m,
            n,
            D,
            K,
            o,
        }, ...)
    end

    q[1].InputBegan:Connect(function(...)
        return d.p099({P, Q}, ...)
    end)

    local R = a.game:GetService'UserInputService'

    R.InputEnded:Connect(function(...)
        return d.p100({P}, ...)
    end)

    local S = a.game:GetService'UserInputService'

    S.InputChanged:Connect(function(...)
        return d.p101({P, Q}, ...)
    end)
    aa[3][1]()

    local T = a.coroutine.wrap(function(...)
        return d.p102({
            D,
            aa[2],
        }, ...)
    end)

    T()

    return
end
d.p096 = function(aa, e, f)
    aa[1][1] = f
    aa[2][1].Visible = aa[1][1]

    a.pcall(aa[3][1], aa[1][1])

    return
end
d.p095 = function(aa, ...)
    while a.task.wait() do
        aa[1][1].BackgroundColor3 = aa[2][1].accentclr
    end
end
d.p094 = function(aa)
    aa[1][1] = (not aa[1][1])
    aa[2][1].Visible = aa[1][1]

    a.pcall(aa[3][1], aa[1][1])

    return
end
d.create_multi_toggle = function(aa, e, f, g, h)
    local i, j, k, l, m, n, o, p, q

    i = e
    j = f
    k = g
    l = h

    local r, s = {l}, a.Instance.new'TextButton'

    s.Name = 'Toggle'
    s.Parent = aa[1][1]

    local t = a.Color3.fromRGB(38, 38, 38)

    s.BackgroundColor3 = t
    s.BorderSizePixel = 0

    local u = a.UDim2.new(1, 0, 0, 22)

    s.Size = u
    s.AutoButtonColor = false
    s.Text = ''

    local v = a.Instance.new'ImageLabel'

    v.Parent = s
    v.BackgroundTransparency = 1

    local w = a.UDim2.new(1, 0, 1, 0)

    v.Size = w
    v.Image = 'rbxassetid://2592362371'

    local x = a.Color3.fromRGB(60, 60, 60)

    v.ImageColor3 = x
    v.ScaleType = a.Enum.ScaleType.Slice

    local y = a.Rect.new(2, 2, 62, 62)

    v.SliceCenter = y

    local z = a.Instance.new'ImageLabel'

    z.Parent = s
    z.BackgroundTransparency = 1

    local A = a.UDim2.new(0, 1, 0, 1)

    z.Position = A

    local B = a.UDim2.new(1, (-2), 1, (-2))

    z.Size = B
    z.Image = 'rbxassetid://2592362371'

    local C = a.Color3.fromRGB(0, 0, 0)

    z.ImageColor3 = C
    z.ScaleType = a.Enum.ScaleType.Slice

    local D = a.Rect.new(2, 2, 62, 62)

    z.SliceCenter = D

    local E = a.Instance.new'Frame'

    E.Parent = s

    local F = a.Color3.fromRGB(28, 28, 28)

    E.BackgroundColor3 = F
    E.BorderSizePixel = 0

    local G = a.UDim2.new(0, 6, 0.5, (-6))

    E.Position = G

    local H = a.UDim2.new(0, 12, 0, 12)

    E.Size = H

    local I = a.Instance.new'Frame'
    local J = {I}

    J[1].Parent = E
    J[1].BackgroundColor3 = aa[2][1].accentclr
    J[1].BorderSizePixel = 0

    local K = a.UDim2.new(0, 2, 0, 2)

    J[1].Position = K

    local L = a.UDim2.new(0, 8, 0, 8)

    J[1].Size = L
    l = r
    m = s
    n = J
    o = J[1]
    p = 'Visible'
    q = k

    if (k) then
    else
        q = false
    end

    o[p] = q

    local M = a.Instance.new'TextLabel'

    M.Parent = m
    M.BackgroundTransparency = 1

    local N = a.UDim2.new(0, 25, 0, 0)

    M.Position = N

    local O = a.UDim2.new(1, (-25), 1, 0)

    M.Size = O
    M.Font = a.Enum.Font.Code
    M.Text = j

    local P = a.Color3.fromRGB(190, 190, 190)

    M.TextColor3 = P
    M.TextSize = 14
    M.TextXAlignment = a.Enum.TextXAlignment.Left
    p = k

    if (k) then
    else
        p = false
    end

    local Q = {p}

    m.MouseButton1Click:Connect(function(...)
        return d.p094({Q, n, l}, ...)
    end)
    aa[3][1]()

    local R = a.coroutine.wrap(function(...)
        return d.p095({
            n,
            aa[2],
        }, ...)
    end)

    R()

    local S = {}

    S.Set = function(...)
        return d.p096({Q, n, l}, ...)
    end

    return S
end
d.p092 = function(aa)
    local e = a.UDim2.new(1, 0, 0, aa[2][1].AbsoluteContentSize.Y)

    aa[1][1].Size = e

    aa[3][1]()

    return
end
d.p091 = function(aa, ...)
    while a.task.wait() do
        if aa[1][1].Visible then
            aa[1][1].BackgroundColor3 = aa[2][1].accentclr
        end
    end
end
d.p090 = function(aa, ...)
    for e, f in a.ipairs(aa[1][1])do
        local g = e == aa[2][1]

        f.page.Visible = g
        f.underline.Visible = g
        f.btn.BackgroundColor3 = g and a.Color3.fromRGB(38, 38, 38) or a.Color3.fromRGB(28, 28, 28)
        f.btn.TextColor3 = g and a.Color3.fromRGB(230, 230, 230) or a.Color3.fromRGB(150, 150, 150)
    end

    aa[3][1]()
end
d.p089 = function(aa)
    local e = a.UDim2.new(1, 0, 0, aa[2][1].AbsoluteContentSize.Y)

    aa[1][1].Size = e

    aa[3][1]()

    return
end
d.p088 = function(aa, ...)
    local e = 0

    for f, g in a.ipairs(aa[1][1])do
        local h = g:FindFirstChildOfClass'UIListLayout'

        if h then
            e = a.math.max(e, h.AbsoluteContentSize.Y)
        end
    end

    aa[2][1].Size = a.UDim2.new(1, -16, 0, e)
    aa[3][1].Size = a.UDim2.new(1, -2, 0, e + 36)
    aa[4][1].CanvasSize = a.UDim2.new(0, 0, 0, aa[5][1].AbsoluteContentSize.Y + 20)
    aa[6][1].CanvasSize = a.UDim2.new(0, 0, 0, aa[7][1].AbsoluteContentSize.Y + 20)
end
d.create_multisection = function(aa, ...)
    local e, f = {}, pack(...)

    for g = 1, 3 do
        e[g - 1] = f[g]
    end

    local g = 1

    while true do
        if g == 1 then
            e[4] = aa[1][1]
            e[5] = 1
            e[3] = e[4] - e[5]
            aa[1][1] = e[3]

            for h = 3, 3 do
                e[h] = nil
            end

            e[5] = e[2]
            e[6] = 1
            e[4] = e[5] == e[6]

            if (not not e[4]) == false then
                g = 3
            else
                g = 2
            end
        elseif g == 2 then
            e[4] = aa[2][1]
            e[3] = e[4]
            g = 20
        elseif g == 3 then
            e[5] = e[2]
            e[6] = 2
            e[4] = e[5] == e[6]

            if (not not e[4]) == false then
                g = 5
            else
                g = 4
            end
        elseif g == 4 then
            e[4] = aa[3][1]
            e[3] = e[4]
            g = 20
        elseif g == 5 then
            e[4] = 0
            e[5] = 0
            e[6] = a.next
            e[7] = aa[2][1]
            e[9] = 'GetChildren'
            e[8] = e[7]
            e[7] = e[7][e[9] ]

            do
                local h = 1
                local i = pack(e[7](b(e, 8, 7 + h)))

                for j = 1, 2 do
                    e[7 + j - 1] = i[j]
                end
            end

            g = 10
        elseif g == 6 then
            e[13] = e[10]
            e[14] = 'Name'
            e[12] = e[13][e[14] ]
            e[13] = 'Section'
            e[11] = e[12] == e[13]

            if (not not e[11]) == true then
                g = 8
            else
                g = 7
            end
        elseif g == 7 then
            e[13] = e[10]
            e[14] = 'Name'
            e[12] = e[13][e[14] ]
            e[13] = 'MultiSection'
            e[11] = e[12] == e[13]
            g = 8
        elseif g == 8 then
            if (not not e[11]) == false then
                g = 10
            else
                g = 9
            end
        elseif g == 9 then
            e[12] = e[4]
            e[13] = 1
            e[11] = e[12] + e[13]
            e[4] = e[11]
            g = 10
        elseif g == 10 then
            do
                local h = pack(e[6](e[7], e[8]))
                local i = h[1]

                if i ~= nil then
                    e[8] = i

                    for j = 1, 2 do
                        e[8 + j] = h[j]
                    end

                    g = 6
                else
                    g = 11
                end
            end
        elseif g == 11 then
            e[6] = a.next
            e[7] = aa[3][1]
            e[9] = 'GetChildren'
            e[8] = e[7]
            e[7] = e[7][e[9] ]

            do
                local h = 1
                local i = pack(e[7](b(e, 8, 7 + h)))

                for j = 1, 2 do
                    e[7 + j - 1] = i[j]
                end
            end

            g = 16
        elseif g == 12 then
            e[13] = e[10]
            e[14] = 'Name'
            e[12] = e[13][e[14] ]
            e[13] = 'Section'
            e[11] = e[12] == e[13]

            if (not not e[11]) == true then
                g = 14
            else
                g = 13
            end
        elseif g == 13 then
            e[13] = e[10]
            e[14] = 'Name'
            e[12] = e[13][e[14] ]
            e[13] = 'MultiSection'
            e[11] = e[12] == e[13]
            g = 14
        elseif g == 14 then
            if (not not e[11]) == false then
                g = 16
            else
                g = 15
            end
        elseif g == 15 then
            e[12] = e[5]
            e[13] = 1
            e[11] = e[12] + e[13]
            e[5] = e[11]
            g = 16
        elseif g == 16 then
            do
                local h = pack(e[6](e[7], e[8]))
                local i = h[1]

                if i ~= nil then
                    e[8] = i

                    for j = 1, 2 do
                        e[8 + j] = h[j]
                    end

                    g = 12
                else
                    g = 17
                end
            end
        elseif g == 17 then
            e[7] = e[4]
            e[8] = e[5]
            e[6] = e[7] <= e[8]

            if (not not e[6]) == false then
                g = 19
            else
                g = 18
            end
        elseif g == 18 then
            e[6] = aa[2][1]
            e[3] = e[6]
            g = 20
        elseif g == 19 then
            e[6] = aa[3][1]
            e[3] = e[6]
            g = 20
        elseif g == 20 then
            e[5] = a.Instance
            e[6] = 'new'
            e[4] = e[5][e[6] ]
            e[5] = 'Frame'

            do
                local h = 1
                local i = pack(e[4](b(e, 5, 4 + h)))

                for j = 1, 1 do
                    e[4 + j - 1] = i[j]
                end
            end

            e[4] = {
                e[4],
            }
            e[5] = e[4][1]
            e[6] = 'Name'
            e[7] = 'MultiSection'
            e[5][e[6] ] = e[7]
            e[5] = e[4][1]
            e[6] = 'Parent'
            e[7] = e[3]
            e[5][e[6] ] = e[7]
            e[5] = e[4][1]
            e[6] = 'AnchorPoint'
            e[8] = a.Vector2
            e[9] = 'new'
            e[7] = e[8][e[9] ]
            e[8] = 0.5
            e[9] = 0

            do
                local h = 2
                local i = pack(e[7](b(e, 8, 7 + h)))

                for j = 1, 1 do
                    e[7 + j - 1] = i[j]
                end
            end

            e[5][e[6] ] = e[7]
            e[5] = e[4][1]
            e[6] = 'BackgroundColor3'
            e[8] = a.Color3
            e[9] = 'fromRGB'
            e[7] = e[8][e[9] ]
            e[8] = 30
            e[9] = 30
            e[10] = 30

            do
                local h = 3
                local i = pack(e[7](b(e, 8, 7 + h)))

                for j = 1, 1 do
                    e[7 + j - 1] = i[j]
                end
            end

            e[5][e[6] ] = e[7]
            e[5] = e[4][1]
            e[6] = 'BorderSizePixel'
            e[7] = 0
            e[5][e[6] ] = e[7]
            e[5] = e[4][1]
            e[6] = 'Size'
            e[8] = a.UDim2
            e[9] = 'new'
            e[7] = e[8][e[9] ]
            e[8] = 1
            e[10] = 2
            e[9] = -e[10]
            e[10] = 0
            e[11] = 50

            do
                local h = 4
                local i = pack(e[7](b(e, 8, 7 + h)))

                for j = 1, 1 do
                    e[7 + j - 1] = i[j]
                end
            end

            e[5][e[6] ] = e[7]
            e[5] = e[4][1]
            e[6] = 'ZIndex'
            e[7] = aa[1][1]
            e[5][e[6] ] = e[7]
            e[6] = a.Instance
            e[7] = 'new'
            e[5] = e[6][e[7] ]
            e[6] = 'ImageLabel'

            do
                local h = 1
                local i = pack(e[5](b(e, 6, 5 + h)))

                for j = 1, 1 do
                    e[5 + j - 1] = i[j]
                end
            end

            e[6] = e[5]
            e[7] = 'Parent'
            e[8] = e[4][1]
            e[6][e[7] ] = e[8]
            e[6] = e[5]
            e[7] = 'BackgroundTransparency'
            e[8] = 1
            e[6][e[7] ] = e[8]
            e[6] = e[5]
            e[7] = 'Size'
            e[9] = a.UDim2
            e[10] = 'new'
            e[8] = e[9][e[10] ]
            e[9] = 1
            e[10] = 0
            e[11] = 1
            e[12] = 0

            do
                local h = 4
                local i = pack(e[8](b(e, 9, 8 + h)))

                for j = 1, 1 do
                    e[8 + j - 1] = i[j]
                end
            end

            e[6][e[7] ] = e[8]
            e[6] = e[5]
            e[7] = 'Image'
            e[8] = 'rbxassetid://2592362371'
            e[6][e[7] ] = e[8]
            e[6] = e[5]
            e[7] = 'ImageColor3'
            e[9] = a.Color3
            e[10] = 'fromRGB'
            e[8] = e[9][e[10] ]
            e[9] = 0
            e[10] = 0
            e[11] = 0

            do
                local h = 3
                local i = pack(e[8](b(e, 9, 8 + h)))

                for j = 1, 1 do
                    e[8 + j - 1] = i[j]
                end
            end

            e[6][e[7] ] = e[8]
            e[6] = e[5]
            e[7] = 'ScaleType'
            e[10] = a.Enum
            e[11] = 'ScaleType'
            e[9] = e[10][e[11] ]
            e[10] = 'Slice'
            e[8] = e[9][e[10] ]
            e[6][e[7] ] = e[8]
            e[6] = e[5]
            e[7] = 'SliceCenter'
            e[9] = a.Rect
            e[10] = 'new'
            e[8] = e[9][e[10] ]
            e[9] = 2
            e[10] = 2
            e[11] = 62
            e[12] = 62

            do
                local h = 4
                local i = pack(e[8](b(e, 9, 8 + h)))

                for j = 1, 1 do
                    e[8 + j - 1] = i[j]
                end
            end

            e[6][e[7] ] = e[8]
            e[7] = a.Instance
            e[8] = 'new'
            e[6] = e[7][e[8] ]
            e[7] = 'ImageLabel'

            do
                local h = 1
                local i = pack(e[6](b(e, 7, 6 + h)))

                for j = 1, 1 do
                    e[6 + j - 1] = i[j]
                end
            end

            e[7] = e[6]
            e[8] = 'Parent'
            e[9] = e[4][1]
            e[7][e[8] ] = e[9]
            e[7] = e[6]
            e[8] = 'BackgroundTransparency'
            e[9] = 1
            e[7][e[8] ] = e[9]
            e[7] = e[6]
            e[8] = 'Position'
            e[10] = a.UDim2
            e[11] = 'new'
            e[9] = e[10][e[11] ]
            e[10] = 0
            e[11] = 1
            e[12] = 0
            e[13] = 1

            do
                local h = 4
                local i = pack(e[9](b(e, 10, 9 + h)))

                for j = 1, 1 do
                    e[9 + j - 1] = i[j]
                end
            end

            e[7][e[8] ] = e[9]
            e[7] = e[6]
            e[8] = 'Size'
            e[10] = a.UDim2
            e[11] = 'new'
            e[9] = e[10][e[11] ]
            e[10] = 1
            e[12] = 2
            e[11] = -e[12]
            e[12] = 1
            e[14] = 2
            e[13] = -e[14]

            do
                local h = 4
                local i = pack(e[9](b(e, 10, 9 + h)))

                for j = 1, 1 do
                    e[9 + j - 1] = i[j]
                end
            end

            e[7][e[8] ] = e[9]
            e[7] = e[6]
            e[8] = 'Image'
            e[9] = 'rbxassetid://2592362371'
            e[7][e[8] ] = e[9]
            e[7] = e[6]
            e[8] = 'ImageColor3'
            e[10] = a.Color3
            e[11] = 'fromRGB'
            e[9] = e[10][e[11] ]
            e[10] = 60
            e[11] = 60
            e[12] = 60

            do
                local h = 3
                local i = pack(e[9](b(e, 10, 9 + h)))

                for j = 1, 1 do
                    e[9 + j - 1] = i[j]
                end
            end

            e[7][e[8] ] = e[9]
            e[7] = e[6]
            e[8] = 'ScaleType'
            e[11] = a.Enum
            e[12] = 'ScaleType'
            e[10] = e[11][e[12] ]
            e[11] = 'Slice'
            e[9] = e[10][e[11] ]
            e[7][e[8] ] = e[9]
            e[7] = e[6]
            e[8] = 'SliceCenter'
            e[10] = a.Rect
            e[11] = 'new'
            e[9] = e[10][e[11] ]
            e[10] = 2
            e[11] = 2
            e[12] = 62
            e[13] = 62

            do
                local h = 4
                local i = pack(e[9](b(e, 10, 9 + h)))

                for j = 1, 1 do
                    e[9 + j - 1] = i[j]
                end
            end

            e[7][e[8] ] = e[9]
            e[8] = a.Instance
            e[9] = 'new'
            e[7] = e[8][e[9] ]
            e[8] = 'Frame'

            do
                local h = 1
                local i = pack(e[7](b(e, 8, 7 + h)))

                for j = 1, 1 do
                    e[7 + j - 1] = i[j]
                end
            end

            e[8] = e[7]
            e[9] = 'Parent'
            e[10] = e[4][1]
            e[8][e[9] ] = e[10]
            e[8] = e[7]
            e[9] = 'BackgroundTransparency'
            e[10] = 1
            e[8][e[9] ] = e[10]
            e[8] = e[7]
            e[9] = 'Position'
            e[11] = a.UDim2
            e[12] = 'new'
            e[10] = e[11][e[12] ]
            e[11] = 0
            e[12] = 6
            e[13] = 0
            e[14] = 4

            do
                local h = 4
                local i = pack(e[10](b(e, 11, 10 + h)))

                for j = 1, 1 do
                    e[10 + j - 1] = i[j]
                end
            end

            e[8][e[9] ] = e[10]
            e[8] = e[7]
            e[9] = 'Size'
            e[11] = a.UDim2
            e[12] = 'new'
            e[10] = e[11][e[12] ]
            e[11] = 1
            e[13] = 12
            e[12] = -e[13]
            e[13] = 0
            e[14] = 22

            do
                local h = 4
                local i = pack(e[10](b(e, 11, 10 + h)))

                for j = 1, 1 do
                    e[10 + j - 1] = i[j]
                end
            end

            e[8][e[9] ] = e[10]
            e[9] = a.Instance
            e[10] = 'new'
            e[8] = e[9][e[10] ]
            e[9] = 'UIListLayout'

            do
                local h = 1
                local i = pack(e[8](b(e, 9, 8 + h)))

                for j = 1, 1 do
                    e[8 + j - 1] = i[j]
                end
            end

            e[9] = e[8]
            e[10] = 'Parent'
            e[11] = e[7]
            e[9][e[10] ] = e[11]
            e[9] = e[8]
            e[10] = 'FillDirection'
            e[13] = a.Enum
            e[14] = 'FillDirection'
            e[12] = e[13][e[14] ]
            e[13] = 'Horizontal'
            e[11] = e[12][e[13] ]
            e[9][e[10] ] = e[11]
            e[9] = e[8]
            e[10] = 'SortOrder'
            e[13] = a.Enum
            e[14] = 'SortOrder'
            e[12] = e[13][e[14] ]
            e[13] = 'LayoutOrder'
            e[11] = e[12][e[13] ]
            e[9][e[10] ] = e[11]
            e[9] = e[8]
            e[10] = 'Padding'
            e[12] = a.UDim
            e[13] = 'new'
            e[11] = e[12][e[13] ]
            e[12] = 0
            e[13] = 2

            do
                local h = 2
                local i = pack(e[11](b(e, 12, 11 + h)))

                for j = 1, 1 do
                    e[11 + j - 1] = i[j]
                end
            end

            e[9][e[10] ] = e[11]
            e[10] = a.Instance
            e[11] = 'new'
            e[9] = e[10][e[11] ]
            e[10] = 'Frame'

            do
                local h = 1
                local i = pack(e[9](b(e, 10, 9 + h)))

                for j = 1, 1 do
                    e[9 + j - 1] = i[j]
                end
            end

            e[9] = {
                e[9],
            }
            e[10] = e[9][1]
            e[11] = 'Parent'
            e[12] = e[4][1]
            e[10][e[11] ] = e[12]
            e[10] = e[9][1]
            e[11] = 'BackgroundTransparency'
            e[12] = 1
            e[10][e[11] ] = e[12]
            e[10] = e[9][1]
            e[11] = 'Position'
            e[13] = a.UDim2
            e[14] = 'new'
            e[12] = e[13][e[14] ]
            e[13] = 0.5
            e[14] = 0
            e[15] = 0
            e[16] = 28

            do
                local h = 4
                local i = pack(e[12](b(e, 13, 12 + h)))

                for j = 1, 1 do
                    e[12 + j - 1] = i[j]
                end
            end

            e[10][e[11] ] = e[12]
            e[10] = e[9][1]
            e[11] = 'AnchorPoint'
            e[13] = a.Vector2
            e[14] = 'new'
            e[12] = e[13][e[14] ]
            e[13] = 0.5
            e[14] = 0

            do
                local h = 2
                local i = pack(e[12](b(e, 13, 12 + h)))

                for j = 1, 1 do
                    e[12 + j - 1] = i[j]
                end
            end

            e[10][e[11] ] = e[12]
            e[10] = e[9][1]
            e[11] = 'Size'
            e[13] = a.UDim2
            e[14] = 'new'
            e[12] = e[13][e[14] ]
            e[13] = 1
            e[15] = 16
            e[14] = -e[15]
            e[15] = 0
            e[16] = 0

            do
                local h = 4
                local i = pack(e[12](b(e, 13, 12 + h)))

                for j = 1, 1 do
                    e[12 + j - 1] = i[j]
                end
            end

            e[10][e[11] ] = e[12]
            e[10] = {}
            e[11] = {}
            e[10] = {
                e[10],
            }
            e[11] = {
                e[11],
            }
            e[12] = {}

            for h = 13, 13 do
                e[h] = nil
            end

            e[13] = {
                e[13],
            }
            e[14] = function(...)
                return d.p088({
                    e[10],
                    e[9],
                    e[4],
                    aa[2],
                    aa[4],
                    aa[3],
                    aa[5],
                }, ...)
            end
            e[13][1] = e[14]
            e[14] = a.ipairs
            e[15] = e[1]

            do
                local h = 1
                local i = pack(e[14](b(e, 15, 14 + h)))

                for j = 1, 3 do
                    e[14 + j - 1] = i[j]
                end
            end

            g = 30
        elseif g == 21 then
            e[19] = {
                e[17],
            }
            e[21] = a.Instance
            e[22] = 'new'
            e[20] = e[21][e[22] ]
            e[21] = 'Frame'

            do
                local h = 1
                local i = pack(e[20](b(e, 21, 20 + h)))

                for j = 1, 1 do
                    e[20 + j - 1] = i[j]
                end
            end

            e[20] = {
                e[20],
            }
            e[21] = e[20][1]
            e[22] = 'Name'
            e[24] = 'Page_'
            e[25] = e[18]
            e[23] = e[24] .. e[25]
            e[21][e[22] ] = e[23]
            e[21] = e[20][1]
            e[22] = 'Parent'
            e[23] = e[9][1]
            e[21][e[22] ] = e[23]
            e[21] = e[20][1]
            e[22] = 'BackgroundTransparency'
            e[23] = 1
            e[21][e[22] ] = e[23]
            e[21] = e[20][1]
            e[22] = 'Size'
            e[24] = a.UDim2
            e[25] = 'new'
            e[23] = e[24][e[25] ]
            e[24] = 1
            e[25] = 0
            e[26] = 0
            e[27] = 0

            do
                local h = 4
                local i = pack(e[23](b(e, 24, 23 + h)))

                for j = 1, 1 do
                    e[23 + j - 1] = i[j]
                end
            end

            e[21][e[22] ] = e[23]
            e[21] = e[20][1]
            e[22] = 'Visible'
            e[24] = e[19][1]
            e[25] = 1
            e[23] = e[24] == e[25]
            e[21][e[22] ] = e[23]
            e[22] = a.Instance
            e[23] = 'new'
            e[21] = e[22][e[23] ]
            e[22] = 'UIListLayout'

            do
                local h = 1
                local i = pack(e[21](b(e, 22, 21 + h)))

                for j = 1, 1 do
                    e[21 + j - 1] = i[j]
                end
            end

            e[21] = {
                e[21],
            }
            e[22] = e[21][1]
            e[23] = 'Parent'
            e[24] = e[20][1]
            e[22][e[23] ] = e[24]
            e[22] = e[21][1]
            e[23] = 'SortOrder'
            e[26] = a.Enum
            e[27] = 'SortOrder'
            e[25] = e[26][e[27] ]
            e[26] = 'LayoutOrder'
            e[24] = e[25][e[26] ]
            e[22][e[23] ] = e[24]
            e[22] = e[21][1]
            e[23] = 'Padding'
            e[25] = a.UDim
            e[26] = 'new'
            e[24] = e[25][e[26] ]
            e[25] = 0
            e[26] = 5

            do
                local h = 2
                local i = pack(e[24](b(e, 25, 24 + h)))

                for j = 1, 1 do
                    e[24 + j - 1] = i[j]
                end
            end

            e[22][e[23] ] = e[24]
            e[22] = e[21][1]
            e[24] = 'GetPropertyChangedSignal'
            e[23] = e[22]
            e[22] = e[22][e[24] ]
            e[24] = 'AbsoluteContentSize'

            do
                local h = 2
                local i = pack(e[22](b(e, 23, 22 + h)))

                for j = 1, 1 do
                    e[22 + j - 1] = i[j]
                end
            end

            e[24] = 'Connect'
            e[23] = e[22]
            e[22] = e[22][e[24] ]
            e[24] = function(...)
                return d.p089({
                    e[20],
                    e[21],
                    e[13],
                }, ...)
            end

            do
                local h = 2

                e[22](b(e, 23, 22 + h))
            end

            e[23] = a.Instance
            e[24] = 'new'
            e[22] = e[23][e[24] ]
            e[23] = 'TextButton'

            do
                local h = 1
                local i = pack(e[22](b(e, 23, 22 + h)))

                for j = 1, 1 do
                    e[22 + j - 1] = i[j]
                end
            end

            e[23] = e[22]
            e[24] = 'Parent'
            e[25] = e[7]
            e[23][e[24] ] = e[25]
            e[23] = e[22]
            e[24] = 'BackgroundColor3'
            e[26] = e[19][1]
            e[27] = 1
            e[25] = e[26] == e[27]

            if (not not e[25]) == false then
                g = 23
            else
                g = 22
            end
        elseif g == 22 then
            e[26] = a.Color3
            e[27] = 'fromRGB'
            e[25] = e[26][e[27] ]
            e[26] = 38
            e[27] = 38
            e[28] = 38

            do
                local h = 3
                local i = pack(e[25](b(e, 26, 25 + h)))

                for j = 1, 1 do
                    e[25 + j - 1] = i[j]
                end
            end

            g = 23
        elseif g == 23 then
            if (not not e[25]) == true then
                g = 25
            else
                g = 24
            end
        elseif g == 24 then
            e[26] = a.Color3
            e[27] = 'fromRGB'
            e[25] = e[26][e[27] ]
            e[26] = 28
            e[27] = 28
            e[28] = 28

            do
                local h = 3
                local i = pack(e[25](b(e, 26, 25 + h)))

                for j = 1, 1 do
                    e[25 + j - 1] = i[j]
                end
            end

            g = 25
        elseif g == 25 then
            e[23][e[24] ] = e[25]
            e[23] = e[22]
            e[24] = 'BorderSizePixel'
            e[25] = 0
            e[23][e[24] ] = e[25]
            e[23] = e[22]
            e[24] = 'Size'
            e[26] = a.UDim2
            e[27] = 'new'
            e[25] = e[26][e[27] ]
            e[26] = 0
            e[27] = 0
            e[28] = 1
            e[29] = 0

            do
                local h = 4
                local i = pack(e[25](b(e, 26, 25 + h)))

                for j = 1, 1 do
                    e[25 + j - 1] = i[j]
                end
            end

            e[23][e[24] ] = e[25]
            e[23] = e[22]
            e[24] = 'AutomaticSize'
            e[27] = a.Enum
            e[28] = 'AutomaticSize'
            e[26] = e[27][e[28] ]
            e[27] = 'X'
            e[25] = e[26][e[27] ]
            e[23][e[24] ] = e[25]
            e[23] = e[22]
            e[24] = 'AutoButtonColor'
            e[25] = false
            e[23][e[24] ] = e[25]
            e[23] = e[22]
            e[24] = 'Font'
            e[27] = a.Enum
            e[28] = 'Font'
            e[26] = e[27][e[28] ]
            e[27] = 'Code'
            e[25] = e[26][e[27] ]
            e[23][e[24] ] = e[25]
            e[23] = e[22]
            e[24] = 'Text'
            e[26] = '  '
            e[28] = e[18]
            e[29] = '  '
            e[27] = e[28] .. e[29]
            e[25] = e[26] .. e[27]
            e[23][e[24] ] = e[25]
            e[23] = e[22]
            e[24] = 'TextColor3'
            e[26] = e[19][1]
            e[27] = 1
            e[25] = e[26] == e[27]

            if (not not e[25]) == false then
                g = 27
            else
                g = 26
            end
        elseif g == 26 then
            e[26] = a.Color3
            e[27] = 'fromRGB'
            e[25] = e[26][e[27] ]
            e[26] = 230
            e[27] = 230
            e[28] = 230

            do
                local h = 3
                local i = pack(e[25](b(e, 26, 25 + h)))

                for j = 1, 1 do
                    e[25 + j - 1] = i[j]
                end
            end

            g = 27
        elseif g == 27 then
            if (not not e[25]) == true then
                g = 29
            else
                g = 28
            end
        elseif g == 28 then
            e[26] = a.Color3
            e[27] = 'fromRGB'
            e[25] = e[26][e[27] ]
            e[26] = 150
            e[27] = 150
            e[28] = 150

            do
                local h = 3
                local i = pack(e[25](b(e, 26, 25 + h)))

                for j = 1, 1 do
                    e[25 + j - 1] = i[j]
                end
            end

            g = 29
        elseif g == 29 then
            e[23][e[24] ] = e[25]
            e[23] = e[22]
            e[24] = 'TextSize'
            e[25] = 13
            e[23][e[24] ] = e[25]
            e[24] = a.Instance
            e[25] = 'new'
            e[23] = e[24][e[25] ]
            e[24] = 'Frame'

            do
                local h = 1
                local i = pack(e[23](b(e, 24, 23 + h)))

                for j = 1, 1 do
                    e[23 + j - 1] = i[j]
                end
            end

            e[23] = {
                e[23],
            }
            e[24] = e[23][1]
            e[25] = 'Parent'
            e[26] = e[22]
            e[24][e[25] ] = e[26]
            e[24] = e[23][1]
            e[25] = 'BackgroundColor3'
            e[27] = aa[6][1]
            e[28] = 'accentclr'
            e[26] = e[27][e[28] ]
            e[24][e[25] ] = e[26]
            e[24] = e[23][1]
            e[25] = 'BorderSizePixel'
            e[26] = 0
            e[24][e[25] ] = e[26]
            e[24] = e[23][1]
            e[25] = 'Position'
            e[27] = a.UDim2
            e[28] = 'new'
            e[26] = e[27][e[28] ]
            e[27] = 0
            e[28] = 0
            e[29] = 1
            e[31] = 2
            e[30] = -e[31]

            do
                local h = 4
                local i = pack(e[26](b(e, 27, 26 + h)))

                for j = 1, 1 do
                    e[26 + j - 1] = i[j]
                end
            end

            e[24][e[25] ] = e[26]
            e[24] = e[23][1]
            e[25] = 'Size'
            e[27] = a.UDim2
            e[28] = 'new'
            e[26] = e[27][e[28] ]
            e[27] = 1
            e[28] = 0
            e[29] = 0
            e[30] = 2

            do
                local h = 4
                local i = pack(e[26](b(e, 27, 26 + h)))

                for j = 1, 1 do
                    e[26 + j - 1] = i[j]
                end
            end

            e[24][e[25] ] = e[26]
            e[24] = e[23][1]
            e[25] = 'Visible'
            e[27] = e[19][1]
            e[28] = 1
            e[26] = e[27] == e[28]
            e[24][e[25] ] = e[26]
            e[25] = a.table
            e[26] = 'insert'
            e[24] = e[25][e[26] ]
            e[25] = e[10][1]
            e[26] = e[20][1]

            do
                local h = 2

                e[24](b(e, 25, 24 + h))
            end

            e[25] = a.table
            e[26] = 'insert'
            e[24] = e[25][e[26] ]
            e[25] = e[11][1]
            e[26] = {}
            e[27] = '_154_244'
            e[28] = e[22]
            e[26][e[27] ] = e[28]
            e[27] = 'v49110'
            e[28] = e[23][1]
            e[26][e[27] ] = e[28]
            e[27] = 'a18b56c86'
            e[28] = e[20][1]
            e[26][e[27] ] = e[28]

            do
                local h = 2

                e[24](b(e, 25, 24 + h))
            end

            e[25] = e[22]
            e[26] = 'MouseButton1Click'
            e[24] = e[25][e[26] ]
            e[26] = 'Connect'
            e[25] = e[24]
            e[24] = e[24][e[26] ]
            e[26] = function(...)
                return d.p090({
                    e[11],
                    e[19],
                    e[13],
                }, ...)
            end

            do
                local h = 2

                e[24](b(e, 25, 24 + h))
            end

            e[25] = a.coroutine
            e[26] = 'wrap'
            e[24] = e[25][e[26] ]
            e[25] = function(...)
                return d.p091({
                    e[23],
                    aa[6],
                }, ...)
            end

            do
                local h = 1
                local i = pack(e[24](b(e, 25, 24 + h)))

                for j = 1, 1 do
                    e[24 + j - 1] = i[j]
                end
            end
            do
                local h = 0

                e[24](b(e, 25, 24 + h))
            end

            for h = 24, 24 do
                e[h] = nil
            end

            e[24] = {
                e[24],
            }
            e[25] = function(...)
                return d.p092({
                    e[20],
                    e[21],
                    e[13],
                }, ...)
            end
            e[24][1] = e[25]
            e[25] = {}
            e[26] = function(...)
                return d.create_multi_toggle({
                    e[20],
                    aa[6],
                    e[24],
                }, ...)
            end
            e[27] = e[25]
            e[28] = 'Toggle'
            e[27][e[28] ] = e[26]
            e[26] = function(...)
                return d.create_multi_slider({
                    e[20],
                    aa[6],
                    e[24],
                }, ...)
            end
            e[27] = e[25]
            e[28] = 'Slider'
            e[27][e[28] ] = e[26]
            e[26] = function(...)
                return d.create_multi_label({
                    e[20],
                    e[24],
                }, ...)
            end
            e[27] = e[25]
            e[28] = 'Label'
            e[27][e[28] ] = e[26]
            e[26] = e[12]
            e[27] = e[18]
            e[28] = e[25]
            e[26][e[27] ] = e[28]
            g = 30
        elseif g == 30 then
            do
                local h = pack(e[14](e[15], e[16]))
                local i = h[1]

                if i ~= nil then
                    e[16] = i

                    for j = 1, 2 do
                        e[16 + j] = h[j]
                    end

                    g = 21
                else
                    g = 31
                end
            end
        elseif g == 31 then
            e[15] = a.task
            e[16] = 'defer'
            e[14] = e[15][e[16] ]
            e[15] = e[13][1]

            do
                local h = 1

                e[14](b(e, 15, 14 + h))
            end

            e[14] = e[12]

            local h = 1

            return b(e, 14, 14 + h - 1)
        else
            return
        end
    end
end
d.p086 = function(aa, e, f)
    aa[1][1].Text = f

    return
end
d.create_label = function(aa, e, f)
    local g, h = {}, a.Instance.new'TextLabel'
    local i = {h}

    i[1].Name = 'Label'
    i[1].Parent = aa[1][1]
    i[1].BackgroundTransparency = 1

    local j = a.UDim2.new(1, 0, 0, 18)

    i[1].Size = j
    i[1].Font = a.Enum.Font.Code
    i[1].Text = f

    local k = a.Color3.fromRGB(230, 230, 230)

    i[1].TextColor3 = k
    i[1].TextSize = 14
    i[1].TextXAlignment = a.Enum.TextXAlignment.Left

    aa[2][1]()

    g.Change = function(...)
        return d.p086({i}, ...)
    end

    return g
end
d.p084 = function(aa, e, f)
    local g = a.tostring(f)

    aa[1][1].Text = g
    aa[2][1] = f

    a.pcall(aa[3][1], f)

    return
end
d.p083 = function(aa, ...)
    while a.task.wait() do
        aa[1][1].BorderColor3 = aa[2][1].accentclr
    end
end
d.p082 = function(aa, ...)
    while a.task.wait() do
        local e = a.typeof(aa[1][1]) == 'string' and aa[1][1] == aa[2][1]

        aa[3][1].BackgroundTransparency = 1
        aa[3][1].TextTransparency = e and 0 or 1
        aa[4][1].TextTransparency = e and 1 or 0
        aa[4][1].BackgroundTransparency = e and 0 or 1
        aa[4][1].BorderColor3 = aa[5][1].accentclr
    end
end
d.p081 = function(aa)
    aa[1][1].Visible = false
    aa[2][1].Text = aa[3][1]
    aa[4][1] = aa[3][1]

    a.pcall(aa[5][1], aa[3][1])

    return
end
d.p080 = function(aa, ...)
    local e, f, g = aa[1][1], aa[2][1], aa[3][1]

    if not e.Visible then
        for h, i in a.next, f.dropdownframes do
            if i.Name == 'DropdownHolderFrame' then
                i.Visible = false
            end
        end
        for h, i in a.next, f.dropdownframes do
            if i.Name == 'Dropdown' then
                i.DropdownFrame.DropdownArrow.Rotation = 0
            end
        end

        g.Rotation = 180
        e.Visible = true
    else
        g.Rotation = 0
        e.Visible = false
    end
end
d.create_dropdown = function(aa, ...)
    local e, f = {}, pack(...)

    for g = 1, 5 do
        e[g - 1] = f[g]
    end

    local g, h = 0, 1

    while true do
        if h == 1 then
            e[3] = {
                e[3],
            }
            e[4] = {
                e[4],
            }
            e[6] = a.typeof
            e[7] = e[3][1]

            do
                local i = 1
                local j = pack(e[6](b(e, 7, 6 + i)))

                for k = 1, 1 do
                    e[6 + k - 1] = j[k]
                end
            end

            e[7] = 'string'
            e[5] = e[6] == e[7]

            if (not not e[5]) == false then
                h = 3
            else
                h = 2
            end
        elseif h == 2 then
            e[5] = e[3][1]
            h = 3
        elseif h == 3 then
            e[3][1] = e[5]
            e[6] = e[3][1]
            e[7] = ''
            e[5] = e[6] == e[7]

            if (not not e[5]) == false then
                h = 5
            else
                h = 4
            end
        elseif h == 4 then
            for i = 5, 5 do
                e[i] = nil
            end

            e[3][1] = e[5]
            h = 5
        elseif h == 5 then
            e[6] = a.Instance
            e[7] = 'new'
            e[5] = e[6][e[7] ]
            e[6] = 'Frame'

            do
                local i = 1
                local j = pack(e[5](b(e, 6, 5 + i)))

                for k = 1, 1 do
                    e[5 + k - 1] = j[k]
                end
            end

            e[7] = a.Instance
            e[8] = 'new'
            e[6] = e[7][e[8] ]
            e[7] = 'TextLabel'

            do
                local i = 1
                local j = pack(e[6](b(e, 7, 6 + i)))

                for k = 1, 1 do
                    e[6 + k - 1] = j[k]
                end
            end

            e[8] = a.Instance
            e[9] = 'new'
            e[7] = e[8][e[9] ]
            e[8] = 'TextButton'

            do
                local i = 1
                local j = pack(e[7](b(e, 8, 7 + i)))

                for k = 1, 1 do
                    e[7 + k - 1] = j[k]
                end
            end

            e[7] = {
                e[7],
            }
            e[9] = a.Instance
            e[10] = 'new'
            e[8] = e[9][e[10] ]
            e[9] = 'ImageLabel'

            do
                local i = 1
                local j = pack(e[8](b(e, 9, 8 + i)))

                for k = 1, 1 do
                    e[8 + k - 1] = j[k]
                end
            end

            e[10] = a.Instance
            e[11] = 'new'
            e[9] = e[10][e[11] ]
            e[10] = 'ImageLabel'

            do
                local i = 1
                local j = pack(e[9](b(e, 10, 9 + i)))

                for k = 1, 1 do
                    e[9 + k - 1] = j[k]
                end
            end

            e[11] = a.Instance
            e[12] = 'new'
            e[10] = e[11][e[12] ]
            e[11] = 'TextLabel'

            do
                local i = 1
                local j = pack(e[10](b(e, 11, 10 + i)))

                for k = 1, 1 do
                    e[10 + k - 1] = j[k]
                end
            end

            e[10] = {
                e[10],
            }
            e[12] = a.Instance
            e[13] = 'new'
            e[11] = e[12][e[13] ]
            e[12] = 'ImageLabel'

            do
                local i = 1
                local j = pack(e[11](b(e, 12, 11 + i)))

                for k = 1, 1 do
                    e[11 + k - 1] = j[k]
                end
            end

            e[11] = {
                e[11],
            }
            e[12] = e[5]
            e[13] = 'Name'
            e[14] = 'Dropdown'
            e[12][e[13] ] = e[14]
            e[12] = e[5]
            e[13] = 'Parent'
            e[14] = aa[1][1]
            e[12][e[13] ] = e[14]
            e[12] = e[5]
            e[13] = 'BackgroundTransparency'
            e[14] = 1
            e[12][e[13] ] = e[14]
            e[12] = e[5]
            e[13] = 'Size'
            e[15] = a.UDim2
            e[16] = 'new'
            e[14] = e[15][e[16] ]
            e[15] = 1
            e[16] = 0
            e[17] = 0
            e[18] = 37

            do
                local i = 4
                local j = pack(e[14](b(e, 15, 14 + i)))

                for k = 1, 1 do
                    e[14 + k - 1] = j[k]
                end
            end

            e[12][e[13] ] = e[14]
            e[12] = e[6]
            e[13] = 'Name'
            e[14] = 'DropdownTitle'
            e[12][e[13] ] = e[14]
            e[12] = e[6]
            e[13] = 'Parent'
            e[14] = e[5]
            e[12][e[13] ] = e[14]
            e[12] = e[6]
            e[13] = 'BackgroundTransparency'
            e[14] = 1
            e[12][e[13] ] = e[14]
            e[12] = e[6]
            e[13] = 'Size'
            e[15] = a.UDim2
            e[16] = 'new'
            e[14] = e[15][e[16] ]
            e[15] = 0
            e[16] = 0
            e[17] = 0
            e[18] = 13

            do
                local i = 4
                local j = pack(e[14](b(e, 15, 14 + i)))

                for k = 1, 1 do
                    e[14 + k - 1] = j[k]
                end
            end

            e[12][e[13] ] = e[14]
            e[12] = e[6]
            e[13] = 'Font'
            e[16] = a.Enum
            e[17] = 'Font'
            e[15] = e[16][e[17] ]
            e[16] = 'Code'
            e[14] = e[15][e[16] ]
            e[12][e[13] ] = e[14]
            e[12] = e[6]
            e[13] = 'Text'
            e[14] = e[1]
            e[12][e[13] ] = e[14]
            e[12] = e[6]
            e[13] = 'TextColor3'
            e[15] = a.Color3
            e[16] = 'fromRGB'
            e[14] = e[15][e[16] ]
            e[15] = 230
            e[16] = 230
            e[17] = 230

            do
                local i = 3
                local j = pack(e[14](b(e, 15, 14 + i)))

                for k = 1, 1 do
                    e[14 + k - 1] = j[k]
                end
            end

            e[12][e[13] ] = e[14]
            e[12] = e[6]
            e[13] = 'TextSize'
            e[14] = 14
            e[12][e[13] ] = e[14]
            e[12] = e[6]
            e[13] = 'TextXAlignment'
            e[16] = a.Enum
            e[17] = 'TextXAlignment'
            e[15] = e[16][e[17] ]
            e[16] = 'Left'
            e[14] = e[15][e[16] ]
            e[12][e[13] ] = e[14]
            e[12] = e[7][1]
            e[13] = 'Name'
            e[14] = 'DropdownFrame'
            e[12][e[13] ] = e[14]
            e[12] = e[7][1]
            e[13] = 'Parent'
            e[14] = e[5]
            e[12][e[13] ] = e[14]
            e[12] = e[7][1]
            e[13] = 'BackgroundColor3'
            e[15] = a.Color3
            e[16] = 'fromRGB'
            e[14] = e[15][e[16] ]
            e[15] = 38
            e[16] = 38
            e[17] = 38

            do
                local i = 3
                local j = pack(e[14](b(e, 15, 14 + i)))

                for k = 1, 1 do
                    e[14 + k - 1] = j[k]
                end
            end

            e[12][e[13] ] = e[14]
            e[12] = e[7][1]
            e[13] = 'BorderSizePixel'
            e[14] = 0
            e[12][e[13] ] = e[14]
            e[12] = e[7][1]
            e[13] = 'Position'
            e[15] = a.UDim2
            e[16] = 'new'
            e[14] = e[15][e[16] ]
            e[15] = 0
            e[16] = 0
            e[17] = 1
            e[19] = 20
            e[18] = -e[19]

            do
                local i = 4
                local j = pack(e[14](b(e, 15, 14 + i)))

                for k = 1, 1 do
                    e[14 + k - 1] = j[k]
                end
            end

            e[12][e[13] ] = e[14]
            e[12] = e[7][1]
            e[13] = 'Size'
            e[15] = a.UDim2
            e[16] = 'new'
            e[14] = e[15][e[16] ]
            e[15] = 1
            e[16] = 0
            e[17] = 0
            e[18] = 20

            do
                local i = 4
                local j = pack(e[14](b(e, 15, 14 + i)))

                for k = 1, 1 do
                    e[14 + k - 1] = j[k]
                end
            end

            e[12][e[13] ] = e[14]
            e[12] = e[7][1]
            e[13] = 'Text'
            e[14] = ''
            e[12][e[13] ] = e[14]
            e[12] = e[7][1]
            e[13] = 'AutoButtonColor'
            e[14] = false
            e[12][e[13] ] = e[14]
            e[12] = e[8]
            e[13] = 'Parent'
            e[14] = e[7][1]
            e[12][e[13] ] = e[14]
            e[12] = e[8]
            e[13] = 'BackgroundTransparency'
            e[14] = 1
            e[12][e[13] ] = e[14]
            e[12] = e[8]
            e[13] = 'Size'
            e[15] = a.UDim2
            e[16] = 'new'
            e[14] = e[15][e[16] ]
            e[15] = 1
            e[16] = 0
            e[17] = 1
            e[18] = 0

            do
                local i = 4
                local j = pack(e[14](b(e, 15, 14 + i)))

                for k = 1, 1 do
                    e[14 + k - 1] = j[k]
                end
            end

            e[12][e[13] ] = e[14]
            e[12] = e[8]
            e[13] = 'Image'
            e[14] = 'rbxassetid://2592362371'
            e[12][e[13] ] = e[14]
            e[12] = e[8]
            e[13] = 'ImageColor3'
            e[15] = a.Color3
            e[16] = 'fromRGB'
            e[14] = e[15][e[16] ]
            e[15] = 60
            e[16] = 60
            e[17] = 60

            do
                local i = 3
                local j = pack(e[14](b(e, 15, 14 + i)))

                for k = 1, 1 do
                    e[14 + k - 1] = j[k]
                end
            end

            e[12][e[13] ] = e[14]
            e[12] = e[8]
            e[13] = 'ScaleType'
            e[16] = a.Enum
            e[17] = 'ScaleType'
            e[15] = e[16][e[17] ]
            e[16] = 'Slice'
            e[14] = e[15][e[16] ]
            e[12][e[13] ] = e[14]
            e[12] = e[8]
            e[13] = 'SliceCenter'
            e[15] = a.Rect
            e[16] = 'new'
            e[14] = e[15][e[16] ]
            e[15] = 2
            e[16] = 2
            e[17] = 62
            e[18] = 62

            do
                local i = 4
                local j = pack(e[14](b(e, 15, 14 + i)))

                for k = 1, 1 do
                    e[14 + k - 1] = j[k]
                end
            end

            e[12][e[13] ] = e[14]
            e[12] = e[9]
            e[13] = 'Parent'
            e[14] = e[7][1]
            e[12][e[13] ] = e[14]
            e[12] = e[9]
            e[13] = 'BackgroundTransparency'
            e[14] = 1
            e[12][e[13] ] = e[14]
            e[12] = e[9]
            e[13] = 'Position'
            e[15] = a.UDim2
            e[16] = 'new'
            e[14] = e[15][e[16] ]
            e[15] = 0
            e[16] = 1
            e[17] = 0
            e[18] = 1

            do
                local i = 4
                local j = pack(e[14](b(e, 15, 14 + i)))

                for k = 1, 1 do
                    e[14 + k - 1] = j[k]
                end
            end

            e[12][e[13] ] = e[14]
            e[12] = e[9]
            e[13] = 'Size'
            e[15] = a.UDim2
            e[16] = 'new'
            e[14] = e[15][e[16] ]
            e[15] = 1
            e[17] = 2
            e[16] = -e[17]
            e[17] = 1
            e[19] = 2
            e[18] = -e[19]

            do
                local i = 4
                local j = pack(e[14](b(e, 15, 14 + i)))

                for k = 1, 1 do
                    e[14 + k - 1] = j[k]
                end
            end

            e[12][e[13] ] = e[14]
            e[12] = e[9]
            e[13] = 'Image'
            e[14] = 'rbxassetid://2592362371'
            e[12][e[13] ] = e[14]
            e[12] = e[9]
            e[13] = 'ImageColor3'
            e[15] = a.Color3
            e[16] = 'fromRGB'
            e[14] = e[15][e[16] ]
            e[15] = 0
            e[16] = 0
            e[17] = 0

            do
                local i = 3
                local j = pack(e[14](b(e, 15, 14 + i)))

                for k = 1, 1 do
                    e[14 + k - 1] = j[k]
                end
            end

            e[12][e[13] ] = e[14]
            e[12] = e[9]
            e[13] = 'ScaleType'
            e[16] = a.Enum
            e[17] = 'ScaleType'
            e[15] = e[16][e[17] ]
            e[16] = 'Slice'
            e[14] = e[15][e[16] ]
            e[12][e[13] ] = e[14]
            e[12] = e[9]
            e[13] = 'SliceCenter'
            e[15] = a.Rect
            e[16] = 'new'
            e[14] = e[15][e[16] ]
            e[15] = 2
            e[16] = 2
            e[17] = 62
            e[18] = 62

            do
                local i = 4
                local j = pack(e[14](b(e, 15, 14 + i)))

                for k = 1, 1 do
                    e[14 + k - 1] = j[k]
                end
            end

            e[12][e[13] ] = e[14]
            e[12] = e[10][1]
            e[13] = 'Name'
            e[14] = 'DropdownText'
            e[12][e[13] ] = e[14]
            e[12] = e[10][1]
            e[13] = 'Parent'
            e[14] = e[7][1]
            e[12][e[13] ] = e[14]
            e[12] = e[10][1]
            e[13] = 'BackgroundTransparency'
            e[14] = 1
            e[12][e[13] ] = e[14]
            e[12] = e[10][1]
            e[13] = 'Position'
            e[15] = a.UDim2
            e[16] = 'new'
            e[14] = e[15][e[16] ]
            e[15] = 0
            e[16] = 5
            e[17] = 0
            e[18] = 0

            do
                local i = 4
                local j = pack(e[14](b(e, 15, 14 + i)))

                for k = 1, 1 do
                    e[14 + k - 1] = j[k]
                end
            end

            e[12][e[13] ] = e[14]
            e[12] = e[10][1]
            e[13] = 'Size'
            e[15] = a.UDim2
            e[16] = 'new'
            e[14] = e[15][e[16] ]
            e[15] = 1
            e[17] = 5
            e[16] = -e[17]
            e[17] = 1
            e[18] = 0

            do
                local i = 4
                local j = pack(e[14](b(e, 15, 14 + i)))

                for k = 1, 1 do
                    e[14 + k - 1] = j[k]
                end
            end

            e[12][e[13] ] = e[14]
            e[12] = e[10][1]
            e[13] = 'Font'
            e[16] = a.Enum
            e[17] = 'Font'
            e[15] = e[16][e[17] ]
            e[16] = 'Code'
            e[14] = e[15][e[16] ]
            e[12][e[13] ] = e[14]
            e[12] = e[10][1]
            e[13] = 'Text'
            e[15] = a.typeof
            e[16] = e[3][1]

            do
                local i = 1
                local j = pack(e[15](b(e, 16, 15 + i)))

                for k = 1, 1 do
                    e[15 + k - 1] = j[k]
                end
            end

            e[16] = 'string'
            e[14] = e[15] == e[16]

            if (not not e[14]) == false then
                h = 7
            else
                h = 6
            end
        elseif h == 6 then
            e[14] = e[3][1]
            h = 7
        elseif h == 7 then
            if (not not e[14]) == true then
                h = 9
            else
                h = 8
            end
        elseif h == 8 then
            e[14] = '...'
            h = 9
        elseif h == 9 then
            e[12][e[13] ] = e[14]
            e[12] = e[10][1]
            e[13] = 'TextColor3'
            e[15] = a.Color3
            e[16] = 'fromRGB'
            e[14] = e[15][e[16] ]
            e[15] = 180
            e[16] = 180
            e[17] = 180

            do
                local i = 3
                local j = pack(e[14](b(e, 15, 14 + i)))

                for k = 1, 1 do
                    e[14 + k - 1] = j[k]
                end
            end

            e[12][e[13] ] = e[14]
            e[12] = e[10][1]
            e[13] = 'TextSize'
            e[14] = 14
            e[12][e[13] ] = e[14]
            e[12] = e[10][1]
            e[13] = 'TextXAlignment'
            e[16] = a.Enum
            e[17] = 'TextXAlignment'
            e[15] = e[16][e[17] ]
            e[16] = 'Left'
            e[14] = e[15][e[16] ]
            e[12][e[13] ] = e[14]
            e[12] = e[11][1]
            e[13] = 'Name'
            e[14] = 'DropdownArrow'
            e[12][e[13] ] = e[14]
            e[12] = e[11][1]
            e[13] = 'Parent'
            e[14] = e[7][1]
            e[12][e[13] ] = e[14]
            e[12] = e[11][1]
            e[13] = 'AnchorPoint'
            e[15] = a.Vector2
            e[16] = 'new'
            e[14] = e[15][e[16] ]
            e[15] = 0
            e[16] = 0.5

            do
                local i = 2
                local j = pack(e[14](b(e, 15, 14 + i)))

                for k = 1, 1 do
                    e[14 + k - 1] = j[k]
                end
            end

            e[12][e[13] ] = e[14]
            e[12] = e[11][1]
            e[13] = 'BackgroundTransparency'
            e[14] = 1
            e[12][e[13] ] = e[14]
            e[12] = e[11][1]
            e[13] = 'Position'
            e[15] = a.UDim2
            e[16] = 'new'
            e[14] = e[15][e[16] ]
            e[15] = 1
            e[17] = 22
            e[16] = -e[17]
            e[17] = 0.5
            e[18] = 0

            do
                local i = 4
                local j = pack(e[14](b(e, 15, 14 + i)))

                for k = 1, 1 do
                    e[14 + k - 1] = j[k]
                end
            end

            e[12][e[13] ] = e[14]
            e[12] = e[11][1]
            e[13] = 'Size'
            e[15] = a.UDim2
            e[16] = 'new'
            e[14] = e[15][e[16] ]
            e[15] = 0
            e[16] = 20
            e[17] = 0
            e[18] = 20

            do
                local i = 4
                local j = pack(e[14](b(e, 15, 14 + i)))

                for k = 1, 1 do
                    e[14 + k - 1] = j[k]
                end
            end

            e[12][e[13] ] = e[14]
            e[12] = e[11][1]
            e[13] = 'Image'
            e[14] = 'http://www.roblox.com/asset/?id=6031091004'
            e[12][e[13] ] = e[14]
            e[12] = e[11][1]
            e[13] = 'ImageColor3'
            e[15] = a.Color3
            e[16] = 'fromRGB'
            e[14] = e[15][e[16] ]
            e[15] = 180
            e[16] = 180
            e[17] = 180

            do
                local i = 3
                local j = pack(e[14](b(e, 15, 14 + i)))

                for k = 1, 1 do
                    e[14 + k - 1] = j[k]
                end
            end

            e[12][e[13] ] = e[14]
            e[12] = aa[2][1]

            do
                local i = 0

                e[12](b(e, 13, 12 + i))
            end

            e[13] = a.Instance
            e[14] = 'new'
            e[12] = e[13][e[14] ]
            e[13] = 'Frame'

            do
                local i = 1
                local j = pack(e[12](b(e, 13, 12 + i)))

                for k = 1, 1 do
                    e[12 + k - 1] = j[k]
                end
            end

            e[12] = {
                e[12],
            }
            e[14] = a.Instance
            e[15] = 'new'
            e[13] = e[14][e[15] ]
            e[14] = 'ImageLabel'

            do
                local i = 1
                local j = pack(e[13](b(e, 14, 13 + i)))

                for k = 1, 1 do
                    e[13 + k - 1] = j[k]
                end
            end

            e[15] = a.Instance
            e[16] = 'new'
            e[14] = e[15][e[16] ]
            e[15] = 'ImageLabel'

            do
                local i = 1
                local j = pack(e[14](b(e, 15, 14 + i)))

                for k = 1, 1 do
                    e[14 + k - 1] = j[k]
                end
            end

            e[16] = a.Instance
            e[17] = 'new'
            e[15] = e[16][e[17] ]
            e[16] = 'ScrollingFrame'

            do
                local i = 1
                local j = pack(e[15](b(e, 16, 15 + i)))

                for k = 1, 1 do
                    e[15 + k - 1] = j[k]
                end
            end

            e[17] = a.Instance
            e[18] = 'new'
            e[16] = e[17][e[18] ]
            e[17] = 'UIListLayout'

            do
                local i = 1
                local j = pack(e[16](b(e, 17, 16 + i)))

                for k = 1, 1 do
                    e[16 + k - 1] = j[k]
                end
            end

            e[18] = a.Instance
            e[19] = 'new'
            e[17] = e[18][e[19] ]
            e[18] = 'UIPadding'

            do
                local i = 1
                local j = pack(e[17](b(e, 18, 17 + i)))

                for k = 1, 1 do
                    e[17 + k - 1] = j[k]
                end
            end

            e[18] = e[12][1]
            e[19] = 'Name'
            e[20] = 'DropdownHolderFrame'
            e[18][e[19] ] = e[20]
            e[18] = e[12][1]
            e[19] = 'Parent'
            e[20] = aa[3][1]
            e[18][e[19] ] = e[20]
            e[18] = e[12][1]
            e[19] = 'AnchorPoint'
            e[21] = a.Vector2
            e[22] = 'new'
            e[20] = e[21][e[22] ]
            e[21] = 0.5
            e[22] = 0

            do
                local i = 2
                local j = pack(e[20](b(e, 21, 20 + i)))

                for k = 1, 1 do
                    e[20 + k - 1] = j[k]
                end
            end

            e[18][e[19] ] = e[20]
            e[18] = e[12][1]
            e[19] = 'BackgroundColor3'
            e[21] = a.Color3
            e[22] = 'fromRGB'
            e[20] = e[21][e[22] ]
            e[21] = 38
            e[22] = 38
            e[23] = 38

            do
                local i = 3
                local j = pack(e[20](b(e, 21, 20 + i)))

                for k = 1, 1 do
                    e[20 + k - 1] = j[k]
                end
            end

            e[18][e[19] ] = e[20]
            e[18] = e[12][1]
            e[19] = 'BorderSizePixel'
            e[20] = 0
            e[18][e[19] ] = e[20]
            e[18] = e[12][1]
            e[19] = 'Position'
            e[21] = a.UDim2
            e[22] = 'new'
            e[20] = e[21][e[22] ]
            e[21] = 0.5
            e[22] = 0
            e[23] = 0
            e[27] = aa[4][1]
            e[28] = 'AbsoluteContentSize'
            e[26] = e[27][e[28] ]
            e[27] = 'Y'
            e[25] = e[26][e[27] ]
            e[26] = 19
            e[24] = e[25] + e[26]

            do
                local i = 4
                local j = pack(e[20](b(e, 21, 20 + i)))

                for k = 1, 1 do
                    e[20 + k - 1] = j[k]
                end
            end

            e[18][e[19] ] = e[20]
            e[18] = e[12][1]
            e[19] = 'Size'
            e[21] = a.UDim2
            e[22] = 'new'
            e[20] = e[21][e[22] ]
            e[21] = 1
            e[23] = 16
            e[22] = -e[23]
            e[23] = 0
            e[24] = 0

            do
                local i = 4
                local j = pack(e[20](b(e, 21, 20 + i)))

                for k = 1, 1 do
                    e[20 + k - 1] = j[k]
                end
            end

            e[18][e[19] ] = e[20]
            e[18] = e[12][1]
            e[19] = 'Visible'
            e[20] = false
            e[18][e[19] ] = e[20]
            e[18] = e[12][1]
            e[19] = 'ZIndex'
            e[20] = 10
            e[18][e[19] ] = e[20]
            e[18] = e[13]
            e[19] = 'Parent'
            e[20] = e[12][1]
            e[18][e[19] ] = e[20]
            e[18] = e[13]
            e[19] = 'BackgroundTransparency'
            e[20] = 1
            e[18][e[19] ] = e[20]
            e[18] = e[13]
            e[19] = 'Size'
            e[21] = a.UDim2
            e[22] = 'new'
            e[20] = e[21][e[22] ]
            e[21] = 1
            e[22] = 0
            e[23] = 1
            e[24] = 0

            do
                local i = 4
                local j = pack(e[20](b(e, 21, 20 + i)))

                for k = 1, 1 do
                    e[20 + k - 1] = j[k]
                end
            end

            e[18][e[19] ] = e[20]
            e[18] = e[13]
            e[19] = 'Image'
            e[20] = 'rbxassetid://2592362371'
            e[18][e[19] ] = e[20]
            e[18] = e[13]
            e[19] = 'ImageColor3'
            e[21] = a.Color3
            e[22] = 'fromRGB'
            e[20] = e[21][e[22] ]
            e[21] = 60
            e[22] = 60
            e[23] = 60

            do
                local i = 3
                local j = pack(e[20](b(e, 21, 20 + i)))

                for k = 1, 1 do
                    e[20 + k - 1] = j[k]
                end
            end

            e[18][e[19] ] = e[20]
            e[18] = e[13]
            e[19] = 'ScaleType'
            e[22] = a.Enum
            e[23] = 'ScaleType'
            e[21] = e[22][e[23] ]
            e[22] = 'Slice'
            e[20] = e[21][e[22] ]
            e[18][e[19] ] = e[20]
            e[18] = e[13]
            e[19] = 'SliceCenter'
            e[21] = a.Rect
            e[22] = 'new'
            e[20] = e[21][e[22] ]
            e[21] = 2
            e[22] = 2
            e[23] = 62
            e[24] = 62

            do
                local i = 4
                local j = pack(e[20](b(e, 21, 20 + i)))

                for k = 1, 1 do
                    e[20 + k - 1] = j[k]
                end
            end

            e[18][e[19] ] = e[20]
            e[18] = e[14]
            e[19] = 'Parent'
            e[20] = e[12][1]
            e[18][e[19] ] = e[20]
            e[18] = e[14]
            e[19] = 'BackgroundTransparency'
            e[20] = 1
            e[18][e[19] ] = e[20]
            e[18] = e[14]
            e[19] = 'Position'
            e[21] = a.UDim2
            e[22] = 'new'
            e[20] = e[21][e[22] ]
            e[21] = 0
            e[22] = 1
            e[23] = 0
            e[24] = 1

            do
                local i = 4
                local j = pack(e[20](b(e, 21, 20 + i)))

                for k = 1, 1 do
                    e[20 + k - 1] = j[k]
                end
            end

            e[18][e[19] ] = e[20]
            e[18] = e[14]
            e[19] = 'Size'
            e[21] = a.UDim2
            e[22] = 'new'
            e[20] = e[21][e[22] ]
            e[21] = 1
            e[23] = 2
            e[22] = -e[23]
            e[23] = 1
            e[25] = 2
            e[24] = -e[25]

            do
                local i = 4
                local j = pack(e[20](b(e, 21, 20 + i)))

                for k = 1, 1 do
                    e[20 + k - 1] = j[k]
                end
            end

            e[18][e[19] ] = e[20]
            e[18] = e[14]
            e[19] = 'Image'
            e[20] = 'rbxassetid://2592362371'
            e[18][e[19] ] = e[20]
            e[18] = e[14]
            e[19] = 'ImageColor3'
            e[21] = a.Color3
            e[22] = 'fromRGB'
            e[20] = e[21][e[22] ]
            e[21] = 0
            e[22] = 0
            e[23] = 0

            do
                local i = 3
                local j = pack(e[20](b(e, 21, 20 + i)))

                for k = 1, 1 do
                    e[20 + k - 1] = j[k]
                end
            end

            e[18][e[19] ] = e[20]
            e[18] = e[14]
            e[19] = 'ScaleType'
            e[22] = a.Enum
            e[23] = 'ScaleType'
            e[21] = e[22][e[23] ]
            e[22] = 'Slice'
            e[20] = e[21][e[22] ]
            e[18][e[19] ] = e[20]
            e[18] = e[14]
            e[19] = 'SliceCenter'
            e[21] = a.Rect
            e[22] = 'new'
            e[20] = e[21][e[22] ]
            e[21] = 2
            e[22] = 2
            e[23] = 62
            e[24] = 62

            do
                local i = 4
                local j = pack(e[20](b(e, 21, 20 + i)))

                for k = 1, 1 do
                    e[20 + k - 1] = j[k]
                end
            end

            e[18][e[19] ] = e[20]
            e[18] = e[15]
            e[19] = 'Name'
            e[20] = 'DropdownHolder'
            e[18][e[19] ] = e[20]
            e[18] = e[15]
            e[19] = 'Parent'
            e[20] = e[12][1]
            e[18][e[19] ] = e[20]
            e[18] = e[15]
            e[19] = 'Active'
            e[20] = true
            e[18][e[19] ] = e[20]
            e[18] = e[15]
            e[19] = 'BackgroundTransparency'
            e[20] = 1
            e[18][e[19] ] = e[20]
            e[18] = e[15]
            e[19] = 'BorderSizePixel'
            e[20] = 0
            e[18][e[19] ] = e[20]
            e[18] = e[15]
            e[19] = 'Size'
            e[21] = a.UDim2
            e[22] = 'new'
            e[20] = e[21][e[22] ]
            e[21] = 1
            e[23] = 4
            e[22] = -e[23]
            e[23] = 1
            e[24] = 0

            do
                local i = 4
                local j = pack(e[20](b(e, 21, 20 + i)))

                for k = 1, 1 do
                    e[20 + k - 1] = j[k]
                end
            end

            e[18][e[19] ] = e[20]
            e[18] = e[15]
            e[19] = 'ScrollBarThickness'
            e[20] = 2
            e[18][e[19] ] = e[20]
            e[18] = e[15]
            e[19] = 'CanvasSize'
            e[21] = a.UDim2
            e[22] = 'new'
            e[20] = e[21][e[22] ]
            e[21] = 0
            e[22] = 0
            e[23] = 0
            e[24] = 0

            do
                local i = 4
                local j = pack(e[20](b(e, 21, 20 + i)))

                for k = 1, 1 do
                    e[20 + k - 1] = j[k]
                end
            end

            e[18][e[19] ] = e[20]
            e[18] = e[16]
            e[19] = 'Parent'
            e[20] = e[15]
            e[18][e[19] ] = e[20]
            e[18] = e[16]
            e[19] = 'HorizontalAlignment'
            e[22] = a.Enum
            e[23] = 'HorizontalAlignment'
            e[21] = e[22][e[23] ]
            e[22] = 'Center'
            e[20] = e[21][e[22] ]
            e[18][e[19] ] = e[20]
            e[18] = e[16]
            e[19] = 'Padding'
            e[21] = a.UDim
            e[22] = 'new'
            e[20] = e[21][e[22] ]
            e[21] = 0
            e[22] = 2

            do
                local i = 2
                local j = pack(e[20](b(e, 21, 20 + i)))

                for k = 1, 1 do
                    e[20 + k - 1] = j[k]
                end
            end

            e[18][e[19] ] = e[20]
            e[18] = e[17]
            e[19] = 'Parent'
            e[20] = e[15]
            e[18][e[19] ] = e[20]
            e[18] = e[17]
            e[19] = 'PaddingTop'
            e[21] = a.UDim
            e[22] = 'new'
            e[20] = e[21][e[22] ]
            e[21] = 0
            e[22] = 6

            do
                local i = 2
                local j = pack(e[20](b(e, 21, 20 + i)))

                for k = 1, 1 do
                    e[20 + k - 1] = j[k]
                end
            end

            e[18][e[19] ] = e[20]
            e[19] = a.table
            e[20] = 'insert'
            e[18] = e[19][e[20] ]
            e[20] = aa[5][1]
            e[21] = 'dropdownframes'
            e[19] = e[20][e[21] ]
            e[20] = e[12][1]

            do
                local i = 2

                e[18](b(e, 19, 18 + i))
            end

            e[19] = a.table
            e[20] = 'insert'
            e[18] = e[19][e[20] ]
            e[20] = aa[5][1]
            e[21] = 'dropdownframes'
            e[19] = e[20][e[21] ]
            e[20] = e[5]

            do
                local i = 2

                e[18](b(e, 19, 18 + i))
            end

            e[18] = {}
            e[20] = e[7][1]
            e[21] = 'MouseButton1Click'
            e[19] = e[20][e[21] ]
            e[21] = 'Connect'
            e[20] = e[19]
            e[19] = e[19][e[21] ]
            e[21] = function(...)
                return d.p080({
                    e[12],
                    aa[5],
                    e[11],
                }, ...)
            end

            do
                local i = 2

                e[19](b(e, 20, 19 + i))
            end

            e[19] = a.next
            e[20] = e[2]

            for i = 21, 21 do
                e[i] = nil
            end

            h = 11
        elseif h == 10 then
            e[24] = {
                e[23],
            }
            e[26] = a.Instance
            e[27] = 'new'
            e[25] = e[26][e[27] ]
            e[26] = 'TextButton'

            do
                local i = 1
                local j = pack(e[25](b(e, 26, 25 + i)))

                for k = 1, 1 do
                    e[25 + k - 1] = j[k]
                end
            end

            e[25] = {
                e[25],
            }
            e[27] = a.Instance
            e[28] = 'new'
            e[26] = e[27][e[28] ]
            e[27] = 'TextLabel'

            do
                local i = 1
                local j = pack(e[26](b(e, 27, 26 + i)))

                for k = 1, 1 do
                    e[26 + k - 1] = j[k]
                end
            end

            e[26] = {
                e[26],
            }
            e[27] = e[25][1]
            e[28] = 'Name'
            e[29] = 'Item'
            e[27][e[28] ] = e[29]
            e[27] = e[25][1]
            e[28] = 'Parent'
            e[29] = e[15]
            e[27][e[28] ] = e[29]
            e[27] = e[25][1]
            e[28] = 'BackgroundColor3'
            e[30] = a.Color3
            e[31] = 'fromRGB'
            e[29] = e[30][e[31] ]
            e[30] = 50
            e[31] = 50
            e[32] = 50

            do
                local i = 3
                local j = pack(e[29](b(e, 30, 29 + i)))

                for k = 1, 1 do
                    e[29 + k - 1] = j[k]
                end
            end

            e[27][e[28] ] = e[29]
            e[27] = e[25][1]
            e[28] = 'Size'
            e[30] = a.UDim2
            e[31] = 'new'
            e[29] = e[30][e[31] ]
            e[30] = 1
            e[32] = 12
            e[31] = -e[32]
            e[32] = 0
            e[33] = 20

            do
                local i = 4
                local j = pack(e[29](b(e, 30, 29 + i)))

                for k = 1, 1 do
                    e[29 + k - 1] = j[k]
                end
            end

            e[27][e[28] ] = e[29]
            e[27] = e[25][1]
            e[28] = 'AutoButtonColor'
            e[29] = false
            e[27][e[28] ] = e[29]
            e[27] = e[25][1]
            e[28] = 'Font'
            e[31] = a.Enum
            e[32] = 'Font'
            e[30] = e[31][e[32] ]
            e[31] = 'Code'
            e[29] = e[30][e[31] ]
            e[27][e[28] ] = e[29]
            e[27] = e[25][1]
            e[28] = 'Text'
            e[30] = ' '
            e[31] = e[24][1]
            e[29] = e[30] .. e[31]
            e[27][e[28] ] = e[29]
            e[27] = e[25][1]
            e[28] = 'TextColor3'
            e[30] = a.Color3
            e[31] = 'fromRGB'
            e[29] = e[30][e[31] ]
            e[30] = 230
            e[31] = 230
            e[32] = 230

            do
                local i = 3
                local j = pack(e[29](b(e, 30, 29 + i)))

                for k = 1, 1 do
                    e[29 + k - 1] = j[k]
                end
            end

            e[27][e[28] ] = e[29]
            e[27] = e[25][1]
            e[28] = 'TextSize'
            e[29] = 14
            e[27][e[28] ] = e[29]
            e[27] = e[25][1]
            e[28] = 'TextXAlignment'
            e[31] = a.Enum
            e[32] = 'TextXAlignment'
            e[30] = e[31][e[32] ]
            e[31] = 'Left'
            e[29] = e[30][e[31] ]
            e[27][e[28] ] = e[29]
            e[27] = e[26][1]
            e[28] = 'Name'
            e[29] = 'ItemText'
            e[27][e[28] ] = e[29]
            e[27] = e[26][1]
            e[28] = 'Parent'
            e[29] = e[25][1]
            e[27][e[28] ] = e[29]
            e[27] = e[26][1]
            e[28] = 'BackgroundTransparency'
            e[29] = 1
            e[27][e[28] ] = e[29]
            e[27] = e[26][1]
            e[28] = 'Position'
            e[30] = a.UDim2
            e[31] = 'new'
            e[29] = e[30][e[31] ]
            e[30] = 0
            e[31] = 7
            e[32] = 0
            e[33] = 0

            do
                local i = 4
                local j = pack(e[29](b(e, 30, 29 + i)))

                for k = 1, 1 do
                    e[29 + k - 1] = j[k]
                end
            end

            e[27][e[28] ] = e[29]
            e[27] = e[26][1]
            e[28] = 'Size'
            e[30] = a.UDim2
            e[31] = 'new'
            e[29] = e[30][e[31] ]
            e[30] = 1
            e[32] = 7
            e[31] = -e[32]
            e[32] = 1
            e[33] = 0

            do
                local i = 4
                local j = pack(e[29](b(e, 30, 29 + i)))

                for k = 1, 1 do
                    e[29 + k - 1] = j[k]
                end
            end

            e[27][e[28] ] = e[29]
            e[27] = e[26][1]
            e[28] = 'Font'
            e[31] = a.Enum
            e[32] = 'Font'
            e[30] = e[31][e[32] ]
            e[31] = 'Code'
            e[29] = e[30][e[31] ]
            e[27][e[28] ] = e[29]
            e[27] = e[26][1]
            e[28] = 'Text'
            e[29] = e[24][1]
            e[27][e[28] ] = e[29]
            e[27] = e[26][1]
            e[28] = 'TextColor3'
            e[30] = aa[5][1]
            e[31] = 'accentclr'
            e[29] = e[30][e[31] ]
            e[27][e[28] ] = e[29]
            e[27] = e[26][1]
            e[28] = 'TextSize'
            e[29] = 14
            e[27][e[28] ] = e[29]
            e[27] = e[26][1]
            e[28] = 'TextXAlignment'
            e[31] = a.Enum
            e[32] = 'TextXAlignment'
            e[30] = e[31][e[32] ]
            e[31] = 'Left'
            e[29] = e[30][e[31] ]
            e[27][e[28] ] = e[29]
            e[28] = e[25][1]
            e[29] = 'MouseButton1Click'
            e[27] = e[28][e[29] ]
            e[29] = 'Connect'
            e[28] = e[27]
            e[27] = e[27][e[29] ]
            e[29] = function(...)
                return d.p081({
                    e[12],
                    e[10],
                    e[24],
                    e[3],
                    e[4],
                }, ...)
            end

            do
                local i = 2

                e[27](b(e, 28, 27 + i))
            end

            e[28] = a.coroutine
            e[29] = 'wrap'
            e[27] = e[28][e[29] ]
            e[28] = function(...)
                return d.p082({
                    e[3],
                    e[24],
                    e[26],
                    e[25],
                    aa[5],
                }, ...)
            end

            do
                local i = 1
                local j = pack(e[27](b(e, 28, 27 + i)))

                for k = 1, 1 do
                    e[27 + k - 1] = j[k]
                end
            end
            do
                local i = 0

                e[27](b(e, 28, 27 + i))
            end

            e[27] = e[12][1]
            e[28] = 'Size'
            e[30] = a.UDim2
            e[31] = 'new'
            e[29] = e[30][e[31] ]
            e[30] = 1
            e[32] = 16
            e[31] = -e[32]
            e[32] = 0
            e[34] = a.math
            e[35] = 'clamp'
            e[33] = e[34][e[35] ]
            e[37] = e[16]
            e[38] = 'AbsoluteContentSize'
            e[36] = e[37][e[38] ]
            e[37] = 'Y'
            e[35] = e[36][e[37] ]
            e[36] = 12
            e[34] = e[35] + e[36]
            e[35] = 0
            e[36] = 150

            do
                local i = 3
                local j = pack(e[33](b(e, 34, 33 + i)))

                for k = 1, j.n do
                    e[33 + k - 1] = j[k]
                end

                g = 33 + j.n
            end
            do
                local i = (g - 29 - 1)
                local j = pack(e[29](b(e, 30, 29 + i)))

                for k = 1, 1 do
                    e[29 + k - 1] = j[k]
                end
            end

            e[27][e[28] ] = e[29]
            e[27] = e[15]
            e[28] = 'CanvasSize'
            e[30] = a.UDim2
            e[31] = 'new'
            e[29] = e[30][e[31] ]
            e[30] = 0
            e[31] = 0
            e[32] = 0
            e[36] = e[16]
            e[37] = 'AbsoluteContentSize'
            e[35] = e[36][e[37] ]
            e[36] = 'Y'
            e[34] = e[35][e[36] ]
            e[35] = 12
            e[33] = e[34] + e[35]

            do
                local i = 4
                local j = pack(e[29](b(e, 30, 29 + i)))

                for k = 1, 1 do
                    e[29 + k - 1] = j[k]
                end
            end

            e[27][e[28] ] = e[29]
            h = 11
        elseif h == 11 then
            do
                local i = pack(e[19](e[20], e[21]))
                local j = i[1]

                if j ~= nil then
                    e[21] = j

                    for k = 1, 2 do
                        e[21 + k] = i[k]
                    end

                    h = 10
                else
                    h = 12
                end
            end
        elseif h == 12 then
            e[20] = a.coroutine
            e[21] = 'wrap'
            e[19] = e[20][e[21] ]
            e[20] = function(...)
                return d.p083({
                    e[7],
                    aa[5],
                }, ...)
            end

            do
                local i = 1
                local j = pack(e[19](b(e, 20, 19 + i)))

                for k = 1, 1 do
                    e[19 + k - 1] = j[k]
                end
            end
            do
                local i = 0

                e[19](b(e, 20, 19 + i))
            end

            e[19] = function(...)
                return d.p084({
                    e[10],
                    e[3],
                    e[4],
                }, ...)
            end
            e[20] = e[18]
            e[21] = 'Set'
            e[20][e[21] ] = e[19]
            e[19] = e[18]

            local i = 1

            return b(e, 19, 19 + i - 1)
        else
            return
        end
    end
end
d.p078 = function(aa, e)
    a.pcall(aa[1][1], aa[2][1].Text)

    return
end
d.create_input = function(aa, e, f, g, h, i)
    local j, k, l, m, n, o, p, q, r

    j = e
    k = f
    l = g
    m = h
    n = i

    local s, t, u, v = {n}, a.Instance.new'Frame', a.Instance.new'TextLabel', a.Instance.new'TextBox'
    local w = {v}

    t.Name = 'Input'
    t.Parent = aa[1][1]
    t.BackgroundTransparency = 1

    local x = a.UDim2.new(1, 0, 0, 38)

    t.Size = x
    u.Name = 'InputTitle'
    u.Parent = t
    u.BackgroundTransparency = 1

    local y = a.UDim2.new(1, 0, 0, 15)

    u.Size = y
    u.Font = a.Enum.Font.Code
    u.Text = k

    local z = a.Color3.fromRGB(190, 190, 190)

    u.TextColor3 = z
    u.TextSize = 14
    u.TextXAlignment = a.Enum.TextXAlignment.Left
    w[1].Name = 'InputBox'
    w[1].Parent = t

    local A = a.Color3.fromRGB(38, 38, 38)

    w[1].BackgroundColor3 = A
    w[1].BorderSizePixel = 0

    local B = a.UDim2.new(0, 0, 0, 18)

    w[1].Position = B

    local C = a.UDim2.new(1, 0, 0, 20)

    w[1].Size = C
    w[1].Font = a.Enum.Font.Code
    n = s
    o = w
    p = w[1]
    q = 'PlaceholderText'
    r = m

    if (m) then
    else
        r = ''
    end

    p[q] = r
    p = o[1]
    q = 'Text'
    r = l

    if (l) then
    else
        r = ''
    end

    p[q] = r

    local D = a.Color3.fromRGB(230, 230, 230)

    o[1].TextColor3 = D
    o[1].TextSize = 14
    o[1].TextXAlignment = a.Enum.TextXAlignment.Left

    o[1].FocusLost:Connect(function(...)
        return d.p078({n, o}, ...)
    end)
    aa[2][1]()

    return
end
d.p076 = function(aa, ...)
    while a.task.wait() do
        aa[1][1].BackgroundColor3 = aa[2][1].accentclr
    end
end
d.p075 = function(aa, e)
    local f, g

    f = e
    g = aa[1][1]

    if (not aa[1][1]) then
    else
        g = (f.UserInputType == a.Enum.UserInputType.MouseMovement)

        if ((f.UserInputType == a.Enum.UserInputType.MouseMovement)) then
        else
            g = (f.UserInputType == a.Enum.UserInputType.Touch)
        end
    end
    if (not g) then
    else
        aa[2][1](f)
    end

    return
end
d.p074 = function(aa, e)
    local f, g

    f = e
    g = (f.UserInputType == a.Enum.UserInputType.MouseButton1)

    if ((f.UserInputType == a.Enum.UserInputType.MouseButton1)) then
    else
        g = (f.UserInputType == a.Enum.UserInputType.Touch)
    end
    if (not g) then
    else
        aa[1][1] = false
    end

    return
end
d.p073 = function(aa, e)
    local f, g

    f = e
    g = (f.UserInputType == a.Enum.UserInputType.MouseButton1)

    if ((f.UserInputType == a.Enum.UserInputType.MouseButton1)) then
    else
        g = (f.UserInputType == a.Enum.UserInputType.Touch)
    end
    if (not g) then
    else
        aa[1][1] = true

        aa[2][1](f)
    end

    return
end
d.p072 = function(aa, e)
    local f = a.math.clamp((e.Position.X - aa[1][1].AbsolutePosition.X) / aa[1][1].AbsoluteSize.X, 0, 1)
    local g = aa[2][1] + (aa[3][1] - aa[2][1]) * f

    if aa[4][1] == 0 then
        g = a.math.floor(g + 0.5)
    else
        g = a.tonumber(a.string.format('%.' .. aa[4][1] .. 'f', g))
    end

    aa[5][1].Size = a.UDim2.new(f, 0, 1, 0)
    aa[6][1].Text = a.tostring(g) .. 's'

    a.pcall(aa[7][1], g)
end
d.create_slider = function(aa, e, f, g, h, i, j, k)
    local l, m, n, o, p = {g}, {h}, {j}, {k}, a.Instance.new'TextButton'
    local q, r = {p}, a.Instance.new'Frame'
    local s, t, u = {r}, a.Instance.new'TextLabel', a.Instance.new'TextLabel'
    local v = {u}

    q[1].Name = 'SliderBar'
    q[1].Parent = aa[1][1]

    local w = a.Color3.fromRGB(38, 38, 38)

    q[1].BackgroundColor3 = w
    q[1].BorderSizePixel = 0

    local x = a.UDim2.new(1, 0, 0, 16)

    q[1].Size = x
    q[1].Text = ''
    q[1].AutoButtonColor = false

    local y = a.Instance.new'ImageLabel'

    y.Parent = q[1]
    y.BackgroundTransparency = 1

    local z = a.UDim2.new(1, 0, 1, 0)

    y.Size = z
    y.Image = 'rbxassetid://2592362371'

    local A = a.Color3.fromRGB(60, 60, 60)

    y.ImageColor3 = A
    y.ScaleType = a.Enum.ScaleType.Slice

    local B = a.Rect.new(2, 2, 62, 62)

    y.SliceCenter = B

    local C = a.Instance.new'ImageLabel'

    C.Parent = q[1]
    C.BackgroundTransparency = 1

    local D = a.UDim2.new(0, 1, 0, 1)

    C.Position = D

    local E = a.UDim2.new(1, (-2), 1, (-2))

    C.Size = E
    C.Image = 'rbxassetid://2592362371'

    local F = a.Color3.fromRGB(0, 0, 0)

    C.ImageColor3 = F
    C.ScaleType = a.Enum.ScaleType.Slice

    local G = a.Rect.new(2, 2, 62, 62)

    C.SliceCenter = G
    s[1].Name = 'SliderFill'
    s[1].Parent = q[1]
    s[1].BackgroundColor3 = aa[2][1].accentclr
    s[1].BorderSizePixel = 0
    s[1].BackgroundTransparency = 0.55

    local H = a.UDim2.new(((i - l[1]) / (m[1] - l[1])), 0, 1, 0)

    s[1].Size = H
    t.Name = 'SliderTitle'
    t.Parent = q[1]
    t.BackgroundTransparency = 1

    local I = a.UDim2.new(0, 6, 0, 0)

    t.Position = I

    local J = a.UDim2.new(0.7, 0, 1, 0)

    t.Size = J
    t.Font = a.Enum.Font.Code
    t.Text = f

    local K = a.Color3.fromRGB(190, 190, 190)

    t.TextColor3 = K
    t.TextSize = 13
    t.TextXAlignment = a.Enum.TextXAlignment.Left
    t.ZIndex = 2
    v[1].Name = 'SliderValue'
    v[1].Parent = q[1]
    v[1].BackgroundTransparency = 1

    local L = a.UDim2.new(1, (-75), 0, 0)

    v[1].Position = L

    local M = a.UDim2.new(0, 70, 1, 0)

    v[1].Size = M
    v[1].Font = a.Enum.Font.Code

    local N = a.tostring(i)

    v[1].Text = (N .. 's')

    local O = a.Color3.fromRGB(240, 240, 240)

    v[1].TextColor3 = O
    v[1].TextSize = 13
    v[1].TextXAlignment = a.Enum.TextXAlignment.Right
    v[1].ZIndex = 5

    local P, Q = {false}, {nil}

    Q[1] = function(...)
        return d.p072({
            q,
            l,
            m,
            n,
            s,
            v,
            o,
        }, ...)
    end

    q[1].InputBegan:Connect(function(...)
        return d.p073({P, Q}, ...)
    end)

    local R = a.game:GetService'UserInputService'

    R.InputEnded:Connect(function(...)
        return d.p074({P}, ...)
    end)

    local S = a.game:GetService'UserInputService'

    S.InputChanged:Connect(function(...)
        return d.p075({P, Q}, ...)
    end)
    aa[3][1]()

    local T = a.coroutine.wrap(function(...)
        return d.p076({
            s,
            aa[2],
        }, ...)
    end)

    T()

    return
end
d.p070 = function(aa, ...)
    while a.task.wait() do
        aa[1][1].BorderColor3 = aa[2][1].accentclr
    end
end
d.p069 = function(aa)
    aa[1][1].BorderSizePixel = 0

    return
end
d.p068 = function(aa)
    aa[1][1].BorderSizePixel = 1

    return
end
d.p067 = function(aa)
    a.pcall(aa[1][1])

    return
end
d.create_button = function(aa, e, f, g)
    local h, i = {g}, a.Instance.new'TextButton'
    local j, k, l = {i}, a.Instance.new'ImageLabel', a.Instance.new'ImageLabel'

    j[1].Name = 'Button'
    j[1].Parent = aa[1][1]

    local m = a.Color3.fromRGB(38, 38, 38)

    j[1].BackgroundColor3 = m
    j[1].BorderColor3 = aa[2][1].accentclr
    j[1].BorderSizePixel = 0

    local n = a.UDim2.new(1, 0, 0, 20)

    j[1].Size = n
    j[1].AutoButtonColor = false
    j[1].Font = a.Enum.Font.Code

    local o = a.Color3.fromRGB(230, 230, 230)

    j[1].TextColor3 = o
    j[1].TextSize = 14
    j[1].Text = f
    k.Name = 'ButtonOutline1'
    k.Parent = j[1]
    k.BackgroundTransparency = 1

    local p = a.UDim2.new(1, 0, 1, 0)

    k.Size = p
    k.Image = 'rbxassetid://2592362371'

    local q = a.Color3.fromRGB(60, 60, 60)

    k.ImageColor3 = q
    k.ScaleType = a.Enum.ScaleType.Slice

    local r = a.Rect.new(2, 2, 62, 62)

    k.SliceCenter = r
    l.Name = 'ButtonOutline2'
    l.Parent = j[1]
    l.BackgroundTransparency = 1

    local s = a.UDim2.new(0, 1, 0, 1)

    l.Position = s

    local t = a.UDim2.new(1, (-2), 1, (-2))

    l.Size = t
    l.Image = 'rbxassetid://2592362371'

    local u = a.Color3.fromRGB(0, 0, 0)

    l.ImageColor3 = u
    l.ScaleType = a.Enum.ScaleType.Slice

    local v = a.Rect.new(2, 2, 62, 62)

    l.SliceCenter = v

    j[1].MouseButton1Click:Connect(function(...)
        return d.p067({h}, ...)
    end)
    j[1].MouseEnter:Connect(function(...)
        return d.p068({j}, ...)
    end)
    j[1].MouseLeave:Connect(function(...)
        return d.p069({j}, ...)
    end)
    aa[3][1]()

    local w = a.coroutine.wrap(function(...)
        return d.p070({
            j,
            aa[2],
        }, ...)
    end)

    w()

    return
end
d.p065 = function(aa, e, f)
    aa[1][1] = f
    aa[2][1].Visible = aa[1][1]

    a.pcall(aa[3][1], aa[1][1])

    return
end
d.p064 = function(aa, ...)
    while a.task.wait() do
        aa[1][1].BackgroundColor3 = aa[2][1].accentclr
    end
end
d.p063 = function(aa)
    aa[1][1] = (not aa[1][1])
    aa[2][1].Visible = aa[1][1]

    a.pcall(aa[3][1], aa[1][1])

    return
end
d.create_toggle = function(aa, e, f, g, h)
    local i, j, k, l, m, n, o, p, q, r

    i = e
    j = f
    k = g
    l = h

    local s, t, u, v, w, x = {l}, a.Instance.new'TextButton', a.Instance.new'ImageLabel', a.Instance.new'ImageLabel', a.Instance.new'Frame', a.Instance.new'Frame'
    local y, z = {x}, a.Instance.new'TextLabel'

    t.Name = 'Toggle'
    t.Parent = aa[1][1]

    local A = a.Color3.fromRGB(38, 38, 38)

    t.BackgroundColor3 = A
    t.BorderSizePixel = 0

    local B = a.UDim2.new(1, 0, 0, 22)

    t.Size = B
    t.AutoButtonColor = false
    t.Text = ''
    u.Parent = t
    u.BackgroundTransparency = 1

    local C = a.UDim2.new(1, 0, 1, 0)

    u.Size = C
    u.Image = 'rbxassetid://2592362371'

    local D = a.Color3.fromRGB(60, 60, 60)

    u.ImageColor3 = D
    u.ScaleType = a.Enum.ScaleType.Slice

    local E = a.Rect.new(2, 2, 62, 62)

    u.SliceCenter = E
    v.Parent = t
    v.BackgroundTransparency = 1

    local F = a.UDim2.new(0, 1, 0, 1)

    v.Position = F

    local G = a.UDim2.new(1, (-2), 1, (-2))

    v.Size = G
    v.Image = 'rbxassetid://2592362371'

    local H = a.Color3.fromRGB(0, 0, 0)

    v.ImageColor3 = H
    v.ScaleType = a.Enum.ScaleType.Slice

    local I = a.Rect.new(2, 2, 62, 62)

    v.SliceCenter = I
    w.Name = 'Box'
    w.Parent = t

    local J = a.Color3.fromRGB(28, 28, 28)

    w.BackgroundColor3 = J
    w.BorderSizePixel = 0

    local K = a.UDim2.new(0, 6, 0.5, (-6))

    w.Position = K

    local L = a.UDim2.new(0, 12, 0, 12)

    w.Size = L
    y[1].Name = 'Check'
    y[1].Parent = w
    y[1].BackgroundColor3 = aa[2][1].accentclr
    y[1].BorderSizePixel = 0

    local M = a.UDim2.new(0, 2, 0, 2)

    y[1].Position = M

    local N = a.UDim2.new(0, 8, 0, 8)

    y[1].Size = N
    l = s
    m = t
    n = y
    o = z
    p = y[1]
    q = 'Visible'
    r = k

    if (k) then
    else
        r = false
    end

    p[q] = r
    o.Parent = m
    o.BackgroundTransparency = 1

    local O = a.UDim2.new(0, 25, 0, 0)

    o.Position = O

    local P = a.UDim2.new(1, (-25), 1, 0)

    o.Size = P
    o.Font = a.Enum.Font.Code
    o.Text = j

    local Q = a.Color3.fromRGB(190, 190, 190)

    o.TextColor3 = Q
    o.TextSize = 14
    o.TextXAlignment = a.Enum.TextXAlignment.Left
    p = k

    if (k) then
    else
        p = false
    end

    local R = {p}

    m.MouseButton1Click:Connect(function(...)
        return d.p063({R, n, l}, ...)
    end)
    aa[3][1]()

    local S = a.coroutine.wrap(function(...)
        return d.p064({
            n,
            aa[2],
        }, ...)
    end)

    S()

    local T = {}

    T.Set = function(...)
        return d.p065({R, n, l}, ...)
    end

    return T
end
d.p061 = function(aa)
    local e = a.UDim2.new(1, (-2), 0, (aa[2][1].AbsoluteContentSize.Y + 24))

    aa[1][1].Size = e

    local f = a.UDim2.new(0, 0, 0, (aa[4][1].AbsoluteContentSize.Y + 20))

    aa[3][1].CanvasSize = f

    local g = a.UDim2.new(0, 0, 0, (aa[6][1].AbsoluteContentSize.Y + 20))

    aa[5][1].CanvasSize = g

    return
end
d.create_section = function(aa, ...)
    local e, f = {}, pack(...)

    for g = 1, 3 do
        e[g - 1] = f[g]
    end

    local g = 1

    while true do
        if g == 1 then
            e[4] = aa[1][1]
            e[5] = 1
            e[3] = e[4] - e[5]
            aa[1][1] = e[3]

            for h = 3, 3 do
                e[h] = nil
            end

            e[5] = e[2]
            e[6] = 1
            e[4] = e[5] == e[6]

            if (not not e[4]) == false then
                g = 3
            else
                g = 2
            end
        elseif g == 2 then
            e[4] = aa[2][1]
            e[3] = e[4]
            g = 24
        elseif g == 3 then
            e[5] = e[2]
            e[6] = 2
            e[4] = e[5] == e[6]

            if (not not e[4]) == false then
                g = 5
            else
                g = 4
            end
        elseif g == 4 then
            e[4] = aa[3][1]
            e[3] = e[4]
            g = 24
        elseif g == 5 then
            e[4] = 0
            e[5] = 0
            e[6] = a.next
            e[7] = aa[2][1]
            e[9] = 'GetChildren'
            e[8] = e[7]
            e[7] = e[7][e[9] ]

            do
                local h = 1
                local i = pack(e[7](b(e, 8, 7 + h)))

                for j = 1, 2 do
                    e[7 + j - 1] = i[j]
                end
            end

            g = 10
        elseif g == 6 then
            e[13] = e[10]
            e[14] = 'Name'
            e[12] = e[13][e[14] ]
            e[13] = 'Section'
            e[11] = e[12] == e[13]

            if (not not e[11]) == true then
                g = 8
            else
                g = 7
            end
        elseif g == 7 then
            e[13] = e[10]
            e[14] = 'Name'
            e[12] = e[13][e[14] ]
            e[13] = 'MultiSection'
            e[11] = e[12] == e[13]
            g = 8
        elseif g == 8 then
            if (not not e[11]) == false then
                g = 10
            else
                g = 9
            end
        elseif g == 9 then
            e[12] = e[4]
            e[13] = 1
            e[11] = e[12] + e[13]
            e[4] = e[11]
            g = 10
        elseif g == 10 then
            do
                local h = pack(e[6](e[7], e[8]))
                local i = h[1]

                if i ~= nil then
                    e[8] = i

                    for j = 1, 2 do
                        e[8 + j] = h[j]
                    end

                    g = 6
                else
                    g = 11
                end
            end
        elseif g == 11 then
            e[6] = a.next
            e[7] = aa[3][1]
            e[9] = 'GetChildren'
            e[8] = e[7]
            e[7] = e[7][e[9] ]

            do
                local h = 1
                local i = pack(e[7](b(e, 8, 7 + h)))

                for j = 1, 2 do
                    e[7 + j - 1] = i[j]
                end
            end

            g = 16
        elseif g == 12 then
            e[13] = e[10]
            e[14] = 'Name'
            e[12] = e[13][e[14] ]
            e[13] = 'Section'
            e[11] = e[12] == e[13]

            if (not not e[11]) == true then
                g = 14
            else
                g = 13
            end
        elseif g == 13 then
            e[13] = e[10]
            e[14] = 'Name'
            e[12] = e[13][e[14] ]
            e[13] = 'MultiSection'
            e[11] = e[12] == e[13]
            g = 14
        elseif g == 14 then
            if (not not e[11]) == false then
                g = 16
            else
                g = 15
            end
        elseif g == 15 then
            e[12] = e[5]
            e[13] = 1
            e[11] = e[12] + e[13]
            e[5] = e[11]
            g = 16
        elseif g == 16 then
            do
                local h = pack(e[6](e[7], e[8]))
                local i = h[1]

                if i ~= nil then
                    e[8] = i

                    for j = 1, 2 do
                        e[8 + j] = h[j]
                    end

                    g = 12
                else
                    g = 17
                end
            end
        elseif g == 17 then
            e[7] = e[4]
            e[8] = 0
            e[6] = e[7] == e[8]

            if (not not e[6]) == false then
                g = 19
            else
                g = 18
            end
        elseif g == 18 then
            e[7] = e[5]
            e[8] = 0
            e[6] = e[7] == e[8]
            g = 19
        elseif g == 19 then
            if (not not e[6]) == false then
                g = 21
            else
                g = 20
            end
        elseif g == 20 then
            e[6] = aa[2][1]
            e[3] = e[6]
            g = 24
        elseif g == 21 then
            e[7] = e[4]
            e[8] = e[5]
            e[6] = e[7] == e[8]

            if (not not e[6]) == false then
                g = 23
            else
                g = 22
            end
        elseif g == 22 then
            e[6] = aa[2][1]
            e[3] = e[6]
            g = 24
        elseif g == 23 then
            e[6] = aa[3][1]
            e[3] = e[6]
            g = 24
        elseif g == 24 then
            e[5] = a.Instance
            e[6] = 'new'
            e[4] = e[5][e[6] ]
            e[5] = 'Frame'

            do
                local h = 1
                local i = pack(e[4](b(e, 5, 4 + h)))

                for j = 1, 1 do
                    e[4 + j - 1] = i[j]
                end
            end

            e[4] = {
                e[4],
            }
            e[6] = a.Instance
            e[7] = 'new'
            e[5] = e[6][e[7] ]
            e[6] = 'ImageLabel'

            do
                local h = 1
                local i = pack(e[5](b(e, 6, 5 + h)))

                for j = 1, 1 do
                    e[5 + j - 1] = i[j]
                end
            end

            e[7] = a.Instance
            e[8] = 'new'
            e[6] = e[7][e[8] ]
            e[7] = 'ImageLabel'

            do
                local h = 1
                local i = pack(e[6](b(e, 7, 6 + h)))

                for j = 1, 1 do
                    e[6 + j - 1] = i[j]
                end
            end

            e[8] = a.Instance
            e[9] = 'new'
            e[7] = e[8][e[9] ]
            e[8] = 'Frame'

            do
                local h = 1
                local i = pack(e[7](b(e, 8, 7 + h)))

                for j = 1, 1 do
                    e[7 + j - 1] = i[j]
                end
            end

            e[9] = a.Instance
            e[10] = 'new'
            e[8] = e[9][e[10] ]
            e[9] = 'TextLabel'

            do
                local h = 1
                local i = pack(e[8](b(e, 9, 8 + h)))

                for j = 1, 1 do
                    e[8 + j - 1] = i[j]
                end
            end

            e[10] = a.Instance
            e[11] = 'new'
            e[9] = e[10][e[11] ]
            e[10] = 'Frame'

            do
                local h = 1
                local i = pack(e[9](b(e, 10, 9 + h)))

                for j = 1, 1 do
                    e[9 + j - 1] = i[j]
                end
            end

            e[9] = {
                e[9],
            }
            e[11] = a.Instance
            e[12] = 'new'
            e[10] = e[11][e[12] ]
            e[11] = 'UIListLayout'

            do
                local h = 1
                local i = pack(e[10](b(e, 11, 10 + h)))

                for j = 1, 1 do
                    e[10 + j - 1] = i[j]
                end
            end

            e[10] = {
                e[10],
            }
            e[11] = e[4][1]
            e[12] = 'Name'
            e[13] = 'Section'
            e[11][e[12] ] = e[13]
            e[11] = e[4][1]
            e[12] = 'Parent'
            e[13] = e[3]
            e[11][e[12] ] = e[13]
            e[11] = e[4][1]
            e[12] = 'AnchorPoint'
            e[14] = a.Vector2
            e[15] = 'new'
            e[13] = e[14][e[15] ]
            e[14] = 0.5
            e[15] = 0

            do
                local h = 2
                local i = pack(e[13](b(e, 14, 13 + h)))

                for j = 1, 1 do
                    e[13 + j - 1] = i[j]
                end
            end

            e[11][e[12] ] = e[13]
            e[11] = e[4][1]
            e[12] = 'BackgroundColor3'
            e[14] = a.Color3
            e[15] = 'fromRGB'
            e[13] = e[14][e[15] ]
            e[14] = 30
            e[15] = 30
            e[16] = 30

            do
                local h = 3
                local i = pack(e[13](b(e, 14, 13 + h)))

                for j = 1, 1 do
                    e[13 + j - 1] = i[j]
                end
            end

            e[11][e[12] ] = e[13]
            e[11] = e[4][1]
            e[12] = 'BorderSizePixel'
            e[13] = 0
            e[11][e[12] ] = e[13]
            e[11] = e[4][1]
            e[12] = 'Size'
            e[14] = a.UDim2
            e[15] = 'new'
            e[13] = e[14][e[15] ]
            e[14] = 1
            e[16] = 2
            e[15] = -e[16]
            e[16] = 0
            e[17] = 24

            do
                local h = 4
                local i = pack(e[13](b(e, 14, 13 + h)))

                for j = 1, 1 do
                    e[13 + j - 1] = i[j]
                end
            end

            e[11][e[12] ] = e[13]
            e[11] = e[4][1]
            e[12] = 'ZIndex'
            e[13] = aa[1][1]
            e[11][e[12] ] = e[13]
            e[11] = e[5]
            e[12] = 'Name'
            e[13] = 'SectionOutline2'
            e[11][e[12] ] = e[13]
            e[11] = e[5]
            e[12] = 'Parent'
            e[13] = e[4][1]
            e[11][e[12] ] = e[13]
            e[11] = e[5]
            e[12] = 'BackgroundTransparency'
            e[13] = 1
            e[11][e[12] ] = e[13]
            e[11] = e[5]
            e[12] = 'Size'
            e[14] = a.UDim2
            e[15] = 'new'
            e[13] = e[14][e[15] ]
            e[14] = 1
            e[15] = 0
            e[16] = 1
            e[17] = 0

            do
                local h = 4
                local i = pack(e[13](b(e, 14, 13 + h)))

                for j = 1, 1 do
                    e[13 + j - 1] = i[j]
                end
            end

            e[11][e[12] ] = e[13]
            e[11] = e[5]
            e[12] = 'Image'
            e[13] = 'rbxassetid://2592362371'
            e[11][e[12] ] = e[13]
            e[11] = e[5]
            e[12] = 'ImageColor3'
            e[14] = a.Color3
            e[15] = 'fromRGB'
            e[13] = e[14][e[15] ]
            e[14] = 0
            e[15] = 0
            e[16] = 0

            do
                local h = 3
                local i = pack(e[13](b(e, 14, 13 + h)))

                for j = 1, 1 do
                    e[13 + j - 1] = i[j]
                end
            end

            e[11][e[12] ] = e[13]
            e[11] = e[5]
            e[12] = 'ScaleType'
            e[15] = a.Enum
            e[16] = 'ScaleType'
            e[14] = e[15][e[16] ]
            e[15] = 'Slice'
            e[13] = e[14][e[15] ]
            e[11][e[12] ] = e[13]
            e[11] = e[5]
            e[12] = 'SliceCenter'
            e[14] = a.Rect
            e[15] = 'new'
            e[13] = e[14][e[15] ]
            e[14] = 2
            e[15] = 2
            e[16] = 62
            e[17] = 62

            do
                local h = 4
                local i = pack(e[13](b(e, 14, 13 + h)))

                for j = 1, 1 do
                    e[13 + j - 1] = i[j]
                end
            end

            e[11][e[12] ] = e[13]
            e[11] = e[6]
            e[12] = 'Name'
            e[13] = 'SectionOutline1'
            e[11][e[12] ] = e[13]
            e[11] = e[6]
            e[12] = 'Parent'
            e[13] = e[4][1]
            e[11][e[12] ] = e[13]
            e[11] = e[6]
            e[12] = 'BackgroundTransparency'
            e[13] = 1
            e[11][e[12] ] = e[13]
            e[11] = e[6]
            e[12] = 'Position'
            e[14] = a.UDim2
            e[15] = 'new'
            e[13] = e[14][e[15] ]
            e[14] = 0
            e[15] = 1
            e[16] = 0
            e[17] = 1

            do
                local h = 4
                local i = pack(e[13](b(e, 14, 13 + h)))

                for j = 1, 1 do
                    e[13 + j - 1] = i[j]
                end
            end

            e[11][e[12] ] = e[13]
            e[11] = e[6]
            e[12] = 'Size'
            e[14] = a.UDim2
            e[15] = 'new'
            e[13] = e[14][e[15] ]
            e[14] = 1
            e[16] = 2
            e[15] = -e[16]
            e[16] = 1
            e[18] = 2
            e[17] = -e[18]

            do
                local h = 4
                local i = pack(e[13](b(e, 14, 13 + h)))

                for j = 1, 1 do
                    e[13 + j - 1] = i[j]
                end
            end

            e[11][e[12] ] = e[13]
            e[11] = e[6]
            e[12] = 'Image'
            e[13] = 'rbxassetid://2592362371'
            e[11][e[12] ] = e[13]
            e[11] = e[6]
            e[12] = 'ImageColor3'
            e[14] = a.Color3
            e[15] = 'fromRGB'
            e[13] = e[14][e[15] ]
            e[14] = 60
            e[15] = 60
            e[16] = 60

            do
                local h = 3
                local i = pack(e[13](b(e, 14, 13 + h)))

                for j = 1, 1 do
                    e[13 + j - 1] = i[j]
                end
            end

            e[11][e[12] ] = e[13]
            e[11] = e[6]
            e[12] = 'ScaleType'
            e[15] = a.Enum
            e[16] = 'ScaleType'
            e[14] = e[15][e[16] ]
            e[15] = 'Slice'
            e[13] = e[14][e[15] ]
            e[11][e[12] ] = e[13]
            e[11] = e[6]
            e[12] = 'SliceCenter'
            e[14] = a.Rect
            e[15] = 'new'
            e[13] = e[14][e[15] ]
            e[14] = 2
            e[15] = 2
            e[16] = 62
            e[17] = 62

            do
                local h = 4
                local i = pack(e[13](b(e, 14, 13 + h)))

                for j = 1, 1 do
                    e[13 + j - 1] = i[j]
                end
            end

            e[11][e[12] ] = e[13]
            e[11] = e[7]
            e[12] = 'Name'
            e[13] = 'SectionTitleFrame'
            e[11][e[12] ] = e[13]
            e[11] = e[7]
            e[12] = 'Parent'
            e[13] = e[4][1]
            e[11][e[12] ] = e[13]
            e[11] = e[7]
            e[12] = 'BackgroundColor3'
            e[14] = a.Color3
            e[15] = 'fromRGB'
            e[13] = e[14][e[15] ]
            e[14] = 30
            e[15] = 30
            e[16] = 30

            do
                local h = 3
                local i = pack(e[13](b(e, 14, 13 + h)))

                for j = 1, 1 do
                    e[13 + j - 1] = i[j]
                end
            end

            e[11][e[12] ] = e[13]
            e[11] = e[7]
            e[12] = 'BorderSizePixel'
            e[13] = 0
            e[11][e[12] ] = e[13]
            e[11] = e[7]
            e[12] = 'Position'
            e[14] = a.UDim2
            e[15] = 'new'
            e[13] = e[14][e[15] ]
            e[14] = 0
            e[15] = 10
            e[16] = 0
            e[17] = 0

            do
                local h = 4
                local i = pack(e[13](b(e, 14, 13 + h)))

                for j = 1, 1 do
                    e[13 + j - 1] = i[j]
                end
            end

            e[11][e[12] ] = e[13]
            e[11] = e[8]
            e[12] = 'Name'
            e[13] = 'SectionTitle'
            e[11][e[12] ] = e[13]
            e[11] = e[8]
            e[12] = 'Parent'
            e[13] = e[7]
            e[11][e[12] ] = e[13]
            e[11] = e[8]
            e[12] = 'BackgroundTransparency'
            e[13] = 1
            e[11][e[12] ] = e[13]
            e[11] = e[8]
            e[12] = 'Position'
            e[14] = a.UDim2
            e[15] = 'new'
            e[13] = e[14][e[15] ]
            e[14] = 0
            e[15] = 0
            e[16] = 0
            e[18] = 3
            e[17] = -e[18]

            do
                local h = 4
                local i = pack(e[13](b(e, 14, 13 + h)))

                for j = 1, 1 do
                    e[13 + j - 1] = i[j]
                end
            end

            e[11][e[12] ] = e[13]
            e[11] = e[8]
            e[12] = 'Size'
            e[14] = a.UDim2
            e[15] = 'new'
            e[13] = e[14][e[15] ]
            e[14] = 1
            e[15] = 0
            e[16] = 0
            e[17] = 7

            do
                local h = 4
                local i = pack(e[13](b(e, 14, 13 + h)))

                for j = 1, 1 do
                    e[13 + j - 1] = i[j]
                end
            end

            e[11][e[12] ] = e[13]
            e[11] = e[8]
            e[12] = 'Font'
            e[15] = a.Enum
            e[16] = 'Font'
            e[14] = e[15][e[16] ]
            e[15] = 'Code'
            e[13] = e[14][e[15] ]
            e[11][e[12] ] = e[13]
            e[11] = e[8]
            e[12] = 'Text'
            e[13] = e[1]
            e[11][e[12] ] = e[13]
            e[11] = e[8]
            e[12] = 'TextColor3'
            e[14] = a.Color3
            e[15] = 'fromRGB'
            e[13] = e[14][e[15] ]
            e[14] = 230
            e[15] = 230
            e[16] = 230

            do
                local h = 3
                local i = pack(e[13](b(e, 14, 13 + h)))

                for j = 1, 1 do
                    e[13 + j - 1] = i[j]
                end
            end

            e[11][e[12] ] = e[13]
            e[11] = e[8]
            e[12] = 'TextSize'
            e[13] = 14
            e[11][e[12] ] = e[13]
            e[11] = e[9][1]
            e[12] = 'Name'
            e[13] = 'SectionItemHolderFrame'
            e[11][e[12] ] = e[13]
            e[11] = e[9][1]
            e[12] = 'Parent'
            e[13] = e[4][1]
            e[11][e[12] ] = e[13]
            e[11] = e[9][1]
            e[12] = 'AnchorPoint'
            e[14] = a.Vector2
            e[15] = 'new'
            e[13] = e[14][e[15] ]
            e[14] = 0.5
            e[15] = 0

            do
                local h = 2
                local i = pack(e[13](b(e, 14, 13 + h)))

                for j = 1, 1 do
                    e[13 + j - 1] = i[j]
                end
            end

            e[11][e[12] ] = e[13]
            e[11] = e[9][1]
            e[12] = 'BackgroundTransparency'
            e[13] = 1
            e[11][e[12] ] = e[13]
            e[11] = e[9][1]
            e[12] = 'Position'
            e[14] = a.UDim2
            e[15] = 'new'
            e[13] = e[14][e[15] ]
            e[14] = 0.5
            e[15] = 0
            e[16] = 0
            e[17] = 15

            do
                local h = 4
                local i = pack(e[13](b(e, 14, 13 + h)))

                for j = 1, 1 do
                    e[13 + j - 1] = i[j]
                end
            end

            e[11][e[12] ] = e[13]
            e[11] = e[9][1]
            e[12] = 'Size'
            e[14] = a.UDim2
            e[15] = 'new'
            e[13] = e[14][e[15] ]
            e[14] = 1
            e[16] = 16
            e[15] = -e[16]
            e[16] = 0
            e[17] = 0

            do
                local h = 4
                local i = pack(e[13](b(e, 14, 13 + h)))

                for j = 1, 1 do
                    e[13 + j - 1] = i[j]
                end
            end

            e[11][e[12] ] = e[13]
            e[11] = e[10][1]
            e[12] = 'Parent'
            e[13] = e[9][1]
            e[11][e[12] ] = e[13]
            e[11] = e[10][1]
            e[12] = 'SortOrder'
            e[15] = a.Enum
            e[16] = 'SortOrder'
            e[14] = e[15][e[16] ]
            e[15] = 'LayoutOrder'
            e[13] = e[14][e[15] ]
            e[11][e[12] ] = e[13]
            e[11] = e[10][1]
            e[12] = 'Padding'
            e[14] = a.UDim
            e[15] = 'new'
            e[13] = e[14][e[15] ]
            e[14] = 0
            e[15] = 5

            do
                local h = 2
                local i = pack(e[13](b(e, 14, 13 + h)))

                for j = 1, 1 do
                    e[13 + j - 1] = i[j]
                end
            end

            e[11][e[12] ] = e[13]
            e[11] = e[7]
            e[12] = 'Size'
            e[14] = a.UDim2
            e[15] = 'new'
            e[13] = e[14][e[15] ]
            e[14] = 0
            e[18] = e[8]
            e[19] = 'TextBounds'
            e[17] = e[18][e[19] ]
            e[18] = 'X'
            e[16] = e[17][e[18] ]
            e[17] = 6
            e[15] = e[16] + e[17]
            e[16] = 0
            e[17] = 7

            do
                local h = 4
                local i = pack(e[13](b(e, 14, 13 + h)))

                for j = 1, 1 do
                    e[13 + j - 1] = i[j]
                end
            end

            e[11][e[12] ] = e[13]

            for h = 11, 11 do
                e[h] = nil
            end

            e[11] = {
                e[11],
            }
            e[12] = function(...)
                return d.p061({
                    e[4],
                    e[10],
                    aa[2],
                    aa[4],
                    aa[3],
                    aa[5],
                }, ...)
            end
            e[11][1] = e[12]
            e[12] = {}
            e[13] = function(...)
                return d.create_toggle({
                    e[9],
                    aa[6],
                    e[11],
                }, ...)
            end
            e[14] = e[12]
            e[15] = 'Toggle'
            e[14][e[15] ] = e[13]
            e[13] = function(...)
                return d.create_button({
                    e[9],
                    aa[6],
                    e[11],
                }, ...)
            end
            e[14] = e[12]
            e[15] = 'Button'
            e[14][e[15] ] = e[13]
            e[13] = function(...)
                return d.create_slider({
                    e[9],
                    aa[6],
                    e[11],
                }, ...)
            end
            e[14] = e[12]
            e[15] = 'Slider'
            e[14][e[15] ] = e[13]
            e[13] = function(...)
                return d.create_input({
                    e[9],
                    e[11],
                }, ...)
            end
            e[14] = e[12]
            e[15] = 'Input'
            e[14][e[15] ] = e[13]
            e[13] = function(...)
                return d.create_dropdown({
                    e[9],
                    e[11],
                    e[4],
                    e[10],
                    aa[6],
                }, ...)
            end
            e[14] = e[12]
            e[15] = 'Dropdown'
            e[14][e[15] ] = e[13]
            e[13] = function(...)
                return d.create_label({
                    e[9],
                    e[11],
                }, ...)
            end
            e[14] = e[12]
            e[15] = 'Label'
            e[14][e[15] ] = e[13]
            e[13] = e[12]

            local h = 1

            return b(e, 13, 13 + h - 1)
        else
            return
        end
    end
end
d.p059 = function(aa, ...)
    while a.task.wait() do
        if aa[1][1].Visible then
            aa[1][1].BackgroundColor3 = aa[2][1].accentclr
        end
    end
end
d.p058 = function(aa, ...)
    local e = a.game:GetService'TweenService'

    for f, g in a.ipairs(aa[1][1])do
        local h = g.btn == aa[2][1]

        e:Create(g.btn, a.TweenInfo.new(0.12, a.Enum.EasingStyle.Quad), {
            BackgroundColor3 = h and a.Color3.fromRGB(33, 33, 33) or a.Color3.fromRGB(22, 22, 22),
            TextColor3 = h and a.Color3.fromRGB(230, 230, 230) or a.Color3.fromRGB(150, 150, 150),
        }):Play()

        g.topLine.Visible = h
        g.outline.ImageColor3 = h and a.Color3.fromRGB(65, 65, 65) or a.Color3.fromRGB(45, 45, 45)
        g.h1.Visible = h
        g.h2.Visible = h
    end
end
d.create_tab = function(aa, ...)
    local e, f = {}, pack(...)

    for g = 1, 2 do
        e[g - 1] = f[g]
    end

    local g, h = 0, 1

    while true do
        if h == 1 then
            e[2] = 50
            e[2] = {
                e[2],
            }
            e[4] = a.Instance
            e[5] = 'new'
            e[3] = e[4][e[5] ]
            e[4] = 'TextButton'

            do
                local i = 1
                local j = pack(e[3](b(e, 4, 3 + i)))

                for k = 1, 1 do
                    e[3 + k - 1] = j[k]
                end
            end

            e[3] = {
                e[3],
            }
            e[4] = e[3][1]
            e[5] = 'Name'
            e[7] = e[1]
            e[8] = '_TabBtn'
            e[6] = e[7] .. e[8]
            e[4][e[5] ] = e[6]
            e[4] = e[3][1]
            e[5] = 'Parent'
            e[6] = aa[1][1]
            e[4][e[5] ] = e[6]
            e[4] = e[3][1]
            e[5] = 'BackgroundColor3'
            e[7] = a.Color3
            e[8] = 'fromRGB'
            e[6] = e[7][e[8] ]
            e[7] = 25
            e[8] = 25
            e[9] = 25

            do
                local i = 3
                local j = pack(e[6](b(e, 7, 6 + i)))

                for k = 1, 1 do
                    e[6 + k - 1] = j[k]
                end
            end

            e[4][e[5] ] = e[6]
            e[4] = e[3][1]
            e[5] = 'BorderSizePixel'
            e[6] = 0
            e[4][e[5] ] = e[6]
            e[4] = e[3][1]
            e[5] = 'Font'
            e[8] = a.Enum
            e[9] = 'Font'
            e[7] = e[8][e[9] ]
            e[8] = 'Code'
            e[6] = e[7][e[8] ]
            e[4][e[5] ] = e[6]
            e[4] = e[3][1]
            e[5] = 'Text'
            e[6] = e[1]
            e[4][e[5] ] = e[6]
            e[4] = e[3][1]
            e[5] = 'TextColor3'
            e[7] = a.Color3
            e[8] = 'fromRGB'
            e[6] = e[7][e[8] ]
            e[7] = 150
            e[8] = 150
            e[9] = 150

            do
                local i = 3
                local j = pack(e[6](b(e, 7, 6 + i)))

                for k = 1, 1 do
                    e[6 + k - 1] = j[k]
                end
            end

            e[4][e[5] ] = e[6]
            e[4] = e[3][1]
            e[5] = 'TextSize'
            e[6] = 14
            e[4][e[5] ] = e[6]
            e[4] = e[3][1]
            e[5] = 'AutoButtonColor'
            e[6] = false
            e[4][e[5] ] = e[6]
            e[4] = a.game
            e[6] = 'GetService'
            e[5] = e[4]
            e[4] = e[4][e[6] ]
            e[6] = 'TextService'

            do
                local i = 2
                local j = pack(e[4](b(e, 5, 4 + i)))

                for k = 1, 1 do
                    e[4 + k - 1] = j[k]
                end
            end

            e[5] = e[4]
            e[7] = 'GetTextSize'
            e[6] = e[5]
            e[5] = e[5][e[7] ]
            e[7] = e[1]
            e[8] = 14
            e[11] = a.Enum
            e[12] = 'Font'
            e[10] = e[11][e[12] ]
            e[11] = 'Code'
            e[9] = e[10][e[11] ]
            e[11] = a.Vector2
            e[12] = 'new'
            e[10] = e[11][e[12] ]
            e[11] = 500
            e[12] = 500

            do
                local i = 2
                local j = pack(e[10](b(e, 11, 10 + i)))

                for k = 1, j.n do
                    e[10 + k - 1] = j[k]
                end

                g = 10 + j.n
            end
            do
                local i = (g - 5 - 1)
                local j = pack(e[5](b(e, 6, 5 + i)))

                for k = 1, 1 do
                    e[5 + k - 1] = j[k]
                end
            end

            e[6] = e[3][1]
            e[7] = 'Size'
            e[9] = a.UDim2
            e[10] = 'new'
            e[8] = e[9][e[10] ]
            e[9] = 0
            e[12] = e[5]
            e[13] = 'X'
            e[11] = e[12][e[13] ]
            e[12] = 28
            e[10] = e[11] + e[12]
            e[11] = 0
            e[12] = 26

            do
                local i = 4
                local j = pack(e[8](b(e, 9, 8 + i)))

                for k = 1, 1 do
                    e[8 + k - 1] = j[k]
                end
            end

            e[6][e[7] ] = e[8]
            e[7] = a.Instance
            e[8] = 'new'
            e[6] = e[7][e[8] ]
            e[7] = 'Frame'

            do
                local i = 1
                local j = pack(e[6](b(e, 7, 6 + i)))

                for k = 1, 1 do
                    e[6 + k - 1] = j[k]
                end
            end

            e[6] = {
                e[6],
            }
            e[7] = e[6][1]
            e[8] = 'Name'
            e[9] = 'TopLine'
            e[7][e[8] ] = e[9]
            e[7] = e[6][1]
            e[8] = 'Parent'
            e[9] = e[3][1]
            e[7][e[8] ] = e[9]
            e[7] = e[6][1]
            e[8] = 'BackgroundColor3'
            e[10] = aa[2][1]
            e[11] = 'accentclr'
            e[9] = e[10][e[11] ]
            e[7][e[8] ] = e[9]
            e[7] = e[6][1]
            e[8] = 'BorderSizePixel'
            e[9] = 0
            e[7][e[8] ] = e[9]
            e[7] = e[6][1]
            e[8] = 'Position'
            e[10] = a.UDim2
            e[11] = 'new'
            e[9] = e[10][e[11] ]
            e[10] = 0
            e[11] = 0
            e[12] = 0
            e[13] = 0

            do
                local i = 4
                local j = pack(e[9](b(e, 10, 9 + i)))

                for k = 1, 1 do
                    e[9 + k - 1] = j[k]
                end
            end

            e[7][e[8] ] = e[9]
            e[7] = e[6][1]
            e[8] = 'Size'
            e[10] = a.UDim2
            e[11] = 'new'
            e[9] = e[10][e[11] ]
            e[10] = 1
            e[11] = 0
            e[12] = 0
            e[13] = 2

            do
                local i = 4
                local j = pack(e[9](b(e, 10, 9 + i)))

                for k = 1, 1 do
                    e[9 + k - 1] = j[k]
                end
            end

            e[7][e[8] ] = e[9]
            e[7] = e[6][1]
            e[8] = 'Visible'
            e[9] = false
            e[7][e[8] ] = e[9]
            e[8] = a.Instance
            e[9] = 'new'
            e[7] = e[8][e[9] ]
            e[8] = 'ImageLabel'

            do
                local i = 1
                local j = pack(e[7](b(e, 8, 7 + i)))

                for k = 1, 1 do
                    e[7 + k - 1] = j[k]
                end
            end

            e[8] = e[7]
            e[9] = 'Name'
            e[10] = 'Outline'
            e[8][e[9] ] = e[10]
            e[8] = e[7]
            e[9] = 'Parent'
            e[10] = e[3][1]
            e[8][e[9] ] = e[10]
            e[8] = e[7]
            e[9] = 'BackgroundTransparency'
            e[10] = 1
            e[8][e[9] ] = e[10]
            e[8] = e[7]
            e[9] = 'Size'
            e[11] = a.UDim2
            e[12] = 'new'
            e[10] = e[11][e[12] ]
            e[11] = 1
            e[12] = 0
            e[13] = 1
            e[14] = 0

            do
                local i = 4
                local j = pack(e[10](b(e, 11, 10 + i)))

                for k = 1, 1 do
                    e[10 + k - 1] = j[k]
                end
            end

            e[8][e[9] ] = e[10]
            e[8] = e[7]
            e[9] = 'Image'
            e[10] = 'rbxassetid://2592362371'
            e[8][e[9] ] = e[10]
            e[8] = e[7]
            e[9] = 'ImageColor3'
            e[11] = a.Color3
            e[12] = 'fromRGB'
            e[10] = e[11][e[12] ]
            e[11] = 45
            e[12] = 45
            e[13] = 45

            do
                local i = 3
                local j = pack(e[10](b(e, 11, 10 + i)))

                for k = 1, 1 do
                    e[10 + k - 1] = j[k]
                end
            end

            e[8][e[9] ] = e[10]
            e[8] = e[7]
            e[9] = 'ScaleType'
            e[12] = a.Enum
            e[13] = 'ScaleType'
            e[11] = e[12][e[13] ]
            e[12] = 'Slice'
            e[10] = e[11][e[12] ]
            e[8][e[9] ] = e[10]
            e[8] = e[7]
            e[9] = 'SliceCenter'
            e[11] = a.Rect
            e[12] = 'new'
            e[10] = e[11][e[12] ]
            e[11] = 2
            e[12] = 2
            e[13] = 62
            e[14] = 62

            do
                local i = 4
                local j = pack(e[10](b(e, 11, 10 + i)))

                for k = 1, 1 do
                    e[10 + k - 1] = j[k]
                end
            end

            e[8][e[9] ] = e[10]
            e[9] = a.Instance
            e[10] = 'new'
            e[8] = e[9][e[10] ]
            e[9] = 'ScrollingFrame'

            do
                local i = 1
                local j = pack(e[8](b(e, 9, 8 + i)))

                for k = 1, 1 do
                    e[8 + k - 1] = j[k]
                end
            end

            e[8] = {
                e[8],
            }
            e[10] = a.Instance
            e[11] = 'new'
            e[9] = e[10][e[11] ]
            e[10] = 'UIPadding'

            do
                local i = 1
                local j = pack(e[9](b(e, 10, 9 + i)))

                for k = 1, 1 do
                    e[9 + k - 1] = j[k]
                end
            end

            e[11] = a.Instance
            e[12] = 'new'
            e[10] = e[11][e[12] ]
            e[11] = 'UIListLayout'

            do
                local i = 1
                local j = pack(e[10](b(e, 11, 10 + i)))

                for k = 1, 1 do
                    e[10 + k - 1] = j[k]
                end
            end

            e[10] = {
                e[10],
            }
            e[12] = a.Instance
            e[13] = 'new'
            e[11] = e[12][e[13] ]
            e[12] = 'ScrollingFrame'

            do
                local i = 1
                local j = pack(e[11](b(e, 12, 11 + i)))

                for k = 1, 1 do
                    e[11 + k - 1] = j[k]
                end
            end

            e[11] = {
                e[11],
            }
            e[13] = a.Instance
            e[14] = 'new'
            e[12] = e[13][e[14] ]
            e[13] = 'UIPadding'

            do
                local i = 1
                local j = pack(e[12](b(e, 13, 12 + i)))

                for k = 1, 1 do
                    e[12 + k - 1] = j[k]
                end
            end

            e[14] = a.Instance
            e[15] = 'new'
            e[13] = e[14][e[15] ]
            e[14] = 'UIListLayout'

            do
                local i = 1
                local j = pack(e[13](b(e, 14, 13 + i)))

                for k = 1, 1 do
                    e[13 + k - 1] = j[k]
                end
            end

            e[13] = {
                e[13],
            }
            e[14] = e[8][1]
            e[15] = 'Name'
            e[17] = e[1]
            e[18] = '_Holder1'
            e[16] = e[17] .. e[18]
            e[14][e[15] ] = e[16]
            e[14] = e[8][1]
            e[15] = 'Parent'
            e[16] = aa[3][1]
            e[14][e[15] ] = e[16]
            e[14] = e[8][1]
            e[15] = 'Active'
            e[16] = true
            e[14][e[15] ] = e[16]
            e[14] = e[8][1]
            e[15] = 'BackgroundTransparency'
            e[16] = 1
            e[14][e[15] ] = e[16]
            e[14] = e[8][1]
            e[15] = 'BorderSizePixel'
            e[16] = 0
            e[14][e[15] ] = e[16]
            e[14] = e[8][1]
            e[15] = 'Position'
            e[17] = a.UDim2
            e[18] = 'new'
            e[16] = e[17][e[18] ]
            e[17] = 0
            e[18] = 1
            e[19] = 0
            e[20] = 35

            do
                local i = 4
                local j = pack(e[16](b(e, 17, 16 + i)))

                for k = 1, 1 do
                    e[16 + k - 1] = j[k]
                end
            end

            e[14][e[15] ] = e[16]
            e[14] = e[8][1]
            e[15] = 'Size'
            e[17] = a.UDim2
            e[18] = 'new'
            e[16] = e[17][e[18] ]
            e[17] = 0
            e[18] = 245
            e[19] = 1
            e[21] = 40
            e[20] = -e[21]

            do
                local i = 4
                local j = pack(e[16](b(e, 17, 16 + i)))

                for k = 1, 1 do
                    e[16 + k - 1] = j[k]
                end
            end

            e[14][e[15] ] = e[16]
            e[14] = e[8][1]
            e[15] = 'Visible'
            e[16] = false
            e[14][e[15] ] = e[16]
            e[14] = e[8][1]
            e[15] = 'CanvasSize'
            e[17] = a.UDim2
            e[18] = 'new'
            e[16] = e[17][e[18] ]
            e[17] = 0
            e[18] = 0
            e[19] = 0
            e[20] = 0

            do
                local i = 4
                local j = pack(e[16](b(e, 17, 16 + i)))

                for k = 1, 1 do
                    e[16 + k - 1] = j[k]
                end
            end

            e[14][e[15] ] = e[16]
            e[14] = e[8][1]
            e[15] = 'ScrollBarThickness'
            e[16] = 4
            e[14][e[15] ] = e[16]
            e[14] = e[8][1]
            e[15] = 'ScrollingEnabled'
            e[16] = true
            e[14][e[15] ] = e[16]
            e[14] = e[9]
            e[15] = 'Parent'
            e[16] = e[8][1]
            e[14][e[15] ] = e[16]
            e[14] = e[9]
            e[15] = 'PaddingTop'
            e[17] = a.UDim
            e[18] = 'new'
            e[16] = e[17][e[18] ]
            e[17] = 0
            e[18] = 5

            do
                local i = 2
                local j = pack(e[16](b(e, 17, 16 + i)))

                for k = 1, 1 do
                    e[16 + k - 1] = j[k]
                end
            end

            e[14][e[15] ] = e[16]
            e[14] = e[10][1]
            e[15] = 'Parent'
            e[16] = e[8][1]
            e[14][e[15] ] = e[16]
            e[14] = e[10][1]
            e[15] = 'SortOrder'
            e[18] = a.Enum
            e[19] = 'SortOrder'
            e[17] = e[18][e[19] ]
            e[18] = 'LayoutOrder'
            e[16] = e[17][e[18] ]
            e[14][e[15] ] = e[16]
            e[14] = e[10][1]
            e[15] = 'Padding'
            e[17] = a.UDim
            e[18] = 'new'
            e[16] = e[17][e[18] ]
            e[17] = 0
            e[18] = 10

            do
                local i = 2
                local j = pack(e[16](b(e, 17, 16 + i)))

                for k = 1, 1 do
                    e[16 + k - 1] = j[k]
                end
            end

            e[14][e[15] ] = e[16]
            e[14] = e[11][1]
            e[15] = 'Name'
            e[17] = e[1]
            e[18] = '_Holder2'
            e[16] = e[17] .. e[18]
            e[14][e[15] ] = e[16]
            e[14] = e[11][1]
            e[15] = 'Parent'
            e[16] = aa[3][1]
            e[14][e[15] ] = e[16]
            e[14] = e[11][1]
            e[15] = 'Active'
            e[16] = true
            e[14][e[15] ] = e[16]
            e[14] = e[11][1]
            e[15] = 'BackgroundTransparency'
            e[16] = 1
            e[14][e[15] ] = e[16]
            e[14] = e[11][1]
            e[15] = 'BorderSizePixel'
            e[16] = 0
            e[14][e[15] ] = e[16]
            e[14] = e[11][1]
            e[15] = 'Position'
            e[17] = a.UDim2
            e[18] = 'new'
            e[16] = e[17][e[18] ]
            e[17] = 0
            e[18] = 255
            e[19] = 0
            e[20] = 35

            do
                local i = 4
                local j = pack(e[16](b(e, 17, 16 + i)))

                for k = 1, 1 do
                    e[16 + k - 1] = j[k]
                end
            end

            e[14][e[15] ] = e[16]
            e[14] = e[11][1]
            e[15] = 'Size'
            e[17] = a.UDim2
            e[18] = 'new'
            e[16] = e[17][e[18] ]
            e[17] = 0
            e[18] = 245
            e[19] = 1
            e[21] = 40
            e[20] = -e[21]

            do
                local i = 4
                local j = pack(e[16](b(e, 17, 16 + i)))

                for k = 1, 1 do
                    e[16 + k - 1] = j[k]
                end
            end

            e[14][e[15] ] = e[16]
            e[14] = e[11][1]
            e[15] = 'Visible'
            e[16] = false
            e[14][e[15] ] = e[16]
            e[14] = e[11][1]
            e[15] = 'CanvasSize'
            e[17] = a.UDim2
            e[18] = 'new'
            e[16] = e[17][e[18] ]
            e[17] = 0
            e[18] = 0
            e[19] = 0
            e[20] = 0

            do
                local i = 4
                local j = pack(e[16](b(e, 17, 16 + i)))

                for k = 1, 1 do
                    e[16 + k - 1] = j[k]
                end
            end

            e[14][e[15] ] = e[16]
            e[14] = e[11][1]
            e[15] = 'ScrollBarThickness'
            e[16] = 4
            e[14][e[15] ] = e[16]
            e[14] = e[11][1]
            e[15] = 'ScrollingEnabled'
            e[16] = true
            e[14][e[15] ] = e[16]
            e[14] = e[12]
            e[15] = 'Parent'
            e[16] = e[11][1]
            e[14][e[15] ] = e[16]
            e[14] = e[12]
            e[15] = 'PaddingTop'
            e[17] = a.UDim
            e[18] = 'new'
            e[16] = e[17][e[18] ]
            e[17] = 0
            e[18] = 5

            do
                local i = 2
                local j = pack(e[16](b(e, 17, 16 + i)))

                for k = 1, 1 do
                    e[16 + k - 1] = j[k]
                end
            end

            e[14][e[15] ] = e[16]
            e[14] = e[13][1]
            e[15] = 'Parent'
            e[16] = e[11][1]
            e[14][e[15] ] = e[16]
            e[14] = e[13][1]
            e[15] = 'SortOrder'
            e[18] = a.Enum
            e[19] = 'SortOrder'
            e[17] = e[18][e[19] ]
            e[18] = 'LayoutOrder'
            e[16] = e[17][e[18] ]
            e[14][e[15] ] = e[16]
            e[14] = e[13][1]
            e[15] = 'Padding'
            e[17] = a.UDim
            e[18] = 'new'
            e[16] = e[17][e[18] ]
            e[17] = 0
            e[18] = 10

            do
                local i = 2
                local j = pack(e[16](b(e, 17, 16 + i)))

                for k = 1, 1 do
                    e[16 + k - 1] = j[k]
                end
            end

            e[14][e[15] ] = e[16]
            e[15] = a.table
            e[16] = 'insert'
            e[14] = e[15][e[16] ]
            e[15] = aa[4][1]
            e[16] = {}
            e[17] = 'btn'
            e[18] = e[3][1]
            e[16][e[17] ] = e[18]
            e[17] = 'topLine'
            e[18] = e[6][1]
            e[16][e[17] ] = e[18]
            e[17] = 'outline'
            e[18] = e[7]
            e[16][e[17] ] = e[18]
            e[17] = 'h1'
            e[18] = e[8][1]
            e[16][e[17] ] = e[18]
            e[17] = 'h2'
            e[18] = e[11][1]
            e[16][e[17] ] = e[18]

            do
                local i = 2

                e[14](b(e, 15, 14 + i))
            end

            e[15] = aa[5][1]
            e[16] = false
            e[14] = e[15] == e[16]

            if (not not e[14]) == false then
                h = 3
            else
                h = 2
            end
        elseif h == 2 then
            e[14] = true
            aa[5][1] = e[14]
            e[14] = e[8][1]
            e[15] = 'Visible'
            e[16] = true
            e[14][e[15] ] = e[16]
            e[14] = e[11][1]
            e[15] = 'Visible'
            e[16] = true
            e[14][e[15] ] = e[16]
            e[14] = e[3][1]
            e[15] = 'BackgroundColor3'
            e[17] = a.Color3
            e[18] = 'fromRGB'
            e[16] = e[17][e[18] ]
            e[17] = 33
            e[18] = 33
            e[19] = 33

            do
                local i = 3
                local j = pack(e[16](b(e, 17, 16 + i)))

                for k = 1, 1 do
                    e[16 + k - 1] = j[k]
                end
            end

            e[14][e[15] ] = e[16]
            e[14] = e[3][1]
            e[15] = 'TextColor3'
            e[17] = a.Color3
            e[18] = 'fromRGB'
            e[16] = e[17][e[18] ]
            e[17] = 230
            e[18] = 230
            e[19] = 230

            do
                local i = 3
                local j = pack(e[16](b(e, 17, 16 + i)))

                for k = 1, 1 do
                    e[16 + k - 1] = j[k]
                end
            end

            e[14][e[15] ] = e[16]
            e[14] = e[6][1]
            e[15] = 'Visible'
            e[16] = true
            e[14][e[15] ] = e[16]
            e[14] = e[7]
            e[15] = 'ImageColor3'
            e[17] = a.Color3
            e[18] = 'fromRGB'
            e[16] = e[17][e[18] ]
            e[17] = 65
            e[18] = 65
            e[19] = 65

            do
                local i = 3
                local j = pack(e[16](b(e, 17, 16 + i)))

                for k = 1, 1 do
                    e[16 + k - 1] = j[k]
                end
            end

            e[14][e[15] ] = e[16]
            h = 3
        elseif h == 3 then
            e[15] = e[3][1]
            e[16] = 'MouseButton1Click'
            e[14] = e[15][e[16] ]
            e[16] = 'Connect'
            e[15] = e[14]
            e[14] = e[14][e[16] ]
            e[16] = function(...)
                return d.p058({
                    aa[4],
                    e[3],
                }, ...)
            end

            do
                local i = 2

                e[14](b(e, 15, 14 + i))
            end

            e[15] = a.coroutine
            e[16] = 'wrap'
            e[14] = e[15][e[16] ]
            e[15] = function(...)
                return d.p059({
                    e[6],
                    aa[2],
                }, ...)
            end

            do
                local i = 1
                local j = pack(e[14](b(e, 15, 14 + i)))

                for k = 1, 1 do
                    e[14 + k - 1] = j[k]
                end
            end
            do
                local i = 0

                e[14](b(e, 15, 14 + i))
            end

            e[14] = {}
            e[15] = function(...)
                return d.create_section({
                    e[2],
                    e[8],
                    e[11],
                    e[10],
                    e[13],
                    aa[2],
                }, ...)
            end
            e[16] = e[14]
            e[17] = 'Section'
            e[16][e[17] ] = e[15]
            e[15] = function(...)
                return d.create_multisection({
                    e[2],
                    e[8],
                    e[11],
                    e[10],
                    e[13],
                    aa[2],
                }, ...)
            end
            e[16] = e[14]
            e[17] = 'MultiSection'
            e[16][e[17] ] = e[15]
            e[15] = e[14]

            local i = 1

            return b(e, 15, 15 + i - 1)
        else
            return
        end
    end
end
d.update_cursor = function(aa)
    while a.task.wait() do
        local e = aa[2][1].accentclr

        aa[1][1].BackgroundColor3 = e
        aa[3][1].Color = e
        aa[4][1].BackgroundColor3 = e

        if aa[5][1] then
            local f = a.game:GetService'UserInputService':GetMouseLocation()

            aa[4][1].Position = a.UDim2.new(0, f.X, 0, f.Y)
        end
    end
end
d.p055 = function(aa)
    aa[1][1] = (not aa[1][1])

    aa[2][1]()

    return
end
d.menu_key_handler = function(aa, e, f)
    local g, h

    g = e
    h = f

    if (not (g.KeyCode == a.Enum.KeyCode.RightShift)) then
    else
        aa[1][1] = (not aa[1][1])

        aa[2][1]()
    end

    return
end
d.set_window_visible = function(aa)
    local e

    aa[1][1].Visible = aa[2][1]
    aa[3][1].Visible = aa[2][1]

    local f = a.game:GetService'UserInputService'

    f.MouseBehavior = a.Enum.MouseBehavior.Default

    local g = a.game:GetService'TweenService'

    e = g

    if (not aa[2][1]) then
        local h, i = a.TweenInfo.new(0.2, a.Enum.EasingStyle.Quad, a.Enum.EasingDirection.Out), {}

        i.Size = 0

        local j = e:Create(aa[4][1], h, i)

        j:Play()
    else
        local h, i = a.TweenInfo.new(0.2, a.Enum.EasingStyle.Quad, a.Enum.EasingDirection.Out), {}

        i.Size = 18

        local j = e:Create(aa[4][1], h, i)

        j:Play()

        aa[1][1].BackgroundTransparency = 1

        local k, l = a.TweenInfo.new(0.2, a.Enum.EasingStyle.Quad, a.Enum.EasingDirection.Out), {}

        l.BackgroundTransparency = 0.15

        local m = e:Create(aa[1][1], k, l)

        m:Play()
    end

    return
end
d.create_window = function(aa, e, f)
    local g, h, i, j, k, l, m, n, o, p, q, r, s

    g = e
    h = f

    local t, u, v = {true}, {false}, {}
    local w, x = {v}, a.Instance.new'Frame'
    local y, z, A, B = {x}, a.Instance.new'ImageLabel', a.Instance.new'ImageLabel', a.Instance.new'Frame'
    local C, D = {B}, a.Instance.new'ScrollingFrame'
    local E, F, G, H, I, J = {D}, a.Instance.new'UIListLayout', a.Instance.new'UIPadding', a.Instance.new'Frame', a.Instance.new'TextLabel', a.Instance.new'Frame'
    local K = {J}

    y[1].Name = 'MainFrame'
    y[1].Parent = aa[1][1]

    local L = a.Vector2.new(0.5, 0.5)

    y[1].AnchorPoint = L

    local M = a.Color3.fromRGB(20, 20, 20)

    y[1].BackgroundColor3 = M
    y[1].BackgroundTransparency = 0.15

    local N = a.Color3.fromRGB(60, 60, 60)

    y[1].BorderColor3 = N
    y[1].BorderSizePixel = 0

    local O = a.UDim2.new(0.5, 0, 0.5, 0)

    y[1].Position = O

    local P = a.UDim2.new(0, 525, 0, 631)

    y[1].Size = P
    y[1].Visible = true
    y[1].ClipsDescendants = true
    z.Name = 'OutlineMainFrame1'
    z.Parent = y[1]
    z.BackgroundTransparency = 1

    local Q = a.UDim2.new(0, 1, 0, 1)

    z.Position = Q

    local R = a.UDim2.new(1, (-2), 1, (-2))

    z.Size = R
    z.Image = 'rbxassetid://2592362371'

    local S = a.Color3.fromRGB(60, 60, 60)

    z.ImageColor3 = S
    z.ScaleType = a.Enum.ScaleType.Slice

    local T = a.Rect.new(2, 2, 62, 62)

    z.SliceCenter = T
    A.Name = 'OutlineMainFrame2'
    A.Parent = y[1]
    A.BackgroundTransparency = 1

    local U = a.UDim2.new(1, 0, 1, 0)

    A.Size = U
    A.Image = 'rbxassetid://2592362371'

    local V = a.Color3.fromRGB(0, 0, 0)

    A.ImageColor3 = V
    A.ScaleType = a.Enum.ScaleType.Slice

    local W = a.Rect.new(2, 2, 62, 62)

    A.SliceCenter = W
    C[1].Name = 'ContainerHolderFrame'
    C[1].Parent = y[1]

    local X = a.Vector2.new(0.5, 0)

    C[1].AnchorPoint = X

    local Y = a.Color3.fromRGB(24, 24, 24)

    C[1].BackgroundColor3 = Y

    local Z = a.UDim2.new(0.5, 0, 0.071, 10)

    C[1].Position = Z

    local _ = a.UDim2.new(1, (-18), 1, (-42))

    C[1].Size = _
    C[1].BackgroundTransparency = 1
    C[1].ClipsDescendants = true
    E[1].Name = 'TabHolderFrame'
    E[1].Parent = C[1]
    E[1].BackgroundTransparency = 1

    local ab = a.UDim2.new(1, 0, 0, 32)

    E[1].Size = ab
    E[1].Visible = true

    local ac = a.UDim2.new(0, 700, 0, 0)

    E[1].CanvasSize = ac
    E[1].ScrollBarThickness = 0
    F.Name = 'TabHolderFrameLayout'
    F.Parent = E[1]
    F.FillDirection = a.Enum.FillDirection.Horizontal
    F.SortOrder = a.Enum.SortOrder.LayoutOrder

    local ad = a.UDim.new(0, 4)

    F.Padding = ad
    G.Name = 'TabHolderFramePadding'
    G.Parent = E[1]

    local ae = a.UDim.new(0, 5)

    G.PaddingLeft = ae
    H.Name = 'TopBar'
    H.Parent = y[1]

    local af = a.Vector2.new(0.5, 0)

    H.AnchorPoint = af

    local ag = a.Color3.fromRGB(24, 24, 24)

    H.BackgroundColor3 = ag
    H.BorderSizePixel = 0

    local ah = a.UDim2.new(0.5, 0, 0, 2)

    H.Position = ah

    local ai = a.UDim2.new(1, (-5), 0, 28)

    H.Size = ai
    I.Name = 'TopBarTitle'
    I.Parent = H
    I.BackgroundTransparency = 1

    local aj = a.UDim2.new(0, 7, 0, 5)

    I.Position = aj

    local ak = a.UDim2.new(0, 0, 0, 16)

    I.Size = ak
    I.Font = a.Enum.Font.Code
    I.Text = h

    local al = a.Color3.fromRGB(230, 230, 230)

    I.TextColor3 = al
    I.TextSize = 16
    I.TextXAlignment = a.Enum.TextXAlignment.Left
    K[1].Name = 'TopBarLine'
    K[1].Parent = H
    K[1].BackgroundColor3 = aa[2][1].accentclr
    K[1].BorderSizePixel = 0

    local am = a.UDim2.new(0, 0, 0, 27)

    K[1].Position = am

    local an = a.UDim2.new(1, 0, 0, 1)

    K[1].Size = an

    aa[3][1](H, y[1])

    local ao = a.game:GetService'Lighting'
    local ap = {ao}
    local aq = ap[1]:FindFirstChild'ValkUIBlur'

    i = t
    j = u
    k = w
    l = y
    m = C
    n = E
    o = K
    p = ap
    q = aq

    if (aq) then
    else
        local ar = a.Instance.new'BlurEffect'

        q = ar
    end

    local ar = {q}

    ar[1].Name = 'ValkUIBlur'
    ar[1].Size = 0
    ar[1].Parent = p[1]

    local as = {nil}

    as[1] = function(...)
        return d.set_window_visible({
            l,
            i,
            aa[4],
            ar,
        }, ...)
    end

    local at = a.game:GetService'UserInputService'

    at.InputBegan:Connect(function(...)
        return d.menu_key_handler({i, as}, ...)
    end)

    local au = a.game:GetService'CoreGui'
    local av = au:FindFirstChild'ExecutorToggleUI'

    r = as
    s = au

    if (not av) then
    else
        s.ExecutorToggleUI:Destroy()
    end

    local aw = a.Instance.new'ScreenGui'

    aw.Name = 'ExecutorToggleUI'
    aw.ResetOnSpawn = false
    aw.Parent = s

    local ax = a.Instance.new'TextButton'

    ax.Name = 'ToggleFrame'

    local ay = a.UDim2.new(0, 65, 0, 36)

    ax.Size = ay

    local az = a.UDim2.new(0, 20, 0, 20)

    ax.Position = az

    local aA = a.Color3.fromRGB(30, 30, 30)

    ax.BackgroundColor3 = aA
    ax.BorderSizePixel = 0
    ax.Active = true
    ax.Draggable = true
    ax.Parent = aw

    local aB = a.Instance.new'UIStroke'
    local aC = {aB}

    aC[1].Color = aa[2][1].accentclr
    aC[1].Thickness = 2
    aC[1].Parent = ax

    local aD, aE = a.Instance.new'TextLabel', a.UDim2.new(1, (-6), 0, 16)

    aD.Size = aE

    local aF = a.UDim2.new(0, 3, 0, 2)

    aD.Position = aF
    aD.BackgroundTransparency = 1
    aD.Text = 'Toggle'

    local aG = a.Color3.fromRGB(230, 230, 230)

    aD.TextColor3 = aG
    aD.TextSize = 12
    aD.Font = a.Enum.Font.GothamBold
    aD.TextXAlignment = a.Enum.TextXAlignment.Left
    aD.Parent = ax

    local aH, aI = a.Instance.new'TextLabel', a.UDim2.new(1, (-6), 0, 16)

    aH.Size = aI

    local aJ = a.UDim2.new(0, 3, 0, 18)

    aH.Position = aJ
    aH.BackgroundTransparency = 1
    aH.Text = 'Look'

    local aK = a.Color3.fromRGB(230, 230, 230)

    aH.TextColor3 = aK
    aH.TextSize = 12
    aH.Font = a.Enum.Font.GothamBold
    aH.TextXAlignment = a.Enum.TextXAlignment.Left
    aH.Parent = ax

    ax.MouseButton1Click:Connect(function(...)
        return d.p055({i, r}, ...)
    end)

    local aL = a.coroutine.wrap(function(...)
        return d.update_cursor({
            o,
            aa[2],
            aC,
            aa[4],
            i,
        }, ...)
    end)

    aL()

    local aM = {}

    aM.Tab = function(...)
        return d.create_tab({
            n,
            aa[2],
            m,
            k,
            j,
        }, ...)
    end
    aM.Destroy = function(...)
        return d.destroy_ui_blur({
            p,
            aa[1],
        }, ...)
    end

    a.task.spawn(function(...)
        return d.animate_ui_blur({
            aa[1],
            aa[2],
            i,
            r,
        }, ...)
    end)

    return aM
end
d.p051 = function(aa)
    aa[1][1]:Destroy()

    return
end
d.p050 = function(aa)
    a.pcall(function(...)
        return d.p051({
            aa[1],
        }, ...)
    end)
    aa[2][1]()

    return
end
d.p049 = function(aa, ...)
    for ab, ac in a.ipairs(aa[1][1])do
        if ac.bar == aa[2][1] then
            a.table.remove(aa[1][1], ab)

            break
        end
    end

    local ab = aa[2][1]

    if not ab or not ab.Parent then
        aa[3][1]()

        return
    end

    local ac = aa[4][1]
    local ad, ae, af = ac:Create(aa[5][1], a.TweenInfo.new(0.15, a.Enum.EasingStyle.Quad, a.Enum.EasingDirection.In), {TextTransparency = 1}), ac:Create(ab, a.TweenInfo.new(0.22, a.Enum.EasingStyle.Quart, a.Enum.EasingDirection.In), {
        Size = a.UDim2.new(0, 0, 0, aa[6][1]),
        BackgroundTransparency = 1,
    }), ac:Create(aa[7][1], a.TweenInfo.new(0.22), {Transparency = 1})

    ad:Play()
    ae:Play()
    af:Play()
    ae.Completed:Connect(function(...)
        return d.p050({
            aa[2],
            aa[3],
        }, ...)
    end)
end
d.p048 = function(aa)
    aa[1][1]:Play()

    return
end
d.p047 = function(aa)
    if (not aa[1][1].bar) then
    else
        aa[1][1].bar:Destroy()
    end

    return
end
d.p046 = function(aa)
    a.pcall(function(...)
        return d.p047({
            aa[1],
        }, ...)
    end)
    aa[2][1]()

    return
end
d.show_notification = function(aa, ...)
    local ab, ac = {}, pack(...)

    for ad = 1, 4 do
        ab[ad - 1] = ac[ad]
    end

    local ad, ae = 0, 1

    while true do
        if ae == 1 then
            ab[4] = ab[3]

            if (not not ab[4]) == true then
                ae = 3
            else
                ae = 2
            end
        elseif ae == 2 then
            ab[4] = aa[1][1]
            ae = 3
        elseif ae == 3 then
            ab[3] = ab[4]
            ab[4] = a.tostring
            ab[5] = ab[1]

            if (not not ab[5]) == true then
                ae = 5
            else
                ae = 4
            end
        elseif ae == 4 then
            ab[5] = ''
            ae = 5
        elseif ae == 5 then
            do
                local af = 1
                local ag = pack(ab[4](b(ab, 5, 4 + af)))

                for ah = 1, 1 do
                    ab[4 + ah - 1] = ag[ah]
                end
            end

            ab[5] = ab[2]

            if (not not ab[5]) == false then
                ae = 7
            else
                ae = 6
            end
        elseif ae == 6 then
            ab[6] = ab[2]
            ab[7] = ''
            ab[5] = ab[6] ~= ab[7]
            ae = 7
        elseif ae == 7 then
            if (not not ab[5]) == false then
                ae = 9
            else
                ae = 8
            end
        elseif ae == 8 then
            ab[6] = ab[4]
            ab[8] = '  \u{b7}  '
            ab[9] = a.tostring
            ab[10] = ab[2]

            do
                local af = 1
                local ag = pack(ab[9](b(ab, 10, 9 + af)))

                for ah = 1, 1 do
                    ab[9 + ah - 1] = ag[ah]
                end
            end

            ab[7] = ab[8] .. ab[9]
            ab[5] = ab[6] .. ab[7]
            ab[4] = ab[5]
            ae = 9
        elseif ae == 9 then
            ab[5] = a.game
            ab[7] = 'GetService'
            ab[6] = ab[5]
            ab[5] = ab[5][ab[7] ]
            ab[7] = 'TweenService'

            do
                local af = 2
                local ag = pack(ab[5](b(ab, 6, 5 + af)))

                for ah = 1, 1 do
                    ab[5 + ah - 1] = ag[ah]
                end
            end

            ab[5] = {
                ab[5],
            }
            ae = 10
        elseif ae == 10 then
            ab[8] = aa[2][1]
            ab[7] = #ab[8]
            ab[8] = aa[3][1]
            ab[6] = ab[7] >= ab[8]

            if (not not ab[6]) == false then
                ae = 18
            else
                ae = 11
            end
        elseif ae == 11 then
            ab[7] = a.table
            ab[8] = 'remove'
            ab[6] = ab[7][ab[8] ]
            ab[7] = aa[2][1]

            do
                local af = 1
                local ag = pack(ab[6](b(ab, 7, 6 + af)))

                for ah = 1, 1 do
                    ab[6 + ah - 1] = ag[ah]
                end
            end

            ab[6] = {
                ab[6],
            }
            ab[7] = ab[6][1]

            if (not not ab[7]) == false then
                ae = 13
            else
                ae = 12
            end
        elseif ae == 12 then
            ab[8] = ab[6][1]
            ab[9] = 'bar'
            ab[7] = ab[8][ab[9] ]
            ae = 13
        elseif ae == 13 then
            if (not not ab[7]) == false then
                ae = 15
            else
                ae = 14
            end
        elseif ae == 14 then
            ab[9] = ab[6][1]
            ab[10] = 'bar'
            ab[8] = ab[9][ab[10] ]
            ab[9] = 'Parent'
            ab[7] = ab[8][ab[9] ]
            ae = 15
        elseif ae == 15 then
            if (not not ab[7]) == false then
                ae = 17
            else
                ae = 16
            end
        elseif ae == 16 then
            ab[7] = ab[5][1]
            ab[9] = 'Create'
            ab[8] = ab[7]
            ab[7] = ab[7][ab[9] ]
            ab[10] = ab[6][1]
            ab[11] = 'label'
            ab[9] = ab[10][ab[11] ]
            ab[11] = a.TweenInfo
            ab[12] = 'new'
            ab[10] = ab[11][ab[12] ]
            ab[11] = 0.15
            ab[14] = a.Enum
            ab[15] = 'EasingStyle'
            ab[13] = ab[14][ab[15] ]
            ab[14] = 'Quad'
            ab[12] = ab[13][ab[14] ]
            ab[15] = a.Enum
            ab[16] = 'EasingDirection'
            ab[14] = ab[15][ab[16] ]
            ab[15] = 'In'
            ab[13] = ab[14][ab[15] ]

            do
                local af = 3
                local ag = pack(ab[10](b(ab, 11, 10 + af)))

                for ah = 1, 1 do
                    ab[10 + ah - 1] = ag[ah]
                end
            end

            ab[11] = {}
            ab[12] = 'TextTransparency'
            ab[13] = 1
            ab[11][ab[12] ] = ab[13]

            do
                local af = 4
                local ag = pack(ab[7](b(ab, 8, 7 + af)))

                for ah = 1, 1 do
                    ab[7 + ah - 1] = ag[ah]
                end
            end

            ab[8] = ab[5][1]
            ab[10] = 'Create'
            ab[9] = ab[8]
            ab[8] = ab[8][ab[10] ]
            ab[11] = ab[6][1]
            ab[12] = 'bar'
            ab[10] = ab[11][ab[12] ]
            ab[12] = a.TweenInfo
            ab[13] = 'new'
            ab[11] = ab[12][ab[13] ]
            ab[12] = 0.2
            ab[15] = a.Enum
            ab[16] = 'EasingStyle'
            ab[14] = ab[15][ab[16] ]
            ab[15] = 'Quart'
            ab[13] = ab[14][ab[15] ]
            ab[16] = a.Enum
            ab[17] = 'EasingDirection'
            ab[15] = ab[16][ab[17] ]
            ab[16] = 'In'
            ab[14] = ab[15][ab[16] ]

            do
                local af = 3
                local ag = pack(ab[11](b(ab, 12, 11 + af)))

                for ah = 1, 1 do
                    ab[11 + ah - 1] = ag[ah]
                end
            end

            ab[12] = {}
            ab[13] = 'Size'
            ab[15] = a.UDim2
            ab[16] = 'new'
            ab[14] = ab[15][ab[16] ]
            ab[15] = 0
            ab[16] = 0
            ab[17] = 0
            ab[18] = aa[4][1]

            do
                local af = 4
                local ag = pack(ab[14](b(ab, 15, 14 + af)))

                for ah = 1, 1 do
                    ab[14 + ah - 1] = ag[ah]
                end
            end

            ab[12][ab[13] ] = ab[14]
            ab[13] = 'BackgroundTransparency'
            ab[14] = 1
            ab[12][ab[13] ] = ab[14]

            do
                local af = 4
                local ag = pack(ab[8](b(ab, 9, 8 + af)))

                for ah = 1, 1 do
                    ab[8 + ah - 1] = ag[ah]
                end
            end

            ab[9] = ab[5][1]
            ab[11] = 'Create'
            ab[10] = ab[9]
            ab[9] = ab[9][ab[11] ]
            ab[12] = ab[6][1]
            ab[13] = 'stroke'
            ab[11] = ab[12][ab[13] ]
            ab[13] = a.TweenInfo
            ab[14] = 'new'
            ab[12] = ab[13][ab[14] ]
            ab[13] = 0.2

            do
                local af = 1
                local ag = pack(ab[12](b(ab, 13, 12 + af)))

                for ah = 1, 1 do
                    ab[12 + ah - 1] = ag[ah]
                end
            end

            ab[13] = {}
            ab[14] = 'Transparency'
            ab[15] = 1
            ab[13][ab[14] ] = ab[15]

            do
                local af = 4
                local ag = pack(ab[9](b(ab, 10, 9 + af)))

                for ah = 1, 1 do
                    ab[9 + ah - 1] = ag[ah]
                end
            end

            ab[10] = ab[7]
            ab[12] = 'Play'
            ab[11] = ab[10]
            ab[10] = ab[10][ab[12] ]

            do
                local af = 1

                ab[10](b(ab, 11, 10 + af))
            end

            ab[10] = ab[8]
            ab[12] = 'Play'
            ab[11] = ab[10]
            ab[10] = ab[10][ab[12] ]

            do
                local af = 1

                ab[10](b(ab, 11, 10 + af))
            end

            ab[10] = ab[9]
            ab[12] = 'Play'
            ab[11] = ab[10]
            ab[10] = ab[10][ab[12] ]

            do
                local af = 1

                ab[10](b(ab, 11, 10 + af))
            end

            ab[11] = ab[8]
            ab[12] = 'Completed'
            ab[10] = ab[11][ab[12] ]
            ab[12] = 'Connect'
            ab[11] = ab[10]
            ab[10] = ab[10][ab[12] ]
            ab[12] = function(...)
                return d.p046({
                    ab[6],
                    aa[5],
                }, ...)
            end

            do
                local af = 2

                ab[10](b(ab, 11, 10 + af))
            end

            ae = 17
        elseif ae == 17 then
            ae = 10
        elseif ae == 18 then
            ab[7] = a.Instance
            ab[8] = 'new'
            ab[6] = ab[7][ab[8] ]
            ab[7] = 'Frame'

            do
                local af = 1
                local ag = pack(ab[6](b(ab, 7, 6 + af)))

                for ah = 1, 1 do
                    ab[6 + ah - 1] = ag[ah]
                end
            end

            ab[6] = {
                ab[6],
            }
            ab[7] = ab[6][1]
            ab[8] = 'Name'
            ab[9] = 'Notification'
            ab[7][ab[8] ] = ab[9]
            ab[7] = ab[6][1]
            ab[8] = 'Parent'
            ab[9] = aa[6][1]
            ab[7][ab[8] ] = ab[9]
            ab[7] = ab[6][1]
            ab[8] = 'AnchorPoint'
            ab[10] = a.Vector2
            ab[11] = 'new'
            ab[9] = ab[10][ab[11] ]
            ab[10] = 0.5
            ab[11] = 0

            do
                local af = 2
                local ag = pack(ab[9](b(ab, 10, 9 + af)))

                for ah = 1, 1 do
                    ab[9 + ah - 1] = ag[ah]
                end
            end

            ab[7][ab[8] ] = ab[9]
            ab[7] = ab[6][1]
            ab[8] = 'BackgroundColor3'
            ab[10] = a.Color3
            ab[11] = 'fromRGB'
            ab[9] = ab[10][ab[11] ]
            ab[10] = 18
            ab[11] = 18
            ab[12] = 20

            do
                local af = 3
                local ag = pack(ab[9](b(ab, 10, 9 + af)))

                for ah = 1, 1 do
                    ab[9 + ah - 1] = ag[ah]
                end
            end

            ab[7][ab[8] ] = ab[9]
            ab[7] = ab[6][1]
            ab[8] = 'BorderSizePixel'
            ab[9] = 0
            ab[7][ab[8] ] = ab[9]
            ab[7] = ab[6][1]
            ab[8] = 'Position'
            ab[10] = a.UDim2
            ab[11] = 'new'
            ab[9] = ab[10][ab[11] ]
            ab[10] = 0.5
            ab[11] = 0
            ab[12] = 0
            ab[13] = aa[7][1]

            do
                local af = 4
                local ag = pack(ab[9](b(ab, 10, 9 + af)))

                for ah = 1, 1 do
                    ab[9 + ah - 1] = ag[ah]
                end
            end

            ab[7][ab[8] ] = ab[9]
            ab[7] = ab[6][1]
            ab[8] = 'Size'
            ab[10] = a.UDim2
            ab[11] = 'new'
            ab[9] = ab[10][ab[11] ]
            ab[10] = 0
            ab[11] = 0
            ab[12] = 0
            ab[13] = aa[4][1]

            do
                local af = 4
                local ag = pack(ab[9](b(ab, 10, 9 + af)))

                for ah = 1, 1 do
                    ab[9 + ah - 1] = ag[ah]
                end
            end

            ab[7][ab[8] ] = ab[9]
            ab[7] = ab[6][1]
            ab[8] = 'ClipsDescendants'
            ab[9] = true
            ab[7][ab[8] ] = ab[9]
            ab[7] = ab[6][1]
            ab[8] = 'BackgroundTransparency'
            ab[9] = 0.05
            ab[7][ab[8] ] = ab[9]
            ab[7] = ab[6][1]
            ab[8] = 'ZIndex'
            ab[9] = 100
            ab[7][ab[8] ] = ab[9]
            ab[8] = a.Instance
            ab[9] = 'new'
            ab[7] = ab[8][ab[9] ]
            ab[8] = 'UIStroke'

            do
                local af = 1
                local ag = pack(ab[7](b(ab, 8, 7 + af)))

                for ah = 1, 1 do
                    ab[7 + ah - 1] = ag[ah]
                end
            end

            ab[7] = {
                ab[7],
            }
            ab[8] = ab[7][1]
            ab[9] = 'Parent'
            ab[10] = ab[6][1]
            ab[8][ab[9] ] = ab[10]
            ab[8] = ab[7][1]
            ab[9] = 'Color'
            ab[11] = aa[8][1]
            ab[12] = 'accentclr'
            ab[10] = ab[11][ab[12] ]
            ab[8][ab[9] ] = ab[10]
            ab[8] = ab[7][1]
            ab[9] = 'Thickness'
            ab[10] = 1.5
            ab[8][ab[9] ] = ab[10]
            ab[8] = ab[7][1]
            ab[9] = 'Transparency'
            ab[10] = 0.25
            ab[8][ab[9] ] = ab[10]
            ab[9] = a.Instance
            ab[10] = 'new'
            ab[8] = ab[9][ab[10] ]
            ab[9] = 'Frame'

            do
                local af = 1
                local ag = pack(ab[8](b(ab, 9, 8 + af)))

                for ah = 1, 1 do
                    ab[8 + ah - 1] = ag[ah]
                end
            end

            ab[9] = ab[8]
            ab[10] = 'Name'
            ab[11] = 'AccentLine'
            ab[9][ab[10] ] = ab[11]
            ab[9] = ab[8]
            ab[10] = 'Parent'
            ab[11] = ab[6][1]
            ab[9][ab[10] ] = ab[11]
            ab[9] = ab[8]
            ab[10] = 'BackgroundColor3'
            ab[12] = aa[8][1]
            ab[13] = 'accentclr'
            ab[11] = ab[12][ab[13] ]
            ab[9][ab[10] ] = ab[11]
            ab[9] = ab[8]
            ab[10] = 'BorderSizePixel'
            ab[11] = 0
            ab[9][ab[10] ] = ab[11]
            ab[9] = ab[8]
            ab[10] = 'Size'
            ab[12] = a.UDim2
            ab[13] = 'new'
            ab[11] = ab[12][ab[13] ]
            ab[12] = 0
            ab[13] = 3
            ab[14] = 1
            ab[15] = 0

            do
                local af = 4
                local ag = pack(ab[11](b(ab, 12, 11 + af)))

                for ah = 1, 1 do
                    ab[11 + ah - 1] = ag[ah]
                end
            end

            ab[9][ab[10] ] = ab[11]
            ab[9] = ab[8]
            ab[10] = 'Position'
            ab[12] = a.UDim2
            ab[13] = 'new'
            ab[11] = ab[12][ab[13] ]
            ab[12] = 0
            ab[13] = 0
            ab[14] = 0
            ab[15] = 0

            do
                local af = 4
                local ag = pack(ab[11](b(ab, 12, 11 + af)))

                for ah = 1, 1 do
                    ab[11 + ah - 1] = ag[ah]
                end
            end

            ab[9][ab[10] ] = ab[11]
            ab[10] = a.Instance
            ab[11] = 'new'
            ab[9] = ab[10][ab[11] ]
            ab[10] = 'TextLabel'

            do
                local af = 1
                local ag = pack(ab[9](b(ab, 10, 9 + af)))

                for ah = 1, 1 do
                    ab[9 + ah - 1] = ag[ah]
                end
            end

            ab[9] = {
                ab[9],
            }
            ab[10] = ab[9][1]
            ab[11] = 'Parent'
            ab[12] = ab[6][1]
            ab[10][ab[11] ] = ab[12]
            ab[10] = ab[9][1]
            ab[11] = 'BackgroundTransparency'
            ab[12] = 1
            ab[10][ab[11] ] = ab[12]
            ab[10] = ab[9][1]
            ab[11] = 'Position'
            ab[13] = a.UDim2
            ab[14] = 'new'
            ab[12] = ab[13][ab[14] ]
            ab[13] = 0
            ab[14] = 14
            ab[15] = 0
            ab[16] = 0

            do
                local af = 4
                local ag = pack(ab[12](b(ab, 13, 12 + af)))

                for ah = 1, 1 do
                    ab[12 + ah - 1] = ag[ah]
                end
            end

            ab[10][ab[11] ] = ab[12]
            ab[10] = ab[9][1]
            ab[11] = 'Size'
            ab[13] = a.UDim2
            ab[14] = 'new'
            ab[12] = ab[13][ab[14] ]
            ab[13] = 1
            ab[15] = 28
            ab[14] = -ab[15]
            ab[15] = 1
            ab[16] = 0

            do
                local af = 4
                local ag = pack(ab[12](b(ab, 13, 12 + af)))

                for ah = 1, 1 do
                    ab[12 + ah - 1] = ag[ah]
                end
            end

            ab[10][ab[11] ] = ab[12]
            ab[10] = ab[9][1]
            ab[11] = 'Font'
            ab[14] = a.Enum
            ab[15] = 'Font'
            ab[13] = ab[14][ab[15] ]
            ab[14] = 'Code'
            ab[12] = ab[13][ab[14] ]
            ab[10][ab[11] ] = ab[12]
            ab[10] = ab[9][1]
            ab[11] = 'Text'
            ab[12] = ab[4]
            ab[10][ab[11] ] = ab[12]
            ab[10] = ab[9][1]
            ab[11] = 'TextColor3'
            ab[13] = a.Color3
            ab[14] = 'fromRGB'
            ab[12] = ab[13][ab[14] ]
            ab[13] = 230
            ab[14] = 230
            ab[15] = 230

            do
                local af = 3
                local ag = pack(ab[12](b(ab, 13, 12 + af)))

                for ah = 1, 1 do
                    ab[12 + ah - 1] = ag[ah]
                end
            end

            ab[10][ab[11] ] = ab[12]
            ab[10] = ab[9][1]
            ab[11] = 'TextSize'
            ab[12] = 13
            ab[10][ab[11] ] = ab[12]
            ab[10] = ab[9][1]
            ab[11] = 'TextXAlignment'
            ab[14] = a.Enum
            ab[15] = 'TextXAlignment'
            ab[13] = ab[14][ab[15] ]
            ab[14] = 'Center'
            ab[12] = ab[13][ab[14] ]
            ab[10][ab[11] ] = ab[12]
            ab[10] = ab[9][1]
            ab[11] = 'TextTransparency'
            ab[12] = 1
            ab[10][ab[11] ] = ab[12]
            ab[10] = ab[9][1]
            ab[11] = 'TextTruncate'
            ab[14] = a.Enum
            ab[15] = 'TextTruncate'
            ab[13] = ab[14][ab[15] ]
            ab[14] = 'None'
            ab[12] = ab[13][ab[14] ]
            ab[10][ab[11] ] = ab[12]
            ab[10] = a.game
            ab[12] = 'GetService'
            ab[11] = ab[10]
            ab[10] = ab[10][ab[12] ]
            ab[12] = 'TextService'

            do
                local af = 2
                local ag = pack(ab[10](b(ab, 11, 10 + af)))

                for ah = 1, 1 do
                    ab[10 + ah - 1] = ag[ah]
                end
            end

            ab[11] = ab[10]
            ab[13] = 'GetTextSize'
            ab[12] = ab[11]
            ab[11] = ab[11][ab[13] ]
            ab[13] = ab[4]
            ab[14] = 13
            ab[17] = a.Enum
            ab[18] = 'Font'
            ab[16] = ab[17][ab[18] ]
            ab[17] = 'Code'
            ab[15] = ab[16][ab[17] ]
            ab[17] = a.Vector2
            ab[18] = 'new'
            ab[16] = ab[17][ab[18] ]
            ab[17] = 2000
            ab[18] = aa[4][1]

            do
                local af = 2
                local ag = pack(ab[16](b(ab, 17, 16 + af)))

                for ah = 1, ag.n do
                    ab[16 + ah - 1] = ag[ah]
                end

                ad = 16 + ag.n
            end
            do
                local af = (ad - 11 - 1)
                local ag = pack(ab[11](b(ab, 12, 11 + af)))

                for ah = 1, 1 do
                    ab[11 + ah - 1] = ag[ah]
                end
            end

            ab[13] = a.math
            ab[14] = 'clamp'
            ab[12] = ab[13][ab[14] ]
            ab[15] = ab[11]
            ab[16] = 'X'
            ab[14] = ab[15][ab[16] ]
            ab[15] = 48
            ab[13] = ab[14] + ab[15]
            ab[14] = 200
            ab[15] = 480

            do
                local af = 3
                local ag = pack(ab[12](b(ab, 13, 12 + af)))

                for ah = 1, 1 do
                    ab[12 + ah - 1] = ag[ah]
                end
            end

            ab[14] = a.table
            ab[15] = 'insert'
            ab[13] = ab[14][ab[15] ]
            ab[14] = aa[2][1]
            ab[15] = 1
            ab[16] = {}
            ab[17] = 'bar'
            ab[18] = ab[6][1]
            ab[16][ab[17] ] = ab[18]
            ab[17] = 'label'
            ab[18] = ab[9][1]
            ab[16][ab[17] ] = ab[18]
            ab[17] = 'stroke'
            ab[18] = ab[7][1]
            ab[16][ab[17] ] = ab[18]

            do
                local af = 3

                ab[13](b(ab, 14, 13 + af))
            end

            ab[13] = aa[5][1]

            do
                local af = 0

                ab[13](b(ab, 14, 13 + af))
            end

            ab[13] = ab[5][1]
            ab[15] = 'Create'
            ab[14] = ab[13]
            ab[13] = ab[13][ab[15] ]
            ab[15] = ab[6][1]
            ab[17] = a.TweenInfo
            ab[18] = 'new'
            ab[16] = ab[17][ab[18] ]
            ab[17] = 0.28
            ab[20] = a.Enum
            ab[21] = 'EasingStyle'
            ab[19] = ab[20][ab[21] ]
            ab[20] = 'Quart'
            ab[18] = ab[19][ab[20] ]
            ab[21] = a.Enum
            ab[22] = 'EasingDirection'
            ab[20] = ab[21][ab[22] ]
            ab[21] = 'Out'
            ab[19] = ab[20][ab[21] ]

            do
                local af = 3
                local ag = pack(ab[16](b(ab, 17, 16 + af)))

                for ah = 1, 1 do
                    ab[16 + ah - 1] = ag[ah]
                end
            end

            ab[17] = {}
            ab[18] = 'Size'
            ab[20] = a.UDim2
            ab[21] = 'new'
            ab[19] = ab[20][ab[21] ]
            ab[20] = 0
            ab[21] = ab[12]
            ab[22] = 0
            ab[23] = aa[4][1]

            do
                local af = 4
                local ag = pack(ab[19](b(ab, 20, 19 + af)))

                for ah = 1, 1 do
                    ab[19 + ah - 1] = ag[ah]
                end
            end

            ab[17][ab[18] ] = ab[19]

            do
                local af = 4
                local ag = pack(ab[13](b(ab, 14, 13 + af)))

                for ah = 1, 1 do
                    ab[13 + ah - 1] = ag[ah]
                end
            end

            ab[14] = ab[5][1]
            ab[16] = 'Create'
            ab[15] = ab[14]
            ab[14] = ab[14][ab[16] ]
            ab[16] = ab[9][1]
            ab[18] = a.TweenInfo
            ab[19] = 'new'
            ab[17] = ab[18][ab[19] ]
            ab[18] = 0.2
            ab[21] = a.Enum
            ab[22] = 'EasingStyle'
            ab[20] = ab[21][ab[22] ]
            ab[21] = 'Quad'
            ab[19] = ab[20][ab[21] ]
            ab[22] = a.Enum
            ab[23] = 'EasingDirection'
            ab[21] = ab[22][ab[23] ]
            ab[22] = 'Out'
            ab[20] = ab[21][ab[22] ]

            do
                local af = 3
                local ag = pack(ab[17](b(ab, 18, 17 + af)))

                for ah = 1, 1 do
                    ab[17 + ah - 1] = ag[ah]
                end
            end

            ab[18] = {}
            ab[19] = 'TextTransparency'
            ab[20] = 0
            ab[18][ab[19] ] = ab[20]

            do
                local af = 4
                local ag = pack(ab[14](b(ab, 15, 14 + af)))

                for ah = 1, 1 do
                    ab[14 + ah - 1] = ag[ah]
                end
            end

            ab[14] = {
                ab[14],
            }
            ab[15] = ab[13]
            ab[17] = 'Play'
            ab[16] = ab[15]
            ab[15] = ab[15][ab[17] ]

            do
                local af = 1

                ab[15](b(ab, 16, 15 + af))
            end

            ab[16] = a.task
            ab[17] = 'delay'
            ab[15] = ab[16][ab[17] ]
            ab[16] = 0.08
            ab[17] = function(...)
                return d.p048({
                    ab[14],
                }, ...)
            end

            do
                local af = 2

                ab[15](b(ab, 16, 15 + af))
            end

            ab[16] = a.task
            ab[17] = 'delay'
            ab[15] = ab[16][ab[17] ]
            ab[16] = ab[3]
            ab[17] = function(...)
                return d.p049({
                    aa[2],
                    ab[6],
                    aa[5],
                    ab[5],
                    ab[9],
                    aa[4],
                    ab[7],
                }, ...)
            end

            do
                local af = 2

                ab[15](b(ab, 16, 15 + af))
            end

            local af = 0

            return b(ab, 0, 0 + af - 1)
        else
            return
        end
    end
end
d.animate_notification_bar = function(aa)
    local ab = a.game:GetService'TweenService'

    for ac, ad in ipairs(aa[1][1])do
        if ad.bar and ad.bar.Parent then
            local ae = aa[2][1] + (ac - 1) * (aa[3][1] + aa[4][1])

            ab:Create(ad.bar, a.TweenInfo.new(0.25, a.Enum.EasingStyle.Quart, a.Enum.EasingDirection.Out), {
                Position = a.UDim2.new(0.5, 0, 0, ae),
            }):Play()
        end
    end
end
d.p043 = function(aa)
    return
end
d.p042 = function(aa, ab)
    local ac, ad

    ac = ab
    ad = (ac == aa[1][1])

    if (not (ac == aa[1][1])) then
    else
        ad = aa[2][1]
    end
    if (not ad) then
    else
        local ae = a.UDim2.new(aa[5][1].X.Scale, (aa[5][1].X.Offset + (ac.Position - aa[3][1]).X), aa[5][1].Y.Scale, (aa[5][1].Y.Offset + (ac.Position - aa[3][1]).Y))

        aa[4][1].Position = ae
    end

    return
end
d.p041 = function(aa, ab)
    local ac, ad

    ac = ab
    ad = (ac.UserInputType == a.Enum.UserInputType.MouseMovement)

    if ((ac.UserInputType == a.Enum.UserInputType.MouseMovement)) then
    else
        ad = (ac.UserInputType == a.Enum.UserInputType.Touch)
    end
    if (not ad) then
    else
        aa[1][1] = ac
    end

    return
end
d.p040 = function(aa)
    if (not (aa[1][1].UserInputState == a.Enum.UserInputState.End)) then
    else
        aa[2][1] = false
    end

    return
end
d.p039 = function(aa, ab)
    local ac, ad

    ac = ab

    local ae = {ac}

    ac = ae
    ad = (ae[1].UserInputType == a.Enum.UserInputType.MouseButton1)

    if ((ae[1].UserInputType == a.Enum.UserInputType.MouseButton1)) then
    else
        ad = (ac[1].UserInputType == a.Enum.UserInputType.Touch)
    end
    if (not ad) then
    else
        aa[1][1] = true
        aa[2][1] = ac[1].Position
        aa[4][1] = aa[3][1].Position

        ac[1].Changed:Connect(function(...)
            return d.p040({
                ac,
                aa[1],
            }, ...)
        end)
    end

    return
end
d.make_draggable = function(aa)
    local ab, ac, ad, ae = {false}, {nil}, {nil}, {nil}

    aa[1][1].InputBegan:Connect(function(...)
        return d.p039({
            ab,
            ad,
            aa[2],
            ae,
        }, ...)
    end)
    aa[1][1].InputChanged:Connect(function(...)
        return d.p041({ac}, ...)
    end)

    local af = a.game:GetService'UserInputService'

    af.InputChanged:Connect(function(...)
        return d.p042({
            ac,
            ab,
            ad,
            aa[2],
            ae,
        }, ...)
    end)

    return
end
d.p037 = function(aa, ab, ac)
    local ad, ae = {ab}, {ac}

    a.pcall(function(...)
        return d.make_draggable({ad, ae}, ...)
    end)

    return
end
d.has_active_state = function(aa, ab, ac)
    for ad, ae in next, ab do
        if ad == ac or ae == ac then
            return true
        end
    end
end
d.p035 = function(aa)
    aa[1][1]:SetNetworkOwner(aa[2][1])

    return
end
d.p034 = function(aa)
    local ab, ac, ad, ae = (a.tick())

    if (not ((ab - aa[1][1]) < 3)) then
        local af = a.tick()

        aa[1][1] = af
        ac = aa[2][1].Character
        ad = aa[2][1].Character

        if (not aa[2][1].Character) then
        else
            local ag = ac:FindFirstChild'HumanoidRootPart'

            ad = ag
        end

        local ag = {ad}

        ad = ag
        ae = ag[1]

        if (not ag[1]) then
        else
            ae = ad[1].SetNetworkOwner
        end
        if (not ae) then
        else
            a.pcall(function(...)
                return d.p035({
                    ad,
                    aa[2],
                }, ...)
            end)
        end

        return
    else
        return
    end
end
d.p033 = function(aa)
    local ab, ac = a.game:GetService'RunService', {0}

    ab.Heartbeat:Connect(function(...)
        return d.p034({
            ac,
            aa[1],
        }, ...)
    end)

    return
end
d.p032 = function(aa)
    if (not a.setfflag) then
    else
        a.pcall(a.setfflag, 'DebugRunServiceHumanoidCheck', 'False')
    end

    return
end
d.p031 = function(aa)
    if (not a.getconnections) then
    end

    return
end
d.p030 = function(aa)
    return
end
d.p029 = function(aa)
    local ab

    ab = aa[1][1]

    if (not aa[1][1]) then
    else
        ab = aa[1][1].Error
    end
    if (not ab) then
    else
        aa[1][1].Error:Connect(function(...)
            return d.p030({}, ...)
        end)
    end

    return
end
d.cleanup_overlay_loop = function(aa)
    a.task.wait(1)

    for ab, ac in ipairs{
        'HalmuESP',
        'HalmuFOV',
        'HalmuIndicators',
        'ExecutorToggleUI',
        'CustomCursorGui',
    }do
        local ad = aa[1][1]:FindFirstChild(ac)

        if ad then
            aa[2][1](ad)
        end

        local ae = aa[3][1]
        local af = ae and ae:FindFirstChild'PlayerGui'

        if af then
            local ag = ae.PlayerGui:FindFirstChild(ac)

            if ag then
                aa[2][1](ag)
            end
        end
    end
end
d.p027 = function(aa)
    local ab = a.tostring(a.math.random(100000, 999999))

    aa[1][1].Name = ab

    return
end
d.p026 = function(aa, ab)
    local ac

    ac = ab

    local ad = {ac}

    ac = ad

    if (not (not ad[1])) then
        a.pcall(function(...)
            return d.p027({ac}, ...)
        end)

        return
    else
        return
    end
end
d.p025 = function(aa)
    local ab = {nil}

    ab[1] = function(...)
        return d.p026({}, ...)
    end

    a.task.defer(function(...)
        return d.cleanup_overlay_loop({
            aa[1],
            ab,
            aa[2],
        }, ...)
    end)

    return
end
d.p024 = function(aa, ab, ...)
    if a.getnamecallmethod() == 'Kick' then
        return
    end

    return aa[1][1](ab, ...)
end
d.p023 = function(aa, ab, ...)
    local ac = a.getnamecallmethod()

    if ac == 'Kick' or ac == 'kick' then
        return
    end

    return aa[1][1](ab, ...)
end
d.p022 = function(aa, ab)
    if type(ab) ~= 'string' then
        return false
    end

    ab = a.string.lower(ab)

    for ac, ad in pairs(aa[1][1])do
        if a.string.find(ab, ad, 1, true) then
            return true
        end
    end

    return false
end
d.p021 = function(aa)
    local ab, ac, ad, ae, af, ag

    ab = (not a.hookmetamethod)

    if ((not a.hookmetamethod)) then
    else
        ab = (not a.getnamecallmethod)
    end
    if (not ab) then
        local ah = {}

        ah.kick = true
        ah.ban = true
        ah.punish = true
        ah.anticheat = true
        ah.detect = true
        ah.report = true
        ah.flag = true
        ah.crash = true
        ah.log = true
        ah.screenshot = true
        ah.security = true
        ah.mod = true
        ah.admin = true
        ah.watchdog = true
        ah.sentinel = true

        local ai = {nil}

        ac = ai
        ad = a.hookmetamethod
        ae = a.game
        af = '__namecall'
        ag = a.newcclosure

        if (not a.newcclosure) then
        else
            local aj = a.newcclosure(function(...)
                return d.p023({ac}, ...)
            end)

            ag = aj
        end
        if (ag) then
        else
            ag = function(...)
                return d.p024({ac}, ...)
            end
        end

        local aj = ad(ae, af, ag)

        ac[1] = aj

        return
    else
        return
    end
end
d.p020 = function(aa, ...)
    return
end
d.p019 = function(aa)
    local ab

    ab = aa[1][1]

    if (not aa[1][1]) then
    else
        local ac = a.typeof(aa[1][1].Kick)

        ab = (ac == 'function')
    end
    if (not ab) then
    else
        aa[1][1].Kick = function(...)
            return d.p020({}, ...)
        end
    end

    return
end
d.runtime_guard_setup = function(aa)
    local ab, ac = a.game:GetService'Players', a.game:GetService'ReplicatedStorage'
    local ad, ae = {
        ab.LocalPlayer,
    }, a.game:GetService'CoreGui'
    local af, ag, ah, ai = {ae}, a.game:GetService'StarterGui', a.game:GetService'LogService', a.game:GetService'ScriptContext'
    local aj, ak = {ai}, a.game:GetService'GuiService'

    a.pcall(function(...)
        return d.p019({ad}, ...)
    end)
    a.pcall(function(...)
        return d.p021({}, ...)
    end)
    a.pcall(function(...)
        return d.p025({af, ad}, ...)
    end)
    a.pcall(function(...)
        return d.p029({aj}, ...)
    end)
    a.pcall(function(...)
        return d.p031({}, ...)
    end)
    a.pcall(function(...)
        return d.p032({}, ...)
    end)
    a.pcall(function(...)
        return d.p033({ad}, ...)
    end)

    return
end
d.p017 = function(aa, ab)
    aa[1][1] = (aa[1][1] + 1)

    return ((aa[1][1] % ab) == 0)
end
d.p005 = function(aa)
    local ab, ac, ad = (a.tostring(aa[1][1].Name))
    local ae = ab:find'nexlib'

    ac = ab
    ad = ae

    if (ae) then
    else
        local af = ac:find'Vanta'

        ad = af
    end
    if (ad) then
    else
        local af = ac:find'Halmu'

        ad = af
    end
    if (ad) then
    else
        local af = ac:find'ExecutorToggle'

        ad = af
    end
    if (ad) then
    else
        local af = ac:find'NexSkin'

        ad = af
    end
    if (ad) then
    else
        local af = ac:find'KeyGate'

        ad = af
    end
    if (ad) then
    else
        local af = ac:find'\u{d560}\u{bb34}'

        ad = af
    end
    if (not ad) then
    else
        aa[1][1]:Destroy()
    end

    return
end
d.p004 = function(aa)
    local ab

    if (not aa[1][1]) then
    else
        local ac = aa[1][1]:FindFirstChild'PlayerGui'

        ab = ac

        if (not ac) then
        else
            aa[2][1][(#aa[2][1] + 1)] = ab
        end
    end

    return
end
d.p003 = function(aa)
    local ab = a.game:GetService'CoreGui'

    aa[1][1][(#aa[1][1] + 1)] = ab

    return
end
d.p002 = function(aa)
    if (not a.gethui) then
    else
        local ab = a.gethui()

        aa[1][1][(#aa[1][1] + 1)] = ab
    end

    return
end
d.cleanup_old_ui = function(aa)
    local ab, ac = a.game:GetService'Players'.LocalPlayer, {}

    a.pcall(function()
        ac[#ac + 1] = a.gethui()
    end)
    a.pcall(function()
        ac[#ac + 1] = a.game:GetService'CoreGui'
    end)
    a.pcall(function()
        ac[#ac + 1] = ab.PlayerGui
    end)

    for ad, ae in ipairs(ac)do
        if ae then
            for af, ag in ipairs(ae:GetChildren())do
                local ah = {ag}

                a.pcall(function()
                    return d.p005{ah}
                end)
            end
        end
    end
end
d.root_bootstrap = function(aa, ...)
    local ab, ac = {}, pack(...)

    for ad = 1, 0 do
        ab[ad - 1] = ac[ad]
    end

    local ad, ae, af = pack(b(ac, 1, ac.n)), 0, (a.getgenv and a.getgenv()) or a

    if af.VantaSC_Running then
        return
    end

    af.VantaSC_Running = true

    pcall(function()
        if d.cleanup_old_ui then
            d.cleanup_old_ui{}
        end
    end)

    local ag = 23

    while true do
        if ag == 23 then
            ab[0] = a.bit32

            if (not not ab[0]) == true then
                ag = 25
            else
                ag = 24
            end
        elseif ag == 24 then
            ab[0] = a.bit
            ag = 25
        elseif ag == 25 then
            ab[1] = 0
            ab[1] = {
                ab[1],
            }

            for ah = 2, 2 do
                ab[ah] = nil
            end

            ab[2] = {
                ab[2],
            }
            ab[3] = function(...)
                return d.p017({
                    ab[1],
                }, ...)
            end
            ab[2][1] = ab[3]
            ab[3] = a.pcall
            ab[4] = function(...)
                return d.runtime_guard_setup({}, ...)
            end

            do
                local ah = 1

                ab[3](b(ab, 4, 3 + ah))
            end

            ab[3] = {}
            ab[4] = 'accentclr'
            ab[6] = a.Color3
            ab[7] = 'fromRGB'
            ab[5] = ab[6][ab[7] ]
            ab[6] = 128
            ab[7] = 213
            ab[8] = 247

            do
                local ah = 3
                local ai = pack(ab[5](b(ab, 6, 5 + ah)))

                for aj = 1, 1 do
                    ab[5 + aj - 1] = ai[aj]
                end
            end

            ab[3][ab[4] ] = ab[5]
            ab[4] = 'dropdownframes'
            ab[5] = {}
            ab[3][ab[4] ] = ab[5]
            ab[4] = 'colorpickerframes'
            ab[5] = {}
            ab[3][ab[4] ] = ab[5]
            ab[3] = {
                ab[3],
            }
            ab[4] = {}
            ab[7] = a.Enum
            ab[8] = 'UserInputType'
            ab[6] = ab[7][ab[8] ]
            ab[7] = 'MouseButton1'
            ab[5] = ab[6][ab[7] ]
            ab[6] = 'M1'
            ab[4][ab[5] ] = ab[6]
            ab[7] = a.Enum
            ab[8] = 'UserInputType'
            ab[6] = ab[7][ab[8] ]
            ab[7] = 'MouseButton2'
            ab[5] = ab[6][ab[7] ]
            ab[6] = 'M2'
            ab[4][ab[5] ] = ab[6]
            ab[7] = a.Enum
            ab[8] = 'UserInputType'
            ab[6] = ab[7][ab[8] ]
            ab[7] = 'MouseButton3'
            ab[5] = ab[6][ab[7] ]
            ab[6] = 'M3'
            ab[4][ab[5] ] = ab[6]
            ab[5] = {}
            ab[8] = a.Enum
            ab[9] = 'KeyCode'
            ab[7] = ab[8][ab[9] ]
            ab[8] = 'Unknown'
            ab[6] = ab[7][ab[8] ]
            ab[9] = a.Enum
            ab[10] = 'KeyCode'
            ab[8] = ab[9][ab[10] ]
            ab[9] = 'W'
            ab[7] = ab[8][ab[9] ]
            ab[10] = a.Enum
            ab[11] = 'KeyCode'
            ab[9] = ab[10][ab[11] ]
            ab[10] = 'A'
            ab[8] = ab[9][ab[10] ]
            ab[11] = a.Enum
            ab[12] = 'KeyCode'
            ab[10] = ab[11][ab[12] ]
            ab[11] = 'S'
            ab[9] = ab[10][ab[11] ]
            ab[12] = a.Enum
            ab[13] = 'KeyCode'
            ab[11] = ab[12][ab[13] ]
            ab[12] = 'D'
            ab[10] = ab[11][ab[12] ]
            ab[13] = a.Enum
            ab[14] = 'KeyCode'
            ab[12] = ab[13][ab[14] ]
            ab[13] = 'Up'
            ab[11] = ab[12][ab[13] ]
            ab[14] = a.Enum
            ab[15] = 'KeyCode'
            ab[13] = ab[14][ab[15] ]
            ab[14] = 'Left'
            ab[12] = ab[13][ab[14] ]
            ab[15] = a.Enum
            ab[16] = 'KeyCode'
            ab[14] = ab[15][ab[16] ]
            ab[15] = 'Down'
            ab[13] = ab[14][ab[15] ]
            ab[16] = a.Enum
            ab[17] = 'KeyCode'
            ab[15] = ab[16][ab[17] ]
            ab[16] = 'Right'
            ab[14] = ab[15][ab[16] ]
            ab[17] = a.Enum
            ab[18] = 'KeyCode'
            ab[16] = ab[17][ab[18] ]
            ab[17] = 'Slash'
            ab[15] = ab[16][ab[17] ]
            ab[18] = a.Enum
            ab[19] = 'KeyCode'
            ab[17] = ab[18][ab[19] ]
            ab[18] = 'Tab'
            ab[16] = ab[17][ab[18] ]
            ab[19] = a.Enum
            ab[20] = 'KeyCode'
            ab[18] = ab[19][ab[20] ]
            ab[19] = 'Backspace'
            ab[17] = ab[18][ab[19] ]
            ab[20] = a.Enum
            ab[21] = 'KeyCode'
            ab[19] = ab[20][ab[21] ]
            ab[20] = 'Escape'
            ab[18] = ab[19][ab[20] ]
            ab[21] = a.Enum
            ab[22] = 'KeyCode'
            ab[20] = ab[21][ab[22] ]
            ab[21] = 'RightShift'
            ab[19] = ab[20][ab[21] ]

            do
                local ah, ai = 14, ab[5]

                for aj = 1, ah do
                    ai[0 + aj] = ab[5 + aj]
                end
            end

            ab[6] = function(...)
                return d.has_active_state({}, ...)
            end

            for ah = 7, 7 do
                ab[ah] = nil
            end

            ab[7] = {
                ab[7],
            }
            ab[8] = function(...)
                return d.p037({}, ...)
            end
            ab[7][1] = ab[8]
            ab[9] = a.Instance
            ab[10] = 'new'
            ab[8] = ab[9][ab[10] ]
            ab[9] = 'ScreenGui'

            do
                local ah = 1
                local ai = pack(ab[8](b(ab, 9, 8 + ah)))

                for aj = 1, 1 do
                    ab[8 + aj - 1] = ai[aj]
                end
            end

            ab[8] = {
                ab[8],
            }
            ab[9] = ab[8][1]
            ab[10] = 'Name'
            ab[11] = 'nexlib'
            ab[9][ab[10] ] = ab[11]
            ab[9] = a.setthreadidentity

            if (not not ab[9]) == true then
                ag = 27
            else
                ag = 26
            end
        elseif ag == 26 then
            ab[9] = function(...)
                return d.p043({}, ...)
            end
            ag = 27
        elseif ag == 27 then
            a.setthreadidentity = ab[9]
            ab[9] = a.setthreadidentity
            ab[10] = 8

            do
                local ah = 1

                ab[9](b(ab, 10, 9 + ah))
            end

            ab[9] = ab[8][1]
            ab[10] = 'Parent'
            ab[11] = a.game
            ab[13] = 'GetService'
            ab[12] = ab[11]
            ab[11] = ab[11][ab[13] ]
            ab[13] = 'CoreGui'

            do
                local ah = 2
                local ai = pack(ab[11](b(ab, 12, 11 + ah)))

                for aj = 1, 1 do
                    ab[11 + aj - 1] = ai[aj]
                end
            end

            ab[9][ab[10] ] = ab[11]
            ab[9] = ab[8][1]
            ab[10] = 'ZIndexBehavior'
            ab[13] = a.Enum
            ab[14] = 'ZIndexBehavior'
            ab[12] = ab[13][ab[14] ]
            ab[13] = 'Sibling'
            ab[11] = ab[12][ab[13] ]
            ab[9][ab[10] ] = ab[11]
            ab[10] = a.Instance
            ab[11] = 'new'
            ab[9] = ab[10][ab[11] ]
            ab[10] = 'ScreenGui'

            do
                local ah = 1
                local ai = pack(ab[9](b(ab, 10, 9 + ah)))

                for aj = 1, 1 do
                    ab[9 + aj - 1] = ai[aj]
                end
            end

            ab[10] = ab[9]
            ab[11] = 'Name'
            ab[12] = 'CustomCursorGui'
            ab[10][ab[11] ] = ab[12]
            ab[10] = ab[9]
            ab[11] = 'ResetOnSpawn'
            ab[12] = false
            ab[10][ab[11] ] = ab[12]
            ab[10] = ab[9]
            ab[11] = 'Parent'
            ab[12] = ab[8][1]
            ab[10][ab[11] ] = ab[12]
            ab[11] = a.Instance
            ab[12] = 'new'
            ab[10] = ab[11][ab[12] ]
            ab[11] = 'Frame'

            do
                local ah = 1
                local ai = pack(ab[10](b(ab, 11, 10 + ah)))

                for aj = 1, 1 do
                    ab[10 + aj - 1] = ai[aj]
                end
            end

            ab[10] = {
                ab[10],
            }
            ab[11] = ab[10][1]
            ab[12] = 'Name'
            ab[13] = 'CursorBox'
            ab[11][ab[12] ] = ab[13]
            ab[11] = ab[10][1]
            ab[12] = 'Size'
            ab[14] = a.UDim2
            ab[15] = 'new'
            ab[13] = ab[14][ab[15] ]
            ab[14] = 0
            ab[15] = 6
            ab[16] = 0
            ab[17] = 6

            do
                local ah = 4
                local ai = pack(ab[13](b(ab, 14, 13 + ah)))

                for aj = 1, 1 do
                    ab[13 + aj - 1] = ai[aj]
                end
            end

            ab[11][ab[12] ] = ab[13]
            ab[11] = ab[10][1]
            ab[12] = 'BackgroundColor3'
            ab[14] = a.Color3
            ab[15] = 'fromRGB'
            ab[13] = ab[14][ab[15] ]
            ab[14] = 128
            ab[15] = 213
            ab[16] = 247

            do
                local ah = 3
                local ai = pack(ab[13](b(ab, 14, 13 + ah)))

                for aj = 1, 1 do
                    ab[13 + aj - 1] = ai[aj]
                end
            end

            ab[11][ab[12] ] = ab[13]
            ab[11] = ab[10][1]
            ab[12] = 'BorderSizePixel'
            ab[13] = 0
            ab[11][ab[12] ] = ab[13]
            ab[11] = ab[10][1]
            ab[12] = 'Visible'
            ab[13] = false
            ab[11][ab[12] ] = ab[13]
            ab[11] = ab[10][1]
            ab[12] = 'Parent'
            ab[13] = ab[9]
            ab[11][ab[12] ] = ab[13]
            ab[12] = a.Instance
            ab[13] = 'new'
            ab[11] = ab[12][ab[13] ]
            ab[12] = 'Folder'

            do
                local ah = 1
                local ai = pack(ab[11](b(ab, 12, 11 + ah)))

                for aj = 1, 1 do
                    ab[11 + aj - 1] = ai[aj]
                end
            end

            ab[11] = {
                ab[11],
            }
            ab[12] = ab[11][1]
            ab[13] = 'Name'
            ab[14] = 'NotificationFolder'
            ab[12][ab[13] ] = ab[14]
            ab[12] = ab[11][1]
            ab[13] = 'Parent'
            ab[14] = ab[8][1]
            ab[12][ab[13] ] = ab[14]
            ab[12] = {}
            ab[12] = {
                ab[12],
            }
            ab[13] = 22
            ab[13] = {
                ab[13],
            }
            ab[14] = 6
            ab[14] = {
                ab[14],
            }
            ab[15] = 8
            ab[15] = {
                ab[15],
            }
            ab[16] = 3
            ab[16] = {
                ab[16],
            }
            ab[17] = 40
            ab[17] = {
                ab[17],
            }

            for ah = 18, 18 do
                ab[ah] = nil
            end

            ab[18] = {
                ab[18],
            }
            ab[19] = function(...)
                return d.animate_notification_bar({
                    ab[12],
                    ab[17],
                    ab[13],
                    ab[14],
                }, ...)
            end
            ab[18][1] = ab[19]
            ab[19] = function(...)
                return d.show_notification({
                    ab[16],
                    ab[12],
                    ab[15],
                    ab[13],
                    ab[18],
                    ab[11],
                    ab[17],
                    ab[3],
                }, ...)
            end
            ab[20] = ab[3][1]
            ab[21] = 'Notification'
            ab[20][ab[21] ] = ab[19]
            ab[19] = function(...)
                return d.create_window({
                    ab[8],
                    ab[3],
                    ab[7],
                    ab[10],
                }, ...)
            end
            ab[20] = ab[3][1]
            ab[21] = 'Window'
            ab[20][ab[21] ] = ab[19]
            ab[19] = a.game
            ab[21] = 'GetService'
            ab[20] = ab[19]
            ab[19] = ab[19][ab[21] ]
            ab[21] = 'Players'

            do
                local ah = 2
                local ai = pack(ab[19](b(ab, 20, 19 + ah)))

                for aj = 1, 1 do
                    ab[19 + aj - 1] = ai[aj]
                end
            end

            ab[19] = {
                ab[19],
            }
            ab[20] = a.game
            ab[22] = 'GetService'
            ab[21] = ab[20]
            ab[20] = ab[20][ab[22] ]
            ab[22] = 'RunService'

            do
                local ah = 2
                local ai = pack(ab[20](b(ab, 21, 20 + ah)))

                for aj = 1, 1 do
                    ab[20 + aj - 1] = ai[aj]
                end
            end

            ab[20] = {
                ab[20],
            }
            ab[21] = a.game
            ab[23] = 'GetService'
            ab[22] = ab[21]
            ab[21] = ab[21][ab[23] ]
            ab[23] = 'UserInputService'

            do
                local ah = 2
                local ai = pack(ab[21](b(ab, 22, 21 + ah)))

                for aj = 1, 1 do
                    ab[21 + aj - 1] = ai[aj]
                end
            end

            ab[22] = a.game
            ab[24] = 'GetService'
            ab[23] = ab[22]
            ab[22] = ab[22][ab[24] ]
            ab[24] = 'Workspace'

            do
                local ah = 2
                local ai = pack(ab[22](b(ab, 23, 22 + ah)))

                for aj = 1, 1 do
                    ab[22 + aj - 1] = ai[aj]
                end
            end

            ab[23] = a.game
            ab[25] = 'GetService'
            ab[24] = ab[23]
            ab[23] = ab[23][ab[25] ]
            ab[25] = 'HttpService'

            do
                local ah = 2
                local ai = pack(ab[23](b(ab, 24, 23 + ah)))

                for aj = 1, 1 do
                    ab[23 + aj - 1] = ai[aj]
                end
            end

            ab[23] = {
                ab[23],
            }
            ab[24] = a.game
            ab[26] = 'GetService'
            ab[25] = ab[24]
            ab[24] = ab[24][ab[26] ]
            ab[26] = 'TweenService'

            do
                local ah = 2
                local ai = pack(ab[24](b(ab, 25, 24 + ah)))

                for aj = 1, 1 do
                    ab[24 + aj - 1] = ai[aj]
                end
            end

            ab[25] = a.game
            ab[27] = 'GetService'
            ab[26] = ab[25]
            ab[25] = ab[25][ab[27] ]
            ab[27] = 'ReplicatedStorage'

            do
                local ah = 2
                local ai = pack(ab[25](b(ab, 26, 25 + ah)))

                for aj = 1, 1 do
                    ab[25 + aj - 1] = ai[aj]
                end
            end

            ab[25] = {
                ab[25],
            }
            ab[27] = ab[19][1]
            ab[28] = 'LocalPlayer'
            ab[26] = ab[27][ab[28] ]
            ab[26] = {
                ab[26],
            }
            ab[28] = ab[22]
            ab[29] = 'CurrentCamera'
            ab[27] = ab[28][ab[29] ]
            ab[27] = {
                ab[27],
            }
            ab[28] = true
            ab[28] = {
                ab[28],
            }

            for ah = 29, 29 do
                ab[ah] = nil
            end

            ab[29] = {
                ab[29],
            }
            ab[30] = function(...)
                return d.get_team_id({
                    ab[28],
                    ab[26],
                }, ...)
            end
            ab[29][1] = ab[30]

            for ah = 30, 30 do
                ab[ah] = nil
            end

            ab[30] = {
                ab[30],
            }
            ab[31] = function(...)
                return d.is_invulnerable({}, ...)
            end
            ab[30][1] = ab[31]

            for ah = 31, 31 do
                ab[ah] = nil
            end

            ab[31] = {
                ab[31],
            }
            ab[32] = function(...)
                return d.anti_katana_check({}, ...)
            end
            ab[31][1] = ab[32]
            ab[32] = true
            ab[32] = {
                ab[32],
            }
            ab[33] = false
            ab[33] = {
                ab[33],
            }
            ab[34] = false
            ab[34] = {
                ab[34],
            }
            ab[35] = 50000000
            ab[35] = {
                ab[35],
            }
            ab[36] = false
            ab[36] = {
                ab[36],
            }
            ab[37] = 50
            ab[37] = {
                ab[37],
            }
            ab[38] = false
            ab[38] = {
                ab[38],
            }
            ab[39] = false
            ab[39] = {
                ab[39],
            }
            ab[40] = 0.25
            ab[40] = {
                ab[40],
            }
            ab[41] = 0.1
            ab[41] = {
                ab[41],
            }
            ab[43] = a.task
            ab[44] = 'spawn'
            ab[42] = ab[43][ab[44] ]
            ab[43] = function(...)
                return d.wait_numeric_state({
                    ab[39],
                    ab[32],
                    ab[41],
                    ab[40],
                }, ...)
            end

            do
                local ah = 1

                ab[42](b(ab, 43, 42 + ah))
            end

            ab[42] = false
            ab[42] = {
                ab[42],
            }
            ab[43] = 5
            ab[43] = {
                ab[43],
            }
            ab[44] = 100
            ab[44] = {
                ab[44],
            }
            ab[45] = 'head'
            ab[45] = {
                ab[45],
            }
            ab[46] = false
            ab[46] = {
                ab[46],
            }
            ab[47] = false
            ab[47] = {
                ab[47],
            }
            ab[48] = false
            ab[48] = {
                ab[48],
            }
            ab[49] = false
            ab[49] = {
                ab[49],
            }
            ab[50] = 'head'
            ab[50] = {
                ab[50],
            }
            ab[51] = 300
            ab[51] = {
                ab[51],
            }
            ab[52] = false
            ab[52] = {
                ab[52],
            }
            ab[53] = false
            ab[53] = {
                ab[53],
            }

            for ah = 54, 54 do
                ab[ah] = nil
            end

            ab[55] = false
            ab[55] = {
                ab[55],
            }
            ab[56] = false
            ab[56] = {
                ab[56],
            }
            ab[57] = false
            ab[57] = {
                ab[57],
            }
            ab[58] = false
            ab[58] = {
                ab[58],
            }
            ab[59] = false
            ab[59] = {
                ab[59],
            }
            ab[60] = false
            ab[60] = {
                ab[60],
            }
            ab[61] = false
            ab[61] = {
                ab[61],
            }
            ab[62] = false
            ab[62] = {
                ab[62],
            }
            ab[63] = false
            ab[63] = {
                ab[63],
            }
            ab[64] = false
            ab[64] = {
                ab[64],
            }
            ab[65] = false
            ab[65] = {
                ab[65],
            }
            ab[66] = false
            a.espEnabled = ab[66]
            ab[66] = a._G
            ab[67] = 'espEnabled'
            ab[68] = false
            ab[66][ab[67] ] = ab[68]
            ab[66] = true
            a.espBoxEnabled = ab[66]
            ab[66] = true
            a.espNameEnabled = ab[66]
            ab[66] = true
            a.espHealthEnabled = ab[66]
            ab[66] = true
            a.espWeaponEnabled = ab[66]
            ab[66] = true
            ab[67] = true
            ab[68] = false
            ab[68] = {
                ab[68],
            }
            ab[69] = false
            ab[69] = {
                ab[69],
            }
            ab[70] = false
            ab[70] = {
                ab[70],
            }
            ab[71] = 50
            ab[71] = {
                ab[71],
            }
            ab[72] = 50
            ab[72] = {
                ab[72],
            }
            ab[73] = false
            ab[73] = {
                ab[73],
            }
            ab[74] = 'all walls'
            ab[74] = {
                ab[74],
            }
            ab[75] = false
            ab[75] = {
                ab[75],
            }
            ab[76] = false
            ab[76] = {
                ab[76],
            }
            ab[77] = 40
            ab[77] = {
                ab[77],
            }

            for ah = 78, 78 do
                ab[ah] = nil
            end

            ab[78] = {
                ab[78],
            }

            for ah = 79, 79 do
                ab[ah] = nil
            end

            ab[79] = {
                ab[79],
            }
            ab[80] = a.getgenv

            do
                local ah = 0
                local ai = pack(ab[80](b(ab, 81, 80 + ah)))

                for aj = 1, 1 do
                    ab[80 + aj - 1] = ai[aj]
                end
            end

            ab[81] = '_VantaEmoteSelected'
            ab[82] = 'Dance'
            ab[80][ab[81] ] = ab[82]
            ab[80] = a.getgenv

            do
                local ah = 0
                local ai = pack(ab[80](b(ab, 81, 80 + ah)))

                for aj = 1, 1 do
                    ab[80 + aj - 1] = ai[aj]
                end
            end

            ab[81] = '_VantaEmoteAnimIds'
            ab[82] = {}
            ab[83] = 'Bodybuilder'
            ab[84] = '3994130516'
            ab[82][ab[83] ] = ab[84]
            ab[83] = 'Crawling in a Circle'
            ab[84] = '116935126100338'
            ab[82][ab[83] ] = ab[84]
            ab[83] = 'Dolphin Dance'
            ab[84] = '5938365243'
            ab[82][ab[83] ] = ab[84]
            ab[83] = 'Dance'
            ab[84] = '507771019'
            ab[82][ab[83] ] = ab[84]
            ab[83] = 'Dance Break'
            ab[84] = '94258912028011'
            ab[82][ab[83] ] = ab[84]
            ab[83] = 'French Confidence'
            ab[84] = '116968182519797'
            ab[82][ab[83] ] = ab[84]
            ab[83] = 'Floss'
            ab[84] = '72174079036035'
            ab[82][ab[83] ] = ab[84]
            ab[83] = 'Frosty Flair'
            ab[84] = '10214406616'
            ab[82][ab[83] ] = ab[84]
            ab[83] = 'Full Wiggle'
            ab[84] = '86520127496722'
            ab[82][ab[83] ] = ab[84]
            ab[83] = 'Ghost Floating'
            ab[84] = '75911227509248'
            ab[82][ab[83] ] = ab[84]
            ab[83] = 'Gun'
            ab[84] = '81100102810594'
            ab[82][ab[83] ] = ab[84]
            ab[83] = 'Gangnam Style'
            ab[84] = '78801539668900'
            ab[82][ab[83] ] = ab[84]
            ab[83] = 'Hip Bounce'
            ab[84] = '123602332785269'
            ab[82][ab[83] ] = ab[84]
            ab[83] = 'Hype Dance'
            ab[84] = '93079641847306'
            ab[82][ab[83] ] = ab[84]
            ab[83] = 'Kicking Feet'
            ab[84] = '109814083870185'
            ab[82][ab[83] ] = ab[84]
            ab[83] = 'Line Dance'
            ab[84] = '4049646104'
            ab[82][ab[83] ] = ab[84]
            ab[83] = 'Lay Floating'
            ab[84] = '126579240140537'
            ab[82][ab[83] ] = ab[84]
            ab[83] = "Let's Drive"
            ab[84] = '17360720445'
            ab[82][ab[83] ] = ab[84]
            ab[83] = 'Long Legs'
            ab[84] = '82416741608012'
            ab[82][ab[83] ] = ab[84]
            ab[83] = 'Rock Out'
            ab[84] = '18225077553'
            ab[82][ab[83] ] = ab[84]
            ab[83] = 'Samba'
            ab[84] = '6869813008'
            ab[82][ab[83] ] = ab[84]
            ab[83] = 'Still Standing'
            ab[84] = '11435177473'
            ab[82][ab[83] ] = ab[84]
            ab[83] = 'Spiral'
            ab[84] = '81926730031709'
            ab[82][ab[83] ] = ab[84]
            ab[83] = 'Solar System'
            ab[84] = '118314972618293'
            ab[82][ab[83] ] = ab[84]
            ab[83] = 'Twirl'
            ab[84] = '3716633898'
            ab[82][ab[83] ] = ab[84]
            ab[83] = 'Take Me Under'
            ab[84] = '6797938823'
            ab[82][ab[83] ] = ab[84]
            ab[83] = 'The Worm'
            ab[84] = '99563207397301'
            ab[82][ab[83] ] = ab[84]
            ab[83] = 'Take the L'
            ab[84] = '110664723286332'
            ab[82][ab[83] ] = ab[84]
            ab[83] = 'Zesty'
            ab[84] = '102901317133934'
            ab[82][ab[83] ] = ab[84]
            ab[80][ab[81] ] = ab[82]
            ab[80] = a.getgenv

            do
                local ah = 0
                local ai = pack(ab[80](b(ab, 81, 80 + ah)))

                for aj = 1, 1 do
                    ab[80 + aj - 1] = ai[aj]
                end
            end

            ab[81] = '_VantaEmoteNameList'
            ab[82] = {}
            ab[83] = 'Bodybuilder'
            ab[84] = 'Crawling in a Circle'
            ab[85] = 'Dolphin Dance'
            ab[86] = 'Dance'
            ab[87] = 'Dance Break'
            ab[88] = 'French Confidence'
            ab[89] = 'Floss'
            ab[90] = 'Frosty Flair'
            ab[91] = 'Full Wiggle'
            ab[92] = 'Ghost Floating'
            ab[93] = 'Gun'
            ab[94] = 'Gangnam Style'
            ab[95] = 'Hip Bounce'
            ab[96] = 'Hype Dance'
            ab[97] = 'Kicking Feet'
            ab[98] = 'Line Dance'
            ab[99] = 'Lay Floating'
            ab[100] = "Let's Drive"
            ab[101] = 'Long Legs'
            ab[102] = 'Rock Out'
            ab[103] = 'Samba'
            ab[104] = 'Still Standing'
            ab[105] = 'Spiral'
            ab[106] = 'Solar System'
            ab[107] = 'Twirl'
            ab[108] = 'Take Me Under'
            ab[109] = 'The Worm'
            ab[110] = 'Take the L'
            ab[111] = 'Zesty'

            do
                local ah, ai = 29, ab[82]

                for aj = 1, ah do
                    ai[0 + aj] = ab[82 + aj]
                end
            end

            ab[80][ab[81] ] = ab[82]
            ab[81] = a.getgenv

            do
                local ah = 0
                local ai = pack(ab[81](b(ab, 82, 81 + ah)))

                for aj = 1, 1 do
                    ab[81 + aj - 1] = ai[aj]
                end
            end

            ab[82] = '_VantaEmoteSelected'
            ab[80] = ab[81][ab[82] ]

            if (not not ab[80]) == true then
                ag = 29
            else
                ag = 28
            end
        elseif ag == 28 then
            ab[80] = 'Dance'
            ag = 29
        elseif ag == 29 then
            ab[80] = {
                ab[80],
            }
            ab[82] = a.getgenv

            do
                local ah = 0
                local ai = pack(ab[82](b(ab, 83, 82 + ah)))

                for aj = 1, 1 do
                    ab[82 + aj - 1] = ai[aj]
                end
            end

            ab[83] = '_VantaEmoteAnimIds'
            ab[81] = ab[82][ab[83] ]
            ab[81] = {
                ab[81],
            }
            ab[83] = a.getgenv

            do
                local ah = 0
                local ai = pack(ab[83](b(ab, 84, 83 + ah)))

                for aj = 1, 1 do
                    ab[83 + aj - 1] = ai[aj]
                end
            end

            ab[84] = '_VantaEmoteNameList'
            ab[82] = ab[83][ab[84] ]

            for ah = 83, 83 do
                ab[ah] = nil
            end

            ab[83] = {
                ab[83],
            }
            ab[84] = function(...)
                return d.p114({
                    ab[78],
                    ab[79],
                }, ...)
            end
            ab[83][1] = ab[84]

            for ah = 84, 84 do
                ab[ah] = nil
            end

            ab[84] = {
                ab[84],
            }
            ab[85] = function(...)
                return d.play_emote({
                    ab[83],
                    ab[81],
                    ab[80],
                    ab[79],
                    ab[78],
                    ab[77],
                }, ...)
            end
            ab[84][1] = ab[85]
            ab[86] = a.task
            ab[87] = 'spawn'
            ab[85] = ab[86][ab[87] ]
            ab[86] = function(...)
                return d.watch_emote_speed({
                    ab[76],
                    ab[26],
                    ab[78],
                    ab[84],
                    ab[77],
                }, ...)
            end

            do
                local ah = 1

                ab[85](b(ab, 86, 85 + ah))
            end

            ab[86] = ab[26][1]
            ab[87] = 'CharacterAdded'
            ab[85] = ab[86][ab[87] ]
            ab[87] = 'Connect'
            ab[86] = ab[85]
            ab[85] = ab[85][ab[87] ]
            ab[87] = function(...)
                return d.p125({
                    ab[76],
                    ab[84],
                }, ...)
            end

            do
                local ah = 2

                ab[85](b(ab, 86, 85 + ah))
            end

            ab[85] = false
            ab[85] = {
                ab[85],
            }
            ab[86] = 'Dark Sky'
            ab[86] = {
                ab[86],
            }
            ab[87] = false
            ab[87] = {
                ab[87],
            }
            ab[88] = 'vr'
            ab[88] = {
                ab[88],
            }
            ab[89] = {}
            ab[90] = 'Dark Sky'
            ab[91] = {}
            ab[92] = 'SkyboxUp'
            ab[93] = 'rbxassetid://570555929'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxRt'
            ab[93] = 'rbxassetid://570555882'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxDn'
            ab[93] = 'rbxassetid://570555964'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxFt'
            ab[93] = 'rbxassetid://570555800'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxLf'
            ab[93] = 'rbxassetid://570555840'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxBk'
            ab[93] = 'rbxassetid://570555736'
            ab[91][ab[92] ] = ab[93]
            ab[89][ab[90] ] = ab[91]
            ab[90] = 'Vaporwave'
            ab[91] = {}
            ab[92] = 'SkyboxUp'
            ab[93] = 'rbxassetid://1417494643'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxRt'
            ab[93] = 'rbxassetid://1417494499'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxLf'
            ab[93] = 'rbxassetid://1417494402'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxFt'
            ab[93] = 'rbxassetid://1417494253'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxBk'
            ab[93] = 'rbxassetid://1417494030'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxDn'
            ab[93] = 'rbxassetid://1417494146'
            ab[91][ab[92] ] = ab[93]
            ab[89][ab[90] ] = ab[91]
            ab[90] = 'Lake Sky'
            ab[91] = {}
            ab[92] = 'SkyboxRt'
            ab[93] = 'rbxassetid://6823531746'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxUp'
            ab[93] = 'rbxassetid://6823528533'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SunTextureId'
            ab[93] = 'rbxassetid://5392574622'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxDn'
            ab[93] = 'rbxassetid://6823525702'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxFt'
            ab[93] = 'rbxassetid://6823482923'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxLf'
            ab[93] = 'rbxassetid://6823530023'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxBk'
            ab[93] = 'rbxassetid://6823523318'
            ab[91][ab[92] ] = ab[93]
            ab[89][ab[90] ] = ab[91]
            ab[90] = 'Black Mesa'
            ab[91] = {}
            ab[92] = 'SkyboxUp'
            ab[93] = 'rbxassetid://9569598752'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxRt'
            ab[93] = 'rbxassetid://9569601267'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxDn'
            ab[93] = 'rbxassetid://9569613307'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxFt'
            ab[93] = 'rbxassetid://9569611418'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxLf'
            ab[93] = 'rbxassetid://9569608166'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxBk'
            ab[93] = 'rbxassetid://9569742122'
            ab[91][ab[92] ] = ab[93]
            ab[89][ab[90] ] = ab[91]
            ab[90] = 'Space'
            ab[91] = {}
            ab[92] = 'SkyboxBk'
            ab[93] = 'rbxassetid://149397684'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxDn'
            ab[93] = 'rbxassetid://149397686'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxFt'
            ab[93] = 'rbxassetid://149397688'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxLf'
            ab[93] = 'rbxassetid://149397692'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxRt'
            ab[93] = 'rbxassetid://149397697'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxUp'
            ab[93] = 'rbxassetid://149397702'
            ab[91][ab[92] ] = ab[93]
            ab[89][ab[90] ] = ab[91]
            ab[90] = 'Night'
            ab[91] = {}
            ab[92] = 'SkyboxBk'
            ab[93] = 'rbxassetid://12064107'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxDn'
            ab[93] = 'rbxassetid://12064152'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxFt'
            ab[93] = 'rbxassetid://12064121'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxLf'
            ab[93] = 'rbxassetid://12064115'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxRt'
            ab[93] = 'rbxassetid://12063984'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxUp'
            ab[93] = 'rbxassetid://12064131'
            ab[91][ab[92] ] = ab[93]
            ab[89][ab[90] ] = ab[91]
            ab[90] = 'Sunset'
            ab[91] = {}
            ab[92] = 'SkyboxBk'
            ab[93] = 'rbxassetid://264908339'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxDn'
            ab[93] = 'rbxassetid://264907909'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxFt'
            ab[93] = 'rbxassetid://264909420'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxLf'
            ab[93] = 'rbxassetid://264908886'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxRt'
            ab[93] = 'rbxassetid://264909758'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxUp'
            ab[93] = 'rbxassetid://264907379'
            ab[91][ab[92] ] = ab[93]
            ab[89][ab[90] ] = ab[91]
            ab[90] = 'Cloudy'
            ab[91] = {}
            ab[92] = 'SkyboxBk'
            ab[93] = 'rbxassetid://591058823'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxDn'
            ab[93] = 'rbxassetid://591059876'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxFt'
            ab[93] = 'rbxassetid://591058104'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxLf'
            ab[93] = 'rbxassetid://591057861'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxRt'
            ab[93] = 'rbxassetid://591057625'
            ab[91][ab[92] ] = ab[93]
            ab[92] = 'SkyboxUp'
            ab[93] = 'rbxassetid://591059642'
            ab[91][ab[92] ] = ab[93]
            ab[89][ab[90] ] = ab[91]
            ab[89] = {
                ab[89],
            }

            for ah = 90, 90 do
                ab[ah] = nil
            end

            ab[90] = {
                ab[90],
            }
            ab[91] = function(...)
                return d.skybox_manager({
                    ab[85],
                    ab[86],
                    ab[89],
                }, ...)
            end
            ab[90][1] = ab[91]
            ab[92] = a.task
            ab[93] = 'spawn'
            ab[91] = ab[92][ab[93] ]
            ab[92] = function(...)
                return d.p130({
                    ab[85],
                    ab[90],
                    ab[86],
                }, ...)
            end

            do
                local ah = 1

                ab[91](b(ab, 92, 91 + ah))
            end

            ab[91] = false
            ab[91] = {
                ab[91],
            }
            ab[92] = ''
            ab[93] = ''
            ab[94] = false
            ab[96] = a.Vector3
            ab[97] = 'zero'
            ab[95] = ab[96][ab[97] ]
            ab[97] = a.Vector3
            ab[98] = 'new'
            ab[96] = ab[97][ab[98] ]
            ab[97] = 0
            ab[98] = 2
            ab[99] = 0

            do
                local ah = 3
                local ai = pack(ab[96](b(ab, 97, 96 + ah)))

                for aj = 1, 1 do
                    ab[96 + aj - 1] = ai[aj]
                end
            end

            for ah = 97, 97 do
                ab[ah] = nil
            end

            ab[97] = {
                ab[97],
            }

            for ah = 98, 98 do
                ab[ah] = nil
            end

            ab[98] = {
                ab[98],
            }

            for ah = 99, 99 do
                ab[ah] = nil
            end

            ab[99] = {
                ab[99],
            }
            ab[100] = function(...)
                return d.find_hitbox_part({}, ...)
            end
            ab[99][1] = ab[100]

            for ah = 100, 100 do
                ab[ah] = nil
            end

            ab[100] = {
                ab[100],
            }
            ab[101] = function(...)
                return d.p132({}, ...)
            end
            ab[101] = {
                ab[101],
            }
            ab[102] = false
            ab[102] = {
                ab[102],
            }
            ab[103] = 3
            ab[103] = {
                ab[103],
            }
            ab[104] = 0
            ab[105] = 3
            ab[106] = 0
            ab[104] = {
                ab[104],
            }
            ab[105] = {
                ab[105],
            }
            ab[106] = {
                ab[106],
            }
            ab[107] = 500
            ab[107] = {
                ab[107],
            }
            ab[108] = true
            ab[108] = {
                ab[108],
            }
            ab[109] = 'closest'
            ab[109] = {
                ab[109],
            }
            ab[110] = 0
            ab[110] = {
                ab[110],
            }
            ab[112] = a.task
            ab[113] = 'spawn'
            ab[111] = ab[112][ab[113] ]
            ab[112] = function(...)
                return d.silent_aim_bootstrap({
                    ab[26],
                    ab[25],
                    ab[100],
                    ab[20],
                    ab[102],
                    ab[32],
                    ab[98],
                    ab[19],
                    ab[29],
                    ab[30],
                    ab[31],
                    ab[101],
                }, ...)
            end

            do
                local ah = 1

                ab[111](b(ab, 112, 111 + ah))
            end

            for ah = 111, 111 do
                ab[ah] = nil
            end

            ab[111] = {
                ab[111],
            }

            for ah = 112, 112 do
                ab[ah] = nil
            end

            ab[112] = {
                ab[112],
            }

            for ah = 113, 113 do
                ab[ah] = nil
            end

            ab[113] = {
                ab[113],
            }
            ab[114] = function(...)
                return d.p144({
                    ab[26],
                }, ...)
            end
            ab[113][1] = ab[114]

            for ah = 114, 114 do
                ab[ah] = nil
            end

            ab[114] = {
                ab[114],
            }
            ab[115] = function(...)
                return d.capture_root_state({
                    ab[26],
                    ab[111],
                    ab[112],
                }, ...)
            end
            ab[114][1] = ab[115]
            ab[115] = a.pcall
            ab[116] = function(...)
                return d.unbind_desync_restore({
                    ab[20],
                }, ...)
            end

            do
                local ah = 1

                ab[115](b(ab, 116, 115 + ah))
            end

            ab[115] = a.pcall
            ab[116] = function(...)
                return d.bind_desync_restore({
                    ab[20],
                    ab[114],
                }, ...)
            end

            do
                local ah = 1

                ab[115](b(ab, 116, 115 + ah))
            end

            ab[116] = ab[20][1]
            ab[117] = 'RenderStepped'
            ab[115] = ab[116][ab[117] ]
            ab[117] = 'Connect'
            ab[116] = ab[115]
            ab[115] = ab[115][ab[117] ]
            ab[117] = ab[114][1]

            do
                local ah = 2

                ab[115](b(ab, 116, 115 + ah))
            end

            ab[116] = ab[20][1]
            ab[117] = 'Heartbeat'
            ab[115] = ab[116][ab[117] ]
            ab[117] = 'Connect'
            ab[116] = ab[115]
            ab[115] = ab[115][ab[117] ]
            ab[117] = function(...)
                return d.rage_desync_step({
                    ab[2],
                    ab[102],
                    ab[98],
                    ab[111],
                    ab[26],
                    ab[114],
                    ab[32],
                    ab[113],
                    ab[19],
                    ab[31],
                    ab[107],
                    ab[112],
                    ab[104],
                    ab[105],
                    ab[103],
                    ab[106],
                    ab[110],
                    ab[34],
                    ab[97],
                    ab[35],
                }, ...)
            end

            do
                local ah = 2

                ab[115](b(ab, 116, 115 + ah))
            end

            ab[116] = a.task
            ab[117] = 'spawn'
            ab[115] = ab[116][ab[117] ]
            ab[116] = function(...)
                return d.nearest_player_helper({
                    ab[102],
                    ab[39],
                    ab[32],
                    ab[26],
                    ab[19],
                    ab[29],
                    ab[30],
                    ab[31],
                    ab[99],
                    ab[98],
                }, ...)
            end

            do
                local ah = 1

                ab[115](b(ab, 116, 115 + ah))
            end

            for ah = 115, 115 do
                ab[ah] = nil
            end

            ab[115] = {
                ab[115],
            }

            for ah = 116, 116 do
                ab[ah] = nil
            end

            ab[116] = {
                ab[116],
            }
            ab[117] = function(...)
                return d.rage_worker_bootstrap({
                    ab[115],
                    ab[26],
                    ab[25],
                    ab[20],
                    ab[38],
                    ab[32],
                    ab[19],
                    ab[29],
                    ab[30],
                }, ...)
            end
            ab[116][1] = ab[117]
            ab[118] = ab[26][1]
            ab[119] = 'PlayerScripts'
            ab[117] = ab[118][ab[119] ]
            ab[118] = ab[117]
            ab[120] = 'WaitForChild'
            ab[119] = ab[118]
            ab[118] = ab[118][ab[120] ]
            ab[120] = 'Controllers'
            ab[121] = 10

            do
                local ah = 3
                local ai = pack(ab[118](b(ab, 119, 118 + ah)))

                for aj = 1, 1 do
                    ab[118 + aj - 1] = ai[aj]
                end
            end

            ab[118] = {
                ab[118],
            }
            ab[119] = a.require
            ab[121] = ab[25][1]
            ab[122] = 'Modules'
            ab[120] = ab[121][ab[122] ]
            ab[122] = 'WaitForChild'
            ab[121] = ab[120]
            ab[120] = ab[120][ab[122] ]
            ab[122] = 'EnumLibrary'
            ab[123] = 10

            do
                local ah = 3
                local ai = pack(ab[120](b(ab, 121, 120 + ah)))

                for aj = 1, ai.n do
                    ab[120 + aj - 1] = ai[aj]
                end

                ae = 120 + ai.n
            end
            do
                local ah = (ae - 119 - 1)
                local ai = pack(ab[119](b(ab, 120, 119 + ah)))

                for aj = 1, 1 do
                    ab[119 + aj - 1] = ai[aj]
                end
            end

            ab[119] = {
                ab[119],
            }
            ab[120] = ab[119][1]

            if (not not ab[120]) == false then
                ag = 31
            else
                ag = 30
            end
        elseif ag == 30 then
            ab[120] = ab[119][1]
            ab[122] = 'WaitForEnumBuilder'
            ab[121] = ab[120]
            ab[120] = ab[120][ab[122] ]

            do
                local ah = 1

                ab[120](b(ab, 121, 120 + ah))
            end

            ag = 31
        elseif ag == 31 then
            ab[120] = a.require
            ab[122] = ab[25][1]
            ab[123] = 'Modules'
            ab[121] = ab[122][ab[123] ]
            ab[123] = 'WaitForChild'
            ab[122] = ab[121]
            ab[121] = ab[121][ab[123] ]
            ab[123] = 'CosmeticLibrary'
            ab[124] = 10

            do
                local ah = 3
                local ai = pack(ab[121](b(ab, 122, 121 + ah)))

                for aj = 1, ai.n do
                    ab[121 + aj - 1] = ai[aj]
                end

                ae = 121 + ai.n
            end
            do
                local ah = (ae - 120 - 1)
                local ai = pack(ab[120](b(ab, 121, 120 + ah)))

                for aj = 1, 1 do
                    ab[120 + aj - 1] = ai[aj]
                end
            end

            ab[120] = {
                ab[120],
            }
            ab[121] = a.require
            ab[123] = ab[25][1]
            ab[124] = 'Modules'
            ab[122] = ab[123][ab[124] ]
            ab[124] = 'WaitForChild'
            ab[123] = ab[122]
            ab[122] = ab[122][ab[124] ]
            ab[124] = 'ItemLibrary'
            ab[125] = 10

            do
                local ah = 3
                local ai = pack(ab[122](b(ab, 123, 122 + ah)))

                for aj = 1, ai.n do
                    ab[122 + aj - 1] = ai[aj]
                end

                ae = 122 + ai.n
            end
            do
                local ah = (ae - 121 - 1)
                local ai = pack(ab[121](b(ab, 122, 121 + ah)))

                for aj = 1, 1 do
                    ab[121 + aj - 1] = ai[aj]
                end
            end

            ab[122] = a.require
            ab[123] = ab[118][1]
            ab[125] = 'WaitForChild'
            ab[124] = ab[123]
            ab[123] = ab[123][ab[125] ]
            ab[125] = 'PlayerDataController'
            ab[126] = 10

            do
                local ah = 3
                local ai = pack(ab[123](b(ab, 124, 123 + ah)))

                for aj = 1, ai.n do
                    ab[123 + aj - 1] = ai[aj]
                end

                ae = 123 + ai.n
            end
            do
                local ah = (ae - 122 - 1)
                local ai = pack(ab[122](b(ab, 123, 122 + ah)))

                for aj = 1, 1 do
                    ab[122 + aj - 1] = ai[aj]
                end
            end

            ab[122] = {
                ab[122],
            }
            ab[123] = {}
            ab[124] = {}
            ab[123] = {
                ab[123],
            }
            ab[124] = {
                ab[124],
            }

            for ah = 125, 125 do
                ab[ah] = nil
            end
            for ah = 126, 126 do
                ab[ah] = nil
            end

            ab[125] = {
                ab[125],
            }
            ab[126] = {
                ab[126],
            }

            for ah = 127, 127 do
                ab[ah] = nil
            end

            ab[127] = {
                ab[127],
            }

            for ah = 128, 128 do
                ab[ah] = nil
            end

            ab[128] = {
                ab[128],
            }
            ab[129] = function(...)
                return d.build_cosmetic_state({
                    ab[120],
                    ab[119],
                }, ...)
            end
            ab[128][1] = ab[129]
            ab[129] = 'unlockall/config.json'
            ab[129] = {
                ab[129],
            }

            for ah = 130, 130 do
                ab[ah] = nil
            end

            ab[130] = {
                ab[130],
            }
            ab[131] = function(...)
                return d.save_cosmetic_state({
                    ab[124],
                    ab[123],
                    ab[129],
                    ab[23],
                }, ...)
            end
            ab[130][1] = ab[131]
            ab[131] = function(...)
                return d.load_cosmetic_state({
                    ab[129],
                    ab[23],
                    ab[123],
                    ab[128],
                    ab[124],
                }, ...)
            end
            ab[132] = false
            ab[132] = {
                ab[132],
            }
            ab[134] = ab[120][1]
            ab[135] = 'OwnsCosmetic'
            ab[133] = ab[134][ab[135] ]
            ab[133] = {
                ab[133],
            }
            ab[134] = ab[120][1]
            ab[135] = 'OwnsCosmetic'
            ab[136] = function(...)
                return d.normalize_cosmetic_type({
                    ab[132],
                    ab[133],
                    ab[120],
                }, ...)
            end
            ab[134][ab[135] ] = ab[136]
            ab[134] = ab[120][1]
            ab[135] = 'OwnsCosmeticNormally'
            ab[136] = function(...)
                return d.p171({
                    ab[132],
                    ab[120],
                }, ...)
            end
            ab[134][ab[135] ] = ab[136]
            ab[134] = ab[120][1]
            ab[135] = 'OwnsCosmeticUniversally'
            ab[136] = function(...)
                return d.p172({
                    ab[132],
                    ab[120],
                }, ...)
            end
            ab[134][ab[135] ] = ab[136]
            ab[134] = ab[120][1]
            ab[135] = 'OwnsCosmeticForWeapon'
            ab[136] = function(...)
                return d.p173({
                    ab[132],
                    ab[120],
                }, ...)
            end
            ab[134][ab[135] ] = ab[136]
            ab[135] = ab[122][1]
            ab[136] = 'Get'
            ab[134] = ab[135][ab[136] ]
            ab[134] = {
                ab[134],
            }
            ab[135] = ab[122][1]
            ab[136] = 'Get'
            ab[137] = function(...)
                return d.build_cosmetic_inventory({
                    ab[134],
                    ab[132],
                    ab[120],
                    ab[124],
                }, ...)
            end
            ab[135][ab[136] ] = ab[137]
            ab[136] = ab[122][1]
            ab[137] = 'GetWeaponData'
            ab[135] = ab[136][ab[137] ]
            ab[135] = {
                ab[135],
            }
            ab[136] = ab[122][1]
            ab[137] = 'GetWeaponData'
            ab[138] = function(...)
                return d.index_cosmetics_by_name({
                    ab[135],
                    ab[123],
                }, ...)
            end
            ab[136][ab[137] ] = ab[138]

            for ah = 136, 136 do
                ab[ah] = nil
            end

            ab[136] = {
                ab[136],
            }
            ab[137] = a.pcall
            ab[138] = function(...)
                return d.load_fighter_controller({
                    ab[118],
                    ab[136],
                }, ...)
            end

            do
                local ah = 1

                ab[137](b(ab, 138, 137 + ah))
            end

            ab[137] = false

            if (not not ab[137]) == false then
                ag = 33
            else
                ag = 32
            end
        elseif ag == 32 then
            ab[137] = a.hookmetamethod
            ag = 33
        elseif ag == 33 then
            if (not not ab[137]) == false then
                ag = 47
            else
                ag = 34
            end
        elseif ag == 34 then
            ab[137] = ab[25][1]
            ab[139] = 'FindFirstChild'
            ab[138] = ab[137]
            ab[137] = ab[137][ab[139] ]
            ab[139] = 'Remotes'

            do
                local ah = 2
                local ai = pack(ab[137](b(ab, 138, 137 + ah)))

                for aj = 1, 1 do
                    ab[137 + aj - 1] = ai[aj]
                end
            end

            ab[138] = ab[137]

            if (not not ab[138]) == false then
                ag = 36
            else
                ag = 35
            end
        elseif ag == 35 then
            ab[138] = ab[137]
            ab[140] = 'FindFirstChild'
            ab[139] = ab[138]
            ab[138] = ab[138][ab[140] ]
            ab[140] = 'Data'

            do
                local ah = 2
                local ai = pack(ab[138](b(ab, 139, 138 + ah)))

                for aj = 1, 1 do
                    ab[138 + aj - 1] = ai[aj]
                end
            end

            ag = 36
        elseif ag == 36 then
            ab[139] = ab[138]

            if (not not ab[139]) == false then
                ag = 38
            else
                ag = 37
            end
        elseif ag == 37 then
            ab[139] = ab[138]
            ab[141] = 'FindFirstChild'
            ab[140] = ab[139]
            ab[139] = ab[139][ab[141] ]
            ab[141] = 'EquipCosmetic'

            do
                local ah = 2
                local ai = pack(ab[139](b(ab, 140, 139 + ah)))

                for aj = 1, 1 do
                    ab[139 + aj - 1] = ai[aj]
                end
            end

            ag = 38
        elseif ag == 38 then
            ab[139] = {
                ab[139],
            }
            ab[140] = ab[138]

            if (not not ab[140]) == false then
                ag = 40
            else
                ag = 39
            end
        elseif ag == 39 then
            ab[140] = ab[138]
            ab[142] = 'FindFirstChild'
            ab[141] = ab[140]
            ab[140] = ab[140][ab[142] ]
            ab[142] = 'FavoriteCosmetic'

            do
                local ah = 2
                local ai = pack(ab[140](b(ab, 141, 140 + ah)))

                for aj = 1, 1 do
                    ab[140 + aj - 1] = ai[aj]
                end
            end

            ag = 40
        elseif ag == 40 then
            ab[140] = {
                ab[140],
            }
            ab[141] = ab[137]

            if (not not ab[141]) == false then
                ag = 42
            else
                ag = 41
            end
        elseif ag == 41 then
            ab[141] = ab[137]
            ab[143] = 'FindFirstChild'
            ab[142] = ab[141]
            ab[141] = ab[141][ab[143] ]
            ab[143] = 'Replication'

            do
                local ah = 2
                local ai = pack(ab[141](b(ab, 142, 141 + ah)))

                for aj = 1, 1 do
                    ab[141 + aj - 1] = ai[aj]
                end
            end

            ag = 42
        elseif ag == 42 then
            ab[142] = ab[141]

            if (not not ab[142]) == false then
                ag = 44
            else
                ag = 43
            end
        elseif ag == 43 then
            ab[142] = ab[141]
            ab[144] = 'FindFirstChild'
            ab[143] = ab[142]
            ab[142] = ab[142][ab[144] ]
            ab[144] = 'Fighter'

            do
                local ah = 2
                local ai = pack(ab[142](b(ab, 143, 142 + ah)))

                for aj = 1, 1 do
                    ab[142 + aj - 1] = ai[aj]
                end
            end

            ag = 44
        elseif ag == 44 then
            ab[143] = ab[142]

            if (not not ab[143]) == false then
                ag = 46
            else
                ag = 45
            end
        elseif ag == 45 then
            ab[143] = ab[142]
            ab[145] = 'FindFirstChild'
            ab[144] = ab[143]
            ab[143] = ab[143][ab[145] ]
            ab[145] = 'UseItem'

            do
                local ah = 2
                local ai = pack(ab[143](b(ab, 144, 143 + ah)))

                for aj = 1, 1 do
                    ab[143 + aj - 1] = ai[aj]
                end
            end

            ag = 46
        elseif ag == 46 then
            ab[143] = {
                ab[143],
            }

            for ah = 144, 144 do
                ab[ah] = nil
            end

            ab[144] = {
                ab[144],
            }
            ab[145] = a.hookmetamethod
            ab[146] = a.game
            ab[147] = '__namecall'
            ab[148] = function(...)
                return d.cosmetic_namecall_hook({
                    ab[144],
                    ab[143],
                    ab[136],
                    ab[26],
                    ab[127],
                    ab[139],
                    ab[134],
                    ab[122],
                    ab[123],
                    ab[128],
                    ab[130],
                    ab[140],
                    ab[120],
                    ab[124],
                }, ...)
            end

            do
                local ah = 3
                local ai = pack(ab[145](b(ab, 146, 145 + ah)))

                for aj = 1, 1 do
                    ab[145 + aj - 1] = ai[aj]
                end
            end

            ab[144][1] = ab[145]
            ag = 47
        elseif ag == 47 then
            for ah = 137, 137 do
                ab[ah] = nil
            end

            ab[137] = {
                ab[137],
            }
            ab[138] = a.pcall
            ab[139] = function(...)
                return d.load_client_item_classes({
                    ab[26],
                    ab[137],
                }, ...)
            end

            do
                local ah = 1

                ab[138](b(ab, 139, 138 + ah))
            end

            ab[138] = ab[137][1]

            if (not not ab[138]) == false then
                ag = 49
            else
                ag = 48
            end
        elseif ag == 48 then
            ab[139] = ab[137][1]
            ab[140] = '_CreateViewModel'
            ab[138] = ab[139][ab[140] ]
            ag = 49
        elseif ag == 49 then
            if (not not ab[138]) == false then
                ag = 51
            else
                ag = 50
            end
        elseif ag == 50 then
            ab[139] = ab[137][1]
            ab[140] = '_CreateViewModel'
            ab[138] = ab[139][ab[140] ]
            ab[138] = {
                ab[138],
            }
            ab[139] = ab[137][1]
            ab[140] = '_CreateViewModel'
            ab[141] = function(...)
                return d.apply_item_skin({
                    ab[26],
                    ab[125],
                    ab[123],
                    ab[138],
                }, ...)
            end
            ab[139][ab[140] ] = ab[141]
            ag = 51
        elseif ag == 51 then
            ab[143] = ab[26][1]
            ab[144] = 'PlayerScripts'
            ab[142] = ab[143][ab[144] ]
            ab[143] = 'Modules'
            ab[141] = ab[142][ab[143] ]
            ab[142] = 'ClientReplicatedClasses'
            ab[140] = ab[141][ab[142] ]
            ab[141] = 'ClientFighter'
            ab[139] = ab[140][ab[141] ]
            ab[140] = 'ClientItem'
            ab[138] = ab[139][ab[140] ]
            ab[140] = 'FindFirstChild'
            ab[139] = ab[138]
            ab[138] = ab[138][ab[140] ]
            ab[140] = 'ClientViewModel'

            do
                local ah = 2
                local ai = pack(ab[138](b(ab, 139, 138 + ah)))

                for aj = 1, 1 do
                    ab[138 + aj - 1] = ai[aj]
                end
            end

            ab[139] = ab[138]

            if (not not ab[139]) == false then
                ag = 57
            else
                ag = 52
            end
        elseif ag == 52 then
            ab[139] = a.require
            ab[140] = ab[138]

            do
                local ah = 1
                local ai = pack(ab[139](b(ab, 140, 139 + ah)))

                for aj = 1, 1 do
                    ab[139 + aj - 1] = ai[aj]
                end
            end

            ab[141] = ab[139]
            ab[142] = 'GetCharm'
            ab[140] = ab[141][ab[142] ]

            if (not not ab[140]) == false then
                ag = 54
            else
                ag = 53
            end
        elseif ag == 53 then
            ab[141] = ab[139]
            ab[142] = 'GetCharm'
            ab[140] = ab[141][ab[142] ]
            ab[140] = {
                ab[140],
            }
            ab[141] = ab[139]
            ab[142] = 'GetCharm'
            ab[143] = function(...)
                return d.apply_item_charm({
                    ab[26],
                    ab[123],
                    ab[140],
                }, ...)
            end
            ab[141][ab[142] ] = ab[143]
            ag = 54
        elseif ag == 54 then
            ab[141] = ab[139]
            ab[142] = 'GetWrap'
            ab[140] = ab[141][ab[142] ]

            if (not not ab[140]) == false then
                ag = 56
            else
                ag = 55
            end
        elseif ag == 55 then
            ab[141] = ab[139]
            ab[142] = 'GetWrap'
            ab[140] = ab[141][ab[142] ]
            ab[140] = {
                ab[140],
            }
            ab[141] = ab[139]
            ab[142] = 'GetWrap'
            ab[143] = function(...)
                return d.apply_item_wrap({
                    ab[26],
                    ab[123],
                    ab[140],
                }, ...)
            end
            ab[141][ab[142] ] = ab[143]
            ag = 56
        elseif ag == 56 then
            ab[141] = ab[139]
            ab[142] = 'new'
            ab[140] = ab[141][ab[142] ]
            ab[140] = {
                ab[140],
            }
            ab[141] = ab[139]
            ab[142] = 'new'
            ab[143] = function(...)
                return d.refresh_client_fighter_cosmetics({
                    ab[125],
                    ab[26],
                    ab[123],
                    ab[25],
                    ab[140],
                }, ...)
            end
            ab[141][ab[142] ] = ab[143]
            ag = 57
        elseif ag == 57 then
            ab[139] = ab[121]
            ab[140] = 'GetViewModelImageFromWeaponData'
            ab[141] = function(...)
                return d.resolve_skin_image({
                    ab[123],
                    ab[126],
                    ab[26],
                }, ...)
            end
            ab[139][ab[140] ] = ab[141]

            for ah = 139, 139 do
                ab[ah] = nil
            end

            ab[139] = {
                ab[139],
            }
            ab[140] = a.pcall
            ab[141] = function(...)
                return d.get_emotes({
                    ab[118],
                    ab[139],
                    ab[120],
                }, ...)
            end

            do
                local ah = 1

                ab[140](b(ab, 141, 140 + ah))
            end

            ab[140] = a.pcall
            ab[141] = function(...)
                return d.fetch_profile_page({
                    ab[26],
                    ab[126],
                }, ...)
            end

            do
                local ah = 1

                ab[140](b(ab, 141, 140 + ah))
            end

            ab[140] = ab[131]

            do
                local ah = 0

                ab[140](b(ab, 141, 140 + ah))
            end

            ab[140] = ab[3][1]
            ab[142] = 'Window'
            ab[141] = ab[140]
            ab[140] = ab[140][ab[142] ]
            ab[142] = '\u{d560}\u{bb34}\u{bc18}\u{d0c0} free'

            do
                local ah = 2
                local ai = pack(ab[140](b(ab, 141, 140 + ah)))

                for aj = 1, 1 do
                    ab[140 + aj - 1] = ai[aj]
                end
            end

            ab[141] = {}
            ab[142] = 'Combat'
            ab[143] = ab[140]
            ab[145] = 'Tab'
            ab[144] = ab[143]
            ab[143] = ab[143][ab[145] ]
            ab[145] = 'Combat'

            do
                local ah = 2
                local ai = pack(ab[143](b(ab, 144, 143 + ah)))

                for aj = 1, 1 do
                    ab[143 + aj - 1] = ai[aj]
                end
            end

            ab[141][ab[142] ] = ab[143]
            ab[142] = 'Visuals'
            ab[143] = ab[140]
            ab[145] = 'Tab'
            ab[144] = ab[143]
            ab[143] = ab[143][ab[145] ]
            ab[145] = 'Visuals'

            do
                local ah = 2
                local ai = pack(ab[143](b(ab, 144, 143 + ah)))

                for aj = 1, 1 do
                    ab[143 + aj - 1] = ai[aj]
                end
            end

            ab[141][ab[142] ] = ab[143]
            ab[142] = 'Misc'
            ab[143] = ab[140]
            ab[145] = 'Tab'
            ab[144] = ab[143]
            ab[143] = ab[143][ab[145] ]
            ab[145] = 'Misc'

            do
                local ah = 2
                local ai = pack(ab[143](b(ab, 144, 143 + ah)))

                for aj = 1, 1 do
                    ab[143 + aj - 1] = ai[aj]
                end
            end

            ab[141][ab[142] ] = ab[143]
            ab[142] = 'UI Settings'
            ab[143] = ab[140]
            ab[145] = 'Tab'
            ab[144] = ab[143]
            ab[143] = ab[143][ab[145] ]
            ab[145] = 'UI Settings'

            do
                local ah = 2
                local ai = pack(ab[143](b(ab, 144, 143 + ah)))

                for aj = 1, 1 do
                    ab[143 + aj - 1] = ai[aj]
                end
            end

            ab[141][ab[142] ] = ab[143]
            ab[141] = {
                ab[141],
            }
            ab[143] = ab[141][1]
            ab[144] = 'UI Settings'
            ab[142] = ab[143][ab[144] ]
            ab[144] = 'Section'
            ab[143] = ab[142]
            ab[142] = ab[142][ab[144] ]
            ab[144] = 'menu'
            ab[145] = 1

            do
                local ah = 3
                local ai = pack(ab[142](b(ab, 143, 142 + ah)))

                for aj = 1, 1 do
                    ab[142 + aj - 1] = ai[aj]
                end
            end

            ab[143] = ab[142]
            ab[145] = 'Label'
            ab[144] = ab[143]
            ab[143] = ab[143][ab[145] ]
            ab[145] = 'menu key: Right Shift'

            do
                local ah = 2

                ab[143](b(ab, 144, 143 + ah))
            end

            ab[143] = ab[142]
            ab[145] = 'Label'
            ab[144] = ab[143]
            ab[143] = ab[143][ab[145] ]
            ab[145] = 'key system: disabled'

            do
                local ah = 2

                ab[143](b(ab, 144, 143 + ah))
            end

            ab[143] = ab[142]
            ab[145] = 'Label'
            ab[144] = ab[143]
            ab[143] = ab[143][ab[145] ]
            ab[145] = 'max key users: 11'

            do
                local ah = 2

                ab[143](b(ab, 144, 143 + ah))
            end

            ab[143] = ab[142]
            ab[145] = 'Toggle'
            ab[144] = ab[143]
            ab[143] = ab[143][ab[145] ]
            ab[145] = 'show custom cursor'
            ab[146] = false
            ab[147] = function(...)
                return d.toggle_custom_cursor({}, ...)
            end

            do
                local ah = 4

                ab[143](b(ab, 144, 143 + ah))
            end

            ab[143] = ab[142]
            ab[145] = 'Button'
            ab[144] = ab[143]
            ab[143] = ab[143][ab[145] ]
            ab[145] = 'unload script'
            ab[146] = function(...)
                return d.unload_script({}, ...)
            end

            do
                local ah = 3

                ab[143](b(ab, 144, 143 + ah))
            end

            ab[144] = ab[141][1]
            ab[145] = 'UI Settings'
            ab[143] = ab[144][ab[145] ]
            ab[145] = 'Section'
            ab[144] = ab[143]
            ab[143] = ab[143][ab[145] ]
            ab[145] = 'info'
            ab[146] = 2

            do
                local ah = 3
                local ai = pack(ab[143](b(ab, 144, 143 + ah)))

                for aj = 1, 1 do
                    ab[143 + aj - 1] = ai[aj]
                end
            end

            ab[144] = ab[143]
            ab[146] = 'Label'
            ab[145] = ab[144]
            ab[144] = ab[144][ab[146] ]
            ab[146] = '\u{d560}\u{bb34}\u{bc18}\u{d0c0} free \u{b7} authorized'

            do
                local ah = 2

                ab[144](b(ab, 145, 144 + ah))
            end

            ab[144] = ab[143]
            ab[146] = 'Label'
            ab[145] = ab[144]
            ab[144] = ab[144][ab[146] ]
            ab[146] = 'skins embedded \u{b7} no external links'

            do
                local ah = 2

                ab[144](b(ab, 145, 144 + ah))
            end

            ab[142] = function(...)
                return d.build_main_ui({
                    ab[141],
                    ab[49],
                    ab[50],
                    ab[51],
                    ab[52],
                    ab[53],
                    ab[42],
                    ab[45],
                    ab[43],
                    ab[44],
                    ab[46],
                    ab[47],
                    ab[48],
                    ab[8],
                    ab[33],
                    ab[102],
                    ab[101],
                    ab[34],
                    ab[35],
                    ab[39],
                    ab[32],
                    ab[40],
                    ab[41],
                    ab[104],
                    ab[105],
                    ab[103],
                    ab[106],
                    ab[107],
                    ab[110],
                    ab[108],
                    ab[109],
                    ab[28],
                    ab[38],
                    ab[36],
                    ab[116],
                    ab[55],
                    ab[56],
                    ab[57],
                    ab[58],
                    ab[59],
                    ab[60],
                    ab[37],
                    ab[91],
                    ab[63],
                    ab[85],
                    ab[90],
                    ab[86],
                    ab[64],
                    ab[65],
                    ab[61],
                    ab[62],
                    ab[132],
                    ab[122],
                    ab[26],
                    ab[69],
                    ab[71],
                    ab[70],
                    ab[72],
                    ab[73],
                    ab[74],
                    ab[76],
                    ab[84],
                    ab[83],
                    ab[80],
                    ab[77],
                    ab[78],
                    ab[20],
                    ab[2],
                    ab[87],
                    ab[88],
                    ab[75],
                    ab[68],
                }, ...)
            end
            ab[143] = ab[142]

            do
                local ah = 0

                ab[143](b(ab, 144, 143 + ah))
            end

            ab[142] = function(...)
                return d.client_feature_bootstrap({
                    ab[141],
                    ab[3],
                }, ...)
            end
            ab[143] = ab[142]

            do
                local ah = 0

                ab[143](b(ab, 144, 143 + ah))
            end

            ab[142] = function(...)
                return d.init_esp({
                    ab[26],
                    ab[19],
                    ab[20],
                    ab[27],
                    ab[2],
                    ab[29],
                    ab[55],
                    ab[63],
                }, ...)
            end
            ab[143] = ab[142]

            do
                local ah = 0

                ab[143](b(ab, 144, 143 + ah))
            end

            ab[142] = function(...)
                return d.combat_runtime({}, ...)
            end
            ab[143] = ab[142]

            do
                local ah = 0

                ab[143](b(ab, 144, 143 + ah))
            end

            ab[142] = a.pcall
            ab[143] = function(...)
                return d.build_wallbang_ui({
                    ab[141],
                }, ...)
            end

            do
                local ah = 1

                ab[142](b(ab, 143, 142 + ah))
            end

            local ah = 0

            return b(ab, 0, 0 + ah - 1)
        else
            return
        end
    end
end

return d.root_bootstrap({}, ...)