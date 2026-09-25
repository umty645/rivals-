loadstring(game:HttpGet("https://raw.githubusercontent.com/DeoSCRIPTS/VoxVoid/refs/heads/main/loader.lua"))()

local players = game:GetService("Players")
local localplayer = players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local user_input_service = game:GetService("UserInputService")
local run_service = game:GetService("RunService")
local virtual_user = game:GetService("VirtualUser")
local workspace = game:GetService("Workspace")
local http_service = game:GetService("HttpService")
local teleport_service = game:GetService("TeleportService")
local lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local manip_ray_params = RaycastParams.new()

local manip_offsets = {
 Vector3.new(0,12,0), Vector3.new(0,16,0), Vector3.new(0,20,0), Vector3.new(0,24,0),
 Vector3.new(0,28,0), Vector3.new(0,32,0), Vector3.new(0,36,0), Vector3.new(0,40,0),
}

local manipulation = {}

do
 manipulation.get_closest = function()
  if not localplayer.Character or not localplayer.Character:FindFirstChild("HumanoidRootPart") then return nil, nil end
  local my_hrp = localplayer.Character.HumanoidRootPart
  local my_pos = my_hrp.Position
  local target, char, best_score = nil, nil, math.huge
  local my_team = localplayer.Team
  for _, v in next, players:GetPlayers() do
   if v ~= localplayer and v.Character then
    local head = v.Character:FindFirstChild("Head")
    local t_hrp = v.Character:FindFirstChild("HumanoidRootPart")
    local hum = v.Character:FindFirstChildOfClass("Humanoid")
    local no_ff = not v.Character:FindFirstChildOfClass("ForceField")
    local diff_team = my_team == nil or v.Team == nil or my_team ~= v.Team
    if head and t_hrp and hum and hum.Health > 0 and no_ff and diff_team then
     local mag = (my_pos - head.Position).Magnitude

     local vel = t_hrp.AssemblyLinearVelocity
     local predicted_pos = t_hrp.Position + vel * 0.1
     local predicted_mag = (my_pos - predicted_pos).Magnitude

     local hp_penalty = math.clamp(hum.Health / (hum.MaxHealth + 1), 0, 1) * 200
     local score = (mag * 0.6 + predicted_mag * 0.4) + hp_penalty
     if score < best_score then best_score = score; target = head; char = v.Character end
    end
   end
  end
  return target, char
 end
 manipulation.calculate_point = function(origin, target_pos, target_char)
  manip_ray_params.FilterDescendantsInstances = {localplayer.Character, target_char}
  manip_ray_params.FilterType = Enum.RaycastFilterType.Exclude
  if not workspace:Raycast(origin, target_pos - origin, manip_ray_params) then return origin, nil end
  for _, offset in next, manip_offsets do
   local scan_pos = origin + offset
   if not workspace:Raycast(scan_pos, target_pos - scan_pos, manip_ray_params) then return scan_pos, offset.Y end
  end
  return nil, nil
 end
 manipulation.fire_toward = function(target_part, target_char)
  pcall(function()
   local rs = game:GetService("ReplicatedStorage")
   local util_ok, util = pcall(require, rs.Modules.Utility)
   local enums_ok, enums = pcall(require, rs.Modules.EnumLibrary)
   local fighter_ok, fighter = pcall(require, localplayer.PlayerScripts.Controllers.FighterController)
   if not util_ok or not enums_ok or not fighter_ok then return end
   if not fighter.LocalFighter then return end
   local item = fighter.LocalFighter.EquippedItem
   if not item then return end
   local cam = workspace.CurrentCamera.CFrame
   local manip_pt, height = manipulation.calculate_point(cam.Position, target_part.Position, target_char)
   if not manip_pt then return end
   local shoot_pos = (height == nil and manip_pt) or cam.Position
   local cameradata = {}
   cameradata[utf8.char(1)] = {
    [utf8.char(0)] = util:EncodeCFrame(CFrame.new(shoot_pos.X, shoot_pos.Y + (height or 0), shoot_pos.Z) * CFrame.Angles(CFrame.lookAt(shoot_pos, target_part.Position):ToOrientation())),
    [utf8.char(1)] = height and util:EncodeCFrame(CFrame.new(target_part.Position) * CFrame.Angles(CFrame.lookAt(shoot_pos, target_part.Position):ToOrientation())) or util:EncodeCFrame(CFrame.new(shoot_pos.X, shoot_pos.Y + (height or 0), shoot_pos.Z) * CFrame.Angles(CFrame.lookAt(shoot_pos, target_part.Position):ToOrientation())),
    [utf8.char(2)] = target_part,
    [utf8.char(3)] = util:EncodeCFrame(target_part.CFrame:ToObjectSpace(CFrame.new(target_part.Position))),
   }
   rs.Remotes.Replication.Fighter.UseItem:FireServer(item:Get("ObjectID"), enums:ToEnum("StartShooting"), cameradata, nil)
  end)
 end

end

getgenv().config = {
 et_order = "spiral", et_mode = "Random", et_speed = 1000, et_total = 1000,
 sleepyhub_counter_enabled = false, ue_counter_enabled = false, hook_counter_enabled = false,
 slingshot_bypass_enabled = false, slingshot_bypass_range = 100000000000000, slingshot_bypass_manipulation = true, slingshot_bypass_tp = true,
 slingshot_orbit_enabled = false, slingshot_orbit_radius = 6, slingshot_orbit_speed = 180,
 glue_enabled = false,
 glue_distance = 0,
 glue_height = 0,
 glue_hide_time = 0.45,
 glue_attack_time = 0.55,
 anti_teleportation = false,
 anti_tp_threshold = 2000,
 anti_tp_escape_dist = 100000000,
 vst_attack_method = "Adaptive",
 ui_keybind = "RightControl",
 ui_lock_keybind = "LeftControl",
 vs_pos_resolver = false, vs_predictive_sync = false, vs_protocol = "Adaptive", vs_pos_restore = false,
 vs_min_dist = 1, vs_max_dist = 50000,
 vs_char_origin = false,
 vs_dir_xp = 5000, vs_dir_xn = 5000, vs_dir_yp = 5000, vs_dir_yn = 5000, vs_dir_zp = 5000, vs_dir_zn = 5000,
 vs_radius = 50000,
 vs_stabilizer_enabled = false, vs_stability = 50,
 vs_movement = "Random",
 vs_smoothness_enabled = false, vs_smoothness = 10,
 vs_interval = 1,
 vs_depth_bias = 0, vs_chaos_amp = 1, vs_burst_delay = 0, vs_axis_lock_strength = 0,
 evs_direction = "Down",
 evs_distance = 50000,
 evs_void_tick = 60,
 evs_iter_count = 200,
 evs_iter_speed = 1,
 evs_x_radius = 0,
 evs_y_radius = 0,
 evs_z_radius = 0,
 vs_motion_tog1 = false,
 vs_motion_tog2 = false,
 vs_motion_tog3 = false,
 vs_motion_tog4 = false,
 vs_motion_tog5 = false,
 evs_iter_mode = "Adaptive",
 evs_axis_radius = 3000000,
 evs_phase_shift = 0,
 evs_amplitude = 1,
 evs_frequency = 1,
 evs_spread = 500,
 evs_orbit_radius = 10000,
 evs_orbit_speed = 5,
 evs_spiral_tightness = 1,
 evs_jitter = 0,
 evs_y_bias = 0,
 evs_burst = 100,
 evs_layer_count = 1,
 evs_pattern = "Linear",
 evs_axis = "Y",
 evs_falloff = "None",
 evs_blend_mode = "Replace",
 evs_auto_reverse = false,
 evs_kill_velocity = true,
 evs_warp_mode = "Instant",
 evs_gravity_mult = 1,
 evs_rotation_chaos = false,
 evs_snap_back = false,
 evs_snap_back_delay = 0,
 evs_layer_offset = 0,
 evs_axis_clamp = 0,
 evs_turbulence = 0,
 evs_echo_count = 0,
 evs_echo_decay = 0.5,
 evs_invert_x = false,
 evs_invert_y = false,
 evs_invert_z = false,
 evs_pattern2 = "None",
 evs_blend_weight = 0.5,
 vs_dir_mode = "Uniform",
 vs_radial_scale = 1,
 vs_vertical_bias = 0,
 vs_horizontal_lock = false,
 vs_chaos_mode = "Off",
 vs_chaos_intensity = 1,
 vs_pulse_rate = 1,
 vs_warp_bias = 0,
 vs_gravity_drain = false,
 vs_eccentricity = 0,
 vs_enter_delay = 0,
 vs_exit_delay = 0,
 vs_snap_mode = "Instant",
 vs_burst_shape = "Random",
 vs_recoil_comp = false,
 vs_recoil_scale = 1,
 vs_pos_clamp = false,
 vs_pos_clamp_radius = 50000,
 vs_scatter_seed = 1,
 vs_phase_mode = "Off",
 vs_dir_blend = "None",
 vs_layer_mix = "Sequential",
 vs_burst_fade = false,
 vs_burst_fade_alpha = 0.5,
 vs_momentum_carry = false,
 vs_momentum_scale = 1,
 vs_angular_noise = 0,
 vs_void_gate = false,
 vs_void_gate_dist = 10000,

 evs_scatter_mode = "Random",
 evs_burst_profile = "Flat",
 evs_tick_jitter = 0,
 evs_invert_burst = false,
 evs_clamp_radius = 0,
 evs_orbit_lock = false,
 evs_wave_freq = 1,
 evs_depth_floor = 0,
 evs_axis_weight_x = 1,
 evs_axis_weight_y = 1,
 evs_axis_weight_z = 1,
 evs_burst_stagger = 0,
 evs_layer_blend = "Add",
 evs_pulse_sync = false,
 evs_gravity_dir = "Down",
 evs_spin_lock = false,
 vst_enabled = false,
 vst_spin_speed = 1e85,
 vst_type = "Defensive",
 gm_speed = 9e24,
 gm_spread_dir = "All",
 vst_unhittability_y_range = 10,
 vst_defend_intensity = 50,
 vst_translocation_intensity = 50,
 vst_hide_mode = "Defensive",
 vst_defend_proximity_escape = true,
 vst_defend_proximity_radius = 50000000,
 vst_defend_escape_dist = 3000000,
 vst_bait_depth = 20,
 vst_defend_x_dist = 10000,
 vst_defend_y_dist = 10000,
 vst_defend_z_dist = 10000,
 vst_attack_tracking_type = "Teleportation",
 void_hide_x = 1e6,
 void_hide_y = 9e25,
 void_hide_enabled = false,

 void_hide_z = 1e6, pixel_enabled = false, pixel_count = 8,

 fake_pos_enabled = false,
 fake_pos_radius = 500,
 fake_pos_height = 0,
 fake_pos_speed = 50,
 fake_pos_count = 5,
 fake_pos_drop1 = "Scatter",
 fake_pos_drop2 = "Random",
 fake_pos_drop3 = "None",
 fake_pos_drop4 = "Linear",
 fake_pos_drop5 = "Off",
 fake_pos_tog1 = false,
 fake_pos_tog2 = false,
 fake_pos_tog3 = false,
 fake_pos_tog4 = false,
 fake_pos_tog5 = false,
 desync_enabled = false,
 desync_intensity = 50,
 desync_speed = 10,
 desync_angle = 90,
 desync_jitter = 20,
 desync_flip = false,
 desync_unhittable_enabled = false,
 desync_unhittable_intensity = 50,
 desync_unhittable_radius = 9000,
 desync_unhittable_iters = 100,
 desync_unhittable_y_range = 10, vs_sl1 = 50, vs_sl2 = 10, vs_sl3 = 10, vs_sl4 = 0, vs_sl5 = 10,
 vs_sl6 = 0, vs_sl7 = 10, vs_sl8 = 0, vs_sl9 = 10, vs_sl10 = 0,
 vs_sl11 = 10, vs_sl12 = 0, vs_sl13 = 10, vs_sl14 = 0, vs_sl15 = 10,
 vs_sl16 = 0, vs_sl17 = 10, vs_sl18 = 1, vs_sl19 = 0, vs_sl20 = 10,
 vs_sl21 = 0, vs_sl22 = 10, vs_sl23 = 0, vs_sl24 = 1, vs_sl25 = 0,
 vs_sl26 = 10, vs_sl27 = 0, vs_sl28 = 10, vs_sl29 = 0, vs_sl30 = 1,
 vs_sl31 = 0, vs_sl32 = 10, vs_sl33 = 0, vs_sl34 = 10, vs_sl35 = 0,
 vs_sl36 = 10, vs_sl37 = 0, vs_sl38 = 1, vs_sl39 = 0, vs_sl40 = 10,
 vs_dr1 = "Scatter", vs_dr2 = "Random", vs_dr3 = "None", vs_dr4 = "Linear", vs_dr5 = "Off",
 vs_dr6 = "Uniform", vs_dr7 = "Replace", vs_dr8 = "Adaptive", vs_dr9 = "Instant", vs_dr10 = "None",
 vs_dr11 = "Random", vs_dr12 = "Add", vs_dr13 = "Sphere", vs_dr14 = "Flat", vs_dr15 = "Down",
 vs_dr16 = "All", vs_dr17 = "Sequential", vs_dr18 = "None", vs_dr19 = "Off", vs_dr20 = "Random",
 vs_dr21 = "Instant", vs_dr22 = "None", vs_dr23 = "Uniform", vs_dr24 = "Replace", vs_dr25 = "Off",
 vs_dr26 = "None", vs_dr27 = "Linear", vs_dr28 = "Random", vs_dr29 = "Adaptive", vs_dr30 = "None",
 vs_dr31 = "Off", vs_dr32 = "Uniform", vs_dr33 = "Replace", vs_dr34 = "Instant", vs_dr35 = "None",
 vs_dr36 = "Random", vs_dr37 = "Scatter", vs_dr38 = "Adaptive", vs_dr39 = "Linear", vs_dr40 = "Off",
 vs_tg1 = false, vs_tg2 = false, vs_tg3 = false, vs_tg4 = false, vs_tg5 = false,
 vs_tg6 = false, vs_tg7 = false, vs_tg8 = false, vs_tg9 = false, vs_tg10 = false,
 vs_tg11 = false, vs_tg12 = false, vs_tg13 = false, vs_tg14 = false, vs_tg15 = false,
 vs_tg16 = false, vs_tg17 = false, vs_tg18 = false, vs_tg19 = false, vs_tg20 = false,
 vs_tg21 = false, vs_tg22 = false, vs_tg23 = false, vs_tg24 = false, vs_tg25 = false,
 vs_tg26 = false, vs_tg27 = false, vs_tg28 = false, vs_tg29 = false, vs_tg30 = false,
 vs_tg31 = false, vs_tg32 = false, vs_tg33 = false, vs_tg34 = false, vs_tg35 = false,
 vs_tg36 = false, vs_tg37 = false, vs_tg38 = false, vs_tg39 = false, vs_tg40 = false,
 vs_tg41 = false, vs_tg42 = false, vs_tg43 = false, vs_tg44 = false, vs_tg45 = false,
 vs_tg46 = false, vs_tg47 = false, vs_tg48 = false, vs_tg49 = false, vs_tg50 = false,
 vs_tg51 = false, vs_tg52 = false, vs_tg53 = false, vs_tg54 = false, vs_tg55 = false,
 vs_tg56 = false, vs_tg57 = false, vs_tg58 = false, vs_tg59 = false, vs_tg60 = false,
 vs_tg61 = false, vs_tg62 = false, vs_tg63 = false, vs_tg64 = false, vs_tg65 = false,
 vs_tg66 = false, vs_tg67 = false, vs_tg68 = false, vs_tg69 = false, vs_tg70 = false,
 vs_sl41 = 0, vs_sl42 = 10, vs_sl43 = 0, vs_sl44 = 0, vs_sl45 = 10,
 vs_sl46 = 0, vs_sl47 = 0, vs_sl48 = 10, vs_sl49 = 0, vs_sl50 = 10,
 vs_sl51 = 0, vs_sl52 = 10, vs_sl53 = 0, vs_sl54 = 10, vs_sl55 = 0,
 vs_sl56 = 10, vs_sl57 = 0, vs_sl58 = 10, vs_sl59 = 0, vs_sl60 = 10,
 vs_sl61 = 0, vs_sl62 = 10, vs_sl63 = 0, vs_sl64 = 10, vs_sl65 = 0,
 vs_sl66 = 10, vs_sl67 = 0, vs_sl68 = 10, vs_sl69 = 0, vs_sl70 = 10,
 vs_dr41 = "None", vs_dr42 = "None", vs_dr43 = "Rigid", vs_dr44 = "None", vs_dr45 = "Wrap",
 vs_dr46 = "None", vs_dr47 = "Ignore", vs_dr48 = "None", vs_dr49 = "None", vs_dr50 = "On Entry",
 vs_dr51 = "None", vs_dr52 = "Linear", vs_dr53 = "Random", vs_dr54 = "None", vs_dr55 = "Off",
 vs_dr56 = "Uniform", vs_dr57 = "None", vs_dr58 = "Replace", vs_dr59 = "None", vs_dr60 = "Instant",
 vs_dr61 = "None", vs_dr62 = "Linear", vs_dr63 = "None", vs_dr64 = "Adaptive", vs_dr65 = "None",
 vs_dr66 = "Off", vs_dr67 = "None", vs_dr68 = "Random", vs_dr69 = "None", vs_dr70 = "Replace",
 evs_iter_rad_directional = false,
 vs_cust_drop1 = "Scatter",
 vs_cust_drop2 = "Random",
 vs_cust_drop3 = "None",
 vs_cust_drop4 = "Linear",
 vs_cust_drop5 = "Off",
 vs_cust_drop6 = "Uniform",
 vs_cust_drop7 = "Replace",
 vs_cust_drop8 = "Adaptive",
 vs_cust_drop9 = "Instant",
 vs_cust_drop10 = "None",
 vs_cust_sl1 = 10,
 vs_cust_sl2 = 10,
 vs_cust_sl3 = 10,
 vs_cust_sl4 = 10,
 vs_cust_sl5 = 10,
 vs_cust_sl6 = 10,
 vs_cust_sl7 = 10,
 vs_cust_sl8 = 10,
 vs_cust_sl9 = 10,
 vs_cust_sl10 = 10,
 vs_cust_tog1 = false,
 vs_cust_tog2 = false,
 vs_cust_tog3 = false,
 vs_cust_tog4 = false,
 vs_cust_tog5 = false,
 vs_cust_tog6 = false,
 vs_cust_tog7 = false,
 vs_cust_tog8 = false,
 vs_cust_tog9 = false,
 vs_cust_tog10 = false,

 vs_scatter_layers = 1,
 vs_depth_clamp = 0,
 vs_burst_mode = "Random",
 vs_axis_bias = "None",
 vs_falloff_mode = "None",
 vs_velocity_inherit = false,
 vs_phase_invert = false,
 vs_clamp_enabled = false,
 vs_layer_stagger = 0,
 vs_intensity = 50,
 vs_spread_bias = 0,
 evs_extra_drop1 = "Linear",
 evs_extra_drop2 = "Random",
 evs_extra_tog1 = false,
 evs_extra_tog2 = false,
 evs_extra_sl1 = 10,
 evs_extra_sl2 = 10,
 randomizer_seed = "",
 randomizer_mode1 = "Random",
 randomizer_mode2 = "Uniform",
 randomizer_active = false,
 evs_sync_mode = "Instant",
 evs_burst_falloff = "None",
 evs_chaos_axis = "All",
 evs_sync_strength = 50,
 evs_chaos_blend = 0,
 evs_burst_radius_scale = 1,
 evs_chaos_sync = false,
 evs_burst_lock = false,
 evs_depth_override = false,
 rapid_fire_enabled = false,

 gun_bypass_enabled = false,
 gun_bypass_method = 1,
 autoshoot_enabled = false,
 bullet_redirect_enabled = false,
 void_spam_enabled = false,
 vst_auto_kill = false,
 vs_motion_spread = 50000,
 vs_motion_hjitter = 0,
 vs_motion_vjitter = 0,
 vs_motion_pulse = false,
 vs_motion_pattern = "Broken Spiral",
 vs_warp_multiplier = 1,
 vs_scatter_radius = 500000,
 vs_depth_mult = 1,
 vs_rebound_strength = 0,
 vs_axis_spin = 0,
 vs_frequency_mod = 1,
 vs_position_noise = 0,
 vs_burst_gap = 0,
 vs_entropy_mod = 0,
 vs_gravity_strength = 0,
 orbit_enabled = false,
 orbit_radius = 50000,
 orbit_speed = 5,
 orbit_height = 0,
 orbit_iters = 100,
 orbit_jitter = 0,
 orbit_pattern = "Circle",
 orbit_target = "Closest",
 orbit_axis = "Y",
 orbit_direction = "Clockwise",
 orbit_warp_mode = "Instant",
 orbit_warp_strength = 50,
 orbit_falloff = "None",
 orbit_phase_offset = 0,
 orbit_layer_count = 1,
 orbit_layer_offset = 0,
 orbit_wave_freq = 1,
 orbit_tightness = 10,
 orbit_kill_velocity = true,

 orbit_chaos_blend = 0,
 orbit_invert_x = false,
 orbit_invert_z = false,
 orbit_y_bias = 0,
 orbit_depth_floor = 0,
 vs_turbulence_freq = 1,
 vs_turbulence_amp = 1,
 vs_vortex_strength = 0,
 vs_vortex_radius = 10000,
 vs_layer_twist = 0,
 vs_quantum_jump_prob = 0,
 vs_quantum_jump_scale = 1,
 vs_fractal_depth = 1,
 vs_fractal_scale = 1,
 vs_echo_trail = 0,
 vs_echo_decay_rate = 0.5,
 vs_gravity_vector_x = 0,
 vs_gravity_vector_y = -1,
 vs_gravity_vector_z = 0,
 vs_scatter_seed_mode = "Random",
 vs_depth_pulse_freq = 1,
 vs_depth_pulse_amp = 0,
 vs_spiral_offset_x = 0,
 vs_spiral_offset_z = 0,
 vs_node_gravity = false,
 vs_flux_reversal = false,
 vs_axis_wobble = 0,
 vs_chaos_feedback = false,
 vs_void_gate_mode = "Instant",
 godmode_enabled = false,
 godmode_y_range = 10,
 anti_aim_enabled = false,
 anti_aim_spin_speed = 1e85,
 anti_aim_pitch = 0,
 anti_aim_roll = 0,
 anti_aim_jitter = 0,
 sounds_enabled = false,
 sounds_toggle_sound = "rbxassetid://9120386954",
 fly_enabled = false,
 fly_speed = 60,
 fly_noclip = false,
 fly_gravity_cancel = true,
 bm_enabled = false,
 bm_pitch = 90,
 bm_yaw = 90,
 bm_randomangle = false,
 bm_minangle = 30,
 bm_maxangle = 60,
anti_aim_angle = "Down",
anti_aim_method = "Pixelation",
anti_aim_custom_angle = 0,
evasion_enabled = false,
kicia_counter_enabled = false, kicia_counter_method = 2, kicia_counter_speed = 1,
underground_enabled = false,
voidspam_enabled = false,
voidspam_rate = 0,
vst_attack_target_name = "",
counter_sleepyhub_enabled = false,
ragebot_bypass_enabled = false,
ragebot_bypass_x = 10000000000000,
ragebot_bypass_z = 10000000000000,
ragebot_bypass_coord_list = {},
ragebot_bypass_coord_index = 1,
perfect_accuracy_enabled = false,
nebula_counter_enabled = false,
 csh_under_offset = 6,
 csh_autoshoot_enabled = false,
 csh_rapid_fire_enabled = false,
patience_enabled = false,
blip_dodge_enabled = false, blip_dodge_rate = 0.1,
cframe_noise_enabled = false, cframe_noise_amount = 0.5,
hitbox_offset_enabled = false, hitbox_offset_intensity = 0,

perfect_block_enabled = false,
smart_riot_enabled = false,
riot_abuser_enabled = false,
riot_abuser_spin_speed = 720,
riot_abuser_iterate_rate = 0.016,
riot_abuser_iterate_radius = 50,
riot_abuser_pitch = 0,
riot_bypass_enabled = false,
riot_bypass_distance = 10,
riot_bypass_height = 0,
riot_bypass_update_rate = 0.5,
ragebot_bypass_frequency = 1000,
ragebot_bypass_offset_distance = 10000000000000,
ragebot_bypass_y_offset = 10000000000000,
ragebot_bypass_fake_layers = 10,
anti_afk_enabled = false,
auto_collect = false,
collect_radius = 120,
safe_zone_rescue = false,
depth_threshold = -10,
return_home = false,
return_delay = 1.0,
teleport_loop_enabled = false,
loop_delay = 0.5,
ffa_server_hopping = false,

knife_bypass_enabled = false,
}

getgenv().all_connections = {}

local config = getgenv().config
local configs_folder = "meowlua private/configs"
if not isfolder("meowlua private") then makefolder("meowlua private") end
if not isfolder("meowlua private/configs") then makefolder("meowlua private/configs") end
if not isfolder("meowlua private/themes") then makefolder("meowlua private/themes") end

local function notify(title, content)
 pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", { Title=title, Text=content, Duration=3 }) end)

end

getgenv().get_hrp = function(plr)
 local p = plr or localplayer
 if not p.Character then return nil end
 return p.Character:FindFirstChild("HumanoidRootPart")

end

local last_target_tick = 0
local cached_target = nil

getgenv().get_closest = function(check_ff)
 local now = tick()
 if now - last_target_tick < 0.1 then
 if cached_target and cached_target.Character then
 local ct_hrp = cached_target.Character:FindFirstChild("HumanoidRootPart")
 local ct_hum = cached_target.Character:FindFirstChild("Humanoid")
 if ct_hrp and ct_hum and ct_hum.Health > 0 then
 if not check_ff or not cached_target.Character:FindFirstChildOfClass("ForceField") then
 return cached_target
 end
 end
 end
 end
 last_target_tick = now
 local closest, min_d = nil, math.huge
 local hrp = getgenv().get_hrp(localplayer)
 if not hrp then return nil end
 for _, p in ipairs(players:GetPlayers()) do
 if p ~= localplayer and p.Character then
 if not (check_ff and p.Character:FindFirstChildOfClass("ForceField")) then
 local t_hrp = p.Character:FindFirstChild("HumanoidRootPart")
 local hum = p.Character:FindFirstChild("Humanoid")
 if t_hrp and hum and hum.Health > 0 then
 if localplayer.Team == nil or p.Team == nil or localplayer.Team ~= p.Team then
 local d = (hrp.Position - t_hrp.Position).Magnitude
 local sr = config.search_radius or 999e15
 if d < min_d and d <= sr then min_d = d; closest = p end
 end
 end
 end
 end
 end
 cached_target = closest
 return closest

end

do
local _sb_active = false
local _sb_sling_conn = nil
local _sb_child_added_conn = nil
local _sb_child_removed_conn = nil

local _sb_projectiles = {}
local _sb_void_pos = CFrame.new(9000, 9000, 9000)

getgenv().start_slingshot_bypass = function()
	if _sb_active then return end
	_sb_active = true
	config.slingshot_bypass = true
	_sb_child_added_conn = workspace.ChildAdded:Connect(function(o)
		if not o:IsA("BasePart") then return end
		if o.Name == "CoreProjectile" then
			_sb_projectiles[o] = true
		elseif o.Name == "Part" then
			task.defer(function()
				if o and o.Parent and o.AssemblyLinearVelocity.Magnitude > 50 then
					_sb_projectiles[o] = true
				end
			end)
		end
	end)
	_sb_child_removed_conn = workspace.ChildRemoved:Connect(function(o)
		_sb_projectiles[o] = nil
	end)
	local _sb_hb_last = 0
	_sb_sling_conn = run_service.Heartbeat:Connect(function()
		local now = tick()
		if now - _sb_hb_last < 0.033 then return end
		_sb_hb_last = now
		pcall(function()
			for _, p in pairs(players:GetPlayers()) do
				if p ~= localplayer and p.Character then
					local h = p.Character:FindFirstChild("HumanoidRootPart")
					if h then
						h.CFrame = _sb_void_pos
						h.AssemblyLinearVelocity = Vector3.zero
					end
				end
			end
			for p in pairs(_sb_projectiles) do
				if p and p.Parent then
					p.CFrame = _sb_void_pos
					p.AssemblyLinearVelocity = Vector3.zero
				else
					_sb_projectiles[p] = nil
				end
			end
		end)
	end)

end

getgenv().stop_slingshot_bypass = function()
	_sb_active = false
	config.slingshot_bypass = false
	if _sb_sling_conn then _sb_sling_conn:Disconnect(); _sb_sling_conn = nil end
	if _sb_child_added_conn then _sb_child_added_conn:Disconnect(); _sb_child_added_conn = nil end
	if _sb_child_removed_conn then _sb_child_removed_conn:Disconnect(); _sb_child_removed_conn = nil end
	_sb_projectiles = {}

end

local _orb_active = false
local _orb_conn = nil
local _orb_angle = 0

getgenv().start_slingshot_orbit = function()
	if _orb_active then return end
	_orb_active = true
	config.slingshot_orbit = true
	_movement_save_pos()
	local _orb_hb_last = 0
	_orb_conn = run_service.Heartbeat:Connect(function(dt)
		if not config.slingshot_orbit then return end
		local _orb_now = tick()
		if _orb_now - _orb_hb_last < 0.016 then return end
		_orb_hb_last = _orb_now
		local target = nil
		local min_dist = math.huge
		local my_hrp = getgenv().get_hrp(localplayer)
		if not my_hrp then return end
		for _, p in pairs(players:GetPlayers()) do
			if p ~= localplayer and p.Character then
				local hrp = p.Character:FindFirstChild("HumanoidRootPart")
				local hum = p.Character:FindFirstChild("Humanoid")
				if hrp and hum and hum.Health > 0 then
					if localplayer.Team == nil or p.Team == nil or localplayer.Team ~= p.Team then
						local d = (my_hrp.Position - hrp.Position).Magnitude
						if d < min_dist then
							min_dist = d
							target = hrp
						end
					end
				end
			end
		end
		if not target then return end
		local radius = config.slingshot_orbit_radius or 6
		local speed  = math.rad(config.slingshot_orbit_speed or 180)
		_orb_angle = _orb_angle + speed * dt
		local target_pos = target.Position
		local orbit_offset = Vector3.new(
			math.cos(_orb_angle) * radius,
			0,
			math.sin(_orb_angle) * radius
		)
		local orbit_pos = target_pos + orbit_offset
		my_hrp.CFrame = CFrame.new(orbit_pos, target_pos)
	end)

end

getgenv().stop_slingshot_orbit = function()
	_orb_active = false
	config.slingshot_orbit = false
	if _orb_conn then _orb_conn:Disconnect(); _orb_conn = nil end
	_orb_angle = 0
	_movement_restore_pos()
end

local melee_conn = nil
local godmode_active = false

local godmode_fake_cf_store = {}
local GODMODE_FAKE_OFFSET = Vector3.new(900000, 900000, 900000)

local function melee_in_y_range(my_hrp, target_hrp)
 local range = config.godmode_activation_range or 10
 local y_diff = my_hrp.Position.Y - target_hrp.Position.Y
 return y_diff >= 0 and y_diff <= range

end

getgenv().start_godmode = function()
 if godmode_active then return end
 godmode_active = true
 config.godmode = true
 local function apply_melee_fake(h)
  tt_write(h, CFrame.new(GODMODE_FAKE_OFFSET))
 end
 local gm_last = 0
 melee_conn = run_service.Heartbeat:Connect(function()
  if not config.godmode then return end
  local now = tick()
  if now - gm_last < 0.05 then return end
  gm_last = now
  local my_hrp = getgenv().get_hrp(localplayer)
  if not my_hrp then return end
  pcall(function()
   for _, p in pairs(players:GetPlayers()) do
    if p ~= localplayer and p.Character then
     local h = p.Character:FindFirstChild("HumanoidRootPart")
     if h then
      if melee_in_y_range(my_hrp, h) then
       godmode_fake_cf_store[p] = h.CFrame
       apply_melee_fake(h)
      else
       godmode_fake_cf_store[p] = nil
      end
     end
    end
   end
  end)
 end)

end

getgenv().stop_godmode = function()
 godmode_active = false
 config.godmode = false
 if melee_conn then melee_conn:Disconnect(); melee_conn = nil end
 godmode_fake_cf_store = {}

end

end

local anti_aim_conn = nil
local anti_aim_active = false
local aa_spin_angle = 0

local aa_hook_rotFn = nil
local aa_hook_orig = nil
local aa_hook_camTable = nil
local aa_render_conn = nil

local function aa_compute_server_cf(client_cf)
    local mode = config.anti_aim_mode or "Spin"
    local spin_speed = math.max(config.anti_aim_spin_speed or 720, 1)
    local pitch_deg = config.anti_aim_pitch_deg or 89
    local jitter_deg = config.anti_aim_jitter_deg or 0
    local pos = client_cf.Position
    local rx, ry, rz = client_cf:ToOrientation()
    if mode == "Spin" then
        aa_spin_angle = (aa_spin_angle + spin_speed * 0.016) % 360
        local yaw = math.rad(aa_spin_angle)
        local pitch = math.rad(pitch_deg + (jitter_deg > 0 and (math.random() - 0.5) * 2 * jitter_deg or 0))
        return CFrame.new(pos) * CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch, 0, 0)
    elseif mode == "Static" then
        local pitch = math.rad(pitch_deg + (jitter_deg > 0 and (math.random() - 0.5) * 2 * jitter_deg or 0))
        return CFrame.new(pos) * CFrame.Angles(pitch, 0, 0)
    elseif mode == "Jitter" then
        local yaw = math.rad(math.random(0, 360))
        local pitch = math.rad(pitch_deg + (math.random() - 0.5) * 2 * math.max(jitter_deg, 45))
        return CFrame.new(pos) * CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch, 0, 0)
    elseif mode == "Desync" then
        aa_spin_angle = (aa_spin_angle + spin_speed * 0.016) % 360
        local flipped = (math.floor(aa_spin_angle / 45) % 2 == 0) and 1 or -1
        local yaw = math.rad(aa_spin_angle * flipped)
        local pitch = math.rad(pitch_deg * flipped + (jitter_deg > 0 and (math.random() - 0.5) * 2 * jitter_deg or 0))
        return CFrame.new(pos) * CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch, 0, 0)
    elseif mode == "Flat" then
        local yaw = math.rad(math.random(0, 360))
        return CFrame.new(pos) * CFrame.Angles(0, yaw, 0)
    elseif mode == "Backward" then
        local pitch = math.rad(pitch_deg + (jitter_deg > 0 and (math.random() - 0.5) * 2 * jitter_deg or 0))
        return CFrame.new(pos) * CFrame.Angles(0, ry + math.pi, 0) * CFrame.Angles(pitch, 0, 0)
    elseif mode == "Freestanding" then
        local nearest = nil
        local best_d = math.huge
        for _, p in ipairs(players:GetPlayers()) do
            if p ~= localplayer and p.Character then
                local t_hrp = p.Character:FindFirstChild("HumanoidRootPart")
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if t_hrp and hum and hum.Health > 0 then
                    local d = (pos - t_hrp.Position).Magnitude
                    if d < best_d then best_d = d; nearest = t_hrp end
                end
            end
        end
        if nearest then
            local to_enemy = (nearest.Position - pos)
            local free_yaw = math.atan2(to_enemy.X, to_enemy.Z) + math.pi * 0.5
            local pitch = math.rad(pitch_deg + (jitter_deg > 0 and (math.random() - 0.5) * 2 * jitter_deg or 0))
            return CFrame.new(pos) * CFrame.Angles(0, free_yaw, 0) * CFrame.Angles(pitch, 0, 0)
        end
        return CFrame.new(pos) * CFrame.Angles(0, ry, 0)
    elseif mode == "LowerBody" then
        aa_spin_angle = (aa_spin_angle + spin_speed * 0.016) % 360
        local yaw_server = math.rad(aa_spin_angle)
        return CFrame.new(pos) * CFrame.Angles(0, yaw_server, 0)
    elseif mode == "PitchDown" then
        local yaw = math.rad(math.random(0, 360))
        return CFrame.new(pos) * CFrame.Angles(0, yaw, 0) * CFrame.Angles(math.rad(89), 0, 0)
    elseif mode == "PitchUp" then
        local yaw = math.rad(math.random(0, 360))
        return CFrame.new(pos) * CFrame.Angles(0, yaw, 0) * CFrame.Angles(math.rad(-89), 0, 0)
    elseif mode == "SpinPitch" then
        aa_spin_angle = (aa_spin_angle + spin_speed * 0.016) % 360
        local yaw = math.rad(aa_spin_angle)
        local pitch_cycle = math.sin(math.rad(aa_spin_angle * 3)) * math.rad(pitch_deg)
        return CFrame.new(pos) * CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch_cycle, 0, 0)
    elseif mode == "Random" then
        local rroll = math.rad(math.random(0, 360))
        local rpitch = math.rad(math.random(-89, 89))
        local ryaw = math.rad(math.random(0, 360))
        return CFrame.new(pos) * CFrame.Angles(rpitch, ryaw, rroll)
    end
    return client_cf
end

local function aa_apply_hook()
    if not config.anti_aim then return end
    if not aa_hook_camTable then return end
    local char = localplayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local client_cf = hrp.CFrame
    local server_cf = aa_compute_server_cf(client_cf)
    local rx, ry, rz = server_cf:ToOrientation()
    aa_hook_camTable.Rotation = Vector2.new(math.deg(-rx), ry)
    local V0 = Vector3.zero
    local mt_aa = getrawmetatable(hrp)
    local ni_aa = mt_aa and rawget(mt_aa, "__newindex")
    if ni_aa then
        pcall(ni_aa, hrp, "AssemblyLinearVelocity", V0)
        pcall(ni_aa, hrp, "AssemblyAngularVelocity", V0)
        pcall(ni_aa, hrp, "CFrame", server_cf)
        pcall(ni_aa, hrp, "AssemblyLinearVelocity", V0)
    else
        pcall(function()
            hrp.AssemblyLinearVelocity = V0
            hrp.AssemblyAngularVelocity = V0
            hrp.CFrame = server_cf
            hrp.AssemblyLinearVelocity = V0
        end)
    end
    if sethiddenproperty then
        pcall(sethiddenproperty, hrp, "CFrame", server_cf)
        pcall(sethiddenproperty, hrp, "AssemblyLinearVelocity", V0)
    end
end

getgenv().start_body_manip = function()
    if anti_aim_active then return end
    anti_aim_active = true
    config.anti_aim = true
    aa_spin_angle = 0
    pcall(function() run_service:UnbindFromRenderStep("__aa_mrot") end)
    pcall(function()
        if aa_hook_orig and aa_hook_rotFn then
            pcall(function() hookfunction(aa_hook_rotFn, aa_hook_orig) end)
            aa_hook_orig = nil
        end
        aa_hook_rotFn = nil
        aa_hook_camTable = nil
        aa_hook_rotFn = filtergc("function", {Name = "_UpdateCharacterRotation"}, true)
        if not aa_hook_rotFn then return end
        for _, v in ipairs(debug.getupvalues(aa_hook_rotFn)) do
            if type(v) == "table" and typeof(v.Rotation) == "Vector2" then
                aa_hook_camTable = v
                break
            end
        end
        if not aa_hook_camTable then return end
        pcall(function()
            run_service:BindToRenderStep("__aa_mrot", Enum.RenderPriority.Character.Value - 1, aa_apply_hook)
        end)
        local aa_snap
        aa_snap = hookfunction(aa_hook_rotFn, function(...)
            aa_apply_hook()
            return aa_snap(...)
        end)
        aa_hook_orig = aa_snap
    end)
    local aa_last = 0
    anti_aim_conn = run_service.Heartbeat:Connect(function()
        if not config.anti_aim then return end
        local now = tick()
        if now - aa_last < 0.016 then return end
        aa_last = now
        aa_apply_hook()
    end)
end

getgenv().stop_body_manip = function()
    anti_aim_active = false
    config.anti_aim = false
    pcall(function() run_service:UnbindFromRenderStep("__aa_mrot") end)
    if anti_aim_conn then anti_aim_conn:Disconnect(); anti_aim_conn = nil end
    if aa_render_conn then aa_render_conn:Disconnect(); aa_render_conn = nil end
    if aa_hook_orig and aa_hook_rotFn then
        pcall(function() hookfunction(aa_hook_rotFn, aa_hook_orig) end)
        aa_hook_orig = nil
    end
    aa_hook_rotFn = nil
    aa_hook_camTable = nil
    aa_spin_angle = 0
end

getgenv().stop_anti_aim = getgenv().stop_body_manip
local vs_motion_step = 0

local fake_pos_conn = nil
local fake_pos_render_conn = nil
local fake_pos_realCF = nil
local fake_pos_spiral_angle = 0
local fake_pos_linear_t = 0
local fake_pos_last_packet_t = 0

local _ragebot_ctrl_ref = nil
local _ragebot_rb_ref = nil

local _dsync_pos_history = {}
local _dsync_pos_history_max = 8
local _dsync_last_known_cf = nil
local _dsync_last_update_t = 0

local function _dsync_read_true_cf(hrp)
 if not hrp then return nil end
 local cf
 pcall(function()
  local mt = getrawmetatable(hrp)
  local ri = mt and rawget(mt, "__index")
  if ri then cf = ri(hrp, "CFrame") end
 end)
 if cf then return cf end
 pcall(function()
  if gethiddenproperty then
   local v = gethiddenproperty(hrp, "CFrame")
   if v then cf = v end
  end
 end)
 if cf then return cf end
 pcall(function()
  if ficlone then
   local cl = ficlone(hrp)
   if cl then cf = cl.CFrame end
  end
 end)
 if cf then return cf end
 local ok, raw = pcall(function() return hrp.CFrame end)
 if ok and raw then return raw end
 return nil
end

local function _dsync_record_pos(cf)
 if not cf then return end
 local t = tick()
 table.insert(_dsync_pos_history, { cf = cf, t = t })
 if #_dsync_pos_history > _dsync_pos_history_max then
  table.remove(_dsync_pos_history, 1)
 end
 _dsync_last_known_cf = cf
 _dsync_last_update_t = t
end

local function _dsync_get_best_cf(hrp)
 local true_cf = _dsync_read_true_cf(hrp)
 if true_cf then
  _dsync_record_pos(true_cf)
  return true_cf
 end
 if _dsync_last_known_cf and (tick() - _dsync_last_update_t) < 0.5 then
  return _dsync_last_known_cf
 end
 return nil
end

local function _dsync_predict_cf(hrp, dt)
 dt = dt or 0
 local cf = _dsync_get_best_cf(hrp)
 if not cf then return nil end
 if #_dsync_pos_history >= 2 then
  local newest = _dsync_pos_history[#_dsync_pos_history]
  local prev = _dsync_pos_history[#_dsync_pos_history - 1]
  local elapsed = newest.t - prev.t
  if elapsed > 0 then
   local vel = (newest.cf.Position - prev.cf.Position) / elapsed
   local predicted = newest.cf.Position + vel * dt
   return CFrame.new(predicted) * (cf - cf.Position)
  end
 end
 return cf
end

getgenv().dsync_get_true_cf = _dsync_get_best_cf
getgenv().dsync_predict_cf = _dsync_predict_cf
getgenv().dsync_record_pos = _dsync_record_pos

local anti_translocation_conn = nil
local anti_translocation_active = false

getgenv().start_anti_translocation = function()
 if anti_translocation_active then return end
 anti_translocation_active = true
 config.anti_translocation = true
 if anti_translocation_conn then anti_translocation_conn:Disconnect() end
 local at_last = 0
 anti_translocation_conn = run_service.Heartbeat:Connect(function()
  if not config.anti_translocation then return end
  local now = tick()
  if now - at_last < 0.1 then return end
  at_last = now
  local hrp = getgenv().get_hrp(localplayer)
  if not hrp then return end
  local hum = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")
  if not hum or hum.Health <= 0 then return end
  local my_pos = hrp.Position
  for _, p in ipairs(players:GetPlayers()) do
   if p ~= localplayer and p.Character then
    local t_hrp = p.Character:FindFirstChild("HumanoidRootPart")
    local t_hum = p.Character:FindFirstChildOfClass("Humanoid")
    local no_ff = not p.Character:FindFirstChildOfClass("ForceField")
    local diff_team = localplayer.Team == nil or p.Team == nil or localplayer.Team ~= p.Team
    if t_hrp and t_hum and t_hum.Health > 0 and no_ff and diff_team then
     local dist = (my_pos - t_hrp.Position).Magnitude
     if dist <= 100000 then
      local dest = CFrame.new(my_pos.X + 100000000, my_pos.Y, my_pos.Z + 100000000)
      local V0 = Vector3.zero
      pcall(function()
       hrp.AssemblyLinearVelocity = V0
       hrp.AssemblyAngularVelocity = V0
       hrp.CFrame = dest
       hrp.AssemblyLinearVelocity = V0
       hrp.AssemblyAngularVelocity = V0
      end)
      pcall(function()
       local mt = getrawmetatable(hrp)
       if not mt then return end
       local ni = rawget(mt, "__newindex")
       if not ni then return end
       ni(hrp, "AssemblyLinearVelocity", V0)
       ni(hrp, "AssemblyAngularVelocity", V0)
       ni(hrp, "CFrame", dest)
       ni(hrp, "AssemblyLinearVelocity", V0)
       ni(hrp, "AssemblyAngularVelocity", V0)
      end)
      if sethiddenproperty then
       pcall(sethiddenproperty, hrp, "AssemblyLinearVelocity", V0)
       pcall(sethiddenproperty, hrp, "AssemblyAngularVelocity", V0)
       pcall(sethiddenproperty, hrp, "CFrame", dest)
       pcall(sethiddenproperty, hrp, "AssemblyLinearVelocity", V0)
      end
      pcall(function()
       game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Anti Translocation";
        Text = "Dodged A Target";
        Duration = 3;
       })
      end)
      break
     end
    end
   end
  end
 end)
end

getgenv().stop_anti_translocation = function()
 anti_translocation_active = false
 config.anti_translocation = false
 if anti_translocation_conn then anti_translocation_conn:Disconnect(); anti_translocation_conn = nil end
end

local anti_tp_conn = nil
local anti_tp_active = false
local _atp_last_positions = {}

getgenv().start_anti_teleportation = function()
 if anti_tp_active then return end
 anti_tp_active = true
 config.anti_teleportation = true
 _atp_last_positions = {}
 if anti_tp_conn then anti_tp_conn:Disconnect() end
 local atp_last = 0
 anti_tp_conn = run_service.Heartbeat:Connect(function()
  if not config.anti_teleportation then return end
  local now = tick()
  if now - atp_last < 0.05 then return end
  atp_last = now
  local hrp = getgenv().get_hrp(localplayer)
  if not hrp then return end
  local hum = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")
  if not hum or hum.Health <= 0 then return end
  local my_pos = hrp.Position
  local threshold = config.anti_tp_threshold or 2000
  local escape_dist = config.anti_tp_escape_dist or 100000000
  for _, p in ipairs(players:GetPlayers()) do
   if p ~= localplayer and p.Character then
    local t_hrp = p.Character:FindFirstChild("HumanoidRootPart")
    local t_hum = p.Character:FindFirstChildOfClass("Humanoid")
    local no_ff = not p.Character:FindFirstChildOfClass("ForceField")
    local diff_team = localplayer.Team == nil or p.Team == nil or localplayer.Team ~= p.Team
    if t_hrp and t_hum and t_hum.Health > 0 and no_ff and diff_team then
     local prev = _atp_last_positions[p]
     local cur = t_hrp.Position
     if prev then
      local jump = (cur - prev).Magnitude
      local dist_to_me = (my_pos - cur).Magnitude
      if jump > threshold and dist_to_me < threshold then
       local V0 = Vector3.zero
       local angle = math.random() * 2 * math.pi
       local dest = CFrame.new(my_pos.X + math.cos(angle) * escape_dist, my_pos.Y, my_pos.Z + math.sin(angle) * escape_dist)
       pcall(function()
        hrp.AssemblyLinearVelocity = V0
        hrp.AssemblyAngularVelocity = V0
        hrp.CFrame = dest
        hrp.AssemblyLinearVelocity = V0
        hrp.AssemblyAngularVelocity = V0
       end)
       pcall(function()
        local mt = getrawmetatable(hrp)
        if not mt then return end
        local ni = rawget(mt, "__newindex")
        if not ni then return end
        ni(hrp, "AssemblyLinearVelocity", V0)
        ni(hrp, "AssemblyAngularVelocity", V0)
        ni(hrp, "CFrame", dest)
        ni(hrp, "AssemblyLinearVelocity", V0)
        ni(hrp, "AssemblyAngularVelocity", V0)
       end)
       if sethiddenproperty then
        pcall(sethiddenproperty, hrp, "AssemblyLinearVelocity", V0)
        pcall(sethiddenproperty, hrp, "AssemblyAngularVelocity", V0)
        pcall(sethiddenproperty, hrp, "CFrame", dest)
        pcall(sethiddenproperty, hrp, "AssemblyLinearVelocity", V0)
       end
       pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
         Title = "Anti Teleportation";
         Text = "Evaded teleport from " .. p.Name;
         Duration = 3;
        })
       end)
       break
      end
     end
     _atp_last_positions[p] = cur
    end
   end
  end
 end)
end

getgenv().stop_anti_teleportation = function()
 anti_tp_active = false
 config.anti_teleportation = false
 if anti_tp_conn then anti_tp_conn:Disconnect(); anti_tp_conn = nil end
 _atp_last_positions = {}
end

local ragebot_sync_conn = nil
local ragebot_sync_active = false

local _dsync_pos_sample_conn = nil
local _dsync_pos_sample_last = 0

local function _dsync_start_pos_sampler()
 if _dsync_pos_sample_conn then return end
 _dsync_pos_sample_conn = run_service.Heartbeat:Connect(function()
  local now = tick()
  if now - _dsync_pos_sample_last < 0.05 then return end
  _dsync_pos_sample_last = now
  local hrp = getgenv().get_hrp(localplayer)
  if not hrp then return end
  local cf = _dsync_read_true_cf(hrp)
  if cf then _dsync_record_pos(cf) end
 end)
end

local function _dsync_stop_pos_sampler()
 if _dsync_pos_sample_conn then
  _dsync_pos_sample_conn:Disconnect()
  _dsync_pos_sample_conn = nil
 end
end

local function _dsync_apply_cf(hrp, target_cf)
 if not hrp or not target_cf then return end
 local mt = getrawmetatable(hrp)
 local ni = mt and rawget(mt, "__newindex")
 if ni then
  pcall(ni, hrp, "AssemblyLinearVelocity", Vector3.zero)
  pcall(ni, hrp, "AssemblyAngularVelocity", Vector3.zero)
  pcall(ni, hrp, "CFrame", target_cf)
  pcall(ni, hrp, "AssemblyLinearVelocity", Vector3.zero)
 else
  pcall(function()
   hrp.AssemblyLinearVelocity = Vector3.zero
   hrp.AssemblyAngularVelocity = Vector3.zero
   hrp.CFrame = target_cf
   hrp.AssemblyLinearVelocity = Vector3.zero
  end)
 end
 if sethiddenproperty then
  pcall(sethiddenproperty, hrp, "CFrame", target_cf)
  pcall(sethiddenproperty, hrp, "AssemblyLinearVelocity", Vector3.zero)
  pcall(sethiddenproperty, hrp, "AssemblyAngularVelocity", Vector3.zero)
 end
 _dsync_record_pos(target_cf)
end

getgenv().dsync_apply_cf = _dsync_apply_cf
getgenv().dsync_start_pos_sampler = _dsync_start_pos_sampler
getgenv().dsync_stop_pos_sampler = _dsync_stop_pos_sampler

getgenv().start_ragebot_sync = function()
 if ragebot_sync_active then return end
 ragebot_sync_active = true
 config.teleport_sync_ragebot = true
 _dsync_start_pos_sampler()
 if ragebot_sync_conn then ragebot_sync_conn:Disconnect() end
 local krbs_last = 0
 ragebot_sync_conn = run_service.Heartbeat:Connect(function()
  if not config.teleport_sync_ragebot then return end
  local now = tick()
  if now - krbs_last < 0.1 then return end
  krbs_last = now
  local hrp = getgenv().get_hrp(localplayer)
  if not hrp then return end
  local cf = _dsync_get_best_cf(hrp)
  if cf then _dsync_record_pos(cf) end
 end)
end

getgenv().stop_ragebot_sync = function()
 ragebot_sync_active = false
 config.teleport_sync_ragebot = false
 if ragebot_sync_conn then ragebot_sync_conn:Disconnect(); ragebot_sync_conn = nil end
 _dsync_stop_pos_sampler()
end

local tt_conn = nil
local tt_sample_conn = nil
local tt_locked_target = nil

local tt_live = {}

local tt_track = {}
local TT_HIST = 64

local function tt_nan(v) return v ~= v end

local function tt_inf(v) return math.abs(v) == math.huge end

local function tt_ok(v) return not tt_nan(v) and not tt_inf(v) end

local function tt_ok3(x,y,z) return tt_ok(x) and tt_ok(y) and tt_ok(z) end

local function tt_okv(v) return v and tt_ok3(v.X,v.Y,v.Z) end

local function tt_read(part)
	if not part then return nil end
	local cf
	pcall(function()
		local mt = getrawmetatable(part)
		local ri = mt and rawget(mt,"__index")
		if ri then cf = ri(part,"CFrame") end
	end)
	if cf and tt_okv(cf.Position) then return cf end
	pcall(function() if gethiddenproperty then local v = gethiddenproperty(part,"CFrame"); if v then cf = v end end end)
	if cf and tt_okv(cf.Position) then return cf end
	pcall(function() if ficlone then local cl = ficlone(part); if cl then cf = cl.CFrame end end end)
	if cf and tt_okv(cf.Position) then return cf end
	pcall(function() if getproperties then local p = getproperties(part); if p and p.CFrame then cf = p.CFrame end end end)
	if cf and tt_okv(cf.Position) then return cf end
	local ok,raw = pcall(function() return part.CFrame end)
	if ok and raw and tt_okv(raw.Position) then return raw end
	return nil

end

local function tt_record(part, cf, now)
	local x,y,z = cf.X,cf.Y,cf.Z
	if not tt_ok3(x,y,z) then return end
	local live = tt_live[part]
	if not live then
		tt_live[part] = {
			x=x,y=y,z=z,cf=cf,t=now,
			lkg_x=x,lkg_y=y,lkg_z=z,lkg_t=now,
			vx=0,vy=0,vz=0,
		}
		live = tt_live[part]
	else
		local dt = now - live.t
		if dt > 0.0001 then
			local raw_vx = (x-live.x)/dt
			local raw_vy = (y-live.y)/dt
			local raw_vz = (z-live.z)/dt
			local raw_speed = math.sqrt(raw_vx*raw_vx + raw_vy*raw_vy + raw_vz*raw_vz)
			local a = math.clamp(0.4 + (raw_speed / 5000) * 0.6, 0.4, 1.0)
			live.vx = live.vx*(1-a) + raw_vx*a
			live.vy = live.vy*(1-a) + raw_vy*a
			live.vz = live.vz*(1-a) + raw_vz*a
		end
		live.x,live.y,live.z,live.cf,live.t = x,y,z,cf,now
		live.lkg_x,live.lkg_y,live.lkg_z,live.lkg_t = x,y,z,now
	end
	local entry = tt_track[part]
	if not entry then
		tt_track[part] = {buf={},i=0}
		entry = tt_track[part]
	end
	local i = (entry.i % TT_HIST) + 1
	entry.i = i
	entry.buf[i] = {x=x,y=y,z=z,t=now}

end

local function tt_sample(part)
	local cf = tt_read(part)
	if cf then tt_record(part, cf, tick()) end

end

local function tt_best_pos(part)
	local live = tt_live[part]
	if live then
		if live.lkg_x then
			return Vector3.new(live.lkg_x, live.lkg_y, live.lkg_z)
		end
		return Vector3.new(live.x, live.y, live.z)
	end
	local cf = tt_read(part)
	if cf then return cf.Position end
	return nil

end

local function tt_predicted_pos(part, ping)
	local live = tt_live[part]
	if not live then return tt_best_pos(part) end
	local pos = Vector3.new(live.lkg_x or live.x, live.lkg_y or live.y, live.lkg_z or live.z)
	local vx,vy,vz = live.vx, live.vy, live.vz
	local speed = math.sqrt(vx*vx + vy*vy + vz*vz)
	if speed < 1 then return pos end
	local max_lead = math.clamp(0.016 + (1 - math.min(speed, 50000) / 50000) * (0.3 - 0.016), 0.016, 0.3)
	local t = math.clamp(ping, 0, max_lead)
	local pred = Vector3.new(pos.X + vx*t, pos.Y + vy*t, pos.Z + vz*t)
	if tt_okv(pred) then return pred end
	return pos

end

local function tt_get_ping()
	local ok, stat = pcall(function() return game:GetService("Stats") end)
	if ok and stat then
		local ok2,p = pcall(function() return stat.Network.ServerStatsItem["Data Ping"].Value end)
		if ok2 and type(p) == "number" and tt_ok(p) then
			return math.clamp(p/1000, 0, 0.4)
		end
	end
	return 0.05

end

local function tt_valid_target(p)
	if not p or p == localplayer then return false end
	if not p.Character then return false end
	local hrp = p.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end
	if p.Character:FindFirstChildOfClass("ForceField") then return false end
	if localplayer.Team and p.Team and localplayer.Team == p.Team then return false end
	local hum = p.Character:FindFirstChildOfClass("Humanoid")
	local alive = false
	if hum then pcall(function() alive = hum.Health > 0 end) end
	return alive

end

local function tt_pick_target()
	local mode = config.target_mode or "Closest"
	local prio = config.target_priority
	if prio and prio ~= "" then
		local sp = players:FindFirstChild(prio)
		if sp and tt_valid_target(sp) then
			if config.target_lock then tt_locked_target = sp end
			return sp
		end
	end
	if config.target_lock and tt_locked_target then
		if tt_valid_target(tt_locked_target) then return tt_locked_target end
		tt_locked_target = nil
	end
	local my_hrp = getgenv().get_hrp(localplayer)
	if not my_hrp then return nil end
	local mx,my_y2,mz = my_hrp.Position.X, my_hrp.Position.Y, my_hrp.Position.Z
	local best, bestval = nil, (mode == "Closest") and math.huge or -math.huge
	for _,p in ipairs(players:GetPlayers()) do
		if p ~= localplayer and tt_valid_target(p) then
			local chr = p.Character
			local hrp2 = chr and chr:FindFirstChild("HumanoidRootPart")
			if hrp2 then
				local live = tt_live[hrp2]
				local tx = live and (live.lkg_x or live.x) or hrp2.Position.X
				local ty = live and (live.lkg_y or live.y) or hrp2.Position.Y
				local tz = live and (live.lkg_z or live.z) or hrp2.Position.Z
				local dx,dy,dz = tx-mx, ty-my_y2, tz-mz
				local dsq = dx*dx + dy*dy + dz*dz
				if mode == "Closest" and dsq < bestval then bestval=dsq; best=p
				elseif mode == "Farthest" and dsq > bestval then bestval=dsq; best=p
				elseif mode == "LowestHP" then
					local hum = chr:FindFirstChildOfClass("Humanoid")
					local hp = math.huge
					if hum then pcall(function() hp=hum.Health end) end
					if hp < bestval then bestval=hp; best=p end
				end
			end
		end
	end
	if config.target_lock and best then tt_locked_target = best end
	return best

end

local function tt_nuke()
	pcall(function() workspace.FallenPartsDestroyHeight = -math.huge end)
	pcall(function() workspace.FallenPartsDestroyHeight = 0/0 end)
	pcall(function()
		local mt = getrawmetatable(workspace)
		local ni = mt and rawget(mt,"__newindex")
		if ni then
			ni(workspace,"FallenPartsDestroyHeight",-math.huge)
			pcall(function() ni(workspace,"FallenPartsDestroyHeight",0/0) end)
		end
	end)

end

local _tt_write_ni_cache = nil
local _tt_write_ni_checked = false
local function tt_write(hrp, target_cf)
	local V0 = Vector3.zero
	if not _tt_write_ni_checked then
		local mt = getrawmetatable(hrp)
		_tt_write_ni_cache = mt and rawget(mt, "__newindex")
		_tt_write_ni_checked = true
	end
	local ni = _tt_write_ni_cache
	if ni then
		pcall(ni, hrp, "AssemblyLinearVelocity", V0)
		pcall(ni, hrp, "AssemblyAngularVelocity", V0)
		pcall(ni, hrp, "CFrame", target_cf)
		pcall(ni, hrp, "AssemblyLinearVelocity", V0)
	else
		pcall(function()
			hrp.AssemblyLinearVelocity = V0
			hrp.AssemblyAngularVelocity = V0
			hrp.CFrame = target_cf
			hrp.AssemblyLinearVelocity = V0
		end)
	end
	if sethiddenproperty then
		pcall(sethiddenproperty, hrp, "CFrame", target_cf)
		pcall(sethiddenproperty, hrp, "AssemblyLinearVelocity", V0)
	end
end

local function tt_resolve_void_pos_deep(t_hrp, head)
	local pos = tt_best_pos(t_hrp)
	if pos and tt_okv(pos) then return pos end
	if head then
		pos = tt_best_pos(head)
		if pos and tt_okv(pos) then return pos end
	end
	local cf = tt_read(t_hrp)
	if cf then return cf.Position end
	if head then
		local cf2 = tt_read(head)
		if cf2 then return cf2.Position end
	end
	return nil

end

local function tt_apply_teleport(hrp, dest, hum, t_hrp)
	if not tt_okv(dest) then return end
	local target_cf = CFrame.new(dest)
	if hum then
		pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end)
		pcall(function() hum.AutoRotate = false end)
		pcall(function() hum.PlatformStand = false end)
	end
	tt_nuke()
	tt_write(hrp, target_cf)
end

local function tt_void_pierce_sample(part)
	if not part then return nil end
	local pos
	pcall(function()
		local mt = getrawmetatable(part)
		local ri = mt and rawget(mt, "__index")
		if ri then
			local cf = ri(part, "CFrame")
			if cf and tt_okv(cf.Position) then pos = cf.Position end
		end
	end)
	if pos then return pos end
	pcall(function()
		if gethiddenproperty then
			local cf = gethiddenproperty(part, "CFrame")
			if cf and tt_okv(cf.Position) then pos = cf.Position end
		end
	end)
	if pos then return pos end
	pcall(function()
		if ficlone then
			local cl = ficlone(part)
			if cl and tt_okv(cl.CFrame.Position) then pos = cl.CFrame.Position end
		end
	end)
	if pos then return pos end
	pcall(function()
		if getproperties then
			local props = getproperties(part)
			if props and props.CFrame and tt_okv(props.CFrame.Position) then pos = props.CFrame.Position end
		end
	end)
	if pos then return pos end
	local ok, cf = pcall(function() return part.CFrame end)
	if ok and cf and tt_okv(cf.Position) then return cf.Position end
	return nil
end
getgenv().tt_void_pierce_sample = tt_void_pierce_sample

local rapid_fire_hook_orig = nil
local rapid_fire_hook_active = false

local rapid_fire_weapon_settings = {
 ShootRecoil = 0,
 ShootSpread = 0,
 ProjectileSpeed = 9e4,
 ShootCooldown = 0,
 QuickShotCooldown = 0,
 ShootBurstCooldown = 0,
 ShootExplosionRadius = 0,
 AttackCooldown = 0,
 Cooldown = 0,
 DashCooldown = 0,
 SpinCooldown = 0,
 SpinSpeed = 500,
 DeflectCooldown = 0,
}

getgenv().start_rapid_fire = function()
 if rapid_fire_hook_active then return end
 task.spawn(function()
  pcall(function()
   local ClientItem = require(localplayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem)
   local Input = ClientItem.Input
   rapid_fire_hook_orig = hookfunction(Input, newcclosure(function(...)
    local args = {...}
    if (config.rapid_fire or config.csh_rapid_fire) and type(args[1]) == "table" and args[1].Info then
     for k, v in pairs(rapid_fire_weapon_settings) do
      args[1].Info[k] = v
     end
    end
    return rapid_fire_hook_orig(...)
   end))
   rapid_fire_hook_active = true
  end)
 end)

end

getgenv().stop_rapid_fire = function()
 config.rapid_fire = false
 if rapid_fire_hook_orig and rapid_fire_hook_active then
  pcall(function()
   local ClientItem = require(localplayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem)
   hookfunction(ClientItem.Input, rapid_fire_hook_orig)
  end)
  rapid_fire_hook_orig = nil
  rapid_fire_hook_active = false
 end
end


local translocation_conn = nil
local translocation_active = false
local TRANSLOC_FAR_AXIS = 1073741824

local function transloc_ringPoint(anchor, minR, maxR)
    local angle = math.random() * 2 * math.pi
    local radius = minR + math.random() * (maxR - minR)
    return CFrame.new(anchor + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius))
        * CFrame.fromOrientation(
            math.random() * 2 * math.pi,
            math.random() * 2 * math.pi,
            math.random() * 2 * math.pi
        )
end

local function translocateEvade(currentCF, hasTargetsNow)
    if not hasTargetsNow then
        return transloc_ringPoint(currentCF.Position, 10000, 1000000000)
    end
    local collectionService = cloneref(game:GetService("CollectionService"))
    local chosen = nil
    for _, part in ipairs(collectionService:GetTagged("OutOfBoundsPart")) do
        if part:GetAttribute("KillDelay") == 0 then
            chosen = part
            break
        end
    end
    if chosen == nil then
        return transloc_ringPoint(currentCF.Position, 10000, 1000000000)
    end
    local offset = -5
    return chosen.CFrame * CFrame.new(0, -chosen.Size.Y / 2 + offset, 0)
end

local gun_bypass_conn = nil
local gun_bypass_active = false
local gun_bypass_render_conn = nil
local gun_bypass_rf_hook_orig = nil
local gun_bypass_rf_active = false

local gun_bypass_weapon_settings = {
 ShootRecoil = 0,
 ShootSpread = 0,
 ProjectileSpeed = math.huge,
 ShootCooldown = 0,
 QuickShotCooldown = 0,
 ShootBurstCooldown = 0,
 ShootExplosionRadius = 0,
 AttackCooldown = 0,
 Cooldown = 0,
 DashCooldown = 0,
 SpinCooldown = 0,
 SpinSpeed = 500,
 DeflectCooldown = 0,
}

local function gb_start_rf_hook()
 if gun_bypass_rf_active then return end
 task.spawn(function()
  pcall(function()
   local ClientItem = require(localplayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem)
   local Input = ClientItem.Input
   gun_bypass_rf_hook_orig = hookfunction(Input, newcclosure(function(...)
    local args = {...}
    if config.gun_bypass_enabled and config.gun_bypass_method == 2 and type(args[1]) == "table" and args[1].Info then
     for k, v in pairs(gun_bypass_weapon_settings) do
      args[1].Info[k] = v
     end
    end
    return gun_bypass_rf_hook_orig(...)
   end))
   gun_bypass_rf_active = true
  end)
 end)
end

local function gb_stop_rf_hook()
 if gun_bypass_rf_hook_orig and gun_bypass_rf_active then
  pcall(function()
   local ClientItem = require(localplayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem)
   hookfunction(ClientItem.Input, gun_bypass_rf_hook_orig)
  end)
  gun_bypass_rf_hook_orig = nil
  gun_bypass_rf_active = false
 end
end

getgenv().start_gun_bypass = function()
 if gun_bypass_active then return end
 gun_bypass_active = true
 config.gun_bypass_enabled = true
 do
  gb_start_rf_hook()
  if gun_bypass_conn then gun_bypass_conn:Disconnect() end
  local gb2_last = 0
  gun_bypass_conn = run_service.Heartbeat:Connect(function()
   if not config.gun_bypass_enabled then return end
   local now = tick()
   if now - gb2_last < 0.016 then return end
   gb2_last = now
   local fire_part, target_char = manipulation.get_closest()
   if not fire_part or not target_char then return end
   manipulation.fire_toward(fire_part, target_char)
  end)
 end
end

getgenv().stop_gun_bypass = function()
 gun_bypass_active = false
 config.gun_bypass_enabled = false
 if gun_bypass_conn then gun_bypass_conn:Disconnect(); gun_bypass_conn = nil end
 if gun_bypass_render_conn then gun_bypass_render_conn:Disconnect(); gun_bypass_render_conn = nil end
 gb_stop_rf_hook()
 local hum = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")
 if hum then
  pcall(function() hum.AutoRotate = true end)
  pcall(function() hum.PlatformStand = false end)
  pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
 end
end

local _autoshoot_conn = nil
local _autoshoot_active = false

getgenv().start_autoshoot = function()
 if _autoshoot_active then return end
 _autoshoot_active = true
 config.autoshoot_enabled = true
 local _as_last = 0
 _autoshoot_conn = run_service.Heartbeat:Connect(function()
  if not config.autoshoot_enabled then return end
  local now = tick()
  if now - _as_last < 0.016 then return end
  _as_last = now
  if not localplayer.Character then return end
  local root = localplayer.Character:FindFirstChild("HumanoidRootPart")
  if not root then return end
  pcall(function()
   local rs = game:GetService("ReplicatedStorage")
   local fighter_ok, fighter = pcall(require, localplayer.PlayerScripts.Controllers.FighterController)
   if not fighter_ok or not fighter.LocalFighter then return end
   local item = fighter.LocalFighter.EquippedItem
   if not item then return end
   local fire_part, target_char = manipulation.get_closest()
   if not fire_part or not target_char then return end
   manipulation.fire_toward(fire_part, target_char)
  end)
 end)
end

getgenv().stop_autoshoot = function()
 _autoshoot_active = false
 config.autoshoot_enabled = false
 if _autoshoot_conn then _autoshoot_conn:Disconnect(); _autoshoot_conn = nil end
end

local _br_conn = nil
local _br_active = false

getgenv().start_bullet_redirect = function()
 if _br_active then return end
 _br_active = true
 config.bullet_redirect_enabled = true
 local _br_last = 0
 _br_conn = run_service.Heartbeat:Connect(function()
  if not config.bullet_redirect_enabled then return end
  local now = tick()
  if now - _br_last < 0.016 then return end
  _br_last = now
  if not localplayer.Character then return end
  pcall(function()
   local rs = game:GetService("ReplicatedStorage")
   local util_ok, util = pcall(require, rs.Modules.Utility)
   local enums_ok, enums = pcall(require, rs.Modules.EnumLibrary)
   local fighter_ok, fighter = pcall(require, localplayer.PlayerScripts.Controllers.FighterController)
   if not util_ok or not enums_ok or not fighter_ok then return end
   if not fighter.LocalFighter then return end
   local item = fighter.LocalFighter.EquippedItem
   if not item then return end
   local target_part, target_char = manipulation.get_closest()
   if not target_part or not target_char then return end
   local cam = workspace.CurrentCamera.CFrame
   local manip_pt, height = manipulation.calculate_point(cam.Position, target_part.Position, target_char)
   if not manip_pt then return end
   local shoot_pos = (height == nil and manip_pt) or cam.Position
   local cameradata = {}
   cameradata[utf8.char(1)] = {
    [utf8.char(0)] = util:EncodeCFrame(CFrame.new(shoot_pos.X, shoot_pos.Y + (height or 0), shoot_pos.Z) * CFrame.Angles(CFrame.lookAt(shoot_pos, target_part.Position):ToOrientation())),
    [utf8.char(1)] = height and util:EncodeCFrame(CFrame.new(target_part.Position) * CFrame.Angles(CFrame.lookAt(shoot_pos, target_part.Position):ToOrientation())) or util:EncodeCFrame(CFrame.new(shoot_pos.X, shoot_pos.Y + (height or 0), shoot_pos.Z) * CFrame.Angles(CFrame.lookAt(shoot_pos, target_part.Position):ToOrientation())),
    [utf8.char(2)] = target_part,
    [utf8.char(3)] = util:EncodeCFrame(target_part.CFrame:ToObjectSpace(CFrame.new(target_part.Position))),
   }
   rs.Remotes.Replication.Fighter.UseItem:FireServer(item:Get("ObjectID"), enums:ToEnum("StartShooting"), cameradata, nil)
  end)
 end)
end

getgenv().stop_bullet_redirect = function()
 _br_active = false
 config.bullet_redirect_enabled = false
 if _br_conn then _br_conn:Disconnect(); _br_conn = nil end
end

local KC_ITER_RADIUS = 500000

local function kc_find_target()
 local hrp = getgenv().get_hrp(localplayer)
 if not hrp then return nil end
 local best, best_d = nil, math.huge
 for _, p in ipairs(players:GetPlayers()) do
  if p ~= localplayer and p.Character then
   local t_hrp = p.Character:FindFirstChild("HumanoidRootPart")
   local hum = p.Character:FindFirstChildOfClass("Humanoid")
   local no_ff = not p.Character:FindFirstChildOfClass("ForceField")
   local diff_team = localplayer.Team == nil or p.Team == nil or localplayer.Team ~= p.Team
   if t_hrp and hum and hum.Health > 0 and no_ff and diff_team then
    local d = (hrp.Position - t_hrp.Position).Magnitude
    if d < best_d then best_d = d; best = p end
   end
  end
 end
 return best
end

local ragebot_bypass_active = false
local ragebot_bypass_conn = nil
local ragebot_bypass_projectiles = {}
local ragebot_bypass_child_added_conn = nil
local ragebot_bypass_child_removed_conn = nil
local RAGEBOT_BYPASS_TARGET_POS = CFrame.new(9000, 9000, 9000)
local _rb_coord_sign_x = 1
local _rb_coord_sign_y = 1
local _rb_coord_sign_z = 1
local _rb_coord_flip_last = 0
local function _rb_get_bypass_target_pos()
 local list = config.ragebot_bypass_coord_list
 if list and #list > 0 then
  local idx = config.ragebot_bypass_coord_index or 1
  local entry = list[idx]
  if entry then
   return CFrame.new(entry[1], entry[2], entry[3])
  end
 end
 local bx = config.ragebot_bypass_x or 10000000000000
 local by = config.ragebot_bypass_y_offset or 10000000000000
 local bz = config.ragebot_bypass_z or 10000000000000
 return CFrame.new(bx * _rb_coord_sign_x, by * _rb_coord_sign_y, bz * _rb_coord_sign_z)
end

getgenv().start_ragebot_bypass = function()
 if ragebot_bypass_active then return end
 ragebot_bypass_active = true
 config.ragebot_bypass_enabled = true
 ragebot_bypass_projectiles = {}
 if ragebot_bypass_child_added_conn then ragebot_bypass_child_added_conn:Disconnect() end
 if ragebot_bypass_child_removed_conn then ragebot_bypass_child_removed_conn:Disconnect() end
 ragebot_bypass_child_added_conn = workspace.ChildAdded:Connect(function(o)
  if not o:IsA("BasePart") then return end
  if o.Name == "CoreProjectile" then
   ragebot_bypass_projectiles[o] = true
  elseif o.Name == "Part" then
   task.defer(function()
    if o and o.Parent and o.AssemblyLinearVelocity.Magnitude > 50 then
     ragebot_bypass_projectiles[o] = true
    end
   end)
  end
 end)
 ragebot_bypass_child_removed_conn = workspace.ChildRemoved:Connect(function(o)
  ragebot_bypass_projectiles[o] = nil
 end)
 local _rb_hb_last = 0
 local _rb_target = nil
 local _rb_target_scan = 0
 local _rb_last_fire = 0
 local _rb_pos_bufs = {}
 local RB_BUF_SIZE = 32

 local function _rb_get_or_create_buf(key)
  if not _rb_pos_bufs[key] then
   _rb_pos_bufs[key] = { pts={}, head=0, n=0 }
  end
  return _rb_pos_bufs[key]
 end
 local function _rb_buf_push(buf, x, y, z, t)
  local idx = (buf.head % RB_BUF_SIZE) + 1
  buf.pts[idx] = {x=x, y=y, z=z, t=t}
  buf.head = idx
  if buf.n < RB_BUF_SIZE then buf.n = buf.n + 1 end
 end
 local function _rb_buf_all(buf)
  local out = {}
  for i = 1, buf.n do
   out[i] = buf.pts[i]
  end
  return out
 end
 local function _rb_is_voidspamming(t_hrp, buf)
  local live = tt_live and tt_live[t_hrp]
  if live and live.vx then
   local spd = math.sqrt(live.vx*live.vx + live.vy*live.vy + live.vz*live.vz)
   if spd > (5000000) then return true end
  end
  if buf.n >= 2 then
   local latest = buf.pts[buf.head]
   local prev_idx = ((buf.head - 2) % RB_BUF_SIZE) + 1
   local prev = buf.pts[prev_idx]
   if latest and prev then
    local dt = latest.t - prev.t
    if dt > 0 and dt < 0.5 then
     local dx = latest.x - prev.x
     local dy = latest.y - prev.y
     local dz = latest.z - prev.z
     local step = math.sqrt(dx*dx + dy*dy + dz*dz)
     if step > (5000000) then return true end
    end
   end
  end
  local ok_v, vel = pcall(function() return t_hrp.AssemblyLinearVelocity end)
  if ok_v and vel then
   if vel.Magnitude > (5000000) then return true end
  end
  return false
 end
 local function _rb_resolve_pos(t_hrp, head)
  local positions = {}
  local live = tt_live and tt_live[t_hrp]
  if live then
   if live.lkg_x and tt_ok3(live.lkg_x, live.lkg_y, live.lkg_z) then
    positions[#positions+1] = Vector3.new(live.lkg_x, live.lkg_y, live.lkg_z)
   end
   if tt_ok3(live.x, live.y, live.z) then
    positions[#positions+1] = Vector3.new(live.x, live.y, live.z)
   end
  end
  if head then
   local live_h = tt_live and tt_live[head]
   if live_h and live_h.lkg_x and tt_ok3(live_h.lkg_x, live_h.lkg_y, live_h.lkg_z) then
    positions[#positions+1] = Vector3.new(live_h.lkg_x, live_h.lkg_y, live_h.lkg_z)
   end
  end
  local ok_cf, raw_cf = pcall(function() return t_hrp.CFrame end)
  if ok_cf and raw_cf and tt_okv(raw_cf.Position) then
   positions[#positions+1] = raw_cf.Position
  end
  local raw = tt_void_pierce_sample(t_hrp)
  if raw and tt_okv(raw) then positions[#positions+1] = raw end
  if head then
   local raw_h = tt_void_pierce_sample(head)
   if raw_h and tt_okv(raw_h) then positions[#positions+1] = raw_h end
  end
  return positions
 end
 local function _rb_find_target()
  local my_hrp = getgenv().get_hrp(localplayer)
  if not my_hrp then return nil end
  local best, best_d = nil, math.huge
  for _, p in ipairs(players:GetPlayers()) do
   if p ~= localplayer and p.Character then
    local t_hrp = p.Character:FindFirstChild("HumanoidRootPart")
    local hum = p.Character:FindFirstChildOfClass("Humanoid")
    local no_ff = not p.Character:FindFirstChildOfClass("ForceField")
    local diff_team = localplayer.Team == nil or p.Team == nil or localplayer.Team ~= p.Team
    if t_hrp and hum and hum.Health > 0 and no_ff and diff_team then
     local ok_cf, cf = pcall(function() return t_hrp.CFrame end)
     local pos = (ok_cf and cf) and cf.Position or t_hrp.Position
     local d = (my_hrp.Position - pos).Magnitude
     if d < best_d then best_d = d; best = p end
    end
   end
  end
  return best
 end
 local function _rb_attack_positions(my_hrp, my_hum, positions, fire_part, target_char)
  local V0 = Vector3.zero
  local mt_rb = getrawmetatable(my_hrp)
  local ni_rb = mt_rb and rawget(mt_rb, "__newindex")
  local snaps = math.max(config.vk_snap_count or 3, 1)
  for _, pos in ipairs(positions) do
   if tt_okv(pos) then
    local snap_cf = CFrame.new(pos.X, pos.Y + 15, pos.Z)
    for _ = 1, snaps do
     if ni_rb then
      pcall(ni_rb, my_hrp, "AssemblyLinearVelocity", V0)
      pcall(ni_rb, my_hrp, "AssemblyAngularVelocity", V0)
      pcall(ni_rb, my_hrp, "CFrame", snap_cf)
      pcall(ni_rb, my_hrp, "AssemblyLinearVelocity", V0)
     else
      pcall(function()
       my_hrp.AssemblyLinearVelocity = V0
       my_hrp.AssemblyAngularVelocity = V0
       my_hrp.CFrame = snap_cf
       my_hrp.AssemblyLinearVelocity = V0
      end)
     end
     if sethiddenproperty then
      pcall(sethiddenproperty, my_hrp, "AssemblyLinearVelocity", V0)
      pcall(sethiddenproperty, my_hrp, "AssemblyAngularVelocity", V0)
      pcall(sethiddenproperty, my_hrp, "CFrame", snap_cf)
     end
    end
    pcall(function() my_hum:ChangeState(Enum.HumanoidStateType.Physics) end)
    pcall(manipulation.fire_toward, fire_part, target_char)
    tt_nuke()
   end
  end
 end
 ragebot_bypass_conn = run_service.Heartbeat:Connect(function(dt)
  if not config.ragebot_bypass_enabled then return end
  local now = tick()
  local _rb_interval = 1 / 128
  if now - _rb_hb_last < _rb_interval then return end
  _rb_hb_last = now
  local list = config.ragebot_bypass_coord_list
  if list and #list > 1 then
   local idx = config.ragebot_bypass_coord_index or 1
   idx = (idx % #list) + 1
   config.ragebot_bypass_coord_index = idx
  end
  local _KC_STEP = 1e17
  local _KC_ITERS = 4
  local _rnd_rb = math.random
  local _cf_rb = CFrame.new
  local _V0_kc = Vector3.zero
  task.defer(function()
   for _, p in pairs(players:GetPlayers()) do
    if p ~= localplayer and p.Character then
     local h = p.Character:FindFirstChild("HumanoidRootPart")
     if h then
      local mt_kc = getrawmetatable(h)
      local ni_kc = mt_kc and rawget(mt_kc, "__newindex")
      local px, py, pz = 999999986991104, 999999986991104, -999999986991104
      if ni_kc then
       pcall(function()
        for _kci = 1, _KC_ITERS do
         local nx = px + (_rnd_rb() < 0.5 and _KC_STEP or -_KC_STEP)
         local ny = py + (_rnd_rb() < 0.5 and _KC_STEP or -_KC_STEP)
         local nz = pz + (_rnd_rb() < 0.5 and _KC_STEP or -_KC_STEP)
         ni_kc(h, "AssemblyLinearVelocity", _V0_kc)
         ni_kc(h, "CFrame", _cf_rb(nx, ny, nz))
         px = nx; py = ny; pz = nz
        end
        ni_kc(h, "AssemblyLinearVelocity", _V0_kc)
        ni_kc(h, "AssemblyAngularVelocity", _V0_kc)
       end)
      else
       pcall(function()
        for _kci = 1, _KC_ITERS do
         local nx = px + (_rnd_rb() < 0.5 and _KC_STEP or -_KC_STEP)
         local ny = py + (_rnd_rb() < 0.5 and _KC_STEP or -_KC_STEP)
         local nz = pz + (_rnd_rb() < 0.5 and _KC_STEP or -_KC_STEP)
         h.AssemblyLinearVelocity = _V0_kc
         h.CFrame = _cf_rb(nx, ny, nz)
         px = nx; py = ny; pz = nz
        end
        h.AssemblyLinearVelocity = _V0_kc
        h.AssemblyAngularVelocity = _V0_kc
       end)
      end
      if sethiddenproperty then
       pcall(sethiddenproperty, h, "AssemblyLinearVelocity", _V0_kc)
       pcall(sethiddenproperty, h, "AssemblyAngularVelocity", _V0_kc)
       pcall(sethiddenproperty, h, "CFrame", _cf_rb(px, py, pz))
      end
     end
    end
   end
   for p in pairs(ragebot_bypass_projectiles) do
    if p and p.Parent then
     local mt_kcp = getrawmetatable(p)
     local ni_kcp = mt_kcp and rawget(mt_kcp, "__newindex")
     local px2, py2, pz2 = 999999986991104, 999999986991104, -999999986991104
     if ni_kcp then
      pcall(function()
       for _kci2 = 1, _KC_ITERS do
        local nx = px2 + (_rnd_rb() < 0.5 and _KC_STEP or -_KC_STEP)
        local ny = py2 + (_rnd_rb() < 0.5 and _KC_STEP or -_KC_STEP)
        local nz = pz2 + (_rnd_rb() < 0.5 and _KC_STEP or -_KC_STEP)
        ni_kcp(p, "AssemblyLinearVelocity", _V0_kc)
        ni_kcp(p, "CFrame", _cf_rb(nx, ny, nz))
        px2 = nx; py2 = ny; pz2 = nz
       end
       ni_kcp(p, "AssemblyLinearVelocity", _V0_kc)
       ni_kcp(p, "AssemblyAngularVelocity", _V0_kc)
      end)
     else
      pcall(function()
       for _kci2 = 1, _KC_ITERS do
        local nx = px2 + (_rnd_rb() < 0.5 and _KC_STEP or -_KC_STEP)
        local ny = py2 + (_rnd_rb() < 0.5 and _KC_STEP or -_KC_STEP)
        local nz = pz2 + (_rnd_rb() < 0.5 and _KC_STEP or -_KC_STEP)
        p.AssemblyLinearVelocity = _V0_kc
        p.CFrame = _cf_rb(nx, ny, nz)
        px2 = nx; py2 = ny; pz2 = nz
       end
       p.AssemblyLinearVelocity = _V0_kc
       p.AssemblyAngularVelocity = _V0_kc
      end)
     end
    else
     ragebot_bypass_projectiles[p] = nil
    end
   end
  end)
  if now - _rb_target_scan >= 0.5 then
   _rb_target = _rb_find_target()
   _rb_target_scan = now
  end
  local target = _rb_target
  if not target or not target.Character then return end
  local t_hrp = target.Character:FindFirstChild("HumanoidRootPart")
  local head = target.Character:FindFirstChild("Head")
  if not t_hrp then return end
  local buf = _rb_get_or_create_buf(t_hrp)
  for _ = 1, 4 do
   pcall(tt_sample_part, t_hrp)
   if head then pcall(tt_sample_part, head) end
  end
  local raw = tt_void_pierce_sample(t_hrp)
  if raw and tt_okv(raw) then
   pcall(tt_record, t_hrp, CFrame.new(raw), now)
   _rb_buf_push(buf, raw.X, raw.Y, raw.Z, now)
  else
   local ok_cf, cf = pcall(function() return t_hrp.CFrame end)
   if ok_cf and cf and tt_okv(cf.Position) then
    _rb_buf_push(buf, cf.X, cf.Y, cf.Z, now)
   end
  end
  if head then
   local raw_h = tt_void_pierce_sample(head)
   if raw_h and tt_okv(raw_h) then pcall(tt_record, head, CFrame.new(raw_h), now) end
  end
  local fire_interval = 1 / math.max(config.ragebot_bypass_frequency or 60, 1)
  if now - _rb_last_fire < fire_interval then return end
  _rb_last_fire = now
  local my_hrp = getgenv().get_hrp(localplayer)
  local my_hum = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")
  if not my_hrp or not my_hum or my_hum.Health <= 0 then return end
  local is_voiding = _rb_is_voidspamming(t_hrp, buf)
  local positions = _rb_resolve_pos(t_hrp, head)
  if #positions == 0 then return end
  if is_voiding then
   local all_pts = _rb_buf_all(buf)
   for _, pt in ipairs(all_pts) do
    if pt and tt_ok3(pt.x, pt.y, pt.z) then
     positions[#positions+1] = Vector3.new(pt.x, pt.y, pt.z)
    end
   end
  end
  kc_nuke_fallen_parts()
  pcall(function() my_hum:ChangeState(Enum.HumanoidStateType.Physics) end)
  pcall(function() my_hum.PlatformStand = false end)
  pcall(function() my_hum.AutoRotate = false end)
  local fire_part = head or t_hrp
  local _rb_layers = math.max(config.ragebot_bypass_fake_layers or 1, 1)
  for _rbl = 1, _rb_layers do
   _rb_attack_positions(my_hrp, my_hum, positions, fire_part, target.Character)
  end
  kc_nuke_fallen_parts()
 end)
end

getgenv().stop_ragebot_bypass = function()
 ragebot_bypass_active = false
 config.ragebot_bypass_enabled = false
 if ragebot_bypass_conn then ragebot_bypass_conn:Disconnect(); ragebot_bypass_conn = nil end
 if ragebot_bypass_child_added_conn then ragebot_bypass_child_added_conn:Disconnect(); ragebot_bypass_child_added_conn = nil end
 if ragebot_bypass_child_removed_conn then ragebot_bypass_child_removed_conn:Disconnect(); ragebot_bypass_child_removed_conn = nil end
 ragebot_bypass_projectiles = {}
end

local _rbpg_active = false
local _rbpg_conn = nil
local _rbpg_glued_parts = {}
local _rbpg_bindings = {}
local _RBPG_VOID = CFrame.new(math.random(-100000, -10000), 100000, math.random(-100000, 10000))

local function _rbpg_setup_glue(part)
 local entry = _rbpg_glued_parts[part]
 if entry then entry.refCount = entry.refCount + 1; return end
 local weld = part:FindFirstChildOfClass("WeldConstraint")
 local orig = nil
 if weld then
  orig = weld.Part1
  if orig then weld.Part1 = nil end
  part.Anchored = true
 end
 _rbpg_glued_parts[part] = { refCount = 1, weld = weld, originalPart1 = orig }
end

local function _rbpg_release_glue(part)
 local entry = _rbpg_glued_parts[part]
 if not entry then return end
 entry.refCount = entry.refCount - 1
 if entry.refCount > 0 then return end
 local weld = entry.weld
 if weld and entry.originalPart1 then
  weld.Part1 = entry.originalPart1
  entry.originalPart1.Anchored = false
 end
 _rbpg_glued_parts[part] = nil
end

local function _rbpg_acquire(ourPart, hitboxPart)
 if setthreadidentity and getthreadidentity then
  local prev = getthreadidentity()
  setthreadidentity(8)
  pcall(sethiddenproperty, ourPart, "PhysicsRepRootPart", hitboxPart)
  setthreadidentity(prev)
 end
 local bound = _rbpg_bindings[ourPart]
 if bound ~= hitboxPart then
  if bound then _rbpg_release_glue(bound) end
  _rbpg_setup_glue(hitboxPart)
  _rbpg_bindings[ourPart] = hitboxPart
 end
 hitboxPart.CFrame = CFrame.new(_RBPG_VOID.Position)
 return _RBPG_VOID
end

local function _rbpg_free(ourPart)
 local bound = _rbpg_bindings[ourPart]
 if not bound then return end
 _rbpg_bindings[ourPart] = nil
 _rbpg_release_glue(bound)
 if setthreadidentity and getthreadidentity then
  local prev = getthreadidentity()
  setthreadidentity(8)
  pcall(sethiddenproperty, ourPart, "PhysicsRepRootPart", nil)
  setthreadidentity(prev)
 end
end

local function _rbpg_find_target()
 local my_hrp = getgenv().get_hrp(localplayer)
 if not my_hrp then return nil end
 local best, best_d = nil, math.huge
 for _, p in ipairs(players:GetPlayers()) do
  if p ~= localplayer and p.Character then
   local t_hrp = p.Character:FindFirstChild("HumanoidRootPart")
   local hum = p.Character:FindFirstChildOfClass("Humanoid")
   local no_ff = not p.Character:FindFirstChildOfClass("ForceField")
   local diff_team = localplayer.Team == nil or p.Team == nil or localplayer.Team ~= p.Team
   if t_hrp and hum and hum.Health > 0 and no_ff and diff_team then
    local ok_cf, cf = pcall(function() return t_hrp.CFrame end)
    local pos = (ok_cf and cf) and cf.Position or t_hrp.Position
    local d = (my_hrp.Position - pos).Magnitude
    if d < best_d then best_d = d; best = p end
   end
  end
 end
 return best
end

local function _rbpg_resolve_hitbox(target_char)
 return target_char:FindFirstChild("HitboxHead")
  or target_char:FindFirstChild("HitboxBody")
  or target_char:FindFirstChild("Head")
  or target_char:FindFirstChild("HumanoidRootPart")
end

getgenv().start_ragebot_bypass_partglue = function()
 if _rbpg_active then return end
 _rbpg_active = true
 config.ragebot_bypass_enabled = true
 local _rbpg_last = 0
 local _rbpg_target = nil
 local _rbpg_scan = 0
 _rbpg_conn = run_service.Heartbeat:Connect(function()
  if not config.ragebot_bypass_enabled then return end
  local now = tick()
  local fire_interval = 1 / math.max(config.ragebot_bypass_frequency or 60, 1)
  if now - _rbpg_last < fire_interval then return end
  _rbpg_last = now
  if now - _rbpg_scan >= 0.5 then
   _rbpg_target = _rbpg_find_target()
   _rbpg_scan = now
  end
  local target = _rbpg_target
  if not target or not target.Character then return end
  local my_hrp = getgenv().get_hrp(localplayer)
  local my_hum = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")
  if not my_hrp or not my_hum or my_hum.Health <= 0 then return end
  local hitbox = _rbpg_resolve_hitbox(target.Character)
  if not hitbox then return end
  pcall(function()
   local void_cf = _rbpg_acquire(my_hrp, hitbox)
   local snap_cf = CFrame.new(void_cf.Position.X, void_cf.Position.Y - 0.7, void_cf.Position.Z)
   local V0 = Vector3.zero
   local mt = getrawmetatable(my_hrp)
   local ni = mt and rawget(mt, "__newindex")
   local snaps = math.max(config.vk_snap_count or 3, 1)
   for _ = 1, snaps do
    if ni then
     pcall(ni, my_hrp, "AssemblyLinearVelocity", V0)
     pcall(ni, my_hrp, "AssemblyAngularVelocity", V0)
     pcall(ni, my_hrp, "CFrame", snap_cf)
     pcall(ni, my_hrp, "AssemblyLinearVelocity", V0)
    else
     pcall(function()
      my_hrp.AssemblyLinearVelocity = V0
      my_hrp.AssemblyAngularVelocity = V0
      my_hrp.CFrame = snap_cf
      my_hrp.AssemblyLinearVelocity = V0
     end)
    end
    if sethiddenproperty then
     pcall(sethiddenproperty, my_hrp, "AssemblyLinearVelocity", V0)
     pcall(sethiddenproperty, my_hrp, "AssemblyAngularVelocity", V0)
     pcall(sethiddenproperty, my_hrp, "CFrame", snap_cf)
    end
   end
   pcall(function() my_hum:ChangeState(Enum.HumanoidStateType.Physics) end)
   if config.autoshoot_enabled then
    pcall(manipulation.fire_toward, hitbox, target.Character)
   end
   if config.bullet_redirect_enabled then
    pcall(function()
     local rs = game:GetService("ReplicatedStorage")
     local util_ok, util = pcall(require, rs.Modules.Utility)
     local enums_ok, enums = pcall(require, rs.Modules.EnumLibrary)
     local fighter_ok, fighter = pcall(require, localplayer.PlayerScripts.Controllers.FighterController)
     if not util_ok or not enums_ok or not fighter_ok then return end
     if not fighter.LocalFighter then return end
     local item = fighter.LocalFighter.EquippedItem
     if not item then return end
     local target_pos = hitbox.Position
     local shoot_pos = snap_cf.Position
     local cameradata = {}
     cameradata[utf8.char(1)] = {
      [utf8.char(0)] = util:EncodeCFrame(CFrame.new(shoot_pos) * CFrame.Angles(CFrame.lookAt(shoot_pos, target_pos):ToOrientation())),
      [utf8.char(1)] = util:EncodeCFrame(CFrame.new(target_pos) * CFrame.Angles(CFrame.lookAt(shoot_pos, target_pos):ToOrientation())),
      [utf8.char(2)] = hitbox,
      [utf8.char(3)] = util:EncodeCFrame(hitbox.CFrame:ToObjectSpace(CFrame.new(target_pos))),
     }
     rs.Remotes.Replication.Fighter.UseItem:FireServer(item:Get("ObjectID"), enums:ToEnum("StartShooting"), cameradata, nil)
    end)
   end
   if not config.autoshoot_enabled and not config.bullet_redirect_enabled then
    pcall(manipulation.fire_toward, hitbox, target.Character)
   end
   _rbpg_free(my_hrp)
  end)
  kc_nuke_fallen_parts()
 end)
end

getgenv().stop_ragebot_bypass_partglue = function()
 _rbpg_active = false
 config.ragebot_bypass_enabled = false
 if _rbpg_conn then _rbpg_conn:Disconnect(); _rbpg_conn = nil end
 for ourPart in pairs(_rbpg_bindings) do
  pcall(_rbpg_free, ourPart)
 end
 _rbpg_bindings = {}
 _rbpg_glued_parts = {}
end

local function _dispatch_start_ragebot_bypass()
 getgenv().start_ragebot_bypass_partglue()
end

local function _dispatch_stop_ragebot_bypass()
 getgenv().stop_ragebot_bypass_partglue()
end

local function kc_nuke_fallen_parts()
 pcall(function() workspace.FallenPartsDestroyHeight = -math.huge end)
 pcall(function() workspace.FallenPartsDestroyHeight = 0/0 end)
 pcall(function()
  local mt = getrawmetatable(workspace)
  if mt then
   local ni = rawget(mt, "__newindex")
   if ni then
    ni(workspace, "FallenPartsDestroyHeight", -math.huge)
    pcall(function() ni(workspace, "FallenPartsDestroyHeight", 0/0) end)
   end
  end
 end)
end

local kicia_counter_conn = nil
local kicia_counter_active = false
local kc_m1_projectiles = {}
local kc_m1_child_added_conn = nil
local kc_m1_child_removed_conn = nil
local KC_M1_TARGET_POS = CFrame.new(9000, 9000, 9000)

local function kc_force_cf(hrp, target_cf)
 local V0 = Vector3.zero
 pcall(function()
  hrp.AssemblyLinearVelocity = V0
  hrp.AssemblyAngularVelocity = V0
  hrp.CFrame = target_cf
  hrp.AssemblyLinearVelocity = V0
  hrp.AssemblyAngularVelocity = V0
 end)
 pcall(function()
  local mt = getrawmetatable(hrp)
  if not mt then return end
  local ni = rawget(mt, "__newindex")
  if not ni then return end
  ni(hrp, "AssemblyLinearVelocity", V0)
  ni(hrp, "AssemblyAngularVelocity", V0)
  ni(hrp, "CFrame", target_cf)
  ni(hrp, "AssemblyLinearVelocity", V0)
  ni(hrp, "AssemblyAngularVelocity", V0)
  ni(hrp, "CFrame", target_cf)
  ni(hrp, "AssemblyLinearVelocity", V0)
  ni(hrp, "AssemblyAngularVelocity", V0)
 end)
 if sethiddenproperty then
  pcall(sethiddenproperty, hrp, "CFrame", target_cf)
  pcall(sethiddenproperty, hrp, "AssemblyLinearVelocity", V0)
  pcall(sethiddenproperty, hrp, "AssemblyAngularVelocity", V0)
  pcall(sethiddenproperty, hrp, "CFrame", target_cf)
 end
 pcall(function()
  local was = hrp.Anchored
  hrp.Anchored = true
  hrp.CFrame = target_cf
  hrp.AssemblyLinearVelocity = V0
  hrp.AssemblyAngularVelocity = V0
  hrp.CFrame = target_cf
  hrp.Anchored = was
 end)
end

local kc_last_snap = 0

getgenv().start_kicia_counter = function()
 if kicia_counter_active then return end
 kicia_counter_active = true
 config.kicia_counter_enabled = true
 kc_nuke_fallen_parts()
 if config.kicia_counter_method == 1 then
  kc_m1_projectiles = {}
  if kc_m1_child_added_conn then kc_m1_child_added_conn:Disconnect() end
  if kc_m1_child_removed_conn then kc_m1_child_removed_conn:Disconnect() end
  kc_m1_child_added_conn = workspace.ChildAdded:Connect(function(o)
   if not o:IsA("BasePart") then return end
   if o.Name == "CoreProjectile" then
    kc_m1_projectiles[o] = true
   elseif o.Name == "Part" then
    task.defer(function()
     if o and o.Parent and o.AssemblyLinearVelocity.Magnitude > 50 then
      kc_m1_projectiles[o] = true
     end
    end)
   end
  end)
  kc_m1_child_removed_conn = workspace.ChildRemoved:Connect(function(o)
   kc_m1_projectiles[o] = nil
  end)
  local _kc_m1_hb_last = 0
  kicia_counter_conn = run_service.Heartbeat:Connect(function()
   local _now = tick()
   if _now - _kc_m1_hb_last < 0.033 then return end
   _kc_m1_hb_last = _now
   pcall(function()
    for _, p in pairs(players:GetPlayers()) do
     if p ~= localplayer and p.Character then
      local h = p.Character:FindFirstChild("HumanoidRootPart")
      if h then
       h.CFrame = KC_M1_TARGET_POS
       h.AssemblyLinearVelocity = Vector3.zero
      end
     end
    end
    for p in pairs(kc_m1_projectiles) do
     if p and p.Parent then
      p.CFrame = KC_M1_TARGET_POS
      p.AssemblyLinearVelocity = Vector3.zero
     else
      kc_m1_projectiles[p] = nil
     end
    end
   end)
  end)
 elseif config.kicia_counter_method == 2 then
  kicia_counter_conn = run_service.Heartbeat:Connect(function()
   if not config.kicia_counter_enabled then return end
   local hrp = getgenv().get_hrp(localplayer)
   local hum = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")
   if not hrp or not hum or hum.Health <= 0 then return end
   local target = kc_find_target()
   if not target or not target.Character then return end
   local t_hrp = target.Character:FindFirstChild("HumanoidRootPart")
   if not t_hrp then return end
   local head = target.Character:FindFirstChild("Head")
   local aggression = math.clamp(config.void_counter_aggression or 5, 1, 5)
   local passes = 16 * aggression
   for _ = 1, passes do
    pcall(tt_sample_part, t_hrp)
    if head then pcall(tt_sample_part, head) end
   end
   local raw = tt_void_pierce_sample(t_hrp)
   if raw then
    pcall(tt_record, t_hrp, raw.X, raw.Y, raw.Z, CFrame.new(raw), tick())
   end
   if head then
    local rh = tt_void_pierce_sample(head)
    if rh then pcall(tt_record, head, rh.X, rh.Y, rh.Z, CFrame.new(rh), tick()) end
   end
   local now = tick()
   local min_interval = 0.016 / aggression
   if now - kc_last_snap < min_interval then return end
   kc_last_snap = now
   pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end)
   pcall(function() hum.PlatformStand = false end)
   pcall(function() hum.AutoRotate = false end)
   kc_nuke_fallen_parts()
   local sky_cf = CFrame.new(hrp.Position.X, hrp.Position.Y + 10000 * math.max(config.kicia_counter_speed or 1, 0.1), hrp.Position.Z)
   local snaps = math.clamp(config.void_counter_snap_count or 8, 1, 16)
   for _ = 1, snaps do
    kc_force_cf(hrp, sky_cf)
   end
   local fire_target = head or t_hrp
   manipulation.fire_toward(fire_target, target.Character)
   kc_nuke_fallen_parts()
  end)
  pcall(function()
   run_service:BindToRenderStep("KiciaCounterVoidGuard", Enum.RenderPriority.First.Value - 300, function()
    if not config.kicia_counter_enabled or not kicia_counter_active then
     pcall(function() run_service:UnbindFromRenderStep("KiciaCounterVoidGuard") end)
     return
    end
    local hrp = getgenv().get_hrp(localplayer)
    if not hrp then return end
    local hum = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")
    local target = kc_find_target()
    if not target or not target.Character then return end
    local t_hrp = target.Character:FindFirstChild("HumanoidRootPart")
    local head = target.Character:FindFirstChild("Head")
    if not t_hrp then return end
    local aggression = math.clamp(config.void_counter_aggression or 5, 1, 5)
    for _ = 1, 8 * aggression do
     pcall(tt_sample_part, t_hrp)
     if head then pcall(tt_sample_part, head) end
    end
    if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end) end
    kc_nuke_fallen_parts()
    local snaps = math.clamp(config.void_counter_snap_count or 8, 1, 16)
    local sky_cf_rs = CFrame.new(hrp.Position.X, hrp.Position.Y + 10000 * math.max(config.kicia_counter_speed or 1, 0.1), hrp.Position.Z)
    for _ = 1, snaps do
     kc_force_cf(hrp, sky_cf_rs)
    end
    local fire_target = head or t_hrp
    manipulation.fire_toward(fire_target, target.Character)
    kc_nuke_fallen_parts()
   end)
  end)
 elseif config.kicia_counter_method == 3 then
  local kc_m3_last_snap = 0
  local KC_M3_UNDERGROUND_Y = -2048
  kicia_counter_conn = run_service.Heartbeat:Connect(function()
   if not config.kicia_counter_enabled then return end
   local hrp = getgenv().get_hrp(localplayer)
   local hum = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")
   if not hrp or not hum or hum.Health <= 0 then return end
   local target = kc_find_target()
   if not target or not target.Character then return end
   local t_hrp = target.Character:FindFirstChild("HumanoidRootPart")
   local head = target.Character:FindFirstChild("Head")
   if not t_hrp then return end
   for _ = 1, 16 do
    pcall(tt_sample_part, t_hrp)
    if head then pcall(tt_sample_part, head) end
   end
   local now = tick()
   if now - kc_m3_last_snap < 0.016 then return end
   kc_m3_last_snap = now
   pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end)
   pcall(function() hum.PlatformStand = false end)
   pcall(function() hum.AutoRotate = false end)
   kc_nuke_fallen_parts()
   local cur_pos = hrp.Position
   local ray_params_m3 = RaycastParams.new()
   ray_params_m3.FilterDescendantsInstances = { localplayer.Character }
   ray_params_m3.FilterType = Enum.RaycastFilterType.Exclude
   local surface_y = KC_M3_UNDERGROUND_Y
   local underground_cf = CFrame.new(cur_pos.X, surface_y, cur_pos.Z)
   local snaps = math.clamp(config.void_counter_snap_count or 8, 1, 16)
   for _ = 1, snaps do
    kc_force_cf(hrp, underground_cf)
   end
   local fire_target = head or t_hrp
   pcall(function()
    local rs2 = game:GetService("ReplicatedStorage")
    local util_ok2, util2 = pcall(require, rs2.Modules.Utility)
    local enums_ok2, enums2 = pcall(require, rs2.Modules.EnumLibrary)
    local fighter_ok2, fighter2 = pcall(require, localplayer.PlayerScripts.Controllers.FighterController)
    if not util_ok2 or not enums_ok2 or not fighter_ok2 then return end
    if not fighter2.LocalFighter then return end
    local item2 = fighter2.LocalFighter.EquippedItem
    if not item2 then return end
    local cam2 = workspace.CurrentCamera.CFrame
    local manip_pt2, height2 = manipulation.calculate_point(cam2.Position, fire_target.Position, target.Character)
    if not manip_pt2 then return end
    local shoot_pos2 = (height2 == nil and manip_pt2) or cam2.Position
    local cameradata2 = {}
    cameradata2[utf8.char(1)] = {
     [utf8.char(0)] = util2:EncodeCFrame(CFrame.new(shoot_pos2.X, shoot_pos2.Y + (height2 or 0), shoot_pos2.Z) * CFrame.Angles(CFrame.lookAt(shoot_pos2, fire_target.Position):ToOrientation())),
     [utf8.char(1)] = height2 and util2:EncodeCFrame(CFrame.new(fire_target.Position) * CFrame.Angles(CFrame.lookAt(shoot_pos2, fire_target.Position):ToOrientation())) or util2:EncodeCFrame(CFrame.new(shoot_pos2.X, shoot_pos2.Y + (height2 or 0), shoot_pos2.Z) * CFrame.Angles(CFrame.lookAt(shoot_pos2, fire_target.Position):ToOrientation())),
     [utf8.char(2)] = fire_target,
     [utf8.char(3)] = util2:EncodeCFrame(fire_target.CFrame:ToObjectSpace(CFrame.new(fire_target.Position))),
    }
    rs2.Remotes.Replication.Fighter.UseItem:FireServer(item2:Get("ObjectID"), enums2:ToEnum("StartShooting"), cameradata2, nil)
   end)
   kc_nuke_fallen_parts()
  end)
  pcall(function()
   run_service:BindToRenderStep("KiciaCounterM3Guard", Enum.RenderPriority.First.Value - 300, function()
    if not config.kicia_counter_enabled or not kicia_counter_active then
     pcall(function() run_service:UnbindFromRenderStep("KiciaCounterM3Guard") end)
     return
    end
    local hrp = getgenv().get_hrp(localplayer)
    if not hrp then return end
    local hum = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")
    local target = kc_find_target()
    if not target or not target.Character then return end
    local t_hrp = target.Character:FindFirstChild("HumanoidRootPart")
    local head = target.Character:FindFirstChild("Head")
    if not t_hrp then return end
    for _ = 1, 8 do
     pcall(tt_sample_part, t_hrp)
     if head then pcall(tt_sample_part, head) end
    end
    if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end) end
    kc_nuke_fallen_parts()
    local cur_pos2 = hrp.Position
    local ray_params_m3b = RaycastParams.new()
    ray_params_m3b.FilterDescendantsInstances = { localplayer.Character }
    ray_params_m3b.FilterType = Enum.RaycastFilterType.Exclude
    local surface_y2 = -2048
    local underground_cf2 = CFrame.new(cur_pos2.X, surface_y2, cur_pos2.Z)
    local snaps2 = math.clamp(config.void_counter_snap_count or 8, 1, 16)
    for _ = 1, snaps2 do
     kc_force_cf(hrp, underground_cf2)
    end
    local fire_target2 = head or t_hrp
    manipulation.fire_toward(fire_target2, target.Character)
    kc_nuke_fallen_parts()
   end)
  end)
 end
end

getgenv().stop_kicia_counter = function()
 kicia_counter_active = false
 config.kicia_counter_enabled = false
 if kicia_counter_conn then kicia_counter_conn:Disconnect(); kicia_counter_conn = nil end
 if kc_m1_child_added_conn then kc_m1_child_added_conn:Disconnect(); kc_m1_child_added_conn = nil end
 if kc_m1_child_removed_conn then kc_m1_child_removed_conn:Disconnect(); kc_m1_child_removed_conn = nil end
end

local nebula_counter_conn = nil
local nebula_counter_active = false
local nebula_counter_last_snap = 0

getgenv().start_nebula_counter = function()
 if nebula_counter_active then return end
 nebula_counter_active = true
 config.nebula_counter_enabled = true
 local _nbc2_projectiles = {}
 local _nbc2_child_added = workspace.ChildAdded:Connect(function(o)
  if not o:IsA("BasePart") then return end
  if o.Name == "CoreProjectile" then
   _nbc2_projectiles[o] = true
  elseif o.Name == "Part" then
   task.defer(function()
    if o and o.Parent and o.AssemblyLinearVelocity.Magnitude > 50 then
     _nbc2_projectiles[o] = true
    end
   end)
  end
 end)
 local _nbc2_child_removed = workspace.ChildRemoved:Connect(function(o)
  _nbc2_projectiles[o] = nil
 end)
 local _nbc2_target_pos = CFrame.new(9000, 9000, 9000)
 local _nbc2_hb_last = 0
 nebula_counter_conn = run_service.Heartbeat:Connect(function()
  if not config.nebula_counter_enabled then return end
  local now = tick()
  if now - _nbc2_hb_last < 0.033 then return end
  _nbc2_hb_last = now
  pcall(function()
   for _, p in pairs(players:GetPlayers()) do
    if p ~= localplayer and p.Character then
     local h = p.Character:FindFirstChild("HumanoidRootPart")
     if h then
      h.CFrame = _nbc2_target_pos
      h.AssemblyLinearVelocity = Vector3.zero
     end
    end
   end
   for p in pairs(_nbc2_projectiles) do
    if p and p.Parent then
     p.CFrame = _nbc2_target_pos
     p.AssemblyLinearVelocity = Vector3.zero
    else
     _nbc2_projectiles[p] = nil
    end
   end
  end)
 end)
 getgenv()._nbc2_child_added_conn = _nbc2_child_added
 getgenv()._nbc2_child_removed_conn = _nbc2_child_removed
end

getgenv().stop_nebula_counter = function()
 nebula_counter_active = false
 config.nebula_counter_enabled = false
 if nebula_counter_conn then nebula_counter_conn:Disconnect(); nebula_counter_conn = nil end
 if getgenv()._nbc2_child_added_conn then getgenv()._nbc2_child_added_conn:Disconnect(); getgenv()._nbc2_child_added_conn = nil end
 if getgenv()._nbc2_child_removed_conn then getgenv()._nbc2_child_removed_conn:Disconnect(); getgenv()._nbc2_child_removed_conn = nil end
end

local vs_conn, last_vs_pos = nil, nil
local vs_render_conn = nil

getgenv().stop_void_spam = function()
 if vs_conn then vs_conn:Disconnect(); vs_conn = nil end
 if vs_render_conn then vs_render_conn:Disconnect(); vs_render_conn = nil end
 config.void_spam_enabled = false
 last_vs_pos = nil

end

local evs_conn = nil
local evs_tick_acc = 0
local evs_phase = 0
local vs_spiral = 0
local vs_wave = 0
local vs_helix = 0
local vs_orbit_angle = 0
local vs_phase_hex = 0
local vs_phase_oct = 0
local vs_phase_star = 0
local vs_phase_cross = 0
local vs_phase_rhombus = 0

local function evs_get_direction_vec()
 local d = config.evs_axis or "Y"
 if d == "X" then return Vector3.new(1,0,0)
 elseif d == "Z" then return Vector3.new(0,0,1)
 elseif d == "XZ" then return Vector3.new(1,0,1).Unit
 elseif d == "XY" then return Vector3.new(1,1,0).Unit
 elseif d == "YZ" then return Vector3.new(0,1,1).Unit
 else return Vector3.new(0,1,0) end

end

local function evs_apply_falloff(dist, i, total)
 local mode = config.evs_falloff or "None"
 if mode == "Linear" then return dist * (1 - (i-1)/total)
 elseif mode == "Exp" then return dist * math.exp(-3*(i-1)/total)
 elseif mode == "Sine" then return dist * math.abs(math.sin((i-1)/total * math.pi))
 else return dist end

end

local function evs_compute_offset(i, total, base_dist, jitter, phase, freq, amp, spread)
 local pattern = config.evs_pattern or "Linear"
 local frac = (i-1)/total
 local j = jitter > 0 and Vector3.new((math.random()-0.5)*jitter,(math.random()-0.5)*jitter,(math.random()-0.5)*jitter) or Vector3.zero
 local dir = evs_get_direction_vec()
 local d = evs_apply_falloff(base_dist, i, total) * amp
 local _esx = (math.random() < 0.5) and 1 or -1
 local _esy = (math.random() < 0.5) and 1 or -1
 local _esz = (math.random() < 0.5) and 1 or -1
 if pattern == "Linear" then
 return Vector3.new(dir.X * d * _esx, dir.Y * d * _esy, dir.Z * d * _esz) + j
 elseif pattern == "Spiral" then
 local a = frac * math.pi * 2 * freq + phase
 local r = d * config.evs_orbit_radius / 50000
 return Vector3.new(math.cos(a)*r*_esx, d*_esy, math.sin(a)*r*_esz) + j
 elseif pattern == "Wave" then
 local a = frac * math.pi * 2 * freq + phase
 return Vector3.new(dir.X * d * amp * _esx, dir.Y * d * amp * _esy, dir.Z * d * amp * _esz) + Vector3.new(math.sin(a)*spread*_esx, 0, math.cos(a)*spread*_esz) + j
 elseif pattern == "Helix" then
 local a = frac * math.pi * 2 * freq * config.evs_spiral_tightness + phase
 local r = config.evs_orbit_radius / 10
 return Vector3.new(math.cos(a)*r*_esx, d*_esy, math.sin(a)*r*_esz) + j
 elseif pattern == "Chaos" then
 return Vector3.new((math.random()-0.5)*d*2*_esx, (math.random())*d*_esy, (math.random()-0.5)*d*2*_esz) + j
 elseif pattern == "Orbit" then
 local a = frac * math.pi * 2 * config.evs_orbit_speed / 5 + phase
 local r = config.evs_orbit_radius
 return Vector3.new(math.cos(a)*r*_esx, d*_esy, math.sin(a)*r*_esz) + j
 elseif pattern == "Pulse" then
 local pulse = math.abs(math.sin(frac * math.pi * freq + phase))
 return Vector3.new(dir.X * d * pulse * _esx, dir.Y * d * pulse * _esy, dir.Z * d * pulse * _esz) + j
 elseif pattern == "Stutter" then
 local s = (math.floor(frac * freq * 8) % 2 == 0) and 1 or -1
 return Vector3.new(dir.X * d * s * _esx, dir.Y * d * s * _esy, dir.Z * d * s * _esz) + j
 else
 return Vector3.new(dir.X * d * _esx, dir.Y * d * _esy, dir.Z * d * _esz) + j
 end

end

getgenv().stop_extra_voidspam = function()
 if evs_conn then evs_conn:Disconnect(); evs_conn = nil end

end

local vst_conn = nil
local vst_phase = "hide"
local vst_phase_start = 0
local vst_dt_buf = 0
local vst_last_pos = nil
local vst_pre_enable_cf = nil

local _movement_pre_cf = nil
local _movement_active_count = 0

local function _movement_save_pos()
 local hrp = getgenv().get_hrp(localplayer)
 if hrp and not _movement_pre_cf then
  _movement_pre_cf = hrp.CFrame
 end
 _movement_active_count = _movement_active_count + 1
end

local function _movement_restore_pos()
 _movement_active_count = math.max(0, _movement_active_count - 1)
 if _movement_active_count > 0 then return end
 local cf = _movement_pre_cf
 _movement_pre_cf = nil
 if not cf then return end
 local hrp = getgenv().get_hrp(localplayer)
 if not hrp then return end
 local hum = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")
 task.defer(function()
  pcall(function()
   if hum then hum:ChangeState(Enum.HumanoidStateType.Physics) end
   hrp.AssemblyLinearVelocity = Vector3.zero
   hrp.AssemblyAngularVelocity = Vector3.zero
   hrp.CFrame = cf
   local mt = getrawmetatable(hrp)
   local ni = mt and rawget(mt, "__newindex")
   if ni then
    pcall(ni, hrp, "CFrame", cf)
    pcall(ni, hrp, "AssemblyLinearVelocity", Vector3.zero)
   end
   if sethiddenproperty then
    pcall(sethiddenproperty, hrp, "CFrame", cf)
    pcall(sethiddenproperty, hrp, "AssemblyLinearVelocity", Vector3.zero)
   end
   if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
  end)
 end)
end
local void_spin_conn = nil
local _vdb_deep_y = nil
local _vdb_ascending = false

getgenv().start_voidspam_type = function()
 if vst_conn then vst_conn:Disconnect() end
 if void_spin_conn then void_spin_conn:Disconnect() end
 vst_phase = "hide"
 vst_phase_start = tick()
 vst_dt_buf = 0
 vst_last_pos = nil
 _movement_save_pos()
 local hrp0 = getgenv().get_hrp(localplayer)
 if hrp0 and not vst_pre_enable_cf then vst_pre_enable_cf = hrp0.CFrame end
 local _vst_hb_last = 0
 local _vst_burst_running = false
 vst_conn = run_service.Heartbeat:Connect(function(dt)
 if not config.void then return end
 local _vst_now_hb = tick()
 _vst_hb_last = _vst_now_hb
 pcall(function() workspace.FallenPartsDestroyHeight = -math.huge end)
 pcall(function() workspace.FallenPartsDestroyHeight = 0/0 end)
 local hrp = getgenv().get_hrp(localplayer)
 local hum = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")
 if not hrp or not hum or hum.Health <= 0 then return end
 local vtype = config.vst_type or "Defensive"
 if vtype ~= "Bait" then
  if hum:GetState() ~= Enum.HumanoidStateType.Physics then
   hum:ChangeState(Enum.HumanoidStateType.Physics)
  end
 end
 local _V0 = Vector3.zero
 local function vst_write_cf(cf)
  local mt = getrawmetatable(hrp)
  local ni = mt and rawget(mt, "__newindex")
  if ni then
   pcall(function() ni(hrp, "AssemblyLinearVelocity", _V0); ni(hrp, "AssemblyAngularVelocity", _V0); ni(hrp, "CFrame", cf) end)
  else
   pcall(function() hrp.AssemblyLinearVelocity = _V0; hrp.AssemblyAngularVelocity = _V0; hrp.CFrame = cf end)
  end
 end
 local function vst_do_proximity_evade()
  local my_pos = hrp.Position
  local threat_dist = math.huge
  local threat_hrp = nil
  local evade_threshold = math.max(config.vst_defend_proximity_radius or 50000000, 1000000)
  for _, p in ipairs(players:GetPlayers()) do
   if p ~= localplayer and p.Character then
    local t_hrp = p.Character:FindFirstChild("HumanoidRootPart")
    local t_hum = p.Character:FindFirstChildOfClass("Humanoid")
    local diff_team = localplayer.Team == nil or p.Team == nil or localplayer.Team ~= p.Team
    if t_hrp and t_hum and t_hum.Health > 0 and diff_team then
     local vel = t_hrp.AssemblyLinearVelocity
     local effective_dist = math.min((my_pos - t_hrp.Position).Magnitude, (my_pos - t_hrp.Position + vel * 0.15).Magnitude)
     if effective_dist < evade_threshold and effective_dist < threat_dist then
      threat_dist = effective_dist; threat_hrp = t_hrp
     end
    end
   end
  end
  if threat_hrp then
   local to_me = my_pos - threat_hrp.Position
   local evade_dir = to_me.Magnitude > 0.001 and to_me.Unit or Vector3.new(0, 0, -1)
   local escape_dist = math.max(config.vst_defend_escape_dist or 3000000, 1000000)
   vst_write_cf(CFrame.new(my_pos + evade_dir * escape_dist))
   notify("Evaded Target", "")
   vst_last_pos = hrp.Position
   return true
  end
  return false
 end
 local function vst_get_direction_offset(base_pos, dist)
  local pat = config.motion_pattern or "Broken Spiral"
  local spread = math.max(config.spread_distance or 50000, 1)

  local _my_pos_g = hrp and hrp.Position or base_pos
  local _nearest_enemy_d = math.huge
  for _, _p in ipairs(players:GetPlayers()) do
   if _p ~= localplayer and _p.Character then
    local _eh = _p.Character:FindFirstChild("HumanoidRootPart")
    if _eh then
     local _d = (_my_pos_g - _eh.Position).Magnitude
     if _d < _nearest_enemy_d then _nearest_enemy_d = _d end
    end
   end
  end

  if _nearest_enemy_d < 50 then spread = spread * 3
  elseif _nearest_enemy_d < 200 then spread = spread * 2
  elseif _nearest_enemy_d < 1000 then spread = spread * 1.5
  end
  local hj = config.horizontal_jitter or 0
  local vj = config.vertical_jitter or 0
  local s = vs_motion_step
  vs_motion_step = vs_motion_step + 1
  local t = (s % 65536) * 1.2732
  local sx = (math.random() < 0.5) and 1 or -1
  local sy = (math.random() < 0.5) and 1 or -1
  local sz = (math.random() < 0.5) and 1 or -1
  local hrand = hj > 0 and (math.random() - 0.5) * hj or 0
  local hrandz = hj > 0 and (math.random() - 0.5) * hj or 0
  local vrand = vj > 0 and (math.random() - 0.5) * vj or 0
  local x, y, z
  if pat == "Staggered Cross" then
   local arm = s % 4
   if arm == 0 then x = spread; y = spread * 0.3; z = 0
   elseif arm == 1 then x = 0; y = -spread * 0.3; z = spread
   elseif arm == 2 then x = -spread; y = spread * 0.3; z = 0
   else x = 0; y = -spread * 0.3; z = -spread end
  elseif pat == "Offset Pentagon" then
   local ang = (s % 5) * (2 * math.pi / 5) + math.pi * 0.1
   x = math.cos(ang) * spread; y = math.sin(ang * 1.3) * spread * 0.4; z = math.sin(ang) * spread
  elseif pat == "Asymmetric Wedge" then
   local side = s % 3
   if side == 0 then x = spread; y = spread * 0.7; z = spread * 0.2
   elseif side == 1 then x = -spread * 0.6; y = -spread * 0.5; z = spread * 0.9
   else x = spread * 0.1; y = spread * 0.3; z = -spread end
  elseif pat == "Broken Spiral" then
   local ang = t * 2.399
   local r = spread * (0.4 + (s % 7) * 0.09)
   x = math.cos(ang) * r; y = (s % 5 - 2) * spread * 0.2; z = math.sin(ang) * r
  elseif pat == "Shear Grid" then
   local gx = (s % 3) - 1
   local gz = math.floor(s / 3) % 3 - 1
   x = gx * spread + gz * spread * 0.4; y = sy * spread * 0.25; z = gz * spread
  elseif pat == "Offset Bowtie" then
   local phase = s % 4
   if phase == 0 then x = spread; y = spread * 0.5; z = spread * 0.5
   elseif phase == 1 then x = -spread; y = -spread * 0.5; z = spread * 0.5
   elseif phase == 2 then x = spread * 0.5; y = spread * 0.5; z = -spread
   else x = -spread * 0.5; y = -spread * 0.5; z = -spread end
  elseif pat == "Oblique Zigzag" then
   local even = s % 2 == 0
   x = (even and spread or -spread) + (s % 3 - 1) * spread * 0.3
   y = sy * spread * 0.35
   z = (s % 5 - 2) * spread * 0.4
  elseif pat == "Fractured Diamond" then
   local q = s % 8
   local ang = q * math.pi * 0.25 + (q % 3) * 0.7
   x = math.cos(ang) * spread; y = (q % 3 - 1) * spread * 0.5; z = math.sin(ang) * spread
  elseif pat == "Phase-Shifted Lemniscate" then
   local u = t * 1.5 + s * 0.4
   local denom = 1 + math.sin(u) * math.sin(u)
   x = spread * math.cos(u) / denom; y = sy * spread * 0.3; z = spread * math.sin(u) * math.cos(u) / denom
  elseif pat == "Alternating Trident" then
   local prong = s % 3
   if prong == 0 then x = 0; y = spread; z = spread * 0.15
   elseif prong == 1 then x = spread * 0.8; y = -spread * 0.5; z = spread * 0.15
   else x = -spread * 0.8; y = -spread * 0.5; z = spread * 0.15 end
   y = y + (s % 2 == 0 and spread * 0.6 or -spread * 0.6)
  elseif pat == "Skewed Hexagon" then
   local ang = (s % 6) * (math.pi / 3) + 0.3
   x = math.cos(ang) * spread + math.sin(ang) * spread * 0.2
   y = (s % 3 - 1) * spread * 0.35
   z = math.sin(ang) * spread
  elseif pat == "Bifurcated Sine" then
   local branch = s % 2 == 0 and 1 or -1
   x = (s % 9 - 4) * spread * 0.25
   y = math.sin(t) * spread * 0.6 * branch
   z = math.cos(t * 0.7) * spread * branch
  elseif pat == "Chaotic Lattice" then
   local lx = (s * 7) % 5 - 2
   local ly = (s * 3) % 4 - 2
   local lz = (s * 11) % 5 - 2
   x = lx * spread * 0.5; y = ly * spread * 0.35; z = lz * spread * 0.5
  elseif pat == "Sawtooth Orbit" then
   local frac = (s % 11) / 11
   local ang = frac * 2 * math.pi + math.floor(s / 11) * 1.1
   x = math.cos(ang) * spread * (0.3 + frac * 0.7)
   y = (frac - 0.5) * spread * 0.8
   z = math.sin(ang) * spread * (0.3 + frac * 0.7)
  elseif pat == "Rotary Offset Star" then
   local tip = s % 5
   local ang = tip * (2 * math.pi / 5) + math.floor(s / 5) * 0.4
   local r = (s % 2 == 0) and spread or spread * 0.45
   x = math.cos(ang) * r; y = sy * spread * 0.3; z = math.sin(ang) * r
  elseif pat == "Compressed Torus" then
   local u = t * 1.8; local v = t * 3.1
   x = (spread * 0.7 + spread * 0.3 * math.cos(v)) * math.cos(u)
   y = spread * 0.3 * math.sin(v) * 0.4
   z = (spread * 0.7 + spread * 0.3 * math.cos(v)) * math.sin(u)
  elseif pat == "Displaced Trefoil" then
   local u = t * 2
   x = math.sin(u) + 2 * math.sin(2 * u)
   y = math.cos(u) - 2 * math.cos(2 * u)
   z = -math.sin(3 * u)
   x = x * spread * 0.3; y = y * spread * 0.3; z = z * spread * 0.5
  elseif pat == "Inverted Chevron" then
   local row = math.floor(s / 3) % 4
   local col = s % 3 - 1
   x = col * spread * 0.6
   y = (row % 2 == 0 and -1 or 1) * spread * 0.5
   z = (math.abs(col) * 0.5 - 0.25) * spread * (row % 2 == 0 and 1 or -1)
  elseif pat == "Collapsed Octagon" then
   local ang = (s % 8) * (math.pi / 4) + (math.floor(s / 8) % 2) * (math.pi / 8)
   x = math.cos(ang) * spread; y = (math.floor(s / 8) % 3 - 1) * spread * 0.4; z = math.sin(ang) * spread * 0.55
  elseif pat == "Wobble Crown" then
   local ang = (s % 7) * (2 * math.pi / 7)
   local wobble = math.sin(ang * 3.5) * spread * 0.25
   x = math.cos(ang) * (spread + wobble)
   y = math.abs(math.sin(ang * 3.5)) * spread * 0.6 - spread * 0.15
   z = math.sin(ang) * (spread + wobble)
  elseif pat == "Anti-Diagonal Stripe" then
   local d = s % 6
   x = (d - 2.5) * spread * 0.35
   y = sy * spread * 0.45
   z = -(d - 2.5) * spread * 0.35 + (s % 3 - 1) * spread * 0.5
  elseif pat == "Split Parabola" then
   local half = s % 2 == 0 and 1 or -1
   local u = ((s % 9) - 4) * spread * 0.22
   x = u; y = half * (u * u / spread * 0.8 + spread * 0.1); z = half * spread * 0.6
  elseif pat == "Phase Jitter Ring" then
   local ang = (s % 12) * (math.pi / 6) + math.random() * 0.5
   x = math.cos(ang) * spread; y = (math.random() - 0.5) * spread * 0.7; z = math.sin(ang) * spread
  elseif pat == "Stochastic Radial" then
   local ang = math.random() * 2 * math.pi
   local r = spread * (0.3 + math.random() * 0.7)
   x = math.cos(ang) * r; y = sy * spread * (0.1 + math.random() * 0.6); z = math.sin(ang) * r
  elseif pat == "Recursive Triangle" then
   local depth = math.floor(s / 3) % 4
   local v2 = s % 3
   local scale = spread * (0.25 + depth * 0.2)
   if v2 == 0 then x = 0; y = scale; z = 0
   elseif v2 == 1 then x = scale * 0.87; y = -scale * 0.5; z = scale * 0.3
   else x = -scale * 0.87; y = -scale * 0.5; z = scale * 0.3 end
  elseif pat == "Sheared Oval" then
   local ang = (s % 10) * (2 * math.pi / 10)
   x = math.cos(ang) * spread + math.sin(ang) * spread * 0.5
   y = math.sin(ang * 2) * spread * 0.3
   z = math.sin(ang) * spread * 0.65
  elseif pat == "Axial Lurch" then
   local axis = s % 3
   local mag = spread * (0.5 + (s % 5) * 0.12)
   local sign = (s % 2 == 0) and 1 or -1
   if axis == 0 then x = sign * mag; y = sy * spread * 0.2; z = (math.random() - 0.5) * spread * 0.3
   elseif axis == 1 then x = (math.random() - 0.5) * spread * 0.3; y = sign * mag; z = (math.random() - 0.5) * spread * 0.3
   else x = (math.random() - 0.5) * spread * 0.3; y = sy * spread * 0.2; z = sign * mag end
  elseif pat == "Compound Rake" then
   local tooth = s % 7
   local row = math.floor(s / 7) % 3
   x = (tooth - 3) * spread * 0.3
   y = (row - 1) * spread * 0.5
   z = (tooth % 2 == 0 and 1 or -1) * spread * 0.6
  elseif pat == "Tangent Break" then
   local ang = t * 2.1
   local r = spread
   local flip = (s % 4 < 2) and 1 or -1
   x = math.cos(ang) * r; y = flip * math.abs(math.sin(ang)) * spread * 0.7; z = math.sin(ang) * r * flip
  elseif pat == "Glitch Burst" then
   local g = s % 5
   if g == 0 then x = sx * spread; y = sy * spread * 0.9; z = sz * spread * 0.1
   elseif g == 1 then x = sx * spread * 0.1; y = sy * spread; z = sz * spread * 0.9
   elseif g == 2 then x = sx * spread * 0.7; y = -sy * spread * 0.3; z = sz * spread * 0.7
   elseif g == 3 then x = -sx * spread * 0.4; y = sy * spread * 0.6; z = sx * spread * 0.8
   else x = sx * spread * 0.9; y = sy * spread * 0.1; z = -sz * spread end
  else
   x = sx * spread; y = sy * spread; z = sz * spread
  end
  x = x + hrand; y = y + vrand; z = z + hrandz
  return Vector3.new(x, y, z)
 end
 local _im_route_scores = {}
 local _im_route_cap = 64
 local _im_last_target_pos = nil
 local _im_target_vel = Vector3.zero
 local _im_vel_alpha = 0.25

 local _im_ring_head = 1
 local function im_record_good_route(pos)
  if typeof(pos) ~= "Vector3" then return end
  _im_route_scores[_im_ring_head] = pos
  _im_ring_head = (_im_ring_head % _im_route_cap) + 1
 end

 local function im_update_target_vel(tpos)
  if typeof(tpos) ~= "Vector3" then return end
  if _im_last_target_pos then
   local raw = tpos - _im_last_target_pos
   _im_target_vel = _im_target_vel + (raw - _im_target_vel) * _im_vel_alpha
  end
  _im_last_target_pos = tpos
 end

 local _TP_REACH_MIN   = 40000000
 local _TP_REACH_SCALE = 3.5
 local _TP_PENALTY_MUL = 12.0
 local _TP_HISTORY_NEAR = 200000000

 local function im_estimate_tp_reach(ref_tpos)
  local vx, vy, vz = _im_target_vel.X, _im_target_vel.Y, _im_target_vel.Z
  local speed = math.sqrt(vx*vx + vy*vy + vz*vz)
  local base = math.max(_TP_REACH_MIN, speed * _TP_REACH_SCALE)
  if ref_tpos then
   local pred3 = ref_tpos + _im_target_vel * 3
   local ex = pred3.X - ref_tpos.X
   local ey = pred3.Y - ref_tpos.Y
   local ez = pred3.Z - ref_tpos.Z
   local predicted_range = math.sqrt(ex*ex + ey*ey + ez*ez) * 2
   base = math.max(base, predicted_range)
  end
  return base
 end

 local function im_score_pos(pos, tpos, mode)
  if typeof(pos) ~= "Vector3" or typeof(tpos) ~= "Vector3" then return 0 end
  local dx = pos.X - tpos.X
  local dy = pos.Y - tpos.Y
  local dz = pos.Z - tpos.Z
  local dist = math.sqrt(dx*dx + dy*dy + dz*dz)
  local score = dist

  local tp_reach = im_estimate_tp_reach(tpos)
  if dist < tp_reach then
   local ratio = 1 - (dist / tp_reach)
   score = score - (tp_reach * _TP_PENALTY_MUL * ratio * ratio)
  end

  local history_penalty_scale = (mode == "Adaptive" or mode == "Hybrid") and 2.5 or 1.0
  for _, r in ipairs(_im_route_scores) do
   local bx = pos.X - r.X; local by = pos.Y - r.Y; local bz = pos.Z - r.Z
   local bd = math.sqrt(bx*bx + by*by + bz*bz)
   if bd < _TP_HISTORY_NEAR then
    score = score + (_TP_HISTORY_NEAR - bd) * history_penalty_scale
   end
  end

  if mode == "Predictive" or mode == "Hybrid" then
   local lookahead = mode == "Hybrid" and 5 or 7
   local pred = tpos + _im_target_vel * lookahead
   local px = pos.X - pred.X; local py = pos.Y - pred.Y; local pz = pos.Z - pred.Z
   local pred_dist = math.sqrt(px*px + py*py + pz*pz)
   local pred_weight = mode == "Hybrid" and 0.8 or 1.0
   score = score + pred_dist * pred_weight
   local pred_tp_reach = math.max(tp_reach, im_estimate_tp_reach(tpos) * 1.5)
   if pred_dist < pred_tp_reach then
    local ratio = 1 - (pred_dist / pred_tp_reach)
    score = score - (pred_tp_reach * _TP_PENALTY_MUL * ratio * ratio * pred_weight)
   end
   local pred2 = tpos + _im_target_vel * (lookahead * 2)
   local p2x = pos.X - pred2.X; local p2y = pos.Y - pred2.Y; local p2z = pos.Z - pred2.Z
   local pred2_dist = math.sqrt(p2x*p2x + p2y*p2y + p2z*p2z)
   if pred2_dist < pred_tp_reach then
    local ratio2 = 1 - (pred2_dist / pred_tp_reach)
    score = score - (pred_tp_reach * _TP_PENALTY_MUL * 0.4 * ratio2 * ratio2)
   end
  end
  return score
 end

 local function im_get_target_pos()
  local tgt = nil
  local best_dist = math.huge
  local lp_pos = hrp and hrp.Position
  if not lp_pos then return nil end
  for _, p in ipairs(players:GetPlayers()) do
   if p ~= localplayer and p.Character then
    local th = p.Character:FindFirstChild("HumanoidRootPart")
    if th then
     local d = (th.Position - lp_pos).Magnitude
     if d < best_dist then best_dist = d; tgt = th.Position end
    end
   end
  end
  return tgt
 end

 local function im_pick_best(candidates, mode)
  if not candidates or #candidates == 0 then return nil end
  local tpos = im_get_target_pos()
  if not tpos then return candidates[1] end
  if mode == "Predictive" or mode == "Hybrid" then im_update_target_vel(tpos) end
  local best_pos = nil
  local best_score = -math.huge
  for _, pos in ipairs(candidates) do
   local s = im_score_pos(pos, tpos, mode)
   if s > best_score then best_score = s; best_pos = pos end
  end
  if best_pos then im_record_good_route(best_pos) end
  return best_pos
 end

 getgenv().__im_pick_best = im_pick_best

 local _vdb_prev_x, _vdb_prev_y, _vdb_prev_z = nil, nil, nil
 local _vdb_tvel_x, _vdb_tvel_y, _vdb_tvel_z = 0, 0, 0
 local _vdb_last_tpos_x, _vdb_last_tpos_y, _vdb_last_tpos_z = nil, nil, nil
 local _vdb_route_ring = {}
 local _vdb_route_head = 1
 local _VDB_ROUTE_CAP = 96
 local _VDB_TP_SAFE_MULT = 4.5
 local _VDB_TP_BASE_REACH = 55000000
 local _VDB_AVOID_HISTORY_RADIUS = 300000000
 local function _vdb_get_tpos()
  local best_pos = nil
  local best_d = math.huge
  local my_pos = hrp.Position
  for _, p in ipairs(players:GetPlayers()) do
   if p ~= localplayer and p.Character then
    local th = p.Character:FindFirstChild("HumanoidRootPart")
    local hum2 = p.Character:FindFirstChildOfClass("Humanoid")
    if th and hum2 and hum2.Health > 0 then
     local d = (th.Position - my_pos).Magnitude
     if d < best_d then best_d = d; best_pos = th.Position end
    end
   end
  end
  return best_pos
 end

 local function _vdb_update_tvel(tpos)
  if not tpos then return end
  if _vdb_last_tpos_x then
   local raw_x = tpos.X - _vdb_last_tpos_x
   local raw_y = tpos.Y - _vdb_last_tpos_y
   local raw_z = tpos.Z - _vdb_last_tpos_z
   local alpha = 0.3
   _vdb_tvel_x = _vdb_tvel_x + (raw_x - _vdb_tvel_x) * alpha
   _vdb_tvel_y = _vdb_tvel_y + (raw_y - _vdb_tvel_y) * alpha
   _vdb_tvel_z = _vdb_tvel_z + (raw_z - _vdb_tvel_z) * alpha
  end
  _vdb_last_tpos_x = tpos.X
  _vdb_last_tpos_y = tpos.Y
  _vdb_last_tpos_z = tpos.Z
 end

 local function _vdb_tp_reach()
  local spd = math.sqrt(_vdb_tvel_x*_vdb_tvel_x + _vdb_tvel_y*_vdb_tvel_y + _vdb_tvel_z*_vdb_tvel_z)
  return math.max(_VDB_TP_BASE_REACH, spd * 4.0)
 end

 local function _vdb_record(x, y, z)
  _vdb_route_ring[_vdb_route_head] = {x, y, z}
  _vdb_route_head = (_vdb_route_head % _VDB_ROUTE_CAP) + 1
 end

 local function _vdb_score(cx, cy, cz, tpos, tp_reach, prev_x, prev_y, prev_z)
  if not tt_ok3(cx, cy, cz) then return -1e18 end
  local score = 0
  if tpos then
   local dx = cx - tpos.X
   local dy = cy - tpos.Y
   local dz = cz - tpos.Z
   local dist_to_t = math.sqrt(dx*dx + dy*dy + dz*dz)
   local safe_dist = tp_reach * _VDB_TP_SAFE_MULT
   if dist_to_t < safe_dist then
    score = score - (safe_dist - dist_to_t) * 6.0
   else
    score = score + math.min((dist_to_t - safe_dist) / safe_dist, 1) * 80
   end
   local pred1_x = tpos.X + _vdb_tvel_x * 5
   local pred1_y = tpos.Y + _vdb_tvel_y * 5
   local pred1_z = tpos.Z + _vdb_tvel_z * 5
   local p1x = cx - pred1_x; local p1y = cy - pred1_y; local p1z = cz - pred1_z
   local pred1_dist = math.sqrt(p1x*p1x + p1y*p1y + p1z*p1z)
   local pred_reach = tp_reach * (_VDB_TP_SAFE_MULT * 1.3)
   if pred1_dist < pred_reach then
    score = score - (pred_reach - pred1_dist) * 4.5
   else
    score = score + math.min((pred1_dist - pred_reach) / pred_reach, 1) * 50
   end
   local pred2_x = tpos.X + _vdb_tvel_x * 12
   local pred2_y = tpos.Y + _vdb_tvel_y * 12
   local pred2_z = tpos.Z + _vdb_tvel_z * 12
   local p2x = cx - pred2_x; local p2y = cy - pred2_y; local p2z = cz - pred2_z
   local pred2_dist = math.sqrt(p2x*p2x + p2y*p2y + p2z*p2z)
   if pred2_dist < pred_reach then
    score = score - (pred_reach - pred2_dist) * 2.5
   end
  end
  local step_x = cx - prev_x; local step_y = cy - prev_y; local step_z = cz - prev_z
  local step_dist = math.sqrt(step_x*step_x + step_y*step_y + step_z*step_z)
  score = score + math.min(step_dist / 25000000, 1) * 60
  for i = 1, math.min(#_vdb_route_ring, _VDB_ROUTE_CAP) do
   local r = _vdb_route_ring[i]
   if r then
    local rx = cx - r[1]; local ry = cy - r[2]; local rz = cz - r[3]
    local rdist = math.sqrt(rx*rx + ry*ry + rz*rz)
    if rdist < _VDB_AVOID_HISTORY_RADIUS then
     score = score - (_VDB_AVOID_HISTORY_RADIUS - rdist) * 2.5
    end
   end
  end
  local abs_y = math.abs(cy)
  if abs_y > 80000000 then score = score + math.min(abs_y / 800000000, 1) * 40 end
  return score
 end

 local function vst_do_defend_burst()
 getgenv().__cvs_defend_burst = vst_do_defend_burst
 if vst_do_proximity_evade() then return end
 local _ws_mt = getrawmetatable(workspace)
 local _ws_ni = _ws_mt and rawget(_ws_mt, "__newindex")
 local function _vdb_guard_fallen()
  if _ws_ni then pcall(_ws_ni, workspace, "FallenPartsDestroyHeight", -math.huge)
  else pcall(function() workspace.FallenPartsDestroyHeight = -math.huge end) end
 end
 _vdb_guard_fallen()
 local _my_char = localplayer.Character
 local _my_hum = _my_char and _my_char:FindFirstChildOfClass("Humanoid")
 if _my_hum and _my_hum.Health <= 0 then return end
 local function _vdb_guard_hum()
  local _hum2 = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")
  if _hum2 then
   if _hum2.Health <= 0 then
    pcall(function() _hum2.Health = _hum2.MaxHealth end)
    pcall(function()
     local mt_h = getrawmetatable(_hum2)
     local ni_h = mt_h and rawget(mt_h, "__newindex")
     if ni_h then ni_h(_hum2, "Health", _hum2.MaxHealth) end
    end)
   end
   pcall(function() _hum2:ChangeState(Enum.HumanoidStateType.Physics) end)
  end
  _vdb_guard_fallen()
 end
 local iters = math.max(config.evs_iter_count or 200, 1)
 if iters > 500 then iters = 500 end
 local mt_vdb = getrawmetatable(hrp)
 local ni_vdb = mt_vdb and rawget(mt_vdb, "__newindex")
 local use_x = config.enable_x_axis ~= false
 local use_y = config.enable_y_axis ~= false
 local use_z = config.enable_z_axis ~= false
 local _hrp_pos = hrp.Position
 local origin_x, origin_y, origin_z = _hrp_pos.X, _hrp_pos.Y, _hrp_pos.Z
 if not _vdb_deep_y then _vdb_deep_y = origin_y; _vdb_ascending = false end
 local _VDB_CHAIN_MIN = 25000000
 local _VDB_CHAIN_MAX = 30000000
 local _pos_rx = math.max(config.evs_x_radius or 0, 0)
 local _pos_ry = math.max(config.evs_y_radius or 0, 0)
 local _pos_rz = math.max(config.evs_z_radius or 0, 0)
 if _pos_rx > 0 then origin_x = origin_x + (math.random() < 0.5 and _pos_rx or -_pos_rx) end
 if _pos_ry > 0 then origin_y = origin_y + (math.random() < 0.5 and _pos_ry or -_pos_ry) end
 if _pos_rz > 0 then origin_z = origin_z + (math.random() < 0.5 and _pos_rz or -_pos_rz) end
 local _iter_rx = math.max(config.evs_x_radius or 0, 0)
 local _iter_ry = math.max(config.evs_y_radius or 0, 0)
 local _iter_rz = math.max(config.evs_z_radius or 0, 0)
 _vdb_prev_x = _vdb_prev_x or origin_x
 _vdb_prev_y = _vdb_prev_y or origin_y
 _vdb_prev_z = _vdb_prev_z or origin_z
 local _prev_x, _prev_y, _prev_z = _vdb_prev_x, _vdb_prev_y, _vdb_prev_z
 local _rnd = math.random
 local _cf  = CFrame.new
 local tpos = _vdb_get_tpos()
 _vdb_update_tvel(tpos)
 local tp_reach = _vdb_tp_reach()
 local _CAND_COUNT = 16
 local function _vdb_pick_dir_for_step(px, py, pz)
  local best_score = -1e18
  local best_nx, best_ny, best_nz = px, py, pz
  for _ = 1, _CAND_COUNT do
   local dist = _VDB_CHAIN_MIN + _rnd() * (_VDB_CHAIN_MAX - _VDB_CHAIN_MIN)
   local sx = _rnd() < 0.5 and 1 or -1
   local sy = _rnd() < 0.5 and 1 or -1
   local sz = _rnd() < 0.5 and 1 or -1
   local rx_j = _iter_rx > 0 and (_iter_rx * (0.5 + _rnd() * 0.5) * (_rnd() < 0.5 and 1 or -1)) or 0
   local ry_j = _iter_ry > 0 and (_iter_ry * (0.5 + _rnd() * 0.5) * (_rnd() < 0.5 and 1 or -1)) or 0
   local rz_j = _iter_rz > 0 and (_iter_rz * (0.5 + _rnd() * 0.5) * (_rnd() < 0.5 and 1 or -1)) or 0
   local cx = use_x and (px + sx * dist + rx_j) or px
   local cy = use_y and (py + sy * dist + ry_j) or py
   local cz = use_z and (pz + sz * dist + rz_j) or pz
   local sc = _vdb_score(cx, cy, cz, tpos, tp_reach, px, py, pz)
   if sc > best_score then
    best_score = sc
    best_nx = cx; best_ny = cy; best_nz = cz
   end
  end
  return best_nx, best_ny, best_nz
 end
 local _phase_iters = math.floor(iters / 3)
 if ni_vdb then
  pcall(function()
   for i = 1, iters do
    local nx, ny, nz
    if i <= _phase_iters then
     nx, ny, nz = _vdb_pick_dir_for_step(_prev_x, _prev_y, _prev_z)
    elseif i <= _phase_iters * 2 then
     local dist = _VDB_CHAIN_MIN + _rnd() * (_VDB_CHAIN_MAX - _VDB_CHAIN_MIN)
     local sx = _rnd() < 0.5 and 1 or -1
     local sy = _rnd() < 0.5 and 1 or -1
     local sz = _rnd() < 0.5 and 1 or -1
     nx = use_x and (_prev_x + sx * dist) or _prev_x
     ny = use_y and (_prev_y + sy * dist) or _prev_y
     nz = use_z and (_prev_z + sz * dist) or _prev_z
     if tpos then
      local dx = nx - tpos.X; local dy2 = ny - tpos.Y; local dz = nz - tpos.Z
      local d2t = math.sqrt(dx*dx + dy2*dy2 + dz*dz)
      if d2t < tp_reach * _VDB_TP_SAFE_MULT then
       nx, ny, nz = _vdb_pick_dir_for_step(_prev_x, _prev_y, _prev_z)
      end
     end
    else
     nx, ny, nz = _vdb_pick_dir_for_step(_prev_x, _prev_y, _prev_z)
    end
    if not tt_ok3(nx, ny, nz) then nx, ny, nz = _prev_x, _prev_y, _prev_z end
    ni_vdb(hrp, "AssemblyLinearVelocity", _V0)
    ni_vdb(hrp, "CFrame", _cf(nx, ny, nz))
    _prev_x, _prev_y, _prev_z = nx, ny, nz
    if i % 32 == 0 then _vdb_record(nx, ny, nz) end
   end
   ni_vdb(hrp, "AssemblyLinearVelocity", _V0)
   ni_vdb(hrp, "AssemblyAngularVelocity", _V0)
  end)
 else
  pcall(function()
   for i = 1, iters do
    local nx, ny, nz
    if i <= _phase_iters then
     nx, ny, nz = _vdb_pick_dir_for_step(_prev_x, _prev_y, _prev_z)
    elseif i <= _phase_iters * 2 then
     local dist = _VDB_CHAIN_MIN + _rnd() * (_VDB_CHAIN_MAX - _VDB_CHAIN_MIN)
     local sx = _rnd() < 0.5 and 1 or -1
     local sy = _rnd() < 0.5 and 1 or -1
     local sz = _rnd() < 0.5 and 1 or -1
     nx = use_x and (_prev_x + sx * dist) or _prev_x
     ny = use_y and (_prev_y + sy * dist) or _prev_y
     nz = use_z and (_prev_z + sz * dist) or _prev_z
     if tpos then
      local dx = nx - tpos.X; local dy2 = ny - tpos.Y; local dz = nz - tpos.Z
      local d2t = math.sqrt(dx*dx + dy2*dy2 + dz*dz)
      if d2t < tp_reach * _VDB_TP_SAFE_MULT then
       nx, ny, nz = _vdb_pick_dir_for_step(_prev_x, _prev_y, _prev_z)
      end
     end
    else
     nx, ny, nz = _vdb_pick_dir_for_step(_prev_x, _prev_y, _prev_z)
    end
    if not tt_ok3(nx, ny, nz) then nx, ny, nz = _prev_x, _prev_y, _prev_z end
    hrp.AssemblyLinearVelocity = _V0
    hrp.CFrame = _cf(nx, ny, nz)
    _prev_x, _prev_y, _prev_z = nx, ny, nz
    if i % 32 == 0 then _vdb_record(nx, ny, nz) end
   end
   hrp.AssemblyLinearVelocity = _V0
   hrp.AssemblyAngularVelocity = _V0
  end)
 end
 _vdb_prev_x, _vdb_prev_y, _vdb_prev_z = _prev_x, _prev_y, _prev_z
 _vdb_record(_prev_x, _prev_y, _prev_z)
 _vdb_guard_fallen()
 _vdb_guard_hum()
 do
  pcall(function()
   local _rb_char = localplayer.Character
   if not _rb_char then return end
   local _rb_item = _rb_char:FindFirstChild("EquippedItem")
   if not _rb_item then return end
   local _rb_tgt_char = nil
   local _rb_tgt_head = nil
   local _rb_tgt_hrp = nil
   local _rb_best_d = math.huge
   local _rb_my_pos = hrp.Position
   for _, _rb_p in ipairs(players:GetPlayers()) do
    if _rb_p ~= localplayer and _rb_p.Character then
     local _rb_ph = _rb_p.Character:FindFirstChild("Head")
     local _rb_pr = _rb_p.Character:FindFirstChild("HumanoidRootPart")
     local _rb_hm = _rb_p.Character:FindFirstChildOfClass("Humanoid")
     local _rb_ff = not _rb_p.Character:FindFirstChildOfClass("ForceField")
     local _rb_dt = localplayer.Team == nil or _rb_p.Team == nil or localplayer.Team ~= _rb_p.Team
     if _rb_ph and _rb_pr and _rb_hm and _rb_hm.Health > 0 and _rb_ff and _rb_dt then
      local _rb_d = (_rb_pr.Position - _rb_my_pos).Magnitude
      if _rb_d < _rb_best_d then
       _rb_best_d = _rb_d
       _rb_tgt_char = _rb_p.Character
       _rb_tgt_head = _rb_ph
       _rb_tgt_hrp  = _rb_pr
      end
     end
    end
   end
   if not _rb_tgt_char then return end
   local _rb_fire_part = _rb_tgt_head or _rb_tgt_hrp
   if not _rb_fire_part then return end
   local _rb_pos = _rb_fire_part.Position + Vector3.new((_rnd()-0.5)*0.7, (_rnd()-0.5)*0.7, (_rnd()-0.5)*0.7)
   local _rb_rs = game:GetService("ReplicatedStorage")
   local _rb_http = game:GetService("HttpService")
   local _rb_util_ok, _rb_util = pcall(require, _rb_rs.Modules.Utility)
   local _rb_enm_ok, _rb_enm  = pcall(require, _rb_rs.Modules.EnumLibrary)
   local _rb_fok,  _rb_fc     = pcall(require, localplayer.PlayerScripts.Controllers.FighterController)
   if _rb_util_ok and _rb_enm_ok and _rb_fok and _rb_fc and _rb_fc.LocalFighter then
    local _rb_lf   = _rb_fc.LocalFighter
    local _rb_litem = _rb_lf.EquippedItem
    if _rb_litem then
     local _rb_cam = workspace.CurrentCamera.CFrame
     local _rb_shoot_cf = CFrame.new(_rb_pos) * CFrame.Angles(CFrame.lookAt(_rb_cam.Position, _rb_pos):ToOrientation())
     local _rb_camdata = {}
     _rb_camdata[utf8.char(1)] = {
      [utf8.char(0)] = _rb_util:EncodeCFrame(_rb_shoot_cf),
      [utf8.char(1)] = _rb_util:EncodeCFrame(CFrame.new(_rb_pos) * CFrame.Angles(CFrame.lookAt(_rb_cam.Position, _rb_pos):ToOrientation())),
      [utf8.char(2)] = _rb_fire_part,
      [utf8.char(3)] = _rb_util:EncodeCFrame(_rb_fire_part.CFrame:ToObjectSpace(CFrame.new(_rb_pos))),
     }
     pcall(function()
      _rb_rs.Remotes.Replication.Fighter.UseItem:FireServer(_rb_litem:Get("ObjectID"), _rb_enm:ToEnum("StartShooting"), _rb_camdata, nil)
     end)
     getgenv().__rb_atk_num = (getgenv().__rb_atk_num or 0) + 1
    end
   else
    local _rb_remote_ok, _rb_remote = pcall(function()
     return _rb_rs:FindFirstChild("Remotes") and _rb_rs.Remotes:FindFirstChild("Fighter") and _rb_rs.Remotes.Fighter:FindFirstChild("UseItem")
    end)
    if _rb_remote_ok and _rb_remote then
     pcall(function()
      _rb_remote:FireServer({
       id      = _rb_http:GenerateGUID(false),
       objectId = _rb_http:GenerateGUID(false),
       item    = _rb_item.Name,
       position = _rb_pos,
       attackNum = (getgenv().__rb_atk_num or 0) + 1,
       one     = Vector3.one,
       packed  = {"\x00", "\x01", "\x02", "\x03"},
      })
      getgenv().__rb_atk_num = (getgenv().__rb_atk_num or 0) + 1
     end)
    end
   end
  end)
 end
 end
 local function vst_do_hide_burst()
  pcall(function() workspace.FallenPartsDestroyHeight = -math.huge end)
  vst_write_cf(CFrame.new(0, 0, 0))
 end
 local _vst_now = tick()
 do
  local _vst_true_cf = _dsync_read_true_cf(hrp)
  if _vst_true_cf then _dsync_record_pos(_vst_true_cf) end
 end
 if vtype == "Defensive" then
 if not _vst_burst_running then
  _vst_burst_running = true
  task.spawn(function()
   if config.vst_auto_kill then
    getgenv().start_ragebot_bypass_partglue()
   else
    vst_do_defend_burst()
    local _my_hrp_r = getgenv().get_hrp(localplayer)
    if _my_hrp_r then
     local mt_def = getrawmetatable(_my_hrp_r)
     local ni_def = mt_def and rawget(mt_def, "__newindex")
     if ni_def then
      pcall(ni_def, _my_hrp_r, "AssemblyLinearVelocity", _V0)
      pcall(ni_def, _my_hrp_r, "AssemblyAngularVelocity", _V0)
     else
      pcall(function() _my_hrp_r.AssemblyLinearVelocity = _V0; _my_hrp_r.AssemblyAngularVelocity = _V0 end)
     end
    end
    local _def_fire_part, _def_target_char = manipulation.get_closest()
    if _def_fire_part and _def_target_char then
     pcall(function()
      local _def_rs = game:GetService("ReplicatedStorage")
      local _def_fighter_ok, _def_fighter = pcall(require, localplayer.PlayerScripts.Controllers.FighterController)
      if not _def_fighter_ok or not _def_fighter.LocalFighter then return end
      local _def_item = _def_fighter.LocalFighter.EquippedItem
      if not _def_item then return end
      manipulation.fire_toward(_def_fire_part, _def_target_char)
     end)
    end
   end
   _vst_burst_running = false
  end)
 end
 elseif vtype == "Attack" then
 if not _vst_burst_running then
  _vst_burst_running = true
  task.spawn(function()
   local atk_target
   do
    local sel = config.vst_attack_target_name
    if sel and sel ~= "" and sel ~= "Closest" then
     local sp = players:FindFirstChild(sel)
     if sp and sp ~= localplayer and sp.Character then
      local sh = sp.Character:FindFirstChildOfClass("Humanoid")
      local sff = not sp.Character:FindFirstChildOfClass("ForceField")
      if sh and sh.Health > 0 and sff then atk_target = sp end
     end
    end
    if not atk_target then atk_target = getgenv().get_closest(true) end
   end
   if atk_target and atk_target.Character then
    local at_hrp  = atk_target.Character:FindFirstChild("HumanoidRootPart")
    local at_head = atk_target.Character:FindFirstChild("Head")
    if at_hrp then
     local vst_atk_lkg = nil
     local function vst_atk_nan(v) return v ~= v end
     local function vst_atk_inf(v) return math.abs(v) == math.huge end
     local function vst_atk_okv(v) return v and not vst_atk_nan(v.X) and not vst_atk_nan(v.Y) and not vst_atk_nan(v.Z) and not vst_atk_inf(v.X) and not vst_atk_inf(v.Y) and not vst_atk_inf(v.Z) end
     local function vst_atk_read(part)
      if not part then return nil end
      local cf
      pcall(function()
       local mt = getrawmetatable(part)
       local ri = mt and rawget(mt, "__index")
       if ri then cf = ri(part, "CFrame") end
      end)
      if cf and vst_atk_okv(cf.Position) then return cf.Position end
      pcall(function() if gethiddenproperty then local v = gethiddenproperty(part, "CFrame"); if v and vst_atk_okv(v.Position) then cf = v end end end)
      if cf and vst_atk_okv(cf.Position) then return cf.Position end
      local ok, raw = pcall(function() return part.CFrame end)
      if ok and raw and vst_atk_okv(raw.Position) then return raw.Position end
      return nil
     end
     local function vst_atk_sample()
      local p = vst_atk_read(at_hrp)
      if p then vst_atk_lkg = p; return end
      if at_head then
       local ph = vst_atk_read(at_head)
       if ph then vst_atk_lkg = ph end
      end
     end
     local function vst_atk_get_best()
      local raw = vst_atk_read(at_hrp)
      if raw and vst_atk_okv(raw) then return raw end
      if at_head then
       local rh = vst_atk_read(at_head)
       if rh and vst_atk_okv(rh) then return rh end
      end
      if vst_atk_lkg and vst_atk_okv(vst_atk_lkg) then return vst_atk_lkg end
      return nil
     end
     local function vst_atk_force(my_hrp, dest_cf)
      tt_write(my_hrp, dest_cf)
     end
     local rs2 = game:GetService("ReplicatedStorage")
     local _util2, _enums2, _fighter2
     pcall(function()
      local u_ok, u = pcall(require, rs2.Modules.Utility)
      local e_ok, e = pcall(require, rs2.Modules.EnumLibrary)
      local f_ok, f = pcall(require, localplayer.PlayerScripts.Controllers.FighterController)
      if u_ok then _util2 = u end
      if e_ok then _enums2 = e end
      if f_ok then _fighter2 = f end
     end)
     local vst_atk_start    = tick()
     local vst_atk_duration = 0.25
     local vst_atk_hb_last  = 0
     local vst_atk_hb_c
     vst_atk_hb_c = run_service.Heartbeat:Connect(function()
      if tick() - vst_atk_start > vst_atk_duration then
       vst_atk_hb_c:Disconnect()
       _vst_burst_running = false
       return
      end
      local now = tick()
      if now - vst_atk_hb_last < 0.016 then return end
      vst_atk_hb_last = now
      vst_atk_sample()
      local dest = vst_atk_get_best()
      if not dest or not vst_atk_okv(dest) then return end
      local my_hrp = getgenv().get_hrp(localplayer)
      local my_hum = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")
      if not my_hrp or not my_hum or my_hum.Health <= 0 then return end
      local dest_cf = CFrame.new(dest)
      pcall(function() my_hum:ChangeState(Enum.HumanoidStateType.Physics) end)
      pcall(function() my_hum.PlatformStand = false end)
      pcall(function() my_hum.AutoRotate = false end)
      pcall(function() workspace.FallenPartsDestroyHeight = -math.huge end)
      pcall(function() workspace.FallenPartsDestroyHeight = 0/0 end)
      pcall(function()
       local mt_w = getrawmetatable(workspace)
       if mt_w then
        local ni_w = rawget(mt_w, "__newindex")
        if ni_w then
         ni_w(workspace, "FallenPartsDestroyHeight", -math.huge)
         pcall(function() ni_w(workspace, "FallenPartsDestroyHeight", 0/0) end)
        end
       end
      end)
      local snaps = math.clamp(config.glue_snap_count or 4, 1, 16)
      for _ = 1, snaps do vst_atk_force(my_hrp, dest_cf) end
      pcall(function()
       if not _util2 or not _enums2 or not _fighter2 then return end
       if not _fighter2.LocalFighter then return end
       local item2 = _fighter2.LocalFighter.EquippedItem
       if not item2 then return end
       local fire_part = at_head or at_hrp
       local cam2 = workspace.CurrentCamera.CFrame
       local manip_pt2, height2 = manipulation.calculate_point(cam2.Position, fire_part.Position, atk_target.Character)
       if not manip_pt2 then return end
       local shoot_pos2 = (height2 == nil and manip_pt2) or cam2.Position
       local cameradata2 = {}
       cameradata2[utf8.char(1)] = {
        [utf8.char(0)] = _util2:EncodeCFrame(CFrame.new(shoot_pos2.X, shoot_pos2.Y + (height2 or 0), shoot_pos2.Z) * CFrame.Angles(CFrame.lookAt(shoot_pos2, fire_part.Position):ToOrientation())),
        [utf8.char(1)] = height2 and _util2:EncodeCFrame(CFrame.new(fire_part.Position) * CFrame.Angles(CFrame.lookAt(shoot_pos2, fire_part.Position):ToOrientation())) or _util2:EncodeCFrame(CFrame.new(shoot_pos2.X, shoot_pos2.Y + (height2 or 0), shoot_pos2.Z) * CFrame.Angles(CFrame.lookAt(shoot_pos2, fire_part.Position):ToOrientation())),
        [utf8.char(2)] = fire_part,
        [utf8.char(3)] = _util2:EncodeCFrame(fire_part.CFrame:ToObjectSpace(CFrame.new(fire_part.Position))),
       }
       rs2.Remotes.Replication.Fighter.UseItem:FireServer(item2:Get("ObjectID"), _enums2:ToEnum("StartShooting"), cameradata2, nil)
      end)
     end)
    end
   end
   _vst_burst_running = false
  end)
 end
 elseif vtype == "Kill" then
 if not _vst_burst_running then
  _vst_burst_running = true
  task.spawn(function()
   local _kill_waveT = 0
   local _kill_altVert = 1
   local _kill_pulseT = 0
   local _kill_pingPongDir = 1
   local _kill_acc = 0
   local _kill_last = tick()
   local _kill_conn
   _kill_conn = run_service.Heartbeat:Connect(function(dt)
    if not config.void or config.vst_type ~= "Kill" then
     _kill_conn:Disconnect()
     _vst_burst_running = false
     return
    end
    local _kroot = getgenv().get_hrp(localplayer)
    if not _kroot then return end
    local _kmt = getrawmetatable(_kroot)
    local _kni = _kmt and rawget(_kmt, "AssemblyLinearVelocity" and "__newindex")
    local _kmt2 = getrawmetatable(_kroot)
    local _kni2 = _kmt2 and rawget(_kmt2, "__newindex")
    local _krealCF = _kroot.CFrame
    _kill_acc = _kill_acc + dt
    local _kinterval = 1 / 512
    if _kill_acc < _kinterval then return end
    _kill_acc = _kill_acc % _kinterval
    local _kbase = _krealCF.Position
    local _klayers = 10
    local _kburst = 10
    for _kb = 1, _kburst do
     for _ki = 1, _klayers do
      local _kd = 1e15
      _kill_waveT = _kill_waveT + 0.01
      _kd = _kd + math.sin(_kill_waveT * 2 * 2 * math.pi) * 1e11
      _kill_pulseT = _kill_pulseT + 0.01
      _kd = _kd + math.sin(_kill_pulseT * 1 * 2 * math.pi) * 1e11
      if (_ki % 2) == 0 then _kill_pingPongDir = -_kill_pingPongDir end
      _kd = _kd * _kill_pingPongDir
      if _ki > 1 then _kd = _kd + (_ki - 1) * 1e11 end
      local _klook = _krealCF.LookVector
      local _kox = _klook.X * _kd
      local _koz = _klook.Z * _kd
      _kill_altVert = -_kill_altVert
      local _koy = _kill_altVert * (math.abs(_kd) + 1e11)
      local _kspinAng = tick() * math.rad(720)
      local _knx = _kox * math.cos(_kspinAng) - _koz * math.sin(_kspinAng)
      local _knz = _kox * math.sin(_kspinAng) + _koz * math.cos(_kspinAng)
      _kox = _knx; _koz = _knz
      local _kfcf = CFrame.new(_kbase.X + _kox, _kbase.Y + _koy, _kbase.Z + _koz)
      local _kfv = Vector3.new(
       (math.random() - 0.5) * 1e15 * 2,
       (math.random() - 0.5) * 1e15 * 2,
       (math.random() - 0.5) * 1e15 * 2
      )
      if _kni2 then
       pcall(_kni2, _kroot, "CFrame", _kfcf)
       pcall(_kni2, _kroot, "AssemblyLinearVelocity", _kfv)
      else
       pcall(function() _kroot.CFrame = _kfcf; _kroot.AssemblyLinearVelocity = _kfv end)
      end
     end
     if _kb < _kburst then task.wait(0.001) end
    end
    if _kni2 then
     pcall(_kni2, _kroot, "CFrame", _krealCF)
     pcall(_kni2, _kroot, "AssemblyLinearVelocity", Vector3.zero)
     pcall(_kni2, _kroot, "AssemblyAngularVelocity", Vector3.zero)
    else
     pcall(function()
      _kroot.CFrame = _krealCF
      _kroot.AssemblyLinearVelocity = Vector3.zero
      _kroot.AssemblyAngularVelocity = Vector3.zero
     end)
    end
    if sethiddenproperty then
     pcall(sethiddenproperty, _kroot, "CFrame", _krealCF)
     pcall(sethiddenproperty, _kroot, "AssemblyLinearVelocity", Vector3.zero)
    end
   end)
  end)
 end
 elseif vtype == "Bait" then
 local cur = hrp.Position
 local bait_depth = math.clamp(config.bait_depth or 20, 1, 40)
 vst_write_cf(CFrame.new(cur.X, cur.Y - bait_depth, cur.Z))
 elseif vtype == "Godmode" then
 do
  local _gmMethod = config.gm_void_method or "Quantum"
  local _gmSpeed = 2e12
  local _gmChaos = 0.98
  local _gmAlt = 1e12
  local _gmRadius = 2e12

  local _enemy_count = 0
  for _, _gp in ipairs(players:GetPlayers()) do
   if _gp ~= localplayer and _gp.Character then
    local _ghum = _gp.Character:FindFirstChildOfClass("Humanoid")
    if _ghum and _ghum.Health > 0 then _enemy_count = _enemy_count + 1 end
   end
  end
  if _enemy_count > 1 then
   _gmAlt = _gmAlt * (1 + _enemy_count * 0.3)
   _gmRadius = _gmRadius * (1 + _enemy_count * 0.2)
  end
  if not config._gm_vs_elapsed then config._gm_vs_elapsed = 0 end
  if not config._gm_vs_pos then config._gm_vs_pos = Vector3.new(hrp.Position.X, _gmAlt, hrp.Position.Z) end
  if not config._gm_vs_drift then config._gm_vs_drift = Vector3.new(1, 0, 0) end
  local _elt = config._gm_vs_elapsed
  local _pos = config._gm_vs_pos
  local _dft = config._gm_vs_drift
  local _basePos = Vector3.new(0, _gmAlt, 0)
  local _newPos
  local function _gmComputeDriftDir(t)
   local nx, ny, nz, amp, freq = 0, 0, 0, 1, 0.0001
   for _i = 1, 4 do
    nx = nx + math.noise(t * freq, 0, 0) * amp
    ny = ny + math.noise(0, t * freq, 0) * amp
    nz = nz + math.noise(0, 0, t * freq) * amp
    freq = freq * 2.37
    amp = amp * 0.5
   end
   local sp, cp = t * 0.00073, t * 0.00213
   nx = nx + math.noise(sp + 13.7, 7.3, 0) * 0.3 + math.sin(cp) * math.cos(cp * 1.618) * 0.2
   ny = ny + math.noise(0, sp + 31.1, 17.9) * 0.3 + math.cos(cp * 0.618) * math.sin(cp * 2.718) * 0.2
   nz = nz + math.noise(7.3, 0, sp + 11.5) * 0.3 + math.sin(cp * 1.3) * math.cos(cp * 0.7) * 0.2
   local len = math.sqrt(nx * nx + ny * ny + nz * nz)
   if len < 0.001 then return 1, 0, 0 end
   return nx / len, ny / len, nz / len
  end
  if _gmMethod == "Drift" then
   local dx, dy, dz = _gmComputeDriftDir(_elt)
   _dft = _dft:Lerp(Vector3.new(dx, dy, dz).Unit, _gmChaos * 0.016 * 10)
   _pos = _pos + _dft * _gmSpeed * 0.016
   if (_pos - _basePos).Magnitude > _gmRadius then
    _pos = _basePos + (_pos - _basePos).Unit * _gmRadius
    _dft = -_dft
   end
   _newPos = _pos
  elseif _gmMethod == "Chaos" then
   _pos = _pos + Vector3.new(
    (math.random() - 0.5) * _gmSpeed * 0.016 * 5,
    (math.random() - 0.5) * _gmSpeed * 0.016 * 5,
    (math.random() - 0.5) * _gmSpeed * 0.016 * 5
   )
   if (_pos - _basePos).Magnitude > _gmRadius then
    _pos = _basePos + (_pos - _basePos).Unit * _gmRadius
   end
   _newPos = _pos
  elseif _gmMethod == "Loop" then
   local r = math.min(_gmRadius * 0.8, 1e9 + (_elt % 100) * 1e7)
   _newPos = _basePos + Vector3.new(math.cos(_elt * 2) * r, math.sin(_elt * 1.3) * r * 0.2, math.sin(_elt * 2) * r)
  elseif _gmMethod == "Spiral" then
   local r = math.min(_gmRadius * 0.9, (_elt % 50) * 2e9)
   _newPos = _basePos + Vector3.new(math.cos(_elt * 3) * r, math.sin(_elt * 0.5) * r * 0.3, math.sin(_elt * 3) * r)
  else
   local r = _gmRadius * (math.random() > 0.5 and 1 or -1)
   _newPos = _basePos + Vector3.new(r, (math.random() - 0.5) * _gmRadius * 0.2, r) + Vector3.new((math.random() - 0.5) * _gmRadius, 0, (math.random() - 0.5) * _gmRadius)
  end
  config._gm_vs_elapsed = _elt + 0.016
  config._gm_vs_pos = _newPos
  config._gm_vs_drift = _dft
  local _evadeTriggered = false
  if _newPos then
   for _, _ep in ipairs(players:GetPlayers()) do
    if _ep ~= localplayer and _ep.Character then
     local _ehrp = _ep.Character:FindFirstChild("HumanoidRootPart")
     local _ehum = _ep.Character:FindFirstChildOfClass("Humanoid")
     if _ehrp and _ehum and _ehum.Health > 0 then
      local _edist = (hrp.Position - _ehrp.Position).Magnitude
      if _edist <= 100 then
       local _eangle = math.random() * 2 * math.pi
       local _epos = CFrame.new(
        hrp.Position.X + math.cos(_eangle) * 100000,
        hrp.Position.Y,
        hrp.Position.Z + math.sin(_eangle) * 100000
       )
       pcall(function()
        hrp.CFrame = _epos
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
       end)
       notify("Evaded Target", "")
       _evadeTriggered = true
       break
      end
     end
    end
   end
  end
  if not _evadeTriggered and _newPos then
   pcall(function()
    hrp.CFrame = CFrame.new(_newPos)
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
   end)
   if math.random(1, 10) == 1 then
    pcall(function()
     hrp.AssemblyLinearVelocity = Vector3.new(
      (math.random() - 0.5) * 2e7,
      (math.random() - 0.5) * 2e7,
      (math.random() - 0.5) * 2e7
     )
    end)
   end
  end
 end
 elseif vtype == "Minimal" then
 do
  local min_angle = math.random() * 2 * math.pi
  local min_radius = 10000 + math.random() * 990000
  local cur_min = hrp.Position
  local min_pos = CFrame.new(
   cur_min.X + math.cos(min_angle) * min_radius,
   cur_min.Y,
   cur_min.Z + math.sin(min_angle) * min_radius
  ) * CFrame.fromOrientation(
   math.random() * 2 * math.pi,
   math.random() * 2 * math.pi,
   math.random() * 2 * math.pi
  )
  local min_dest = min_pos.Position
  if tt_ok3(min_dest.X, min_dest.Y, min_dest.Z) then
   local V0_min = Vector3.zero
   local mt_min = getrawmetatable(hrp)
   local ni_min = mt_min and rawget(mt_min, "__newindex")
   if ni_min then
    pcall(ni_min, hrp, "AssemblyLinearVelocity", V0_min)
    pcall(ni_min, hrp, "AssemblyAngularVelocity", V0_min)
    pcall(ni_min, hrp, "CFrame", min_pos)
    pcall(ni_min, hrp, "AssemblyLinearVelocity", V0_min)
   else
    pcall(function()
     hrp.AssemblyLinearVelocity = V0_min
     hrp.AssemblyAngularVelocity = V0_min
     hrp.CFrame = min_pos
     hrp.AssemblyLinearVelocity = V0_min
    end)
   end
   if sethiddenproperty then
    pcall(sethiddenproperty, hrp, "AssemblyLinearVelocity", V0_min)
    pcall(sethiddenproperty, hrp, "AssemblyAngularVelocity", V0_min)
    pcall(sethiddenproperty, hrp, "CFrame", min_pos)
    pcall(sethiddenproperty, hrp, "AssemblyLinearVelocity", V0_min)
   end
   vst_last_pos = min_dest
  end
 end
 elseif vtype == "Random" then
 do
  local iters = math.clamp(config.iterations or 200, 1, 200)
  local _sr = getgenv().__seed_routes
  local _sr_active = config.randomizer_active and _sr and #_sr > 0
  local V0_r = Vector3.zero
  local mt_r = getrawmetatable(hrp)
  local ni_r = mt_r and rawget(mt_r, "__newindex")
  local origin_rx, origin_ry, origin_rz = hrp.CFrame.X, hrp.CFrame.Y, hrp.CFrame.Z
  local _R_VOID_MIN = 35000000
  local _R_VOID_MAX = 45000000
  local last_nx_r, last_ny_r, last_nz_r = origin_rx, origin_ry, origin_rz
  local _rnd = math.random
  local _cf  = CFrame.new
  local _sqrt = math.sqrt
  local function _do_loop(write_cf, finalize)
   for i = 1, iters do
    local step_dist = _R_VOID_MIN + _rnd() * (_R_VOID_MAX - _R_VOID_MIN)
    local _dir_rx, _dir_ry, _dir_rz = 1, 0, 0
    if _sr_active then
     local idx = getgenv().__seed_route_idx
     local sr_off = _sr[idx]
     getgenv().__seed_route_idx = (idx % #_sr) + 1
     local om = _sqrt(sr_off.X*sr_off.X + sr_off.Y*sr_off.Y + sr_off.Z*sr_off.Z)
     if om > 0 then
      _dir_rx = sr_off.X/om; _dir_ry = sr_off.Y/om; _dir_rz = sr_off.Z/om
     end
    else
     local rx = _rnd() - 0.5
     local ry = _rnd() - 0.5
     local rz = _rnd() - 0.5
     local rlen = _sqrt(rx*rx + ry*ry + rz*rz)
     if rlen == 0 then rlen = 1 end
     _dir_rx = rx/rlen; _dir_ry = ry/rlen; _dir_rz = rz/rlen
    end
    local nx_r = origin_rx + _dir_rx * step_dist
    local ny_r = origin_ry + _dir_ry * step_dist
    local nz_r = origin_rz + _dir_rz * step_dist
    local _gdx_r = nx_r - origin_rx; local _gdy_r = ny_r - origin_ry; local _gdz_r = nz_r - origin_rz
    local _gap_r = _sqrt(_gdx_r*_gdx_r + _gdy_r*_gdy_r + _gdz_r*_gdz_r)
    if _gap_r < _R_VOID_MIN and _gap_r > 0 then
     local _gs = _R_VOID_MIN / _gap_r
     nx_r = origin_rx + _gdx_r * _gs; ny_r = origin_ry + _gdy_r * _gs; nz_r = origin_rz + _gdz_r * _gs
    elseif _gap_r == 0 then
     nx_r = origin_rx + _dir_rx * _R_VOID_MIN; ny_r = origin_ry + _dir_ry * _R_VOID_MIN; nz_r = origin_rz + _dir_rz * _R_VOID_MIN
    end
    if tt_ok3(nx_r, ny_r, nz_r) then
     write_cf(_cf(nx_r, ny_r, nz_r))
     last_nx_r, last_ny_r, last_nz_r = nx_r, ny_r, nz_r
    end
   end
   finalize()
  end
  if ni_r then
   pcall(_do_loop,
    function(cf) ni_r(hrp, "AssemblyLinearVelocity", V0_r); ni_r(hrp, "CFrame", cf) end,
    function() ni_r(hrp, "AssemblyLinearVelocity", V0_r); ni_r(hrp, "AssemblyAngularVelocity", V0_r) end)
  else
   pcall(_do_loop,
    function(cf) hrp.AssemblyLinearVelocity = V0_r; hrp.CFrame = cf end,
    function() hrp.AssemblyLinearVelocity = V0_r; hrp.AssemblyAngularVelocity = V0_r end)
  end
  vst_last_pos = Vector3.new(last_nx_r, last_ny_r, last_nz_r)
 end
 end
 do
  local _V0_vst_rb = Vector3.zero
  local _KC_STEP_VST = 1e17
  local _KC_ITERS_VST = 4
  local _rnd_vst = math.random
  local _cf_vst = CFrame.new
  pcall(function()
   for _, _vp in pairs(players:GetPlayers()) do
    if _vp ~= localplayer and _vp.Character then
     local _vh = _vp.Character:FindFirstChild("HumanoidRootPart")
     if _vh then
      local mt_vh = getrawmetatable(_vh)
      local ni_vh = mt_vh and rawget(mt_vh, "__newindex")
      local _vpx = 999999986991104
      local _vpy = 999999986991104
      local _vpz = -999999986991104
      if ni_vh then
       pcall(function()
        for _vkci = 1, _KC_ITERS_VST do
         local _vnx = _vpx + (_rnd_vst() < 0.5 and _KC_STEP_VST or -_KC_STEP_VST)
         local _vny = _vpy + (_rnd_vst() < 0.5 and _KC_STEP_VST or -_KC_STEP_VST)
         local _vnz = _vpz + (_rnd_vst() < 0.5 and _KC_STEP_VST or -_KC_STEP_VST)
         ni_vh(_vh, "AssemblyLinearVelocity", _V0_vst_rb)
         ni_vh(_vh, "CFrame", _cf_vst(_vnx, _vny, _vnz))
         _vpx = _vnx; _vpy = _vny; _vpz = _vnz
        end
        ni_vh(_vh, "AssemblyLinearVelocity", _V0_vst_rb)
        ni_vh(_vh, "AssemblyAngularVelocity", _V0_vst_rb)
       end)
      else
       pcall(function()
        for _vkci = 1, _KC_ITERS_VST do
         local _vnx = _vpx + (_rnd_vst() < 0.5 and _KC_STEP_VST or -_KC_STEP_VST)
         local _vny = _vpy + (_rnd_vst() < 0.5 and _KC_STEP_VST or -_KC_STEP_VST)
         local _vnz = _vpz + (_rnd_vst() < 0.5 and _KC_STEP_VST or -_KC_STEP_VST)
         _vh.AssemblyLinearVelocity = _V0_vst_rb
         _vh.CFrame = _cf_vst(_vnx, _vny, _vnz)
         _vpx = _vnx; _vpy = _vny; _vpz = _vnz
        end
        _vh.AssemblyLinearVelocity = _V0_vst_rb
        _vh.AssemblyAngularVelocity = _V0_vst_rb
       end)
      end
      if sethiddenproperty then
       pcall(sethiddenproperty, _vh, "AssemblyLinearVelocity", _V0_vst_rb)
       pcall(sethiddenproperty, _vh, "AssemblyAngularVelocity", _V0_vst_rb)
       pcall(sethiddenproperty, _vh, "CFrame", _cf_vst(_vpx, _vpy, _vpz))
      end
     end
    end
   end
  end)
  if ragebot_bypass_active then
   pcall(function()
    for _rbp in pairs(ragebot_bypass_projectiles) do
     if _rbp and _rbp.Parent then
      local mt_rbp = getrawmetatable(_rbp)
      local ni_rbp = mt_rbp and rawget(mt_rbp, "__newindex")
      local _rpx = 999999986991104
      local _rpy = 999999986991104
      local _rpz = -999999986991104
      if ni_rbp then
       for _vkci2 = 1, _KC_ITERS_VST do
        local _rnx = _rpx + (_rnd_vst() < 0.5 and _KC_STEP_VST or -_KC_STEP_VST)
        local _rny = _rpy + (_rnd_vst() < 0.5 and _KC_STEP_VST or -_KC_STEP_VST)
        local _rnz = _rpz + (_rnd_vst() < 0.5 and _KC_STEP_VST or -_KC_STEP_VST)
        ni_rbp(_rbp, "AssemblyLinearVelocity", _V0_vst_rb)
        ni_rbp(_rbp, "CFrame", _cf_vst(_rnx, _rny, _rnz))
        _rpx = _rnx; _rpy = _rny; _rpz = _rnz
       end
       ni_rbp(_rbp, "AssemblyLinearVelocity", _V0_vst_rb)
       ni_rbp(_rbp, "AssemblyAngularVelocity", _V0_vst_rb)
      else
       for _vkci2 = 1, _KC_ITERS_VST do
        local _rnx = _rpx + (_rnd_vst() < 0.5 and _KC_STEP_VST or -_KC_STEP_VST)
        local _rny = _rpy + (_rnd_vst() < 0.5 and _KC_STEP_VST or -_KC_STEP_VST)
        local _rnz = _rpz + (_rnd_vst() < 0.5 and _KC_STEP_VST or -_KC_STEP_VST)
        _rbp.AssemblyLinearVelocity = _V0_vst_rb
        _rbp.CFrame = _cf_vst(_rnx, _rny, _rnz)
        _rpx = _rnx; _rpy = _rny; _rpz = _rnz
       end
       _rbp.AssemblyLinearVelocity = _V0_vst_rb
       _rbp.AssemblyAngularVelocity = _V0_vst_rb
      end
      if sethiddenproperty then
       pcall(sethiddenproperty, _rbp, "AssemblyLinearVelocity", _V0_vst_rb)
       pcall(sethiddenproperty, _rbp, "AssemblyAngularVelocity", _V0_vst_rb)
       pcall(sethiddenproperty, _rbp, "CFrame", _cf_vst(_rpx, _rpy, _rpz))
      end
     else
      ragebot_bypass_projectiles[_rbp] = nil
     end
    end
   end)
  end
  if config.vs_enemy_desc == "No Evasion" then
   local _ne_target = kc_find_target()
   if _ne_target and _ne_target.Character then
    local _ne_thrp = _ne_target.Character:FindFirstChild("HumanoidRootPart")
    local _ne_head = _ne_target.Character:FindFirstChild("Head")
    if _ne_thrp then
     local _ne_aggression = math.clamp(config.void_counter_aggression or 5, 1, 5)
     local _ne_passes = 8 * _ne_aggression
     for _ = 1, _ne_passes do
      pcall(tt_sample_part, _ne_thrp)
      if _ne_head then pcall(tt_sample_part, _ne_head) end
     end
     local _ne_hum = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")
     if _ne_hum then
      pcall(function() _ne_hum:ChangeState(Enum.HumanoidStateType.Physics) end)
      pcall(function() _ne_hum.PlatformStand = false end)
      pcall(function() _ne_hum.AutoRotate = false end)
     end
     kc_nuke_fallen_parts()
     local _ne_sky = CFrame.new(hrp.Position.X, hrp.Position.Y + 10000 * math.max(config.kicia_counter_speed or 1, 0.1), hrp.Position.Z)
     local _ne_snaps = math.clamp(config.void_counter_snap_count or 8, 1, 16)
     for _ = 1, _ne_snaps do
      kc_force_cf(hrp, _ne_sky)
     end
     local _ne_firetgt = _ne_head or _ne_thrp
     pcall(manipulation.fire_toward, _ne_firetgt, _ne_target.Character)
     kc_nuke_fallen_parts()
    end
   end
  end
 end
end)

end

getgenv().stop_voidspam_type = function(_keep_flag)
 if not _keep_flag then config.void = false end
 if vst_conn then vst_conn:Disconnect(); vst_conn = nil end
 if void_spin_conn then void_spin_conn:Disconnect(); void_spin_conn = nil end
 vst_last_pos = nil
 vst_pre_enable_cf = nil
 _vdb_deep_y = nil
 _vdb_ascending = false
 vs_motion_step = 0
 vs_spiral = 0
 vs_wave = 0
 vs_helix = 0
 vs_orbit_angle = 0
 vs_phase_hex = 0
 vs_phase_oct = 0
 vs_phase_star = 0
 vs_phase_cross = 0
 vs_phase_rhombus = 0
 evs_phase = 0
 evs_tick_acc = 0
 _movement_restore_pos()
end

local afk_conn = nil

getgenv().start_anti_afk = function()
 if afk_conn then afk_conn:Disconnect() end
 afk_conn = localplayer.Idled:Connect(function()
  if config.anti_afk_enabled then
   virtual_user:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
   task.wait(1)
   virtual_user:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
  end
 end)
end

getgenv().stop_anti_afk = function()
 if afk_conn then afk_conn:Disconnect(); afk_conn = nil end
end

local auto_conn = nil
local last_auto_tick = 0
local _ac_kw_vals = {gem=3,chest=2.5,loot=2,coin=1.5,drop=1}
local _ac_kw_list = {"gem","chest","loot","coin","drop"}

getgenv().start_autocollect = function()
 if auto_conn then auto_conn:Disconnect() end
 local _ac_cached_parts = {}
 local _ac_cache_last = 0
 local _ac_cache_interval = 2
 auto_conn = run_service.Heartbeat:Connect(function()
  if not config.auto_collect then return end
  local hrp = getgenv().get_hrp(localplayer)
  if not hrp then return end
  local now = tick()
  if now - last_auto_tick < 0.5 then return end
  last_auto_tick = now
  if now - _ac_cache_last >= _ac_cache_interval then
   _ac_cache_last = now
   _ac_cached_parts = {}
   for _, o in ipairs(workspace:GetDescendants()) do
    if o:IsA("BasePart") then
     local n = string.lower(o.Name)
     local item_value = 0
     for _, kw in ipairs(_ac_kw_list) do
      if n:find(kw, 1, true) then
       local v = _ac_kw_vals[kw]
       if v > item_value then item_value = v end
      end
     end
     if item_value > 0 then
      _ac_cached_parts[#_ac_cached_parts + 1] = {part = o, value = item_value}
     end
    end
   end
  end
  local best, best_score = nil, math.huge
  local my_pos = hrp.Position
  local collect_radius = config.collect_radius or 120
  for _, entry in ipairs(_ac_cached_parts) do
   local o = entry.part
   if o and o.Parent then
    local ok, opos = pcall(function() return o.Position end)
    if ok and opos then
     local d = (my_pos - opos).Magnitude
     if d < collect_radius then
      local score = d / entry.value
      if score < best_score then best_score = score; best = o end
     end
    end
   end
  end
  if best then
   pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero end)
   hrp.CFrame = CFrame.new(best.Position)
   pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero end)
  end
 end)
end

getgenv().stop_autocollect = function()
 if auto_conn then auto_conn:Disconnect(); auto_conn = nil end
 config.auto_collect = false
end

local home_conn = nil

getgenv().start_return_home = function()
 if home_conn then home_conn:Disconnect() end
 local rh_last = 0
 home_conn = run_service.Heartbeat:Connect(function()
  if not config.return_home then return end
  if not getgenv().home_position then return end
  local now = tick()
  if now - rh_last < 0.1 then return end
  rh_last = now
  local hrp = getgenv().get_hrp(localplayer)
  if not hrp then return end
  local hp = getgenv().home_position
  local dist = (hrp.Position - hp).Magnitude
  if dist < 1 then return end
  local hum = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")
  pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero end)
  pcall(function() hrp.AssemblyAngularVelocity = Vector3.zero end)
  if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end) end
  local target_cf = CFrame.new(hp)
  pcall(function() hrp.CFrame = target_cf end)
  local mt_rh = getrawmetatable(hrp)
  local ni_rh = mt_rh and rawget(mt_rh, "__newindex")
  if ni_rh then
   pcall(ni_rh, hrp, "CFrame", target_cf)
   pcall(ni_rh, hrp, "AssemblyLinearVelocity", Vector3.zero)
  end
  if sethiddenproperty then
   pcall(sethiddenproperty, hrp, "CFrame", target_cf)
   pcall(sethiddenproperty, hrp, "AssemblyLinearVelocity", Vector3.zero)
  end
  pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero end)
  pcall(function() hrp.AssemblyAngularVelocity = Vector3.zero end)
 end)
end

getgenv().stop_return_home = function()
 if home_conn then home_conn:Disconnect(); home_conn = nil end
 config.return_home = false
end

local safe_conn = nil

getgenv().start_safe_zone = function()
 if safe_conn then safe_conn:Disconnect() end
 local sz_last = 0
 safe_conn = run_service.Heartbeat:Connect(function()
  if not config.safe_zone_rescue then return end
  local now = tick()
  if now - sz_last < 0.1 then return end
  sz_last = now
  local hrp = getgenv().get_hrp(localplayer)
  if not hrp then return end
  local threshold = config.depth_threshold or -10
  if hrp.Position.Y < threshold then
   local safe_y = math.abs(threshold) + 50
   local ray_origin = Vector3.new(hrp.Position.X, threshold, hrp.Position.Z)
   local ray_dir = Vector3.new(0, safe_y + 100, 0)
   local rp = RaycastParams.new()
   rp.FilterDescendantsInstances = {localplayer.Character}
   rp.FilterType = Enum.RaycastFilterType.Exclude
   local result = workspace:Raycast(ray_origin, ray_dir, rp)
   local rescue_y
   if result and result.Position then
    rescue_y = result.Position.Y + 3
   else
    rescue_y = safe_y
   end
   local rescue_cf = CFrame.new(hrp.Position.X, rescue_y, hrp.Position.Z)
   pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero end)
   pcall(function() hrp.AssemblyAngularVelocity = Vector3.zero end)
   pcall(function() hrp.CFrame = rescue_cf end)
   local mt_sz = getrawmetatable(hrp)
   local ni_sz = mt_sz and rawget(mt_sz, "__newindex")
   if ni_sz then
    pcall(ni_sz, hrp, "CFrame", rescue_cf)
    pcall(ni_sz, hrp, "AssemblyLinearVelocity", Vector3.zero)
   end
   if sethiddenproperty then
    pcall(sethiddenproperty, hrp, "CFrame", rescue_cf)
   end
   pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero end)
   pcall(function() hrp.AssemblyAngularVelocity = Vector3.zero end)
  end
 end)
end

getgenv().stop_safe_zone = function()
 if safe_conn then safe_conn:Disconnect(); safe_conn = nil end
 config.safe_zone_rescue = false
end

local tl_conn = nil
local tl_active = false
getgenv().loop_waypoints = {}
getgenv().loop_index = 1

getgenv().start_teleport_loop = function()
 if tl_conn then tl_active = false; tl_conn = nil end
 tl_active = true
 _movement_save_pos()
 tl_conn = task.spawn(function()
  while tl_active and config.teleport_loop_enabled do
   if #getgenv().loop_waypoints > 0 then
    local idx = getgenv().loop_index
    local wp = getgenv().loop_waypoints[idx]
    if wp then
     local hrp = getgenv().get_hrp(localplayer)
     local hum = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")
     if hrp then
      local target_cf = CFrame.new(wp)
      pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero end)
      pcall(function() hrp.AssemblyAngularVelocity = Vector3.zero end)
      if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end) end
      pcall(function() hrp.CFrame = target_cf end)
      local mt_tl = getrawmetatable(hrp)
      local ni_tl = mt_tl and rawget(mt_tl, "__newindex")
      if ni_tl then
       pcall(ni_tl, hrp, "CFrame", target_cf)
       pcall(ni_tl, hrp, "AssemblyLinearVelocity", Vector3.zero)
      end
      if sethiddenproperty then
       pcall(sethiddenproperty, hrp, "CFrame", target_cf)
       pcall(sethiddenproperty, hrp, "AssemblyLinearVelocity", Vector3.zero)
      end
      pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero end)
      pcall(function() hrp.AssemblyAngularVelocity = Vector3.zero end)
     end
     getgenv().loop_index = (idx % #getgenv().loop_waypoints) + 1
    end
   end
   task.wait(math.max(config.loop_delay or 0.5, 0.05))
  end
 end)
end

getgenv().stop_teleport_loop = function()
 tl_active = false
 tl_conn = nil
 config.teleport_loop_enabled = false
 _movement_restore_pos()
end

local astral_sound_ids = {
 Space = "rbxassetid://719384308",
 Pop = "rbxassetid://140323850218372",
 Bonk = "rbxassetid://18794851884",
 Skeet = "rbxassetid://83717596220569",
 Neverlose = "rbxassetid://97643101798871",
 Slip = "rbxassetid://70557734865364",
}
local astral_sound_volume = 0.5
local astral_sound_selected = "Space"
local astral_sound_service = game:GetService("SoundService")
local astral_toggle_sound = Instance.new("Sound", astral_sound_service)
astral_toggle_sound.SoundId = astral_sound_ids[astral_sound_selected]
astral_toggle_sound.Volume = astral_sound_volume

local function play_toggle_sound()
 if not config.enable_sounds then return end
 pcall(function()
  astral_toggle_sound.SoundId = astral_sound_ids[astral_sound_selected] or astral_sound_ids.Space
  astral_toggle_sound.Volume = astral_sound_volume
  astral_toggle_sound.PlaybackSpeed = math.random(95, 105) / 100
  astral_toggle_sound:Play()
 end)

end

getgenv().play_toggle_sound = play_toggle_sound
local Library, ThemeManager, SaveManager

getgenv().__meowlua_generation = (tonumber(getgenv().__meowlua_generation) or 0) + 1
local load_generation = getgenv().__meowlua_generation
task.spawn(function()
 local ui_ready = false
 local ui_ok, ui_error = xpcall(function()
  if load_generation ~= getgenv().__meowlua_generation then return end
if getgenv().config then
 local c = getgenv().config
 if c.translocation_enabled == nil then c.translocation_enabled = false end
 if c.void_axis_x == nil then c.void_axis_x = true end
 if c.void_axis_y == nil then c.void_axis_y = true end
 if c.void_axis_z == nil then c.void_axis_z = true end
 if c.enable_x_axis == nil then c.enable_x_axis = true end
 if c.enable_y_axis == nil then c.enable_y_axis = true end
 if c.enable_z_axis == nil then c.enable_z_axis = true end

end

 local _ok1, _lib = pcall(function()
  return loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/Library.lua"))() end)
 if not _ok1 or not _lib then
  notify("meowlua", "linorialib failed to load.")
  return
 end
 Library = _lib
 getgenv().unload_all = function()
  getgenv().meowlua_loaded = false
  getgenv().meowlua_loading = false
  getgenv().__meowlua_generation = (tonumber(getgenv().__meowlua_generation) or 0) + 1
  if getgenv().config then
   getgenv().config.void = false
   getgenv().config.orbit = false
   getgenv().config.glue_enabled = false
   getgenv().config.anti_aim = false
  end
  pcall(getgenv().stop_voidspam_type)
  pcall(getgenv().stop_orbit)
  pcall(getgenv().stop_glue)
  pcall(getgenv().stop_body_manip)
  pcall(Library.Unload, Library)
 end
 local _ok2, _tm = pcall(function()
  return loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/addons/ThemeManager.lua"))() end)
 if _ok2 and _tm then ThemeManager = _tm end
 local _ok3, _sm = pcall(function()
  return loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/addons/SaveManager.lua"))() end)
 if _ok3 and _sm then SaveManager = _sm end
 if not ThemeManager or not SaveManager then
  notify("meowlua", "linoria addons failed to load.")
  return
 end
local Window = Library:CreateWindow({
 Title="meowlua private - discord.gg/meowwc", Center=true, AutoShow=true, TabPadding=8, MenuFadeTime=0, })

local Tabs = {
 Movement=Window:AddTab("Movement"), Aggression=Window:AddTab("Aggression"), Defense=Window:AddTab("Defense"), Protection=Window:AddTab("Protection"), Misc=Window:AddTab("Misc"), Settings=Window:AddTab("Settings"), }
task.wait()

local function tnotify(title, desc)
 Library:Notify(title, desc or "", 3)

end

local orbit_conn = nil
local orbit_phase = 0

local function orb_get_base()
 local tgt = config.orbit_target or "Self"
 if tgt == "Closest" then

  local my_hrp = getgenv().get_hrp(localplayer)
  local my_pos = my_hrp and my_hrp.Position
  local best_dist = math.huge
  local best_pos = nil
  for _, p in ipairs(players:GetPlayers()) do
   if p ~= localplayer and p.Character then
    local t_hrp = p.Character:FindFirstChild("HumanoidRootPart")
    local hum = p.Character:FindFirstChildOfClass("Humanoid")
    local diff_team = localplayer.Team == nil or p.Team == nil or localplayer.Team ~= p.Team
    if t_hrp and hum and hum.Health > 0 and diff_team then

     local live = tt_live and tt_live[t_hrp]
     local candidate_pos
     if live then
      if not live.is_void and tt_ok3(live.x, live.y, live.z) then
       candidate_pos = Vector3.new(live.x, live.y, live.z)
      elseif live.lkg_x and tt_ok3(live.lkg_x, live.lkg_y, live.lkg_z) then
       candidate_pos = Vector3.new(live.lkg_x, live.lkg_y, live.lkg_z)
      end
     end

     if not candidate_pos then
      local ok, cf = pcall(function() return t_hrp.CFrame end)
      if ok and cf and tt_okv(cf.Position) then candidate_pos = cf.Position end
     end
     if candidate_pos and my_pos then
      local d = (my_pos - candidate_pos).Magnitude
      if d < best_dist then
       best_dist = d

       local vel_ok, vel = pcall(function() return t_hrp.AssemblyLinearVelocity end)
       if vel_ok and vel then
        local predicted = candidate_pos + vel * 0.05
        if tt_okv(predicted) then best_pos = predicted else best_pos = candidate_pos end
       else
        best_pos = candidate_pos
       end
      end
     end
    end
   end
  end
  return best_pos
 end
 return nil

end

local function orb_apply_falloff(dist, i, total)
 local mode = config.orbit_falloff or "None"
 if mode == "Linear" then return dist * (1 - (i - 1) / total)
 elseif mode == "Exp" then return dist * math.exp(-3 * (i - 1) / total)
 elseif mode == "Sine" then return dist * math.abs(math.sin((i - 1) / total * math.pi))
 elseif mode == "Cosine" then return dist * math.abs(math.cos((i - 1) / total * math.pi * 0.5))
 else return dist end

end

local function orb_compute_offset(i, total, phase)
 local frac = (i - 1) / math.max(total - 1, 1)
 local radius = math.max(config.orbit_radius or 50000, 1)
 local height = config.height_offset or 0
 local pattern = config.orbit_pattern or "Circle"
 local axis = config.orbit_axis or "Y"
 local dir_sign = (config.orbit_direction == "Counter-clockwise") and -1 or 1
 local jitter = config.orbit_jitter or 0
 local tightness = math.max(config.tightness or 10, 1)
 local wave_freq = config.wave_freq or 1
 local eff_dist = orb_apply_falloff(radius, i, total)
 local j = jitter > 0 and Vector3.new((math.random() - 0.5) * jitter, (math.random() - 0.5) * jitter * 0.2, (math.random() - 0.5) * jitter) or Vector3.zero
 local a = frac * math.pi * 2 * dir_sign + phase
 local ox, oy, oz
 if pattern == "Circle" then
  if axis == "Y" then
   ox = math.cos(a) * eff_dist
   oy = height
   oz = math.sin(a) * eff_dist
  elseif axis == "X" then
   ox = 0
   oy = math.cos(a) * eff_dist + height
   oz = math.sin(a) * eff_dist
  elseif axis == "Z" then
   ox = math.cos(a) * eff_dist
   oy = math.sin(a) * eff_dist + height
   oz = 0
  else
   ox = math.cos(a) * eff_dist
   oy = height
   oz = math.sin(a) * eff_dist
  end
 elseif pattern == "Ellipse" then
  ox = math.cos(a) * eff_dist
  oy = height
  oz = math.sin(a) * (eff_dist * 0.5)
 elseif pattern == "Figure8" then
  ox = math.sin(a) * eff_dist
  oy = height
  oz = math.sin(a * 2) * (eff_dist * 0.5)
 elseif pattern == "Helix" then
  ox = math.cos(a * tightness * 0.1) * eff_dist
  oy = height + frac * eff_dist * 0.5
  oz = math.sin(a * tightness * 0.1) * eff_dist
 elseif pattern == "Wave" then
  ox = math.cos(a) * eff_dist
  oy = math.sin(frac * math.pi * 2 * wave_freq + phase) * eff_dist * 0.4 + height
  oz = math.sin(a) * eff_dist
 elseif pattern == "Spiral" then
  local r_mod = eff_dist * (0.2 + 0.8 * frac)
  ox = math.cos(a * tightness * 0.1) * r_mod
  oy = height
  oz = math.sin(a * tightness * 0.1) * r_mod
 elseif pattern == "Pulse" then
  local pulse = math.abs(math.sin(frac * math.pi * wave_freq + phase))
  ox = math.cos(a) * eff_dist * pulse
  oy = height
  oz = math.sin(a) * eff_dist * pulse
 else
  ox = math.cos(a) * eff_dist
  oy = height
  oz = math.sin(a) * eff_dist
 end
 local chaos = config.orbit_chaos_blend or 0
 if chaos > 0 then
  ox = ox + (math.random() - 0.5) * eff_dist * chaos * 0.02
  oz = oz + (math.random() - 0.5) * eff_dist * chaos * 0.02
 end
 if config.orbit_invert_x then ox = -ox end
 if config.orbit_invert_z then oz = -oz end
 local y_bias = config.y_bias or 0
 oy = oy + y_bias
 local depth_floor = config.depth_floor or 0
 if depth_floor > 0 then oy = math.max(oy, -depth_floor) end
 return Vector3.new(ox, oy, oz) + j

end

local function orb_apply_warp(from_cf, to_pos)
 local target_cf = CFrame.new(to_pos)
 local mode = config.orbit_warp_mode or "Instant"
 local strength = math.clamp((config.warp_strength or 50) / 100, 0.01, 1)
 if mode == "Lerp" then
  return from_cf:Lerp(target_cf, strength)
 elseif mode == "Spring" then
  return from_cf:Lerp(target_cf, math.clamp(strength * 1.5, 0.01, 1))
 elseif mode == "Bounce" then
  local t = strength
  local bounce = math.abs(math.sin(t * math.pi * 3)) * (1 - t)
  return from_cf:Lerp(target_cf, math.clamp(t + bounce * 0.2, 0.01, 1))
 elseif mode == "Elastic" then
  local t = strength
  local elastic = math.sin(t * math.pi * 4.5) * math.exp(-t * 3)
  return from_cf:Lerp(target_cf, math.clamp(t + elastic * 0.15, 0.01, 1))
 else
  return target_cf
 end

end

getgenv().start_orbit = function()
 if orbit_conn then orbit_conn:Disconnect() end
 pcall(function() run_service:UnbindFromRenderStep("OrbitPhaseAdvance") end)
 _movement_save_pos()
 orbit_phase = 0
 pcall(function()
  run_service:BindToRenderStep("OrbitPhaseAdvance", Enum.RenderPriority.First.Value - 200, function(dt)
   if not config.orbit then return end
   orbit_phase = orbit_phase + dt * (config.orbit_speed or 5) * 0.5
  end)
 end)
 local orb_hb_last = 0
 orbit_conn = run_service.Heartbeat:Connect(function(dt)
  if not config.orbit then return end
  local now = tick()
  if now - orb_hb_last < 0.016 then return end
  orb_hb_last = now
  local hrp = getgenv().get_hrp(localplayer)
  local hum = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")
  if not hrp or not hum or hum.Health <= 0 then return end
  local hrp_pos = hrp.Position
  if not tt_ok3(hrp_pos.X, hrp_pos.Y, hrp_pos.Z) then return end
  pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end)
  pcall(function() hum.AutoRotate = false end)
  pcall(function() workspace.FallenPartsDestroyHeight = -math.huge end)
  pcall(function() workspace.FallenPartsDestroyHeight = 0/0 end)
  local iters = math.clamp(config.orbit_iterations or 100, 1, 500)
  local layers = math.clamp(config.layer_count or 1, 1, 8)
  local layer_offset_rad = math.rad(config.layer_offset or 0)
  local base_override = orb_get_base()
  local V0 = Vector3.zero
  local mt_orb = getrawmetatable(hrp)
  local ni_orb = mt_orb and rawget(mt_orb, "__newindex")
  local final_cf_last = nil
  local _rnd = math.random
  local _cf = CFrame.new
  pcall(function()
   for layer = 1, layers do
    local layer_phase = orbit_phase + layer_offset_rad * layer
    local base_pos = base_override or hrp.Position
    if not tt_okv(base_pos) then base_pos = hrp_pos end
    for i = 1, iters do
     local offset = orb_compute_offset(i, iters, layer_phase)
     local tx = base_pos.X + offset.X
     local ty = base_pos.Y + offset.Y
     local tz = base_pos.Z + offset.Z
     if not tt_ok3(tx, ty, tz) then
      tx = base_pos.X; ty = base_pos.Y; tz = base_pos.Z
     end
     local target_cf
     local warp_mode = config.orbit_warp_mode or "Instant"
     if warp_mode == "Instant" then
      target_cf = _cf(tx, ty, tz)
     else
      target_cf = orb_apply_warp(hrp.CFrame, Vector3.new(tx, ty, tz))
     end
     if ni_orb then
      pcall(ni_orb, hrp, "AssemblyLinearVelocity", V0)
      pcall(ni_orb, hrp, "AssemblyAngularVelocity", V0)
      pcall(ni_orb, hrp, "CFrame", target_cf)
      pcall(ni_orb, hrp, "AssemblyLinearVelocity", V0)
     else
      pcall(function()
       hrp.AssemblyLinearVelocity = V0
       hrp.AssemblyAngularVelocity = V0
       hrp.CFrame = target_cf
       hrp.AssemblyLinearVelocity = V0
      end)
     end
     final_cf_last = target_cf
    end
   end
  end)
  if sethiddenproperty and final_cf_last then
   pcall(sethiddenproperty, hrp, "CFrame", final_cf_last)
   pcall(sethiddenproperty, hrp, "AssemblyLinearVelocity", V0)
   pcall(sethiddenproperty, hrp, "AssemblyAngularVelocity", V0)
  end
  if config.orbit_kill_velocity then
   pcall(function() hrp.AssemblyLinearVelocity = V0 end)
   pcall(function() hrp.AssemblyAngularVelocity = V0 end)
   if sethiddenproperty then
    pcall(sethiddenproperty, hrp, "AssemblyLinearVelocity", V0)
    pcall(sethiddenproperty, hrp, "AssemblyAngularVelocity", V0)
   end
  end
  do
   local _orb_true_cf = _dsync_read_true_cf(hrp)
   if _orb_true_cf then _dsync_record_pos(_orb_true_cf) end
  end
  pcall(function() workspace.FallenPartsDestroyHeight = -math.huge end)
  pcall(function() workspace.FallenPartsDestroyHeight = 0/0 end)
 end)

end

getgenv().stop_orbit = function()
 if orbit_conn then orbit_conn:Disconnect(); orbit_conn = nil end
 pcall(function() run_service:UnbindFromRenderStep("OrbitPhaseAdvance") end)
 config.orbit = false
 orbit_phase = 0
 local hum = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")
 if hum then
  pcall(function() hum.AutoRotate = true end)
  pcall(function() hum.PlatformStand = false end)
 end
 _movement_restore_pos()
end

local fly_conn = nil
local fly_nc_conn = nil

local fly_nc_parts = {}

getgenv().start_fly = function()
 if fly_conn then fly_conn:Disconnect(); fly_conn = nil end
 if fly_nc_conn then fly_nc_conn:Disconnect(); fly_nc_conn = nil end
 fly_nc_parts = {}
 local cam = workspace.CurrentCamera
 local _fly_hb_last = 0
 fly_conn = run_service.Heartbeat:Connect(function(dt)
  if not config.fly_enabled then return end
  local _fly_now = tick()
  if _fly_now - _fly_hb_last < 0.016 then return end
  local _fly_dt = _fly_now - _fly_hb_last
  _fly_hb_last = _fly_now
  dt = _fly_dt
  local hrp = getgenv().get_hrp(localplayer)
  if not hrp then return end
  local hum = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")
  if hum and config.fly_enabled then
   pcall(function() hum.PlatformStand = true end)
  end
  local spd = math.max(config.fly_speed or 60, 1)
  local cf = cam.CFrame
  local move = Vector3.zero
  local uis = user_input_service
  if uis:IsKeyDown(Enum.KeyCode.W) then move = move + cf.LookVector end
  if uis:IsKeyDown(Enum.KeyCode.S) then move = move - cf.LookVector end
  if uis:IsKeyDown(Enum.KeyCode.A) then move = move - cf.RightVector end
  if uis:IsKeyDown(Enum.KeyCode.D) then move = move + cf.RightVector end
  if uis:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
  if uis:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
  if move.Magnitude > 0 then move = move.Unit * spd * dt end
  if config.fly_gravity_cancel then
   pcall(function()
    local mt = getrawmetatable(hrp)
    if mt then
     local ni = rawget(mt, "__newindex")
     if ni then
      ni(hrp, "AssemblyLinearVelocity", move.Magnitude > 0 and (move / dt) or Vector3.zero)
     end
    end
   end)
   pcall(function() hrp.AssemblyLinearVelocity = move.Magnitude > 0 and (move / dt) or Vector3.zero end)
  end
  pcall(function() hrp.CFrame = hrp.CFrame + move end)
 end)
 if config.fly_noclip then
  fly_nc_conn = run_service.Stepped:Connect(function()
   if not config.fly_enabled or not config.fly_noclip then return end
   local char = localplayer.Character
   if not char then return end
   for _, part in ipairs(char:GetDescendants()) do
    if part:IsA("BasePart") and not fly_nc_parts[part] then
     fly_nc_parts[part] = true
    end
    if part:IsA("BasePart") then
     pcall(function() part.CanCollide = false end)
    end
   end
  end)
 end

end

getgenv().stop_fly = function()
 if fly_conn then fly_conn:Disconnect(); fly_conn = nil end
 if fly_nc_conn then fly_nc_conn:Disconnect(); fly_nc_conn = nil end
 fly_nc_parts = {}
 config.fly_enabled = false
 local hrp = getgenv().get_hrp(localplayer)
 if hrp then
  pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero end)
 end
 local hum = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")
 if hum then pcall(function() hum.PlatformStand = false end) end
 local char = localplayer.Character
 if char then
  for _, part in ipairs(char:GetDescendants()) do
   if part:IsA("BasePart") then
    pcall(function() part.CanCollide = true end)
   end
  end
 end

end

getgenv().unload_all = function()
 getgenv().meowlua_loaded = false
 getgenv().meowlua_loading = false
 getgenv().__meowlua_generation = (tonumber(getgenv().__meowlua_generation) or 0) + 1
 if getgenv().config then
  getgenv().config.void = false
  getgenv().config.orbit = false
  getgenv().config.glue_enabled = false
  getgenv().config.anti_aim = false
 end
 pcall(getgenv().stop_anti_afk)
 pcall(getgenv().stop_void_spam)
 pcall(getgenv().stop_autocollect); pcall(getgenv().stop_safe_zone); pcall(getgenv().stop_return_home)
 pcall(getgenv().stop_teleport_loop)
 pcall(getgenv().stop_slingshot_bypass); pcall(getgenv().stop_slingshot_orbit); pcall(getgenv().stop_godmode)
 pcall(getgenv().stop_perfect_block); pcall(getgenv().stop_knife_bypass)
 pcall(getgenv().stop_orbit)
 pcall(getgenv().stop_extra_voidspam)
 pcall(getgenv().stop_voidspam_type)
 pcall(getgenv().stop_glue)
 pcall(getgenv().stop_body_manip)
 pcall(getgenv().stop_anti_translocation)
 pcall(getgenv().stop_kicia_counter)
 pcall(getgenv().stop_underground)
 pcall(getgenv().stop_ragebot_bypass); pcall(getgenv().stop_nebula_counter)
 pcall(getgenv().stop_fly)
 for _, c in ipairs(getgenv().all_connections) do pcall(function() c:Disconnect() end) end
 getgenv().all_connections = {}
 pcall(function() Library:Unload() end)
 if getgenv().__destroyXYZOverlay then pcall(getgenv().__destroyXYZOverlay) end

end

task.wait()
local VoidMainTabbox = Tabs.Movement:AddLeftTabbox()
local LeftVoid = VoidMainTabbox:AddTab("Void")
local CustVoid = LeftVoid
local CustVoidB = LeftVoid
local OrbitTab = VoidMainTabbox:AddTab("Orbit")
local _xyzSg, _xyzConn, _xyzVals

local function buildXYZOverlay()
 if _xyzSg and _xyzSg.Parent then return end
 local sg = Instance.new("ScreenGui")
 sg.Name = "MeowluaXYZOverlay"
 sg.ResetOnSpawn = false
 sg.DisplayOrder = 9999
 local coreOk = pcall(function() sg.Parent = game:GetService("CoreGui") end)
 if not coreOk then sg.Parent = localplayer:WaitForChild("PlayerGui") end
 _xyzSg = sg
 local panel = Instance.new("Frame")
 panel.Size = UDim2.new(0, 170, 0, 96)
 panel.Position = UDim2.new(0, 14, 0.5, -48)
 panel.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
 panel.BackgroundTransparency = 0.08
 panel.BorderSizePixel = 0
 panel.Parent = sg
 local pc = Instance.new("UICorner"); pc.CornerRadius = UDim.new(0,7); pc.Parent = panel
 local ps = Instance.new("UIStroke"); ps.Color = Color3.fromRGB(60,60,65); ps.Thickness = 1; ps.Transparency = 0.3; ps.Parent = panel
 local hdr = Instance.new("Frame")
 hdr.Size = UDim2.new(1,0,0,26); hdr.BackgroundTransparency = 1; hdr.Parent = panel
 local dot = Instance.new("Frame")
 dot.Size = UDim2.new(0,7,0,7); dot.Position = UDim2.new(0,10,0.5,-3)
 dot.BackgroundColor3 = Color3.fromRGB(210,55,55); dot.BorderSizePixel = 0; dot.Parent = hdr
 local dc = Instance.new("UICorner"); dc.CornerRadius = UDim.new(1,0); dc.Parent = dot
 local ttl = Instance.new("TextLabel")
 ttl.Size = UDim2.new(0,80,1,0); ttl.Position = UDim2.new(0,23,0,0)
 ttl.BackgroundTransparency = 1; ttl.Text = "meowlua"
 ttl.TextColor3 = Color3.fromRGB(220,220,225); ttl.Font = Enum.Font.GothamBold
 ttl.TextSize = 12; ttl.TextXAlignment = Enum.TextXAlignment.Left; ttl.Parent = hdr
 local badge = Instance.new("TextLabel")
 badge.Size = UDim2.new(0,48,0,16); badge.Position = UDim2.new(1,-54,0.5,-8)
 badge.BackgroundColor3 = Color3.fromRGB(38,38,42); badge.Text = "PRIVATE"
 badge.TextColor3 = Color3.fromRGB(160,160,168); badge.Font = Enum.Font.GothamBold
 badge.TextSize = 9; badge.BorderSizePixel = 0; badge.Parent = hdr
 local bdc = Instance.new("UICorner"); bdc.CornerRadius = UDim.new(0,4); bdc.Parent = badge
 local bds = Instance.new("UIStroke"); bds.Color = Color3.fromRGB(70,70,76); bds.Thickness = 1; bds.Parent = badge
 local sep = Instance.new("Frame")
 sep.Size = UDim2.new(1,-16,0,1); sep.Position = UDim2.new(0,8,0,27)
 sep.BackgroundColor3 = Color3.fromRGB(55,55,60); sep.BorderSizePixel = 0; sep.Parent = panel
 _xyzVals = {}
 for i, axis in ipairs({"X","Y","Z"}) do
 local y = 30 + (i-1)*20
 local al = Instance.new("TextLabel")
 al.Size = UDim2.new(0,18,0,18); al.Position = UDim2.new(0,10,0,y)
 al.BackgroundTransparency = 1; al.Text = axis
 al.TextColor3 = Color3.fromRGB(120,120,130); al.Font = Enum.Font.GothamBold
 al.TextSize = 12; al.TextXAlignment = Enum.TextXAlignment.Left; al.Parent = panel
 local vl = Instance.new("TextLabel")
 vl.Size = UDim2.new(1,-30,0,18); vl.Position = UDim2.new(0,14,0,y)
 vl.BackgroundTransparency = 1; vl.Text = "0"
 vl.TextColor3 = Color3.fromRGB(230,230,235); vl.Font = Enum.Font.Gotham
 vl.TextSize = 12; vl.TextXAlignment = Enum.TextXAlignment.Right; vl.Parent = panel
 _xyzVals[axis] = vl
 end
 local function fmtNum(v)
 local s = tostring(math.floor(v + 0.5))
 local k; repeat s, k = string.gsub(s, "^(-?%d+)(%d%d%d)", "%1,%2") until k == 0
 return s
 end
 _xyzConn = run_service.Heartbeat:Connect(function()
 local char = localplayer.Character
 local hrp = char and char:FindFirstChild("HumanoidRootPart")
 if hrp then
 local p = hrp.Position
 _xyzVals.X.Text = fmtNum(p.X)
 _xyzVals.Y.Text = fmtNum(p.Y)
 _xyzVals.Z.Text = fmtNum(p.Z)
 else
 _xyzVals.X.Text = "-"; _xyzVals.Y.Text = "-"; _xyzVals.Z.Text = "-"
 end end)
end

local function destroyXYZOverlay()
 if _xyzConn then pcall(function() _xyzConn:Disconnect() end); _xyzConn = nil end
 if _xyzSg then pcall(function() _xyzSg:Destroy() end); _xyzSg = nil end
end
getgenv().__destroyXYZOverlay = destroyXYZOverlay

local function maybe_destroy_xyz()
 if not config.void and not config.orbit and not config.ragebot_bypass_enabled then
  destroyXYZOverlay()
 end
end

task.wait()
LeftVoid:AddToggle("vs_en", { Text="Void", Default=false, Tooltip="Makes you unhittable utilizing void movement." }):OnChanged(function(v) config.void = v
 play_toggle_sound()
 if v then
  getgenv().start_voidspam_type()
  buildXYZOverlay()
 else
  getgenv().stop_voidspam_type()
  maybe_destroy_xyz()
 end

end)

local vs_type_drop = LeftVoid:AddDropdown("vs_type_sel", { Text="Void Mode", Default=1, Values={"Defensive","Attack","Kill","Minimal"} })

LeftVoid:AddDropdown("evs_iter_mode_sel", { Text="Iteration Mode", Default="Adaptive", Values={"Hybrid","Predictive","Adaptive"} }):OnChanged(function(v) config.evs_iter_mode = v end)
LeftVoid:AddDropdown("vs_enemy_desc_sel", { Text="Enemy Description", Default="Regular", Values={"Regular", "No Evasion"} }):OnChanged(function(v) config.vs_enemy_desc = v end)
LeftVoid:AddToggle("vst_auto_kill_toggle", { Text="Auto Kill", Default=false, Tooltip="void has auto kill already but if you are losing you can enable this" }):OnChanged(function(v)
	config.vst_auto_kill = v
	if not v then getgenv().stop_ragebot_bypass_partglue() end
end)
LeftVoid:AddLabel("Disable your evasion method")
LeftVoid:AddSlider("evs_iter_count_sl", { Text="Iteration Count", Default=200, Min=1, Max=500, Rounding=0, Tooltip="Iterations per void burst frame." }):OnChanged(function(v) config.evs_iter_count = math.clamp(v, 1, 500) end)
LeftVoid:AddSlider("evs_iter_speed_sl2", { Text="Iteration Speed", Default=1, Min=1, Max=5000000, Rounding=0, Tooltip="Multiplier applied to each iteration step distance." }):OnChanged(function(v) config.evs_iter_speed = math.max(v, 1) end)

local vst_unhit_yrange_slider = nil

local function get_player_names_for_dropdown()
 local names = {"Closest"}
 for _, p in ipairs(players:GetPlayers()) do
  if p ~= localplayer then
   table.insert(names, p.Name)
  end
 end
 return names
end

local vst_attack_target_drop = LeftVoid:AddDropdown("vst_attack_target_sel", {
 Text = "Attack Target",
 Default = 1,
 Values = get_player_names_for_dropdown(),
 Visible = false,
})
vst_attack_target_drop:OnChanged(function(v)
 config.vst_attack_target_name = v
end)
players.PlayerAdded:Connect(function()
 pcall(function() vst_attack_target_drop:SetValues(get_player_names_for_dropdown()) end)
end)
players.PlayerRemoving:Connect(function()
 task.wait(0.1)
 pcall(function() vst_attack_target_drop:SetValues(get_player_names_for_dropdown()) end)
end)

LeftVoid:AddSlider("vst_spin_spd", { Text="Spin Speed", Default=1e85, Min=1, Max=1e85, Rounding=0, Tooltip="Spins you very fast while voiding." }):OnChanged(function(v) config.spin_speed = v end)
task.wait()
local VoidMotionBox = Tabs.Movement:AddRightGroupbox("Motion")
VoidMotionBox:AddToggle("vs_motion_pulse_tog", { Text="Velocity Pulse", Default=false, Tooltip="Applies a velocity spike between each iteration to make tracking harder." }):OnChanged(function(v) config.velocity_pulse = v end)
VoidMotionBox:AddSlider("vs_motion_spread_sl", { Text="Spread Distance", Default=50000, Min=1, Max=1000000000, Rounding=0, Tooltip="How far each iteration travels on all axes." }):OnChanged(function(v) config.spread_distance = v end)
VoidMotionBox:AddSlider("vs_motion_hjitter_sl", { Text="Horizontal Jitter", Default=0, Min=0, Max=1000000, Rounding=0, Tooltip="Random horizontal offset added to each iteration." }):OnChanged(function(v) config.horizontal_jitter = v end)
VoidMotionBox:AddSlider("vs_motion_vjitter_sl", { Text="Vertical Jitter", Default=0, Min=0, Max=1000000, Rounding=0, Tooltip="Random vertical offset added to each iteration" }):OnChanged(function(v) config.vertical_jitter = v end)
VoidMotionBox:AddDropdown("vs_motion_pattern_sel", { Text="Motion Pattern", Default=4, Values={"Staggered Cross","Offset Pentagon","Asymmetric Wedge","Broken Spiral","Shear Grid","Offset Bowtie","Oblique Zigzag","Fractured Diamond","Phase-Shifted Lemniscate","Alternating Trident","Skewed Hexagon","Bifurcated Sine","Chaotic Lattice","Sawtooth Orbit","Rotary Offset Star","Compressed Torus","Displaced Trefoil","Inverted Chevron","Collapsed Octagon","Wobble Crown","Anti-Diagonal Stripe","Split Parabola","Phase Jitter Ring","Stochastic Radial","Recursive Triangle","Sheared Oval","Axial Lurch","Compound Rake","Tangent Break","Glitch Burst"} }):OnChanged(function(v) config.motion_pattern = v end)
VoidMotionBox:AddToggle("vs_motion_tog1", { Text="Enable X Axis", Default=true, Tooltip="Includes X axis in void iterations." }):OnChanged(function(v) config.vs_motion_tog1 = v; config.enable_x_axis = v end)
VoidMotionBox:AddToggle("vs_motion_tog2", { Text="Enable Y Axis", Default=true, Tooltip="Includes Y axis in void iterations." }):OnChanged(function(v) config.vs_motion_tog2 = v; config.enable_y_axis = v end)
VoidMotionBox:AddToggle("vs_motion_tog3", { Text="Enable Z Axis", Default=true, Tooltip="Includes Z axis in void iterations." }):OnChanged(function(v) config.vs_motion_tog3 = v; config.enable_z_axis = v end)
VoidMotionBox:AddToggle("vs_motion_tog4", { Text="Randomize Iteration Order", Default=false, Tooltip="Randomizes which axis is iterated first." }):OnChanged(function(v) config.vs_motion_tog4 = v end)
VoidMotionBox:AddToggle("vs_motion_tog5", { Text="Mirror Mode", Default=false, Tooltip="Mirrors each iteration position across all three axes simultaneously." }):OnChanged(function(v) config.vs_motion_tog5 = v end)
VoidMotionBox:AddSlider("vs_motion_x_rad", { Text="X Radius", Default=0, Min=0, Max=996283662819272, Rounding=0, Tooltip="Controls your base X coordinate offset during void." }):OnChanged(function(v) config.evs_x_radius = v end)
VoidMotionBox:AddSlider("vs_motion_y_rad", { Text="Y Radius", Default=0, Min=0, Max=996283662819272, Rounding=0, Tooltip="Controls your base Y coordinate offset during void." }):OnChanged(function(v) config.evs_y_radius = v end)
VoidMotionBox:AddSlider("vs_motion_z_rad", { Text="Z Radius", Default=0, Min=0, Max=996283662819272, Rounding=0, Tooltip="Controls your base Z coordinate offset during void." }):OnChanged(function(v) config.evs_z_radius = v end)

local function vst_update_visibility(mode)
 local is_defend = mode == "Defensive"
 local is_godmode = mode == "Godmode"
 local is_attack = mode == "Attack" or mode == "Kill"
 pcall(function() vst_bait_depth_slider:SetVisible(mode == "Bait") end)
 pcall(function() vst_unhit_yrange_slider:SetVisible(is_defend) end)
 pcall(function() vst_gm_type_drop:SetVisible(is_godmode) end)
 pcall(function()
  vst_attack_target_drop:SetValues(get_player_names_for_dropdown())
  vst_attack_target_drop:SetVisible(is_attack)
 end)
end

vst_update_visibility(config.vst_type or "Defensive")
vs_type_drop:OnChanged(function(v) config.vst_type = v
 vst_update_visibility(v)
 if config.void then
  getgenv().stop_voidspam_type(true)
  task.wait()
  getgenv().start_voidspam_type()
 end

end)

task.wait()
LeftVoid:AddToggle("vs_char_origin", { Text="Character Origin", Default=false, Tooltip="Uses your character's position as the base origin for all void offsets instead of the last void position." }):OnChanged(function(v) config.character_origin = v end)
LeftVoid:AddSlider("vs_min_dist_sl", { Text="Min Distance", Default=1, Min=1, Max=1000000000, Rounding=0 }):OnChanged(function(v) config.min_distance = v end)
LeftVoid:AddSlider("vs_max_dist_sl", { Text="Max Distance", Default=50000, Min=1, Max=1000000000, Rounding=0 }):OnChanged(function(v) config.max_distance = v end)
LeftVoid:AddSlider("vs2_dxp",{ Text="X+ Direction", Default=5000, Min=1, Max=100000000, Rounding=0 }):OnChanged(function(v) config.x_plus_direction=v end)
LeftVoid:AddSlider("vs2_dxn",{ Text="X- Direction", Default=5000, Min=1, Max=100000000, Rounding=0 }):OnChanged(function(v) config.x_minus_direction=v end)
LeftVoid:AddSlider("vs2_dyp",{ Text="Y+ Direction", Default=5000, Min=1, Max=100000000, Rounding=0 }):OnChanged(function(v) config.y_plus_direction=v end)
LeftVoid:AddSlider("vs2_dyn",{ Text="Y- Direction", Default=5000, Min=1, Max=100000000, Rounding=0 }):OnChanged(function(v) config.y_minus_direction=v end)
LeftVoid:AddSlider("vs2_dzp",{ Text="Z+ Direction", Default=5000, Min=1, Max=100000000, Rounding=0 }):OnChanged(function(v) config.z_plus_direction=v end)
LeftVoid:AddSlider("vs2_dzn",{ Text="Z- Direction", Default=5000, Min=1, Max=100000000, Rounding=0 }):OnChanged(function(v) config.z_minus_direction=v end)
task.wait()
local RandVoid = Tabs.Movement:AddRightGroupbox("Randomizer")
local randomizer_seed_input = RandVoid:AddInput("rand_seed_in", { Text="Seeds", Default="", Placeholder="Enter seed...", Numeric=false, Finished=false })
randomizer_seed_input:OnChanged(function(v) config.randomizer_seed = v end)
RandVoid:AddDropdown("rand_mode1", { Text="Mode", Default=1, Values={"Random","Uniform","Weighted","Radial","Axial","Spiral","Chaos"} }):OnChanged(function(v) config.randomizer_mode1=v end)
RandVoid:AddSlider("rand_route_count", { Text="Route Count", Default=128, Min=16, Max=512, Rounding=0 }):OnChanged(function(v) config.randomizer_route_count=v end)
RandVoid:AddSlider("rand_cand_mul", { Text="Candidates", Default=6, Min=2, Max=16, Rounding=0 }):OnChanged(function(v) config.randomizer_cand_mul=v end)
RandVoid:AddButton("Random Seed", function()
 local chars = "abcdefghijklmnopqrstuvwxyz0123456789"
 local seed = ""
 for i = 1, 12 do
  local idx = math.random(1, #chars)
  seed = seed .. chars:sub(idx, idx)
 end
 config.randomizer_seed = seed
 pcall(function() randomizer_seed_input:SetValue(seed) end)
end)

local function _lcg(s)
 return (s * 1664525 + 1013904223) % 2147483648
end

local function _lcgf(s)
 return (s % 100000) / 100000
end

local function _lcg4(s)
 local s1 = _lcg(s)
 local s2 = _lcg(s1)
 local s3 = _lcg(s2)
 local s4 = _lcg(s3)
 return s4, _lcgf(s1), _lcgf(s2), _lcgf(s3), _lcgf(s4)
end

local function _sample_candidate(s, mode, r)
 local ns, f1, f2, f3, f4 = _lcg4(s)
 local PI2 = math.pi * 2
 local x, y, z
 if mode == "Uniform" then
  x = (f1 - 0.5) * 2 * r
  y = (f2 - 0.5) * r * 0.8
  z = (f3 - 0.5) * 2 * r
 elseif mode == "Weighted" then
  local w = f4 * f4
  local ang = f1 * PI2
  local dist = r * (0.3 + w * 0.7)
  x = math.cos(ang) * dist
  y = (f2 - 0.5) * r * 0.6 * w
  z = math.sin(ang) * dist
 elseif mode == "Radial" then
  local ang = f1 * PI2
  local dist = r * (0.5 + f2 * 0.5)
  x = math.cos(ang) * dist
  y = (f3 - 0.5) * r * 0.4
  z = math.sin(ang) * dist
 elseif mode == "Axial" then
  local axis = math.floor(f1 * 3)
  local sign = (f2 < 0.5) and 1 or -1
  local mag = r * (0.5 + f3 * 0.5)
  if axis == 0 then x = sign * mag; y = (f4 - 0.5) * r * 0.3; z = (f2 - 0.5) * r * 0.3
  elseif axis == 1 then x = (f4 - 0.5) * r * 0.3; y = sign * mag; z = (f2 - 0.5) * r * 0.3
  else x = (f4 - 0.5) * r * 0.3; y = (f2 - 0.5) * r * 0.3; z = sign * mag end
 elseif mode == "Spiral" then
  local t = f4
  local ang = t * PI2 * 5 + f1 * 1.2
  local dist = r * (0.2 + t * 0.8)
  x = math.cos(ang) * dist
  y = (t - 0.5) * r * 0.7 + (f2 - 0.5) * r * 0.1
  z = math.sin(ang) * dist
 elseif mode == "Chaos" then
  x = math.sin(f1 * 37.3 + f3 * 11.7) * r
  y = math.cos(f2 * 19.1 + f4 * 23.3) * r * 0.6
  z = math.sin(f3 * 41.7 + f1 * 7.9) * r
 else
  local ang = f1 * PI2
  local elev = (f2 - 0.5) * math.pi
  local dist = r * (0.4 + f3 * 0.6)
  x = math.cos(elev) * math.cos(ang) * dist
  y = math.sin(elev) * dist * 0.55
  z = math.cos(elev) * math.sin(ang) * dist
 end
 return ns, x, y, z
end

local _TRANSLOC_THRESHOLD = 110000
local _MIN_STEP = 80000

local function _score_candidate(cx, cy, cz, prev_x, prev_y, prev_z, route, route_len)
 local score = 0
 local dx = cx - prev_x
 local dy = cy - prev_y
 local dz = cz - prev_z
 local step_dist = math.sqrt(dx*dx + dy*dy + dz*dz)
 if step_dist < _MIN_STEP then return -1e9 end
 local mag = math.sqrt(cx*cx + cy*cy + cz*cz)
 if mag < _TRANSLOC_THRESHOLD then
  score = score - ((_TRANSLOC_THRESHOLD - mag) / _TRANSLOC_THRESHOLD) * 200
 else
  score = score + math.min((mag - _TRANSLOC_THRESHOLD) / _TRANSLOC_THRESHOLD, 1) * 40
 end
 local abs_y = math.abs(cy)
 if abs_y > 50000 then
  score = score + math.min(abs_y / 500000, 1) * 60
 end
 local step_norm = step_dist / math.max(mag, 1)
 score = score + math.min(step_norm, 1) * 50
 if route_len > 0 then
  local prev2_x = route[route_len][1]
  local prev2_y = route[route_len][2]
  local prev2_z = route[route_len][3]
  local v1x = prev_x - prev2_x
  local v1y = prev_y - prev2_y
  local v1z = prev_z - prev2_z
  local v1m = math.sqrt(v1x*v1x + v1y*v1y + v1z*v1z)
  local v2x = cx - prev_x
  local v2y = cy - prev_y
  local v2z = cz - prev_z
  local v2m = math.sqrt(v2x*v2x + v2y*v2y + v2z*v2z)
  if v1m > 0 and v2m > 0 then
   local dot = (v1x*v2x + v1y*v2y + v1z*v2z) / (v1m * v2m)
   score = score + (1 - math.abs(dot)) * 80
  end
 end
 local min_sep = math.huge
 local check_n = math.min(route_len, 12)
 local check_start = route_len - check_n + 1
 for i = check_start, route_len do
  if route[i] then
   local ex = cx - route[i][1]
   local ey = cy - route[i][2]
   local ez = cz - route[i][3]
   local sep = math.sqrt(ex*ex + ey*ey + ez*ez)
   if sep < min_sep then min_sep = sep end
  end
 end
 if min_sep ~= math.huge then
  score = score + math.min(min_sep / _TRANSLOC_THRESHOLD, 2) * 70
 end
 local pmag = math.sqrt(prev_x*prev_x + prev_y*prev_y + prev_z*prev_z)
 if pmag > 0 and mag > 0 then
  local pdx = prev_x / pmag
  local pdy = prev_y / pmag
  local pdz = prev_z / pmag
  local ndx = cx / mag
  local ndy = cy / mag
  local ndz = cz / mag
  local dir_dot = pdx*ndx + pdy*ndy + pdz*ndz
  score = score + (1 - math.max(dir_dot, 0)) * 55
 end
 return score
end

local function _build_seed_routes(seed_str, mode, count, spread)
 local hash = 0
 for i = 1, #seed_str do
  hash = (hash * 31 + string.byte(seed_str, i)) % 2147483647
 end
 math.randomseed(hash)
 local s = hash
 local n = math.max(count or 128, 16)
 local r = math.max(spread or 500000, 1)
 local cand_mul = math.max(config.randomizer_cand_mul or 6, 2)
 local route = {}
 local s2 = _lcg(s)
 local _, sx, sy, sz = _lcg4(s2)
 local prev_x = sx * r * 0.1
 local prev_y = sy * r * 0.1
 local prev_z = sz * r * 0.1
 for i = 1, n do
  local best_score = -1e18
  local best_x, best_y, best_z = prev_x, prev_y + r * 0.5, prev_z
  local cs = s
  for _ = 1, cand_mul do
   cs = _lcg(cs)
   local ns, cx, cy, cz = _sample_candidate(cs, mode, r)
   cs = ns
   local sc = _score_candidate(cx, cy, cz, prev_x, prev_y, prev_z, route, i - 1)
   if sc > best_score then
    best_score = sc
    best_x = cx
    best_y = cy
    best_z = cz
   end
  end
  s = _lcg(_lcg(_lcg(s)))
  route[i] = {best_x, best_y, best_z}
  prev_x = best_x
  prev_y = best_y
  prev_z = best_z
 end
 local out = {}
 for i = 1, n do
  out[i] = Vector3.new(route[i][1], route[i][2], route[i][3])
 end
 return out
end

getgenv().__seed_routes = getgenv().__seed_routes or {}
getgenv().__seed_route_idx = getgenv().__seed_route_idx or 1

RandVoid:AddButton("Generate Seed", function()
 local seed = config.randomizer_seed or ""
 if seed == "" then return end
 local hash = 0
 for i = 1, #seed do
  hash = (hash * 31 + string.byte(seed, i)) % 2147483647
 end
 math.randomseed(hash)
 local mode = config.randomizer_mode1 or "Random"
 local count = config.randomizer_route_count or 128
 local spread = math.max(config.spread_distance or 500000, 1)
 local routes = _build_seed_routes(seed, mode, count, spread)
 getgenv().__seed_routes = routes
 getgenv().__seed_route_idx = 1
 config.randomizer_active = true
 notify("Seed Routes", "Optimized " .. #routes .. " routes (" .. mode .. ")")
end)

RandVoid:AddButton("Clear Seed", function()
 getgenv().__seed_routes = {}
 getgenv().__seed_route_idx = 1
 config.randomizer_active = false
end)

task.wait()

task.wait()
CustVoid:AddToggle("vs_stab", { Text="Stabilizer", Default=false }):OnChanged(function(v) config.stabilizer=v end)
CustVoid:AddSlider("vs_stb", { Text="Stability", Default=50, Min=1, Max=100, Rounding=0 }):OnChanged(function(v) config.stability=v end)
CustVoid:AddToggle("vs_smooth",{ Text="Smoothness", Default=false }):OnChanged(function(v) config.smoothness=v end)
CustVoid:AddSlider("vs_smo", { Text="Smooth Alpha", Default=10, Min=1, Max=100, Rounding=0 }):OnChanged(function(v) config.smooth_alpha=v end)
CustVoid:AddToggle("vs_res", { Text="Position Resolver", Default=false }):OnChanged(function(v) config.position_resolver=v end)
CustVoid:AddToggle("vs_restore",{ Text="Position Restore", Default=false }):OnChanged(function(v) config.position_restore=v end)
CustVoid:AddToggle("vs_pos_cl",  { Text="Position Clamp", Default=false }):OnChanged(function(v) config.position_clamp=v end)
CustVoid:AddSlider("vs_clamp_r", { Text="Clamp Radius", Default=50000, Min=100, Max=100000000, Rounding=0 }):OnChanged(function(v) config.clamp_radius=v end)
task.wait()
local BoxOrbitLeft = OrbitTab
local BoxOrbitRight = OrbitTab
BoxOrbitLeft:AddToggle("orbit_en", { Text="Orbit", Default=false, Tooltip="Orbits your character in a void-driven orbital pattern." }):OnChanged(function(v)
 config.orbit = v
 play_toggle_sound()
 if v then getgenv().start_orbit(); buildXYZOverlay() else getgenv().stop_orbit(); maybe_destroy_xyz() end

end)

BoxOrbitLeft:AddSlider("orbit_rad", { Text="Orbit Radius", Default=50000, Min=1, Max=500000, Rounding=0 }):OnChanged(function(v) config.orbit_radius = v end)
BoxOrbitLeft:AddSlider("orbit_spd", { Text="Orbit Speed", Default=5, Min=1, Max=200, Rounding=0 }):OnChanged(function(v) config.orbit_speed = v end)
BoxOrbitLeft:AddSlider("orbit_iters", { Text="Iterations", Default=100, Min=1, Max=500, Rounding=0 }):OnChanged(function(v) config.orbit_iterations = v end)
BoxOrbitLeft:AddSlider("orbit_hgt", { Text="Height Offset", Default=0, Min=-500000, Max=500000, Rounding=0 }):OnChanged(function(v) config.height_offset = v end)
BoxOrbitLeft:AddSlider("orbit_jit", { Text="Jitter", Default=0, Min=0, Max=100000, Rounding=0 }):OnChanged(function(v) config.orbit_jitter = v end)
BoxOrbitLeft:AddSlider("orbit_yb", { Text="Y Bias", Default=0, Min=-500000, Max=0, Rounding=0 }):OnChanged(function(v) config.y_bias = v end)
BoxOrbitLeft:AddSlider("orbit_df", { Text="Depth Floor", Default=0, Min=0, Max=500000, Rounding=0 }):OnChanged(function(v) config.depth_floor = v end)
BoxOrbitLeft:AddSlider("orbit_tight", { Text="Tightness", Default=10, Min=1, Max=100, Rounding=0 }):OnChanged(function(v) config.tightness = v end)
BoxOrbitLeft:AddSlider("orbit_wfreq", { Text="Wave Freq", Default=1, Min=1, Max=20, Rounding=0 }):OnChanged(function(v) config.wave_freq = v end)
BoxOrbitLeft:AddSlider("orbit_phase", { Text="Phase Offset", Default=0, Min=0, Max=360, Rounding=0 }):OnChanged(function(v) config.phase_offset = math.rad(v) end)
BoxOrbitLeft:AddSlider("orbit_layers", { Text="Layer Count", Default=1, Min=1, Max=8, Rounding=0 }):OnChanged(function(v) config.layer_count = v end)
BoxOrbitLeft:AddSlider("orbit_loff", { Text="Layer Offset", Default=0, Min=0, Max=360, Rounding=0 }):OnChanged(function(v) config.layer_offset = v end)
BoxOrbitLeft:AddSlider("orbit_wstr", { Text="Warp Strength", Default=50, Min=1, Max=100, Rounding=0 }):OnChanged(function(v) config.warp_strength = v end)
BoxOrbitLeft:AddSlider("orbit_chaos", { Text="Chaos Blend", Default=0, Min=0, Max=100, Rounding=0 }):OnChanged(function(v) config.orbit_chaos_blend = v end)
BoxOrbitLeft:AddDropdown("orbit_pat_sel", { Text="Pattern", Default=1, Values={"Circle","Ellipse","Figure8","Helix","Wave","Spiral","Pulse"} }):OnChanged(function(v) config.orbit_pattern = v end)
BoxOrbitLeft:AddDropdown("orbit_target_sel", { Text="Target", Default=1, Values={"Self","Closest"} }):OnChanged(function(v) config.orbit_target = v end)
BoxOrbitLeft:AddDropdown("orbit_axis_sel", { Text="Orbit Axis", Default=1, Values={"Y","X","Z"} }):OnChanged(function(v) config.orbit_axis = v end)
BoxOrbitLeft:AddDropdown("orbit_dir_sel", { Text="Direction", Default=1, Values={"Clockwise","Counter-clockwise"} }):OnChanged(function(v) config.orbit_direction = v end)
BoxOrbitLeft:AddDropdown("orbit_warp_sel", { Text="Warp Mode", Default=1, Values={"Instant","Lerp","Spring","Bounce","Elastic"} }):OnChanged(function(v) config.orbit_warp_mode = v end)
BoxOrbitLeft:AddDropdown("orbit_fall_sel", { Text="Falloff", Default=1, Values={"None","Linear","Exp","Sine","Cosine"} }):OnChanged(function(v) config.orbit_falloff = v end)
BoxOrbitLeft:AddToggle("orbit_kv", { Text="Kill Velocity", Default=true }):OnChanged(function(v) config.orbit_kill_velocity = v end)
BoxOrbitLeft:AddToggle("orbit_ix", { Text="Invert X", Default=false }):OnChanged(function(v) config.orbit_invert_x = v end)
BoxOrbitLeft:AddToggle("orbit_iz", { Text="Invert Z", Default=false }):OnChanged(function(v) config.orbit_invert_z = v end)
task.wait()
if not config.profile then config.profile = {} end
if not config.profile.skinchanger then config.profile.skinchanger = { enabled=false, userid="1" } end
if not config.profile.fpsspoof then config.profile.fpsspoof = { enabled=false, value="1", fraud=false } end
if not config.profile.msspoof then config.profile.msspoof = { enabled=false, value="1", fraud=false } end
if not config.profile.regionspoof then config.profile.regionspoof = { enabled=false, value=".gg/meowwc" } end
local glue_heartbeat_conn = nil
local glue_active         = false

local glue_target_cache  = nil
local glue_target_hrp    = nil
local glue_target_head   = nil
local glue_target_dirty  = true
local glue_target_last   = 0

local _glue_player_conns = {}

local _glue_weld     = nil
local _glue_bound_hrp = nil
local _glue_bound_tgt = nil

local function glue_destroy_constraint()
	if _glue_weld then pcall(function() _glue_weld:Destroy() end); _glue_weld = nil end
	_glue_bound_hrp = nil
	_glue_bound_tgt = nil
end

local function glue_build_constraint(hrp, tgt)
	glue_destroy_constraint()
	local ok_hrp, hrp_pos = pcall(function() return hrp.Position end)
	local ok_tgt, tgt_cf = pcall(function() return tgt.CFrame end)
	if not ok_hrp or not ok_tgt then return end
	if not tt_ok3(hrp_pos.X, hrp_pos.Y, hrp_pos.Z) then return end
	if not tt_okv(tgt_cf.Position) then return end
	local dist = config.glue_distance or 0
	local height = config.glue_height or 0
	local to_tgt = (hrp_pos - tgt_cf.Position)
	local horiz = Vector3.new(to_tgt.X, 0, to_tgt.Z)
	local horiz_unit = horiz.Magnitude > 0.001 and horiz.Unit or Vector3.new(0, 0, 1)
	local offset = horiz_unit * dist + Vector3.new(0, height, 0)
	local target_pos = tgt_cf.Position + offset
	if not tt_ok3(target_pos.X, target_pos.Y, target_pos.Z) then return end
	pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero end)
	pcall(function() hrp.AssemblyAngularVelocity = Vector3.zero end)
	pcall(function() hrp.CFrame = tgt_cf + offset end)
	local w = Instance.new("WeldConstraint")
	w.Name    = "__glue_weld"
	w.Part0   = hrp
	w.Part1   = tgt
	w.Parent  = hrp
	_glue_weld      = w
	_glue_bound_hrp = hrp
	_glue_bound_tgt = tgt
end

local function glue_resolve_target()
	local now = tick()
	local cache_ttl = (glue_target_cache ~= nil) and 0.033 or 0
	if not glue_target_dirty and (now - glue_target_last) < cache_ttl then
		if glue_target_cache and glue_target_cache.Character then
			local h = glue_target_cache.Character:FindFirstChildOfClass("Humanoid")
			local t_hrp2 = glue_target_cache.Character:FindFirstChild("HumanoidRootPart")
			if h and h.Health > 0 and t_hrp2 then
				return glue_target_cache, glue_target_hrp, glue_target_head
			end
		end
	end
	glue_target_dirty = false
	glue_target_last  = now
	local my_hrp = getgenv().get_hrp(localplayer)
	if not my_hrp then glue_target_cache = nil; glue_target_hrp = nil; glue_target_head = nil; return nil end
	local named_sel = config.glue_target_player_name
	if named_sel and named_sel ~= "" and named_sel ~= "Closest" then
		local sp = players:FindFirstChild(named_sel)
		if sp and sp ~= localplayer and sp.Character then
			local s_hrp = sp.Character:FindFirstChild("HumanoidRootPart")
			local s_hum = sp.Character:FindFirstChildOfClass("Humanoid")
			local s_ff  = not sp.Character:FindFirstChildOfClass("ForceField")
			if s_hrp and s_hum and s_hum.Health > 0 and s_ff then
				glue_target_cache = sp
				glue_target_hrp   = s_hrp
				glue_target_head  = sp.Character:FindFirstChild("Head")
				return glue_target_cache, glue_target_hrp, glue_target_head
			end
		end
	end
	local my_pos = my_hrp.Position
	local best, best_d = nil, math.huge
	for _, p in ipairs(players:GetPlayers()) do
		if p ~= localplayer and p.Character then
			local t_hrp = p.Character:FindFirstChild("HumanoidRootPart")
			local hum   = p.Character:FindFirstChildOfClass("Humanoid")
			local no_ff = not p.Character:FindFirstChildOfClass("ForceField")
			local diff  = localplayer.Team == nil or p.Team == nil or localplayer.Team ~= p.Team
			if t_hrp and hum and hum.Health > 0 and no_ff and diff then
				local dx = t_hrp.Position.X - my_pos.X
				local dy = t_hrp.Position.Y - my_pos.Y
				local dz = t_hrp.Position.Z - my_pos.Z
				local dsq = dx*dx + dy*dy + dz*dz
				if dsq < best_d then best_d = dsq; best = p end
			end
		end
	end
	glue_target_cache = best
	if best and best.Character then
		glue_target_hrp  = best.Character:FindFirstChild("HumanoidRootPart")
		glue_target_head = best.Character:FindFirstChild("Head")
	else
		glue_target_hrp  = nil
		glue_target_head = nil
	end
	return glue_target_cache, glue_target_hrp, glue_target_head
end

getgenv().start_glue = function()
	if glue_active then return end
	glue_active         = true
	config.glue_enabled = true
	glue_target_cache   = nil
	glue_target_hrp     = nil
	glue_target_head    = nil
	glue_target_dirty   = true

	for _, p in ipairs(players:GetPlayers()) do
		local c  = p.CharacterAdded:Connect(function() glue_target_dirty = true end)
		local c2 = p.CharacterRemoving:Connect(function() glue_target_dirty = true end)
		table.insert(_glue_player_conns, c)
		table.insert(_glue_player_conns, c2)
	end
	local _glue_pa = players.PlayerAdded:Connect(function(p)
		glue_target_dirty = true
		local c  = p.CharacterAdded:Connect(function() glue_target_dirty = true end)
		local c2 = p.CharacterRemoving:Connect(function() glue_target_dirty = true end)
		table.insert(_glue_player_conns, c)
		table.insert(_glue_player_conns, c2)
	end)
	local _glue_pr = players.PlayerRemoving:Connect(function() glue_target_dirty = true end)
	table.insert(_glue_player_conns, _glue_pa)
	table.insert(_glue_player_conns, _glue_pr)

	local glue_hb_last = 0
	local _glue_vs_phase_start = tick()
	local _glue_vs_in_void = true
	local _GLUE_VOID_DURATION = config.glue_hide_time or 0.45
	local _GLUE_GLUE_DURATION = config.glue_attack_time or 0.55
	local _vdb_prev_x_g, _vdb_prev_y_g, _vdb_prev_z_g = nil, nil, nil

	local function _glue_do_defend_burst(hrp)
		pcall(function() workspace.FallenPartsDestroyHeight = -math.huge end)
		pcall(function() workspace.FallenPartsDestroyHeight = 0/0 end)
		local iters = math.max(config.evs_iter_count or 200, 1)
		if iters > 500 then iters = 500 end
		local mt_vdb = getrawmetatable(hrp)
		local ni_vdb = mt_vdb and rawget(mt_vdb, "__newindex")
		local use_x = config.enable_x_axis ~= false
		local use_y = config.enable_y_axis ~= false
		local use_z = config.enable_z_axis ~= false
		local _hrp_pos = hrp.Position
		local origin_x, origin_y, origin_z = _hrp_pos.X, _hrp_pos.Y, _hrp_pos.Z
		local _VDB_CHAIN_MIN = 25000000
		local _VDB_CHAIN_MAX = 27000000
		local _VDB_AXIS_CAP  = math.huge
		local _V0 = Vector3.zero
		local _prev_x = _vdb_prev_x_g or origin_x
		local _prev_y = _vdb_prev_y_g or origin_y
		local _prev_z = _vdb_prev_z_g or origin_z
		local _rnd = math.random
		local _cf  = CFrame.new
		if ni_vdb then
			pcall(function()
				for i = 1, iters do
					local dist = _VDB_CHAIN_MIN + _rnd() * (_VDB_CHAIN_MAX - _VDB_CHAIN_MIN)
					local nx = use_x and (_prev_x + (_rnd() < 0.5 and dist or -dist)) or _prev_x
					local ny = use_y and (_prev_y + (_rnd() < 0.5 and dist or -dist)) or _prev_y
					local nz = use_z and (_prev_z + (_rnd() < 0.5 and dist or -dist)) or _prev_z
					if not tt_ok3(nx, ny, nz) then nx, ny, nz = _prev_x, _prev_y, _prev_z end
					if nx >  _VDB_AXIS_CAP then nx =  _VDB_AXIS_CAP elseif nx < -_VDB_AXIS_CAP then nx = -_VDB_AXIS_CAP end
					if ny >  _VDB_AXIS_CAP then ny =  _VDB_AXIS_CAP elseif ny < -_VDB_AXIS_CAP then ny = -_VDB_AXIS_CAP end
					if nz >  _VDB_AXIS_CAP then nz =  _VDB_AXIS_CAP elseif nz < -_VDB_AXIS_CAP then nz = -_VDB_AXIS_CAP end
					ni_vdb(hrp, "AssemblyLinearVelocity", _V0)
					ni_vdb(hrp, "CFrame", _cf(nx, ny, nz))
					_prev_x, _prev_y, _prev_z = nx, ny, nz
				end
				ni_vdb(hrp, "AssemblyLinearVelocity", _V0)
				ni_vdb(hrp, "AssemblyAngularVelocity", _V0)
			end)
		else
			pcall(function()
				for i = 1, iters do
					local dist = _VDB_CHAIN_MIN + _rnd() * (_VDB_CHAIN_MAX - _VDB_CHAIN_MIN)
					local nx = use_x and (_prev_x + (_rnd() < 0.5 and dist or -dist)) or _prev_x
					local ny = use_y and (_prev_y + (_rnd() < 0.5 and dist or -dist)) or _prev_y
					local nz = use_z and (_prev_z + (_rnd() < 0.5 and dist or -dist)) or _prev_z
					if not tt_ok3(nx, ny, nz) then nx, ny, nz = _prev_x, _prev_y, _prev_z end
					if nx >  _VDB_AXIS_CAP then nx =  _VDB_AXIS_CAP elseif nx < -_VDB_AXIS_CAP then nx = -_VDB_AXIS_CAP end
					if ny >  _VDB_AXIS_CAP then ny =  _VDB_AXIS_CAP elseif ny < -_VDB_AXIS_CAP then ny = -_VDB_AXIS_CAP end
					if nz >  _VDB_AXIS_CAP then nz =  _VDB_AXIS_CAP elseif nz < -_VDB_AXIS_CAP then nz = -_VDB_AXIS_CAP end
					hrp.AssemblyLinearVelocity = _V0
					hrp.CFrame = _cf(nx, ny, nz)
					_prev_x, _prev_y, _prev_z = nx, ny, nz
				end
				hrp.AssemblyLinearVelocity = _V0
				hrp.AssemblyAngularVelocity = _V0
			end)
		end
		_vdb_prev_x_g, _vdb_prev_y_g, _vdb_prev_z_g = _prev_x, _prev_y, _prev_z
		pcall(function() workspace.FallenPartsDestroyHeight = -math.huge end)
	end

	glue_heartbeat_conn = run_service.Heartbeat:Connect(function()
		if not config.glue_enabled then return end
		local now = tick()
		if now - glue_hb_last < 0.05 then return end
		glue_hb_last = now
		local hrp = getgenv().get_hrp(localplayer)
		if not hrp then return end
		local hum = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 then
			glue_destroy_constraint()
			return
		end
		if not config.voidspam_enabled then
			local _, t_hrp, head = glue_resolve_target()
			local tgt = head or t_hrp
			if not tgt then
				glue_destroy_constraint()
				return
			end
			if _glue_bound_hrp ~= hrp or _glue_bound_tgt ~= tgt
				or not _glue_weld or not _glue_weld.Parent then
				pcall(glue_build_constraint, hrp, tgt)
			end
			return
		end
		local elapsed = now - _glue_vs_phase_start
		if _glue_vs_in_void then
			if elapsed < _GLUE_VOID_DURATION then
				glue_destroy_constraint()
				pcall(_glue_do_defend_burst, hrp)
			else
				_glue_vs_in_void = false
				_glue_vs_phase_start = now
				_vdb_prev_x_g, _vdb_prev_y_g, _vdb_prev_z_g = nil, nil, nil
			end
		else
			if elapsed < _GLUE_GLUE_DURATION then
				local _, t_hrp, head = glue_resolve_target()
				local tgt = head or t_hrp
				if not tgt then
					glue_destroy_constraint()
					return
				end
				if _glue_bound_hrp ~= hrp or _glue_bound_tgt ~= tgt
					or not _glue_weld or not _glue_weld.Parent then
					pcall(glue_build_constraint, hrp, tgt)
				end
			else
				_glue_vs_in_void = true
				_glue_vs_phase_start = now
				glue_destroy_constraint()
			end
		end
	end)
end

getgenv().stop_glue = function()
	glue_active = false
	config.glue_enabled = false
	glue_destroy_constraint()
	if glue_heartbeat_conn then glue_heartbeat_conn:Disconnect(); glue_heartbeat_conn = nil end
	for _, c in ipairs(_glue_player_conns) do pcall(function() c:Disconnect() end) end
	_glue_player_conns = {}
	glue_target_cache  = nil
	glue_target_hrp    = nil
	glue_target_head   = nil
	glue_target_dirty  = true
	local hum = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		pcall(function() hum.AutoRotate    = true end)
		pcall(function() hum.PlatformStand = false end)
		pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
		task.defer(function()
			local h2 = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")
			if h2 then
				pcall(function() h2.AutoRotate    = true end)
				pcall(function() h2.PlatformStand = false end)
				if h2:GetState() == Enum.HumanoidStateType.Physics then
					pcall(function() h2:ChangeState(Enum.HumanoidStateType.GettingUp) end)
				end
			end
		end)
		task.delay(0.1, function()
			local h3 = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")
			if h3 then
				pcall(function() h3.AutoRotate    = true end)
				pcall(function() h3.PlatformStand = false end)
				if h3:GetState() == Enum.HumanoidStateType.Physics then
					pcall(function() h3:ChangeState(Enum.HumanoidStateType.Running) end)
				end
			end
		end)
	end
end

local pb_conn = nil
local pb_active = false
local pb_rotFn_inner    = nil
local pb_camTable_inner = nil
local pb_orig_inner     = nil
local pb_rs_conn2_inner = nil
local pb_rs_conn3_inner = nil

local function pb_nz_inner(a)
	return (a + math.pi) % (2 * math.pi) - math.pi
end

local function pb_nearest_inner()
	local myChar = localplayer.Character
	local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not myHRP then return end
	local best, bestD = nil, math.huge
	for _, p in ipairs(players:GetPlayers()) do
		if p ~= localplayer and p.Character then
			local hrp = p.Character:FindFirstChild("HumanoidRootPart")
			local hum = p.Character:FindFirstChildOfClass("Humanoid")
			if hrp and hum and hum.Health > 0 then
				local d = (myHRP.Position - hrp.Position).Magnitude
				if d < bestD then bestD = d; best = p end
			end
		end
	end
	return best
end

local function pb_apply_inner()
	if not config.perfect_block_enabled then return end
	if not pb_camTable_inner then return end
	local tgt = pb_nearest_inner()
	if not tgt then return end
	local eChar = tgt.Character
	if not eChar then return end
	local eHRP = eChar:FindFirstChild("HumanoidRootPart")
	if not eHRP then return end
	local eHead = eChar:FindFirstChild("Head")
	local myChar = localplayer.Character
	local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not myHRP then return end
	local eLook = eHRP.CFrame.LookVector
	local yaw   = math.atan2(eLook.X, eLook.Z)
	local myYaw = pb_nz_inner(yaw + math.pi)
	local pitch = 0
	if eHead then
		pitch = math.asin(math.clamp(eHead.CFrame.LookVector.Y, -1, 1))
	end
	pb_camTable_inner.Rotation = Vector2.new(-pitch, myYaw)
	local counter = Vector3.new(-eLook.X, 0, -eLook.Z)
	if counter.Magnitude > 0.001 then
		pcall(function()
			myHRP.CFrame = CFrame.lookAt(myHRP.Position, myHRP.Position + counter.Unit)
			myHRP.AssemblyAngularVelocity = Vector3.zero
		end)
	end
end

getgenv().start_perfect_block = function()
	if pb_active then return end
	pb_active = true
	config.perfect_block_enabled = true
	pcall(function()
		pb_rotFn_inner = filtergc("function", {Name = "_UpdateCharacterRotation"}, true)
		if not pb_rotFn_inner then return end
		pb_camTable_inner = nil
		for _, v in ipairs(debug.getupvalues(pb_rotFn_inner)) do
			if type(v) == "table" and typeof(v.Rotation) == "Vector2" then
				pb_camTable_inner = v
				break
			end
		end
		if not pb_camTable_inner then return end
		pcall(function()
			run_service:BindToRenderStep("__pb_mrot", Enum.RenderPriority.Character.Value - 1, pb_apply_inner)
		end)
		if pb_orig_inner then
			pcall(function() hookfunction(pb_rotFn_inner, pb_orig_inner) end)
			pb_orig_inner = nil
		end
		pb_orig_inner = hookfunction(pb_rotFn_inner, function(...)
			pb_apply_inner()
			return pb_orig_inner(...)
		end)
	end)
end

getgenv().stop_perfect_block = function()
	pb_active = false
	config.perfect_block_enabled = false
	pcall(function() run_service:UnbindFromRenderStep("__pb_mrot") end)
	if pb_rs_conn2_inner then pb_rs_conn2_inner:Disconnect(); pb_rs_conn2_inner = nil end
	if pb_rs_conn3_inner then pb_rs_conn3_inner:Disconnect(); pb_rs_conn3_inner = nil end
	if pb_orig_inner and pb_rotFn_inner then
		pcall(function() hookfunction(pb_rotFn_inner, pb_orig_inner) end)
		pb_orig_inner = nil
	end
	pb_rotFn_inner    = nil
	pb_camTable_inner = nil
	if pb_conn then pb_conn:Disconnect(); pb_conn = nil end
end

local riot_abuser_active = false
local riot_abuser_conn = nil
local riot_abuser_rotFn = nil
local riot_abuser_camTable = nil
local riot_abuser_orig = nil
local riot_abuser_angle = 0

local function ra_nz(a)
	return (a + math.pi) % (2 * math.pi) - math.pi
end

local function ra_nearest()
	local myChar = localplayer.Character
	local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not myHRP then return end
	local best, bestD = nil, math.huge
	for _, p in ipairs(players:GetPlayers()) do
		if p ~= localplayer and p.Character then
			local hrp = p.Character:FindFirstChild("HumanoidRootPart")
			local hum = p.Character:FindFirstChildOfClass("Humanoid")
			if hrp and hum and hum.Health > 0 then
				local d = (myHRP.Position - hrp.Position).Magnitude
				if d < bestD then bestD = d; best = p end
			end
		end
	end
	return best
end

local _ra_tvel_x, _ra_tvel_y, _ra_tvel_z = 0, 0, 0
local _ra_last_epos_x, _ra_last_epos_y, _ra_last_epos_z = nil, nil, nil
local _ra_frame_acc = 0

local function ra_apply()
	if not config.riot_abuser_enabled then return end
	if not riot_abuser_camTable then return end
	local tgt = ra_nearest()
	if not tgt then return end
	local eChar = tgt.Character
	if not eChar then return end
	local eHRP = eChar:FindFirstChild("HumanoidRootPart")
	if not eHRP then return end
	local myChar = localplayer.Character
	local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not myHRP then return end
	local epos = eHRP.Position
	if _ra_last_epos_x then
	 local alpha = 0.35
	 _ra_tvel_x = _ra_tvel_x + (epos.X - _ra_last_epos_x - _ra_tvel_x) * alpha
	 _ra_tvel_y = _ra_tvel_y + (epos.Y - _ra_last_epos_y - _ra_tvel_y) * alpha
	 _ra_tvel_z = _ra_tvel_z + (epos.Z - _ra_last_epos_z - _ra_tvel_z) * alpha
	end
	_ra_last_epos_x = epos.X
	_ra_last_epos_y = epos.Y
	_ra_last_epos_z = epos.Z
	local pred_epos = Vector3.new(epos.X + _ra_tvel_x * 4, epos.Y + _ra_tvel_y * 4, epos.Z + _ra_tvel_z * 4)
	local spinRad = math.rad(config.riot_abuser_spin_speed or 720)
	riot_abuser_angle = ra_nz(riot_abuser_angle + spinRad * (1 / 60))
	local pitch = math.rad(config.riot_abuser_pitch or 0)
	riot_abuser_camTable.Rotation = Vector2.new(-pitch, riot_abuser_angle)
	local radius = config.riot_abuser_iterate_radius or 50
	local base_pos = myHRP.Position
	local towards_pred = Vector3.new(pred_epos.X - base_pos.X, 0, pred_epos.Z - base_pos.Z)
	local towards_len = math.sqrt(towards_pred.X*towards_pred.X + towards_pred.Z*towards_pred.Z)
	local bias_x, bias_z = 0, 0
	if towards_len > 0.001 then
	 bias_x = (towards_pred.X / towards_len) * radius * 0.3
	 bias_z = (towards_pred.Z / towards_len) * radius * 0.3
	end
	local offsetX = math.cos(riot_abuser_angle) * radius + bias_x
	local offsetZ = math.sin(riot_abuser_angle) * radius + bias_z
	local mt_ra = getrawmetatable(myHRP)
	local ni_ra = mt_ra and rawget(mt_ra, "__newindex")
	local new_cf = CFrame.new(base_pos + Vector3.new(offsetX, 0, offsetZ)) * CFrame.Angles(pitch, riot_abuser_angle, 0)
	if ni_ra then
	 pcall(ni_ra, myHRP, "CFrame", new_cf)
	 pcall(ni_ra, myHRP, "AssemblyAngularVelocity", Vector3.zero)
	 pcall(ni_ra, myHRP, "AssemblyLinearVelocity", Vector3.zero)
	else
	 pcall(function()
	  myHRP.CFrame = new_cf
	  myHRP.AssemblyAngularVelocity = Vector3.zero
	  myHRP.AssemblyLinearVelocity = Vector3.zero
	 end)
	end
	if sethiddenproperty then
	 pcall(sethiddenproperty, myHRP, "CFrame", new_cf)
	 pcall(sethiddenproperty, myHRP, "AssemblyLinearVelocity", Vector3.zero)
	end
end

getgenv().start_riot_abuser = function()
	if riot_abuser_active then return end
	riot_abuser_active = true
	config.riot_abuser_enabled = true
	riot_abuser_angle = 0
	pcall(function()
		riot_abuser_rotFn = filtergc("function", {Name = "_UpdateCharacterRotation"}, true)
		if not riot_abuser_rotFn then return end
		riot_abuser_camTable = nil
		for _, v in ipairs(debug.getupvalues(riot_abuser_rotFn)) do
			if type(v) == "table" and typeof(v.Rotation) == "Vector2" then
				riot_abuser_camTable = v
				break
			end
		end
		if not riot_abuser_camTable then return end
		pcall(function()
			run_service:BindToRenderStep("__ra_mrot", Enum.RenderPriority.Character.Value - 1, ra_apply)
		end)
		if riot_abuser_orig then
			pcall(function() hookfunction(riot_abuser_rotFn, riot_abuser_orig) end)
			riot_abuser_orig = nil
		end
		riot_abuser_orig = hookfunction(riot_abuser_rotFn, function(...)
			ra_apply()
			return riot_abuser_orig(...)
		end)
	end)
end

getgenv().stop_riot_abuser = function()
	riot_abuser_active = false
	config.riot_abuser_enabled = false
	pcall(function() run_service:UnbindFromRenderStep("__ra_mrot") end)
	if riot_abuser_orig and riot_abuser_rotFn then
		pcall(function() hookfunction(riot_abuser_rotFn, riot_abuser_orig) end)
		riot_abuser_orig = nil
	end
	riot_abuser_rotFn = nil
	riot_abuser_camTable = nil
	riot_abuser_angle = 0
end

local riot_bypass_active = false
local riot_bypass_conn = nil
local riot_bypass_target = nil
local riot_bypass_last_update = 0

local function rb_find_nearest()
	local myHRP = getgenv().get_hrp(localplayer)
	if not myHRP then return nil end
	local closest, closestDist = nil, math.huge
	for _, plr in ipairs(players:GetPlayers()) do
		if plr ~= localplayer and plr.Character then
			local hum = plr.Character:FindFirstChildOfClass("Humanoid")
			local root = plr.Character:FindFirstChild("HumanoidRootPart")
			if hum and hum.Health > 0 and root then
				local dist = (myHRP.Position - root.Position).Magnitude
				if dist < closestDist then
					closestDist = dist
					closest = plr
				end
			end
		end
	end
	return closest
end

getgenv().start_riot_bypass = function()
	if riot_bypass_active then return end
	riot_bypass_active = true
	config.riot_bypass_enabled = true
	riot_bypass_target = nil
	riot_bypass_last_update = 0
	riot_bypass_conn = run_service.Heartbeat:Connect(function()
		if not config.riot_bypass_enabled then return end
		local myHRP = getgenv().get_hrp(localplayer)
		if not myHRP then return end
		local myChar = localplayer.Character
		local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 then return end
		local now = tick()
		if now - riot_bypass_last_update >= (config.riot_bypass_update_rate or 0.5) then
			riot_bypass_target = rb_find_nearest()
			riot_bypass_last_update = now
		end
		if not riot_bypass_target or not riot_bypass_target.Character then return end
		local targetRoot = riot_bypass_target.Character:FindFirstChild("HumanoidRootPart")
		if not targetRoot then return end
		local targetPos = targetRoot.Position
		local targetLook = targetRoot.CFrame.LookVector
		local dist = config.riot_bypass_distance or 10
		local height = config.riot_bypass_height or 0
		local behindPos = targetPos - targetLook * dist + Vector3.new(0, height, 0)
		local tweenInfo = TweenInfo.new(config.riot_bypass_update_rate or 0.5, Enum.EasingStyle.Linear)
		local tween = TweenService:Create(myHRP, tweenInfo, {CFrame = CFrame.new(behindPos)})
		tween:Play()
	end)
end

getgenv().stop_riot_bypass = function()
	riot_bypass_active = false
	config.riot_bypass_enabled = false
	if riot_bypass_conn then riot_bypass_conn:Disconnect(); riot_bypass_conn = nil end
	riot_bypass_target = nil
end

local _kb_active = false
local _kb_thread = nil

getgenv().start_knife_bypass = function()
	if _kb_active then return end
	_kb_active = true
	config.knife_bypass_enabled = true
	_kb_thread = task.spawn(function()
		while config.knife_bypass_enabled do
			task.wait(2)
		end
		_kb_thread = nil
	end)
end

getgenv().stop_knife_bypass = function()
	config.knife_bypass_enabled = false
	_kb_active = false
	_kb_thread = nil
end

task.wait()
task.wait()
local BoxTeleportation = Tabs.Aggression:AddLeftGroupbox("Teleportation")
BoxTeleportation:AddToggle("glue_en", { Text="Teleportation", Default=false, Tooltip="Makes you win hvh, can teleport to UE and kicia." }):OnChanged(function(v)
	config.glue_enabled = v
	play_toggle_sound()
	if v then getgenv().start_glue() else getgenv().stop_glue() end

end)

BoxTeleportation:AddSlider("glue_dist_sl", { Text="Distance", Default=0, Min=0, Max=100, Rounding=0, Tooltip="Horizontal distance from the target." }):OnChanged(function(v)
	config.glue_distance = v
	if glue_active and _glue_weld and _glue_weld.Parent and _glue_bound_hrp and _glue_bound_tgt then
		pcall(glue_build_constraint, _glue_bound_hrp, _glue_bound_tgt)
	end
end)

BoxTeleportation:AddSlider("glue_height_sl", { Text="Height", Default=0, Min=-50, Max=50, Rounding=0, Tooltip="Vertical offset from the target's position." }):OnChanged(function(v)
	config.glue_height = v
	if glue_active and _glue_weld and _glue_weld.Parent and _glue_bound_hrp and _glue_bound_tgt then
		pcall(glue_build_constraint, _glue_bound_hrp, _glue_bound_tgt)
	end
end)

local function get_tp_player_names()
	local names = {"Closest"}
	for _, p in ipairs(players:GetPlayers()) do
		if p ~= localplayer then
			table.insert(names, p.Name)
		end
	end
	return names
end

local glue_target_drop = BoxTeleportation:AddDropdown("glue_target_sel", {
	Text = "Target Player",
	Default = 1,
	Values = get_tp_player_names(),
	Tooltip = "Choose which player to teleport to. Closest = auto-select nearest enemy.",
})
glue_target_drop:OnChanged(function(v)
	config.glue_target_player_name = v
end)

players.PlayerAdded:Connect(function()
	pcall(function() glue_target_drop:SetValues(get_tp_player_names()) end)
end)
players.PlayerRemoving:Connect(function()
	task.wait(0.1)
	pcall(function() glue_target_drop:SetValues(get_tp_player_names()) end)
end)

local glue_hide_time_sl
local glue_attack_time_sl
BoxTeleportation:AddToggle("glue_voidspam_tog", { Text="Voidspam", Default=false, Tooltip="Goes between hide and attack phases." }):OnChanged(function(v)
	config.voidspam_enabled = v
	pcall(function() glue_hide_time_sl:SetVisible(v) end)
	pcall(function() glue_attack_time_sl:SetVisible(v) end)
end)
glue_hide_time_sl = BoxTeleportation:AddSlider("glue_hide_time_sl", { Text="Hide Time", Default=45, Min=1, Max=100, Rounding=0, Suffix="s", Visible=false, Tooltip="How long (0.01s-1s) to use the defensive void burst before switching to glue." })
glue_attack_time_sl = BoxTeleportation:AddSlider("glue_attack_time_sl", { Text="Attack Time", Default=55, Min=1, Max=100, Rounding=0, Suffix="s", Visible=false, Tooltip="How long (0.01s-1s) to use the glue before switching back to void burst." })
glue_hide_time_sl:OnChanged(function(v) config.glue_hide_time = v / 100 end)
glue_attack_time_sl:OnChanged(function(v) config.glue_attack_time = v / 100 end)

local _pa_active = false
local function start_perfect_accuracy()
 if _pa_active then return end
 _pa_active = true
 config.perfect_accuracy_enabled = true
 pcall(function()
  local rs = game:GetService("ReplicatedStorage")
  local ok, ItemLibrary = pcall(require, rs.Modules.ItemLibrary)
  if not ok or not ItemLibrary then return end
  local function setPerfect(tbl)
   for _, v in pairs(tbl) do
    if typeof(v) == "table" then
     if v.ShootSpread   then v.ShootSpread   = 0 end
     if v.ShootAccuracy then v.ShootAccuracy = 0 end
     if v.ShootRecoil   then v.ShootRecoil   = 0 end
     setPerfect(v)
    end
   end
  end
  setPerfect(ItemLibrary)
 end)
end
local function stop_perfect_accuracy()
 _pa_active = false
 config.perfect_accuracy_enabled = false
end

local BoxWeaponBypass = Tabs.Aggression:AddRightGroupbox("Customization")
BoxWeaponBypass:AddToggle("wb_ragebot_bypass_en", { Text="Ragebot Bypass", Default=false, Tooltip="Bypasses ragebot." }):OnChanged(function(v)
	config.ragebot_bypass_enabled = v
	play_toggle_sound()
	if v then _dispatch_start_ragebot_bypass(); buildXYZOverlay() else _dispatch_stop_ragebot_bypass(); maybe_destroy_xyz() end
end)
BoxWeaponBypass:AddLabel("Disable your evasion method")
BoxWeaponBypass:AddToggle("wb_knife_bypass_en", { Text="Knife Bypass", Default=false, Tooltip="Makes you hit all backstabs" }):OnChanged(function(v)
	config.knife_bypass_enabled = v
	play_toggle_sound()
	if v then getgenv().start_knife_bypass() else getgenv().stop_knife_bypass() end
end)
BoxWeaponBypass:AddLabel("Disable your evasion method")
local BoxMeleeBypass = Tabs.Aggression:AddLeftGroupbox("Bypasses")
BoxMeleeBypass:AddToggle("mb_en", { Text="Melee Bypass", Default=false, Tooltip="Makes you hit all of your melee shots." }):OnChanged(function(v)
	config.kicia_counter_enabled = v
	play_toggle_sound()
	if v then getgenv().start_kicia_counter() else getgenv().stop_kicia_counter() end
end)
BoxMeleeBypass:AddLabel("Disable your evasion method")
BoxMeleeBypass:AddDropdown("mb_method_sel", { Text="Method", Default=2, Values={"Method 1", "Method 2", "Method 3"}, Tooltip="Controls which melee bypass method is used." }):OnChanged(function(v)
	if v == "Method 1" then
		config.kicia_counter_method = 1
	elseif v == "Method 2" then
		config.kicia_counter_method = 2
	elseif v == "Method 3" then
		config.kicia_counter_method = 3
	end
	if kicia_counter_active then getgenv().stop_kicia_counter(); getgenv().start_kicia_counter() end
end)
BoxMeleeBypass:AddSlider("mb_speed_sl", { Text="Speed", Default=1, Min=1, Max=9999999999999, Rounding=0, Tooltip="Controls how fast you ascend in Method 2." }):OnChanged(function(v)
	config.kicia_counter_speed = v
end)
BoxMeleeBypass:AddToggle("gb_en", { Text="Gun Bypass", Default=false, Tooltip="Makes you hit all ur gun shots" }):OnChanged(function(v)
	config.gun_bypass_enabled = v
	play_toggle_sound()
	if v then getgenv().start_gun_bypass() else getgenv().stop_gun_bypass() end
end)

BoxWeaponBypass:AddToggle("wb_disable_ragebot_counter_en", { Text="Ragebot Counter", Default=false, Tooltip="Counters script ragebots." }):OnChanged(function(v)
	config.underground_enabled = v
	play_toggle_sound()
	if v then getgenv().start_underground() else getgenv().stop_underground() end
end)
BoxWeaponBypass:AddLabel("disable rage for rage counter")
local BoxGunMods = Tabs.Aggression:AddRightGroupbox("Gun Mods")
BoxGunMods:AddToggle("gm_perfect_accuracy_en", { Text="Perfect Accuracy", Default=false, Tooltip="Makes you hit every shot (bullet redirection needed)." }):OnChanged(function(v)
	config.perfect_accuracy_enabled = v
	play_toggle_sound()
	if v then start_perfect_accuracy() else stop_perfect_accuracy() end
end)
BoxGunMods:AddToggle("gm_rapid_fire_en", { Text="Rapid Fire", Default=false, Tooltip="Removes weapon cooldown." }):OnChanged(function(v)
	config.rapid_fire = v
	play_toggle_sound()
	if v then getgenv().start_rapid_fire() else getgenv().stop_rapid_fire() end
end)

BoxGunMods:AddToggle("gm_autoshoot_en", { Text="Autoshoot", Default=false, Tooltip="Automatically fires at the closest enemy." }):OnChanged(function(v)
	config.autoshoot_enabled = v
	play_toggle_sound()
	if v then getgenv().start_autoshoot() else getgenv().stop_autoshoot() end
end)
BoxGunMods:AddToggle("gm_bullet_redirect_en", { Text="Bullet Redirection", Default=false, Tooltip="Redirects bullets toward the closest enemy through walls." }):OnChanged(function(v)
	config.bullet_redirect_enabled = v
	play_toggle_sound()
	if v then getgenv().start_bullet_redirect() else getgenv().stop_bullet_redirect() end
end)

task.wait()

task.wait()
local BoxAuto = Tabs.Misc:AddLeftGroupbox("Automation")
local BoxLoop = Tabs.Misc:AddRightGroupbox("Teleport Loop")
BoxAuto:AddToggle("ac_e", { Text="Auto Collect", Default=false }):OnChanged(function(v) config.auto_collect=v; if v then getgenv().start_autocollect() else getgenv().stop_autocollect() end end)
BoxAuto:AddSlider("ac_r", { Text="Collect Radius", Default=120, Min=10, Max=300, Rounding=0 }):OnChanged(function(v) config.collect_radius=v end)
BoxAuto:AddToggle("sz_e", { Text="Safe Zone Rescue", Default=false }):OnChanged(function(v) config.safe_zone_rescue=v; if v then getgenv().start_safe_zone() else getgenv().stop_safe_zone() end end)
BoxAuto:AddSlider("sz_y", { Text="Depth Threshold", Default=-10, Min=-200, Max=50, Rounding=0 }):OnChanged(function(v) config.depth_threshold=v end)
BoxAuto:AddToggle("rh_e", { Text="Return Home", Default=false }):OnChanged(function(v) config.return_home=v; if v then getgenv().start_return_home() else getgenv().stop_return_home() end end)
BoxAuto:AddButton("Save Home Position", function()
 local hrp = getgenv().get_hrp(localplayer)
 if hrp then getgenv().home_position = hrp.Position; tnotify("System", "Home position saved.") end
end)
BoxAuto:AddSlider("rh_d", { Text="Return Delay", Default=10, Min=1, Max=150, Rounding=0 }):OnChanged(function(v) config.return_delay=v/10 end)
BoxAuto:AddToggle("afk_tog", { Text="Anti AFK", Default=false }):OnChanged(function(v) config.anti_afk_enabled=v; if v then getgenv().start_anti_afk() else getgenv().stop_anti_afk() end end)
BoxAuto:AddToggle("ffa_tog", { Text="FFA Server Hopping", Default=false }):OnChanged(function(v) config.ffa_server_hopping=v end)
BoxLoop:AddToggle("tl_e", { Text="Teleport Loop", Default=false }):OnChanged(function(v) config.teleport_loop_enabled=v; if v then getgenv().start_teleport_loop() else getgenv().stop_teleport_loop() end end)
BoxLoop:AddSlider("tl_d", { Text="Loop Delay", Default=50, Min=10, Max=1000, Rounding=0 }):OnChanged(function(v) config.loop_delay=v/100 end)
BoxLoop:AddButton("Add Waypoint", function()
 local hrp = getgenv().get_hrp(localplayer)
 if hrp then table.insert(getgenv().loop_waypoints, hrp.Position); tnotify("System", "Waypoint added.") end
end)
BoxLoop:AddButton("Clear Waypoints", function()
 getgenv().loop_waypoints = {}; getgenv().loop_index = 1; tnotify("System", "Waypoints cleared.")
end)
task.wait()

local BoxTranslocation = Tabs.Defense:AddRightGroupbox("Translocation")

local function start_translocation()
    if translocation_active then return end
    translocation_active = true
    config.translocation = true
    _movement_save_pos()
    if translocation_conn then translocation_conn:Disconnect() end
    local kt_last = 0
    translocation_conn = run_service.Heartbeat:Connect(function()
        if not config.translocation then return end
        local now = tick()
        if now - kt_last < 0.1 then return end
        kt_last = now
        local hrp = getgenv().get_hrp(localplayer)
        if not hrp then return end
        local hum = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return end
        local hasTargets = false
        for _, p in ipairs(players:GetPlayers()) do
            if p ~= localplayer and p.Character then
                local t_hrp2 = p.Character:FindFirstChild("HumanoidRootPart")
                local hum2 = p.Character:FindFirstChildOfClass("Humanoid")
                local no_ff2 = not p.Character:FindFirstChildOfClass("ForceField")
                local diff_team2 = localplayer.Team == nil or p.Team == nil or localplayer.Team ~= p.Team
                if t_hrp2 and hum2 and hum2.Health > 0 and no_ff2 and diff_team2 then hasTargets = true; break end
            end
        end
        local dest_cf = nil
        pcall(function()
            dest_cf = translocateEvade(hrp.CFrame, hasTargets)
        end)
        if not dest_cf then return end
        local dest_pos = dest_cf.Position
        if not tt_okv(dest_pos) then return end
        local V0 = Vector3.zero
        pcall(function()
            hrp.AssemblyLinearVelocity = V0
            hrp.AssemblyAngularVelocity = V0
            hrp.CFrame = CFrame.new(dest_pos)
            hrp.AssemblyLinearVelocity = V0
            hrp.AssemblyAngularVelocity = V0
        end)
        pcall(function()
            local mt = getrawmetatable(hrp)
            if not mt then return end
            local ni = rawget(mt, "__newindex")
            if not ni then return end
            ni(hrp, "AssemblyLinearVelocity", V0)
            ni(hrp, "AssemblyAngularVelocity", V0)
            ni(hrp, "CFrame", CFrame.new(dest_pos))
            ni(hrp, "AssemblyLinearVelocity", V0)
            ni(hrp, "AssemblyAngularVelocity", V0)
        end)
        do
            local _kt_dest_cf = CFrame.new(dest_pos)
            _dsync_record_pos(_kt_dest_cf)
        end
    end)

end

local function stop_translocation()
    translocation_active = false
    config.translocation = false
    if translocation_conn then translocation_conn:Disconnect(); translocation_conn = nil end
    _movement_restore_pos()
end

BoxTranslocation:AddToggle("kt_en", { Text="Translocation", Default=false, Tooltip="Kills the opponent when they teleport to you" }):OnChanged(function(v)
    config.translocation = v
    play_toggle_sound()
    if v then start_translocation() else stop_translocation() end

end)


local BoxRiotBypass = Tabs.Defense:AddRightGroupbox("Riot Bypass")
BoxRiotBypass:AddToggle("def_rb_en", { Text="Riot Bypass", Default=false, Tooltip="Lets you hit targets even if they have riot shield on." }):OnChanged(function(v)
	config.riot_bypass_enabled = v
	play_toggle_sound()
	if v then getgenv().start_riot_bypass() else getgenv().stop_riot_bypass() end
end)
BoxRiotBypass:AddSlider("def_rb_dist", { Text="Distance Behind", Default=10, Min=0, Max=50, Rounding=1, Tooltip="How many studs behind the target to position." }):OnChanged(function(v)
	config.riot_bypass_distance = v
end)
BoxRiotBypass:AddSlider("def_rb_height", { Text="Height Offset", Default=0, Min=-20, Max=20, Rounding=1, Tooltip="Vertical offset from the target." }):OnChanged(function(v)
	config.riot_bypass_height = v
end)
BoxRiotBypass:AddSlider("def_rb_rate", { Text="Update Rate", Default=5, Min=1, Max=100, Rounding=1, Tooltip="How often to update your character to the target." }):OnChanged(function(v)
	config.riot_bypass_update_rate = v / 10
end)

local underground_conn = nil
local underground_active = false
local underground_lockedY = nil
local underground_lastPos = nil

getgenv().start_underground = function()
	if underground_active then return end
	underground_active = true
	config.underground_enabled = true
	underground_lockedY = nil
	underground_lastPos = nil
	underground_conn = run_service.Heartbeat:Connect(function()
		if not config.underground_enabled then return end
		local character = localplayer.Character
		if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") then
			local root = character.HumanoidRootPart
			local humanoid = character.Humanoid
			local currentPos = root.Position
			if not underground_lockedY then
				underground_lockedY = currentPos.Y - 7
			end
			local moveDir = humanoid.MoveDirection
			if moveDir.Magnitude > 0 then
				local speed = humanoid.WalkSpeed
				underground_lastPos = root.Position + (moveDir * speed * 0.016)
				root.CFrame = CFrame.new(underground_lastPos.X, underground_lockedY, underground_lastPos.Z) * (root.CFrame - currentPos)
			else
				if not underground_lastPos then
					underground_lastPos = currentPos
				end
				root.CFrame = CFrame.new(underground_lastPos.X, underground_lockedY, underground_lastPos.Z) * (root.CFrame - currentPos)
			end
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
		else
			underground_lockedY = nil
			underground_lastPos = nil
		end
	end)
end

getgenv().stop_underground = function()
	underground_active = false
	config.underground_enabled = false
	underground_lockedY = nil
	underground_lastPos = nil
	if underground_conn then underground_conn:Disconnect(); underground_conn = nil end
end

local BoxAntiTeleportation = Tabs.Defense:AddLeftGroupbox("Anti Teleportation")
BoxAntiTeleportation:AddToggle("atp_en", { Text="Anti Teleportation", Default=false, Tooltip="Defends against teleportation" }):OnChanged(function(v)
    config.anti_teleportation = v
    play_toggle_sound()
    if v then getgenv().start_anti_teleportation() else getgenv().stop_anti_teleportation() end
end)
BoxAntiTeleportation:AddSlider("atp_threshold_sl", { Text="Detect Threshold", Default=2000, Min=100, Max=100000, Rounding=0, Tooltip="How many studs a target has to be to you to trigger." }):OnChanged(function(v)
    config.anti_tp_threshold = v
end)
BoxAntiTeleportation:AddSlider("atp_escape_sl", { Text="Escape Distance", Default=100000000, Min=1000, Max=1000000000, Rounding=0, Tooltip="How far to move away when a teleport is detected." }):OnChanged(function(v)
    config.anti_tp_escape_dist = v
end)

local _evasion_rbRandom = Random.new()
local _evasion_FAR_AXIS = 1073741824
local _evasion_CollectionService = cloneref(game:GetService("CollectionService"))

local _evasion_Config = {
	Enabled = false,
	EvasionMode = "Random",
	TranslocateOffset = -5,
	RandomBaseRadius = 100,
	RandomRadiusFactor = 0.5,
	RandomAnchorFromChar = false,
	FakeViewAngles = true,
	RootDesyncEnabled = true,
	DefensiveStance = true,
	ForceCrouch = true,
	Stability = 0.15,
	ShootFrames = 1,
}

local _evasion_cachedEnumLib
local function _evasion_resolveEnumLibrary()
	if _evasion_cachedEnumLib then return _evasion_cachedEnumLib end
	local rs = cloneref(game:GetService("ReplicatedStorage"))
	local mod = rs:FindFirstChild("Modules") and rs.Modules:FindFirstChild("EnumLibrary")
	if not mod then return nil end
	local ok, lib = pcall(require, mod)
	if ok and type(lib) == "table" then _evasion_cachedEnumLib = lib end
	return _evasion_cachedEnumLib
end
local function _evasion_enc(name)
	local lib = _evasion_resolveEnumLibrary()
	if not lib then return nil end
	local ok, token = pcall(lib.ToEnum, lib, name)
	return ok and token or nil
end

local _evasion_cachedCamRemote, _evasion_cachedStateRemote
local function _evasion_resolveCameraRotationRemote()
	if _evasion_cachedCamRemote and _evasion_cachedCamRemote.Parent then return _evasion_cachedCamRemote end
	local rs = cloneref(game:GetService("ReplicatedStorage"))
	local r = rs:FindFirstChild("Remotes") and rs.Remotes:FindFirstChild("Replication") and rs.Remotes.Replication:FindFirstChild("Fighter") and rs.Remotes.Replication.Fighter:FindFirstChild("CameraRotation")
	if r and r:IsA("RemoteEvent") then _evasion_cachedCamRemote = r end
	return _evasion_cachedCamRemote
end
local function _evasion_resolveUpdateStateRemote()
	if _evasion_cachedStateRemote and _evasion_cachedStateRemote.Parent then return _evasion_cachedStateRemote end
	local rs = cloneref(game:GetService("ReplicatedStorage"))
	local r = rs:FindFirstChild("Remotes") and rs.Remotes:FindFirstChild("Replication") and rs.Remotes.Replication:FindFirstChild("Fighter") and rs.Remotes.Replication.Fighter:FindFirstChild("UpdateState")
	if r and r:IsA("RemoteEvent") then _evasion_cachedStateRemote = r end
	return _evasion_cachedStateRemote
end
local function _evasion_fireServerNative(remote, ...)
	if remote and remote.Parent then pcall(remote.FireServer, remote, ...) end
end

local function _evasion_encodeSingle(n)
	if n == n then return utf8.char(math.clamp(math.floor(n % (2 * math.pi) / math.pi / 2 * 256 + 0.5), 0, 255)) end
	return utf8.char(0)
end
local function _evasion_encodeCameraRotation(v)
	if v == v then
		return utf8.char(math.clamp(math.floor(v.X % (2 * math.pi) / math.pi / 2 * 256 + 0.5), 0, 255))
			.. utf8.char(math.clamp(math.floor(v.Y % (2 * math.pi) / math.pi / 2 * 256 + 0.5), 0, 255))
	end
	return utf8.char(0) .. utf8.char(0)
end
local function _evasion_decodeSingle(s) return utf8.codepoint(s) * math.pi * 2 / 256 end
local function _evasion_anglesToEncoded(a)
	if a.kind == "Unnormalized" then
		return utf8.char(math.clamp(a.pitch, 0, 255)) .. utf8.char(math.clamp(a.yaw, 0, 255))
	end
	return _evasion_encodeSingle(math.rad(a.pitch)) .. _evasion_encodeSingle(math.rad(a.yaw))
end

local _evasion_RootDesync = {}
_evasion_RootDesync.__index = _evasion_RootDesync
function _evasion_RootDesync.new(rootPart)
	local self = setmetatable({
		_rootPart = rootPart,
		_boundId = game:GetService("HttpService"):GenerateGUID(false),
		_oldCFrame = rootPart.CFrame,
		_cframe = nil,
	}, _evasion_RootDesync)
	run_service:BindToRenderStep(self._boundId, Enum.RenderPriority.First.Value, function()
		local old = self._oldCFrame
		if old ~= nil then self._rootPart.CFrame = old; self._oldCFrame = nil end
	end)
	return self
end
function _evasion_RootDesync:SetServerCFrame(cf) self._cframe = cf end
function _evasion_RootDesync:GetServerCFrame() return self._cframe or self._rootPart.CFrame end
function _evasion_RootDesync:GetClientCFrame() return self._oldCFrame or self._rootPart.CFrame end
function _evasion_RootDesync:HeartbeatUpdate()
	local cf = self._cframe
	if cf ~= nil then self._oldCFrame = self._rootPart.CFrame; self._rootPart.CFrame = cf end
end
function _evasion_RootDesync:Destroy()
	pcall(function() run_service:UnbindFromRenderStep(self._boundId) end)
end

local _evasion_ViewAngleDriver = {}
_evasion_ViewAngleDriver.__index = _evasion_ViewAngleDriver
function _evasion_ViewAngleDriver.new()
	return setmetatable({ _slots = {}, _winning = nil, _fullySuppressed = false, _dirty = false }, _evasion_ViewAngleDriver)
end
function _evasion_ViewAngleDriver:_Resolve()
	local best, winner = nil, nil
	for priority, value in pairs(self._slots) do
		if value ~= nil and (best == nil or priority > best) then best, winner = priority, value end
	end
	self._winning = winner
end
function _evasion_ViewAngleDriver:_LoadJointsHook()
	if self._jointsRestore ~= nil then return true end
	local rs = cloneref(game:GetService("ReplicatedStorage"))
	local mod = rs:FindFirstChild("Modules") and rs.Modules:FindFirstChild("ClientFighterCharacterJoints")
	local ok2, joints = pcall(require, mod or Instance.new("ModuleScript"))
	local original = (ok2 and type(joints) == "table") and rawget(joints, "Update") or nil
	if not joints or original == nil then return false end
	local driver = self
	rawset(joints, "Update", function(self2, ...)
		local winning = driver._winning
		if winning ~= nil and not driver._fullySuppressed then
			local encoded = _evasion_anglesToEncoded(winning)
			local ok3, raw = pcall(function()
				return Vector2.new(_evasion_decodeSingle(string.sub(encoded, 1, 1)), _evasion_decodeSingle(string.sub(encoded, 2, 2)))
			end)
			if ok3 then pcall(function() self2.CameraRotationRaw = raw end) end
		end
		return original(self2, ...)
	end)
	self._jointsRestore = { joints = joints, original = original }
	return true
end
function _evasion_ViewAngleDriver:SendViewAngles(priority, value)
	if self._slots[priority] == value then return end
	self._slots[priority] = value
	self._dirty = true
	self:_Resolve()
	if self._winning == nil then return end
	if self:_LoadJointsHook() then
		if self._replicationRestore == nil then
			local proto
			pcall(function()
				for _, v in ipairs(getgc(true)) do
					if type(v) == "table" then
						local mt = getmetatable(v)
						if mt and rawget(mt, "__index") and rawget(rawget(mt, "__index"), "_CameraReplicationLoop") then
							proto = rawget(mt, "__index")
							break
						end
					end
				end
			end)
			if proto then
				local loop = rawget(proto, "_CameraReplicationLoop")
				if loop then
					local ok4, upvalues = pcall(debug.getupvalues, loop)
					if ok4 and type(upvalues) == "table" then
						local utilIndex, util
						for index, value in pairs(upvalues) do
							if type(value) == "table" then
								local vmt = getmetatable(value)
								local vidx = vmt and rawget(vmt, "__index") or nil
								if vidx ~= nil and rawget(vidx, "EncodeCameraRotation") ~= nil then
									util, utilIndex = value, index
									break
								end
							end
						end
						if utilIndex and util then
							local driver = self
							local replacement = {}
							function replacement.EncodeCameraRotation(_, raw)
								if next(driver._slots) == nil and not driver._fullySuppressed then
									return _evasion_encodeCameraRotation(raw)
								end
								return _evasion_encodeCameraRotation(raw)
							end
							pcall(debug.setupvalue, loop, utilIndex, replacement)
							self._replicationRestore = { loop = loop, utilityIndex = utilIndex, utility = util }
						end
					end
				end
			end
		end
	end
end
function _evasion_ViewAngleDriver:Flush()
	if not self._dirty or self._fullySuppressed then return end
	local winning = self._winning
	if winning == nil then self._dirty = false; return end
	self._dirty = false
	local remote = _evasion_resolveCameraRotationRemote()
	if remote then _evasion_fireServerNative(remote, _evasion_anglesToEncoded(winning), nil) end
end
function _evasion_ViewAngleDriver:ClearAll()
	table.clear(self._slots)
	self._winning = nil
	self._dirty = false
end
function _evasion_ViewAngleDriver:Destroy()
	local jr = self._jointsRestore
	if jr ~= nil then
		self._jointsRestore = nil
		pcall(rawset, jr.joints, "Update", jr.original)
	end
	local rr = self._replicationRestore
	if rr ~= nil then
		self._replicationRestore = nil
		pcall(debug.setupvalue, rr.loop, rr.utilityIndex, rr.utility)
	end
end

local _evasion_CharacterController = {}
_evasion_CharacterController.__index = _evasion_CharacterController
function _evasion_CharacterController.new(rootPart)
	return setmetatable({
		_rootDesync = _evasion_RootDesync.new(rootPart),
		_viewAngleDriver = _evasion_ViewAngleDriver.new(),
	}, _evasion_CharacterController)
end
function _evasion_CharacterController:SetServerCFrame(cf)
	if self._rootDesync then self._rootDesync:SetServerCFrame(cf) end
end
function _evasion_CharacterController:GetClientCFrame()
	return self._rootDesync and self._rootDesync:GetClientCFrame() or nil
end
function _evasion_CharacterController:SendViewAngles(priority, value)
	self._viewAngleDriver:SendViewAngles(priority, value)
end
function _evasion_CharacterController:HeartbeatUpdate()
	if self._rootDesync then self._rootDesync:HeartbeatUpdate() end
	self._viewAngleDriver:Flush()
end
function _evasion_CharacterController:Destroy()
	self._viewAngleDriver:ClearAll()
	self._viewAngleDriver:Destroy()
	if self._rootDesync then
		self._rootDesync:Destroy()
		self._rootDesync = nil
	end
end

local _evasion_StateHook = {}
_evasion_StateHook.__index = _evasion_StateHook
function _evasion_StateHook.new() return setmetatable({ _forced = {} }, _evasion_StateHook) end
function _evasion_StateHook:SetForced(name, value)
	local token = _evasion_enc(name)
	if token == nil or self._forced[token] == value then return end
	local remote = _evasion_resolveUpdateStateRemote()
	if not remote then return end
	self._forced[token] = value
	_evasion_fireServerNative(remote, token, value, nil)
end
function _evasion_StateHook:ClearForced(name, offValue)
	local token = _evasion_enc(name)
	if token == nil or self._forced[token] == nil then return end
	self._forced[token] = nil
	local remote = _evasion_resolveUpdateStateRemote()
	if remote then _evasion_fireServerNative(remote, token, offValue, nil) end
end

local function _evasion_ringPoint(anchor, minR, maxR)
	local angle = _evasion_rbRandom:NextNumber(0, 2 * math.pi)
	local radius = _evasion_rbRandom:NextNumber(minR, maxR)
	return CFrame.new(anchor + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius))
		* CFrame.fromOrientation(
			_evasion_rbRandom:NextNumber(0, 2 * math.pi),
			_evasion_rbRandom:NextNumber(0, 2 * math.pi),
			_evasion_rbRandom:NextNumber(0, 2 * math.pi)
		)
end
local function _evasion_scatterFar(pos, anchorFromCharacter, baseRadius, radiusFactor)
	local extra = baseRadius * radiusFactor
	local anchor = anchorFromCharacter and pos or Vector3.new(0, pos.Y, 0)
	local ring = _evasion_ringPoint(anchor, baseRadius, baseRadius + extra)
	local rp = ring.Position
	local x, y, z = rp.X, rp.Y, rp.Z
	local pick = _evasion_rbRandom:NextInteger(1, 3)
	if pick == 1 then x = _evasion_FAR_AXIS
	elseif pick == 2 then y = _evasion_FAR_AXIS
	else z = _evasion_FAR_AXIS end
	return ring - rp + Vector3.new(x, y, z)
end
local function _evasion_translocateEvade(clientCF, hasTargetsNow)
	if not hasTargetsNow then return _evasion_ringPoint(clientCF.Position, 10000, 1000000000) end
	for _, part in ipairs(_evasion_CollectionService:GetTagged("OutOfBoundsPart")) do
		if part:GetAttribute("KillDelay") == 0 then
			return part.CFrame * CFrame.new(0, -part.Size.Y / 2 + _evasion_Config.TranslocateOffset, 0)
		end
	end
	return _evasion_ringPoint(clientCF.Position, 10000, 1000000000)
end
local function _evasion_getDefensiveViewAngles(stance)
	if stance == "None" then return nil end
	local pitch = (stance == "Equipped") and 90 or -90
	return { kind = "Normalized", pitch = pitch, yaw = _evasion_rbRandom:NextNumber(0, 360) }
end

local _evasion_Controller = {}
_evasion_Controller.__index = _evasion_Controller
local _evasion_ControllerInstance = nil
function _evasion_Controller.new()
	return setmetatable({
		_enabled = false,
		_characterController = nil,
		_boundRootPart = nil,
		_stateHook = _evasion_StateHook.new(),
		_lastDefensiveAngles = nil,
	}, _evasion_Controller)
end
function _evasion_Controller:_EnsureCharacterController()
	local char = localplayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root or root.Parent ~= char then
		if self._characterController then
			self._characterController:Destroy()
			self._characterController = nil
			self._boundRootPart = nil
		end
		return nil
	end
	if self._characterController == nil or self._boundRootPart ~= root then
		if self._characterController then self._characterController:Destroy() end
		self._characterController = _evasion_CharacterController.new(root)
		self._boundRootPart = root
	end
	return self._characterController
end
function _evasion_Controller:_ApplyForcedCrouch(on)
	if on then self._stateHook:SetForced("IsCrouching", true)
	else self._stateHook:ClearForced("IsCrouching", false) end
end
function _evasion_Controller:_EvadeCFrame(clientCF)
	local mode = _evasion_Config.EvasionMode
	if mode == "Off" then return nil end
	if mode == "Translocate" then return _evasion_translocateEvade(clientCF, false) end
	return _evasion_scatterFar(clientCF.Position, _evasion_Config.RandomAnchorFromChar, _evasion_Config.RandomBaseRadius, _evasion_Config.RandomRadiusFactor)
end
function _evasion_Controller:Update()
	if not self._enabled then self:_Reset(); return end
	local cc = self:_EnsureCharacterController()
	if cc == nil then return end
	local clientCF = cc:GetClientCFrame()
	if clientCF == nil then return end
	local evadeCF = self:_EvadeCFrame(clientCF)
	cc:SetServerCFrame(evadeCF)
	if _evasion_Config.FakeViewAngles and _evasion_Config.DefensiveStance then
		if self._lastDefensiveAngles == nil then
			self._lastDefensiveAngles = _evasion_getDefensiveViewAngles("Unequipped")
		end
		cc:SendViewAngles(20, self._lastDefensiveAngles)
	else
		cc:SendViewAngles(20, nil)
	end
	if _evasion_Config.ForceCrouch then self:_ApplyForcedCrouch(true) else self:_ApplyForcedCrouch(false) end
	cc:HeartbeatUpdate()
end
function _evasion_Controller:_Reset()
	self._lastDefensiveAngles = nil
	self:_ApplyForcedCrouch(false)
	if self._characterController then
		self._characterController:SetServerCFrame(nil)
		self._characterController:SendViewAngles(20, nil)
		self._characterController:HeartbeatUpdate()
	end
end
function _evasion_Controller:SetEnabled(on)
	if self._enabled == on then return end
	self._enabled = on
	if not on then self:_Reset() end
end
function _evasion_Controller:Destroy()
	self:SetEnabled(false)
	self:_Reset()
	if self._characterController then
		self._characterController:Destroy()
		self._characterController = nil
		self._boundRootPart = nil
	end
end

local _evasion_heartbeat_conn = nil
getgenv().start_evasion = function()
	if not _evasion_ControllerInstance then
		_evasion_ControllerInstance = _evasion_Controller.new()
	end
	_evasion_ControllerInstance:SetEnabled(true)
	config.evasion_enabled = true
	if _evasion_heartbeat_conn then _evasion_heartbeat_conn:Disconnect() end
	local _evasion_hb_last = 0
	_evasion_heartbeat_conn = run_service.Heartbeat:Connect(function()
		if not config.evasion_enabled then return end
		local _ev_now = tick()
		if _ev_now - _evasion_hb_last < 0.016 then return end
		_evasion_hb_last = _ev_now
		pcall(function() _evasion_ControllerInstance:Update() end)
	end)
end
getgenv().stop_evasion = function()
	config.evasion_enabled = false
	if _evasion_heartbeat_conn then _evasion_heartbeat_conn:Disconnect(); _evasion_heartbeat_conn = nil end
	if _evasion_ControllerInstance then
		_evasion_ControllerInstance:SetEnabled(false)
		_evasion_ControllerInstance:_Reset()
	end
end

local BoxBodyManipulation = Tabs.Defense:AddLeftGroupbox("Evasion")
BoxBodyManipulation:AddToggle("bm_kicia_en", { Text="Evasion", Default=false, Tooltip="Non client-sided voidspam." }):OnChanged(function(v)
	config.evasion_enabled = v
	play_toggle_sound()
	if v then getgenv().start_evasion() else getgenv().stop_evasion() end
end)
BoxBodyManipulation:AddDropdown("bm_kicia_evasion", { Text="Evasion Mode", Default=1, Values={"Random"}, Tooltip="How to move the server-side position." }):OnChanged(function(v)
	_evasion_Config.EvasionMode = v
end)

BoxBodyManipulation:AddToggle("bm_kicia_defensive", { Text="Defensive Stance", Default=true, Tooltip="Sends 90 degree pitch during aim and shielding." }):OnChanged(function(v)
	_evasion_Config.DefensiveStance = v
end)
BoxBodyManipulation:AddToggle("bm_kicia_crouch", { Text="Force Crouch", Default=true, Tooltip="Fires IsCrouching" }):OnChanged(function(v)
	_evasion_Config.ForceCrouch = v
end)
BoxBodyManipulation:AddSlider("bm_kicia_radius", { Text="Radius", Default=100, Min=5, Max=100000, Rounding=0, Tooltip="How far to void." }):OnChanged(function(v)
	_evasion_Config.RandomBaseRadius = v
end)
BoxBodyManipulation:AddToggle("bm_kicia_charorigin", { Text="Character Origin", Default=false, Tooltip="Void from your character instead of from map." }):OnChanged(function(v)
	_evasion_Config.RandomAnchorFromChar = v
end)

local BoxRiotAbuser = Tabs.Defense:AddLeftGroupbox("Riot Abuser")
BoxRiotAbuser:AddToggle("def_ra_en", { Text="Riot Abuser", Default=false, Tooltip="Blocks shots with riot shield." }):OnChanged(function(v)
	config.riot_abuser_enabled = v
	play_toggle_sound()
	if v then getgenv().start_riot_abuser() else getgenv().stop_riot_abuser() end
end)
BoxRiotAbuser:AddSlider("def_ra_spin", { Text="Spin Speed", Default=720, Min=1, Max=99999, Rounding=0, Tooltip="Degrees per second to spin." }):OnChanged(function(v)
	config.riot_abuser_spin_speed = v
end)
BoxRiotAbuser:AddSlider("def_ra_radius", { Text="Iterate Radius", Default=50, Min=1, Max=2000, Rounding=0, Tooltip="Radius of the iteration." }):OnChanged(function(v)
	config.riot_abuser_iterate_radius = v
end)
BoxRiotAbuser:AddSlider("def_ra_pitch", { Text="Pitch Angle", Default=0, Min=-89, Max=89, Rounding=0, Tooltip="Rotation pitch." }):OnChanged(function(v)
	config.riot_abuser_pitch = v
end)
BoxRiotAbuser:AddSlider("def_ra_rate", { Text="Iterate Rate", Default=16, Min=1, Max=200, Rounding=0, Tooltip="Iteration rate." }):OnChanged(function(v)
	config.riot_abuser_iterate_rate = v / 1000
end)

local sleepyhub_counter_conn = nil
local sleepyhub_counter_active = false
local sleepyhub_counter_last = 0

local function sleepyhub_find_target()
 local hrp = getgenv().get_hrp(localplayer)
 if not hrp then return nil end
 local best, best_d = nil, math.huge
 for _, p in ipairs(players:GetPlayers()) do
  if p ~= localplayer and p.Character then
   local t_hrp = p.Character:FindFirstChild("HumanoidRootPart")
   local hum = p.Character:FindFirstChildOfClass("Humanoid")
   local no_ff = not p.Character:FindFirstChildOfClass("ForceField")
   local diff_team = localplayer.Team == nil or p.Team == nil or localplayer.Team ~= p.Team
   if t_hrp and hum and hum.Health > 0 and no_ff and diff_team then
    local d = (hrp.Position - t_hrp.Position).Magnitude
    if d < best_d then best_d = d; best = p end
   end
  end
 end
 return best
end

getgenv().start_sleepyhub_counter = function()
 if sleepyhub_counter_active then return end
 sleepyhub_counter_active = true
 config.sleepyhub_counter_enabled = true
 local _shc_projectiles = {}
 local _shc_child_added = workspace.ChildAdded:Connect(function(o)
  if not o:IsA("BasePart") then return end
  if o.Name == "CoreProjectile" then
   _shc_projectiles[o] = true
  elseif o.Name == "Part" then
   task.defer(function()
    if o and o.Parent and o.AssemblyLinearVelocity.Magnitude > 50 then
     _shc_projectiles[o] = true
    end
   end)
  end
 end)
 local _shc_child_removed = workspace.ChildRemoved:Connect(function(o)
  _shc_projectiles[o] = nil
 end)
 local _shc_target_pos = CFrame.new(9000, 9000, 9000)
 sleepyhub_counter_conn = run_service.Heartbeat:Connect(function()
  if not config.sleepyhub_counter_enabled then return end
  local now = tick()
  if now - sleepyhub_counter_last < 0.033 then return end
  sleepyhub_counter_last = now
  pcall(function()
   for _, p in pairs(players:GetPlayers()) do
    if p ~= localplayer and p.Character then
     local h = p.Character:FindFirstChild("HumanoidRootPart")
     if h then
      h.CFrame = _shc_target_pos
      h.AssemblyLinearVelocity = Vector3.zero
     end
    end
   end
   for p in pairs(_shc_projectiles) do
    if p and p.Parent then
     p.CFrame = _shc_target_pos
     p.AssemblyLinearVelocity = Vector3.zero
    else
     _shc_projectiles[p] = nil
    end
   end
  end)
 end)
 getgenv()._shc_child_added_conn = _shc_child_added
 getgenv()._shc_child_removed_conn = _shc_child_removed
end

getgenv().stop_sleepyhub_counter = function()
 sleepyhub_counter_active = false
 config.sleepyhub_counter_enabled = false
 if sleepyhub_counter_conn then sleepyhub_counter_conn:Disconnect(); sleepyhub_counter_conn = nil end
 if getgenv()._shc_child_added_conn then getgenv()._shc_child_added_conn:Disconnect(); getgenv()._shc_child_added_conn = nil end
 if getgenv()._shc_child_removed_conn then getgenv()._shc_child_removed_conn:Disconnect(); getgenv()._shc_child_removed_conn = nil end
end

local ue_counter_conn = nil
local ue_counter_active = false
local ue_counter_last = 0
local ue_counter_method = 1

getgenv().start_ue_counter = function()
 if ue_counter_active then return end
 ue_counter_active = true
 config.ue_counter_enabled = true
 local _uec_projectiles = {}
 local _uec_child_added = workspace.ChildAdded:Connect(function(o)
  if not o:IsA("BasePart") then return end
  if o.Name == "CoreProjectile" then
   _uec_projectiles[o] = true
  elseif o.Name == "Part" then
   task.defer(function()
    if o and o.Parent and o.AssemblyLinearVelocity.Magnitude > 50 then
     _uec_projectiles[o] = true
    end
   end)
  end
 end)
 local _uec_child_removed = workspace.ChildRemoved:Connect(function(o)
  _uec_projectiles[o] = nil
 end)
 local _uec_target_pos = CFrame.new(9000, 9000, 9000)
 local _uec_hb_last = 0
 ue_counter_conn = run_service.Heartbeat:Connect(function()
  if not config.ue_counter_enabled then return end
  local now = tick()
  if now - _uec_hb_last < 0.033 then return end
  _uec_hb_last = now
  pcall(function()
   for _, p in pairs(players:GetPlayers()) do
    if p ~= localplayer and p.Character then
     local h = p.Character:FindFirstChild("HumanoidRootPart")
     if h then
      h.CFrame = _uec_target_pos
      h.AssemblyLinearVelocity = Vector3.zero
     end
    end
   end
   for p in pairs(_uec_projectiles) do
    if p and p.Parent then
     p.CFrame = _uec_target_pos
     p.AssemblyLinearVelocity = Vector3.zero
    else
     _uec_projectiles[p] = nil
    end
   end
  end)
 end)
 getgenv()._uec_child_added_conn = _uec_child_added
 getgenv()._uec_child_removed_conn = _uec_child_removed
end

getgenv().stop_ue_counter = function()
 ue_counter_active = false
 config.ue_counter_enabled = false
 if ue_counter_conn then ue_counter_conn:Disconnect(); ue_counter_conn = nil end
 if getgenv()._uec_child_added_conn then getgenv()._uec_child_added_conn:Disconnect(); getgenv()._uec_child_added_conn = nil end
 if getgenv()._uec_child_removed_conn then getgenv()._uec_child_removed_conn:Disconnect(); getgenv()._uec_child_removed_conn = nil end
end

local hook_counter_conn = nil
local hook_counter_rs_conn = nil
local hook_counter_active = false
local hook_counter_last = 0

getgenv().start_hook_counter = function()
 if hook_counter_active then return end
 hook_counter_active = true
 config.hook_counter_enabled = true
 local _hkc_projectiles = {}
 local _hkc_child_added = workspace.ChildAdded:Connect(function(o)
  if not o:IsA("BasePart") then return end
  if o.Name == "CoreProjectile" then
   _hkc_projectiles[o] = true
  elseif o.Name == "Part" then
   task.defer(function()
    if o and o.Parent and o.AssemblyLinearVelocity.Magnitude > 50 then
     _hkc_projectiles[o] = true
    end
   end)
  end
 end)
 local _hkc_child_removed = workspace.ChildRemoved:Connect(function(o)
  _hkc_projectiles[o] = nil
 end)
 local _hkc_target_pos = CFrame.new(9000, 9000, 9000)
 local _hkc_hb_last = 0
 hook_counter_conn = run_service.Heartbeat:Connect(function()
  if not config.hook_counter_enabled then return end
  local now = tick()
  if now - _hkc_hb_last < 0.033 then return end
  _hkc_hb_last = now
  pcall(function()
   for _, p in pairs(players:GetPlayers()) do
    if p ~= localplayer and p.Character then
     local h = p.Character:FindFirstChild("HumanoidRootPart")
     if h then
      h.CFrame = _hkc_target_pos
      h.AssemblyLinearVelocity = Vector3.zero
     end
    end
   end
   for p in pairs(_hkc_projectiles) do
    if p and p.Parent then
     p.CFrame = _hkc_target_pos
     p.AssemblyLinearVelocity = Vector3.zero
    else
     _hkc_projectiles[p] = nil
    end
   end
  end)
 end)
 getgenv()._hkc_child_added_conn = _hkc_child_added
 getgenv()._hkc_child_removed_conn = _hkc_child_removed
end

getgenv().stop_hook_counter = function()
 hook_counter_active = false
 config.hook_counter_enabled = false
 if hook_counter_conn then hook_counter_conn:Disconnect(); hook_counter_conn = nil end
 if getgenv()._hkc_child_added_conn then getgenv()._hkc_child_added_conn:Disconnect(); getgenv()._hkc_child_added_conn = nil end
 if getgenv()._hkc_child_removed_conn then getgenv()._hkc_child_removed_conn:Disconnect(); getgenv()._hkc_child_removed_conn = nil end
end

local smart_riot_active = false
local smart_riot_conn = nil
local smart_riot_origin = nil

getgenv().start_smart_riot = function()
 if smart_riot_active then return end
 smart_riot_active = true
 config.smart_riot_enabled = true
 local hrp0 = getgenv().get_hrp(localplayer)
 if hrp0 then smart_riot_origin = hrp0.CFrame end
 local _sr_phase = 0
 local _sr_last = 0
 local _sr_void_depths = {-5e25, -8e27, -1.2e30, -3e28}
 local _sr_depth_idx = 1
 local _sr_tvel_x, _sr_tvel_z = 0, 0
 local _sr_last_tp_x, _sr_last_tp_z = nil, nil
 smart_riot_conn = run_service.Heartbeat:Connect(function()
  if not config.smart_riot_enabled then return end
  local now = tick()
  if now - _sr_last < 0.016 then return end
  _sr_last = now
  local hrp = getgenv().get_hrp(localplayer)
  if not hrp then return end
  local hum_sr = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")
  if not hum_sr or hum_sr.Health <= 0 then return end
  if not smart_riot_origin then smart_riot_origin = hrp.CFrame end
  local my_p = hrp.Position
  local best_ep = nil
  local best_ed = math.huge
  for _, p in ipairs(players:GetPlayers()) do
   if p ~= localplayer and p.Character then
    local th = p.Character:FindFirstChild("HumanoidRootPart")
    local hum2 = p.Character:FindFirstChildOfClass("Humanoid")
    if th and hum2 and hum2.Health > 0 then
     local d = (th.Position - my_p).Magnitude
     if d < best_ed then best_ed = d; best_ep = th.Position end
    end
   end
  end
  if best_ep then
   local alpha = 0.3
   if _sr_last_tp_x then
    _sr_tvel_x = _sr_tvel_x + (best_ep.X - _sr_last_tp_x - _sr_tvel_x) * alpha
    _sr_tvel_z = _sr_tvel_z + (best_ep.Z - _sr_last_tp_z - _sr_tvel_z) * alpha
   end
   _sr_last_tp_x = best_ep.X
   _sr_last_tp_z = best_ep.Z
  end
  _sr_phase = (_sr_phase + 1) % 4
  local V0 = Vector3.zero
  local dest_cf
  if _sr_phase == 0 or _sr_phase == 2 then
   _sr_depth_idx = (_sr_depth_idx % #_sr_void_depths) + 1
   local void_y = _sr_void_depths[_sr_depth_idx]
   local origin_x = smart_riot_origin.X
   local origin_z = smart_riot_origin.Z
   if best_ep then
    local dx = best_ep.X - origin_x
    local dz = best_ep.Z - origin_z
    local dm = math.sqrt(dx*dx + dz*dz)
    if dm > 0.001 then
     origin_x = origin_x - (dx/dm) * 200000000
     origin_z = origin_z - (dz/dm) * 200000000
    end
   end
   dest_cf = CFrame.new(origin_x, void_y, origin_z)
  else
   local ox = smart_riot_origin.X
   local oz = smart_riot_origin.Z
   if best_ep then
    local pred_x = best_ep.X + _sr_tvel_x * 6
    local pred_z = best_ep.Z + _sr_tvel_z * 6
    local away_x = ox - pred_x
    local away_z = oz - pred_z
    local away_m = math.sqrt(away_x*away_x + away_z*away_z)
    if away_m > 0.001 then
     ox = ox + (away_x / away_m) * 80000000
     oz = oz + (away_z / away_m) * 80000000
    end
   end
   dest_cf = CFrame.new(ox, smart_riot_origin.Y, oz)
  end
  local mt = getrawmetatable(hrp)
  local ni = mt and rawget(mt, "__newindex")
  if ni then
   pcall(ni, hrp, "AssemblyLinearVelocity", V0)
   pcall(ni, hrp, "AssemblyAngularVelocity", V0)
   pcall(ni, hrp, "CFrame", dest_cf)
   pcall(ni, hrp, "AssemblyLinearVelocity", V0)
   pcall(ni, hrp, "AssemblyAngularVelocity", V0)
  else
   pcall(function()
    hrp.AssemblyLinearVelocity = V0
    hrp.AssemblyAngularVelocity = V0
    hrp.CFrame = dest_cf
    hrp.AssemblyLinearVelocity = V0
    hrp.AssemblyAngularVelocity = V0
   end)
  end
  if sethiddenproperty then
   pcall(sethiddenproperty, hrp, "CFrame", dest_cf)
   pcall(sethiddenproperty, hrp, "AssemblyLinearVelocity", V0)
  end
 end)
end

getgenv().stop_smart_riot = function()
 smart_riot_active = false
 config.smart_riot_enabled = false
 if smart_riot_conn then smart_riot_conn:Disconnect(); smart_riot_conn = nil end
 smart_riot_origin = nil
 local hrp = getgenv().get_hrp(localplayer)
 if hrp then
  pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero end)
  pcall(function() hrp.AssemblyAngularVelocity = Vector3.zero end)
 end
end

local BoxProtAntiAim = Tabs.Protection:AddLeftGroupbox("Anti Aim")
BoxProtAntiAim:AddToggle("prot_bm_en", { Text="Anti Aim", Default=false, Tooltip="Confuses server hit registration." }):OnChanged(function(v)
    config.anti_aim = v
    play_toggle_sound()
    if v then getgenv().start_body_manip() else getgenv().stop_body_manip() end
end)
BoxProtAntiAim:AddDropdown("prot_bm_aa_mode", { Text="Anti Aim Mode", Default=1, Values={"Spin", "Static", "Jitter", "Desync", "Flat", "Backward", "Freestanding", "LowerBody", "PitchDown", "PitchUp", "SpinPitch", "Random"} }):OnChanged(function(v)
    config.anti_aim_mode = v
end)
BoxProtAntiAim:AddSlider("prot_bm_spin_speed", { Text="Spin Speed", Default=720, Min=1, Max=99999, Rounding=0 }):OnChanged(function(v)
    config.anti_aim_spin_speed = v
end)
BoxProtAntiAim:AddSlider("prot_bm_pitch", { Text="Pitch Angle", Default=89, Min=-89, Max=89, Rounding=0 }):OnChanged(function(v)
    config.anti_aim_pitch_deg = v
end)
BoxProtAntiAim:AddSlider("prot_bm_jitter", { Text="Jitter Range", Default=0, Min=0, Max=89, Rounding=0 }):OnChanged(function(v)
    config.anti_aim_jitter_deg = v
end)

local BoxProtAntiTransloc = Tabs.Protection:AddRightGroupbox("Anti Translocation")
BoxProtAntiTransloc:AddToggle("prot_at_en", { Text="Anti Translocation", Default=false, Tooltip="Teleports you away from a translocating user." }):OnChanged(function(v)
    config.anti_translocation = v
    play_toggle_sound()
    if v then getgenv().start_anti_translocation() else getgenv().stop_anti_translocation() end
end)

local BoxProtAntiAFK = Tabs.Protection:AddLeftGroupbox("Anti AFK")

local BoxProtUE = Tabs.Protection:AddRightGroupbox("UE Counter")
BoxProtUE:AddToggle("prot_ue_en", { Text="Disable Your Evasion Method", Default=false, Tooltip="Counters the UE script." }):OnChanged(function(v)
    config.ue_counter_enabled = v
    play_toggle_sound()
    if v then getgenv().start_ue_counter() else getgenv().stop_ue_counter() end
end)

local BoxProtHookCounter = Tabs.Protection:AddLeftGroupbox("KiciaHook Counter")
BoxProtHookCounter:AddToggle("prot_kh_en", { Text="Disable Your Evasion Method", Default=false, Tooltip="Counters the KiciaHook script." }):OnChanged(function(v)
    config.hook_counter_enabled = v
    play_toggle_sound()
    if v then getgenv().start_hook_counter() else getgenv().stop_hook_counter() end
end)

local BoxProtSmartRiot = Tabs.Protection:AddLeftGroupbox("Smart Riot v1.0")
BoxProtSmartRiot:AddToggle("prot_sr_en", { Text="Smart Riot", Default=false, Tooltip="Makes you harder to track." }):OnChanged(function(v)
    config.smart_riot_enabled = v
    play_toggle_sound()
    if v then
        local hrp = getgenv().get_hrp(localplayer)
        if hrp then smart_riot_origin = hrp.CFrame end
        getgenv().start_smart_riot()
    else
        getgenv().stop_smart_riot()
    end
end)

local BoxPerfectBlock = Tabs.Protection:AddRightGroupbox("Perfect Block")
BoxPerfectBlock:AddToggle("prot_pb_en", { Text="Perfect Block", Default=false, Tooltip="Blocks all shots with riot shield (don't disable)" }):OnChanged(function(v)
	config.perfect_block_enabled = v
	play_toggle_sound()
	if v then getgenv().start_perfect_block() else getgenv().stop_perfect_block() end
end)

local BoxKeybinds = Tabs.Settings:AddRightGroupbox("Keybinds")
local BoxSounds = Tabs.Settings:AddRightGroupbox("Sounds")
BoxSounds:AddToggle("snd_en", { Text="Enable Sounds", Default=false, Tooltip="Plays a sound whenever you toggle a feature." }):OnChanged(function(v)
 config.enable_sounds = v

end)

BoxSounds:AddDropdown("snd_sel", { Text="Select Sound", Default=1, Values={"Space", "Pop", "Bonk", "Skeet", "Neverlose", "Slip"} }):OnChanged(function(v)
 astral_sound_selected = v
 astral_toggle_sound.SoundId = astral_sound_ids[v] or astral_sound_ids.Space

end)

BoxSounds:AddSlider("snd_vol", { Text="Sound Volume", Default=50, Min=0, Max=100, Rounding=0, Suffix="%" }):OnChanged(function(v)
 astral_sound_volume = v / 100
 astral_toggle_sound.Volume = astral_sound_volume

end)

BoxSounds:AddButton("Test Sound", function()
 local prev = config.enable_sounds
 config.enable_sounds = true
 play_toggle_sound()
 config.enable_sounds = prev

end)

local MenuGroup = Tabs.Settings:AddLeftGroupbox("Menu")
local queue_on_teleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
local TeleportConnection
local scriptToQueue = 'loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/209ed0200ef18c47b8b2b23a6024a42b.lua"))()'
MenuGroup:AddToggle('AutoExecuteOnTeleport', {
    Text = 'Autoload Script',
    Default = false,
    Tooltip = 'Auto Executes the script for you',
    Callback = function(Value)
        if Value then
            if queue_on_teleport then
                queue_on_teleport(scriptToQueue)
            end
            TeleportConnection = game:GetService("Players").LocalPlayer.OnTeleport:Connect(function(State)
                if queue_on_teleport and (State == Enum.TeleportState.Started or State == Enum.TeleportState.InProgress) then
                    queue_on_teleport(scriptToQueue)
                end
            end)
        else
            if TeleportConnection then
                TeleportConnection:Disconnect()
                TeleportConnection = nil
            end
        end
    end
})
MenuGroup:AddToggle("KeybindMenuOpen", {
    Text = "Open Keybind Menu",
    Default = Library.KeybindFrame.Visible,
    Callback = function(value)
        Library.KeybindFrame.Visible = value
    end,
})
MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddButton("Unload", function() getgenv().unload_all() end)
Library.ToggleKeybind = (Library.Options or {}).MenuKeybind
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:SetFolder('meowlua private/themes')
SaveManager:SetFolder('meowlua private/configs')

ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
local _sm_orig_load = SaveManager.LoadConfig
SaveManager.LoadConfig = function(self, name)
	local ok, err = _sm_orig_load(self, name)
	task.defer(function()
		if config.void then
			getgenv().start_voidspam_type()
			buildXYZOverlay()
		else
			getgenv().stop_voidspam_type()
			destroyXYZOverlay()
		end
		if config.orbit then getgenv().start_orbit(); buildXYZOverlay() else getgenv().stop_orbit(); maybe_destroy_xyz() end
		if config.glue_enabled then getgenv().start_glue() else getgenv().stop_glue() end
		if config.evasion_enabled then getgenv().start_evasion() else getgenv().stop_evasion() end

		if config.godmode then getgenv().start_godmode() else getgenv().stop_godmode() end
		if config.kicia_counter_enabled then getgenv().start_kicia_counter() else getgenv().stop_kicia_counter() end
		if config.underground_enabled then getgenv().start_underground() else getgenv().stop_underground() end
		if config.translocation then start_translocation() else stop_translocation() end
		if config.nebula_counter_enabled then getgenv().start_nebula_counter() else getgenv().stop_nebula_counter() end
		if config.sleepyhub_counter_enabled then getgenv().start_sleepyhub_counter() else getgenv().stop_sleepyhub_counter() end
		if config.ue_counter_enabled then getgenv().start_ue_counter() else getgenv().stop_ue_counter() end
		if config.ragebot_bypass_enabled then getgenv().start_ragebot_bypass() else getgenv().stop_ragebot_bypass() end
		if config.hook_counter_enabled then getgenv().start_hook_counter() else getgenv().stop_hook_counter() end
		if config.fly_enabled then getgenv().start_fly() else getgenv().stop_fly() end
		if config.anti_aim then getgenv().start_body_manip() else getgenv().stop_body_manip() end

			if config.anti_translocation then getgenv().start_anti_translocation() else getgenv().stop_anti_translocation() end
		if config.smart_riot_enabled then getgenv().start_smart_riot() else getgenv().stop_smart_riot() end
		if config.anti_teleportation then getgenv().start_anti_teleportation() else getgenv().stop_anti_teleportation() end
		if config.rapid_fire then getgenv().start_rapid_fire() else getgenv().stop_rapid_fire() end

		if config.anti_afk_enabled then getgenv().start_anti_afk() else getgenv().stop_anti_afk() end
		if config.auto_collect then getgenv().start_autocollect() else getgenv().stop_autocollect() end
		if config.safe_zone_rescue then getgenv().start_safe_zone() else getgenv().stop_safe_zone() end
		if config.return_home then getgenv().start_return_home() else getgenv().stop_return_home() end
		if config.gun_bypass_enabled then getgenv().start_gun_bypass() else getgenv().stop_gun_bypass() end
		if config.autoshoot_enabled then getgenv().start_autoshoot() else getgenv().stop_autoshoot() end
		if config.bullet_redirect_enabled then getgenv().start_bullet_redirect() else getgenv().stop_bullet_redirect() end
		if config.slingshot_bypass then getgenv().start_slingshot_bypass() else getgenv().stop_slingshot_bypass() end

		if config.perfect_block_enabled then getgenv().start_perfect_block() else getgenv().stop_perfect_block() end
		if config.riot_abuser_enabled then getgenv().start_riot_abuser() else getgenv().stop_riot_abuser() end
		if config.riot_bypass_enabled then getgenv().start_riot_bypass() else getgenv().stop_riot_bypass() end
		if config.knife_bypass_enabled then getgenv().start_knife_bypass() else getgenv().stop_knife_bypass() end
		if config.slingshot_orbit then getgenv().start_slingshot_orbit() else getgenv().stop_slingshot_orbit() end
		if config.enable_sounds then
			astral_toggle_sound.SoundId = astral_sound_ids[astral_sound_selected] or astral_sound_ids.Space
			astral_toggle_sound.Volume = astral_sound_volume
		end
	end)
	return ok, err

end

localplayer.CharacterAdded:Connect(function()
 task.wait(0.3)
 if load_generation ~= getgenv().__meowlua_generation then return end
 config._gm_vs_elapsed = nil
 config._gm_vs_pos = nil
 config._gm_vs_drift = nil
 glue_destroy_constraint()
 glue_target_dirty = true
 glue_target_cache = nil
 glue_target_hrp = nil
 glue_target_head = nil
 if config.void then
  getgenv().stop_voidspam_type(true)
  task.wait(0.1)
  getgenv().start_voidspam_type()
  buildXYZOverlay()
 end
 if config.orbit then getgenv().stop_orbit(); task.wait(0.1); getgenv().start_orbit() end
 if config.anti_aim then getgenv().start_body_manip() end
 if config.glue_enabled then
  task.wait(0.2)
  glue_target_dirty = true
 end

end)

pcall(SaveManager.LoadAutoloadConfig, SaveManager)
ui_ready = true
 end, function(message) return tostring(message) end)
 if load_generation == getgenv().__meowlua_generation then
  getgenv().meowlua_loading = false
  getgenv().meowlua_loaded = ui_ok and ui_ready
  if not ui_ok or not ui_ready then
   getgenv().meowlua_last_error = tostring(ui_error or "ui initialization stopped")
  else
   getgenv().meowlua_last_error = nil
  end
 end

end)

task.delay(2, function()
	if getgenv().meowlua_last_error then
		warn("[meowlua] LOAD ERROR: " .. tostring(getgenv().meowlua_last_error))
	else
		print("[meowlua] Loaded successfully.")
	end

end)

return true
