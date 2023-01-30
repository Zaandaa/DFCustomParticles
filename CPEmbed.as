/*
EMBED INSTRUCTIONS
keep this file named "CPEmbed.as" in the same directory as CustomParticles.as
place image files in embed_src
fill out info in this file
1. add file path strings
2. add sprite_name to build_list array
3. add details to dictionary
in the level scripts menu, add CustomParticles.as

when editing the spawn trigger, set the following values:
sprite_name: same as EMBED_ variables, same as the EmbedData list and dictionary keys ("cloud", "large")
sprite_set: this value is ignored for embeds
sprite_frame: 0
sprite_palette: 0

*/

// example no animation
// EMBED_ + SPRITE NUMBER
// "sprites" = 3, each sprite is a different option that can be spawned
const string EMBED_cloud0 = "sprites/cloud0.png";
const string EMBED_cloud1 = "sprites/cloud1.png";
const string EMBED_cloud2 = "sprites/cloud2.png";
const string EMBED_cloud3 = "sprites/cloud3.png";
const string EMBED_cloud4 = "sprites/cloud4.png";

// example animation
// EMBED_ + NAME + SPRITE NUMBER + _ + ANIMATION FRAME
// first number refers to which sprite it is, second number animation frame for that sprite
// this group has "sprites" = 1 because it has "0" as the only option, but "anim_frames" = 8
// all sprites in the same group must have the same number of animation frame images
const string EMBED_large0_0 = "sprites/f0_0.png";
const string EMBED_large0_1 = "sprites/f0_1.png";
const string EMBED_large0_2 = "sprites/f0_2.png";
const string EMBED_large0_3 = "sprites/f0_3.png";
const string EMBED_large0_4 = "sprites/f0_4.png";
const string EMBED_large0_5 = "sprites/f0_5.png";
const string EMBED_large0_6 = "sprites/f0_6.png";
const string EMBED_large0_7 = "sprites/f0_7.png";

class EmbedData {
	EmbedData() {}

	array<string> get_build_list() {
		// list all sprites to build here
		return array<string> = {"cloud", "large"};
	}

	dictionary get_info() {
		return dictionary = {
			{"cloud", dictionary = {
				{"sprites", 5},
				{"offsetx", 128},
				{"offsety", 128},
				{"animate", false},
				{"anim_frames", 1}, // default false animate values
				{"anim_loop", true},
				{"anim_rate", 1}
			}},
			{"large", dictionary = {
				{"sprites", 1},
				{"offsetx", 96},
				{"offsety", 96},
				{"animate", true},
				{"anim_frames", 8}, // int: matches above list of files
				{"anim_loop", true}, // if false, it ignores anim_rate and animation speed matches particle lifespan
				{"anim_rate", 5} // int: in-game frames per animation frame (at 60 fps)
			}}
		};
	}
}
