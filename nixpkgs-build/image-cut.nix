{
	pkgs,
	stdenv,
	pname,
	image,
	height,
	width,
	basedOn ? "width",
	...
}:
# width or height
assert basedOn == "width" || basedOn == "height";
	stdenv.mkDerivation {
		inherit pname;
		name = pname;
		src = image;
		strictDeps = true;
		nativeBuildInputs = with pkgs; [imagemagick busybox];
		dontBuild = true;
		dontUnpack = true;
		installPhase = ''
			if [ "${basedOn}" = "width" ]; then
				width=$(identify -format "%w" "$src")
				height=$(echo "scale=0; $width * ${builtins.toString height} / ${builtins.toString width}" | bc)
			else
				height=$(identify -format "%h" "$src")
				width=$(echo "scale=0; $height * ${builtins.toString width} / ${builtins.toString height}" | bc)
			fi
			magick "$src" -gravity center -crop "''${width}x''${height}+0+0" +repage "$out"
		'';
	}
