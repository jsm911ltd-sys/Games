--!strict
-- Shared remotes accessor. On the server, creates remotes if missing.

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

export type Remotes = {
	Folder: Folder,
	RequestStep: RemoteEvent,
	StepCreated: RemoteEvent,
}

local function getOrCreateRemote(parent: Instance, className: string, name: string): Instance
	local inst = parent:FindFirstChild(name)
	if inst and inst.ClassName == className then
		return inst
	end
	if RunService:IsServer() then
		local newInst = Instance.new(className)
		newInst.Name = name
		newInst.Parent = parent
		return newInst
	else
		-- Client: wait for server to create
		local ok = parent:WaitForChild(name)
		return ok
	end
end

local function getFolder(): Folder
	local root = ReplicatedStorage
	local folder = root:FindFirstChild("Remotes")
	if not folder then
		if RunService:IsServer() then
			folder = Instance.new("Folder")
			folder.Name = "Remotes"
			folder.Parent = root
		else
			folder = root:WaitForChild("Remotes")
		end
	end
	local sub = folder:FindFirstChild("Stepping")
	if not sub then
		if RunService:IsServer() then
			sub = Instance.new("Folder")
			sub.Name = "Stepping"
			sub.Parent = folder
		else
			sub = folder:WaitForChild("Stepping")
		end
	end
	return sub :: Folder
end

local function getRemotes(): Remotes
	local folder = getFolder()
	local request = getOrCreateRemote(folder, "RemoteEvent", "RequestStep") :: RemoteEvent
	local created = getOrCreateRemote(folder, "RemoteEvent", "StepCreated") :: RemoteEvent
	return {
		Folder = folder,
		RequestStep = request,
		StepCreated = created,
	}
end

return getRemotes()

