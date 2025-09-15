--!strict

-- Centralized tunables for the Stepping Platforms feature.
-- Keep values data-driven and referenced by both client and server.

export type PlatformConfig = {
	Size: Vector3,
	Color: Color3,
	Material: Enum.Material,
	Transparency: number,
	Friction: number?,
	Elasticity: number?,
}

export type TrajectoryConfig = {
	FlightTime: number, -- seconds from source to final pose
}

export type ValidationConfig = {
	MaxDistance: number, -- studs from character root
	MaxHeightDelta: number, -- studs above/below root allowed
	MaxSurfaceAngleDeg: number, -- maximum allowed landing surface angle
}

export type PoolConfig = {
	InitialSize: number,
	MaxSize: number,
}

export type GhostConfig = {
	Color: Color3,
	Transparency: number,
}

export type StepConfig = {
	Platform: PlatformConfig,
	Trajectory: TrajectoryConfig,
	Validation: ValidationConfig,
	Pool: PoolConfig,
	Lifetime: number,
	Cooldown: number, -- seconds between allowed steps (soft cap; server validates rate)
	MaxStepsPerSecond: number,
	MaxBurst: number,
	Ghost: GhostConfig,
	StepLength: { Min: number, Max: number },
}

local Config: StepConfig = {
	Platform = {
		Size = Vector3.new(4, 0.4, 2),
		Color = Color3.fromRGB(86, 180, 255),
		Material = Enum.Material.SmoothPlastic,
		Transparency = 0.05,
		Friction = 0.2,
		Elasticity = 0,
	},

	Trajectory = {
		FlightTime = 0.15,
	},

	Validation = {
		MaxDistance = 24,
		MaxHeightDelta = 8,
		MaxSurfaceAngleDeg = 50,
	},

	Pool = {
		InitialSize = 24,
		MaxSize = 128,
	},

	Lifetime = 3.0,
	Cooldown = 0.15,
	MaxStepsPerSecond = 6,
	MaxBurst = 3,

	Ghost = {
		Color = Color3.fromRGB(190, 230, 255),
		Transparency = 0.6,
	},

	StepLength = { Min = 4, Max = 10 },
}

return Config

