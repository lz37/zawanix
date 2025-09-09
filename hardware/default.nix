{
	modulesPath,
	hostName,
	isNvidiaGPU,
	lib,
	...
}: {
	imports =
		[
			(modulesPath + "/installer/scan/not-detected.nix")
		]
		++ [
			(./. + "/hostname/${hostName}.nix")
		]
		++ (lib.optionals isNvidiaGPU [./nvidia/gpu.nix]);
}
