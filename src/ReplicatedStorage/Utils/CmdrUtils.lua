type Arg = {
	Type: string,
	Name: string,
	Description: string,
	Default: any,
}

export type Group = "Admin"

export type CMD = {
	Name: string,
	Aliases: { string },
	Description: string,
	Group: string | Group,
	Args: { Arg },
}

return nil
