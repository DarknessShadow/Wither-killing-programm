-- Version 1.4
-- by DarknessShadow

local component = require("component")
r = require("robot")
inv = component.inventory_controller

WitherSkeletonSkull = 0
WitherSkeletonSkullSizeFree = 6
SoulSand = 0
SoulSandSizeFree = 8
WardedGlass = 0
WardedGlassSizeFree = 2
dofile("saveAfterReboot.lua")

function writeSaveFile()
  f = io.open ("saveAfterReboot.lua", "w")
  f:write('NetherStar = ' .. NetherStar .. '\n')
  f:close ()
end

function placeWither()
  print("Spawning Wither")
  r.turnRight()
  r.forward()
  r.turnLeft()
  r.forward()
  r.forward()
  r.turnLeft()
  r.forward()
  r.turnRight()
  r.use()
  r.forward()
  r.forward()
  r.select(WitherSkeletonSkull)
  r.turnLeft()
  r.place()
  r.turnAround()
  r.place()
  r.down()
  r.select(SoulSand)
  r.place()
  r.turnAround()
  r.place()
  r.placeDown()
  r.up()
  r.placeDown()
  r.turnRight()
  r.back()
  r.select(WitherSkeletonSkull)
  r.place()
  r.back()
  r.select(WardedGlass)
  r.place()
  r.turnLeft()
  r.forward()
  r.turnLeft()
  r.forward()
  r.forward()
  r.turnLeft()
  r.forward()
  r.turnLeft()
end

function checkWand()
  item = inv.getStackInInternalSlot(13)
  r.select(13)
  if item then
    if item.name == "Thaumcraft:WandCasting" then
      inv.equip()
      return true
    end
  else
    inv.equip()
    item = inv.getStackInInternalSlot(13)
    if item then
      if item.name == "Thaumcraft:WandCasting" then
        inv.equip()
        return true
      else
        return false
      end
    end
  end
end

function checkInventory()
  for i = 1, 16 do
    item = inv.getStackInInternalSlot(i)
    if item then
      name = item.name .. ":" .. item.damage
      if "minecraft:skull:1" == name then
        if 3 <= item.size then
          WitherSkeletonSkull = i
        end
        WitherSkeletonSkullSizeFree = 6 - item.size
      end
      if "minecraft:soul_sand:0" == name then
        if 4 <= item.size then
          SoulSand = i
        end
        SoulSandSizeFree = 8 - item.size
      end
      if "Thaumcraft:blockCosmeticOpaque:2" == name then
        if 1 <= item.size then
         WardedGlass = i
        end
        WardedGlassSizeFree = 2 - item.size
      end
    end
  end
end

function invRefill()
  for i = 1, inv.getInventorySize(0) do
    item = inv.getStackInSlot(0, i)
    if item then
      name = item.name .. ":" .. item.damage
      if "minecraft:skull:1" == name then
        if WitherSkeletonSkull == 0 then
          r.select(1)
        else
          r.select(WitherSkeletonSkull)
        end
        inv.suckFromSlot(0, i, WitherSkeletonSkullSizeFree)
      end
      if "minecraft:soul_sand:0" == name then
        if SoulSand == 0 then
          r.select(1)
        else
          r.select(SoulSand)
        end
        inv.suckFromSlot(0, i, SoulSandSizeFree)
      end
      if "Thaumcraft:blockCosmeticOpaque:2" == name then
        if WardedGlass == 0 then
          r.select(1)
        else
          r.select(WardedGlass)
        end
        inv.suckFromSlot(0, i, WardedGlassSizeFree)
      end
    end
  end
end

function reset()
  WitherSkeletonSkull = 0
  WitherSkeletonSkullSizeFree = 64
  SoulSand = 0
  SoulSandSizeFree = 64
  WardedGlass = 0
  WardedGlassSizeFree = 64
end

function main()
  while running do
    if checkWand() == true then
      checkInventory()
      invRefill()
      checkInventory()
      if WitherSkeletonSkull == 0 or SoulSand == 0 or WardedGlass == 0 then
        print("Waiting 5min")
        os.sleep(300)
      else
        placeWither()
        WaitForNetherStar()
      end
      reset()
      print("Nether Stars Collected: " .. NetherStar)
    else
      print("Insert wand into tool slot")
      print("Waiting 1min")
      os.sleep(60)
    end
    print("")
  end
end

function WaitForNetherStar()
  wait = true
  print("Waiting for Nether Star")
  os.sleep(20)
  while wait do
    for i = 1, inv.getInventorySize(3) do
      item = inv.getStackInSlot(3, i)
      if item then
        name = item.name .. ":" .. item.damage
        if "minecraft:nether_star:0" == name then
          r.select(16)
          inv.suckFromSlot(3, i)
          NetherStar = NetherStar + 1
          writeSaveFile()
          for j = 1, inv.getInventorySize(0) do
            inv.dropIntoSlot(0, j)
          end
          wait = false
          break
        end
      end
    end
  end
end

running = true

main()
